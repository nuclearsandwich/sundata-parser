#!/usr/bin/env ruby

class SundataParser
  attr_reader :input_files, :input_data, :output_data

  def initialize input_files
    @input_files = input_files
    @input_data = Hash.new
    @output_data = Array.new
  end

  def read
    @input_files.each do |file|
      if File.exist? file
        input_data[file] = File.read(file)
      end
    end
  end

  def parse
  end

  def write_csv filename
  end
end
