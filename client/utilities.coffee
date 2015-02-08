@Keys = new class
  DELETE: [8, 46]

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
    character = null
    unless charCode in Keys.DELETE
      character = String.fromCharCode(charCode)

    phrase = Utils.currentRace().phrase
    text = $('#message').val()
    re = new RegExp("^(#{text})(#{character})(.*?)")
    isValid = re.test(phrase)
    color = isValid && "good" || "bad"

    $goal = $('.goal')
    goalText = $goal.text()
    highlightedGoal = null
    if isValid
      Session.set 'lastValid', text + character
      highlightedGoal = goalText.replace re, (match, $1, $2) ->
        "<span class='good'>#{match}</span>"
    else
      lastValid = Session.get 'lastValid'
      replacementText = goalText.replace(new RegExp(lastValid), "")
      highlightedGoal =
        "<span class='good'>#{lastValid}</span>" +
        "<span class='bad'>#{replacementText}</span>"

    $goal.html highlightedGoal
