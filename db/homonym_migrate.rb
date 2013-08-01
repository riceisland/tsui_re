require "sequel"
require "../model.rb"

#sequel使えるようにする
Sequel::Model.plugin(:schema)
Sequel.extension :pagination
Sequel.connect("mysql://yonejima:redbook6@localhost/tsui", {:compress => false, :encoding => "utf8"})

#重複しているspellを取り出す
dataset = Word.group(:spell).having('count(spell) > 1').select_group(:spell).all;

dataset.each do |data|
 print(data.spell,"\n")
  homonym_spells = Word.where(:spell => data.spell).all
  
  set = "" 
  homonym_spells.each do |data|
    set = set + data.word_id + ","
  end
  set.chop!
  #print(set,"\n")
  Relation.create({
    :word_set => set,
    :relation_id => 1,
  })

end

##同音異義語マイグレート
##所要時間約5分