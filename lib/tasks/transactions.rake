namespace :transactions do
  desc "Add in any transactions that should be recurring"
  task record_recurring: :environment do
    RecurringTransaction
      .where({:start => {'$lte' => DateTime.now.utc}})
      .and({:end => {'$gte' => DateTime.now.utc}})
      .all.each do |t|
        t.record
    end
  end

  desc "Pull in tebex transactions"
  task pull_tebex: :environment do
    require 'net/http'

    uri = URI('https://plugin.buycraft.net/payments/')
    Net::HTTP.start(uri.host, uri.port, :use_ssl => uri.scheme == 'https') do |http|
      req = Net::HTTP::Get.new(uri)
      req['X-Buycraft-Secret'] = $stratus['tebex-secret']

      response = http.request req # Net::HTTPResponse object
      payments = JSON.parse(response.body)
      payments.each do |p|
        date = DateTime.parse(p['date'])
        id = p['id'].to_i
        amount = (p['amount'].to_f * 100).to_i
        player = p['player']['name']
        break if Transaction.where(tebex_id: id).last.present?
        Transaction.create(
          category: Category.tebex_category,
          name: "Tebex - " + player,
          description: "Tebex payment from " + player + " (#{p['player']['uuid']})",
          price: amount,
          created_at: date,
          tebex_id: id
        )
      end
    end
  end

  desc "Bill digital ocean droplets"
  task bill_droplets: :environment do
    prices = {}
    $DO_CLIENT.sizes.all.each do |s|
      prices["#{s.slug}"] = s.price_monthly
    end
    $DO_CLIENT.droplets.all.each do |d|
      Transaction.create(
        category: d.category,
        name: d.name + " - Hourly",
        description: "Hourly droplet cost",
        price: d.per_hour(prices)
      )
    end
  end
end
