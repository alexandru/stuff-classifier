module StuffClassifier
  autoload :VERSION,    'stuff-classifier/version'
  autoload :Tokenizer,  'stuff-classifier/tokenizer'
  autoload :STOP_WORDS, 'stuff-classifier/tokenizer_properties'

  autoload :Base,       'stuff-classifier/base'
  autoload :Bayes,      'stuff-classifier/bayes'
  autoload :TfIdf,      'stuff-classifier/tf-idf'

  autoload :InMemoryStorage, 'stuff-classifier/storage'
  autoload :FileStorage,     'stuff-classifier/storage'
end
