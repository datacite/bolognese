# modified from https://gist.github.com/ivan-kolmychek/ee2fdc53f3e2c637271d

module Bolognese
  class WhitelistScrubber < Loofah::Scrubber
    def initialize(options={})
      @direction = :bottom_up
      @tags = options[:tags]
      @attributes = options[:attributes]
    end

    def scrub(node)
      scrub_node_attributes(node) and return CONTINUE if node_allowed?(node)
      node.before node.children
      node.remove
    end

    private

    def scrub_node_attributes(node)
      fallback_scrub_node_attributes(node) and return true unless @attributes.present? && @attributes.respond_to?(:include?)
      node.attribute_nodes.each do |attr_node|
        attr_node.remove unless @attributes.include?(attr_node.name)
      end
    end

    def allowed_not_element_node_types
      [ Nokogiri::XML::Node::TEXT_NODE, Nokogiri::XML::Node::CDATA_SECTION_NODE ]
    end

    def fallback_scrub_node_attributes(node)
      Loofah::HTML5::Scrub.scrub_attributes(node)
    end

    def fallback_allowed_element_detection(node)
      Loofah::HTML5::Scrub.allowed_element?(node.name)
    end

    def node_allowed?(node)
      return fallback_allowed_element_detection(node) unless @tags.present? && @tags.respond_to?(:include?)
      return true if allowed_not_element_node_types.include?(node.type)
      return false unless node.type == Nokogiri::XML::Node::ELEMENT_NODE
      @tags.include? node.name
    end
  end
end
