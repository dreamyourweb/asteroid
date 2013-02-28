Meteor.methods getTogglTimeEntries: ->
  startdate = new Date
  startdate.setDate(startdate.getDate()-365)
  result = undefined
  @unblock()
  result = Meteor.http.call("GET", "https://www.toggl.com/api/v6/time_entries.json",
    auth: "4e028d46877b997bdd89ceb4130ae00e:api_token"
    params:
      start_date: startdate.toJSON()
      end_date: (new Date).toJSON()
  )
  console.log result
  return result  if result.statusCode is 200
  false
