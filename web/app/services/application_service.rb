# frozen_string_literal: true

class ApplicationService
  class << self
    def call(*args, **kwargs, &block)
      new(*args, **kwargs, &block).call
    end
  end

  def initialize(*args, **kwargs, &block); end
end
