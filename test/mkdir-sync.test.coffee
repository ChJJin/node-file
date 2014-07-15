expect = require('chai').expect
should = require('chai').should()
fs = require('fs')
nodeFile = require('../lib/node-file.js')
helper = require('./test-helper.coffee')

describe 'Make directory Tasks', ()->
  {fixture, create, remove} = helper

  afterEach ()->
    remove 'outer/inner/deeper'
    remove 'outer/inner'
    remove 'outer'

  test = (p)->
    p = fixture(p)
    nodeFile.mkdirSync p
    expect(fs.existsSync p).to.be.true

  it 'should make a directory with one layer', ()->
    test 'outer' 

  it 'should make a directory with several layers', ()->
    test 'outer/inner/deeper' 

  it 'shouldn\'n throw error if make an existent directory', ()->
    fs.mkdirSync fixture('outer')
    test 'outer' 

  it 'shouldn\'n throw error if make an existent directory with files', ()->
    fs.mkdirSync fixture('outer')
    fs.mkdirSync fixture('outer/inner')
    test 'outer' 
