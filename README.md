# stuff-classifier

A library for classifying text into multiple categories.

Currently provided classifiers:

- a [naive bayes classifier](http://en.wikipedia.org/wiki/Naive_Bayes_classifier)
- a classifier based on [tf-idf weights](http://en.wikipedia.org/wiki/Tf%E2%80%93idf)

Ran a benchmark of 1345 items that I have previously manually
classified with multiple categories. Here's the rate over which the 2
algorithms have correctly detected one of those categories:

- Bayes: 79.26%
- Tf-Idf: 81.34%

I prefer the Naive Bayes approach, because while having lower stats on
this benchmark, it seems to make better decisions than I did in many
cases. For example, an item with title *"Paintball Session, 100 Balls
and Equipment"* was classified as *"Activities"* by me, but the bayes
classifier identified it as *"Sports"*, at which point I had an
intellectual orgasm. Also, the Tf-Idf classifier seems to do better on
clear-cut cases, but doesn't seem to handle uncertainty so well. Of
course, these are just quick tests I made and I have no idea which is
really better.

## Install

```bash
gem install stuff-classifier
```

## Usage

You either instantiate one class or the other. Both have the same
signature:

```ruby
require 'stuff-classifier'

# for the naive bayes implementation
cls = StuffClassifier::Bayes.new("Cats or Dogs")

# for the Tf-Idf based implementation
cls = StuffClassifier::TfIdf.new("Cats or Dogs")

# these classifiers use word stemming by default, but if it has weird
# behavior, then you can disable it on init:
cls = StuffClassifier::TfIdf.new("Cats or Dogs", :stemming => false)

# also by default, the parsing phase filters out stop words, to
# disable or to come up with your own list of stop words, on a
# classifier instance you can do this:
cls.ignore_words = [ 'the', 'my', 'i', 'dont' ]
 ```

Training the classifier:

```ruby
cls.train(:dog, "Dogs are awesome, cats too. I love my dog")
cls.train(:cat, "Cats are more preferred by software developers. I never could stand cats. I have a dog")    
cls.train(:dog, "My dog's name is Willy. He likes to play with my wife's cat all day long. I love dogs")
cls.train(:cat, "Cats are difficult animals, unlike dogs, really annoying, I hate them all")
cls.train(:dog, "So which one should you choose? A dog, definitely.")
cls.train(:cat, "The favorite food for cats is bird meat, although mice are good, but birds are a delicacy")
cls.train(:dog, "A dog will eat anything, including birds or whatever meat")
cls.train(:cat, "My cat's favorite place to purr is on my keyboard")
cls.train(:dog, "My dog's favorite place to take a leak is the tree in front of our house")
```

And finally, classifying stuff:

```ruby
cls.classify("This test is about cats.")
#=> :cat
cls.classify("I hate ...")
#=> :cat
cls.classify("The most annoying animal on earth.")
#=> :cat
cls.classify("The preferred company of software developers.")
#=> :cat
cls.classify("My precious, my favorite!")
#=> :cat
cls.classify("Get off my keyboard!")
#=> :cat
cls.classify("Kill that bird!")
#=> :cat

cls.classify("This test is about dogs.")
#=> :dog
cls.classify("Cats or Dogs?") 
#=> :dog
cls.classify("What pet will I love more?")    
#=> :dog
cls.classify("Willy, where the heck are you?")
#=> :dog
cls.classify("I like big buts and I cannot lie.") 
#=> :dog
cls.classify("Why is the front door of our house open?")
#=> :dog
cls.classify("Who is eating my meat?")
#=> :dog
```

## Persistency

The following layers for saving the training data between sessions are
implemented:

- in memory (by default)
- on disk
- (coming soon) in a RDBMS

To persist the data on disk, you can do this:

```ruby
store = StuffClassifier::FileStorage.new(@storage_path)

# global setting
StuffClassifier::Base.storage = store

# or alternative local setting on instantiation, by means of an
# optional param ...
cls = StuffClassifier::Bayes.new("Cats or Dogs", :storage => store)

# after training is done, to persist the data ...
cls.save_state

# or you could just do this:
StuffClassifier::Bayes.open("Cats or Dogs") do |cls|
  # when done, save_state is called on END
end

# to start fresh, deleting the saved training data for this classifier
StuffClassifier::Bayes.new("Cats or Dogs", :purge_state => true)
```

The name you give your classifier is important, as based on it the
data will get loaded and saved. For instance, following 3 classifiers
will be stored in different buckets, being independent of each other.

```ruby
cls1 = StuffClassifier::Bayes.new("Cats or Dogs")
cls2 = StuffClassifier::Bayes.new("True or False")
cls3 = StuffClassifier::Bayes.new("Spam or Ham")	
```

## License

MIT Licensed. See LICENSE.txt for details.


