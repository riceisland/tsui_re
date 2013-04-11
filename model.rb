require "sequel"

#sequel使えるようにする
Sequel::Model.plugin(:schema)
Sequel.extension :pagination
Sequel.connect("sqlite://user.db")

class User < Sequel::Model
  unless table_exists?
    set_schema do
	  primary_key :id
	  varchar :name
	  varchar :password
	end
	create_table
  end
  
  #認証メソッド
  def self.authenticate(name, hexpass)    
    #p hexpass
    user = self.first(name: name)  
    user if user && user.password == hexpass
  end
  
end

#word_id:レコードid
#direction:見出し語
#spell:読み

class Word < Sequel::Model
  unless table_exists?
    set_schema do
      varchar :word_id
      varchar :direction
      varchar :spell
    end
    create_table
  end
end

#関係をあらかじめ登録しておく
class Relation_code < Sequel::Model
  unless table_exists?
    set_schema do
      primary_key :relation_id
      varchar :relation_name
    end
    create_table
  end
end

#relation_id: relation_codeよりidを参照
#word_set: 関係を持つ語の集合（カンマ区切り）
#refer: ことわざ・名言のid

class Relation < Sequel::Model
  unless table_exists?
    set_schema do
      primary_key :id
      foreign_key :relation_id, :relation_code
      varchar :word_set
      varchar :refer
    end
    create_table
  end
end

class Proverb < Sequel::Model
  unless table_exists?
    set_schema do
      primary_key :id
      varchar :proverb
    end
    create_table
  end
end

class Wisdom < Sequel::Model
  unless table_exists?
    set_schema do
      primary_key :id
      varchar :wisdom
      varchar :creator
    end
    create_table
  end
end