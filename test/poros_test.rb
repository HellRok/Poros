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

  describe '#where' do
    before do
      @object_1 = DefaultObject.new(name: 'first', order: 1).save
      @object_2 = DefaultObject.new(name: 'second', order: 2).save
      @object_3 = DefaultObject.new(name: 'third', order: 1).save
    end

    after do
      @object_1.destroy
      @object_2.destroy
      @object_3.destroy
    end

    it 'finds on exact matches' do
      assert_equal DefaultObject.where(order: 1).map(&:uuid).sort,
        [@object_1, @object_3].map(&:uuid).sort
    end

    it 'finds on exact matches of multiple options' do
      assert_equal DefaultObject.where(order: 1, name: 'third').map(&:uuid),
        [@object_3.uuid]
    end
  end
end
