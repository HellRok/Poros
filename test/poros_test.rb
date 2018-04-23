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

  describe '#find' do
    before do
      @object = DefaultObject.new(name: 'other', order: 1)
      @object.save
      @uuid = @object.uuid
    end

    after do
      @object.destroy
    end

    it 'finds a saved file' do
      found_object = DefaultObject.find(@uuid)
      assert_equal found_object.uuid, @object.uuid
      assert_equal found_object.name, @object.name
      assert_equal found_object.order, @object.order
    end
  end
end
