isWindows = process.platform is 'win32'
rm = remove = exports.rm = exports.remove = (p, options, cb)->
  if typeof options is 'function'
    cb = options
    options = {}
  cb ?= ()->

  rmFile = (p, cb)->
    fs.unlink p, (err)->
      if err then switch err.code
        when 'ENOENT' then return cb(null)
        when 'EPERM' then if isWindows # windows' error
          fs.chmod p, 666, (err2)->
            if err2 then return cb(err2)
            fs.unlink p, cb
        else
          cb(err)
      else
        cb(null)

  rmFolder = (p, cb)->
    fs.rmdir p, (err)->
      if err then switch err.code
        when 'ENOENT' then return cb(null)
        when 'ENOTEMPTY' then if isWindows
          fs.chmod p, 666, (err2)->
            if err2 then return cb(err2)
            remove(p, cb)
        else
          cb(err)
      else
        cb(null)

  fs.stat p, (err, stat)->
    if err
      return cb(if err.code is 'ENOENT' then null else err) # no such file or directory
    if stat.isDirectory()
      fs.readdir p, (err, files)->
        if err then return cb(err)
        proxy = new eventproxy()
        proxy.fail(cb).after 'rm', files.length, ()-> # if files.lengh is 0, cb will be called at once
          rmFolder p, (err)->
            cb(err)
        for file in files then do (file)->
          newPath = path.join p, file
          remove newPath, options, (err)->
            if err then return proxy.emit 'error', err
            proxy.emit 'rm'
    else
      rmFile p, cb
