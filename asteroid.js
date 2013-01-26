if (Meteor.isClient) {
  
  Session.set('query', "");

  Template.hello.greeting = function () {
    return "Welcome to asteroid.";
  };

  Template.hello.messages = function () {
    if (Session.equals('query',"")){
      return Messages.find();
    }else{
      return Messages.find({body: new RegExp('.*' + Session.get('query') + '.*', 'i') });
    }
  }; 


  Template.hello.events({
    'click #submit' : function () {
      // template data, if any, is available in 'this'
      body = $("input#message_input").val();
      Messages.insert({body: body});
    },
    'click #clear' : function () {
      // template data, if any, is available in 'this'
      Messages.remove({});
    },
    'keyup #search' : function (){
      Session.set('query', $("input#search").val());
    }
  });
}

if (Meteor.isServer) {
  Meteor.startup(function () {
    Messages.insert({body: "Hello World!"});
    Messages.insert({body: "Hello Again!"});
    Messages.insert({body: "Hello Live HTML!"});
  });
}
