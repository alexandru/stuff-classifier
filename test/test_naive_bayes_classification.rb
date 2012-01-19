require 'minitest_helper'


class TestNaiveBayesClassification < StuffClassifierTest  
  before do
    set_classifier StuffClassifier::Bayes.new("Cats or Dogs")
    
    train :dog, "Dogs are awesome, cats too. I love my dog"
    train :cat, "Cats are more preferred by software developers. I never could stand cats. I have a dog"
    train :dog, "My dog's name is Willy. He likes to play with my wife's cat all day long. I love dogs"
    train :cat, "Cats are difficult animals, unlike dogs, really annoying, I hate them all"
    train :dog, "So which one should you choose? A dog, definitely."
  end

  def test_for_cats 
    should_be :cat, "I hate"    
    should_be :cat, "The most annoying animal on earth"
    should_be :cat, "The preferred company of software developers"
  end

  def test_for_dogs
    should_be :dog, "What pet will I love more?"    
    should_be :dog, "Willy, where the heck are you?"
    should_be :dog, "Cats or Dogs?"
  end
end
