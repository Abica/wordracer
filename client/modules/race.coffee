Template.race.helpers
  inRoom: ->
    Session.get('raceKey')

Template.race.rendered = ->
  raceKey = Router.current().state.get('raceKey')
  Session.set('raceKey', raceKey)

  Meteor.subscribe "racers", raceKey
  Meteor.subscribe "sequences", raceKey

