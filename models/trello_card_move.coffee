class TrelloCardMove extends Minimongoid
  @_collection: new Meteor.Collection 'trellocardmoves'

  @get_card_moves: ->
    Meteor.call 'getTrelloCardMoves', (e,actions) ->
      if actions?
        for i, action of actions
          action.data._id = action.id
          console.log(TrelloCardMove.create action.data )
      

# Meteor.methods getTrelloCardMoves: ->
#   result = undefined
#   @unblock()
#   result = Meteor.http.call("GET", "https://api.trello.com/1/boards/4f7b0a856f0fc2d24dabec36/actions",
#     params:
#       key: "b21235703575c2c2844154615e41c3d4"
#       token: "dff76c247049f7706a8c190252f3b9b60e4e51f40f7a9b06103111d64c22809b"
#       filter: "updateCard,createCard"
#   )
#   if result.statusCode is 200
#     actions = []
#     for i, action of result.data
#       do (action) ->
#         if ((action.data.listBefore != undefined && action.type == "updateCard"))#||action.type == "createCard")
#           actions.push action
#     return actions

#   false