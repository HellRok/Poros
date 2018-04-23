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
    self
  end

  def save
    File.write(poros.file_path, poros.to_h.to_yaml)
    self
  end

  class PorosInfo
    def initialize(object)
      @object = object
    end

    def file_path
      @object.class.file_path(@object.uuid)
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

    def find(uuid)
      attrs = YAML.load(File.read(file_path(uuid)))
      attrs.delete(:uuid)

      object = new(attrs)
      object.uuid = uuid
      object
    end

    def file_path(uuid)
      FileUtils.mkdir_p(data_directory) unless File.exist?(data_directory)
      File.join(data_directory, file_name(uuid))
    end

    def data_directory
      "./db/#{self}/"
    end

    def file_name(uuid)
      "#{uuid}.yml"
    end

    def where(query)
      Dir.glob(File.join(data_directory, '*.yml')).map { |file|
        data = YAML.load(File.read(file))
        find(data[:uuid]) if query.all? { |key, value| data[key] == value }
      }.compact
    end
  end
end
