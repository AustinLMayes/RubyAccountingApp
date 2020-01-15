class Transaction
  include Mongoid::Document
  include Mongoid::Timestamps::Created

  belongs_to :category
  # UI stuff
  field :name, type: String
  field :description, type: String

  # Price in US cents
  field :price, type: Integer

  # ID of the recurring transaction that created this
  field :parent_id, type: BSON::ObjectId

  field :tebex_id, type: Integer

  after_save do
    $redis.del("current-bal")
  end

  def is_expense
    category.type == "expense"
  end

  def is_revenue
    !is_expense
  end
end
