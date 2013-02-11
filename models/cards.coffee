class TrelloCard extends Minimongoid
  @_collection: new Meteor.Collection 'trellocard'

  @importCards: ->
    Meteor.call 'getTrelloCards', (e,cards) ->
      if cards?
        for i, card of cards
          bsc_amount = card.desc.match(/BSC:(.|\n)*- (\d*)€/)
          bsc_amount = parseFloat(bsc_amount[bsc_amount.length-1]) if bsc_amount?
          bsc_prob = card.desc.match(/BSC:(.|\n)*- (\d*)%/)
          bsc_prob = parseFloat(bsc_prob[bsc_prob.length-1]) if bsc_prob?
          attributes = {card_id: card.id, name: card.name, desc: card.desc, bsc_amount: bsc_amount, bsc_prob: bsc_prob}
          if (old_card = TrelloCard.where({card_id: card.id})[0]) != undefined
            console.log(old_card.update attributes)
          else
            console.log(TrelloCard.create attributes)

  importActions: ->
    Meteor.call 'getTrelloCardMoves', @attributes.card_id, (e,moves) =>
      @insert {moves: moves}
      console.log(@save())

  timeline: ->
    if @attributes.moves
      card_moves = []
      for i in [0..@attributes.moves.length-2]
        action_string = "#{ @attributes.moves[i].data.listBefore.name } -> #{ @attributes.moves[i].data.listAfter.name }"
        card_moves.push {dX: action_string ,dT: (new Date(@attributes.moves[i].date) - new Date(@attributes.moves[i+1].date))/1000/3600}
      return card_moves
    false
      

Meteor.methods getTrelloCards: ->
  result = undefined
  @unblock()
  result = Meteor.http.call("GET", "https://api.trello.com/1/boards/4f7b0a856f0fc2d24dabec36/cards",
    params:
      key: "b21235703575c2c2844154615e41c3d4"
      token: "dff76c247049f7706a8c190252f3b9b60e4e51f40f7a9b06103111d64c22809b"
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
      token: "dff76c247049f7706a8c190252f3b9b60e4e51f40f7a9b06103111d64c22809b"
      filter: "updateCard,createCard"
  )

  # result = Meteor.http.call("GET", "https://api.trello.com/1/cards/#{card_id}/actions",
  #   params:
  #     key: "b21235703575c2c2844154615e41c3d4",
  #     token: "dff76c247049f7706a8c190252f3b9b60e4e51f40f7a9b06103111d64c22809b" 
  # )
  if result.statusCode is 200
    # return result
    actions = []
    for i, action of result.data
      do (action) ->
        if ((action.data.listBefore != undefined && action.type == "updateCard") || action.type == "createCard") && action.data.card.id == card_id
          actions.push action
    return actions