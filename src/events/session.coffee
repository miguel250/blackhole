express = require("express")
SessionStore = require('connect-redis')(express)


class Session
	constructor: ->
		options = 
			db: require('config').database
		return express.session({ store: new SessionStore(options), maxAge : new Date(Date.now() + 3600000)})
module.exports = Session