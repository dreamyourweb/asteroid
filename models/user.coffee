class User extends Minimongoid
  @_collection: new Meteor.Collection 'users'

  @fields:
    name: {default: "Andres"}