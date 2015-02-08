Meteor.methods {}

Meteor.startup ->
  Meteor.publish "racers", (raceId) ->
    Racers.find
      raceId: raceId

  Meteor.publish "sequences", (raceId) ->
    Sequences.find
      raceId: raceId
