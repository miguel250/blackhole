class Test
    constructor: (app) ->
        @app = app
        app.get '/test', @socket_test
            
    socket_test: (req, res) ->
        date = new Date()
        time = String(Math.round(date.getTime() / 1000) + date.getTimezoneOffset() * 60)
        hostname = req.headers.host
        res.render('test', { time: time, hostname: hostname })

module.exports = (app) ->
    api = new Test(app)