class Auth
    constructor: (query, res) ->
        @valid = true
        @query = query
        @res = res
        @Validate()
        @ValidateKey()
        @ValidateTime()

    ValidateKey: ->
        if false
            @res.statusCode = 401
            @ReturnError(400, 'invaid auth_key')

    ValidateTime: ->
        date = new Date()
        time = String(Math.round(date.getTime() / 1000) + date.getTimezoneOffset() * 60) - @query['auth_timestamp']

        if isNaN(time) or time > 60
            @res.statusCode = 400
            @ReturnError(400, 'invalid auth_timestamp')

    Validate: ->
        name = @query['name']
        auth_key = @query['auth_key']
        body_md5 = @query['body_md5']
        auth_signature =  @query['auth_signature']
        auth_timestamp = @query['auth_timestamp']
  
        if  not name?
            @ReturnError(400, 'event name missing')
            
        if not auth_key?
            @ReturnError(400, 'authication key missing')
        
        if not auth_signature?
            @ReturnError(400, 'auth_signature missing')

        if not body_md5?
            @ReturnError(400, 'body_md5 key missing')
        
        if not auth_timestamp?
            @ReturnError(400, 'auth_timestamp key missing')

    ReturnError: (status_code, message )->
        @res.statusCode = status_code
        @res.send(message)
        @valid = false
    Valid: -> @valid
module.exports = Auth