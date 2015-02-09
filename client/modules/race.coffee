Template.race.helpers
  race: ->
    Utils.currentRace()

  inRace: ->
    Session.get('raceKey')

  isParticipating: ->
    Utils.isParticipating()

  isPending: ->
    Utils.currentParticipant().state is 'pending'

  participants: ->
    RaceParticipants.find()

Template.race.rendered = ->
  raceKey = Router.current().state.get('raceKey')
  Session.set('raceKey', raceKey)

  Meteor.subscribe 'race', raceKey
  Meteor.subscribe 'racers', raceKey
  Meteor.subscribe 'raceParticipants', raceKey, ->
    participantsCursor = RaceParticipants.find()
    participantsCursor.observe
      added: (participant) ->
      changed: (participant) ->

  Meteor.subscribe 'sequences', raceKey

  if Utils.isParticipating()
    $('#message').focus()

Template.race.events
  'click .ready-button': (e) ->

  'click .leave-button': (e) ->

  'click .join-race-button': (e) ->
    Session.set 'lastValid', ''
    Meteor.call 'joinRace', Utils.participantPointer()

  'keypress :text': (e) ->
    charCode = e.which || e.keyCode
    Utils.validateSequence(charCode)

    participant = Utils.currentParticipant()

    validCount = Session.get('lastValid').length
    requiredCount = Utils.currentRace().phrase.length

    participant.progress = validCount / requiredCount * 100

    RaceParticipants.update
      _id: participant._id
    , $set:
        progress: participant.progress
        extras: Utils.participantPointer()

    Utils.redrawParticipant participant

  'keydown :text': (e) ->
    return if $(e.currentTarget).val().length < 1
    charCode = e.which || e.keyCode
    Utils.validateSequence(charCode)

Template.race_participant.helpers
  isCurrentRacer: (racerKey) ->
    Utils.isRacer racerKey

Template.race_participant.rendered = ->
  participant = RaceParticipants.findOne(racerKey: @data.racerKey)
  Utils.redrawParticipant participant
