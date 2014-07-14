var fs = require("fs");
var path = require("path");
var eventproxy = require("eventproxy");
var remove, removeSync, rm, rmSync;

rmSync = removeSync = exports.rmSync = exports.removeSync = function(p, options) {
  var file, files, _fn, _i, _len, _ref;
  if (options == null) {
    options = {};
  }
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
        return cb(err);
      });
    }
  });
};
