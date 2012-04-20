init = () ->
  window.app =
    #config section 
    lang:
      to: 'English'
      from: 'Spanish'
      dict: dicts['English']['Spanish']
      word_from: false
      word_correct: false
      num_correct: 0
      num_total: 0
      num_wrong: 0
      score: 0
    #templates
    hogan:
      correct: Hogan.compile $('#t-correct').html()
      wrong: Hogan.compile $('#t-wrong').html()
      dropdown: Hogan.compile $('#t-dropdown').html()
    #method section
    dom:
      render_lang_options: () ->
        #dynamically generate lang options
        to_options = Object.keys(dicts)
        from_options = []
        for l in to_options
          for lang in Object.keys(dicts[l])
            from_options.push(
              to: l
              from: lang
            )
        html = app.hogan.dropdown.render(
          options: from_options
        )
        $('#drop_option').html(html)
        
      
      #changes the languages defaults to whats stored
      change_lang: (lang_to=app.lang.to, lang_from=app.lang.from) ->

        #change dom
        $('.js_to').html lang_to
        $('.js_from').html lang_from
        $('#js_input').attr('placeholder', lang_to)
        
        #change state
        app.lang.to = lang_to
        app.lang.from = lang_from
        app.lang.dict = dicts[lang_to][lang_from]

        #typehead
        $("#js_input").data().typeahead.source = Object.keys(app.lang.dict)
        

        @random_word()
        $("#js_input").val('').focus()
        true
      
      #picks random word from dict and inserts into dom
      random_word: () ->
        #select random word
        words = Object.keys(app.lang.dict)
        app.lang.word_correct = words[Math.floor(words.length * Math.random())]
        app.lang.word_from= app.lang.dict[app.lang.word_correct]
        
        #insert word into dom
        $('#js_random_word').html(app.lang.word_from)
        false
      
      _insert_prev: (is_correct, val) ->
        app.lang.num_total += 1
        
        if is_correct
          app.lang.num_correct += 1
          row = app.hogan.correct.render(
            word_from: app.lang.word_from
            word_correct: app.lang.word_correct
          )
        else
          if val is ''
            val = '--'
          app.lang.num_wrong += 1
          row = app.hogan.wrong.render(
            word_from: app.lang.word_from
            word_wrong: val 
            word_correct: app.lang.word_correct
          )
        app.lang.score = app.lang.num_correct - app.lang.num_wrong
        #toggle score colors
        score_el = $('#score')
        if app.lang.score > 0
          score_el.removeClass('red')
          score_el.addClass('blue')
        else if app.lang.score < 0
          score_el.removeClass('blue')
          score_el.addClass('red')
        else
          score_el.removeClass('blue')
          score_el.removeClass('red')
        score_el.html(app.lang.score)
        $('#js_answer_after').after(row)
        
      answer_click: (val) ->
        input = $('#js_input')
        if not val
          val = input.val()
        input.val('').focus()
        
        #correct answer
        if val is app.lang.word_correct
          @_insert_prev(true)
        #incorrect answer
        else
          @_insert_prev(false, val)

        #new word
        @random_word()


$(document).ready () ->
  init()
  $("#js_input").typeahead(
    source: Object.keys(app.lang.dict)
  )
  app.dom.change_lang()
  $('.score_holder').popover()
  app.dom.render_lang_options()

  #enter submits box
  $("#js_input").keypress((e) ->
    
    if e.keyCode is 13 and $('.typeahead').css('display') is 'none'
      app.dom.answer_click()
  )

  


  













