// Generated by CoffeeScript 1.3.3
(function() {
  var EventEmitter, RedisStore, app, client, cluster, emitter, express, http, i, io, path, pub, redis, server, sub;

  express = require("express");

  path = require('path');

  cluster = require('cluster');

  http = require('http');

  EventEmitter = require('events').EventEmitter;

  redis = require("redis");

  client = redis.createClient();

  app = express();

  exports.data = '';

  app.configure(function() {
    app.set('port', process.env.PORT || 3000);
    app.set("views", __dirname + "/views");
    app.set("view engine", "jade");
    app.use(require("./middleware/body"));
    app.use(express.logger('dev'));
    app.use(express.methodOverride());
    app.use(app.router);
    return app.use(express["static"](path.join(__dirname, '../public')));
  });

  app.configure("development", function() {
    return app.use(express.errorHandler({
      dumpExceptions: true,
      showStack: true
    }));
  });

  app.configure("production", function() {
    return app.use(express.errorHandler());
  });

  app.get('/*', function(req, res, next) {
    res.removeHeader("X-Powered-By");
    res.header({
      "Access-Control-Allow-Origin": "*"
    });
    return next();
  });

  emitter = new EventEmitter();

  require('./controllers')(app, emitter);

  server = http.createServer(app);

  io = require('socket.io');

  RedisStore = require('socket.io/lib/stores/redis');

  pub = redis.createClient();

  sub = redis.createClient();

  client = redis.createClient();

  io.set('store', new RedisStore({
    redisPub: pub,
    redisSub: sub,
    redisClient: client
  }));

  i = 0;

  if (cluster.isMaster) {
    while (i <= 2) {
      cluster.fork();
      console.log(i);
      ++i;
    }
  } else {
    io.listen(server);
    server.listen(app.get('port'), function() {
      return console.log("Blackhole server listening on port %d in %s mode", app.get('port'), app.settings.env);
    });
  }

}).call(this);