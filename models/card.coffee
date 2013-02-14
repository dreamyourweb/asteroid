class TrelloCardMove extends Minimongoid
  @_collection: new Meteor.Collection 'trellocardmoves'

  @importMoves: ->
    for i, card of TrelloCard.all()
      for j, move of card.timeline()
        move = $.extend(move,{card_id: card.card_id})
        if (old_move = TrelloCardMove.where({move_id: move.move_id})[0]) != undefined
          old_move.update move
          old_move.save()
        else
          console.log(TrelloCardMove.create move)


class TrelloCard extends Minimongoid
  @_collection: new Meteor.Collection 'trellocard'
  @list_ids: ["4f7b0a856f0fc2d24dabec3c", "4f7b0a856f0fc2d24dabec3b","4f7b0a856f0fc2d24dabec3d","4f7b0bac01fd2f07368c022c","4f7b0bb101fd2f07368c08b8"]

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

  # TODO: Make faster
  @importMoves: ->
    Meteor.call 'getTrelloCardMoves', (e,moves) =>
      for i,card of TrelloCard.all()
        card_moves = []
        card.attributes.timeline = undefined
        for j, move of moves
          if move.data.card.id == card.card_id
            card_moves.push move

        card.insert {moves: card_moves}
        console.log(card.save())

  timeline: (update) ->
    if @attributes.timeline != undefined && update != true
      return @attributes.timeline
    else
      if @attributes.moves
        card_moves = []
        if @attributes.moves.length > 1
          for i in [0..@attributes.moves.length-2]
            console.log( @attributes.moves[i])
            card_moves.push {date: @attributes.moves[i].date, move_id: @attributes.moves[i].id ,x1: @attributes.moves[i].data.listBefore.id , x2: @attributes.moves[i].data.listAfter.id, dT: (new Date(@attributes.moves[i].date) - new Date(@attributes.moves[i+1].date))/1000/3600}
          @insert {timeline: card_moves}
          @save()
          return card_moves
    false

  @moves: ->
    # TrelloCard.where({timeline })
    moves_arr = []
    for i,card of TrelloCard.all()
      if card.timeline() != false
        moves_arr.push card.timeline()
    return moves_arr