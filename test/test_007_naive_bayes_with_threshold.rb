require 'helper'

class Test007NaiveBayesClassificationWithThreshold < TestBase

  before do 
    set_classifier StuffClassifier::Bayes.new("Cats or Dogs",:max_prob=>0.04)
    train :dog, "Dogs are Awesome, but in Germany they do Auw Auw"
    train :cat, "Cats are ok, but too independent"
    train :dog, "Dogs in Brasil do Au Au"
    train :cat, "Cats, in another hand do always Miau, Miau"
  end
  def test_for_threshold
    assert @classifier.classify("Oinc","Nothing Found"), "Nothing Found"
    assert @classifier.classify("Au"),:dog
  end
end
