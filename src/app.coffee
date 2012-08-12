express = require("express")
http = require('http')
path = require('path')
redis = require("redis")
{EventEmitter} = require('events')
redis_client = redis.createClient()
socket_pub  = redis.createClient()
socket_sub = redis.createClient()
cons = require('consolidate')
connect = require('connect')


app = express()

redis_client.select(require('config').database)
socket_pub.select(require('config').database)
socket_sub.select(require('config').database)

app.configure ->
    app.set 'port', process.env.PORT || 3000
    app.set "views", __dirname + "/views"
    app.set "view engine", "twig"
    app.engine('twig', cons.swig)
    app.use express.cookieParser(require('config').secret)
    app.use connect.urlencoded()
    app.use connect.multipart()
    app.use require("./middleware/bodyparser")
    app.use express.methodOverride()
    app.use express.favicon()
    app.use app.router
    app.use express.static(path.join(__dirname, '../public'))

app.configure "development", ->
    app.use express.logger('dev')
    app.use express.errorHandler(
        dumpExceptions: true
        showStack: true
    )

app.configure "production", ->
    app.use express.errorHandler()

app.configure "testing", ->
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

io = sio.listen(server, {'log level': 0})

io.set 'store', new RedisStore({
    redisPub: socket_pub
    redisSub: socket_sub
    redisClient: redis_client
    })


io.sockets.on 'connection',(socket) ->
    hs = socket.handshake
    channel =  hs.query.channel 
    namespace = hs.query.appid
    
    io.of("/#{namespace}").on 'connection', (socket)->
        socket.join channel

emitter.on 'add_queue', (data) -> 
    namespace = data.app_id.trim()
    io.of("/#{namespace}").in(data.channel).emit data.event, data.body

module.exports = {server:server, app:app, redis:redis_client }