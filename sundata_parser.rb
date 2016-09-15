#!/usr/bin/env ruby

require_relative "sammy"

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
    input_data.each do |filename, data|
      site = Sammy.site_from_filename filename
      year = Sammy.year_from_filename filename
      line_data = { "site" => site, "year" => year }

      arrived_at_table_data = false

      data.split("\r\n").each do |line|
        line_data = line_data.dup
        next if line.strip.empty? # Skip blank and whitespace lines

        if !arrived_at_table_data
          next if line =~ /\ACreated by SunData/ # Skip created by line
          if date_match = line.match(/\A(\d\d\d\d-\d\d-\d\d)\t\tLocal time is (GMT.\d+ Hrs)/)
            line_data["date"] = date_match[1]
            line_data["timezone"] = date_match[2]
          end

          if sunscan_match = line.match(/\ASunScan probe (v.*)/)
            line_data["sunscan version"] = sunscan_match[1]
          end

          if line[":"]
            line.split(":").map(&:strip).each_slice(2) do |key, value|
              next if value.nil? || value.empty?
              line_data[key.downcase] = value
            end
          end

          if line =~ /\ATime\tPlot\t/ # Skip table header line.
            arrived_at_table_data = true
            next
          end

          # Once we hit the table hearder we can start processing tabular data.
          arrived_at_table_data = true and next if line =~ /\ATime\tPlot\t/ # Skip table header line.
        else
          table_line = line.split("\t")
          line_data["time"] = table_line[0]
          line_data["plot"] = table_line[1]
          line_data["sample"] = table_line[2]
          line_data["transmitted"] = table_line[3]
          line_data["spread"] = table_line[4]
          line_data["incident"] = table_line[5]
          line_data["beam"] = table_line[6]
          line_data["zenith angle"] = table_line[7]
          line_data["lai"] = table_line[8]
          line_data["notes"] = table_line[9]
          # Only record output data once the full line data has been captured.
          output_data << line_data
        end
      end
    end
  end

  def write_csv filename
    File.write(filename, input_data)
  end
end
