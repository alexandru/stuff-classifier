# encoding: utf-8

class StuffClassifier::Bayes < StuffClassifier::Base
  # http://en.wikipedia.org/wiki/Naive_Bayes_classifier

  attr_writer :thresholds

  def initialize(name, opts={})
    super(name, opts)
    @thresholds = {}
  end

  def doc_prob(text, category)
    each_word(text).map {|w|
      word_weighted_average(w, category)
    }.inject(1) {|p,c| p * c}
  end

  def text_prob(text, category)
    cat_prob = cat_count(category) / total_count
    doc_prob = doc_prob(text, category)
    cat_prob * doc_prob
  end

  def cat_scores(text)
    probs = {}
    categories.each do |cat|
      probs[cat] = text_prob(text, cat)
    end
    probs.map{|k,v| [k,v]}.sort{|a,b| b[1] <=> a[1]}
  end

  def classify(text, default=nil)
    # Find the category with the highest probability
    max_prob = 0.0
    best = nil
    
    scores = cat_scores(text)
    scores.each do |score|
      cat, prob = score
      if prob > max_prob
        max_prob = prob
        best = cat
      end
    end

    return default unless best
    threshold = @thresholds[best] || 1.0

    scores.each do |score|
      cat, prob = score
      next if cat == best
      return default if prob * threshold > max_prob
    end

    return best
  end
end
