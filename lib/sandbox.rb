require 'irb'
require 'timeout'

require 'sandbox/response'
require 'sandbox/value'
require 'sandbox/config'

module Sandbox
  extend self
  
  def configure
    block_given? ? yield(Sandbox::Config) : Sandbox::Config
  end
  alias :config :configure
  
  def perform(array)
    Sandbox::Response.new(array)
  end
  
end