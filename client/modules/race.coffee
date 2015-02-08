Template.race.helpers
  race: ->
    Races.findOne()

  inRace: ->
    Session.get('raceKey')

  isParticipating: ->
    key = Session.get('racerKey')
    !!RaceParticipants.findOne
      racerKey: key

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
