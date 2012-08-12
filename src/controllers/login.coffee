Session = require('../events/session')

class Login
    constructor: (app) ->
        @app = app
        session = new Session()
        app.get '/login', session, @LoginGet
        app.post '/login', session, @LoginPost
            
    LoginGet: (req, res) ->
        data = 
            email:''
            password: ''
        res.render('signup', {form: data})

    LoginPost: (req, res) ->
        User = require("../models/user")
        user = new User().Login(req, res)
        
module.exports = (app) ->
   signup = new Login(app)