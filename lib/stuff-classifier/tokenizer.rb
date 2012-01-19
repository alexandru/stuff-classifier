require 'fast_stemmer'

module StuffClassifier::Tokenizer

  def ignore_words=(value)
    @ignore_words = value
  end

  def ignore_words
    @ignore_words || StuffClassifier::STOP_WORDS
  end

  def stemming?
    defined?(@stemming) ? @stemming : false
  end

  def stemming=(value)
    @stemming = value
  end

  def each_word(string)
    string = string.strip
    return if string == ''

    words = []
    
    cnt = string.gsub(/['`]/, '')
    cnt.split("\n").each do |line|
      line_cnt = line.gsub(/[^a-zA-Z]+/, ' ')
      line_cnt.split(/\s+/).each do |w|
        next if w == '' || ignore_words.member?(w.downcase)

        if stemming?
          w = w.stem.downcase
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
