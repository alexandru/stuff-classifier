# encoding: utf-8

require "lingua/stemmer"

class StuffClassifier::Tokenizer
  include StuffClassifier::tokenizer::TOKENIZER_PROPERTIES"
  
  def initialize(opts={})
    if opts[:language]
      @language=opts[:language]
    else
      @language="en"
    end
    @stemming = opts.key?(:stemming) ? opts[:stemming] : true
    if @stemming
      @stemmer = Lingua::Stemmer.new(:language => @language)
    end
    @properties = StuffClassifier::Tokenizer::TOKENIZER_PROPERTIES[@language]
    
  end

  def preprocessing_regexps=(value)
    @preprocessing_regexps = value
  end

  def preprocessing_regexps
    @preprocessing_regexps || @properties["preprocessing_regexps"]
  end

  def ignore_words=(value)
    @ignore_words = value
  end

  def ignore_words
    @ignore_words || @properties["stop_word"]
  end

  def stemming=(value)
    @stemming = value
  end

  def stemming?
    @stemming || false
  end

  def each_word(string)
    string = string.strip
    return if string == ''

    words = []

    # Apply preprocessing regexps
    if preprocessing_regexps
      preprocessing_regexps.each { |regexp,replace_by| string.gsub!(regexp, replace_by) }
    end
    
    # tokenize string
    string.split("\n").each do |line|
      line.gsub(/\p{Word}+/).each do |w|
        next if w == '' || ignore_words.member?(w.downcase)

        if stemming?
          w = @stemmer.stem(w).downcase
          next if ignore_words.member?(w)
        else
          w = w.downcase
        end

        words << (block_given? ? (yield w) : w)
      end
    end

    return words
  end

end
