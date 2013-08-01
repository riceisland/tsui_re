# encoding: utf-8

require "sequel"
require "./model.rb"
require "MeCab"

#sequel使えるようにする
Sequel::Model.plugin(:schema)
Sequel.extension :pagination
Sequel.connect("sqlite://user.db")

#modes = ["proverbs", "wisdom"]

#modes.each do |mode| 

filename = "proverbs.txt"

file = open(filename)

file.each do |record|
  record.chomp!
  str = record.split(",")
  str[1].chop!
  
  Proverb.create({
  	   # :id => str[0],
        :proverb => str[1],
      })
end
