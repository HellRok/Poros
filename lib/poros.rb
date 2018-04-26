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
    self.class.remove_from_index(self)
    self
  end

  def save
    File.write(poros.file_path, poros.to_h.to_yaml)
    self.class.data_changed = true
    self.class.update_index(self)
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
      @object.class.poro_attrs.map { |column|
        [column, @object.send(column.to_s)]
      }.to_h
    end
  end

  module ClassMethods
    attr_accessor :in_transaction, :data_changed

    def poro_attr(*attrs)
      @poro_attrs = [:uuid] | attrs
      attrs.each { |column|
        class_eval "attr_accessor :#{column}"
      }
    end

    def poro_attrs
      @poro_attrs ||= []
    end

    def poro_index(*attrs)
      @poro_indexes ||= []
      @poro_indexes += attrs
    end

    def poro_indexes
      @poro_indexes ||= []
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

    def index_file
      File.join(data_directory, "indexes.yml")
    end

    def all
      Dir.glob(File.join(data_directory, '*.yml')).map { |file|
        next if file == index_file
        data = YAML.load(File.read(file))
        find(data[:uuid])
      }.compact
    end

    def where(query)
      indexed, table_scan = query.partition { |index, key| poro_indexes.include?(index) }

      indexed_results = indexed.map { |key, value|
        case value
        when Regexp
          index_data[key].keys.flat_map { |value_name|
            index_data[key][value_name] if value =~ value_name
          }.compact
        when Array
          value.flat_map { |value_name| index_data[key][value_name] }
        when Proc
          index_data[key].keys.flat_map { |value_name|
            index_data[key][value_name] if value.call(value_name)
          }.compact
        else
          index_data[key].has_key?(value) ?
            index_data[key][value] : []
        end
      }.inject(:&)

      if table_scan.size > 0
        scanned_results = Dir.glob(File.join(data_directory, '*.yml')).map { |file|
          next if file == index_file
          data = YAML.load(File.read(file))
          data[:uuid] if table_scan.all? { |key, value|
            case value
            when Regexp
              value =~ data[key]
            when Array
              value.include?(data[key])
            when Proc
              value.call(data[key])
            else
              data[key] == value
            end
          }
        }.compact
      end

      if indexed.size > 0 && table_scan.size > 0
        results = indexed_results & scanned_results
      elsif indexed.size > 0
        results = indexed_results
      else
        results = scanned_results
      end

      results.map { |uuid| find(uuid) }
    end

    def index_data
      return @index_data if @index_data

      data = File.exist?(index_file) ? YAML.load(File.read(index_file)) : {}
      # Make sure we always have every index as a key
      poro_indexes.each do |index|
        data[index] = {} unless data.has_key?(index)
      end

      @index_data = data
    end

    def write_index_data
      File.write(index_file, @index_data.to_yaml)
    end

    def update_index(object)
      remove_from_index(object, false)

      index_data

      poro_indexes.each do |index|
        @index_data[index] = {} unless @index_data.has_key?(index)
        value = object.send(index)
        @index_data[index][value] ||= []
        @index_data[index][value] = @index_data[index][value] | [object.uuid]
      end

      write_index_data unless @in_transaction
    end

    def remove_from_index(object, perist = true)
      index_data

      poro_indexes.each do |index|
        @index_data[index] = {} unless @index_data.has_key?(index)
        @index_data[index].keys.each do |value|
          @index_data[index][value] ||= []
          @index_data[index][value] -= [object.uuid]
        end
      end
      write_index_data if !@in_transaction && perist
    end

    def rebuild_indexes
      transaction do
        @data_changed = true
        @index_data = {}
        File.delete(index_file) if File.exist?(index_file)
        all.each { |object| update_index(object) }
      end
    end

    def transaction(&block)
      @in_transaction = true
      @data_changed = false
      block.call
      @in_transaction = false
      write_index_data if @data_changed
    end
  end
end
