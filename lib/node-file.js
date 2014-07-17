var fs = require("fs");
var path = require("path");
var util = require("util");
var eventproxy = require("eventproxy");
var Walker, copy, copySync, isWindows, mkdir, mkdirSync, remove, removeSync, rm, rmSync, walk,
  __slice = [].slice;

copySync = exports.copySync = function(src, dest, options) {
  var BUFFER_LENGTH, basename, buffer, canWrite, copyFile, cover, dir, err, file, files, _i, _len, _ref, _results;
  if (options == null) {
    options = {};
  }
  cover = !!options.cover;
  src = path.resolve(src);
  dir = path.dirname(src);
  basename = path.basename(src);
  canWrite = function(p) {
    var err;
    if (cover) {
      try {
        removeSync(p);
        return true;
      } catch (_error) {
        err = _error;
        throw err;
      }
    } else {
      return !fs.existsSync(p);
    }
  };
  BUFFER_LENGTH = 64 * 1024;
  buffer = new Buffer(BUFFER_LENGTH);
  copyFile = function(from, to) {
    var froms, pos, readByte, tos;
    if (canWrite(to)) {
      froms = fs.openSync(from, 'r');
      tos = fs.openSync(to, 'w');
      readByte = 1;
      pos = 0;
      while (readByte > 0) {
        readByte = fs.readSync(froms, buffer, 0, BUFFER_LENGTH, pos);
        fs.writeSync(tos, buffer, 0, readByte, pos);
        pos += readByte;
      }
      fs.closeSync(froms);
      return fs.closeSync(tos);
    }
  };
  try {
    if ((_ref = fs.statSync(src)) != null ? _ref.isDirectory() : void 0) {
      files = fs.readdirSync(src);
      mkdirSync(path.join(dest, basename));
      _results = [];
      for (_i = 0, _len = files.length; _i < _len; _i++) {
        file = files[_i];
        _results.push((function(file) {
          var newDest, newSrc;
          newSrc = path.join(src, file);
          newDest = path.join(dest, basename);
          return copySync(newSrc, newDest, options);
        })(file));
      }
      return _results;
    } else {
      mkdirSync(dest);
      return copyFile(src, path.join(dest, basename));
    }
  } catch (_error) {
    err = _error;
    throw err;
  }
};

copy = exports.copy = function(src, dest, options, cb) {
  var basename, canWrite, copyFile, cover, dir;
  if (typeof options === 'function') {
    cb = options;
    options = {};
  }
  if (cb == null) {
    cb = function() {};
  }
  cover = !!options.cover;
  src = path.resolve(src);
  dir = path.dirname(src);
  basename = path.basename(src);
  canWrite = function(p, cb) {
    if (cover) {
      return remove(p, function(err) {
        if (err) {
          return cb(err);
        }
        return cb(null, true);
      });
    } else {
      return fs.exists(p, function(exists) {
        return cb(null, !exists);
      });
    }
  };
  copyFile = function(from, to, cb) {
    return canWrite(to, function(err, can) {
      var called, dststream, srcstream;
      if (err) {
        return cb(err);
      }
      if (!can) {
        return cb();
      } else {
        called = false;
        srcstream = fs.createReadStream(from);
        dststream = fs.createWriteStream(to);
        dststream.on('open', function() {
          return srcstream.pipe(dststream);
        });
        srcstream.on('error', function(err) {
          if (err && !called) {
            return cb(err);
          }
        });
        dststream.on('error', function(err) {
          if (err && !called) {
            return cb(err);
          }
        });
        return dststream.on('close', function() {
          if (!called) {
            return cb();
          }
        });
      }
    });
  };
  return fs.stat(src, function(err, stat) {
    if (err) {
      return cb(err);
    }
    if (stat.isDirectory()) {
      return fs.readdir(src, function(err, files) {
        var file, proxy, _i, _len, _results;
        if (err) {
          return cb(err);
        }
        proxy = new eventproxy();
        proxy.fail(cb).after('copy', files.length, function() {
          return mkdir(path.join(dest, basename), function(err) {
            return cb(err);
          });
        });
        _results = [];
        for (_i = 0, _len = files.length; _i < _len; _i++) {
          file = files[_i];
          _results.push((function(file) {
            var newDest, newSrc;
            newSrc = path.join(src, file);
            newDest = path.join(dest, basename);
            return copy(newSrc, newDest, options, function(err) {
              if (err) {
                return proxy.emit('error', err);
              }
              return proxy.emit('copy');
            });
          })(file));
        }
        return _results;
      });
    } else {
      return mkdir(dest, function(err) {
        if (err) {
          return cb(err);
        }
        return copyFile(src, path.join(dest, basename), cb);
      });
    }
  });
};

mkdirSync = exports.mkdirSync = function(p, options) {
  var err, mode, _ref;
  if (options == null) {
    options = {};
  }
  p = path.resolve(p);
  mode = (_ref = options.mode) != null ? _ref : 0x1ff & (~process.umask());
  try {
    return fs.mkdirSync(p, mode);
  } catch (_error) {
    err = _error;
    switch (err.code) {
      case 'ENOENT':
        mkdirSync(path.dirname(p), options);
        return mkdirSync(p, options);
      case 'EEXIST':
        break;
      default:
        throw err;
    }
  }
};

mkdir = exports.mkdir = function(p, options, cb) {
  var mode, _ref;
  if (typeof options === 'function') {
    cb = options;
    options = {};
  }
  if (cb == null) {
    cb = function() {};
  }
  p = path.resolve(p);
  mode = (_ref = options.mode) != null ? _ref : 0x1ff & (~process.umask());
  return fs.mkdir(p, mode, function(err) {
    if (!err) {
      return cb();
    } else {
      switch (err.code) {
        case 'EEXIST':
          return cb();
        case 'ENOENT':
          return mkdir(path.dirname(p), options, function(err) {
            if (err) {
              return cb(err);
            }
            return mkdir(p, options, cb);
          });
        default:
          return cb(err);
      }
    }
  });
};

rmSync = removeSync = exports.rmSync = exports.removeSync = function(p, options) {
  var err, file, files, rmFile, rmFolder, _fn, _i, _len, _ref;
  if (options == null) {
    options = {};
  }
  rmFile = function(p) {
    var err, err2;
    try {
      return fs.unlinkSync(p);
    } catch (_error) {
      err = _error;
      switch (err.code) {
        case 'ENOENT':
          break;
        case 'EPERM':
          if (isWindows) {
            try {
              fs.chmodSync(p, 666);
              return fs.unlinkSync(p);
            } catch (_error) {
              err2 = _error;
              throw err2;
            }
          }
          break;
        default:
          throw err;
      }
    }
  };
  rmFolder = function(p) {
    var err, err2;
    try {
      return fs.rmdirSync(p);
    } catch (_error) {
      err = _error;
      switch (err.code) {
        case 'ENOENT':
          break;
        case 'ENOTEMPTY':
          if (isWindows) {
            try {
              fs.chmodSync(p, 666);
              return removeSync(p);
            } catch (_error) {
              err2 = _error;
              throw err2;
            }
          }
          break;
        default:
          throw err;
      }
    }
  };
  try {
    if ((_ref = fs.statSync(p)) != null ? _ref.isDirectory() : void 0) {
      files = fs.readdirSync(p);
      _fn = function(file) {
        var newPath;
        newPath = path.join(p, file);
        return removeSync(newPath, options);
      };
      for (_i = 0, _len = files.length; _i < _len; _i++) {
        file = files[_i];
        _fn(file);
      }
      return rmFolder(p);
    } else {
      return rmFile(p);
    }
  } catch (_error) {
    err = _error;
    if (err.code !== 'ENOENT') {
      throw err;
    }
  }
};

isWindows = process.platform === 'win32';

rm = remove = exports.rm = exports.remove = function(p, options, cb) {
  var rmFile, rmFolder;
  if (typeof options === 'function') {
    cb = options;
    options = {};
  }
  if (cb == null) {
    cb = function() {};
  }
  rmFile = function(p, cb) {
    return fs.unlink(p, function(err) {
      if (err) {
        switch (err.code) {
          case 'ENOENT':
            return cb(null);
          case 'EPERM':
            if (isWindows) {
              return fs.chmod(p, 666, function(err2) {
                if (err2) {
                  return cb(err2);
                }
                return fs.unlink(p, cb);
              });
            }
            break;
          default:
            return cb(err);
        }
      } else {
        return cb(null);
      }
    });
  };
  rmFolder = function(p, cb) {
    return fs.rmdir(p, function(err) {
      if (err) {
        switch (err.code) {
          case 'ENOENT':
            return cb(null);
          case 'ENOTEMPTY':
            if (isWindows) {
              return fs.chmod(p, 666, function(err2) {
                if (err2) {
                  return cb(err2);
                }
                return remove(p, cb);
              });
            }
            break;
          default:
            return cb(err);
        }
      } else {
        return cb(null);
      }
    });
  };
  return fs.stat(p, function(err, stat) {
    if (err) {
      return cb(err.code === 'ENOENT' ? null : err);
    }
    if (stat.isDirectory()) {
      return fs.readdir(p, function(err, files) {
        var file, proxy, _i, _len, _results;
        if (err) {
          return cb(err);
        }
        proxy = new eventproxy();
        proxy.fail(cb).after('rm', files.length, function() {
          return rmFolder(p, function(err) {
            return cb(err);
          });
        });
        _results = [];
        for (_i = 0, _len = files.length; _i < _len; _i++) {
          file = files[_i];
          _results.push((function(file) {
            var newPath;
            newPath = path.join(p, file);
            return remove(newPath, options, function(err) {
              if (err) {
                return proxy.emit('error', err);
              }
              return proxy.emit('rm');
            });
          })(file));
        }
        return _results;
      });
    } else {
      return rmFile(p, cb);
    }
  });
};

walk = exports.walk = Walker = (function() {
  function Walker(_p, options) {
    if (options == null) {
      options = {};
    }
    if (!(this instanceof Walker)) {
      return new Walker(_p, options);
    }
    this._p = _p;
    this._callback = {};
    this._deep = !!options.deep;
  }

  Walker.prototype.on = function(event, cb) {
    var _base;
    if (this._callback == null) {
      this._callback = {};
    }
    if ((_base = this._callback)[event] == null) {
      _base[event] = [];
    }
    this._callback[event].push(cb);
    return this;
  };

  Walker.prototype.emit = function() {
    var args, e, event, _i, _len, _ref, _ref1;
    event = arguments[0], args = 2 <= arguments.length ? __slice.call(arguments, 1) : [];
    _ref1 = (_ref = this._callback[event]) != null ? _ref : [];
    for (_i = 0, _len = _ref1.length; _i < _len; _i++) {
      e = _ref1[_i];
      e.apply(this, args);
    }
    return this;
  };

  Walker.prototype._walk = function(p, next) {
    return fs.stat(p, (function(_this) {
      return function(err, stat) {
        if (err) {
          return _this._onError(err);
        }
        if (stat.isDirectory()) {
          if (_this._deep) {
            return _this._deepWalkDirectory(p, stat, next);
          } else {
            return _this._broadWalkDirectory(p, stat, next);
          }
        } else {
          return _this._onFile(p, stat, next);
        }
      };
    })(this));
  };

  Walker.prototype._deepWalkDirectory = function(p, stat, next) {
    this._onFolder(p, stat);
    return fs.readdir(p, (function(_this) {
      return function(err, files) {
        var _next;
        if (err) {
          return _this._onError(err);
        }
        _next = function() {
          var file;
          if (file = files.shift()) {
            return _this._walk(path.join(p, file), _next);
          } else {
            return next();
          }
        };
        return _next();
      };
    })(this));
  };

  Walker.prototype._broadWalkDirectory = function(p, stat, next) {
    if (this._toWalk == null) {
      this._toWalk = [];
    }
    this._onFolder(p, stat);
    return fs.readdir(p, (function(_this) {
      return function(err, files) {
        var file, _i, _len, _next;
        if (err) {
          return _this._onError(err);
        }
        for (_i = 0, _len = files.length; _i < _len; _i++) {
          file = files[_i];
          _this._toWalk.push(path.join(p, file));
        }
        _next = function() {
          if (file = _this._toWalk.shift()) {
            return _this._walk(file, _next);
          } else {
            return next();
          }
        };
        return _next();
      };
    })(this));
  };

  Walker.prototype._onFile = function(p, stat, next) {
    var pathObj;
    pathObj = this._getPathObj(p);
    this.emit('file', pathObj, stat, next);
    return this.emit('fad', pathObj, stat);
  };

  Walker.prototype._onFolder = function(p, stat) {
    var pathObj;
    pathObj = this._getPathObj(p);
    this.emit('directory', pathObj, stat);
    this.emit('folder', pathObj, stat);
    return this.emit('fad', pathObj, stat);
  };

  Walker.prototype._getPathObj = function(p) {
    var obj;
    return obj = {
      basename: path.basename(p),
      absolute: path.resolve(p),
      relativeToSrc: path.relative(this._p, p),
      relative: path.join(this._p, path.relative(this._p, p))
    };
  };

  Walker.prototype._onError = function(err) {
    return this.emit('error', err);
  };

  Walker.prototype.start = function() {
    return this._walk(this._p, (function(_this) {
      return function() {
        return _this.emit('end');
      };
    })(this));
  };

  return Walker;

})();
