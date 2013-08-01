require "sequel"
require "./model.rb"

#sequel使えるようにする
Sequel::Model.plugin(:schema)
Sequel.extension :pagination
Sequel.connect("mysql://yonejima:redbook6@localhost/tsui", {:compress => false, :encoding => "utf8"})

#spellを重複を除いて取り出す
dataset = Word.group(:spell).having('count(spell) > 0').select_group(:spell).all;
tone_base = Array.new

dataset.each do |data|
  #print(data.spell,"\n")
  char = data.spell.split(//)
  #2文字以上のspellが対象
  if char.length > 1
    tone_base.push(data.spell)
  end
end

tone_base.each do |spell|
  #sql: where like ~
  query = "%" + spell + "%"
  same_tone = Word.grep(:spell, query).all
  
  set = "" 
  if same_tone.length > 1
    same_tone.each do |data|
      set = set + data.word_id + ","
    end
    set.chop!
    print(set,"\n")
  
    Relation.create({
      :word_set => set,
      :relation_id => 3,
    })
  end

end


print(dataset.length,"\n")
print(tone_base.length, "\n")

#同じ音を含む語マイグレート
#かなり時間がかかります
