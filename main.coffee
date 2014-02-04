restify   = require 'restify'
profiling = require './profiling'


server = restify.createServer()
server.get '/', (req, res, next) ->
    res.send 'Hello World'
    next()
server.post '/activities/perform', profiling.performActivity

server.listen 80, () ->
    console.log '%s listening at %s', server.name, server.url
