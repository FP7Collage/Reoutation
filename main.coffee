restify   = require 'restify'
profiling = require './profiling'


server = restify.createServer()
server.use restify.queryParser()
server.use restify.bodyParser()
server.get '/', (req, res, next) ->
    res.send 'Hello World'
    next()
server.post '/activities/perform', profiling.performActivity
server.get '/skills/recommend', profiling.recommendSkills
server.get '/actions/recommend', profiling.recommendActivities
server.get '/categories/recommend', profiling.recommendCategories

server.listen 80, () ->
    console.log '%s listening at %s', server.name, server.url
