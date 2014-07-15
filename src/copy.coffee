copy = exports.copy = (src, dest, options, cb)->
  if typeof options is 'function'
    cb = options
    options = {}
  cb ?= ()->
  src = path.resolve(src)
  dir = path.dirname(src)
  basename = path.basename(src)

  copyFile = (from, to, cb)->
    srcstream = fs.createReadStream from
    dststream = fs.createWriteStream to
    srcstream.pipe(dststream)
    srcstream.on 'end', ()->
      cb()

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
        console.log dest
        console.log fs.existsSync dest
        if err then return cb(err)
        copyFile src, path.join(dest, basename), cb
