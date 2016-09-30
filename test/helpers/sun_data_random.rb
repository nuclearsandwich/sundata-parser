#!/usr/bin/env ruby
require "time"

# Generate bogus data to use in tests.  If you have sunscan data that you would
# like to submit in place of this faked data Send an email to
# <steven@nuclearsandwich.com>

class SunDataRandom
  attr_accessor :title, :timezone, :location, :latitude, :longitude, :date,
    :leaf_absorption, :leaf_angle_distance_parameter, :ext_sensor, :times,
    :plots_and_samples, :incident_transmitted_light, :spread, :beam_fraction,
    :zenith_angle, :leaf_area_index

  def initialize table_rows
    @date = Date.today.iso8601
    @timezone = Time.now.gmt_offset / 3600
    @table_rows = table_rows
    @location = "Fictional"
    @title = "Sample Sunscan Data"
    @leaf_absorption = 0.85
    @leaf_angle_distance_parameter = 1
    @ext_sensor = "BFS"
    @latitude, @longitude = random_lat_long
    @times = random_times
    @plots_and_samples = random_plots_and_samples
    @incident_transmitted_light = random_incident_transmitted_light
    @spread = random_spread
    @beam_fraction = random_beam_fraction
    @zenith_angle = random_zenith_angle
    @leaf_area_index = random_leaf_area_index
  end

  def random_lat_long
    longitude = "#{Random.rand(180.0).round(2)}#{["W", "E"].sample}"
    latitude = "#{Random.rand(90.0).round(2)}#{["N", "S"].sample}"

    [latitude, longitude]
  end

  def random_times
    Array.new.tap do |times|
      @table_rows.times do
        hour = (10..12).to_a.sample
        minute = (0..59).to_a.sample
        second = (0..59).to_a.sample
        times << "%02d:%02d:%02d" % [ hour, minute, second ]
      end
    end.sort!
  end

  def random_plots_and_samples
    Array.new.tap do |plots_and_samples|
      plot = 0
      sample = 0
      @table_rows.times do |i|
        if i % 3 == 0
          plot = plot + 10
          sample = 1
        else
          sample = sample + 1
        end

        plots_and_samples << [plot, sample]
      end
    end
  end

  def random_incident_transmitted_light
    Array.new.tap do |incident_transmitted_light|
      base_incident = (Random.rand(800.0) + 1550)
      @table_rows.times do
        incident = (base_incident + Random.rand(-250.0..250.0)).round(1)
        transmitted = (incident * Random.rand).round(1)
        incident_transmitted_light << [incident, transmitted]
      end
    end
  end

  def random_spread
    Array.new.tap do |spread|
      @table_rows.times do
        spread << "%1.2f" % Random.rand(1.4).round(2)
      end
    end
  end

  def random_beam_fraction
    Array.new.tap do |beam_fraction|
      @table_rows.times do
        beam_fraction << "%1.2f" % Random.rand
      end
    end
  end

  def random_zenith_angle
    Array.new.tap do |zenith_angle|
      @table_rows.times do
        zenith_angle << Random.rand(160.0..170.0).round(1)
      end
    end
  end

  def random_leaf_area_index
    Array.new.tap do |leaf_area_index|
      @table_rows.times do
        leaf_area_index << "%1.1f" % Random.rand(0.0..5.0)
      end
    end
  end

  def output
    header = <<TEMPLATE
Created by SunData for Windows Mobile v2.0.0.1

Title     :	#{title}
Location  :	#{location}
Latitude  :	#{latitude}	Longitude :	#{longitude}
#{date}		Local time is GMT#{timezone} Hrs
SunScan probe v1.02R (C) JGW 2004/01/19

Ext Sensor: #{ext_sensor}		  Leaf Angle Distn Parameter:				#{leaf_angle_distance_parameter}	  Leaf Absorption:		#{leaf_absorption}
Group   1 :	

Time	Plot	Sample	Trans-	Spread	Incid-	Beam	Zenith	LAI	Notes
      mitted		 ent	frac	Angle

TEMPLATE

    @table_rows.times do |i|
      begin
        header << [times[i], plots_and_samples[i][0], plots_and_samples[i][1], incident_transmitted_light[i][1], spread[i],
                 incident_transmitted_light[i][0], beam_fraction[i], zenith_angle[i], leaf_area_index[i]].join("\t") + "\n"
      rescue
        binding.pry
      end
    end

    header.gsub(/\n/, "\r\n")
  end
end

