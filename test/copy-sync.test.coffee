expect = require('chai').expect
should = require('chai').should()
fs = require('fs')
path = require('path')
nodeFile = require('../lib/node-file.js')
helper = require('./test-helper.coffee')

describe 'Copy Sync Tasks', ()->
  {fixture, create, remove} = helper

  beforeEach ()->
    create 'src'
    create 'src/folderouter'
    create 'src/folderouter/folderinner'
    create 'src/folder2'
    create 'src/folder2/text.txt'
    create 'src/srctext.txt'
    remove 'dest'

  afterEach ()->
    remove 'src'
    remove 'dest'

  remove = (p)->
    nodeFile.removeSync fixture p

  testFileExist = (p, exists=true)->
    expect(fs.existsSync p).to.be[exists]

  it 'should copy an empty directory to an existent directory', ()->
    src = fixture('src/folderouter/folderinner')
    dest = fixture('dest')
    testDest = fixture('dest/folderinner')
    create 'dest'

    testFileExist dest
    testFileExist testDest, false

    nodeFile.copySync src, dest
    testFileExist testDest, true

  it 'should copy a directory with files to an existent directory', ()->
    src = fixture('src/folder2')
    dest = fixture('dest')
    testDest = fixture('dest/folder2')
    create 'dest'

    testFileExist dest
    testFileExist testDest, false
    testFileExist path.join(testDest, 'text.txt'), false

    nodeFile.copySync src, dest
    testFileExist testDest
    testFileExist path.join(testDest, 'text.txt')

  it 'should copy a directory with folders to an existent directory', ()->
    src = fixture('src/folderouter')
    dest = fixture('dest')
    testDest = fixture('dest/folderouter')
    create 'dest'

    testFileExist dest
    testFileExist testDest, false
    testFileExist path.join(testDest, 'folderinner'), false

    nodeFile.copySync src, dest
    testFileExist testDest
    testFileExist path.join(testDest, 'folderinner')

  it 'should copy a directory with folders and files to an existent directory', ()->
    src = fixture('src')
    dest = fixture('dest')
    create 'dest'

    testFileExist dest
    testFileExist path.join(dest, 'src/srctext.txt'), false
    testFileExist path.join(dest, 'src/folder2/text.txt'), false
    testFileExist path.join(dest, 'src/folder2'), false
    testFileExist path.join(dest, 'src/folderouter/folderinner'), false
    testFileExist path.join(dest, 'src/folderouter'), false
    testFileExist path.join(dest, 'src'), false

    nodeFile.copySync src, dest
    testFileExist dest
    testFileExist path.join(dest, 'src/srctext.txt')
    testFileExist path.join(dest, 'src/folder2/text.txt')
    testFileExist path.join(dest, 'src/folder2')
    testFileExist path.join(dest, 'src/folderouter/folderinner')
    testFileExist path.join(dest, 'src/folderouter')
    testFileExist path.join(dest, 'src')

  it 'should copy a file to an nonexistent directory', ()->
    src = fixture('src/srctext.txt')
    dest = fixture('dest')

    testFileExist dest, false
    testFileExist path.join(dest, 'srctext.txt'), false

    nodeFile.copySync src, dest
    testFileExist dest
    testFileExist path.join(dest, 'srctext.txt')
