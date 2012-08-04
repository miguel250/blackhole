path = require('path')
cluster = require("cluster")
numCPUs = require("os").cpus().length
fs = require('fs')


if cluster.isMaster
  i = 0
  workers = []
  
  while i < numCPUs
    workers.push(cluster.fork())
    i++
  
  pid = process.pid
  
  fs.writeFile path.join(__dirname, '../pids'), pid, (err) ->
    console.log("Master pid: #{pid}")

  process.on 'SIGUSR2', ->
    
    old_works = workers
    workers = []
    console.log "Reloading Workers"

    for worker in old_works
      worker.send('force kill')
      worker.process.kill('SIGQUIT')

  cluster.on "exit", (worker, code, signal) ->
    workers.push(cluster.fork())
    console.log "worker " + worker.process.pid + " died"
    
else
  {server, app} = require('./app')
  server.listen app.get('port'), ->
    console.log "Blackhole server listening on port %d in %s mode on pid %d", app.get('port'), app.settings.env, process.pid

  process.on "message", (msg) ->
    if msg is "force kill"
       server.close()