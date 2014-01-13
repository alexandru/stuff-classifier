module StuffClassifier
  autoload :VERSION,    'stuff-classifier/version'

  autoload :Storage, 'stuff-classifier/storage'
  autoload :InMemoryStorage, 'stuff-classifier/storage'
  autoload :FileStorage,     'stuff-classifier/storage'
  autoload :RedisStorage, 'stuff-classifier/storage'

  autoload :Tokenizer,  'stuff-classifier/tokenizer'
  autoload :TOKENIZER_PROPERTIES, 'stuff-classifier/tokenizer/tokenizer_properties'

  autoload :Base,       'stuff-classifier/base'
  autoload :Bayes,      'stuff-classifier/bayes'
  autoload :TfIdf,      'stuff-classifier/tf-idf'

end
