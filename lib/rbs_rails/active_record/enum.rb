module RbsRails
  module ActiveRecord
    class Enum
      attr_reader :ast

      ENUM_OPTIONS = %i[_prefix _suffix _default _scopes]

      def initialize(ast)
        @ast = ast
      end

      def methods
        definitions.flat_map do |name, values, options|
          values.keys.map do |label|
            method_name(options, name, label)
          end
        end.compact
      end

      private def method_name(hash, name, label)
        enum_prefix = hash[:_prefix]
        enum_suffix = hash[:_suffix]

        if enum_prefix == true
          prefix = "#{name}_"
        elsif enum_prefix
          prefix = "#{enum_prefix}_"
        end
        if enum_suffix == true
          suffix = "_#{name}"
        elsif enum_suffix
          suffix = "_#{enum_suffix}"
        end

        "#{prefix}#{label}#{suffix}"
      end

      # We need static analysis to detect enum.
      # ActiveRecord has `defined_enums` method,
      # but it does not contain _prefix and _suffix information.
      private def definitions
        return [] unless ast

        traverse(ast).flat_map do |node|
          # @type block: nil | Array[Array[[untyped, untyped, untyped]]]
          next unless node.type == :send
          next unless node.children[0].nil?
          next unless node.children[1] == :enum

          definitions = node.children[2]
          next unless definitions
          next unless definitions.type == :hash
          next unless traverse(definitions).all? { |n| [:str, :sym, :int, :hash, :pair, :true, :false].include?(n.type) }

          enums = evaluate(definitions)
          options = enums.select { |k, _| ENUM_OPTIONS.include?(k) }
          enums.reject { |k, _| ENUM_OPTIONS.include?(k) }.map { |k, v| [k, v, options] }
        end.compact
      end

      private def traverse(node, &block)
        return to_enum(__method__ || raise, node) unless block

        block.call node
        node.children.each do |child|
          traverse(child, &block) if child.is_a?(Parser::AST::Node)
        end
      end

      private def evaluate(node)
        case node.type
        when :int, :str, :sym
          node.children.first
        when :true
          true
        when :false
          false
        when :hash
          node.children.to_h { |child| evaluate(child) }
        when :pair
          node.children.map { |child| evaluate(child) }
        else
          node
        end
      end
    end
  end
end
