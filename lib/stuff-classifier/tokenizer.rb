# encoding: utf-8

module StuffClassifier::Tokenizer
  attr_writer :stemming

  def ignore_words=(value)
    @ignore_words = value
  end

  def ignore_words
    @ignore_words || StuffClassifier::STOP_WORDS[@language]
  end

  def stemming?
    defined?(@stemming) ? @stemming : false
  end

  def each_word(string)
    string = string.strip
    return if string == ''

    words = []
        
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
