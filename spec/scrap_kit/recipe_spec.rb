RSpec.describe ScrapKit::Recipe do
  it "Load recipe from a hash" do
    recipe = ScrapKit::Recipe.load(
      url: "https://status.heroku.com/",
      attributes: {
        apps: ".subnav__inner .ember-view:nth-child(1) > .status-summary__description",
        data: ".subnav__inner .ember-view:nth-child(2) > .status-summary__description",
        tools: ".subnav__inner .ember-view:nth-child(3) > .status-summary__description",
      }
    )
    output = recipe.run

    expect(output).to eq(apps: "ok", data: "ok", tools: "ok")
  end

  it "Load recipe from JSON file" do
    recipe = ScrapKit::Recipe.load("./spec/fixtures/file.json")
    output = recipe.run

    expect(output[:posts]).to include(
      { title: "Creando bookmarks de CodeMirror con Preact" },
      { title: "Estructuras de datos para React" }
    )
  end

  it "Load recipe with selector array" do
    recipe = ScrapKit::Recipe.load(
      url: "https://status.heroku.com/",
      attributes: {
        results: {
          selector: [".up-time-chart", { ".region-header .u-margin-Tm": "REGION" }],
          children_attributes: {
            region: "h4:first-child",
            uptime: "h4:last-child"
          }
        }
      }
    )

    output = recipe.run

    expect(output[:results].map { |result| result[:region] }).to eq(["US REGION", "EU REGION"])
  end
end
