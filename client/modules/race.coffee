timer = new Timer 0, ->
  Session.set 'elapsedRaceTime', @elapsedTime / 1000

Template.race.helpers
  timer: ->
    (+Session.get('elapsedRaceTime')).toFixed 2

  wpm: ->
    Utils.currentWordsPerMinute().toFixed()

  race: ->
    Utils.currentRace()

  lastValid: ->
    Session.get 'lastValid'

  inRace: ->
    Session.get('raceKey')

  isParticipating: ->
    Utils.isParticipating()

  isPending: ->
    participant = Utils.currentParticipant(true)
    participant.state is 'pending'

  participants: ->
    RaceParticipants.find()

Template.race.rendered = ->
  raceKey = Router.current().state.get('raceKey')
  Session.set 'raceKey', raceKey
  Session.set 'elapsedRaceTime', 0

  Meteor.subscribe 'race', raceKey
  Meteor.subscribe 'racers', raceKey
  Meteor.subscribe 'raceParticipants', raceKey, ->
    participantsCursor = RaceParticipants.find()
    participantsCursor.observe
      added: (participant) ->
        unless Utils.isRacer participant.racerKey
          Utils.redrawParticipant participant

      changed: (participant) ->
        unless Utils.isRacer participant.racerKey
          Utils.redrawParticipant participant

  Meteor.subscribe 'sequences', raceKey

  if Utils.isParticipating()
    $('#message').focus()

Template.race.events
  'click .ready-button': (e) ->
    Utils.readyUp()
    Utils.startStoplight =>
      timer.start()

  'click .leave-button': (e) ->
    Utils.leaveRace()

  'click .join-race-button': (e) ->
    Session.set 'lastValid', ''
    Meteor.call 'joinRace', Utils.participantPointer()

  'keypress :text': (e) ->
    charCode = e.which || e.keyCode
    Utils.validateSequence(charCode)

    timer.stop() if Utils.raceFinished()

  'keydown :text': (e) ->
    return if $(e.currentTarget).val().length < 1
    charCode = e.which || e.keyCode
    Utils.validateSequence(charCode)

    timer.stop() if Utils.raceFinished()


Template.race_participant.helpers
  name: ->
    @racer ||= Utils.racer @racerKey
    if Utils.isRacer @racerKey
      "You"
    else if @racer && @racer.name
      @racer.name
    else
      "The Mysterious Racer X"

  avatar: ->
    @racer ||= Utils.racer @racerKey
    @racer.avatar || 'car'

Template.race_participant.rendered = ->
  participant = RaceParticipants.findOne(racerKey: @data.racerKey)
  Utils.redrawParticipant participant
