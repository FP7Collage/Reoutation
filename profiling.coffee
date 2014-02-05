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
    connect() unless connection?
    Q.ninvoke( connection, 'query', txt, args ).then (res) -> res[0]

cache =
    categories: {}
    actions: {}
    tags: {}
getCacheItem = ( key, name ) ->
    cacheItem = cache[ key ][ name ]
    if cacheItem != undefined
        return Q( cacheItem )
    query( 'SELECT `ID` FROM ?? WHERE `Name` = ?', [ key, name ] ).then (results) ->
        cache[ key ][ name ] = results[0]?.ID || false

# /api/activities/perform
# json payload
# {  }
exports.performActivity = ( req, res ) ->
    getCacheItem( 'actions', 'Rate' ).then( (ID) ->
        res.send 200, ID
    ).fail( (whoops) ->
        console.error "arse", whoops
        res.send 500, "Shit broke: " + whoops
    )
