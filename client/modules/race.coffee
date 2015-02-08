Template.race.helpers
  race: ->
    Utils.currentRace()

  inRace: ->
    Session.get('raceKey')

  isParticipating: ->
    Utils.isParticipating()

  participants: ->
    racerKeys = _.map RaceParticipants.find().fetch(), (r) ->
      r.racerKey

    Racers.find racerKey: {$in: racerKeys}

Template.race.rendered = ->
  raceKey = Router.current().state.get('raceKey')
  Session.set('raceKey', raceKey)

  Meteor.subscribe 'race', raceKey
  Meteor.subscribe 'racers', raceKey
  Meteor.subscribe 'raceParticipants', raceKey
  Meteor.subscribe 'sequences', raceKey

  if Utils.isParticipating()
    $('#message').focus()

Template.race.events
  'keypress :text': (e) ->
    character = String.fromCharCode(e.which || e.keyCode)
    phrase = Utils.currentRace().phrase
    text = $('#message').val()
    re = new RegExp("^(#{text})(#{character})(.*?)")
    isValid = re.test(phrase)

    $goal = $('.goal')
    $goal.html $goal.text().replace re, (match, $1, $2) ->
      "<span class='good'>#{match}</span>"

  'keydown :text': (e) ->
    console.log 'sdsds', e.which

Template.race_participant.helpers
  isCurrentRacer: (racerKey) ->
    Racer.racerKey is racerKey

Template.race_participant.rendered = ->
  participant = RaceParticipants.findOne
    racerKey: @data.racerKey

  $img = @$('img')
  $img.css
    left: "calc(#{participant.progress}% - #{$img.width()}px)"

