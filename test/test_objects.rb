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
  has_many :boops, class_name: 'DefaultObject', foreign_key: :name, primary_key: :name

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

  belongs_to :author
  belongs_to :boop, class_name: 'DefaultObject', foreign_key: :title, primary_key: :name

  def initialize(title: '', author: nil, author_uuid: nil)
    @title = title
    @author_uuid = author_uuid if author_uuid
    self.author = author if author
  end

  def self.data_directory
    "./tmp/#{self}/"
  end
end
