# encoding: utf-8

class StuffClassifier::Base
  attr_reader :name
  attr_writer :tokenizer
  attr_accessor :language
  
  def initialize(name, opts={})
    purge_state = opts[:purge_state]
    
    @name = name

    @word_count = {}
    @category_count = {}
    @training_count=0
    
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
    @word_count[word] ||= {}

    @word_count[word][:categories] ||= {}

    @word_count[word][:categories][category] ||= 0
    @word_count[word][:categories][category] += 1

    @word_count[word][:_total_word] ||= 0
    @word_count[word][:_total_word] += 1

    
    # Total word count
    @word_count[:_total_word]||=0
    @word_count[:_total_word]+=1

    # words count by categroy
    @category_count[category] ||= {}
    @category_count[category][:_total_word] ||= 0
    @category_count[category][:_total_word] += 1

  end

  def incr_cat(category)
    @category_count[category] ||= {}
    @category_count[category][:_count] ||= 0
    @category_count[category][:_count] += 1

    @training_count ||= 0
    @training_count += 1 

  end

  # return number of time the word appears in a category
  def word_count(word, category)
    return 0.0 unless @word_count[word] && @word_count[word][:categories] && @word_count[word][:categories][category]
    @word_count[word][category].to_f
  end

  # return the number of time the word appears in all categories
  def total_word_count(word)
    return 0.0 unless @word_count[word] && @word_count[word][:_total_word]
    @word_count[word][:_total_word].to_f
  end

  def total_word_count_in_cat(cat)
    p cat
    p @category_count
    return 0.0 unless @category_count[cat] && @category_count[cat][:_total_word]
    @category_count[cat][:_total_word].to_f
  end

  # return the number of categories
  def total_count
    @training_count
  end
  
  # return the training document count for a category
  def cat_count(category)
    @category_count[category][:_count] ? @category_count[category][:_count].to_f : 0.0
  end
  
  def categories
    @category_count.keys
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
