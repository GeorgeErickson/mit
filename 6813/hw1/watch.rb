watch('src/jade/.*.jade') { |md| system "jade src/jade/translate_game.jade --out build"}
watch('src/less/.*.less') { |md| system "lessc src/less/base.less build/base.css; echo #{md[0]}"}
watch('src/coffee/.*.coffee') { |md| system "coffee -pb src/coffee/main.coffee > build/translate_game.js; echo #{md[0]}"}