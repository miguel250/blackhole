{redis} = require("../app")

class User
    constructor: (query, res) ->
        exports.user = @
    
    Login: (req, res) ->
        email = req.body.email
        password = req.body.password
        hash = @HashPassword(password)
 
        redis.get "u:username:#{email}:uid", (err, id) ->
            redis.hget "u:uid:#{id}", 'password', (err, store_password) ->
                if store_password == hash
                    exports.user.AuthSession(req, res, id)
                else
                    req.session.message = [
                        type: 'error'
                        msg: 'Invalid email or password'
                    ]
                    data = 
                        email: email

                    return res.render('login', { form: data, flash: req.session.message  })
                    
    Logout: (req, res) ->
        req.session.destroy ->
            return res.redirect '/'           

    AuthSession: (req, res, user_id) ->
        if not req.session.redirect_auth?
            redirect = '/'
        else
            redirect = req.session.redirect_auth

        req.session.regenerate ->
            req.session.user_id = user_id
            req.session.auth = true
            return res.redirect redirect
    
    Create: (req, res) ->
        email = req.body.email
        password = req.body.password
        validator = require('validator').check

        try
            validator(email).isEmail()
        catch error
            req.session.message = [
                type: 'error'
                msg: 'Invalid Email'
            ]
            return res.render('signup', { flash: req.session.message  })
        
        redis.get "u:username:#{email}:uid", (err, user_id)->
            if user_id?
                req.session.message = [
                    type: 'error'
                    msg: 'Email address is already being used'
                ]
                return res.render('signup', { flash: req.session.message  })
            else
                redis.incr 'global:nextUserId', (err, id) ->    
                    redis.hset "u:uid:#{id}", "username", email
                    redis.hset "u:uid:#{id}", "password", exports.user.HashPassword(password)
                    redis.set "u:username:#{email}:uid", id
                    redis.hgetall "u:uid#{id}", (err, hash) ->
                        exports.user.AuthSession(req, res, id)

    HashPassword: (plain_password) ->
        salt = require('config').salt
        crypto = require('crypto')
        
        hashed_password = crypto.createHmac('sha1', salt).update(plain_password).digest('hex')
        return hashed_password

module.exports = User