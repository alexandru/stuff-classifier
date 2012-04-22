# -*- coding: utf-8 -*-
require 'helper.rb'

class Test001Tokenizer < TestBase
  before do
    @en_tokenizer = StuffClassifier::Tokenizer.new
    @fr_tokenizer = StuffClassifier::Tokenizer.new(:language => "fr")
  end

  def test_simple_tokens
     words =  @en_tokenizer.each_word('Hello world! How are you?')
     should_return = ["hello", "world"]

     assert_equal should_return, words
  end    

  def test_with_stemming
    words =  @en_tokenizer.each_word('Lots of dogs, lots of cats! This really is the information highway')
    should_return =["lot", "dog", "lot", "cat", "realli" ,"inform", "highway" ]

    assert_equal should_return, words

  end

  def test_complicated_tokens 
    words = @en_tokenizer.each_word("I don't really get what you want to
      accomplish. There is a class TestEval2, you can do test_eval2 =
      TestEval2.new afterwards. And: class A ... end always yields nil, so
      your output is ok I guess ;-)")
    
    should_return = [
      "realli", "want", "accomplish", "class",
      "testeval2",  "test", "eval2","testeval2", "new", "class", "end",
      "yield", "nil", "output", "ok", "guess"]
    
    assert_equal should_return, words
  end  

  def test_unicode
  
    words = @fr_tokenizer.each_word("il s'appelle le vilain petit canard : en référence à Hans Christian Andersen, se démarquer négativement")

    should_return = [
      "appel", "vilain", "pet", "canard", "référent", 
      "han", "christian", "andersen", "démarqu", "négat"]

    assert_equal should_return, words      
  end

end
