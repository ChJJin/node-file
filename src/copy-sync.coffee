copySync = exports.copySync = (src, dest, options={})->
  cover = !!options.cover
  src = path.resolve(src)
  dir = path.dirname(src)
  basename = path.basename(src)

  canWrite = (p)->
    if cover
      try
        removeSync p
        return true
      catch err
        throw err
    else
      return !fs.existsSync(p)

  BUFFER_LENGTH = 64 * 1024
  buffer = new Buffer(BUFFER_LENGTH)
  copyFile = (from, to)->
    if canWrite to
      froms = fs.openSync from, 'r'
      tos   = fs.openSync to, 'w'

      readByte = 1
      pos = 0
      while readByte > 0
        readByte = fs.readSync froms, buffer, 0, BUFFER_LENGTH, pos
        fs.writeSync tos, buffer, 0, readByte, pos
        pos += readByte

      fs.closeSync froms
      fs.closeSync tos

  try
    if fs.statSync(src)?.isDirectory()
      files = fs.readdirSync(src)
      mkdirSync path.join(dest, basename)
      for file in files then do (file)->
        newSrc = path.join src, file
        newDest = path.join dest, basename
        copySync newSrc, newDest, options
    else
      mkdirSync dest
      copyFile src, path.join(dest, basename)
  catch err
    throw err
