require "active_support/core_ext/hash"
require "webdrivers/chromedriver"
require "watir"

module ScrapKit
  class Recipe
    attr_accessor :user_agent

    class << self
      def load(source)
        input = if source.is_a?(Hash)
          source
        elsif source.is_a?(IO)
          JSON.parse(source.read)
        else
          JSON.parse(File.read(source))
        end

        new(input.deep_symbolize_keys)
      end
    end

    def initialize(url: nil, steps: [], attributes: {})
      @url = url
      @steps = steps
      @attributes = attributes
    end

    def run
      output = {}

      @browser = create_browser
      @browser.goto @url

      @steps.each do |step|
        run_step(step)
      end

      @attributes.each do |attribute_name, selector|
        output[attribute_name] = extract_attribute(@browser, selector)
      end

      @browser.close
      @browser = nil

      output
    end

    def run_step(step)
      return goto(step[:goto]) if step[:goto]
      return click(step[:click]) if step[:click]
      return fill_form(step[:fill_form]) if step[:fill_form]

      nil
    end

    def find_element_by_name_or_selector(browser_or_element, name_or_selector)
      element = browser_or_element.element(name: name_or_selector.to_s)
      return element if element.exists?

      element = browser_or_element.element(css: name_or_selector.to_s)
      return element if element.exists?

      nil
    end

    def elements_from_selector(browser_or_element, selector)
      if selector.is_a?(String)
        browser_or_element.elements(css: selector)
      elsif selector.is_a?(Hash)
        browser_or_element.elements(selector)
      elsif selector.is_a?(Array)
        *remainder, condition = selector
        condition_key, condition_value = condition.first
        elements = browser_or_element

        if remainder.empty?
          elements = elements.elements(css: condition_key.to_s)
        else
          remainder.each do |item|
            elements = elements.elements(css: item)
          end
        end

        elements.filter do |element|
          found_element = element.element(css: condition_key.to_s)
          extracted_value = extract_value_from_element(found_element)
          extracted_value.match(condition_value) || extracted_value == condition_value
        end
      end
    end

    def extract_value_from_element(element)
      if element&.respond_to?(:tag_name)
        if element.tag_name.downcase == "input"
          return element.attribute_value(:value)
        end
      end

      element&.text_content
    end

    def extract_attribute(browser_or_element, selector_or_object)
      if selector_or_object.is_a?(String)
        extract_value_from_element(browser_or_element.element(css: selector_or_object))
      elsif selector_or_object.is_a?(Array)
        found_elements = elements_from_selector(browser_or_element, selector_or_object)

        if found_elements.size === 1
          extract_value_from_element(found_elements.first)
        else
          found_elements.map do |element|
            extract_value_from_element(element)
          end
        end
      elsif selector_or_object.is_a?(Hash)
        if selector_or_object[:selector] && selector_or_object[:children_attributes]
          selector = selector_or_object[:selector]
          selector_for_children_attributes = selector_or_object[:children_attributes]

          elements_from_selector(browser_or_element, selector).map do |element|
            output = {}

            selector_for_children_attributes.each do |child_attribute_name, child_selector|
              output[child_attribute_name] = extract_attribute(element, child_selector)
            end

            output
          end
        elsif selector_or_object[:javascript]
          @browser.execute_script(selector_or_object[:javascript])
        else
          found_elements = elements_from_selector(browser_or_element, selector_or_object)

          if found_elements.size === 1
            extract_value_from_element(found_elements.first)
          else
            found_elements.map do |element|
              extract_value_from_element(element)
            end
          end
        end
      end
    rescue
      nil
    end

    private

    def goto(link_or_selector)
      if link_or_selector.is_a?(String)
        @browser.goto(link_or_selector)
      elsif link_or_selector.is_a?(Array) || link_or_selector.is_a?(Hash)
        if found_element = elements_from_selector(@browser, link_or_selector).first
          found_element.click
        end
      end

      sleep 0.5
      @browser.wait_until do
        @browser.ready_state == "complete"
      end
    rescue
      nil
    end

    def click(selector)
      if selector.is_a?(Array) || selector.is_a?(Hash)
        if found_element = elements_from_selector(@browser, selector).first
          found_element.click
        end
      end

      sleep 1
      @browser.wait_until do
        @browser.ready_state == "complete"
      end

    rescue
      nil
    end

    def fill_form(form_data)
      form_data.each do |name, value|
        if element = find_element_by_name_or_selector(@browser.body, name.to_s)
          element = element.to_subtype

          if element.respond_to?(:set)
            element.set(value)
          elsif element.respond_to?(:select)
            element.select(value)
          end
        end
      end

      sleep 0.25
      @browser.wait_until do
        @browser.ready_state == "complete"
      end
    end

    def create_browser
      options = Selenium::WebDriver::Chrome::Options.new

      options.add_argument "--headless"
      options.add_argument "--window-size=1080x720"
      options.add_argument "--hide-scrollbars"
      options.add_argument "--user-agent=#{@user_agent}" if @user_agent

      if chrome_bin = ENV["GOOGLE_CHROME_SHIM"]
        options.add_argument "--no-sandbox"
        options.binary = chrome_bin
      end

      Watir::Browser.new(:chrome, options: options)
    end
  end
end
