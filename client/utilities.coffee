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

  currentParticipant: ->
    key = Session.get('racerKey')
    @participant ||= RaceParticipants.findOne
      racerKey: key

  raceFinished: ->
    race = @currentRace()
    return true if race.state in ['finished', 'abandoned']
    validCount = (Session.get('lastValid') || '').length
    requiredCount = Utils.currentRace().phrase.length
    validCount is requiredCount

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

