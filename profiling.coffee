'use strict';
mysql = require 'mysql'
Q     = require 'q'

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

# /api/activities/perform
# json payload
# {  }
exports.performActivity = ( req, res ) ->
    console.log( "got call!" );
    getCacheItem( 'actions', 'Rate' ).then( (ID) ->
        res.send 200, ID
    ).fail( (whoops) ->
        console.error "arse", whoops
        res.send 500, "Shit broke: " + whoops
    )
