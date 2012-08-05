express = require("express")
http = require('http')
path = require('path')
redis = require("redis")
{EventEmitter} = require('events')
client = redis.createClient()


app = express()


exports.data = ''

app.configure ->
    app.set 'port', process.env.PORT || 3000
    app.set "views", __dirname + "/views"
    app.set "view engine", "jade"
    app.use express.logger('dev');
    app.use require("./middleware/bodyparser")
    app.use express.methodOverride()
    app.use app.router
    app.use express.static(path.join(__dirname, '../public'))

app.configure "development", ->
    app.use express.errorHandler(
        dumpExceptions: true
        showStack: true
    )

app.configure "production", ->
    app.use express.errorHandler()

app.get '/*', (req,res,next) ->
    res.removeHeader("X-Powered-By")
    res.header("Access-Control-Allow-Origin": "*")
    next()

emitter = new EventEmitter
emitter.setMaxListeners(0)
require('./controllers')(app, emitter)

server = http.createServer(app)
sio = require('socket.io')
RedisStore = sio.RedisStore
io = sio.listen(server)

io.set 'store', new RedisStore

io.sockets.on 'connection',(socket) ->
    hs = socket.handshake
    channel =  hs.query.channel 
    namespace = hs.query.appid

    io.of("/#{namespace}").on 'connection', (socket)->
        socket.join channel

emitter.on 'add_queue', (data) -> 
    namespace = data.app_id.trim()
    io.of("/#{namespace}").in(data.channel).emit data.event, data.body

module.exports = {server:server, app:app }