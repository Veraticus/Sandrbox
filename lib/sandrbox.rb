require 'irb'
require 'timeout'

require 'sandrbox/response'
require 'sandrbox/value'
require 'sandrbox/config'

module Sandrbox
  extend self
  
  def configure
    block_given? ? yield(Sandrbox::Config) : Sandrbox::Config
  end
  alias :config :configure
  
  def perform(array)
    Sandrbox::Response.new(array)
  end
  
end