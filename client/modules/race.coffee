Template.race.helpers
  race: ->
    Utils.currentRace()

  inRace: ->
    Session.get('raceKey')

  isParticipating: ->
    Utils.isParticipating()

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
    return if $(e.currentTarget).val().length < 1
    charCode = e.which || e.keyCode
    Utils.validateSequence(charCode)

Template.race_participant.helpers
  isCurrentRacer: (racerKey) ->
    Utils.isRacer racerKey

Template.race_participant.rendered = ->
  participant = RaceParticipants.findOne(racerKey: @data.racerKey)

  progress = participant.progress || 0

  $img = @$('img')
  maxLength = @$('.track').width() - $img.width()
  progress = progress * maxLength / 100

  $img.css
    left: progress + "px"

