// var __slice = [].slice;

// this.modules = {};

// modules.importModules = function() {
//   var names;
//   names = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
//   return _.each(names, function(name) {
//     var base, modulePath, publicPath, staticPath;
//     modulePath = "node_modules/" + name;
//     base = requires.path.resolve(".");
//     if (base === "/") {
//       base = requires.path.dirname(global.require.main.filename);
//     }
//     publicPath = requires.path.resolve(base + "/public/" + modulePath);
//     staticPath = requires.path.resolve(base + "/static/" + modulePath);
//     if (requires.fs.existsSync(publicPath)) {
//       return modules[name] = requires.require(publicPath);
//     } else if (requires.fs.existsSync(staticPath)) {
//       return modules[name] = requires.require(staticPath);
//     } else {
//       return console.log("node_modules not found at " + publicPath + " or " + staticPath);
//     }
//   });
// };

// modules.importModules("LiveScript");
