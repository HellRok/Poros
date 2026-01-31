module Poros
  class Query
    include Enumerable
    attr_accessor :object, :queries

    def initialize(object)
      @object = object
      @queries = {}
    end

    def where(query)
      @queries.merge!(query)
      self
    end

    def each(&block)
      results.each { |result| block.call(result) }
    end

    def results
      indexed, table_scan = @queries.partition { |index, key| @object.poro_indexes.include?(index) }

      indexed_results = indexed.map { |key, value|
        case value
        when Regexp
          @object.index_data[key].keys.flat_map { |value_name|
            @object.index_data[key][value_name] if value =~ value_name
          }.compact
        when Array
          value.flat_map { |value_name| @object.index_data[key][value_name] }
        when Proc
          @object.index_data[key].keys.flat_map { |value_name|
            @object.index_data[key][value_name] if value.call(value_name)
          }.compact
        else
          @object.index_data[key].has_key?(value) ?
            @object.index_data[key][value] : []
        end
      }.inject(:&)

      if table_scan.size > 0
        scanned_results = Dir.glob(File.join(@object.data_directory, '*.yml')).map { |file|
          next if file == @object.index_file
          data = YAML.safe_load(
            File.read(file),
            permitted_classes: Poros::Config.configuration[:permitted_classes],
          )
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

      results.map { |uuid| @object.find(uuid) }
    end
  end
end
