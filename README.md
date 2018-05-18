# Poros ![TravisCI](https://travis-ci.org/HellRok/Poros.svg?branch=master)

This is a little gem written for persistence and active-record like querying of
objects with a simple YAML based backend.

The name stands for Plain Old Ruby Object Storage.

## Installation

This gem requires at least Ruby 2.1 because it uses `.to_h` on an Array and
named arguments for initialize.

Add this line to your application's Gemfile:

```gem 'poros' ```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install poros

## Usage

A basic usage would look like this:

```ruby
class Widget
  include Poros

  poro_attr :name, :order, :active
  poro_index :active

  def initialize(name: '', order: 0, active: false)
    @name = name
    @order = order
    @active = active
  end
end

widget = Widget.new(name: 'Cube', order: 0, active: true)
widget.save

other_widget = Widget.find('uuid')

many_widgets = Widget.where(order: 1, name: /regex/)
```

`#initialize` must use keyword arguments and contain at least all the
attributes defined in `poro_attr`. In the future I may define this function for
you but for right now I'm not sure I want to go that direction.

`poro_attr :blah` will define a getter and setter for `:blah` and also be persisted when you run `#save`

`poro_index :blah` will create indexes on these columns, this will greatly
speed up searching but if your index gets really big the initial load of a
model will take quite a long time.

`self.data_directory` you can re-define this method if you don't want it to
save to the default of `./db/#{self}`. If you do re-define it you _must_
seperate each model into it's own folder or it will have _lots_ of issues.

`.where` acts a bit like ActiveRecord and it takes exact matches, regexs, arrays, or
lambdas in any combination.

```ruby
# Valid examples
Widget.where(name: 'sprocket')
Widget.where(name: /spr.*cket/)
Widget.where(order: -> value { value > 3 })
Widget.where(order: [1, 5, 8], active: true)
Widget.where(order: 1).where(name: 'cog')

# Invalid examples
Widget.where(name: 'sprocket', name: 'cog') # can't check same value twice, use arrays
```


`.find` takes the `#uuid` which is generated by Poros and returns the single record.

## Development

After checking out the repo, run `bundle install` to install dependencies. Then, run
`rake test` to run the tests. You can also run `bin/console` for an interactive
prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To
release a new version, update the version number in `version.rb`, and then run
`bundle exec rake release`, which will create a git tag for the version, push
git commits and tags, and push the `.gem` file to
[rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at
https://github.com/HellRok/Poros

## License

The gem is available as open source under the terms of the [MIT
License](https://opensource.org/licenses/MIT).
