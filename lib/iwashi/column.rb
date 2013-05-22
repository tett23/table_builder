# coding: utf-8

module Iwashi
  class Column
    def initialize(column_name, name, options={})
      default = {
        sortable: false,
        sort_column: nil,
        header: false
      }
      default[:sort_column] = column_name if !column_name.nil? && options[:sortable]

      @options = default.merge(options)
      @column_name = column_name
      @name = name
      @children = []
    end
    attr_reader :column_name, :name, :options
    attr_accessor :children

    def keys
      if has_children?
        [@column_name] + @children.map do |child|
          child.keys
        end.flatten.compact
      else
        [@column_name]
      end
    end

    def push(*children)
      children.each do |child|
        @children << child
      end
    end
    alias_method :<<, :push

    def require_row_size
      return 1 unless has_children?

      children_chain_count()
    end

    def has_children?
      not @children.size.zero?
    end

    def children_chain_count
      counter = 1

      counter += @children.map do |child|
        child.has_children? ? child.children_chain_count() : 1
      end.max

      counter
    end

    def colsize
      return 1 if @children.size.zero?

      @children.map do |column|
        column.colsize()
      end.inject(0){|result, count| result + count}
    end

    def to_html(options={})
      default = {
        rowsize: 1
      }
      options = default.merge(options)

erubis = <<ERB
<th colspan="<%=column.colsize%>" rowspan="<%=(options[:rowsize] - column.require_row_size+1).abs%>">
  <%if column.options[:sortable]%>
    <%
      params = options[:search_params]
      params[:sort_by] = column.options[:sort_column]

      if options[:sort_by].nil?
        params[:sort_order] = :asc
      elsif options[:sort_by].to_sym == column.options[:sort_column] && options[:sort_order] == 'asc'
        params[:sort_order] = :desc
      else
        params[:sort_order] = :asc
      end
    %>

    <a href="?<%=params.to_query%>" style="color: white"><%=column.name%></a>
  <%else%>
    <%=column.name%>
  <%end%>
</th>
ERB
      Erubis::Eruby.new(erubis).result(column: self, options: options)
    end
  end
end
