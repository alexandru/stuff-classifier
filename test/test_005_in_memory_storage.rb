require 'helper'


class Test005InMemoryStorage < TestBase
  before do
    StuffClassifier::Base.storage = StuffClassifier::InMemoryStorage.new

    StuffClassifier::Bayes.open("Cats or Dogs") do |cls|    
      cls.train(:dog, "Dogs are awesome, cats too. I love my dog")
      cls.train(:cat, "Cats are more preferred by software developers. I never could stand cats. I have a dog")
    end
  end

  def test_for_persistance
    test = self
    StuffClassifier::Bayes.new("Cats or Dogs").instance_eval do
      test.assert @storage.instance_of?(StuffClassifier::InMemoryStorage),
        "@storage should be an instance of FileStorage"
      test.assert @word_list.length > 0, "Word count should be persisted"
      test.assert @category_list.length > 0, "Category count should be persisted"
    end
  end

  def test_purge_state
    test = self
    StuffClassifier::Bayes.new("Cats or Dogs", :purge_state => true).instance_eval do
      test.assert @word_list.length == 0, "Word count should be purged"
      test.assert @category_list.length == 0, "Category count should be purged"
    end
  end
end
