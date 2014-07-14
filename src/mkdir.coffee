mkdir = exports.mkdir = (p, options, cb)->
  if typeof options is 'function'
    cb = options
    options = {}
  cb ?= ()->
  p = path.resolve(p)
  mode = options.mode ? (0o777 & (~process.umask()))

  fs.mkdir p, mode, (err)->
    unless err
      cb()
    else
      switch err.code
        when 'EEXIST' then return cb()
        when 'ENOENT'
          mkdir path.dirname(p), options, (err)->
            if err then return cb(err)
            mkdir p, options, cb
        else
          cb(err)
