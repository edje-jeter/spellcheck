module Word
  class FileReader
    attr_reader :line_idx

    def initialize(file_path)
      @file = ::File.open(file_path, "r")
      @enumerator = @file.each_line.lazy
      @line_idx = 0
    end

    def next_line # returns the next non-nil line
      line = @enumerator.next.chomp
      @line_idx += 1
      return next_line if line.empty?

      line
    rescue ::StopIteration
      @file.close
      nil
    end

    def close
      @file.close unless @file.closed?
    end
  end
end
