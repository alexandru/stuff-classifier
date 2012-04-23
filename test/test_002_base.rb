require 'helper'


class Test002Base < TestBase
  before do
    @cls = StuffClassifier::Bayes.new("Cats or Dogs")
    set_classifier @cls
    
    train :dog, "Dogs are awesome, cats too. I love my dog"
    train :cat, "Cats are more preferred by software developers. I never could stand cats. I have a dog"    
    train :dog, "My dog's name is Willy. He likes to play with my wife's cat all day long. I love dogs"
    train :cat, "Cats are difficult animals, unlike dogs, really annoying, I hate them all"
    train :dog, "So which one should you choose? A dog, definitely."
    train :cat, "The favorite food for cats is bird meat, although mice are good, but birds are a delicacy"
    train :dog, "A dog will eat anything, including birds or whatever meat"
    train :cat, "My cat's favorite place to purr is on my keyboard"
    train :dog, "My dog's favorite place to take a leak is the tree in front of our house"
  end

  def test_count 
    assert @cls.total_count == 9
    assert @cls.categories.map {|c| @cls.cat_count(c)}.inject(0){|s,count| s+count} == @cls.total_count

    # compare word count sum to word by cat count sum 
    assert @cls.word_list.map do |w| @cls.total_word_count(w[0]) end.inject(0) do |s,count| s+count end 
            == @cls.categories.map {|c| @cls.total_word_count_in_cat(c)}.inject(0){|s,count| s+count}  

    assert @cls.word_list.map do |w| @cls.total_word_count(w[0]) end.inject(0) do |s,count| s+count end == 58


  end

end
