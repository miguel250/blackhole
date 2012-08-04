path = require('path')
http = require('http')
cluster = require("cluster")
numCPUs = require("os").cpus().length


if cluster.isMaster
  i = 0
  while i < numCPUs
    work = cluster.fork()
    i++
  cluster.on "exit", (worker, code, signal) ->
    console.log "worker " + worker.process.pid + " died"
else
  express = require("express")
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

  server.listen app.get('port'), ->
    console.log "Blackhole server listening on port %d in %s mode", app.get('port'), app.settings.env

  io.sockets.on 'connection',(socket) ->
    connectCounter++
    hs = socket.handshake
    channel =  hs.query.channel 
    emitter.on 'add_queue', (data) -> socket.emit channel, data.body