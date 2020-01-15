class RecurringTransactionsController < ApplicationController

  def index
    now = DateTime.now.utc
    @active = RecurringTransaction
      .where({:start => {'$lte' => now}})
      .and({:end => {'$gte' => now}})
      .all
    @inactive = RecurringTransaction
      .where({:start => {'$gte' => now}})
      .or({:end => {'$lte' => now}})
      .all
    @new = RecurringTransaction.new
  end

  def create
    parse_data(RecurringTransaction.new)
    redirect_to main_app.recurring_transactions_path
  end

  def update
    t = RecurringTransaction.find(id: params['id'])
    parse_data(t)
    redirect_to main_app.recurring_transactions_path
  end

  def destroy
    RecurringTransaction.find(id: params['id']).destroy
    redirect_to main_app.recurring_transactions_path
  end

  private

  def parse_data(t)
    trans = params[:recurring_transaction]
    t.name = trans[:name]
    t.description = trans[:description]
    t.interval = trans[:interval]
    t.interval_type = trans[:interval_type]
    t.start = parse_start(trans[:start])
    t.end = parse_stop(trans[:end])
    t.end = Time.utc(100000) if t.end.nil?
    t.price = trans[:price]
    t.category = Category.where(name: trans[:category]).first
    unless t.save
      raise "#{t.errors.full_messages}"
    end
  end

  def parse_start(text)
    if text.blank?
      Time.now.utc
    else
      Chronic.parse(text).utc
    end
  end

  def parse_stop(text)
    if text.blank?
      Time.utc(100000)
    else
      res = Chronic.parse(text)
      if res.nil?
        return Time.utc(100000)
      else
        return res.utc
      end
    end
  end
end
