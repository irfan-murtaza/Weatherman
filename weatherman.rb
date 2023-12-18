require 'csv'
require 'colorize'

class Years
  def initialize(year_to_find)
    @year_to_find = year_to_find
    @temperature = {}
    @humidity = {}
  end

  def append_values(temperatures)
    temperatures.each do |data|
      next if data == temperatures.first || data == temperatures.last || data[0] == 'PKT'

      min_temp = data[3].to_i
      min_temp = -1 if data[3].nil?
      temp_temperature = [data[1].to_i, data[2].to_i, min_temp]
      temp_humidity = [data[7].to_i, data[8].to_i, data[9].to_i]
      @temperature[Date.parse(data[0])] = temp_temperature
      @humidity[Date.parse(data[0])] = temp_humidity
    end
  end

  def largest_temperature
    @temperature.max_by { |_k, v| v[0] }
  end

  def minimum_temperature
    @temperature.delete_if { |_key, value| value[2].negative? }
    @temperature.min_by { |_k, v| v[2] }
  end

  def largest_humidity
    @humidity.max_by { |_k, v| v[0] }
  end

  def max_avg_temp_in_a_month(given_month)
    data_hash = get_month(given_month)
    avg = 0
    data_hash.each { |_k, v| avg += v[0] }
    avg = avg.to_f / data_hash.keys.length
  end

  def min_avg_temp_in_a_month(given_month)
    data_hash = get_month(given_month)
    avg = 0
    data_hash.each { |_k, v| avg += v[2] }
    avg = avg.to_f / data_hash.keys.length
  end

  def avg_humidity(given_month)
    avg = 0
    data_hash = @humidity.select { |k, _v| k.month == given_month }
    data_hash.each { |_k, v| avg += v[1] }
    avg = avg.to_f / data_hash.keys.length
  end

  def horizontal_bar_chart(given_month)
    temp_data_hash = get_month(given_month)
    temp_data_hash.each do |k, v|
      print "#{k.day}: " 
      v[0].times { print '+'.red }
      print " #{v[0]}C\n"

      print "#{k.day}: "
      v[2].times { print '+'.blue }
      print " #{v[2]}C\n"
    end
  end

  def printt
    puts @temperature.size
    puts @humidity.size
  end

  private

  def get_month(given_month)
    @temperature.select { |k, _v| k.month == given_month.to_i }
  end
end

months = ['Jan.', 'Feb.', 'Mar.', 'Apr.', 'May.', 'Jun.', 'Jul.', 'Aug.', 'Sep.', 'Oct.', 'Nov.', 'Dec.']
array = ARGV[2].split('/')
path = '.'
array.each { |x| path += x + '/' }
path += array.last + '_'
array = ARGV[1].split('/')
path += array[0] + '_'
my_year_class_object = Years.new(array[0].to_i)
months.each do |month|
  file_data = CSV.read(path + month + 'txt')
  my_year_class_object.append_values(file_data)
end

if ARGV[0] == '-a'
  puts "Highest: #{my_year_class_object.largest_temperature[1][0]}C on #{months[my_year_class_object.largest_temperature[0].month-1]} #{my_year_class_object.largest_temperature[0].day}"
  puts "Lowest: #{my_year_class_object.minimum_temperature[1][2]}C on #{months[my_year_class_object.minimum_temperature[0].month-1]} #{my_year_class_object.minimum_temperature[0].day}"
  puts "Humid: #{my_year_class_object.largest_humidity[1][0]}% on #{months[my_year_class_object.largest_humidity[0].month-1]} #{my_year_class_object.largest_humidity[0].day}"
elsif ARGV[0] == '-e'
  puts "Highest Average: #{my_year_class_object.max_avg_temp_in_a_month(array[1].to_i).to_i}C"
  puts "Lowest Average: #{my_year_class_object.min_avg_temp_in_a_month(array[1].to_i).to_i}C"
  puts "Average Humidity: #{my_year_class_object.avg_humidity(array[1].to_i).to_i}%"
else
  my_year_class_object.horizontal_bar_chart(array[1].to_i)
end