module.exports = (app, events) ->
    require('./api')(app, events)
    require('./test')(app)
    require('./signup')(app)
    require('./login')(app)