var init;

init = function() {
  return window.app = {
    lang: {
      to: 'English',
      from: 'Spanish',
      dict: dicts['English']['Spanish'],
      word_from: false,
      word_correct: false,
      num_correct: 0,
      num_total: 0,
      num_wrong: 0,
      score: 0
    },
    hogan: {
      correct: Hogan.compile($('#t-correct').html()),
      wrong: Hogan.compile($('#t-wrong').html()),
      dropdown: Hogan.compile($('#t-dropdown').html())
    },
    dom: {
      render_lang_options: function() {
        var from_options, html, l, lang, to_options, _i, _j, _len, _len2, _ref;
        to_options = Object.keys(dicts);
        from_options = [];
        for (_i = 0, _len = to_options.length; _i < _len; _i++) {
          l = to_options[_i];
          _ref = Object.keys(dicts[l]);
          for (_j = 0, _len2 = _ref.length; _j < _len2; _j++) {
            lang = _ref[_j];
            from_options.push({
              to: l,
              from: lang
            });
          }
        }
        html = app.hogan.dropdown.render({
          options: from_options
        });
        return $('#drop_option').html(html);
      },
      change_lang: function(lang_to, lang_from) {
        if (lang_to == null) lang_to = app.lang.to;
        if (lang_from == null) lang_from = app.lang.from;
        $('.js_to').html(lang_to);
        $('.js_from').html(lang_from);
        $('#js_input').attr('placeholder', lang_to);
        app.lang.to = lang_to;
        app.lang.from = lang_from;
        app.lang.dict = dicts[lang_to][lang_from];
        $("#js_input").data().typeahead.source = Object.keys(app.lang.dict);
        this.random_word();
        $("#js_input").val('').focus();
        return true;
      },
      random_word: function() {
        var words;
        words = Object.keys(app.lang.dict);
        app.lang.word_correct = words[Math.floor(words.length * Math.random())];
        app.lang.word_from = app.lang.dict[app.lang.word_correct];
        $('#js_random_word').html(app.lang.word_from);
        return false;
      },
      _insert_prev: function(is_correct, val) {
        var row, score_el;
        app.lang.num_total += 1;
        if (is_correct) {
          app.lang.num_correct += 1;
          row = app.hogan.correct.render({
            word_from: app.lang.word_from,
            word_correct: app.lang.word_correct
          });
        } else {
          if (val === '') val = '--';
          app.lang.num_wrong += 1;
          row = app.hogan.wrong.render({
            word_from: app.lang.word_from,
            word_wrong: val,
            word_correct: app.lang.word_correct
          });
        }
        app.lang.score = app.lang.num_correct - app.lang.num_wrong;
        score_el = $('#score');
        if (app.lang.score > 0) {
          score_el.removeClass('red');
          score_el.addClass('blue');
        } else if (app.lang.score < 0) {
          score_el.removeClass('blue');
          score_el.addClass('red');
        } else {
          score_el.removeClass('blue');
          score_el.removeClass('red');
        }
        score_el.html(app.lang.score);
        return $('#js_answer_after').after(row);
      },
      answer_click: function(val) {
        var input;
        input = $('#js_input');
        if (!val) val = input.val();
        input.val('').focus();
        if (val === app.lang.word_correct) {
          this._insert_prev(true);
        } else {
          this._insert_prev(false, val);
        }
        return this.random_word();
      }
    }
  };
};

$(document).ready(function() {
  init();
  $("#js_input").typeahead({
    source: Object.keys(app.lang.dict)
  });
  app.dom.change_lang();
  $('.score_holder').popover();
  app.dom.render_lang_options();
  return $("#js_input").keypress(function(e) {
    if (e.keyCode === 13 && $('.typeahead').css('display') === 'none') {
      return app.dom.answer_click();
    }
  });
});
