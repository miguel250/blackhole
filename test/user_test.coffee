express = require('express')
{redis, app} = require('../').app
User = require('../').user
Session = require('../').session
request = require('supertest')
assert = require("assert")

suite 'User', ->
    test 'Password Hashing', (done) ->
        user = new User()
        hash = user.HashPassword('test_hash')
        assert.equal(hash, "58df13b08e0c4abe4202dc6922b20a503b1a17b6")
        done()

    test 'Create User Invalid Email', (done) ->
        request(app).post('/signup')
            .send({email: 'test', password: 'test'})
            .set('content-type', 'application/x-www-form-urlencoded')
            .expect(/Invalid Email/, done)

    test 'Create User Email Been used', (done) ->
        request(app)
        .post('/signup')
        .set('content-type', 'application/x-www-form-urlencoded')
        .send({email: 'test@test.com', password: 'test'})
        .end (err, res)->
            request(app).post('/signup')
            .send({email: 'test@test.com', password: 'test'})
            .set('content-type', 'application/x-www-form-urlencoded')
            .expect(/Email address is already being used/, done)

    test 'Login Invalid Information', (done) ->
        request(app)
        .post('/signup')
        .set('content-type', 'application/x-www-form-urlencoded')
        .send({email: 'test2@test.com', password: 'test'})
        .end (err, res)->
            request(app).post('/login')
            .send({email: 'test2@test.com', password: 'tet'})
            .set('content-type', 'application/x-www-form-urlencoded')
            .expect(/Invalid email or password/, done)

    test 'Login Valid', (done) ->
        request(app)
        .post('/signup')
        .set('content-type', 'application/x-www-form-urlencoded')
        .send({email: 'test3@test.com', password: 'test'})
        .end (err, res)->
            request(app).post('/login')
            .send({email: 'test3@test.com', password: 'test'})
            .set('content-type', 'application/x-www-form-urlencoded')
            .expect(/Moved Temporarily/, done)

    test 'Authentication Session With No redirect', (done) ->
        app = express()
        app.use express.cookieParser(require('config').secret)
        session = new Session()

        app.get '/login', session, (req, res) ->
            user = new User()
            user.AuthSession(req, res, 1)
        app.get '/', session,(req, res) ->
            user_id = req.session.user_id
            res.send("user_id: #{user_id}")

        request(app)
        .get('/login')
        .end (err, res)->
            request(app)
            .get('/')
            .set('Cookie', res.headers['set-cookie'][0])
            .expect(/user_id: 1/, done)
    
    test 'Authentication Session With redirect', (done) ->
        app = express()
        app.use express.cookieParser(require('config').secret)
        session = new Session()

        app.get '/login', session, (req, res) ->
            user = new User()
            req.session.redirect_auth = '/redirect'
            user.AuthSession(req, res, 1)

        request(app)
        .get('/login')
        .expect(/redirect/, done)

    test 'Logout', (done) ->
        app = express()
        app.use express.cookieParser(require('config').secret)
        session = new Session()

        app.get '/login', session, (req, res) ->
            user = new User()
            user.AuthSession(req, res, 1)
        app.get '/logout', session, (req, res) ->
            user = new User()
            user.Logout(req, res)
        app.get '/', session,(req, res) ->
            user_id = req.session.user_id
            res.send("#{user_id}")

        request(app)
        .get('/login')
        .end (err, res)->
            request(app)
            .get('/logout')
            .set('Cookie', res.headers['set-cookie'][0])
            .end (err, res)->
                request(app)
                .get('/')
                .expect('undefined', done)
    suiteTeardown (done) ->
        redis.flushall ()->
            done()