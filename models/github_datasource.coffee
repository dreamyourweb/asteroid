Meteor.methods getGithubEvents: ->

  result = undefined
  @unblock()
  result = Meteor.http.call("GET", "https://api.github.com/dreamyourweb/asteroid/events",
    params:
      client_id: _GITHUIB_ID,
      client_secret: _GITHUB_SECRET
  )
  if result.statusCode is 200
    return result

  false
