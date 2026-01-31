require "test_helper"

describe Poros do
  describe '#save' do
    before do
      @object = DefaultObject.new(name: 'test', order: 100).save
    end

    after do
      @object.destroy
    end

    it 'saves to a file' do
      assert_equal File.exist?(@object.poros.file_path), true
    end
  end

  describe '#find' do
    before do
      @object = DefaultObject.new(name: 'other', order: 1).save
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

    describe "with a non-permitted class" do
      it "raises an error" do
        author = Author.new.save
        assert_raises(Psych::DisallowedClass) {
          Author.find(author.uuid)
        }
      end
    end

    describe "with a permitted class" do
      before do
        Poros::Config.configure do |config|
          config[:permitted_classes] = [Symbol, Date]
        end
      end

      after do
        Poros::Config.configure do |config|
          config[:permitted_classes] = [Symbol]
        end
      end

      it "loads successfully" do
        author = Author.new.save

        assert_equal Date, Author.find(author.uuid).birthday.class
      end
    end
  end

  describe '#where' do
    before do
      @object_1 = DefaultObject.new(name: 'first', order: 1, active: true).save
      @object_2 = DefaultObject.new(name: 'second', order: 2, active: true).save
      @object_3 = DefaultObject.new(name: 'third', order: 1, active: false).save
      @object_4 = DefaultObject.new(name: 'teeeeeest', order: 3, active: true).save
      @object_5 = DefaultObject.new(name: 'test', order: 3, active: false).save
    end

    after do
      DefaultObject.all.map(&:destroy)
    end

    describe 'without indexes' do
      before do
        DefaultObject.instance_variable_set(:@poro_indexes, nil)
      end

      it 'finds on exact matches' do
        assert_equal DefaultObject.where(order: 1).map(&:uuid).sort,
          [@object_1, @object_3].map(&:uuid).sort
      end

      it 'finds on exact matches of multiple options' do
        assert_equal DefaultObject.where(order: 1, name: 'third').map(&:uuid),
          [@object_3.uuid]
      end

      it 'handles boolean values' do
        assert_equal DefaultObject.where(order: 1, active: true).map(&:uuid),
          [@object_1.uuid]
        assert_equal DefaultObject.where(order: 1).where(active: false).map(&:uuid),
          [@object_3.uuid]
      end

      it 'finds based on regexes' do
        assert_equal DefaultObject.where(name: /t.+st/, order: 3).map(&:uuid).sort,
          [@object_4, @object_5].map(&:uuid).sort
      end

      it 'finds in array' do
        assert_equal DefaultObject.where(order: [1, 2]).map(&:uuid).sort,
          [@object_1, @object_2, @object_3].map(&:uuid).sort
      end

      it 'finds by proc' do
        assert_equal DefaultObject.where(
          order: -> value { value + 5 == 6 },
          name: -> value { value == 'third' }
        ).map(&:uuid), [@object_3].map(&:uuid)
      end
    end

    describe 'with indexes' do
      before do
        DefaultObject.instance_variable_set(:@poro_indexes, [:name, :order])
        DefaultObject.rebuild_indexes
      end

      after do
        DefaultObject.instance_variable_set(:@poro_indexes, nil)
        DefaultObject.rebuild_indexes
      end

      it 'finds on exact matches' do
        assert_equal DefaultObject.where(order: 1).map(&:uuid).sort,
          [@object_1, @object_3].map(&:uuid).sort
      end

      it 'finds on exact matches of multiple options' do
        assert_equal DefaultObject.where(order: 1, name: 'third').map(&:uuid),
          [@object_3.uuid]
      end

      it 'handles boolean values' do
        assert_equal DefaultObject.where(order: 1).where(active: true).map(&:uuid),
          [@object_1.uuid]
        assert_equal DefaultObject.where(order: 1, active: false).map(&:uuid),
          [@object_3.uuid]
      end

      it 'finds based on regexes' do
        assert_equal DefaultObject.where(name: /t.+st/, order: 3).map(&:uuid).sort,
          [@object_4, @object_5].map(&:uuid).sort
      end

      it 'finds in array' do
        assert_equal DefaultObject.where(order: [1, 2]).map(&:uuid).sort,
          [@object_1, @object_2, @object_3].map(&:uuid).sort
      end

      it 'finds by proc' do
        assert_equal DefaultObject.where(
          order: -> value { value + 5 == 6 },
          name: -> value { value == 'third' }
        ).map(&:uuid), [@object_3].map(&:uuid)
      end
    end
  end

  describe '#destroy' do
    before do
      DefaultObject.instance_variable_set(:@poro_indexes, [:name])
    end

    after do
      DefaultObject.instance_variable_set(:@poro_indexes, nil)
    end

    it 'properly clears the index file' do
      object = DefaultObject.new(name: 'test').save
      DefaultObject.transaction { object.destroy }
      assert_equal File.read(DefaultObject.index_file), "---\n:name: {}\n"
    end
  end
end
