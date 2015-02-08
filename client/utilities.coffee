@Utils = new class
  setDefault: (name, defaultValue) ->
    Session.set name, Session.get(name) || defaultValue

  isParticipating: ->
    key = Session.get('racerKey')
    !!RaceParticipants.findOne
      racerKey: key
