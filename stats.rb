#!/usr/bin/env ruby

require 'sequel'

SIZES = {
  '~' => 0,
  'S' => 1,
  'M' => 2,
  'L' => 4,
  'XL' => 8
}

db = Sequel.sqlite('items.db')[:items]

items_by_day = {}

db.all.each do |item|
  items_by_day[item[:day]] ||= Hash.new(0)
  items_by_day[item[:day]][item[:status]] += SIZES[item[:size]]
end

items_by_day.keys.sort.each do |key|
  p [key, items_by_day[key]]
end