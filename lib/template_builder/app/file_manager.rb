module TemplateBuilder::App
  class FileManager 
    
    Error = Class.new(StandardError)

    attr_accessor :file, :verbose, :file_name
    alias :verbose? :verbose

    def initialize( opts = {} )
      self.file_name = opts[:file]
      self.verbose = opts[:verbose]
            
      self.file = File.new(self.file_name,  "w+")
              
      @out = opts[:stdout] || $stdout
      @err = opts[:stderr] || $stderr
    end
    
    def write(content)
      self.file.write content+"\n"
    end
    
    def write_gem (gem)
      write "gem "+gem
    end
    
  end
end