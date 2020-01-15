# Helper that clears a model cache when it is updated.
module CachableModel
  extend ActiveSupport::Concern
  include Cachable

  included do
    after_save :flush
  end
end
