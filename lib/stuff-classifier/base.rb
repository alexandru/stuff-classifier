# encoding: utf-8

class StuffClassifier::Base
  extend StuffClassifier::Storage::ActAsStorable
  attr_reader :name
  attr_reader :word_list
  attr_reader :category_list
  attr_reader :training_count

  attr_accessor :tokenizer
  attr_accessor :language
  
  attr_accessor :thresholds
  attr_accessor :weight
  attr_accessor :assumed_prob
  attr_accessor :min_prob


  storable :version,:word_list,:category_list,:training_count,:thresholds,:weight,:assumed_prob,:min_prob
    
  def initialize(name, opts={})
    @version = StuffClassifier::VERSION
    
    @name = name

    # This values are nil or are loaded from storage
    @word_list = {}
    @category_list = {}
    @training_count=0

    # storage
    purge_state = opts[:purge_state]
    @storage = opts[:storage] || StuffClassifier::Base.storage
    unless purge_state
      @storage.load_state(self)
    else
      @storage.purge_state(self)
    end

    # This value can be set during initialization or overrided after load_state
    @thresholds = opts[:thresholds] || {}
    @weight = opts[:weight] || 1.0
    @assumed_prob = opts[:assumed_prob] || 0.1
    @min_prob = opts[:min_prob] || 0.0
    

    @ignore_words = nil
    @tokenizer = StuffClassifier::Tokenizer.new(opts)
    
  end

  def incr_word(word, category)
    @word_list[word] ||= {}

    @word_list[word][:categories] ||= {}
    @word_list[word][:categories][category] ||= 0
    @word_list[word][:categories][category] += 1

    @word_list[word][:_total_word] ||= 0
    @word_list[word][:_total_word] += 1

  
    # words count by categroy
    @category_list[category] ||= {}
    @category_list[category][:_total_word] ||= 0
    @category_list[category][:_total_word] += 1

  end

  def incr_cat(category)
    @category_list[category] ||= {}
    @category_list[category][:_count] ||= 0
    @category_list[category][:_count] += 1

    @training_count ||= 0
    @training_count += 1 

  end

  # return number of times the word appears in a category
  def word_count(word, category)
    return 0.0 unless @word_list[word] && @word_list[word][:categories] && @word_list[word][:categories][category]
    @word_list[word][:categories][category].to_f
  end

  # return the number of times the word appears in all categories
  def total_word_count(word)
    return 0.0 unless @word_list[word] && @word_list[word][:_total_word]
    @word_list[word][:_total_word].to_f
  end

  # return the number of words in a categories
  def total_word_count_in_cat(cat)
    return 0.0 unless @category_list[cat] && @category_list[cat][:_total_word]
    @category_list[cat][:_total_word].to_f
  end

  # return the number of training item 
  def total_cat_count
    @training_count
  end
  
  # return the number of training document for a category
  def cat_count(category)
    @category_list[category][:_count] ? @category_list[category][:_count].to_f : 0.0
  end

  # return the number of time categories in wich a word appear
  def categories_with_word_count(word)
    return 0 unless @word_list[word] && @word_list[word][:categories]
    @word_list[word][:categories].length 
  end  

  # return the number of categories
  def total_categories
    categories.length
  end

  def categories
    @category_list.keys
  end

  def train(category, text)
    @tokenizer.each_word(text) {|w| incr_word(w, category) }
    incr_cat(category)
  end

  def word_prob(word, cat)
    total_words_in_cat = total_word_count_in_cat(cat)
    return 0.0 if total_words_in_cat == 0
    word_count(word, cat).to_f / total_words_in_cat
  end

  def word_weighted_average(word, cat, opts={})
    func = opts[:func]

    # calculate current probability
    basic_prob = func ? func.call(word, cat) : word_prob(word, cat)
    
    # count the number of times this word has appeared in all
    # categories
    totals = total_word_count(word)
    
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
