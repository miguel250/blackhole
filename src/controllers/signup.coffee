Session = require('../events/Session')

class Signup
    constructor: (app) ->
        @app = app
        session = new Session()
        app.get '/signup', session, @signup_get
        app.post '/signup', session, @signup_post
            
    signup_get: (req, res) ->
        res.render('signup')

    signup_post: (req, res) ->
        User = require("../models/user")
        user = new User().Create(req, res)
        
module.exports = (app) ->
   signup = new Signup(app)