# encoding: utf-8

require "sequel"
require "../model.rb"
require "MeCab"

#sequel使えるようにする
Sequel::Model.plugin(:schema)
Sequel.extension :pagination
Sequel.connect("mysql://yonejima:redbook6@localhost/tsui", {:compress => false, :encoding => "utf8"})

modes = ["proverbs", "wisdom"]

modes.each do |mode| 

filename = mode + ".txt"

file = open(filename)

file.each do |record|
  elem_list = Array.new
  record.chomp!
  str = record.split(",")
  
  c = MeCab::Tagger.new(ARGV.join(" "))
  n = c.parseToNode(str[1])

  #featureが諸々の要素（カンマ区切り）
  #surfaceが切り出した語	 
  while n do
	elements = n.feature.split(",")
	elements[0].force_encoding("utf-8")
	if elements[0] == "BOS/EOS" || elements[0] == "助詞" || elements[0] == "助動詞" || elements[0] == "記号"
	else
      elem_list.push(n.surface.force_encoding("utf-8"))
	end
	n = n.next
  end
  
  word_list = Array.new	 
  if elem_list.length > 1
    elem_list.each do |word|
      check = Word.where(:direction => word).first
      if check
        word_list.push(check.word_id)
      end
    end
    
    if word_list.length > 1
      case mode
        when "proverbs"
          relation_id = 6
        when "wisdom"
          relation_id = 7
      end
      
      set = word_list.join(",")
      #print(str[0],"\n")
      Relation.create({
        :word_set => set,
        :relation_id => relation_id,
        :refer => str[0],
      })
    end
    #print(elem_list, "\n")
  end
end

file.close

end

#ことわざ名言マイグレートを一気に実行