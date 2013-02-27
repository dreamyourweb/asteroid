class FlowTime extends Minimongoid
  @bakeTimes: (options={}) ->

    if options.startdate == undefined
      options.startdate = new Date
      options.startdate.setDate(options.startdate.getDate() - 90)
    if options.enddate == undefined then options.enddate = new Date
    if options.enddate > new Date then options.enddate = new Date
    if options.timespan?
      options.startdate = new Date
      options.enddate = new Date
      options.startdate.setDate(options.startdate.getDate() - options.timespan)
    if typeof options.users == "string"
      options.users = [options.users]

    # USE ISO DATES
    startdate = options.startdate.toISOString()
    enddate = options.enddate.toISOString()

    console.log startdate
    console.log enddate

    card_form_34_to_5 = for i, move of TrelloCardMove.where( {'data.listBefore.id': {$in: [TrelloCard.list_ids[2],TrelloCard.list_ids[3]]}, 'data.listAfter.id': TrelloCard.list_ids[4]})
      move.data.card.id

    card_form_34_to_5 = _.uniq(card_form_34_to_5)

    if options.users?
      card_form_34_to_5 = for i, card of TrelloCard.where({id: {$in: card_form_34_to_5}, idMembers: {$in: options.users}})
        card.id

    last_34 = for i, card of TrelloCard.where({_id: {$in: card_form_34_to_5}}, {sort: {id: 1}})
      move = TrelloCardMove.where({'date': {$gte: startdate, $lt: enddate}, 'data.card.id': card.id, 'data.listAfter.id': {$in: [TrelloCard.list_ids[2],TrelloCard.list_ids[3]]}}, {sort: {date: 1}, limit: 1})[0]
      if move == undefined
        move = TrelloCardMove.where({'date': {$gte: startdate, $lt: enddate}, 'data.card.id': card.id, 'type': 'createCard', 'data.list.id': {$in: [TrelloCard.list_ids[2],TrelloCard.list_ids[3]]}}, {sort: {date: 1}, limit: 1})[0]
      move

    last_5 = for i, card of TrelloCard.where({_id: {$in: card_form_34_to_5}}, {sort: {id: 1}})
      move = TrelloCardMove.where({'date': {$gte: startdate, $lt: enddate}, 'data.card.id': card.id, 'data.listAfter.id': TrelloCard.list_ids[4]}, {sort: {date: 1}, limit: 1})[0]

    console.log last_34
    console.log last_5
    dTs = []
    dT = 0
    N = 0
    for i in [0..last_34.length-1]
      if last_5[i]? && last_34[i]?
        dt = new Date(last_5[i].date) - new Date(last_34[i].date)
        if dt >= 0
          dT = dT + dt
          dTs.push dt
          N = N + 1

    dT/N/1000