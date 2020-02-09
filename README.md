# ScrapKit

ScrapKit automates web scraping and converts the results in plain objects by using configuration objects called _recipes_.

Each recipe can be loaded as an object or as JSON file, and have the following structure:

```json
{
  "url": "https://status.heroku.com/",
  "attributes": {
    "apps": ".subnav__inner .ember-view:nth-child(1) > .status-summary__description",
    "data": ".subnav__inner .ember-view:nth-child(2) > .status-summary__description",
    "tools": ".subnav__inner .ember-view:nth-child(3) > .status-summary__description"
  }
}
```

* `url`: It defines the web page to scrape.
* `attributes`: Is an object that maps each attribute name with its corresponding CSS selector.

`attributes` can have a more complex structure to handle collections. For example:

```json
{
  "url": "https://hpneo.dev/",
  "attributes": {
    "posts": {
      "selector": ".post-item",
      "children_attributes": {
        "title": "h2"
      }
    }
  }
}
```

In this case `attributes` has a `posts` key, which will store the results of a collection, defined by a CSS `selector` and an object of children attributes.

`children_attributes` is an object that maps each attribute name with its corresponding CSS selector (similar to how `attributes` works in its simpler version).

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'scrap_kit'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install scrap_kit

## Usage

`ScrapKit::Recipe.load` can take an object with the recipe, or load a JSON file.

```ruby
recipe = ScrapKit::Recipe.load(
  url: "https://status.heroku.com/",
  attributes: {
    apps: ".subnav__inner .status-summary:nth-child(1) > .status-summary__description",
    data: ".subnav__inner .status-summary:nth-child(2) > .status-summary__description",
    tools: ".subnav__inner .status-summary:nth-child(3) > .status-summary__description",
  }
)

output = recipe.run
#=> {:apps=>"ok", :data=>"ok", :tools=>"ok"}
```

For more complex structures it's recommended to store the recipe in a JSON file:

```ruby
recipe = ScrapKit::Recipe.load("./spec/fixtures/file.json")

output = recipe.run
#=> {:posts=>[{:title=>"APIs de Internacionalización en JavaScript"}, {:title=>"Ejecutando comandos desde Ruby"}, {:title=>"Usando Higher-Order Components"}]}
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/hpneo/scrap_kit. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the ScrapKit project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/hpneo/scrap_kit/blob/master/CODE_OF_CONDUCT.md).
