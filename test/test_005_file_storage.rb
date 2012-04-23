require 'helper'


class Test005FileStorage < TestBase
  before do
    @storage_path = "/tmp/test_classifier.db"
    @storage = StuffClassifier::FileStorage.new(@storage_path)
    StuffClassifier::Base.storage = @storage

    StuffClassifier::Bayes.open("Cats or Dogs") do |cls|    
      cls.train(:dog, "Dogs are awesome, cats too. I love my dog")
      cls.train(:cat, "Cats are more preferred by software developers. I never could stand cats. I have a dog")
    end

    # redefining storage instance, forcing it to read from file again
    StuffClassifier::Base.storage = StuffClassifier::FileStorage.new(@storage_path)
  end

  def teardown
    File.unlink @storage_path if File.exists? @storage_path
  end

  def test_for_persistance    
    assert ! @storage.equal?(StuffClassifier::Base.storage),
      "Storage instance should not be the same"

    test = self
    StuffClassifier::Bayes.new("Cats or Dogs").instance_eval do
      test.assert @storage.instance_of?(StuffClassifier::FileStorage),
        "@storage should be an instance of FileStorage"
      test.assert @word_list.length > 0, "Word count should be persisted"
      test.assert @category_list.length > 0, "Category count should be persisted"
    end
  end

  def test_file_created
    assert File.exist?(@storage_path), 
      "File #@storage_path should exist"

    content = File.read(@storage_path)
    assert content.length > 100, 
      "Serialized content should have more than 100 chars"
  end

  def test_purge_state
    test = self
    StuffClassifier::Bayes.new("Cats or Dogs", :purge_state => true).instance_eval do
      test.assert @storage.instance_of?(StuffClassifier::FileStorage),
        "@storage should be an instance of FileStorage"
      test.assert @word_list.length == 0, "Word count should be purged"
      test.assert @category_list.length == 0, "Category count should be purged"
    end
  end
end
