class DealCash
  @bakeCurrentCash: (options={}) ->

    options = Metric.checkOptions(options)

    # USE ISO DATES
    startdate = options.startdate.toJSON()
    enddate = options.enddate.toJSON()

    deals = for i, move of TrelloCardMove.where({'date': {$gte: startdate, $lt: enddate}, 'data.listAfter.id': TrelloCard.list_ids[4]}).fetch()
      move.data.card.id
    deal_card_ids = _.uniq(deals)

    if options.user?
      deals_cash = for i, card of TrelloCard.where({idMembers: options.user.trello.id, id: {$in: deal_card_ids}}).fetch()
        card.bsc_cash
    else
      deals_cash = for i, card of TrelloCard.where({id: {$in: deal_card_ids}}).fetch()
        card.bsc_cash

    total_cash = 0
    for cash in deals_cash
      if cash != undefined
        total_cash = total_cash + cash

    return total_cash
