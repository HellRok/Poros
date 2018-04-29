require 'poros/info'

module Poros::InstanceMethods
  attr_accessor :uuid
  def uuid
    @uuid ||= SecureRandom.uuid
  end

  def poros
    @poros ||= Poros::Info.new(self)
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
end
