Meteor.Router.add('/commits', 'POST', () ->
  console.log @request.body

  
  return [204, 'No Content']
)