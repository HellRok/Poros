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
