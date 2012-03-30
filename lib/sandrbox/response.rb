module Sandrbox
  class Response
    attr_accessor :array, :compressed_array, :expanded_array, :indents, :results, :old_constants
    attr_accessor :class_count, :module_count, :def_count, :end_count, :do_count, :left_curly_count, :right_curly_count, :left_bracket_count, :right_bracket_count
    
    def initialize(array)
      self.array = array
      [:expanded_array, :compressed_array, :indents, :results].each do |arr|
        self.send("#{arr}=".to_sym, [])
      end
      [:class, :module, :def, :end, :do, :left_curly, :right_curly, :left_bracket, :right_bracket].each do |count|
        self.send("#{count}_count=".to_sym, 0)
      end
      expand
      compress
    end
    
    def expand
      self.array.each do |line| 
        next if line.empty?
        self.expanded_array << uncomment(line).split(';').collect(&:strip)
      end
      self.expanded_array.flatten!
    end
    
    def compress
      self.expanded_array.each do |line|
        uncommented_line = uncomment(line)
        ending = nil
        
        [:class, :module, :def, :end, :do].each do |count|
          if uncommented_line =~ /\s*#{count.to_s}\s*/
            self.send("#{count}_count=".to_sym, self.send("#{count}_count".to_sym) + 1) 
            self.indents.push(count.to_s) unless count == :end
            ending = self.indents.pop if count == :end
          end
        end
        
        {:left_curly => ['{', '}'], :right_curly => ['}', '{'], :left_bracket => ['[', ']'], :right_bracket => [']', '[']}.each do |name, sym|
          if uncommented_line.count(sym.first) > uncommented_line.count(sym.last)
            self.send("#{name}_count=".to_sym, self.send("#{name}_count".to_sym) + 1) 
            self.indents.push(sym.first) if name.to_s.include?('left')
            ending = self.indents.pop if name.to_s.include?('right')
          end
        end
        
        if ending
          self.compressed_array.last << "#{uncommented_line}#{semicolon(ending)}"
        elsif indent_level == 1 || self.compressed_array.empty?
          self.compressed_array << "#{uncommented_line}#{semicolon}"
        elsif indent_level > 1
          self.compressed_array.last << "#{uncommented_line}#{semicolon}"
        else
          self.compressed_array << uncommented_line
        end
      end
      
      return evaluate if complete?
    end
    
    def evaluate
      preserve_namespace
      self.compressed_array.each_with_index {|line, line_no| self.results << Sandrbox::Value.new(line, line_no)}
      restore_namespace
    end
    
    def semicolon(char = nil)
      char ||= indent_character
      (char == '{' || char == '[') ? '' : ';'
    end
    
    def uncomment(line)
      line.split('#').first.strip
    end
    
    def indent_level
      self.indents.count
    end
    
    def indent_character
      self.indents.last
    end
    
    def complete?
      self.indents.empty?
    end
    
    def output
      results.collect(&:to_s)
    end
    
    def preserve_namespace
      self.old_constants = Object.constants
    end
    
    def restore_namespace
      (Object.constants - self.old_constants).each {|bad_constant| Object.send(:remove_const, bad_constant)}
    end

  end
end