Meteor.methods getTogglTimeEntries: (user) ->

  api_token = user.api_token
  user_id = user.id

  startdate = new Date
  startdate.setDate(startdate.getDate()-365)

  if (lastTogglDate = Toggl.findOne({user_id: user_id},{sort: {stop: -1}}).stop)
    lastTogglDate = lastTogglDate
  else
    lastTogglDate = startdate.toJSON()

  console.log lastTogglDate
  console.log (new Date).toJSON()

  result = undefined
  @unblock()
  result = Meteor.http.call(
    "GET"
    "https://www.toggl.com/api/v6/time_entries.json"
    auth: "#{api_token}:api_token"
    params:
      start_date: lastTogglDate
      end_date: (new Date).toJSON()

  )
  console.log result
  return result if result.statusCode is 200
  false

Meteor.methods getTogglWorkspaces: ->
  result = undefined
  @unblock()
  result = Meteor.http.call(
    "GET"
    "https://www.toggl.com/api/v6/workspaces.json"
    auth: "4e028d46877b997bdd89ceb4130ae00e:api_token"
  )

  return result if result.statusCode is 200
  false

# curl -v -u 1971800d4d82861d8f2c1651fea4d212:api_token -X GET https://www.toggl.com/api/v6/workspaces/31366/users.json

# curl -v -u 1971800d4d82861d8f2c1651fea4d212:api_token -X GET https://www.toggl.com/api/v6/workspaces.json