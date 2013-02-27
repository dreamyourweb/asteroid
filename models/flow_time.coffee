class FlowTime extends Minimongoid
  @bakeTimes: (startdate, enddate) ->

    if startdate == undefined
      startdate = new Date
      startdate.setDate(startdate.getDate() - 90)
    if enddate == undefined then enddate = new Date
    if enddate > new Date then enddate = new Date
    console.log startdate
    console.log enddate

    # USE ISO DATES
    startdate = startdate.toISOString()
    enddate = enddate.toISOString()

    card_form_34_to_5 = for i, move of TrelloCardMove.where( {'data.listBefore.id': {$in: [TrelloCard.list_ids[2],TrelloCard.list_ids[3]]}, 'data.listAfter.id': TrelloCard.list_ids[4]})
      move.data.card.id

    card_form_34_to_5 = $.unique(card_form_34_to_5)
    console.log card_form_34_to_5.length

    last_34 = for i, card of TrelloCard.where({_id: {$in: card_form_34_to_5}}, {sort: {id: 1}})
      move = TrelloCardMove.where({'date': {$gte: startdate, $lt: enddate}, 'data.card.id': card.id, 'data.listAfter.id': {$in: [TrelloCard.list_ids[2],TrelloCard.list_ids[3]]}}, {sort: {date: 1}, limit: 1})[0]
      if move == undefined
        move = TrelloCardMove.where({'date': {$gte: startdate, $lt: enddate}, 'data.card.id': card.id, 'type': 'createCard', 'data.list.id': {$in: [TrelloCard.list_ids[2],TrelloCard.list_ids[3]]}}, {sort: {date: 1}, limit: 1})[0]
      move

    last_5 = for i, card of TrelloCard.where({_id: {$in: card_form_34_to_5}}, {sort: {id: 1}})
      move = TrelloCardMove.where({'date': {$gte: startdate, $lt: enddate}, 'data.card.id': card.id, 'data.listAfter.id': TrelloCard.list_ids[4]}, {sort: {date: 1}, limit: 1})[0]

    dTs = []
    dT = 0
    N = 0
    for i in [0..last_34.length-1]
      if last_5[i] != undefined && last_34 != undefined
        dt = new Date(last_5[i].date) - new Date(last_34[i].date)
        if dt >= 0
          dT = dT + dt
          dTs.push dt
          N = N + 1

    console.log(dTs)
    console.log(dT/N/1000)

    dT/N/1000