crypto = require 'crypto'
logger = require('log4js').getLogger 'middleware'
_ = require 'lodash'

isSigningUp = (req)->
  #console.log 'middleware.authenticate', req.method, req.url, req.body
  req.url.match /^\/users/ and req.method is 'POST'

getPassword = (req)->
  password = req.body['password'] or req.headers['x-auth-token']
  hashed = req.query['hashed'] or req.headers['x-auth-hashed']

  ## verify hashing status
  hashed = hashed and hashed isnt 'false'

  ## hash password if needed
  password = md5 password if password?.length and not hashed
  return password

getEmail = (req)->
  req.body['email'] or req.headers['x-auth-username']

md5 = (text)-> crypto.createHash('md5').update(text).digest("hex")


exports.ensureAuthCriteria = (req, res, next)->
  ## ignore signup
  return next() if isSigningUp req

#  console.log req.method, req.url

  ## extract information from request
  email = getEmail req
  password = getPassword req

  ## reinsert authentication data back to body to unify with passport stardard
  req.body['password'] = password if password?.length
  req.body['email'] = email if email?.length
  next()

exports.authenticate = (passport)->
  (req, res, next)->
    if isSigningUp req
      req.body['password'] = getPassword req
      return next()

    auth = passport.authenticate 'local', (err, user, info)->
      if err? or not user
        res.send(401, error:info);
      else
        next();

    auth req, res

exports.baucisSearch = (fieldArray)->
  (req, res, next)->
    #logger.debug 'collection get'
    query = req.query.search
    #logger.debug 'search', query
    if query?.length
      regex = new RegExp query, 'ig'

      conditions = {}
      conditions[field] = regex for field in fieldArray

      req.baucis.conditions = _.extend {}, req.baucis.conditions, conditions
    next();