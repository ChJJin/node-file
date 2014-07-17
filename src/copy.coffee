copy = exports.copy = (src, dest, options, cb)->
  if typeof options is 'function'
    cb = options
    options = {}
  cb ?= ()->
  cover = !!options.cover
  src = path.resolve(src)
  dir = path.dirname(src)
  basename = path.basename(src)

  canWrite = (p, cb)->
    if cover
      remove p, (err)->
        if err then return cb(err)
        cb(null, true)
    else
      fs.exists p, (exists)->
        cb(null, !exists)

  copyFile = (from, to, cb)->
    canWrite to, (err, can)->
      if err then return cb(err)
      unless can
        cb()
      else
        called = false
        srcstream = fs.createReadStream from
        dststream = fs.createWriteStream to
        dststream.on 'open', ()->
          srcstream.pipe(dststream)
        srcstream.on 'error', (err)->
          if err and not called then cb(err)
        dststream.on 'error', (err)->
          if err and not called then cb(err)
        dststream.on 'close', ()->
          if not called then cb()

  fs.stat src, (err, stat)->
    if err then return cb(err)
    if stat.isDirectory()
      fs.readdir src, (err, files)->
        if err then return cb(err)
        proxy = new eventproxy()
        proxy.fail(cb).after 'copy', files.length, ()-> # if files.lengh is 0, cb will be called at once
          mkdir path.join(dest, basename), (err)-> # copy empty directory
            cb(err)
        for file in files then do (file)->
          newSrc = path.join src, file
          newDest = path.join dest, basename
          copy newSrc, newDest, options, (err)->
            if err then return proxy.emit 'error', err
            proxy.emit 'copy'
    else # copy file
      mkdir dest, (err)->
        if err then return cb(err)
        copyFile src, path.join(dest, basename), cb
