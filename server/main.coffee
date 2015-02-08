Meteor.methods
  loadRacer: (racerId)  ->
    racer = Racers.findOne
      racerId: racerId

    unless racer
      racerId = Meteor.uuid()

      racer = Racers.insert
        racerId: racerId

     racer.racerId || racerId

  createRace: (raceKey)  ->
    Races.insert
      raceKey: raceKey
      phrase: "abcdefghijklmnopqrstuvwxyz"
      state: "waiting_for_racers"

  joinRace: (joinRacePacket) ->
    check(joinRacePacket, ValidJoinRacePacket)

    RaceParticipants.insert
      racerId: joinRacePacket.racerId
      raceKey: joinRacePacket.raceKey

  changeRacerStatus: (racerStatusPacket) ->
    check(racerStatusPacket, ValidChangeRacerStatusPacket)

    status = racerStatusPacket.status
    delete racerStatusPacket.status

    RaceParticipants.update raceStatusPacket,
      $set:
        status: status

  racerStep: (racePacket) ->
    check(racePacket, ValidRacePacket)

    Sequences.insert
      racerId: racePacket.racerId
      raceKey: racePacket.raceKey
      keycode: racePacket.keycode
      timecode: racePacket.timecode


Meteor.startup ->
  Meteor.publish "race", (raceKey) ->
    Races.find
      raceKey: raceKey

  Meteor.publish "racers", (raceKey) ->
    participants = RaceParticipants.find(raceKey: raceKey)
    racerIds = participants.map (p) -> p.racerId

    Racers.find
      _id:
        $in: racerIds

  Meteor.publish "racerParticipants", (raceKey) ->
    RaceParticipants.find
      raceKey: raceKey

  Meteor.publish "sequences", (raceKey) ->
    Sequences.find
      raceKey: raceKey
