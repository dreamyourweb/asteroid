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
