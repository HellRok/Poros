require 'yaml'
require 'securerandom'

require 'poros/query'
require 'poros/instance_methods'
require 'poros/class_methods'

module Poros
  include Poros::InstanceMethods
  include Poros::ClassMethods

  def self.included(base)
    base.class_eval do
      extend ClassMethods
    end
  end
end
