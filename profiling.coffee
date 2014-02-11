'use strict';
mysql   = require 'mysql'
Q       = require 'q'
restify = require 'restify'

connection = null

connect = () ->
    connection = mysql.createConnection
        host: '10.0.0.2'
        user: 'reputation'
        password: 'reputation'
        database: 'reputation'

query = ( txt, args = [] ) ->
    console.log "Query!", txt, args, connection?
    connect() unless connection?
    Q.ninvoke( connection, 'query', txt, args ).then (res) -> res[0]

cache =
    categories: {}
    actions: {}
    tags: {}
    users: {}

getCacheItem = ( key, name ) ->
    cacheItem = cache[ key ][ name ]
    console.log "cache get", key, name
    if cacheItem != undefined
        return Q( cacheItem )
    query( 'SELECT `ID` FROM ?? WHERE `Name` = ?', [ key, name ] ).then (results) ->
        console.log "Results!", results
        cache[ key ][ name ] = results[0]?.ID || false

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

getStatistics = ( req, res, next, queryString ) ->
    return unless reqParam( req, next, 'user' )
        
    Q(
        getCacheUser req.params.user
    ).then( ( userID ) ->
        return next new restify.InvalidArgumentError "Unknown user '#{req.params.user}'" unless userID
        query queryString, [ userID, userID ]
    )
    .then( (wat) ->

        sum = wat.reduce ( ( total, oneWat) -> total + ( oneWat.Done || 0 ) + ( oneWat.Referenced || 0 ) ), 0

        for oneWat in wat
            oneWat.Probability = ( ( oneWat.Done || 0 ) + ( oneWat.Referenced || 0 ) )/sum

        console.log "woop", wat
        res.send 200, wat
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

    return unless reqParam( req, next, 'action' ) and reqParam( req, next, 'tag' )

    userID = 1 #magical lookup on UID '4FA06769-C5C7-432B-9E37-4A3E7B4D294D'
        
    Q.all([
        getCacheItem 'actions', req.params.action
        getCacheItem 'tags', req.params.tag
    ]).spread( ( actionID, tagID ) ->
        console.log "Got IDs", arguments
        return next new restify.InvalidArgumentError "Unknown action '#{req.params.action}'" unless actionID
        return next new restify.InvalidArgumentError "Unknown tag '#{req.params.tag}'" unless tagID
        query "INSERT INTO `activities` SET ?", [{
            User: userID
            Action: actionID
            Tag: tagID
        }]
    )
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

exports.recommendTags = ( req, res, next ) ->
    statisticsQuery = "
        SELECT tags.Name, b1.Done, b2.Referenced FROM 
            (
            SELECT 
                Tag, COUNT(*) as Done 
            FROM 
                activities 
            WHERE 
                User = ?
            GROUP BY 
                Tag 
            ) b1
        LEFT OUTER JOIN
            (
            SELECT 
                a1.Tag, COUNT(*) as Referenced
            FROM 
                (SELECT * FROM activities WHERE User = ?) a1 LEFT OUTER JOIN activities a2 
            ON 
                ( a1.User != a2.User AND a1.Reference=a2.Reference )
            WHERE
                a2.Key IS NOT NULL
            GROUP BY a1.Tag
            ) b2
        ON b1.Tag = b2.Tag JOIN tags ON tags.ID = b1.Tag 
        ORDER BY IFNULL(b1.Done, 0)+IFNULL(b2.Referenced, 0) DESC" # maybe move user=? to later WHERE

    getStatistics req, res, next, statisticsQuery

exports.recommendActivities = ( req, res, next ) ->
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
        ON b1.Action = b2.Action JOIN actions ON actions.ID = b1.Action
        ORDER BY IFNULL(b1.Done, 0)+IFNULL(b2.Referenced, 0) DESC"

    getStatistics req, res, next, statisticsQuery
    
exports.recommendCategories = ( req, res, next ) ->
    statisticsQuery = "
        SELECT categories.Name, SUM(b1.Done) as Done, SUM(b2.Referenced) as Referenced FROM 
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
        ON b1.Action = b2.Action JOIN (actions, categories) ON (actions.ID = b1.Action AND actions.Category = categories.ID)
        GROUP BY actions.Category
        ORDER BY IFNULL(b1.Done, 0)+IFNULL(b2.Referenced, 0) DESC"

    getStatistics req, res, next, statisticsQuery


# TODO: which query is faster

# SELECT users.UUID as User, tags.Name as Tag, COUNT(activities.Key) as Count FROM activities, tags, users WHERE users.ID = activities.User AND tags.ID = activities.Tag GROUP BY activities.User, activities.Tag ORDER BY activities.User, Count DESC
# SELECT users.UUID, tags.Name, Count FROM tags, users, (SELECT *, COUNT(*) as Count FROM activities GROUP BY activities.User, activities.Tag ORDER BY activities.User, Count DESC) as tmp WHERE users.ID = tmp.User AND tags.ID = tmp.Tag

# SELECT users.UUID, actions.Name, COUNT(activities.Key) as Count FROM activities, actions, users WHERE users.ID = activities.User AND actions.ID = activities.Action GROUP BY activities.User, activities.Action ORDER BY activities.User, Count DESC

# SELECT users.UUID, categories.Name, COUNT(activities.Key) as Count FROM activities, actions, users, categories WHERE users.ID = activities.User AND actions.Category = categories.ID AND actions.ID = activities.Action GROUP BY activities.User, actions.Category ORDER BY activities.User, Count DESC

# SELECT a1.*, COUNT(*) as selfRefs, SUM(numOfRefs) FROM (SELECT a1.*, COUNT(a2.Reference) as numOfRefs FROM (SELECT * FROM activities WHERE User=1) a1 LEFT OUTER JOIN activities a2 ON ( a2.Reference IS NOT NULL AND a1.Key=a2.Reference ) GROUP BY a1.Key) as a1 GROUP BY a1.Action