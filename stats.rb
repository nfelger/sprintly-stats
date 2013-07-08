#!/usr/bin/env ruby

require 'sequel'
require 'json'

SIZES = {
  '~' => 0,
  'S' => 1,
  'M' => 2,
  'L' => 4,
  'XL' => 8
}

tag = ARGV[0]

db = Sequel.sqlite('items.db')[:items]

items_by_day = {}

db.all.each do |item|
  next if tag && JSON.parse(item[:tags]).include?(tag)
  items_by_day[item[:day]] ||= Hash.new(0)
  items_by_day[item[:day]][item[:status]] += SIZES[item[:size]]
end

items_by_day.keys.sort.each do |key|
  p [key, Hash[items_by_day[key].sort]]
end