'use strict';
mysql   = require 'mysql'
Q       = require 'q'
restify = require 'restify'

connection = null

connect = () ->
    connection = mysql.createConnection
        host: '10.0.0.2'
        user: 'root'
        password: ''
        database: 'reputation'

query = ( txt, args = [] ) ->
    console.log "Query!", txt, args, connection?
    connect() unless connection?
    Q.ninvoke( connection, 'query', txt, args ).then (res) -> res[0]

cache =
    categories: {}
    actions: {}
    tags: {}

getCacheItem = ( key, name ) ->
    cacheItem = cache[ key ][ name ]
    console.log "cache get", key, name
    if cacheItem != undefined
        return Q( cacheItem )
    query( 'SELECT `ID` FROM ?? WHERE `Name` = ?', [ key, name ] ).then (results) ->
        console.log "Results!", results
        cache[ key ][ name ] = results[0]?.ID || false

reqParam = ( req, next, p ) ->
    unless req.params[ p ]?
        next new restify.MissingParameterError "'#{p}' is required!"
        return false
    return true
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
