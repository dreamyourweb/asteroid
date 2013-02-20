class TrelloCardMove extends Minimongoid
  @_collection: new Meteor.Collection 'trellocardmoves'

  @importMoves: ->
    Meteor.call 'getTrelloCardMoves', (e,moves) ->
      if moves?
        for i, move of moves
          if (old_move = TrelloCardMove.where(_id: move.id)[0]) != undefined
            console.log(old_move.update move)
          else
            console.log(TrelloCardMove.create move)


class TrelloCard extends Minimongoid
  @_collection: new Meteor.Collection 'trellocard'
  @list_ids: ["4f7b0a856f0fc2d24dabec3c", "4f7b0a856f0fc2d24dabec3b","4f7b0a856f0fc2d24dabec3d","4f7b0bac01fd2f07368c022c","4f7b0bb101fd2f07368c08b8"]

  @importCards: ->
    Meteor.call 'getTrelloCards', (e,cards) ->
      if cards?
        for i, card of cards
          if (old_card = TrelloCard.where(_id: card.id)[0]) != undefined
            console.log(old_card.update card)
          else
            console.log(TrelloCard.create card)


if Meteor.isServer
  Meteor.methods getTrelloCards: ->
    result = undefined
    @unblock()
    result = Meteor.http.call("GET", "https://api.trello.com/1/boards/4f7b0a856f0fc2d24dabec36/cards",
      params:
        key: "b21235703575c2c2844154615e41c3d4"
        token: _TRELLO_TOKEN
        limit: 500
        filter: 'all'
    )
    if result.statusCode is 200
      return result.data

    false

  Meteor.methods getTrelloCardMoves: ->
    result = undefined
    @unblock()
    result = Meteor.http.call("GET", "https://api.trello.com/1/boards/4f7b0a856f0fc2d24dabec36/actions",
      params:
        key: "b21235703575c2c2844154615e41c3d4"
        token: _TRELLO_TOKEN
        filter: "updateCard,createCard"
        limit: 500
    )
    if result.statusCode is 200
      # return result
      moves = []
      for i, action of result.data
        do (action) ->
          if ((action.data.listBefore != undefined && action.type == "updateCard") || action.type == "createCard" || (action.type == "updateCard" && action.data.card.closed == true && action.data.old.closed == false))
            moves.push action
      return moves
