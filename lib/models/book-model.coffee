mongoose = require 'mongoose'

schema = new mongoose.Schema {
  desc: String
  id: {type: String, unique: true}
  name: String
  picture: String
  price: Number
  _id: String
}

schema.path 'id'
  .set (v)->
    #console.log 'v', v
    @_id = v

module.exports = mongoose.model 'book', schema