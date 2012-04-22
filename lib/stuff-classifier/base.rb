# encoding: utf-8

class StuffClassifier::Base
  attr_reader :name
  attr_writer :tokenizer
  attr_accessor :language
  
  def initialize(name, opts={})
    purge_state = opts[:purge_state]
    
    @name = name
    @wcount = {}
    @ccount = {}
    @ignore_words = nil
    @tokenizer = StuffClassifier::Tokenizer.new(opts)

    # word weight evaluation
    @weight = opts[:weight] || 1.0
    @assumed_prob = opts[:assumed_prob] || 0.1

    # storage
    @storage = opts[:storage] || StuffClassifier::Base.storage
    unless purge_state
      @storage.load_state(self)
    else
      @storage.purge_state(self)
    end
  end

  def incr_word(word, category)
    @wcount[word] ||= {}
    @wcount[word][category] ||= 0
    @wcount[word][category] += 1
  end

  def incr_cat(category)
    @ccount[category] ||= 0
    @ccount[category] += 1
  end

  def word_count(word, category)
    return 0.0 unless @wcount[word] && @wcount[word][category]
    @wcount[word][category].to_f
  end
  
  def cat_count(category)
    @ccount[category] ? @ccount[category].to_f : 0.0
  end

  def total_in_cat(category)
    # this has to be optimized
     @wcount.find_all{|k,v| v.member? category}.map{|k,v| v[category]}.inject(0){|a,b| a+b}
  end

  def total_count
    @ccount.values.inject(0){|s,c| s + c}.to_f
  end
  
  def categories
    @ccount.keys
  end

  def train(category, text)
    @tokenizer.each_word(text) {|w| incr_word(w, category) }
    incr_cat(category)
  end

  def word_prob(word, cat)
    total_words_in_cat = total_in_cat(cat)
    return 0.0 if total_words_in_cat == 0
    word_count(word, cat).to_f / total_words_in_cat
  end

  def word_weighted_average(word, cat, opts={})
    func = opts[:func]

    # calculate current probability
    basic_prob = func ? func.call(word, cat) : word_prob(word, cat)
    
    # count the number of times this word has appeared in all
    # categories
    totals = categories.map{|c| word_count(word, c)}.inject(0){|s,c| s + c}
    
    # the final weighted average
    (@weight * @assumed_prob + totals * basic_prob) / (@weight + totals)
  end

  def save_state
    @storage.save_state(self)
  end

  class << self
    attr_writer :storage

    def storage
      @storage = StuffClassifier::InMemoryStorage.new unless defined? @storage
      @storage
    end

    def open(name)
      inst = self.new(name)
      if block_given?
        yield inst
        inst.save_state
      else
        inst
      end
    end
  end
end
