class FlowTime extends Minimongoid
  @bakeTimes: ->
    card_form_34_to_5 = for i, move of TrelloCardMove.where({'data.listBefore.id': {$in: [TrelloCard.list_ids[2],TrelloCard.list_ids[3]]}, 'data.listAfter.id': TrelloCard.list_ids[4]}, {sort: {date: -1}})
      move.data.card.id

    card_form_34_to_5 = $.unique(card_form_34_to_5)

    last_34 = for i, card of TrelloCard.where({_id: {$in: card_form_34_to_5}}, {sort: {id: -1}})
      move = TrelloCardMove.where({'data.card.id': card.id, 'data.listAfter.id': {$in: [TrelloCard.list_ids[2],TrelloCard.list_ids[3]]}}, {sort: {date: -1}, limit: 1})[0]
      if move == undefined
        move = TrelloCardMove.where({'type': 'createCard', 'data.list.id': {$in: [TrelloCard.list_ids[2],TrelloCard.list_ids[3]]}}, {sort: {date: -1}, limit: 1})[0]
      move

    last_5 = for i, card of TrelloCard.where({_id: {$in: card_form_34_to_5}}, {sort: {id:1}})
      move = TrelloCardMove.where({'data.card.id': card.id, 'data.listAfter.id': TrelloCard.list_ids[4]}, {sort: {date: -1}, limit: 1})[0]

    dTs = []
    dT = 0
    N = 0
    for i in [0..card_form_34_to_5.length-1]
      dt = new Date(last_5[i].date) - new Date(last_34[i].date)
      if dt >= 0
        dT = dT + dt
        dTs.push dt
        N = N + 1

    console.log(dTs)
    console.log(dT/N/1000)

    dT/N/1000