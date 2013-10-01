module.exports = function(grunt) {
  grunt.loadNpmTasks("grunt-mocha-test");
  grunt.loadNpmTasks("grunt-contrib-watch");
  grunt.loadNpmTasks("grunt-contrib-clean");
  grunt.loadNpmTasks("grunt-livescript");
  grunt.loadNpmTasks("grunt-lineending");
  grunt.loadNpmTasks("grunt-verbosity");

  grunt.initConfig({
    clean: {
      lib: 'lib/'
    },
    livescript: {
      options: { bare: true },
      src: {
        files: [{ expand: true, cwd: 'src', src: ['*.ls'], dest: 'lib', ext: '.js'}]
      }
    },
    watch: {
      spec: {
        files: ["spec/*-spec.ls", "src/*.ls"]
      }
    },
    mochaTest: {
      options: {
        reporter: "spec",
        require: "grunt-livescript/node_modules/dslivescript"
      },
      test: {
        src: "spec/*.ls"
      }
    },
    lineending: {
      all: {
        files: [{
          expand: true,
          src: ['**/*', '.*', '!node_modules/**/*', '!tmp/**/*'],
          filter: 'isFile',
          dest: '.'
        }]
      }
    },
    verbosity: {
      all: {
        options: { mode: 'dot' },
        tasks: ['lineending', 'livescript', 'clean']
      }
    },
    pkg: require('./package.json')
  });

  grunt.event.on('watch', function(action, filepath, target) {
    specPath = filepath.replace(/src([\/\\].*)\.ls/, 'spec$1-spec.ls');
    grunt.log.ok('________________________________________');
    grunt.util.spawn({
      cmd: 'mocha',
      args: ['--compilers', 'ls:grunt-livescript/node_modules/dslivescript', '-R', 'min', specPath],
      opts: {stdio: 'inherit'}
    }, function done() {
      grunt.log.ok('========================================');
    });
  });

  grunt.task.registerTask('build', ['verbosity', 'lineending', 'livescript']);
  grunt.task.registerTask('dist', ['clean:lib', 'test', 'build']);
  grunt.task.registerTask('test', ['mochaTest']);
  grunt.task.registerTask('default', ['dist']);
}
