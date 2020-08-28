require "active_support/core_ext/hash"
require "webdrivers/chromedriver"
require "watir"

module ScrapKit
  class Recipe
    def initialize(url: nil, steps: [], attributes: {})
      @url = url
      @steps = steps
      @attributes = attributes
    end

    def run
      output = {}

      browser = Watir::Browser.new(:chrome, headless: true)
      browser.goto @url

      @steps.each do |step|
        run_step(browser, step)
      end

      @attributes.each do |attribute_name, selector|
        output[attribute_name] = extract_attribute(browser, selector)
      end

      browser.close
      browser = nil

      output
    end

    def run_step(browser, step)
    end

    def elements_from_selector(browser_or_element, selector)
      if selector.is_a?(String)
        browser_or_element.elements(css: selector)
      elsif selector.is_a?(Array)
        *remainder, condition = selector
        elements = browser_or_element

        remainder.each do |item|
          elements = elements.elements(css: item)
        end

        elements.filter do |element|
          condition_key = condition.keys.first.to_s
          condition_value = condition.values.first
          found_element = element.element(css: condition_key)
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

    def extract_attribute(browser_or_element, selector_or_hash)
      if selector_or_hash.is_a?(String)
        extract_value_from_element(browser_or_element.element(css: selector_or_hash))
      elsif selector_or_hash.is_a?(Hash)
        selector = selector_or_hash[:selector]
        selector_for_children_attributes = selector_or_hash[:children_attributes]

        elements_from_selector(browser_or_element, selector).map do |element|
          output = {}

          selector_for_children_attributes.each do |child_attribute_name, child_selector|
            output[child_attribute_name] = extract_attribute(element, child_selector)
          end

          output
        end
      end
    end

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
  end
end
