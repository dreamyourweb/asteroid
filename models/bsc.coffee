class BSC extends Minimongoid
  @bakeCurrentBSC: (options={}) ->

    if !options.timespan?
      options.timespan = 90
    if !options.user?
      delete options['user']

    cutoffDate = new Date
    cutoffDate.setDate(cutoffDate.getDate() + options.timespan)

    if options.user?
      deals_predicted_cash = for i, card of TrelloCard.where({idMembers: options.user.trello.id, 'idList': {$in: [TrelloCard.list_ids[2], TrelloCard.list_ids[3]]}, bsc_date: {$lt: cutoffDate.toJSON()}})
        card.bsc_cash * card.bsc_prob if (card.bsc_cash != undefined && card.bsc_prob != undefined)
    else
      deals_predicted_cash = for i, card of TrelloCard.where({ 'idList': {$in: [TrelloCard.list_ids[2], TrelloCard.list_ids[3]]}, bsc_date: {$lt: cutoffDate.toJSON()}})
        card.bsc_cash * card.bsc_prob if (card.bsc_cash != undefined && card.bsc_prob != undefined)

    total_predicted_cash = 0
    for cash in deals_predicted_cash
      if cash != undefined
        total_predicted_cash = total_predicted_cash + cash

    return total_predicted_cash