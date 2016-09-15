module Sammy
  def self.site_from_filename filename
    if File.basename(filename) =~ /\Asam/
      match = File.basename(filename).match(/\Asam(?: ?(\d+[a-z]?)|_(tnc_\d+))/)
      if match.nil?
        STDERR.puts "Unable to glean site from filename #{filename}."
        exit(1)
      end
      site = match[1] || match[2]
      site.sub(/\A0/,"").gsub("_", " ")
    else
      match = File.basename(filename).match(/(?:\Asite (\d+[a-z]?)|(\Atnc \d+))/)
      if match.nil?
        STDERR.puts "Unable to glean site from filename #{filename}."
        exit(1)
      end
      site = match[1] || match[2]
      site.sub(/\A0/,"").gsub("_", " ")
    end
  end

  def self.year_from_filename filename
    if File.basename(filename) =~ /\Asam/
      year = "2011"
    else
      match = File.basename(filename).match(/\A(?:site|tnc) \d+[a-z] (\d\d\d\d)/)
      if match.nil?
        STDERR.puts "Unable to glean year from filename #{filename}."
        exit(1)
      end
      year = match[1]
    end
  end
end

