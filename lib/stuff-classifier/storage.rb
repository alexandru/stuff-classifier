require 'msgpack'

module StuffClassifier
  class InMemoryStorage
    def initialize
      @storage = {}
    end

    def load_state(classifier)
      if @storage.key? classifier.name
        _word_list, _category_list, _training_count, _max_prob = @storage[classifier.name]
        classifier.instance_eval do
          @word_list = _word_list
          @category_list = _category_list
          @training_count=_training_count
          @max_prob = _max_prob
        end
      end
    end

    def save_state(classifier)
      name = classifier.name
      word_list = classifier.instance_variable_get :@word_list
      category_list = classifier.instance_variable_get :@category_list
      training_count = classifier.instance_variable_get :@training_count
      max_prob = classifier.instance_variable_get :@max_prob
      @storage[name] = [word_list, category_list, training_count,max_prob]
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
        _word_list, _category_list, _training_count, _max_prob = @storage[classifier.name]
        classifier.instance_eval do
          @word_list = _word_list
          @category_list = _category_list
          @training_count=_training_count
          @max_prob = _max_prob
        end
      end
    end

    def save_state(classifier)
      name = classifier.name
      word_list = classifier.instance_variable_get :@word_list
      category_list = classifier.instance_variable_get :@category_list
      training_count = classifier.instance_variable_get :@training_count
      max_prob = classifier.instance_variable_get :@max_prob
      @storage[name] = [word_list, category_list, training_count,max_prob]
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
