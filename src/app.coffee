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

pub = redis.createClient()
sub = redis.createClient()
client = redis.createClient()


server = http.createServer(app)
sio = require('socket.io')
RedisStore = sio.RedisStore
io = sio.listen(server)

io.set 'store', new RedisStore

io.sockets.on 'connection',(socket) ->
  hs = socket.handshake
  channel =  hs.query.channel 
  emitter.on 'add_queue', (data) -> socket.emit channel, data.body
module.exports = {server:server, app:app }