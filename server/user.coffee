Meteor.methods populateUsers: ->

  Meteor.users.remove({})
 
  Accounts.createUser({profile: {full_name: "Andres Lamont"}, username: "andres", email: "andres@dreamyourweb.nl", password:"dreamyourasteroid"})
  Meteor.users.update {'username': "andres"} , {$set: {'toggl.id': 190122, 'toggl.api_token': _TOGGL_ANDRES_TOKEN}}
 
  Accounts.createUser({profile: {full_name: "Bram den Teuling"}, username: "bram", email: "bram@dreamyourweb.nl", password:"dreamyourasteroid"})
  Meteor.users.update {'username': "bram"} , {$set: {'toggl.id': 190130, 'toggl.api_token': _TOGGL_BRAM_TOKEN}}
 
  Accounts.createUser({profile: {full_name: "Luc Vandewall"}, username: "luc", email: "luc@dreamyourweb.nl", password:"dreamyourasteroid"})
  Meteor.users.update {'username': "luc"} , {$set: {'toggl.id': 190125, 'toggl.api_token': _TOGGL_LUC_TOKEN}} 

  Accounts.createUser({profile: {full_name: "Thijs van de Laar"}, username: "thijs", email: "thijs@dreamyourweb.nl", password:"dreamyourasteroid"})
  Meteor.users.update {'username': "thijs"} , {$set: {'toggl.id': 190124, 'toggl.api_token': _TOGGL_THIJS_TOKEN}}
 
  Meteor.call('getTrelloUserData')

Meteor.methods getTrelloUserData: ->

  result = undefined
  @unblock()
  result = Meteor.http.call("GET", "https://api.trello.com/1/boards/4f7b0a856f0fc2d24dabec36/members",
    params:
      key: "b21235703575c2c2844154615e41c3d4"
      token: _TRELLO_TOKEN
  )
  if result.statusCode is 200
    members = []
    for i, member of result.data
      do (member) ->
        members.push member
        Meteor.users.update {'profile.full_name': member.fullName} , {$set: {'trello.id': member.id, 'trello.username': member.username}}
    return members

  false

Meteor.methods getTogglUserData: ->
  result = undefined
  @unblock()
  result = Meteor.http.call(
    "GET"
    "https://www.toggl.com/api/v6/workspaces/#{Toggl.workspace}/users.json"
    auth: "#{_TOGGL_ANDRES_TOKEN}:api_token"
  )

  return result if result.statusCode is 200
  false


