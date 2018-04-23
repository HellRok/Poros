class DefaultObject
  include Poros

  poro_attrs :name, :order

  def initialize(name: '', order: 0)
    @name = name
    @order = order
  end
end
