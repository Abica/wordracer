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
