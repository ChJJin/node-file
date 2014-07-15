fs = require('fs')
path = require('path')

exports.fixture = fixture = (p)->
  path.join __dirname, p

exports.create = (p)->
  try
    fixturePath = fixture(p)
    if p.indexOf('.') > -1
      fs.writeFileSync fixturePath, 'hehehe'
    else
      fs.mkdirSync fixturePath
  catch err

exports.remove = (p)->
  try
    fixturePath = fixture(p)
    if p.indexOf('.') > -1
      fs.unlinkSync fixturePath
    else
      fs.rmdirSync fixturePath
  catch err
