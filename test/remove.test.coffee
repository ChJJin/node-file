expect = require('chai').expect
should = require('chai').should()
fs = require('fs')
nodeFile = require('../lib/node-file.js')
helper = require('./test-helper.coffee')

describe 'Remove Tasks', ()->
  {fixture, create, remove} = helper

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

  test = (p, done, exists=true)->
    p = fixture(p)
    if exists
      expect(fs.existsSync p).to.be.true
    else
      expect(fs.existsSync p).to.be.false

    nodeFile.remove p, (err)->
      expect(fs.existsSync p).to.be.false
      expect(err).to.not.exist
      done()

  it 'should remove a folder with files and folders in it', (done)->
    test 'outer', done

  it 'should remove a folder with files in it', (done) ->
    test 'outer/inner', done

  it 'should remove an empty folder', (done) ->
    test 'outer/inner-empty', done

  it 'should remove an existent file', (done)->
    test 'outer/inner/inner-file.txt', done

  it 'should remove an nonexistent file or folder', (done)->
    test 'outer/no-such-file', done, false
