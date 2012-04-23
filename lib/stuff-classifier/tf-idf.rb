class StuffClassifier::TfIdf < StuffClassifier::Base
  def tf_idf(word, cat)
    word_cat_nr = word_count(word, cat)
    cat_nr = cat_count(cat)
    tf = 1.0 * word_cat_nr / cat_nr
    
    total_categories = categories.length
    categories_with_word = (@word_count[word] || []).length

    idf = Math.log10((total_categories + 2) / (categories_with_word + 1.0))    
    return tf * idf
  end

  def text_prob(text, cat)
    @tokenizer.each_word(text).map{|w| tf_idf(w, cat)}.inject(0){|s,p| s + p}
  end

  def cat_scores(text)
    probs = {}
    categories.each do |cat|
      p = text_prob(text, cat)
      probs[cat] = p
    end
    probs.map{|k,v| [k,v]}.sort{|a,b| b[1] <=> a[1]}
  end

  def classify(text, default=nil)
    max_prob = 0.0
    best = nil

    cat_scores(text).each do |score|
      cat, prob = score
      if prob > max_prob
        max_prob = prob
        best = cat
      end
    end

    max_prob > 0 ? best : default
  end
end
