class API
    constructor: (app, events) ->
        @app = app
        exports.events = events
        app.post '/apps/:app_id/channels/:channel_name/events', @socket_api
            
    socket_api: (req, res) ->
        Auth = require('../events/auth')
        event = require('events')
        
        if req.header('content-type') != 'application/json'
            res.statusCode = 400
            res.send('invalid content-type')

        valid = new Auth(req.query, res).Valid()
        data =
            channel : req.params.channel_name
            body : req.body[0]
            event : req.query['name']
            app_id : req.params.app_id
            auth_key: req.query['auth_key']
            body_md5 : req.query['body_md5']
            auth_signature: req.query['auth_signature']
            auth_timestamp: req.query['auth_timestamp']
        if valid
            if  data.body != ''
                exports.events.emit 'add_queue', data
                res.send('202 ACCEPTED\n')
            else
                res.statusCode = 400
                res.send('invalid body')

module.exports = (app, events) ->
    api = new API(app, events)