require 'simplecov'
SimpleCov.start

require 'turn'
require 'minitest/autorun'
require 'stuff-classifier'

Turn.config do |c|
 # use one of output formats:
 # :outline  - turn's original case/test outline mode [default]
 # :progress - indicates progress with progress bar
 # :dotted   - test/unit's traditional dot-progress mode
 # :pretty   - new pretty reporter
 # :marshal  - dump output as YAML (normal run mode only)
 # :cue      - interactive testing
 c.format  = :outline
 # turn on invoke/execute tracing, enable full backtrace
 c.trace   = true
 # use humanized test names (works only with :outline format)
 c.natural = true
end

class TestBase < MiniTest::Unit::TestCase
  def self.before(&block)    
    @on_setup = block if block
    @on_setup
  end

  def setup
    on_setup = self.class.before
    instance_eval(&on_setup) if on_setup
  end

  def set_classifier(instance)
    @classifier = instance
  end
  def classifier
    @classifier
  end


  def train(category, value)
    @classifier.train(category, value)
  end

  def should_be(category, value)
    assert_equal category, @classifier.classify(value), value
  end
end
