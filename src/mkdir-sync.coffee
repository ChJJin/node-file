mkdirSync = exports.mkdirSync = (p, options={})->
  p = path.resolve(p)
  mode = options.mode ? (0o777 & (~process.umask()))

  try
    fs.mkdirSync p, mode
  catch err
    switch err.code
      when 'ENOENT'
        mkdirSync path.dirname(p), options
        mkdirSync p, options
      when 'EEXIST' then return
      else
        throw err
