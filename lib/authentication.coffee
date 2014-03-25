passport = require 'passport'
LocalStrategy = require('passport-local').Strategy
models = require('./models/index.coffee')

logger = require('log4js').getLogger 'authentication'

passport.use new LocalStrategy {usernameField:'email'}, (email, password, done)->
  models.user.findOne {email}, (err, user)->
    return done err if err
    return done null, false, {message: 'Incorrect email'} unless user
    return done null, false, {message: 'Incorrect password'} unless user.checkPassword password
    done null, user

passport.serializeUser (user, done)->
  done null, user._id

passport.deserializeUser (_id, done)->
  models.user.findById _id, done

module.exports = passport