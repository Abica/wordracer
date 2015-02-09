@Keys = new class
  DELETE: [8, 46]
  CONTROL: [91]

@RegexUtils = new class
  escape: (str) ->
    str.replace /([.*+?^${}()|\[\]\/\\])/g, "\\$1"

  fromComponents: (components...) ->
    str = [@escape(re) for re in components].join("")
    new RegExp(str)

  escapeComponents: (components...) ->
    _.map components, (re) ->
      @escape re


@Utils = new class
  setDefault: (name, defaultValue) ->
    Session.set name, Session.get(name) || defaultValue

  isParticipating: ->
    !!@currentParticipant()

  currentRace: ->
    @race ||= Races.findOne()

  isRacer: (racerKey) ->
    Session.get('racerKey') is racerKey

  participantPointer: ->
    racerKey: Session.get('racerKey')
    raceKey: Session.get('raceKey')

  currentParticipant: (reload = false) ->
    key = Session.get('racerKey')
    @participant = null if reload
    @participant ||= RaceParticipants.findOne
      racerKey: key

  leaveRace: ->
    Session.set 'lastValid', ''
    Meteor.call 'leaveRace', @participantPointer()
    @participant = null

  readyUp: ->
    Meteor.call 'racerReady', @participantPointer(), ->
      $('#message').focus()

  stepCurrentRacer: ->
    participant = @currentParticipant()
    validCount = Session.get('lastValid').length
    requiredCount = @currentRace().phrase.length

    participant.progress = validCount / requiredCount * 100

    RaceParticipants.update
      _id: participant._id
    , $set:
        progress: participant.progress
        extras: @participantPointer()

    @redrawParticipant participant

  raceFinished: ->
    race = @currentRace()
    return true if race.state in ['finished', 'abandoned']
    validCount = (Session.get('lastValid') || '').length
    requiredCount = Utils.currentRace().phrase.length
    validCount is requiredCount

  redrawParticipant: (participant) ->
    progress = participant.progress || 0

    $car = $(".car-#{participant.carKey}")
    $img = $car.find('img')
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

  validateSequence: (charCode) ->
    $message = $('#message')
    $goal = $('.goal')

    if Utils.raceFinished()
      $message.val(Session.get('lastValid'))
      $message.attr('disabled', true)

    return if charCode in Keys.CONTROL

    phrase = Utils.currentRace().phrase
    text = $message.val()

    character = null
    if charCode in Keys.DELETE
      character = text.substr(-2, 1)
      text = text.substr(0, text.length - 2)
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

      value = parseInt($body.css('background-position')) + 20
      $body.animate
        backgroundPosition: value
      ,
        easing: 'linear'
        duration: 500

      Session.set 'lastValid', text + character
      highlightedGoal = goalText.replace re, (match, $1, $2) ->
        "<span class='good'>#{match}</span>"

    else
      lastValid = Session.get 'lastValid' || ''
      replacementText = goalText.replace(new RegExp(lastValid), '')
      highlightedGoal =
        "<span class='good'>#{lastValid}</span>" +
        "<span class='bad'>#{replacementText}</span>"

    $goal.html highlightedGoal
    @stepCurrentRacer()
