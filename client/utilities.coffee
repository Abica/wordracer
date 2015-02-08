@Keys = new class
  DELETE: [8, 46]
  CONTROL: [91]

@Utils = new class
  setDefault: (name, defaultValue) ->
    Session.set name, Session.get(name) || defaultValue

  isParticipating: ->
    !!@currentParticipant()

  currentRace: ->
    @race ||= Races.findOne()

  currentParticipant: ->
    key = Session.get('racerKey')
    @participant ||= RaceParticipants.findOne
      racerKey: key

  validateSequence: (charCode) ->
    return if charCode in Keys.CONTROL

    $message = $('#message')
    $goal = $('.goal')

    phrase = Utils.currentRace().phrase
    text = $message.val()

    character = null
    if charCode in Keys.DELETE
      character = text.substr(-2, 1)
      text = text.substr(0, text.length - 2)
    else
      character = String.fromCharCode(charCode)

    re = new RegExp("^(#{text})(#{character})")
    isValid = re.test(phrase)

    goalText = $goal.text()
    highlightedGoal = null
    if isValid
      Session.set 'lastValid', text + character
      highlightedGoal = goalText.replace re, (match, $1, $2) ->
        "<span class='good'>#{match}</span>"

    else
      lastValid = Session.get 'lastValid' || ""
      replacementText = goalText.replace(new RegExp(lastValid), "")
      highlightedGoal =
        "<span class='good'>#{lastValid}</span>" +
        "<span class='bad'>#{replacementText}</span>"

    $goal.html highlightedGoal
