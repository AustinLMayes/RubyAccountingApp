class ApplicationController < ActionController::Base

  before_action :set_balance

  def index
    @end = (DateTime.now + 1.day).utc.to_date
    @start = [$CUR_BAL[:date], @end - 1.month].max
    @transactions = Transaction
      .where({:created_at => {'$lte' => @end}})
      .and({:created_at => {'$gte' => @start}})
      .order_by(created_at: :asc)
    @profit = 0
    @transactions.each do |t|
      if t.is_expense
        @profit = @profit - t.price
      else
        @profit = @profit + t.price
      end
    end
    @made_profit = @profit >= 0
    @revenue = {}
    @expenses = {}
    @rev_tot = 0
    @exp_tot = 0
    Category.all.each do |cat|
      total = @transactions.where(category: cat).sum(:price)
      if cat.type == "revenue"
        @revenue[cat.name] = total
        @rev_tot = @rev_tot + total
      else
        @expenses[cat.name] = total
        @exp_tot = @exp_tot + total
      end
    end
    @revenue["Total"] = @rev_tot
    @expenses["Total"] = @exp_tot
  end

  private

  def set_balance
    unless $redis.exists("current-bal")
      base = $CUR_BAL[:bal]
      Transaction.where({:created_at => {'$gte' => $CUR_BAL[:date]}}).each do |t|
        if t.category.type == "revenue"
          base = base + t.price
        else
          base = base - t.price
        end
      end
      $redis.set("current-bal", base)
    end
    @bal = $redis.get("current-bal").to_i
  end

  def transaction_log

  end
end
