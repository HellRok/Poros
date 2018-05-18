class DefaultObject
  include Poros

  poro_attr :name, :order, :active

  def initialize(name: '', order: 0, active: false)
    @name = name
    @order = order
    @active = active
  end

  def self.data_directory
    "./tmp/#{self}/"
  end
end

class Author
  include Poros

  poro_attr :name

  has_many :books

  def initialize(name: '')
    @name = name
  end

  def self.data_directory
    "./tmp/#{self}/"
  end
end

class Book
  include Poros

  poro_attr :title, :author_uuid

  def initialize(title: '', author_uuid: nil)
    @title = title
    @author_uuid = author_uuid
  end

  def self.data_directory
    "./tmp/#{self}/"
  end
end
