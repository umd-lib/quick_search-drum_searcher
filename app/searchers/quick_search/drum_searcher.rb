# frozen_string_literal: true

require 'uri'
require 'nokogiri'

module QuickSearch
  # QuickSearch seacher for DrUM
  class DRUMSearcher < QuickSearch::Searcher
    def search
      @response = @http.get(uri, follow_redirect: true)
      @results = Nokogiri::XML response.body
      @total = total
    end

    def results
      return @results_list if @results_list
      @results_list = @results.xpath('//xmlns:entry').map do |entry|
        OpenStruct.new(
          link: get_hyperlink(entry),
          title: get_title(entry),
          description: get_description(entry)
        )
      end
      @results_list
    end

    def total
      return '' unless @results.is_a? Nokogiri::XML::Document

      node = @results.at('//opensearch:titleResults')
      node ? node.text : ''
    end

    def loaded_link
      base = URI.parse QuickSearch::Engine::DRUM_CONFIG['native_url']
      base.query = Rack::Utils.parse_nested_query(uri.query)
                              .reject { |k| k == 'rpp' }
                              .to_query
      base.to_s
    end

    private

      def host
        QuickSearch::Engine::DRUM_CONFIG['search_url']
      end

      def uri
        base = URI.parse host
        search_term = http_request_queries['uri_escaped'] || ''
        base.query = base_query_params.merge('query' => search_term).to_query
        base
      end

      def base_query_params
        QuickSearch::Engine::DRUM_CONFIG['query_params']
      end

      # Returns the hyperlink to use
      def get_hyperlink(entry)
        node = entry.at('./xmlns:link')
        node ? node['href'] : ''
      end

      # Returns the string to use for the result title
      def get_title(entry)
        node = entry.at('./xmlns:title')
        node ? node.text : ''
      end

      # Returns the string to use for the result description
      def get_description(entry)
        desc = entry.at('./xmlns:summary')
        desc = desc ? desc.text : ''
        content_tag(:div,
                    content_tag(:p, desc),
                    class: ['block-with-text'])
      end
  end
end
