# encoding: utf-8

require "sequel"
require "../model.rb"

#sequel使えるようにする
Sequel::Model.plugin(:schema)
Sequel.extension :pagination
Sequel.connect("mysql://yonejima:redbook6@localhost/tsui", {:compress => false, :encoding => "utf8"})


#spellを重複を除いて取り出す
dataset = Word.group(:direction).having('count(direction) > 0').select_group(:direction).all;
#test = "はよねじまだよ。"
str = ""

#if /[一-龠]/ =~ test
# p "match"
#else
# p "false"
#end

dataset.each do |data|
  if /[一-龠]/ =~ data.direction
  print(data.direction, "\n")
    str = str + data.direction
  end
end

#UTF8の漢字にマッチする正規表現
kanji_list = str.scan(/[一-龠]/)
kanji_list.uniq!

p kanji_list.length

kanji_list.each do |kanji|
  #sql: where like ~
  query = "%" + kanji + "%"
  same_kanji = Word.grep(:direction, query).all
  
  set = "" 
  if same_kanji.length > 1
    same_kanji.each do |data|
      set = set + data.word_id + ","
    end
    set.chop!
    print(set,"\n")
  
    Relation.create({
      :word_set => set,
      :relation_id => 2,
      :refer => kanji,
    })
  end

end