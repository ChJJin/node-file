expect = require('chai').expect
should = require('chai').should()
path = require('path')
nodeFile = require('../lib/node-file.js')
helper = require('./test-helper.coffee')

describe 'Walk Tasks', ()->
  {fixture, create} = helper

  before ()->
    create 'src'
    create 'src/folder2'
    create 'src/folder2/text.txt'
    create 'src/folderouter'
    create 'src/folderouter/folderinner'
    create 'src/srctext.txt'

  after ()->
    nodeFile.removeSync fixture('src')

  it 'should depth-first walk a directory', (done)->
    files = []
    expectArray = ['', 'folder2', path.join('folder2','text.txt'),
                   'folderouter', path.join('folderouter','folderinner'),
                   'srctext.txt']
    walker = nodeFile.walk fixture('src'), {deep: true}
    walker.on 'file', (p, stat, next)->
      files.push p.relativeToSrc
      next()
    walker.on 'folder', (p, stat, next)->
      files.push p.relativeToSrc
      next()
    walker.on 'end', ()->
      expect(files).to.eql(expectArray)
      done()
    walker.start()

  it 'should breadth-first walk a directory', (done)->
    files = []
    expectArray = ['', 'folder2', 'folderouter', 'srctext.txt',
                   path.join('folder2','text.txt'), path.join('folderouter','folderinner')]
    walker = nodeFile.walk fixture('src'), {deep: false}
    walker.on 'file', (p, stat, next)->
      files.push p.relativeToSrc
      next()
    walker.on 'folder', (p, stat, next)->
      files.push p.relativeToSrc
      next()
    walker.on 'end', ()->
      expect(files).to.eql(expectArray)
      done()
    walker.start()
