if Meteor.isClient
  
  Session.set 'query', ""

  Template.hello.greeting ->
    "Welcome to asteroid."

  Template.hello.messages ->
    if Session.equals 'query',"" 
      Messages.find()
    else
      Messages.find({body: new RegExp('.*' + Session.get('query') + '.*', 'i') }) 


  Template.hello.events(
    'click #submit' : !->
      body = $("input#message_input").val()
      Messages.insert {body: body}
    'click #clear' : !->
      Messages.remove({})
    'keyup #search' : !->
      Session.set('query', $("input#search").val())
  )

if Meteor.isServer
  Meteor.startup !->
    Messages.insert({body: "Hello World!"})
    Messages.insert({body: "Hello Again!"})
    Messages.insert({body: "Hello Live HTML!"})
