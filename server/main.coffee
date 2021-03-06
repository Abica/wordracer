Meteor.methods
  loadRacer: (racerKey)  ->
    racer = Racers.findOne
      racerKey: racerKey

    unless racer
      racerKey = Meteor.uuid()

      racer = Racers.insert
        racerKey: racerKey
        name: "Racer #{Racers.find().count() + 1}"
        avatar: 'car'

     racer.racerKey || racerKey

  createRace: (raceKey)  ->
    Races.insert
      raceKey: raceKey
      #phrase: "abcdefghijklmnopqrstuvwxyz"
      phrase: "How now brown cow?"
      state: "waiting_for_racers"
      time: 0
      maxTime: 3 * 60

  joinRace: (participantPointer) ->
    check(participantPointer, ValidParticipantPointerPacket)

    RaceParticipants.upsert
      racerKey: participantPointer.racerKey
      raceKey: participantPointer.raceKey
    , $set:
        mistakes: 0
        progress: 0
        carKey: Meteor.uuid()
        state: 'pending'

  leaveRace: (participantPointer) ->
    check(participantPointer, ValidParticipantPointerPacket)

    participantPointer.state = 'exited'
    Meteor.call 'changeRacerState', participantPointer

  racerStarted: (participantPointer) ->
    check(participantPointer, ValidParticipantPointerPacket)

    participantPointer.state = 'started'
    Meteor.call 'changeRacerState', participantPointer

  racerReady: (participantPointer) ->
    check(participantPointer, ValidParticipantPointerPacket)

    participantPointer.state = 'ready'
    Meteor.call 'changeRacerState', participantPointer

  changeRacerState: (racerStatePacket) ->
    check(racerStatePacket, ValidChangeRacerStatePacket)

    state = racerStatePacket.state
    delete racerStatePacket.state

    RaceParticipants.update racerStatePacket,
      $set:
        state: state

  racerStep: (racePacket) ->
    check(racePacket, ValidRacePacket)

    Sequences.insert
      racerKey: racePacket.racerKey
      raceKey: racePacket.raceKey
      keycode: racePacket.keycode
      timecode: racePacket.timecode


Meteor.startup ->
  Meteor.publish "race", (raceKey) ->
    Races.find
      raceKey: raceKey

  Meteor.publish "racer", (racerKey) ->
    Racers.find
      racerKey: racerKey

  Meteor.publish "racers", (raceKey) ->
    participants = RaceParticipants.find(raceKey: raceKey)
    racerKeys = participants.map (participant) ->
      participant.racerKey

    Racers.find
      racerKey:
        $in: racerKeys

  Meteor.publish "raceParticipants", (raceKey) ->
    RaceParticipants.find
      raceKey: raceKey

  Meteor.publish "sequences", (raceKey) ->
    Sequences.find
      raceKey: raceKey
