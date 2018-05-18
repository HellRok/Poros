require "test_helper"

describe Poros::Relations do
  before do
    @author_1 = Author.new(name: 'Audrey Niffenegger').save
    @author_2 = Author.new(name: 'John Steinbeck').save
    @book_1 = Book.new(title: 'The Grapes of Wrath', author: @author_2).save
    @book_2 = Book.new(title: 'The Time Traveler\'s Wife', author: @author_1).save
    @book_3 = Book.new(title: 'Of Mice and Men', author: @author_2).save
  end

  after do
    @author_1.destroy
    @author_2.destroy
    @book_1.destroy
    @book_2.destroy
    @book_3.destroy
  end

  describe '#has_many' do
    it 'returns it\'s children' do
      assert_equal @author_1.books.map(&:uuid), [@book_2].map(&:uuid)
      assert_equal @author_2.books.map(&:uuid).sort, [@book_1, @book_3].map(&:uuid).sort
    end
  end

  describe '#belongs_to' do
    it 'returns it\'s author' do
      assert_equal @book_1.author, @author_2
      assert_equal @book_2.author, @author_1
      assert_equal @book_3.author, @author_2
    end
  end
end
