express = require("express")
path = require('path')
http = require('http')
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
require('./controllers')(app, emitter)

RedisStore = require("socket.io/lib/stores/redis")
pub = redis.createClient()
sub = redis.createClient()
client = redis.createClient()


server = http.createServer(app)
io = require('socket.io').listen(server)

io.set "store", new RedisStore(
  redisPub: pub
  redisSub: sub
  redisClient: client
)

server.listen app.get('port'), ->
  console.log "Blackhole server listening on port %d in %s mode", app.get('port'), app.settings.env

io.on 'connection',(socket) ->
  hs = socket.handshake
  channel =  hs.query.channel
  emitter.on 'add_queue', (data) -> socket.emit channel, data.body