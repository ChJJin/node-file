rmSync = removeSync = exports.rmSync = exports.removeSync = (p, options={})->
  try
    if fs.statSync(p)?.isDirectory()
      files = fs.readdirSync(p) || []
      for file in files then do (file)->
        newPath = path.join p, file
        removeSync(newPath, options)
      fs.rmdirSync(p)
    else
      fs.unlinkSync(p)
  catch err
    if err.code isnt 'ENOENT'
      throw err
