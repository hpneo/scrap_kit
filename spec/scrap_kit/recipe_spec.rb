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

    expect(output).to eq(
      posts: [
        { title: "Usando OpenStruct" },
        { title: "Aprendiendo a usar arrays en JavaScript" },
        { title: "APIs de Internacionalización en JavaScript" },
        { title: "Ejecutando comandos desde Ruby" },
        { title: "Usando Higher-Order Components" }
      ]
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

    expect(output).to eq(
      results: [
        { region: "US REGION", uptime: "99.999709%" },
        { region: "EU REGION", uptime: "99.999994%" }
      ]
    )
  end
end
