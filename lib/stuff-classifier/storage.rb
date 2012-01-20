require 'msgpack'

module StuffClassifier
  class InMemoryStorage
    def initialize
      @storage = {}
    end

    def load_state(classifier)
      if @storage.key? classifier.name
        _wcount, _ccount = @storage[classifier.name]
        classifier.instance_eval do
          @wcount = _wcount
          @ccount = _ccount
        end
      end
    end

    def save_state(classifier)
      name = classifier.name
      wcount = classifier.instance_variable_get :@wcount
      ccount = classifier.instance_variable_get :@ccount
      @storage[name] = [wcount, ccount]
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
        _wcount, _ccount = @storage[classifier.name]
        classifier.instance_eval do
          @wcount = _wcount
          @ccount = _ccount
        end
      end
    end

    def save_state(classifier)
      name = classifier.name
      wcount = classifier.instance_variable_get :@wcount
      ccount = classifier.instance_variable_get :@ccount
      @storage[name] = [wcount, ccount]
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
