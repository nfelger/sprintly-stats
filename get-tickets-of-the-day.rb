#!/usr/bin/env ruby

require 'open-uri'
require 'json'
require 'sequel'

DB = Sequel.sqlite('items.db')
DB.create_table?(:items) do
  String :day
  Integer :item_id
  String :status
  String :size
  String :item_type
  String :tags
end
db = DB[:items]

key  = ENV['SPRINTLY_API_KEY']
user = ENV['SPRINTLY_USER']
product = ENV['SPRINTLY_PRODUCT_ID']

offset = 0
limit  = 100
items  = []
previous_size = -1
while (previous_size != items.size)
  previous_size = items.size
  cmd = "curl -s -u #{user}:#{key} 'https://sprint.ly/api/products/#{product}/items.json?status=backlog,in-progress,completed,accepted&limit=#{limit}&offset=#{offset}'"
  puts cmd
  response = `#{cmd}`
  items += JSON.parse(response)
  offset += limit
end

items.each do |item|
  day       = Date.today.iso8601
  item_id   = item['number']
  status    = item['status']
  size      = item['score']
  item_type = item['type']
  tags      = item['tags'].to_json

  unless db.where(:day => day, :item_id => item_id).any?
    db.insert(:day => day, :item_id => item_id, :status => status, :item_type => item_type)
  end

  # Always update size and tags.
  db.where(:item_id => item_id).update(:size => size, :tags => tags)
end
