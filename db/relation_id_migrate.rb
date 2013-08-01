require "sequel"
require "./model.rb"

#sequel使えるようにする
Sequel::Model.plugin(:schema)
Sequel.extension :pagination
Sequel.connect("sqlite://user.db")

filename = "relation_code.txt"

file = open(filename)

file.each do |record|
  record.chomp!
  elements = record.split(",")
  
  Relation_code.create({
    #:relation_id => elements[0],
    :relation_name => elements[1],
  })
  
  #print(record, "\n")
end

file.close


##反義語マイグレート