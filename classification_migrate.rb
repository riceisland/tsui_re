require "sequel"
require "./model.rb"

#sequel使えるようにする
Sequel::Model.plugin(:schema)
Sequel.extension :pagination
Sequel.connect("sqlite://user.db")

filename = "bunrui.txt"

file = open(filename)

#方針
#元データの語彙と段落が順番に並んでいることを利用する
#1行ずつ操作
#1つ前の語彙と段落と比較して、同じ場合はsame_classificationにidを追加
#違う場合は、ストックしてきたsame_classificationをclassificationにpush
#最終的にclassificationからDBへデータを格納

#past_classification : 1つ前の言葉の語彙と段落（元データが順番に並んでいることを利用）
#same_classification : 同じ語彙と段落を持ったword_idが1つ1つの要素
#classification : 同じ語彙と段落を持ったword_idを要素とした配列を要素とした配列（二重配列）

past_classification = ["0","0"]
same_classification = Array.new
classification = Array.new

file.each do |record|
  record.chomp!
  elements = record.split(",") 
  
  if past_classification[0] == "0"
    same_classification.push(elements[0])
    past_classification[0] = elements[7]
    past_classification[1] = elements[8]
  
  elsif past_classification[0] == elements[7] && past_classification[1] == elements[8]
    same_classification.push(elements[0])
    
  else
    #同じ分類を求めるので、要素が1の場合はclassificationに格納する必要がない
    if same_classification.length > 1
      classification.push(same_classification)
    end
    past_classification[0] = elements[7]
    past_classification[1] = elements[8]
    same_classification = [elements[0]]
  end
  
end

#一番最後の列がelsifの分岐に入った場合
#最後のsame_classificationはclassificationにpushされてないので、ループの外で操作
if same_classification.length > 1
  classification.push(same_classification)
end

file.close


classification.each do |data|

  data.each do |elem|
    word_id = Word.where(:word_id => elem).first
	
	if word_id
	else
	  data.delete(elem)
    end
  
  end
  
  if data.length > 1
    set = data.join(",")
    Relation.create({
 	  :word_set => set,
	  :relation_id => 4,
    })
  end
  
end