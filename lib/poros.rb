require 'yaml'
require 'securerandom'

require 'poros/config'

require 'poros/query'
require 'poros/instance_methods'
require 'poros/class_methods'
require 'poros/relations'

module Poros
  include Poros::Config

  include Poros::InstanceMethods
  include Poros::ClassMethods
  include Poros::Relations

  def self.included(base)
    base.class_eval do
      extend ClassMethods
      extend Relations
    end
  end
end
