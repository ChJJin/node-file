expect = require('chai').expect
should = require('chai').should()
fs = require('fs')
path = require('path')
nodeFile = require('../lib/node-file.js')

describe 'Remove-Sync Tasks', ()->
  fixture = (p)->
    path.join __dirname, p

  create = (p)->
    try
      fixturePath = fixture(p)
      if p.indexOf('.') > -1
        fs.writeFileSync fixturePath, 'hehehe'
      else
        fs.mkdirSync fixturePath
    catch err

  remove = (p)->
    try
      fixturePath = fixture(p)
      if p.indexOf('.') > -1
        fs.unlinkSync fixturePath
      else
        fs.rmdirSync fixturePath
    catch err

  beforeEach ()->    
    create 'outer'
    create 'outer/inner'
    create 'outer/inner-empty'
    create 'outer/inner/inner-file.txt'
    create 'outer/outer-file1.txt'
    create 'outer/outer-file2.txt'

  afterEach ()->
    remove 'outer/outer-file2.txt'
    remove 'outer/outer-file1.txt'
    remove 'outer/inner/inner-file.txt'
    remove 'outer/inner-empty'
    remove 'outer/inner'
    remove 'outer'

  test = (p, exists=true)->
    p = fixture(p)
    if exists
      expect(fs.existsSync p).to.be.true
    else
      expect(fs.existsSync p).to.be.false

    nodeFile.removeSync p
    expect(fs.existsSync p).to.be.false

  it 'should remove a folder with files and folders in it', ()->
    test 'outer'

  it 'should remove a folder with files in it', () ->
    test 'outer/inner'

  it 'should remove an empty folder', () ->
    test 'outer/inner-empty'

  it 'should remove an existent file', ()->
    test 'outer/inner/inner-file.txt'

  it 'should remove an nonexistent file or folder', ()->
    test 'outer/no-such-file', false
