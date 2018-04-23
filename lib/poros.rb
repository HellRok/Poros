require 'yaml'
require 'securerandom'

module Poros
  attr_accessor :uuid
  def self.included(base)
    base.class_eval do
      extend ClassMethods
    end
  end

  def uuid
    @uuid ||= SecureRandom.uuid
  end

  def poros
    @poros ||= PorosInfo.new(self)
  end

  def destroy
    File.delete(poros.file_path)
  end

  def save
    File.write(poros.file_path, poros.to_h.to_yaml)
  end

  class PorosInfo
    def initialize(object)
      @object = object
    end

    def file_path
      File.join("./tmp", file_name)
    end

    def file_name
      "#{@object.class}-#{@object.uuid}.yml"
    end

    def to_h
      @object.class.poro_columns.map { |column|
        [column, @object.send(column.to_s)]
      }.to_h
    end
  end

  module ClassMethods
    def poro_attrs(*attrs)
      @poro_columns = [:uuid] | attrs
      attrs.each { |column|
        class_eval "attr_accessor :#{column}"
      }
    end

    def poro_columns
      @poro_columns
    end
  end
end
