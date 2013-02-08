class TrelloCard extends Minimongoid
  @_collection: new Meteor.Collection 'trellocard'

  @getCards: ->
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
      

Meteor.methods getTrelloCards: ->
  result = undefined
  @unblock()
  result = Meteor.http.call("GET", "https://api.trello.com/1/boards/4f7b0a856f0fc2d24dabec36/cards",
    params:
      key: "b21235703575c2c2844154615e41c3d4"
      token: "dff76c247049f7706a8c190252f3b9b60e4e51f40f7a9b06103111d64c22809b"
  )
  if result.statusCode is 200
    cards = []
    for i, card of result.data
      do (card) ->
        cards.push card
    return cards

  false