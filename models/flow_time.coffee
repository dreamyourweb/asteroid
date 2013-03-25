class FlowTime
  @bakeTimes: (options={}) ->

    options = Metric.checkOptions(options)

    # USE ISO DATES
    startdate = options.startdate.toJSON()
    enddate = options.enddate.toJSON()

    card_form_34_to_5 = for i, move of TrelloCardMove.where( {'data.listBefore.id': {$in: [TrelloCard.list_ids[2],TrelloCard.list_ids[3]]}, 'data.listAfter.id': TrelloCard.list_ids[4]}).fetch()
      move.data.card.id

    card_form_34_to_5 = _.uniq(card_form_34_to_5)

    if options.user?
      card_form_34_to_5 = for i, card of TrelloCard.where({id: {$in: card_form_34_to_5}, idMembers: options.user.trello.id}).fetch()
        card.attributes.id

    last_34 = for i, card of TrelloCard.where({_id: {$in: card_form_34_to_5}}, {sort: {id: 1}}).fetch()
      move = TrelloCardMove.where({'date': {$gte: startdate, $lt: enddate}, 'data.card.id': card.id, 'data.listAfter.id': {$in: [TrelloCard.list_ids[2],TrelloCard.list_ids[3]]}}, {sort: {date: 1}, limit: 1}).fetch()[0]
      if move == undefined
        move = TrelloCardMove.where({'date': {$gte: startdate, $lt: enddate}, 'data.card.id': card.id, 'type': 'createCard', 'data.list.id': {$in: [TrelloCard.list_ids[2],TrelloCard.list_ids[3]]}}, {sort: {date: 1}, limit: 1}).fetch()[0]
      move

    last_5 = for i, card of TrelloCard.where({_id: {$in: card_form_34_to_5}}, {sort: {id: 1}}).fetch()
      move = TrelloCardMove.where({'date': {$gte: startdate, $lt: enddate}, 'data.card.id': card.id, 'data.listAfter.id': TrelloCard.list_ids[4]}, {sort: {date: 1}, limit: 1}).fetch()[0]

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