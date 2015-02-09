@assert = (cond, msg) ->
  throw(msg) unless cond

@Races = new Meteor.Collection("races")
@Racers = new Meteor.Collection("racers")
@RaceParticipants = new Meteor.Collection("race_participants")
@States = new Meteor.Collection("states")
@Sequences = new Meteor.Collection("sequences")

RaceParticipants.allow
  update: (userId, participant, fields, params) ->
    authPacket = params["$set"].extras

    check(authPacket, ValidJoinRacePacket)

    delete params["$set"].extras

    participant.raceKey is authPacket.raceKey &&
    participant.racerKey is authPacket.racerKey

@RaceStates =
  ['waiting_for_racers',
   'started',
   'abandoned',
   'finished']

@RacerStates =
  ['pending',
   'ready',
   'started',
   'ejected',
   'exited']