restify   = require 'restify'
profiling = require './profiling'
argv = require('yargs').demand(['reputations', 'gaminomics']).argv


# connect to gaminomics

jsonClient = restify.createJsonClient
    requestTimeout: 5000
    connectTimeout: 5000
    retry: false
    url: argv.gaminomics
    version: '*'

jsonClient.post '/listeners', {
    "id": "reputationEvents",
    "type": "Event",
    "callback": argv.reputations + "/activities/perform"
}, (err, req, res, obj) -> console.log 'Register listener:', err, res.body, obj

jsonClient.post '/listeners', {
    "id": "reputationUsers",
    "type": "UserCreate",
    "callback": argv.reputations + "/users"
}, (err, req, res, obj) -> console.log 'Register listener:', err, res.body, obj

server = restify.createServer()
server.use restify.queryParser()
server.use restify.bodyParser()
server.get '/', (req, res, next) ->
    res.send 'Hello World'
    next()
server.post '/users', profiling.addUser
server.post '/activities/perform', profiling.performActivity
server.get '/skills/distribution', profiling.skillsDistribution
server.get '/skills/counts', profiling.skillsCounts
server.get '/skills/recommend', profiling.recommendSkills
server.get '/actions/recommend', profiling.recommendActions
server.get '/actionTypes/recommend', profiling.recommendActionTypes

server.listen 7171, () ->
    console.log '%s listening at %s', server.name, server.url
