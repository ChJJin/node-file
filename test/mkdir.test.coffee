expect = require('chai').expect
should = require('chai').should()
fs = require('fs')
nodeFile = require('../lib/node-file.js')
helper = require('./test-helper.coffee')

describe 'Make directory Sync Tasks', ()->
  {fixture, create, remove} = helper

  afterEach ()->
    remove 'outer/inner/deeper'
    remove 'outer/inner'
    remove 'outer'

  test = (p, done)->
    p = fixture(p)
    nodeFile.mkdir p, ()->
      expect(fs.existsSync p).to.be.true
      done()

  it 'should make a directory with one layer', (done)->
    test 'outer', done

  it 'should make a directory with several layers', (done)->
    test 'outer/inner/deeper', done

  it 'shouldn\'n throw error if make an existent directory', (done)->
    fs.mkdirSync fixture('outer')
    test 'outer', done

  it 'shouldn\'n throw error if make an existent directory with files', (done)->
    fs.mkdirSync fixture('outer')
    fs.mkdirSync fixture('outer/inner')
    test 'outer', done
