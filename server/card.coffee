Meteor.methods getTrelloCards: ->
    result = undefined
    @unblock()
    result = Meteor.http.call("GET", "https://api.trello.com/1/boards/4f7b0a856f0fc2d24dabec36/cards",
      params:
        key: "b21235703575c2c2844154615e41c3d4"
        token: _TRELLO_TOKEN
    )
    if result.statusCode is 200
      # return result
      cards = []
      for i, card of result.data
        do (card) ->
          cards.push card
      return cards

    false


Meteor.methods getTrelloCardMoves: (card_id) ->
  result = undefined
  @unblock()
  result = Meteor.http.call("GET", "https://api.trello.com/1/boards/4f7b0a856f0fc2d24dabec36/actions",
    params:
      key: "b21235703575c2c2844154615e41c3d4"
      token: _TRELLO_TOKEN
      filter: "updateCard,createCard"
  )

  # result = Meteor.http.call("GET", "https://api.trello.com/1/cards/#{card_id}/actions",
  #   params:
  #     key: "b21235703575c2c2844154615e41c3d4",
  #     token: _TRELLO_TOKEN
  # )
  if result.statusCode is 200
    # return result
    actions = []
    for i, action of result.data
      do (action) ->
        if ((action.data.listBefore != undefined && action.type == "updateCard") || action.type == "createCard") && action.data.card.id == card_id
          actions.push action
    return actions