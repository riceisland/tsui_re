#! ruby -Ku
# -*- coding: utf-8 -*-

require "sinatra"
require "warden"
require "json"
require "./model.rb"
require "sinatra/reloader" if development?

# Sinatra のセッションを有効にする
enable :sessions

#sequel使えるようにする
Sequel::Model.plugin(:schema)
Sequel.extension :pagination
Sequel.connect("sqlite://user.db")

configure do
  use Rack::Session::Cookie, :secret => Digest::SHA1.hexdigest(rand.to_s)
end


before do

    @max_id = Word.max(:word_id)
    @relation_size = Relation_code.max(:relation_id) 
    
    @connect_length = 5

	@title = "dictionareading"
	#prefix決めとくと移行した時便利だよー
end

# 認証方式を登録。
Warden::Strategies.add :login_test do
  # 認証に必要なデータが送信されているか検証
  def valid?
    params["name"] || params["password"]
  end

  # 認証
  def authenticate!
    hexpass = OpenSSL::Digest::SHA1.hexdigest(params["password"])
    user = User.authenticate(params["name"], hexpass)
    
    user.nil? ? fail!('Could not log in') : success!(user, 'Successfully logged in')
    #if params["name"] == "test" && params["password"] == "test"
      # ユーザー名とパスワードが正しければログイン成功
    #  user = {
    #    :name => params["name"],
    #    :password => params["password"]
    #  }
    #  success!(user)
    #else
      # ユーザー名とパスワードのどちらかでも間違っていたら
      # ログイン失敗
    #  fail!("Could not log in")
    #end
  end
end

Warden::Manager.before_failure do |env,opts|
  env['REQUEST_METHOD'] = 'POST'
end

# Warden の設定
use Warden::Manager do |manager|
  # 先ほど登録したカスタム認証方式をデフォルトにする
  manager.default_strategies :login_test

  # 認証に失敗したとき呼び出す Rack アプリを設定(必須)
  manager.failure_app = Sinatra::Application
  
  # ユーザー ID をもとにユーザー情報を取得する
  # 今回は単なる Hash だけど、実際の開発ではデータベースから取得するはず
  #Warden::Manager.serialize_from_session do |id|
  #  { :name => id, :password => "test" }
  #end

  Warden::Manager.serialize_from_session{|id| User[id] }
 
  # ユーザー情報からセッションに格納する ID を取り出す
  #Warden::Manager.serialize_into_session do |user|
  #  user[:name]
  #end
  Warden::Manager.serialize_into_session{|user| user.id}

end


get '/' do
  if request.env["warden"].user.nil?
    haml :top
  else
    redirect '/main'
  end
end

# 認証を実行する。
post "/login" do
  request.env["warden"].authenticate!
  redirect "/main"
end

#get-login（URL直打ちパターン）
get "/login" do  
  if request.env["warden"].user.nil?
    haml :login
  else
    redirect "/main"
  end
end


# 認証に失敗したとき呼ばれるルート。
# ログイン失敗ページを表示してみる。
post "/unauthenticated" do
  #erb :fail_login
  haml :fail_login
end

# ログアウトする。
# ログアウト後はトップページに移動。
get "/logout" do
  request.env["warden"].logout
  redirect "/"
end

get "/register" do
  if request.env["warden"].user.nil?
    haml :register
  else
    redirect "/main"
  end
end

post "/register" do
  if params[:name] && params[:password] && params[:re_password] && params[:mail]
    if params[:password] == params[:re_password]
      hexpass = OpenSSL::Digest::SHA1.hexdigest(params["password"])
      User.create({
	    :name => params[:name],
       :password => hexpass,
	  })
	  #登録と同時にログイン処理をしておく
	  request.env["warden"].authenticate!
      redirect "/main"
    else
      redirect "/register"
    end
  else
    redirect "/register"
  end
end


get '/main' do
  #order by rand() を使用せずにランダム抽出をしている！
  @word_list = Array.new
  
  while @word_list.length < @connect_length
    rand_list = Array.new
    10.times do
      rand_id = rand(@max_id.to_i) + 1
      rand_id_s = sprintf("%06d", rand_id.to_s)
      rand_list.push(rand_id_s)
    end
    rand_list.uniq!
    
    len = @connect_length - @word_list.length
    #p rand_list
    
    arr = Word.filter("word_id IN ?", rand_list).limit(len).all;
    
    #p arr
    arr.each do |elem|
      arr_elem = [elem.word_id, elem.direction]
      @word_list.push(arr_elem)
      #p elem.direction
    end
    @word_list.uniq!
    #p word_list
    
  end
  
  @word_list.push(["", ""])
  
  i = 1
  while i < @word_list.length + 1
    
    if i < 4
      x = Rational(i, 4)
      y = Rational(1, 4)
    else
      x = Rational(i-3, 4) 
      y = Rational(2, 3)
    end
    
    @word_list[i-1].push(x)
    @word_list[i-1].push(y)
    
    i += 1
    
  end
  
  haml :main
  #"Hello!"
end

post "/word" do
  word_id = params[:word_id]
  related = params[:related]
  p word_id
  p related
  
  query = "%" + word_id + "%"
  relation_set =  Relation.grep(:word_set, query).all
  
  arr = Array.new(7, [])
  relation_hash = Hash.new
  
  relation_set.each do |elem|
    relation_sets = elem.word_set.split(",")
    relation_sets.delete(word_id)
    #p elem.relation_id
      
    if elem.relation_id
      #p arr[elem.relation_id - 1]
      arr[elem.relation_id - 1] += relation_sets
    end
  end
  
  i = 0
  while i < arr.length
    if arr[i] != []
      relation_hash[i+1] = arr[i]
    end
    i += 1
  end
  
  #arr.delete([])
  #p has
  
  total_val = 0
  
  relation_hash.each do |key, val|
    total_val += val.length
  end  
  
  @relate_word_list = Array.new
  key_list = Array.new
  
  if total_val < @connect_length + 1
    
    relation_hash.each do |key, val|
      val.each do |elem|
        each_word = {:relation_id => key, :word_id => elem}
        @relate_word_list.push(each_word)
        #@relate_word_list[elem] = key
      end
    end 
  
  else
    
    if relation_hash.length < @connect_length  
      comb = @connect_length.divmod(relation_hash.length)
    
      comb[0].times do
        relation_hash.each do |key, val|
          select= val.sample
          val.delete(select)
        
          each_word = {:relation_id => key, :word_id => select}
          @relate_word_list.push(each_word)
          #@relate_word_list[select] = key
        
          if val.length > 0
            key_list.push(key)
          end
        
        end
      end
    
      odd = key_list.sample(comb[1])

      odd.each do |elem|
        each_word = {:relation_id => elem, :word_id => relation_hash[elem].sample}
        @relate_word_list.push(each_word)
        #@relate_word_list[relation_hash[elem].sample] = elem
      end
  
    else
   
      relation_hash.each do |key, val|
        key_list.push(key)
      end
    
      samp = key_list.sample(@connect_length)
    
      samp.each do |elem|
        each_word = {:relation_id => elem, :word_id => relation_hash[elem].sample}
        @relate_word_list.push(each_word)
        #@relate_word_list[relation_hash[elem].sample] = elem
      end
    
    end
  end
  
  @relate_word_list.each do |elem|
    p elem[:word_id]
    r_word_data = Word.where(:word_id => elem[:word_id]).first
    elem["direction"] = r_word_data.direction
  end
  
  p @relate_word_list
  
  word_data = Word.where(:word_id => word_id).first
  
  data_hash = Hash.new
  data_hash["direction"] = word_data.direction
  data_hash["spell"] = word_data.spell
  data_hash["related"] = related
  data_hash["word_id"] = word_id
  data_hash["children"] = @relate_word_list
  
  data_json = JSON.generate(data_hash)
  
  #p data_json
  
  return data_json
end
  