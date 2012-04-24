require 'helper'

class Test008NaiveBayesClassificationWithThresholdWithFileStore < TestBase

  before do 
    @storage_path = "/tmp/test_classifier.db"
    @storage = StuffClassifier::FileStorage.new(@storage_path)
    StuffClassifier::Base.storage = @storage
    StuffClassifier::Bayes.open("Cats or Dogs",:max_prob=>0.01) do |cls|
      cls.train :dog, "Dogs are Awesome, but in Germany they do Wuff wuff"
      cls.train :cat, "Cats are ok, but too independent"
      cls.train :dog, "Dogs in Brasil do Au Au"
      cls.train :cat, "Cats, in another hand do always Miau, Miau"
    end
    StuffClassifier::Base.storage = StuffClassifier::FileStorage.new(@storage_path)
  end
  def test_for_threshold
    @classifier = StuffClassifier::Bayes.new("Cats or Dogs",:max_prob=>0.01)
    assert @classifier.classify("Oinc","Nothing Found"), "Nothing Found"
    assert @classifier.classify("Au"),:dog
  end
  def teardown
    File.unlink @storage_path if File.exists? @storage_path
  end
end
