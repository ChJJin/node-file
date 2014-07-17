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
    nodeFile.removeSync fixture(p)

  testFileExist = (paths, exists=true)->
    unless Array.isArray(paths) then paths = [paths]
    for p in paths
      p = fixture(p)
      expect(fs.existsSync p).to.be[exists]

  describe 'if copy to an existent directory', ()->
    test = (src, testFolders)->
      src = fixture(src)
      dest = fixture('dest')

      create 'dest'
      testFileExist 'dest'
      testFileExist testFolders, false

      try      
        nodeFile.copySync src, dest
      catch err
        expect(err).to.not.exist
      testFileExist testFolders

    it 'should copy an empty directory', ()->
      src = 'src/folderouter/folderinner'
      testFolders = ['dest/folderinner']

      test src, testFolders

    it 'should copy a directory with files', ()->
      src = 'src/folder2'
      testFolders = ['dest/folder2', 'dest/folder2/text.txt']

      test src, testFolders

    it 'should copy a directory with folders', ()->
      src = 'src/folderouter'
      testFolders = ['dest/folderouter', 'dest/folderouter/folderinner']

      test src, testFolders

    it 'should copy a directory with folders and files', ()->
      src = 'src'
      testFolders = ['dest/src/srctext.txt', 'dest/src/folder2/text.txt',
                     'dest/src/folder2', 'dest/src/folderouter',
                     'dest/src/folderouter/folderinner', 'dest/src']

      test src, testFolders

    it 'should copy a file', ()->
      src = 'src/srctext.txt'
      testFolders = ['dest/srctext.txt']

      test src, testFolders

  describe 'if copy to an nonexistent directory', ()->
    test = (src, testFolders)->
      src = fixture(src)
      dest = fixture('dest')

      testFileExist testFolders, false

      try      
        nodeFile.copySync src, dest
      catch err
        expect(err).to.not.exist
      testFileExist testFolders

    it 'should copy a file', ()->
      src = 'src/srctext.txt'
      testFolders = ['dest', 'dest/srctext.txt']

      test src, testFolders
