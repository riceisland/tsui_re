require "sequel"
require "./model.rb"

#sequel使えるようにする
Sequel::Model.plugin(:schema)
Sequel.extension :pagination
Sequel.connect("sqlite://user.db")

filename = "antonym.txt"

file = open(filename)

file.each do |record|
  record.chomp!
  elements = record.split(",")
  
  #表記の完全一致で検索
  wordA_dir = Word.where(:direction => elements[0]).first
  wordB_dir = Word.where(:direction => elements[2]).first
  
  if wordA_dir && wordB_dir
  
    set = wordA_dir.word_id + "," + wordB_dir.word_id
    #print(set,"\n")
    Relation.create({
      :word_set => set,
      :relation_id => 5,
    })
    
  end

end

file.close


##反義語マイグレート