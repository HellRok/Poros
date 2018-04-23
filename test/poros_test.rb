require "test_helper"

describe Poros do
  describe '#save' do
    before do
      @object = DefaultObject.new(name: 'test', order: 100)
      @object.save
    end

    after do
      @object.destroy
    end

    it 'saves to a file' do
      assert_equal File.exists?(@object.poros.file_path), true
    end
  end
end
