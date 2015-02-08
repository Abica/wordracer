@assert = (cond, msg) ->
  throw(msg) unless cond

@Races = new Meteor.Collection("races")
@Racers = new Meteor.Collection("racers")
@States = new Meteor.Collection("states")
@Sequences = new Meteor.Collection("sequences")