# coding: utf-8

module TableBuilder
  class Table
    def initialize(options={})
      default = {
        caption: nil,
        table_class: 'result_small',
        search_params: {},
        sort_by: nil,
        sort_order: :asc
      }
      @options = default.merge(options)
      @columns = []
      @data = []
    end
    attr_reader :options, :data
    attr_accessor :columns

    def add_column(*columns)
      columns.each do |column|
        @columns.push(column)
      end
    end

    def header_rowsize
      @columns.map do |column|
        column.require_row_size
      end.max
    end

    def sort_by_column(column_name, order=:asc)
      column_name = column_name.to_sym
      raise '未定義のTableBuilder::Column' unless keys.include?(column_name)

      @data.sort! do |a, b|
        next 1 if @ignore_sort.call(a)
        next -1 if @ignore_sort.call(b)
        next 1 if !a[column_name]
        next -1 if !b[column_name]

        sort_value_a = a[column_name]
        sort_value_b = b[column_name]

        # 数値っぽかったら勝手に変換する
        sort_value_a = sort_value_a.gsub(/,/, '').to_i if sort_value_a.match(/^[\d,]+$/)
        sort_value_b = sort_value_b.gsub(/,/, '').to_i if sort_value_b.match(/^[\d,]+$/)

        if order == :asc
          cmp = sort_value_a <=> sort_value_b
        else
          cmp = sort_value_b <=> sort_value_a
        end
      end
    end

    def to_html
  erubis = <<ERB
<table class="<%=table.options[:table_class]%>">
  <%unless table.options[:caption].blank?%>
    <caption><%=table.options[:caption]%></caption>
  <%end%>
  <tr>
    <%columns.each do |column|%>
      <%=column.to_html(rowsize: table.header_rowsize, search_params: table.options[:search_params], sort_by: table.options[:sort_by], sort_order: table.options[:sort_order])%>
    <%end%>
  </tr>
  <%columns.each do |column|%>
    <%if column.has_children?%>
      <%column.children.each do |child|%>
        <%=child.to_html%>
      <%end%>
    <%end%>
  <%end%>
  <%data.each do |datum|%>
    <tr>
      <%table.keys.each do |key|%>
        <%column = table.fetch(key)%>
        <%tagname = column.options[:header] ? 'th' : 'td'%>
        <<%=tagname%> class="<%=column.options[:class]%>" style="<%=column.options[:style]%>">
          <%=datum[key]%>
        </<%=tagname%>>
      <%end%>
    </tr>
  <%end%>
</table>
ERB

      Erubis::Eruby.new(erubis).result(columns: @columns, table: self, data: @data)
    end

    def fetch(key)
      columns = @columns.map do |column|
        [column] + column.children.map do |child|
          child
        end
      end.flatten

      columns.find do |column|
        column.column_name == key
      end
    end

    def keys
      @columns.map do |column|
        column.keys
      end.flatten.compact
    end

    def append_row(*row)
      row.flatten.each do |r|
        @data << r
      end
    end
    alias_method :<<, :append_row

    def ignore_sort(&b)
      @ignore_sort = b
    end
  end
end
