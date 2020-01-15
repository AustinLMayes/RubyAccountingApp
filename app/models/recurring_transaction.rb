class RecurringTransaction
  include Mongoid::Document

  belongs_to :category
  # UI stuff
  field :name, type: String
  field :description, type: String

  # Interval stuff
  field :interval, type: Integer

  INTERVAL_TYPES = %w(hours days months years)
  field :interval_type, type: String
  validates_inclusion_of :interval_type, in: INTERVAL_TYPES

  # Dates when the transaction period starts and ends
  field :start, type: DateTime
  field :end, type: DateTime

  # Price in US cents
  field :price, type: Integer

  def describe_interval
    return "every #{interval} #{interval_type}"
  end

  def describe_dates
    return start.strftime("%b %d, %Y") + " - " + (self.end.year == 100000 ? "Forever" : self.end.strftime("%b %d, %Y"))
  end

  def interval_to_ruby(int: interval)
    case interval_type
    when "hours"
      return int.hours
    when "days"
      return int.days
    when "months"
      return int.months
    when "years"
      return int.years
    end
  end

  def back_fill
    first = Transaction.where(parent_id: id).order_by(created_at: :asc).first
    target = (first.nil? ? DateTime.now : first.created_at.to_datetime).utc
    current = start.to_datetime.utc
    record(now: current)
    loop do
      current = current + interval_to_ruby
      break if current > target
      record(now: current)
    end
  end

  def record(now: DateTime.now.utc)
    last = Transaction.where(parent_id: id).order_by(created_at: :desc).first
    latest = last.nil? ? start - interval_to_ruby(int: 1) : last.created_at.to_datetime
    if now >= (latest + interval_to_ruby)
      Transaction.create(
        category: category,
        name: name + " - Recurring",
        description: description,
        price: price,
        parent_id: id,
        created_at: now
      )
    end
  end
end
