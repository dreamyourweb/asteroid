class DealCash extends Minimongoid
  @bakeCurrentCash: (options={}) ->

    if options.startdate == undefined || options.startdate == "" || _.isNaN(options.startdate)
      options.startdate = new Date
      options.startdate.setDate(options.startdate.getDate() - 90)
    if options.enddate == undefined || options.enddate == "" || _.isNaN(options.enddate)
      options.enddate = new Date
    if options.enddate > new Date then options.enddate = new Date
    if options.timespan? && options.timespan != "" && !_.isNaN(options.timespan)
      options.startdate = new Date
      options.enddate = new Date
      options.startdate.setDate(options.startdate.getDate() - options.timespan)
    if typeof options.users == "string"
      options.users = [options.users]

    # USE ISO DATES
    startdate = options.startdate.toISOString()
    enddate = options.enddate.toISOString()

    deals = for i, move of TrelloCardMove.where({'date': {$gte: startdate, $lt: enddate}, 'data.listAfter.id': TrelloCard.list_ids[4]})
      move.data.card.id
    deal_card_ids = _.uniq(deals)

    if options.users?
      deals_cash = for i, card of TrelloCard.where({idMembers: {$in: options.users}, _id: {$in: deal_card_ids}})
        card.getCash()
    else
      deals_cash = for i, card of TrelloCard.where({_id: {$in: deal_card_ids}})
        card.getCash()

    total_cash = 0
    for cash in deals_cash
      if cash != undefined
        total_cash = total_cash + cash

    return total_cash
