ValidKeycode = Match.Where (keycode) ->
  check(keycode, Integer)

  keycode > 0

# todo(nick): make more robust; possibly check code is within known race bounds
ValidTimecode = Match.Where (timecode) ->
  check(timecode, Integer)

  timecode > 0

ValidRaceID = Match.Where (id) ->
  check(id, String)

  id.length == 36

ValidRacePacket = Match.Where (packet) ->
  check(racePacket.raceKey, ValidRaceKey)
  check(racePacket.keycode, ValidKeycode)
  check(racePacket.timecode, ValidTimecode)

  Racer.findOne(_id: packet.racerId)
