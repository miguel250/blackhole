qs = require('querystring')
{server, app} = require('../').app
request = require('supertest')
io =  require('socket.io-client')
assert = require("assert")

suite 'API', ->

    test 'Socket Events', (done) ->
        running = server.listen 5000, ->
            client = io.connect('http://localhost:5000/1?channel=test&appid=1', { 'connect timeout': 5000 })
            client.on 'connect', (socket) ->
                date = new Date()
                query = 
                    name : 'test_socket'
                    auth_key: 'testkey'
                    body_md5: 'bodymd5'
                    auth_signature: 'authsignature'
                    auth_timestamp: String(Math.round(date.getTime() / 1000) + date.getTimezoneOffset() * 60)

                string = qs.stringify(query)
                post_url = "/apps/1/channels/test/events?#{string}"
                request(running).post(post_url).send('Hello World').set('content-type', 'application/json').end (err, res, body) ->
                    done()
                    client.on 'test_socket', (data) ->
                        assert.equal data, '"Hello World"'


    
    test 'Valid Timestamp', (done) ->
        date = new Date()
        query = 
            name : 'test'
            auth_key: 'testkey'
            body_md5: 'bodymd5'
            auth_signature: 'authsignature'
            auth_timestamp:  String(Math.round(date.getTime() / 1000) + date.getTimezoneOffset() * 60)

        string = qs.stringify(query)
        post_url = "/apps/1/channels/test/events?#{string}"
        request(app).post(post_url).set('content-type', 'application/json').send('Hello World').expect('202 ACCEPTED\n', done)
    
    test 'Invalid content-type', (done) ->
        date = new Date()
        query = 
            name : 'test'
            auth_key: 'testkey'
            body_md5: 'bodymd5'
            auth_signature: 'authsignature'
            auth_timestamp:  String(Math.round(date.getTime() / 1000) + date.getTimezoneOffset() * 60)

        string = qs.stringify(query)
        post_url = "/apps/1/channels/test/events?#{string}"
        request(app).post(post_url).send('Hello World').expect('invalid content-type', done)

    test 'Validation All', (done)->
        date = new Date()
        query = 
            name : 'test_event'
            auth_key: 'testkey'
            body_md5: 'bodymd5'
            auth_signature: 'authsignature'
            auth_timestamp: String(Math.round(date.getTime() / 1000) + date.getTimezoneOffset() * 60)

        string = qs.stringify(query)
        post_url = "/apps/1/channels/test/events?#{string}"

        request(app).post(post_url).set('content-type', 'application/json').send('Hello World').expect('202 ACCEPTED\n', done)

    test 'Empty Body', (done)->
        date = new Date()
        query = 
            name : 'test_event'
            auth_key: 'testkey'
            body_md5: 'bodymd5'
            auth_signature: 'authsignature'
            auth_timestamp: String(Math.round(date.getTime() / 1000) + date.getTimezoneOffset() * 60)

        string = qs.stringify(query)
        post_url = "/apps/1/channels/test/events?#{string}"

        request(app).post(post_url).set('content-type', 'application/json').send().expect('invalid body', done)
    
    test 'Missing Event Name', (done) ->
        date = new Date()
        query = 
            auth_key: 'testkey'
            body_md5: 'bodymd5'
            auth_signature: 'authsignature'
            auth_timestamp: String(Math.round(date.getTime() / 1000) + date.getTimezoneOffset() * 60)

        string = qs.stringify(query)
        post_url = "/apps/1/channels/test/events?#{string}"
        request(app).post(post_url).set('content-type', 'application/json').expect('event name missing', done)

    test 'Missing Authication Key', (done) ->
        date = new Date()
        query = 
            name : 'test_event'
            body_md5: 'bodymd5'
            auth_signature: 'authsignature'
            auth_timestamp: String(Math.round(date.getTime() / 1000) + date.getTimezoneOffset() * 60)

        string = qs.stringify(query)
        post_url = "/apps/1/channels/test/events?#{string}"
        request(app).post(post_url).set('content-type', 'application/json').expect('authication key missing', done)

    test 'Missing Body md5', (done) ->
        date = new Date()
        query = 
            name : 'test_event'
            auth_key: 'testkey'
            auth_signature: 'authsignature'
            auth_timestamp: String(Math.round(date.getTime() / 1000) + date.getTimezoneOffset() * 60)

        string = qs.stringify(query)
        post_url = "/apps/1/channels/test/events?#{string}"
        request(app).post(post_url).set('content-type', 'application/json').expect('body_md5 key missing', done)
    
    test 'Missing Auth Signature', (done) ->
        date = new Date()
        query = 
            name : 'test_event'
            auth_key: 'testkey'
            body_md5: 'bodymd5'
            auth_timestamp: String(Math.round(date.getTime() / 1000) + date.getTimezoneOffset() * 60)
        string = qs.stringify(query)
        post_url = "/apps/1/channels/test/events?#{string}"
        request(app).post(post_url).set('content-type', 'application/json').expect('auth_signature missing', done)

    test 'Missing Timestamp', (done) ->
        query = 
            name : 'test'
            auth_key: 'testkey'
            body_md5: 'bodymd5'
            auth_signature: 'authsignature'
        string = qs.stringify(query)
        post_url = "/apps/1/channels/test/events?#{string}"
        
        request(app).post(post_url).set('content-type', 'application/json').expect('auth_timestamp key missing', done)
    test 'Invalid Timestamp', (done) ->
        query = 
            name : 'test'
            auth_key: 'testkey'
            body_md5: 'bodymd5'
            auth_signature: 'authsignature'
            auth_timestamp: 'm'
        string = qs.stringify(query)
        post_url = "/apps/1/channels/test/events?#{string}"
        
        request(app).post(post_url).set('content-type', 'application/json').expect('invalid auth_timestamp', done)

