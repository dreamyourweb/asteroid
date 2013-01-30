Meteor.methods(
  getTogglTimeEntries: ->
    this.unblock();
    result = Meteor.http.call("GET", "https://www.toggl.com/api/v6/time_entries.json" ,auth: "4e028d46877b997bdd89ceb4130ae00e:api_token", params: {start_date:"2013-01-01T00:00:00+02:00", end_date:"2013-01-30T00:00:00+02:00"})
    if result.statusCode == 200
      return result
    return false;
  )
