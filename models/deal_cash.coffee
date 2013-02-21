class DealCash extends Minimongoid
  @bakeCurrentCash: (dateRange, users) ->

    deals = for i, move of TrelloCardMove.where({ 'data.listAfter.id': TrelloCard.list_ids[4]})
      move.data.card.id
    deal_card_ids = $.unique(deals)

    deals_cash = for i, card of TrelloCard.where({_id: {$in: deal_card_ids}})
      card.getCash()

    total_cash = 0
    for cash in deals_cash
      if cash != undefined
        total_cash = total_cash + cash

    return total_cash
