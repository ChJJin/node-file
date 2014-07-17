rmSync = removeSync = exports.rmSync = exports.removeSync = (p, options={})->
  rmFile = (p)->
    try
      fs.unlinkSync p
    catch err
      switch err.code
        when 'ENOENT' then return
        when 'EPERM' then if isWindows
          try
            fs.chmodSync p, 666
            fs.unlinkSync p
          catch err2
            throw err2
        else
          throw err

  rmFolder = (p)->
    try
      fs.rmdirSync p
    catch err
      switch err.code
        when 'ENOENT' then return
        when 'ENOTEMPTY' then if isWindows
          try
            fs.chmodSync p, 666
            removeSync p
          catch err2
            throw err2
        else 
          throw err

  try
    if fs.statSync(p)?.isDirectory()
      files = fs.readdirSync(p)
      for file in files then do (file)->
        newPath = path.join p, file
        removeSync(newPath, options)
      rmFolder(p)
    else
      rmFile(p)
  catch err
    if err.code isnt 'ENOENT'
      throw err
