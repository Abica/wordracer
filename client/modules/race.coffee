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
  Meteor.subscribe 'raceParticipants', raceKey, ->
    participantsCursor = RaceParticipants.find()
    participantsCursor.observe
      changed: (participant) ->

  Meteor.subscribe 'sequences', raceKey

  if Utils.isParticipating()
    $('#message').focus()

Template.race.events
  'keypress :text': (e) ->
    charCode = e.which || e.keyCode
    Utils.validateSequence(charCode)

    participant = Utils.currentParticipant()
    params =
      racerKey: Session.get('racerKey')
      raceKey: Session.get('raceKey')

    validCount = Session.get('lastValid').length
    requiredCount = Utils.currentRace().phrase.length
    RaceParticipants.update
      _id: participant._id
    , $set:
        progress: validCount / requiredCount * 100
        extras: params

  'keydown :text': (e) ->
    charCode = e.which || e.keyCode
    Utils.validateSequence(charCode)

Template.race_participant.helpers
  isCurrentRacer: (racerKey) ->
    Racer.racerKey is racerKey

Template.race_participant.rendered = ->
  participant = Utils.currentParticipant()
  $img = @$('img')
  $img.css
    left: "calc(#{participant.progress}% - #{$img.width()}px)"

