require "sequel"
require "./model.rb"

#sequel使えるようにする
Sequel::Model.plugin(:schema)
Sequel.extension :pagination
Sequel.connect("mysql://yonejima:redbook6@localhost/tsui", {:compress => false, :encoding => "utf8"})

filename = "bunrui.txt"

file = open(filename)

file.each do |record|
  record.chomp!
  elements = record.split(",")
  
  #このやりかたはまずかった...
  #same_dir = Word.where(:direction => elements[11]).first
  #same_spl = Word.where(:spell => elements[13]).first
  
  same = Word.filter([[:direction => elements[11]], [:spell => elements[13]]]).first
  
  if same
  
  else
    print(elements[11],"\n")
    Word.create({
      :word_id => elements[0],
      :direction => elements[11],
      :spell => elements[13],
    })
  end
  #print(record, "\n")
end

file.close


##データ量が多いので、だいたい30分くらいかかります。


