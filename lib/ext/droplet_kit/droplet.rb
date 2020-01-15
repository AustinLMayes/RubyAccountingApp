require "droplet_kit"

module DropletKit
  class Droplet
    def per_hour(size_hash)
      price = size_hash[size_slug]
      raise "Unknown size " + size_slug if price.nil?
      return price * 100
    end

    def category
      tags.each do |t|
        if t.start_with? "finance-"
          cat_slug = "DO - " + t.gsub("finance-", "").capitalize
          existing = Category.where(name: cat_slug).first
          return existing unless existing.nil?
          new = Category.create(name: cat_slug, type: 'expense', description: "DigitalOcean droplets tagged with #{t}. Created automatically.")
          return new
        end
      end
      raise "Droplet does not fall into a financial category"
    end
  end
end
