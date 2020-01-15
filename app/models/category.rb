class Category
  include Mongoid::Document

  field :name, type: String
  field :description, type: String

  TYPES = %w(revenue expense)
  field :type, type: String
  validates_inclusion_of :type, in: TYPES

  def self.tebex_category
    found = Category.where(name: "Tebex").first
    return found unless found.nil?
    return Category.create(
      name: "Tebex",
      description: "All tebex transactions",
      type: 'revenue'
    )
  end
end
