require 'helper'


class Test006FileStorage < TestBase
  before do
    @storage_path = "/tmp/test_classifier.db"
    @storage = StuffClassifier::FileStorage.new(@storage_path)
    StuffClassifier::Base.storage = @storage

    StuffClassifier::Bayes.open("Cats or Dogs") do |cls|    
      cls.train(:dog, "Dogs are awesome, cats too. I love my dog.")
      cls.train(:dog, "My dog's name is Willy. He likes to play with my wife's cat all day long. I love dogs")
      cls.train(:dog, "So which one should you choose? A dog, definitely.")
      cls.train(:dog, "A dog will eat anything, including birds or whatever meat")
      cls.train(:dog, "My dog's favorite place to take a leak is the tree in front of our house")

      cls.train(:cat, "My cat's favorite place to purr is on my keyboard")
      cls.train(:cat, "The favorite food for cats is bird meat, although mice are good, but birds are a delicacy")
      cls.train(:cat, "Cats are difficult animals, unlike dogs, really annoying, I hate them all")
      cls.train(:cat, "Cats are more preferred by software developers. I never could stand cats. I have a dog")    
    end

    # redefining storage instance, forcing it to read from file again
    StuffClassifier::Base.storage = StuffClassifier::FileStorage.new(@storage_path)
  end

  def teardown
    File.unlink @storage_path if File.exists? @storage_path
  end

  def test_result    
    set_classifier StuffClassifier::Bayes.new("Cats or Dogs")
    
    should_be :cat, "This test is about cats."
    should_be :cat, "I hate ..."
    should_be :cat, "The most annoying animal on earth."
    should_be :cat, "The preferred company of software developers."
    should_be :cat, "My precious, my favorite!"
    should_be :cat, "Kill that bird!"

    should_be :dog, "This test is about dogs."
    should_be :dog, "Cats or Dogs?" 
    should_be :dog, "What pet will I love more?"    
    should_be :dog, "Willy, where the heck are you?"
    should_be :dog, "I like big buts and I cannot lie." 
    should_be :dog, "Why is the front door of our house open?"
    should_be :dog, "Who ate my meat?"
    
  end

  def test_for_persistance    
    assert ! @storage.equal?(StuffClassifier::Base.storage),"Storage instance should not be the same"

    test = self
    StuffClassifier::Bayes.new("Cats or Dogs").instance_eval do
      test.assert @storage.instance_of?(StuffClassifier::FileStorage),"@storage should be an instance of FileStorage"
      test.assert @word_list.length > 0, "Word count should be persisted"
      test.assert @category_list.length > 0, "Category count should be persisted"
    end
  end

  def test_file_created
    assert File.exist?(@storage_path), "File #@storage_path should exist"

    content = File.read(@storage_path)
    assert content.length > 100, "Serialized content should have more than 100 chars"
  end

  def test_purge_state
    test = self
    StuffClassifier::Bayes.new("Cats or Dogs", :purge_state => true).instance_eval do
      test.assert @storage.instance_of?(StuffClassifier::FileStorage),"@storage should be an instance of FileStorage"
      test.assert @word_list.length == 0, "Word count should be purged"
      test.assert @category_list.length == 0, "Category count should be purged"
    end
  end
end
