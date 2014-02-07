'use strict';
mysql   = require 'mysql'
Q       = require 'q'
restify = require 'restify'

connection = null

connect = () ->
    connection = mysql.createConnection
        host: 'localhost'
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
        
    Q.all([
        getCacheItem 'actions', req.params.action
        getCacheItem 'tags', req.params.tag
    ]).spread( ( actionID, tagID ) ->
        console.log "Got IDs", arguments
        return next new restify.InvalidArgumentError "Unknown action '#{req.params.action}'" unless actionID
        return next new restify.InvalidArgumentError "Unknown tag '#{req.params.tag}'" unless tagID
        res.send 200, {
            actionID
            tagID
        }
    , (whoops) ->
        console.error "arse", whoops
        res.send 500, "Shit broke: " + whoops
    )
    .finally(next)
    .done()
