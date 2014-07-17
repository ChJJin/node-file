expect = require('chai').expect
should = require('chai').should()
fs = require('fs')
nodeFile = require('../lib/node-file.js')
helper = require('./test-helper.coffee')

describe 'Remove-Sync Tasks', ()->
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

  test = (p, exists=true)->
    p = fixture(p)
    expect(fs.existsSync p).to.be[exists]
    try
      nodeFile.removeSync p
    catch err
      expect(err).to.not.exist
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
