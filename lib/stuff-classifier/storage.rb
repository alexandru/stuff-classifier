# encoding : UTF-8
module StuffClassifier

  class Storage
    module ActAsStorable
        def storable(*to_store)
          @to_store = to_store
        end
        def to_store
          @to_store || []
        end
    end

    attr_accessor :storage

    def initialize(*opts)
      @storage = {}
    end

    def storage_to_classifier(classifier)
      if @storage.key? classifier.name
        @storage[classifier.name].each do |var,value|
          classifier.instance_variable_set "@#{var}",value
        end
      end
    end

    def classifier_to_storage(classifier)
      to_store = classifier.class.to_store + classifier.class.superclass.to_store
      @storage[classifier.name] =  to_store.inject({}) {|h,var| h[var] = classifier.instance_variable_get("@#{var}");h}
    end
    
    def clear_storage(classifier)
      @storage.delete(classifier.name)      
    end

  end

  class InMemoryStorage < Storage
    def initialize
      super
    end

    def load_state(classifier)
      storage_to_classifier(classifier)
    end

    def save_state(classifier)
      classifier_to_storage(classifier)
    end

    def purge_state(classifier)
      clear_storage(classifier)
    end

  end

  class FileStorage < Storage
    def initialize(path)
      super
      @path = path
    end

    def load_state(classifier)
      if @storage.length == 0 && File.exists?(@path)
        data = File.open(@path, 'rb') { |f| f.read }
        @storage = Marshal.load(data)
      end
      storage_to_classifier(classifier)
    end

    def save_state(classifier)
      classifier_to_storage(classifier)
      _write_to_file
    end

    def purge_state(classifier)
      clear_storage(classifier)
      _write_to_file
    end

    def _write_to_file
      File.open(@path, 'wb') do |fh|
        fh.flock(File::LOCK_EX)
        fh.write(Marshal.dump(@storage))
      end
    end

  end

  class RedisStorage < Storage
    def initialize(key, redis_options=nil)
      super
      @key = key
      @redis = Redis.new(redis_options || {})
    end

    def load_state(classifier)
      if @storage.length == 0 && @redis.exists(@key)
        data = @redis.get(@key)
        @storage = Marshal.load(data)
      end
      storage_to_classifier(classifier)
    end

    def save_state(classifier)
      classifier_to_storage(classifier)
      _write_to_redis
    end

    def purge_state(classifier)
      clear_storage(classifier)
      _write_to_redis
    end

    private
    def _write_to_redis
      data = Marshal.dump(@storage)
      @redis.set(@key, data)
    end
  end
end
