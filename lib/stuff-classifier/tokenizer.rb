# encoding: utf-8

require "lingua/stemmer"

class StuffClassifier::Tokenizer
  require  "stuff-classifier/tokenizer/tokenizer_properties"
  
  def initialize(opts={})
    @language = opts.key?(:language) ? opts[:language] : "en"
    @properties = StuffClassifier::Tokenizer::TOKENIZER_PROPERTIES[@language]
    
    @stemming = opts.key?(:stemming) ? opts[:stemming] : true
    if @stemming
      @stemmer = Lingua::Stemmer.new(:language => @language)
    end
  end

  def language
    @language
  end

  def preprocessing_regexps=(value)
    @preprocessing_regexps = value
  end

  def preprocessing_regexps
    @preprocessing_regexps || @properties[:preprocessing_regexps]
  end

  def ignore_words=(value)
    @ignore_words = value
  end

  def ignore_words
    @ignore_words || @properties[:stop_word]
  end

  def stemming?
    @stemming || false
  end

  def each_word(string)
    string = string.strip
    return if string == ''

    words = []

    # tokenize string
    string.split("\n").each do |line|

      # Apply preprocessing regexps
      if preprocessing_regexps
        preprocessing_regexps.each { |regexp,replace_by| line.gsub!(regexp, replace_by) }
      end

      line.gsub(/\p{Word}+/).each do |w|
          next if w == '' || ignore_words.member?(w.downcase)

        if stemming? and stemable?(w)
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

private 

  def stemable?(word)
    word =~ /^\p{Alpha}+$/
  end
  
end
