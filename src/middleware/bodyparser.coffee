 #
 # Handle post body
 #

class BodyParser
    constructor: (req, res, next) ->
        if req.header('content-type') != 'application/json'
            return next()
        exports.data = ''
        req.setEncoding('utf8')

        req.on 'data', (chunk) ->
            exports.data = exports.data + chunk

        req.on 'end', ->
            req.body = [exports.data]
            next()
module.exports =  (req, res, next)->
    body = new BodyParser(req, res, next)