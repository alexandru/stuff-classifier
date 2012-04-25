class StuffClassifier::TfIdf < StuffClassifier::Base
  extend StuffClassifier::Storage::ActAsStorable

  def initialize(name, opts={})
    super(name, opts)
  end


  def word_prob(word, cat)
    word_cat_nr = word_count(word, cat)
    cat_nr = cat_count(cat)

    tf = 1.0 * word_cat_nr / cat_nr
        
    idf = Math.log10((total_categories + 2) / (categories_with_word_count(word) + 1.0))    
    tf * idf
  end

  def text_prob(text, cat)
    @tokenizer.each_word(text).map{|w| word_prob(w, cat)}.inject(0){|s,p| s + p}
  end

  def cat_scores(text)
    probs = {}
    categories.each do |cat|
      p = text_prob(text, cat)
      probs[cat] = p
    end
    probs.map{|k,v| [k,v]}.sort{|a,b| b[1] <=> a[1]}
  end
  
  def word_classification_detail(word)

    p "tf_idf"
    result=self.categories.inject({}) do |h,cat| h[cat]=self.word_prob(word,cat);h end
    ap result

    p "text_prob"
    result=categories.inject({}) do |h,cat| h[cat]=text_prob(word,cat);h end  
    ap result    
    
  end
  
end
