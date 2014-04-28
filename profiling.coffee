'use strict'
mysql   = require 'mysql'
Q       = require 'q'
restify = require 'restify'

connection = null

connect = () ->
    console.log 'Connecting to DB'
    dbString = process.env.DATABASE
    dbVars = []
    if dbString
        dbVars = dbString.split(':')
    else
        dbVars = ['localhost', 3306]

    connection = mysql.createConnection
        host: dbVars[0],
        port: dbVars[1],
        user: 'reputation',
        password: 'reputation',
        database: 'reputation'

    connection.on "error", (e) ->
        if e.code != 'PROTOCOL_CONNECTION_LOST'
            throw e;
        connect()


query = ( txt, args = [] ) ->
    console.log "Query!", txt, args, connection?
    Q.ninvoke( connection, 'query', txt, args ).then (res) -> res[0]

cache =
    actionTypes: {}
    actions: {}
    skills: {}
    users: {}

getCacheItem = ( key, name ) ->
    cacheItem = cache[ key ][ name ]
    console.log "cache get", key, name
    if cacheItem != undefined
        return Q( cacheItem )
    query( 'SELECT `ID` FROM ?? WHERE `Name` = ?', [ key, name ] ).then (results) ->
        console.log "Results!", results
        cache[ key ][ name ] = results[0]?.ID || false

getCacheAction = ( name ) ->
    cacheItem = cache[ 'actions' ][ name ]
    console.log "cache get actions", name
    if cacheItem != undefined
        return Q( cacheItem )
    query( 'SELECT `Action` FROM actionMap WHERE `Name` = ?', [ name ] ).then (results) ->
        console.log "Results!", results
        cache[ 'actions' ][ name ] = results[0]?.Action || false

getCacheUser = ( UUID ) ->
    cacheUser = cache[ 'users' ][ UUID ]
    console.log "cache get", 'users', UUID
    if cacheUser != undefined
        return Q( cacheUser )
    query( 'SELECT `ID` FROM ?? WHERE `UUID` = ?', [ 'users', UUID ] ).then (results) ->
        console.log "Results!", results
        cache[ 'users' ][ UUID ] = results[0]?.ID || false

reqParam = ( req, next, p ) ->
    unless req.params[ p ]?
        next new restify.MissingParameterError "'#{p}' is required!"
        return false
    return true

getRecommendations = ( req, res, next, queryString ) ->
    return unless reqParam( req, next, 'user' )
    return unless reqParam( req, next, 'names' )

    Q(
        getCacheUser req.params.user
    ).then( ( userID ) ->
        return next new restify.InvalidArgumentError "Unknown user '#{req.params.user}'" unless userID
        query queryString, [ userID, userID, req.params.names ]
    )
    .then( (wat) ->

        if not wat instanceof Array
            return

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

        console.log "woop", results
        res.send 200, results
        return results

    )
    .fail( (whoops) ->
        console.error "arse", whoops
        res.send 500, "Shit broke: " + whoops
    )
    .finally(next)
    .done()

exports.addUser = ( req, res, next ) ->
    return unless reqParam( req, next, 'id' )
    query("INSERT INTO `users` SET ?", { UUID: req.params.id })
    .then( (wat) ->
        console.log "woop", wat
        res.send 204
    )
    .fail( (whoops) ->
        console.error "arse", whoops
        res.send 500, "Shit broke: " + whoops
    )
    .finally(next)
    .done()

# /api/activities/perform
# json payload
# {  }
exports.performActivity = ( req, res, next ) ->
    console.log "got call!"

    return unless reqParam( req, next, 'type' ) and reqParam( req, next, 'target' ) and reqParam( req, next, 'activator' )

    butts = for skill in req.params.target.tags
        Q.all([
            getCacheAction req.params.type
            getCacheItem 'skills', skill
            getCacheUser req.params.activator.id
        ]).spread( ( actionID, skillID, userID ) ->
            console.log "Got IDs", arguments
            return next new restify.InvalidArgumentError "Unknown action type '#{req.params.type}'" unless actionID
            return next new restify.InvalidArgumentError "Unknown target '#{skill}'" unless skillID
            return next new restify.InvalidArgumentError "Unknown user '#{req.params.activator}'" unless userID
            query "INSERT INTO `activities` SET ?", [{
                User: userID
                Action: actionID
                Skill: skillID
                Reference: req.params.target.id
            }]
        )
    Q.all(butts)
    .then( (wat) ->
        console.log "woop", wat
        res.send 204
    )
    .fail( (whoops) ->
        console.error "arse", whoops
        res.send 500, "Shit broke: " + whoops
    )
    .finally(next)
    .done()

exports.skillsDistribution = ( req, res, next ) ->
    distributionQuery = "
        SELECT
            skills.Name as Skill, actions.Name as Action, COUNT(*) as Count
        FROM
            activities
        JOIN actions ON
            actions.actionType = 3 AND activities.Action = actions.ID
        JOIN skills ON
            activities.Skill = skills.ID"
    if req.params.user
        distributionQuery += " JOIN users ON activities.User = users.ID AND User = ?"
    distributionQuery += " GROUP BY
            activities.Skill, activities.Action"

    if req.params.user
        promise = Q( getCacheUser req.params.user )
            .then( ( userID ) ->
                return next new restify.InvalidArgumentError "Unknown user '#{req.params.user}'" unless userID
                query distributionQuery, [ userID ]
            )
    else
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
                    contributors:
                        num: 0 # FIXME
                        max: 0 # FIXME
                    types: {}
                    fractions: {}
                }

            for row in wat
                name = row.Skill
                action = row.Action
                skill = getSkill name
                skill.types[action] = row.Count
                sums[name] = sums[name] || 0
                sums[name] += row.Count
                total += row.Count

            for name, data of skills
                sum = sums[name]
                data.count = sum
                data.fraction = Math.floor( (sum / total) * 100 ) / 100
                for action, count of data.types
                    data.fractions[action] = Math.floor( (count / sum) * 100 ) / 100

            results = (skill for name,skill of skills)


        console.log "Skill distribution success!\n", results
        res.send 200, results
        return results

    )
    .fail( (whoops) ->
        console.error "Skill distribution fail!\n", whoops
        res.send 500, "Shit broke: " + whoops
    )
    .finally(next)
    .done()

exports.skillsCounts = ( req, res, next ) ->
    console.log req.params
    connect() unless connection?
    countsQuery = "
        SELECT
            skills.Name as Skill, COUNT(activities.Key) as Count
        FROM
            activities
        JOIN actions ON actions.actionType = 3 AND actions.ID = activities.Action
        JOIN skills ON skills.ID = activities.Skill"
    if req.params.user
        countsQuery += " JOIN users ON users.ID = " + connection.escape req.params.user + ' AND users.ID = activities.ID'
    countsQuery += " WHERE 1=1"
    if req.params.dateFrom
        countsQuery += " AND activities.Date >= " + connection.escape req.params.dateFrom
    if req.params.dateTo
        countsQuery += " AND activities.Date <= " + connection.escape req.params.dateTo
    countsQuery += " GROUP BY
            activities.Skill ORDER BY Count DESC, activities.Skill ASC"

    query( countsQuery )
    .then( (wat) ->
        results = {}
        wat.forEach ( oneWat ) ->
            results[oneWat.Skill] = oneWat.Count

        console.log "woop", results
        res.send 200, results
        return results

    )
    .fail( (whoops) ->
        console.error "arse", whoops
        res.send 500, "Shit broke: " + whoops
    )
    .finally(next)
    .done()

exports.recommendSkills = ( req, res, next ) ->
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
