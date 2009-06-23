module DMAP
  class Node
    
    class << self
      def tags
        @tags = begin
          data = {}
          DMAP::TAGS.each do |k, v|
            data[k] = {:name => v.first, :type => v.last}
          end
          data
        end
      end
      
    end
    
    attr_accessor :tag, :name, :length, :type, :children, :value, :data
    def initialize(tag = nil, data = nil)
      @tag = tag
      tag_info = tags[tag.to_sym]
      if tag_info.nil?
        raise "Could not find tag definition for #{tag}. data: #{data.inspect}"
      end
      @name = tag_info[:name]
      @type = tag_info[:type]
      @data = data

      
      if data
        if @type != :container
          @value = data.unpack(DMAP::UNPACK_MAP[tag_info[:type]]).first
        else
          parse(data)
        end
      end
    end
    
    def [](tag)
      ret = children.select { |n| n.tag.to_sym == tag.to_sym }
      ret.size > 1 ? ret : ret.first
    end
    
    def parse(buffer)
      @children = []
      buffer = StringIO.new(buffer)
      while !buffer.eof?
        tag, length = buffer.read(8).unpack('a4N')
        node = self.class.new(tag, buffer.read(length))
        @children << node
      end
    end
    
    def children
      @children || []
    end
    
    
    def to_s(level = 0)
      begin
        out = "#{" " * level * 2}#{@tag}:#{@name}"
        if children.length > 0
          out += "\n" + children.map { |c| c.to_s(level + 1) }.join("\n")
        else
          out += " - #{@value} #{@data.inspect}"
        end
        out
      end
    end
    
    
    private
      def tags
        self.class.tags
      end
      
    
  end
end