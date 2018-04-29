module Poros
  class Info
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
end

