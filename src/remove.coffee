rm = remove = exports.rm = exports.remove = (p, options, cb)->
  if typeof options is 'function'
    cb = options
    options = {}
  cb ?= ()->

  fs.stat p, (err, stat)->
    if err
      if err.code is 'ENOENT' then err = null # no such file or directory
      return cb(err)
    if stat.isDirectory()
      fs.readdir p, (err, files)->
        if err then return cb(err)
        proxy = new eventproxy()
        proxy.fail(cb).after 'rm', files.length, ()-> # if files.lengh is 0, cb will be called at once
          fs.rmdir p, (err)->
            if err.code is 'ENOENT' then err = null
            cb(err)
        for file in files then do (file)->
          newPath = path.join p, file
          remove newPath, options, (err)->
            if err then return proxy.emit 'error', err
            proxy.emit 'rm'
    else
      fs.unlink p, (err)->
        if err.code is 'ENOENT' then err = null # no such file
        cb(err)
