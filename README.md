
[![Build Status](https://travis-ci.org/singlebrook/bunup.svg?branch=master)](https://travis-ci.org/singlebrook/bunup)

# Bunup

Update Gemfile dependencies and commit to git with one command.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'bunup'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install bunup

## Usage

### Bunup a single gem

```bash
bunup rake
```

### Bunup multiple gems

```bash
bunup rake rubocop
```

### Bunup all gems

```bash
bunup --all
```

## Development

After checking out the repo, enter the project directory and run the following:

```bash
bundle
COVERAGE=1 bundle exec rake
```

`bin/console` is an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. 

To release a new version, update the version number in `version.rb`, and then 
run `bundle exec rake release`, which will create a git tag for the version, 
push git commits and tags, and push the `.gem` file to 
[rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at 
https://github.com/singlebrook/bunup. This project is intended to be a safe, 
welcoming space for collaboration, and contributors are expected to adhere to 
the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## Acknowledgements

Bunup was created by [Jared Beck](https://jaredbeck.com). It is developed by
[Singlebrook Technology](https://singlebrook.com).

## License

The gem is available as open source under the terms of the 
[MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Bunup project’s codebases, issue trackers, chat 
rooms and mailing lists is expected to follow the 
[code of conduct](https://github.com/[USERNAME]/bunup/blob/master/CODE_OF_CONDUCT.md).
