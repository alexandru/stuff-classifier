require 'helper.rb'

class Test001Tokenizer < TestBase
  before do
    @tokenizer = StuffClassifier::Bayes.new("TEST")

  end

  def test_simple_tokens
    assert_equal ["hello", "world"], 
      @tokenizer.each_word('Hello world! How are you?')
  end    

  def test_with_stemming
    @tokenizer.stemming = true
    assert_equal(
       ["lot", "dog", "lot", "cat", "realli" ,"inform", "highway" ], 
       @tokenizer.each_word('Lots of dogs, lots of cats! This really is the information highway')
    )
  end

  def test_complicated_tokens 
    words = @tokenizer.each_word("I don't really get what you want to
      accomplish. There is a class TestEval2, you can do test_eval2 =
      TestEval2.new afterwards. And: class A ... end always yields nil, so
      your output is ok I guess ;-)")
    
    should_return = [
      "really", "want", "accomplish", "class",
      "testeval", "test", "eval", "testeval", "new", "class", "end",
      "yields", "nil", "output", "ok", "guess"]
    
    assert_equal should_return, words
  end  

end
