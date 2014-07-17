walk = exports.walk = class Walker
    constructor: (_p, options={})->
      if @ not instanceof Walker
        return new Walker(_p, options)
      @_p = _p
      @_callback = {}
      @_deep = !!options.deep

    on: (event, cb)->
      @_callback ?= {}
      @_callback[event] ?= []
      @_callback[event].push cb
      @

    emit: (event, args...)->
      for e in (@_callback[event] ? [])
        e.apply @, args
      @

    _walk: (p, next)->
      fs.stat p, (err, stat)=>
        if err then return @_onError(err)
        if stat.isDirectory()
          if @_deep
            @_deepWalkDirectory p, stat, next
          else
            @_broadWalkDirectory p, stat, next
        else
          @_onFile p, stat, next

    _deepWalkDirectory: (p, stat, next)->
      @_onFolder p, stat
      fs.readdir p, (err, files)=>
        if err then return @_onError(err)
        _next = ()=>
          if file = files.shift()
            @_walk path.join(p, file), _next
          else
            next()
        _next()

    _broadWalkDirectory: (p, stat, next)->
      @_toWalk ?= []
      @_onFolder p, stat
      fs.readdir p, (err, files)=>
        if err then return @_onError(err)
        for file in files
          @_toWalk.push path.join(p, file)

        _next = ()=>
          if file = @_toWalk.shift()
            @_walk file, _next
          else
            next()
        _next()

    _onFile: (p, stat, next)->
      pathObj = @_getPathObj(p)
      @emit 'file', pathObj, stat, next
      @emit 'fad', pathObj, stat # file and directory

    _onFolder: (p, stat)->
      pathObj = @_getPathObj(p)
      @emit 'directory', pathObj, stat
      @emit 'folder', pathObj, stat
      @emit 'fad', pathObj, stat # file and directory

    _getPathObj: (p)->
      obj =
        basename: path.basename(p)
        absolute: path.resolve(p)
        relativeToSrc: path.relative(@_p, p)
        relative: path.join(@_p, path.relative(@_p, p))

    _onError: (err)->
      @emit 'error', err

    start: ()->
      @_walk @_p, ()=>
        @emit 'end'
