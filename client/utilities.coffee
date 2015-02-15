@Keys = new class
  DELETE: [8, 46]
  CONTROL: [91]

@RegexUtils = new class
  escape: (str) ->
    str.replace /([.*+?^${}()|\[\]\/\\])/g, "\\$1"

  unescape: (str) ->
    str.replace /\\([.*+?^${}()|\[\]\/\\])/g, "\$1"

  fromComponents: (components...) ->
    str = [@escape(re) for re in components].join("")
    new RegExp(str)

  escapeComponents: (components...) ->
    [@escape(re) for re in components...]


@Utils = new class
  setDefault: (name, defaultValue) ->
    Session.set name, Session.get(name) || defaultValue

  isParticipating: ->
    participant = @currentParticipant()
    participant && participant.state in ['pending', 'ready', 'started']

  currentRace: ->
    @race ||= Races.findOne()

  isRacer: (racerKey) ->
    Session.get('racerKey') is racerKey

  racer: (racerKey) ->
    Racers.findOne
      racerKey: racerKey

  participantPointer: ->
    racerKey: Session.get('racerKey')
    raceKey: Session.get('raceKey')

  currentParticipant: (reload = false) ->
    key = Session.get('racerKey')
    @participant = null if reload
    @participant ||= RaceParticipants.findOne
      racerKey: key

  resetRacer: ->
    Session.set 'lastValid', ''
    @participant = null

  leaveRace: ->
    Meteor.call 'leaveRace', @participantPointer()
    @resetRacer()

  readyUp: ->
    Meteor.call 'racerReady', @participantPointer(), ->
      $('#message').focus()

  stepCurrentRacer: (character = null) ->
    participant = @currentParticipant()
    validCount = Session.get('lastValid').length
    requiredCount = @currentRace().phrase.length

    participant.progress = validCount / requiredCount * 100

    RaceParticipants.update
      _id: participant._id
    , $set:
        progress: participant.progress
        lastCharacter: character
        extras: @participantPointer()

    @redrawParticipant participant

  currentWordsPerMinute: (wordsOnly = true) ->
    sequence = Session.get('lastValid') || ""
    validCount = null

    if wordsOnly
      validCount = sequence.split(/\s+/).length
    else
      validCount = sequence.length

    elapsed = +Session.get('elapsedRaceTime')

    return 0 if elapsed is 0

    validCount / (elapsed / 60)

  raceFinished: ->
    race = @currentRace()
    return true if race.state in ['finished', 'abandoned']
    validCount = (Session.get('lastValid') || '').length
    requiredCount = Utils.currentRace().phrase.length
    validCount is requiredCount

  redrawParticipant: (participant) ->
    progress = participant.progress || 0

    $car = $(".car-#{participant.carKey}")
    $img = $car.find('.car')
    $track = $car.find('.track')
    maxLength = $track.width() - $img.width()
    progress = progress * maxLength / 100

    if $img.is(':animated')
      $img.stop()

    $img.animate
      left: progress
    ,
      duration: 500
      easing: 'linear'

  validateSequence: (charCode, deleteOnly = false) ->
    return if charCode in Keys.CONTROL

    $message = $('#message')
    $goal = $('.goal')

    phrase = Utils.currentRace().phrase
    text = $message.val()

    character = null
    isDelete = charCode in Keys.DELETE

    return if deleteOnly and not isDelete

    if isDelete
      character = text.substr(-2, 1)
      text = text.substr(0, text.length - 2)
      if text.length is 0
        character = ''
    else
      character = String.fromCharCode(charCode)


    [text, character] = RegexUtils.escapeComponents(text, character)
    re = new RegExp("^(#{text})(#{character})")
    isValid = re.test(phrase)

    goalText = $goal.text()
    highlightedGoal = null
    if isValid
      $body = $('body')
      if $body.is(':animated')
        $body.stop()

      velocity = 40
      if isDelete
        velocity *= -1

      value = parseInt($body.css('background-position')) + velocity
      $body.animate
        backgroundPosition: value
      ,
        easing: 'linear'
        duration: 500

      Session.set 'lastValid', RegexUtils.unescape(text + character)
      highlightedGoal = goalText.replace re, (match, $1, $2) ->
        "<span class='good'>#{match}</span>"

      @checkEndGame()

    else
      lastValid = Session.get 'lastValid' || ''
      replacementText = goalText.replace(new RegExp(lastValid), '')
      highlightedGoal =
        "<span class='good'>#{lastValid}</span>" +
        "<span class='bad'>#{replacementText}</span>"

    $goal.html highlightedGoal

    @stepCurrentRacer RegexUtils.unescape(character)

  checkEndGame: ->
    if Utils.raceFinished()
      $message = $('#message')
      $message.val(Session.get('lastValid'))
      $message.attr('disabled', true)
      $message.blur()
      @showShade()
      $('.race-participant, .new-race, .time, .wpm').addClass 'topLayer relative'

  showShade: ->
    $('.shade').show()

  hideShade: ->
    $('.shade').hide()

  startStoplight: (onGo = ->) ->
    @showShade()
    $stoplight = $('#stoplight-section').show()
    $stoplight.find('dim').removeClass('dim')
    $ready = $stoplight.find('.ready')
    $set = $stoplight.find('.set')
    $go = $stoplight.find('.go')
    duration = 700
    $ready.fadeOut
      duration: duration
      complete: ->
        $ready.show().addClass 'dim'
        $set.fadeOut
          duration: duration
          complete: ->
            $set.show().addClass 'dim'
            $go.fadeOut
              duration: duration
              complete: ->
                $go.show().addClass 'dim'
                $stoplight.hide()
                Utils.hideShade()
                $('#message').focus()
                onGo()
