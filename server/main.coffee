Meteor.methods
  createRace: (raceKey)  ->
    Races.create
      raceKey: raceKey
      phrase: "abcdefghijklmnopqrstuvwxyz"
      state: "waiting_for_racers"

  joinRace: (joinRacePacket) ->
    check(joinRacePacket, ValidJoinRacePacket)

  changeRacerStatus: (racerStatusPacket) ->
    check(racerStatusPacket, ValidChangeRacerStatusPacket)

  racerStep: (racePacket) ->
    check(racePacket, ValidRacePacket)

    Sequences.create
      racerId: racePacket.racerId
      raceKey: racePacket.raceKey
      keycode: racePacket.keycode
      timecode: racePacket.timecode


Meteor.startup ->
  Meteor.publish "racers", (raceKey) ->
    Racers.find
      raceId: raceKey

  Meteor.publish "sequences", (raceKey) ->
    Sequences.find
      raceId: raceKey
