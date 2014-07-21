'use strict'
mysql   = require 'mysql'
Q       = require 'q'
restify = require 'restify'
logger  = require './logger'

connection = null

connect = () ->
    logger.info 'Connecting to DB'
    dbString = process.env.DATABASE
    dbVars = []
    if dbString
        dbVars = dbString.split(':')
    else
        dbVars = ['localhost', 3306]

    connection = mysql.createPool
        host: dbVars[0],
        port: dbVars[1],
        user: 'reputation',
        password: 'reputation',
        database: 'reputation',
        connectionLimit: 10

connect()

query = ( txt, args = [] ) ->
    logger.silly "Query!", txt, args, connection?
    connect() unless connection?
    Q.ninvoke( connection, 'query', txt, args ).then (res) -> res[0]

cache =
    actionTypes: {}
    actions: {}
    skills: {}
    users: {}

getCacheItem = ( key, name ) ->
    cacheItem = cache[ key ][ name ]
    if cacheItem != undefined
        logger.silly 'Cache hit for %s["%s"]', key, name
        return Q( cacheItem )
    logger.silly 'Cache miss for %s["%s"]', key, name
    query( 'SELECT `ID` FROM ?? WHERE `Name` = ?', [ key, name ] ).then (results) ->
        logger.silly "Got item: %j", results, {}
        cache[ key ][ name ] = results[0]?.ID || false

getCacheAction = ( name ) ->
    cacheItem = cache[ 'actions' ][ name ]
    if cacheItem != undefined
        logger.silly 'Cache hit for actions["%s"]', name
        return Q( cacheItem )
    logger.silly 'Cache miss for actions["%s"]', name
    query( 'SELECT `Action` FROM actionMap WHERE `Name` = ?', [ name ] ).then (results) ->
        logger.silly "Got action: %j", results, {}
        cache[ 'actions' ][ name ] = results[0]?.Action || false

getCacheUser = ( UUID ) ->
    cacheUser = cache[ 'users' ][ UUID ]
    if cacheUser != undefined
        logger.silly 'Cache hit for users["%s"]', UUID
        return Q( cacheUser )
    logger.silly 'Cache miss for users["%s"]', UUID
    query( 'SELECT `ID` FROM ?? WHERE `UUID` = ?', [ 'users', UUID ] ).then (results) ->
        logger.silly "Got user: %j", results, {}
        cache[ 'users' ][ UUID ] = results[0]?.ID || false

reqParam = ( req, next, p ) ->
    unless req.params[ p ]?
        next new restify.MissingParameterError "'#{p}' is required!"
        return false
    return true

getRecommendations = ( req, res, next, queryString ) ->
    return unless reqParam( req, next, 'user' )
    return unless reqParam( req, next, 'names' )

    logger.verbose '%s: Getting recommendations for %s %s', req.id, req.params.user, req.params.names

    Q(
        getCacheUser req.params.user
    ).then( ( userID ) ->
        return next new restify.InvalidArgumentError "Unknown user '#{req.params.user}'" unless userID
        query queryString, [ userID, userID, req.params.names ]
    )
    .then( (wat) ->

        if not wat instanceof Array
            return
        req.params.names = req.params.names.map ( name ) -> decodeURIComponent( name )

        results = []

        if wat.length < 1
            results = req.params.names.map ( name ) -> { Name: name, Done: 0, Referenced: 0, Probability: Math.floor( 100 / req.params.names.length ) / 100 }
        else
            found_sum = wat.reduce ( ( total, oneWat) -> total + ( oneWat.Done || 0 ) + ( oneWat.Referenced || 0 ) ), 0
            results = req.params.names.map ( name ) ->
                found = false
                for oneWat in wat
                    if oneWat.Name.toLowerCase() == name.toLowerCase()
                        found = oneWat
                        break
                if found
                    found.Probability = Math.floor( ( ( found.Done || 0 ) + ( found.Referenced || 0 ) ) / found_sum * 100) / 100
                    return found
                else
                    return { Name: name, Done: 0, Referenced: 0, Probability: 0 }

        logger.debug '%s: Sending recommendations:\n%j', req.id, results, {}
        res.send 200, results
        return results

    )
    .fail( (whoops) ->
        whoops = whoops.toString()
        logger.error '%s: Couldn\'t req.id, get recommendations: %s', whoops
        res.send 500, "Shit broke: " + whoops
    )
    .finally(next)
    .done()

exports.addUser = ( req, res, next ) ->
    return unless reqParam( req, next, 'id' )
    logger.verbose '%s: Adding user %s', req.id, req.params.id
    query("INSERT INTO `users` SET ?", { UUID: req.params.id })
    .then( (wat) ->
        logger.debug '%s: Added user', req.id
        res.send 204
    )
    .fail( (whoops) ->
        whoops = whoops.toString()
        logger.error '%s: Could not add user: %s', req.id, whoops
        res.send 500, "Shit broke: " + whoops
    )
    .finally(next)
    .done()

exports.addSkill = ( req, res, next ) ->
    return unless reqParam( req, next, 'name' )
    logger.verbose '%s: Adding user %s', req.id, req.params.name
    query("INSERT INTO `skills` SET ?", { Name: req.params.name })
    .then( (wat) ->
        logger.debug '%s: Added skill', req.id
        res.send 204
    )
    .fail( (whoops) ->
        whoops = whoops.toString()
        logger.error '%s: Could not add skill: %s', req.id, whoops
        res.send 500, "Shit broke: " + whoops
    )
    .finally(next)
    .done()

exports.getUserRank = ( req, res, next ) ->
    return unless reqParam( req, next, 'user' )
    logger.verbose '%s: User Rank Reqest for %s', req.id, req.params.user
    userRankQuery = "
        SELECT
            COUNT(*) as rank
        FROM
            (SELECT COUNT(*) as points, User FROM activities GROUP BY User) ui,
            (SELECT COUNT(*) as points, User FROM activities GROUP BY User) uo
        WHERE
            (ui.points, ui.User) >= (uo.points, uo.User) AND uo.User = ?"

    Q( getCacheUser req.params.user )
    .then( ( userID ) ->
        return next new restify.InvalidArgumentError "Unknown user '#{req.params.user}'" unless userID
        query userRankQuery, [ userID ]
    )
    .then( (wat) ->
        if wat.length > 0
            wat = wat[0]
        logger.debug '%s: Sending user ranks:\n%j', req.id, wat, {}
        res.send 200, wat
    )
    .fail( (whoops) ->
        whoops = whoops.toString()
        logger.error '%s: Get user rank failed', req.id, whoops
        res.send 500, "Shit broke: " + whoops
    )
    .finally(next)
    .done()

# /api/activities/perform
# json payload
# {  }
exports.performActivity = ( req, res, next ) ->
    return unless reqParam( req, next, 'type' ) and reqParam( req, next, 'target' ) and reqParam( req, next, 'activator' )

    logger.verbose '%s: Activity performed: %s in %s by %s', req.id, req.params.type, req.params.target, req.params.activator

    abort = false

    butts = for skill in req.params.target.tags
        Q.all([
            getCacheAction req.params.target.type
            getCacheItem 'skills', skill
            getCacheUser req.params.activator.id
        ]).spread( ( actionID, skillID, userID ) ->
            logger.silly "%s: , req.idGot IDs: %j", arguments, {}
            if not actionID
                next new restify.InvalidArgumentError "Unknown action type '#{req.params.type}'"
                abort = true
                return
            else if not skillID
                next new restify.InvalidArgumentError "Unknown target '#{skill}'"
                abort = true
                return
            else if not userID
                next new restify.InvalidArgumentError "Unknown user '#{req.params.activator}'"
                abort = true
                return
            query "INSERT INTO `activities` SET ?", [{
                User: userID
                Action: actionID
                Skill: skillID
                Reference: req.params.target.id
            }]
        )
    Q.all(butts)
    .then( (wat) ->
        if abort
            query "INSERT INTO `allactivities` SET ?", [{
                User: req.params.activator.id
                Action: req.params.target.type
                Skill: req.params.target.tags
                Reference: req.params.target.id
                Blob: JSON.stringify req.params
                }]
            return
        logger.debug '%s: Activity inserted', req.id
        res.send 204
    )
    .fail( (whoops) ->
        whoops = whoops.toString()
        logger.error '%s: Could not insert activity: %s', req.id, whoops
        res.send 500, "Shit broke: " + whoops
    )
    .finally(next)
    .done()

# FIXME: actions.actionType = 3 OR actions.ID = 14 seems very specific to logquest, needs some redesign
exports.skillsDistribution = ( req, res, next ) ->
    distributionQuery = "
        SELECT
            skills.Name as Skill, actions.Name as Action, COUNT(*) as Count
        FROM
            activities
        JOIN actions ON
            ( actions.actionType = 3 OR actions.ID = 14 ) AND activities.Action = actions.ID
        JOIN skills ON
            activities.Skill = skills.ID"
    if req.params.skills and req.params.skills instanceof Array
        distributionQuery += " AND skills.Name IN ('" + req.params.skills.join("','") + "')"
    if req.params.user
        distributionQuery += " JOIN users ON activities.User = users.ID AND User = ?"
    distributionQuery += " GROUP BY
            activities.Skill, activities.Action, activities.User"

    if req.params.user
        logger.verbose '%s: Skill distribution query for %s', req.id, req.params.user
        promise = Q( getCacheUser req.params.user )
            .then( ( userID ) ->
                return next new restify.InvalidArgumentError "Unknown user '#{req.params.user}'" unless userID
                query distributionQuery, [ userID ]
            )
    else
        logger.verbose '%s: Skill distribution query for everyone', req.id
        promise = query distributionQuery

    promise.then( (wat) ->
        results = []

        if wat.length > 0
            total = 0
            sums = {}
            skills = {}

            getSkill = (name) ->
                return skills[name] ||= {
                    name: name
                    count: 0
                    fraction: 0
                    # Competitive
                    rank: 0 # FIXME
                    contribution: 0 # FIXME
                    # Collaborative
                    contributors: 0
                    types: {}
                    fractions: {}
                }

            for row in wat
                name = row.Skill
                action = row.Action
                skill = getSkill name
                skill.types[action] = (skill.types[action] || 0) + row.Count
                sums[name] = (sums[name] || 0) + row.Count
                total += row.Count
                skill.contributors += 1

            for name, data of skills
                sum = sums[name]
                data.count = sum
                data.fraction = Math.floor( (sum / total) * 100 ) / 100
                for action, count of data.types
                    data.fractions[action] = Math.floor( (count / sum) * 100 ) / 100

            results = (skill for name,skill of skills)


        logger.debug '%s: Sending skill distribution:\n%j', req.id, results, {}
        res.send 200, results
        return results

    )
    .fail( (whoops) ->
        whoops = whoops.toString()
        logger.error '%s: Couldn\'t get skill distribution: %s', req.id, whoops
        res.send 500, "Shit broke: " + whoops
    )
    .finally(next)
    .done()

exports.skillsContribution = ( req, res, next ) ->
    return unless reqParam( req, next, 'user' )
    logger.verbose '%s: Skills contribution request for %s', req.id, req.params.user
    distributionQuery = "
        SELECT
            skills.Name as Skill, COUNT(*) as Count, activities.User
        FROM
            activities
        JOIN actions ON
            ( actions.actionType = 3 OR actions.ID = 14 ) AND activities.Action = actions.ID
        JOIN skills ON
            activities.Skill = skills.ID
        GROUP BY
            activities.Skill, activities.User
        ORDER BY Skill, Count DESC"

    user_id = null
    Q( getCacheUser req.params.user )
    .then( ( userID ) ->
        return next new restify.InvalidArgumentError "Unknown user '#{req.params.user}'" unless userID
        user_id = userID
        query distributionQuery, [ userID ]
    ).then( (wat) ->
        results = {}
        rank = 1
        previousSkill = ''

        if wat.length > 0 && user_id
            for row in wat
                if row.Skill != previousSkill
                    rank = 1
                previousSkill = row.Skill

                if row.User == user_id
                    results[row.Skill] =
                        rank: rank
                        contribution: row.Count
                    rank = 1
                else
                    rank++

        logger.debug '%s: Sending skill contributions:\n%j', req.id, results, {}
        res.send 200, results
        return results

    )
    .fail( (whoops) ->
        whoops = whoops.toString()
        logger.error '%s: Couldn\'t get skill contributions: %s', req.id, whoops
        res.send 500, "Shit broke: " + whoops
    )
    .finally(next)
    .done()

exports.userNumber = ( req, res, next ) ->
    logger.verbose '%s: User Number Request', req.id
    userNumberQuery = "
        SELECT
            skills.Name as Skill, COUNT(DISTINCT activities.User) as Count
        FROM
            activities
        JOIN actions ON
            ( actions.actionType = 3 OR actions.ID = 14 ) AND activities.Action = actions.ID
        JOIN skills ON
            activities.Skill = skills.ID
        GROUP BY
            activities.Skill"

    Q( query userNumberQuery )
    .then( (wat) ->
        result = {}
        if wat.length > 0
            for row in wat
                result[row.Skill] = row.Count

        logger.debug '%s: Sending skill user number:\n%j', req.id, result, {}
        res.send 200, result
        return result

    )
    .fail( (whoops) ->
        whoops = whoops.toString()
        logger.error '%s: Couldn\'t get user number: %s', req.id, whoops
        res.send 500, "Shit broke: " + whoops
    )
    .finally(next)
    .done()

exports.skillsCounts = ( req, res, next ) ->
    console.log req.params
    # Why is this here but no where else?
    connect() unless connection?
    countsQuery = "
        SELECT
            skills.Name as Skill, COUNT(activities.Key) as Count
        FROM
            activities
        JOIN actions ON ( actions.actionType = 3 OR actions.ID = 14 ) AND actions.ID = activities.Action
        JOIN skills ON skills.ID = activities.Skill"
    if req.params.user
        countsQuery += " JOIN users ON users.UUID = " + connection.escape(req.params.user) + " AND users.ID = activities.User"
    countsQuery += " WHERE 1=1"
    if req.params.dateFrom
        countsQuery += " AND activities.Date >= " + connection.escape(req.params.dateFrom)
    if req.params.dateTo
        countsQuery += " AND activities.Date <= " + connection.escape(req.params.dateTo)
    countsQuery += " GROUP BY
            activities.Skill ORDER BY Count DESC, activities.Skill ASC"

    logger.verbose '%s: Skills Counts Requests: %s, %s, %s', req.id, req.params.user, req.params.dateFrom, req.params.dateTo

    query( countsQuery )
    .then( (wat) ->
        results = {}
        wat.forEach ( oneWat ) ->
            results[oneWat.Skill] = oneWat.Count

        logger.debug '%s: Sending skills counts:\n%j\n', req.id, results, {}
        res.send 200, results
        return results

    )
    .fail( (whoops) ->
        whoops = whoops.toString()
        logger.error '%s: Couldn\'t get skills count: %s', req.id, whoops
        res.send 500, "Shit broke: " + whoops
    )
    .finally(next)
    .done()

exports.getContributionStatistics = ( req, res, next ) ->
    connect() unless connection?
    countsQuery = "
        SELECT
            skills.Name as Skill, COUNT(activities.Key) as Count, users.UUID
        FROM
            activities
        JOIN actions ON ( actions.actionType = 3 OR actions.ID = 14 ) AND actions.ID = activities.Action
        JOIN skills ON skills.ID = activities.Skill
        JOIN users ON users.ID = activities.User"
    countsQuery += " WHERE 1=1"
    if req.params.dateFrom
        countsQuery += " AND activities.Date >= " + connection.escape(req.params.dateFrom)
    if req.params.dateTo
        countsQuery += " AND activities.Date <= " + connection.escape(req.params.dateTo)
    countsQuery += " GROUP BY
            activities.Skill, activities.User
            ORDER BY activities.Skill ASC, Count DESC"

    logger.verbose '%s: User contributions statistics Request: %s, %s', req.id, req.params.dateFrom, req.params.dateTo

    query( countsQuery )
    .then( (wat) ->
        users = {}
        totalContributions = {total:0, skills:{}}
        contributors = {}
        rank = 1
        previousSkill = ''
        rankings = []

        if wat.length > 0
            wat.forEach ( row ) ->
                if row.Skill != previousSkill
                    contributors[row.Skill] = 0
                    rank = 1
                previousSkill = row.Skill
                users[row.UUID] = users[row.UUID] || { rank:0, contribution:0, contributionFraction:0, skills:{} }
                users[row.UUID].contribution += row.Count

                users[row.UUID].skills[row.Skill] = { skill:row.Skill, rank: rank, contribution:row.Count, contributionFraction:0 }

                totalContributions.total += row.Count
                totalContributions.skills[row.Skill] = ( totalContributions.skills[row.Skill] || 0 ) + row.Count
                contributors[row.Skill]++
                rank++

            for UUID, user of users
                rankings.push { user:UUID, contribution:user.contribution }
                user.contributionFraction = Math.floor( ( user.contribution / totalContributions.total ) * 100 ) / 100
                for skillName, skill of user.skills
                    skill.contributors = contributors[skillName]
                    skill.contributionFraction = Math.floor( ( skill.contribution / totalContributions.skills[skillName] ) * 100 ) / 100

            rankings.sort (a, b) ->
                if a.contribution < b.contribution
                    return 1
                else if a.contribution > b.contribution
                    return -1
                return 0


            for rankObj, rank in rankings
                users[rankObj.user].rank = rank+1


        logger.debug '%s: Sending users contribution statistics:\n%j', req.id, users, {}
        res.send 200, users
        return users

    )
    .fail( (whoops) ->
        whoops = whoops.toString()
        logger.error '%s: Couldn\'t get contribution statistics: %s', req.id, whoops
        res.send 500, "Shit broke: " + whoops
    )
    .finally(next)
    .done()

exports.recommendSkills = ( req, res, next ) ->
    logger.verbose '%s: Skill Recommendations Reqest for %s in %j', req.id, req.params.user, req.params.names, {}
    statisticsQuery = "
        SELECT skills.Name, b1.Done, b2.Referenced FROM
            (
            SELECT
                Skill, COUNT(*) as Done
            FROM
                activities
            WHERE
                User = ?
            GROUP BY
                Skill
            ) b1
        LEFT OUTER JOIN
            (
            SELECT
                a1.Skill, COUNT(*) as Referenced
            FROM
                (SELECT * FROM activities WHERE User = ?) a1 LEFT OUTER JOIN activities a2
            ON
                ( a1.User != a2.User AND a1.Reference=a2.Reference )
            WHERE
                a2.Key IS NOT NULL
            GROUP BY a1.Skill
            ) b2
        ON b1.Skill = b2.Skill JOIN skills ON skills.ID = b1.Skill AND skills.Name IN (?)
        ORDER BY IFNULL(b1.Done, 0)+IFNULL(b2.Referenced, 0) DESC" # maybe move user=? to later WHERE

    getRecommendations req, res, next, statisticsQuery

exports.recommendActions = ( req, res, next ) ->
    logger.verbose '%s: Action Recommendations Reqest for %s in %j', req.id, req.params.user, req.params.names, {}
    statisticsQuery = "
        SELECT actions.Name, b1.Done, b2.Referenced FROM
            (
            SELECT
                Action, COUNT(*) as Done
            FROM
                activities
            WHERE
                User = ?
            GROUP BY
                Action
            ) b1
        LEFT OUTER JOIN
            (
            SELECT
                a1.Action, COUNT(*) as Referenced
            FROM
                (SELECT * FROM activities WHERE User = ?) a1 LEFT OUTER JOIN activities a2
            ON
                ( a1.User != a2.User AND a1.Reference=a2.Reference )
            WHERE
                a2.Key IS NOT NULL
            GROUP BY a1.Action
            ) b2
        ON b1.Action = b2.Action JOIN actions ON actions.ID = b1.Action AND actions.Name IN (?)
        ORDER BY IFNULL(b1.Done, 0)+IFNULL(b2.Referenced, 0) DESC"

    getRecommendations req, res, next, statisticsQuery

exports.recommendActionTypes = ( req, res, next ) ->
    logger.verbose '%s: ActionType Recommendations Reqest for %s in %j', req.id, req.params.user, req.params.names, {}
    statisticsQuery = "
        SELECT actionTypes.Name, SUM(b1.Done) as Done, SUM(b2.Referenced) as Referenced FROM
            (
            SELECT
                Action, COUNT(*) as Done
            FROM
                activities
            WHERE
                User = ?
            GROUP BY
                Action
            ) b1
        LEFT OUTER JOIN
            (
            SELECT
                a1.Action, COUNT(*) as Referenced
            FROM
                (SELECT * FROM activities WHERE User = ?) a1 LEFT OUTER JOIN activities a2
            ON
                ( a1.User != a2.User AND a1.Reference=a2.Reference )
            WHERE
                a2.Key IS NOT NULL
            GROUP BY a1.Action
            ) b2
        ON b1.Action = b2.Action JOIN (actions, actionTypes) ON (actions.ID = b1.Action AND actions.ActionType = actionTypes.ID) AND actionTypes.Name IN (?)
        GROUP BY actions.ActionType
        ORDER BY IFNULL(b1.Done, 0)+IFNULL(b2.Referenced, 0) DESC"

    getRecommendations req, res, next, statisticsQuery


# TODO: which query is faster

# SELECT users.UUID as User, skills.Name as Skill, COUNT(activities.Key) as Count FROM activities, skills, users WHERE users.ID = activities.User AND skills.ID = activities.Skill GROUP BY activities.User, activities.Skill ORDER BY activities.User, Count DESC
# SELECT users.UUID, skills.Name, Count FROM skills, users, (SELECT *, COUNT(*) as Count FROM activities GROUP BY activities.User, activities.Skill ORDER BY activities.User, Count DESC) as tmp WHERE users.ID = tmp.User AND skills.ID = tmp.Skill

# SELECT users.UUID, actions.Name, COUNT(activities.Key) as Count FROM activities, actions, users WHERE users.ID = activities.User AND actions.ID = activities.Action GROUP BY activities.User, activities.Action ORDER BY activities.User, Count DESC

# SELECT users.UUID, actionTypes.Name, COUNT(activities.Key) as Count FROM activities, actions, users, actionTypes WHERE users.ID = activities.User AND actions.ActionType = actionTypes.ID AND actions.ID = activities.Action GROUP BY activities.User, actions.ActionType ORDER BY activities.User, Count DESC

# SELECT a1.*, COUNT(*) as selfRefs, SUM(numOfRefs) FROM (SELECT a1.*, COUNT(a2.Reference) as numOfRefs FROM (SELECT * FROM activities WHERE User=1) a1 LEFT OUTER JOIN activities a2 ON ( a2.Reference IS NOT NULL AND a1.Key=a2.Reference ) GROUP BY a1.Key) as a1 GROUP BY a1.Action
