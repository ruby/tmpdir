# tmpdir

retrieve temporary directory path

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'tmpdir'
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install tmpdir

## Usage

Dir.mktmpdir creates a temporary directory.
The directory is created with 0700 permission.

Application should not change the permission to make the temporary directory accessible from other users.

The prefix and suffix of the name of the directory is specified by
the optional first argument, <i>prefix_suffix</i>.

- If it is not specified or nil, "d" is used as the prefix and no suffix is used.
- If it is a string, it is used as the prefix and no suffix is used.
- If it is an array, first element is used as the prefix and second element is used as a suffix.

```ruby
Dir.mktmpdir {|dir| dir is ".../d..." }
Dir.mktmpdir("foo") {|dir| dir is ".../foo..." }
Dir.mktmpdir(["foo", "bar"]) {|dir| dir is ".../foo...bar" }
```

The directory is created under Dir.tmpdir or
the optional second argument <i>tmpdir</i> if non-nil value is given.

```ruby
Dir.mktmpdir {|dir| dir is "#{Dir.tmpdir}/d..." }
Dir.mktmpdir(nil, "/var/tmp") {|dir| dir is "/var/tmp/d..." }
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/ruby/tmpdir.

