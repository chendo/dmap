require 'dmap/node'
module DMAP
  class Parser
  
    def parse(data)
      tag, length = data.unpack('a4N')
      data[0...8] = ''
      Node.new(tag, data)
    end
    
  end
end