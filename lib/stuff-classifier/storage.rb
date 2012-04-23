require 'msgpack'

module StuffClassifier
  class InMemoryStorage
    def initialize
      @storage = {}
    end

    def load_state(classifier)
      if @storage.key? classifier.name
        _word_count, _category_count,_word_total,_category_total = @storage[classifier.name]
        classifier.instance_eval do
          @word_count = _word_count
          @category_count = _category_count

          @word_total = _word_total
          @category_total = _category_total
        end
      end
    end

    def save_state(classifier)
      name = classifier.name
      word_count = classifier.instance_variable_get :@word_count
      category_count = classifier.instance_variable_get :@category_count
      @storage[name] = [word_count, category_count]
    end

    def purge_state(classifier)
      @storage.delete(classifier.name)
    end
  end

  class FileStorage
    def initialize(path)
      @storage = {}
      @path = path
    end

    def load_state(classifier)
      if @storage.length == 0 && File.exists?(@path)
        @storage = MessagePack.unpack(File.read(@path))
      end

      if @storage.key? classifier.name
        _word_count, _category_count = @storage[classifier.name]
        classifier.instance_eval do
          @word_count = _word_count
          @category_count = _category_count
        end
      end
    end

    def save_state(classifier)
      name = classifier.name
      word_count = classifier.instance_variable_get :@word_count
      category_count = classifier.instance_variable_get :@category_count
      @storage[name] = [word_count, category_count]
      _write_to_file
    end

    def purge_state(classifier)
      @storage.delete(classifier.name)
      _write_to_file
    end

    def _write_to_file
      File.open(@path, 'w') do |fh|
        fh.flock(File::LOCK_EX)
        fh.write(@storage.to_msgpack)
      end
    end
  end
end
