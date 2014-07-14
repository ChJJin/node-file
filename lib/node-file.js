var fs = require("fs");
var path = require("path");
var eventproxy = require("eventproxy");
var mkdir, mkdirSync, remove, removeSync, rm, rmSync;

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
  var err, file, files, _fn, _i, _len, _ref;
  if (options == null) {
    options = {};
  }
  try {
    if ((_ref = fs.statSync(p)) != null ? _ref.isDirectory() : void 0) {
      files = fs.readdirSync(p) || [];
      _fn = function(file) {
        var newPath;
        newPath = path.join(p, file);
        return removeSync(newPath, options);
      };
      for (_i = 0, _len = files.length; _i < _len; _i++) {
        file = files[_i];
        _fn(file);
      }
      return fs.rmdirSync(p);
    } else {
      return fs.unlinkSync(p);
    }
  } catch (_error) {
    err = _error;
    if (err.code !== 'ENOENT') {
      throw err;
    }
  }
};

rm = remove = exports.rm = exports.remove = function(p, options, cb) {
  if (typeof options === 'function') {
    cb = options;
    options = {};
  }
  if (cb == null) {
    cb = function() {};
  }
  return fs.stat(p, function(err, stat) {
    if (err) {
      if (err.code === 'ENOENT') {
        err = null;
      }
      return cb(err);
    }
    if (stat.isDirectory()) {
      return fs.readdir(p, function(err, files) {
        var file, proxy, _i, _len, _results;
        if (err) {
          return cb(err);
        }
        proxy = new eventproxy();
        proxy.fail(cb).after('rm', files.length, function() {
          return fs.rmdir(p, function(err) {
            if ((err != null ? err.code : void 0) === 'ENOENT') {
              err = null;
            }
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
      return fs.unlink(p, function(err) {
        if ((err != null ? err.code : void 0) === 'ENOENT') {
          err = null;
        }
        return cb(err);
      });
    }
  });
};
