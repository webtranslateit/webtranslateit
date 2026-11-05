# frozen_string_literal: true

module WebTranslateIt

  # Checks the `project_id` of a configuration file as written. YAML turns `012` or `0x1F`
  # into a different Integer, which can no longer be told from a plain id, so the value is
  # read from the parse tree instead: every spelling of the key (`project_id :`,
  # `"project_id":`) is seen, and the last one wins when the key is repeated, as it does
  # for YAML.safe_load.
  module ProjectIdText

    NULLS = %w[~ null Null NULL].freeze

    def self.validate!(yaml_text)
      node = node_for(yaml_text)
      return if node.nil? || null?(node)
      return if node.is_a?(Psych::Nodes::Scalar) && node.value.strip.match?(/\A[1-9]\d*\z/)

      raw = node.is_a?(Psych::Nodes::Scalar) ? node.value.strip : node.class.name.split('::').last.downcase
      raise ArgumentError, "Error: project_id must be the numeric id of your project (digits only, no leading zero), got `#{raw}`."
    end

    def self.node_for(yaml_text)
      root = YAML.parse(yaml_text)&.root
      return unless root.is_a?(Psych::Nodes::Mapping)

      root.children.each_slice(2).reverse_each.find { |key, _| key.is_a?(Psych::Nodes::Scalar) && key.value == 'project_id' }&.last
    end

    def self.null?(node)
      node.is_a?(Psych::Nodes::Scalar) && !node.quoted && (node.value.strip.empty? || NULLS.include?(node.value.strip))
    end

  end

end
