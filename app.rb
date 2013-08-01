#! ruby -Ku
# -*- coding: utf-8 -*-

require "sinatra"
require "warden"
require "json"
require "haml"
require "sequel"
require "sqlite3"
require "./model.rb"
require "will_paginate"
require "will_paginate/sequel"
#require "sinatra/reloader" if development?
set :port, 1234

# Sinatra のセッションを有効にする
enable :sessions

#sequel使えるようにする
#Sequel::Model.plugin(:schema)
#Sequel.extension :pagination
#Sequel.connect("sqlite://user.db")

#configure do
#  use Rack::Session::Cookie, :secret => Digest::SHA1.hexdigest(rand.to_s)
#end

helpers do
	include Rack::Utils
	alias_method :h, :escape_html
		  
	def warden
	  request.env['warden']
	end
		  
	def current_user
	  warden.user
	end
end

before do

    @max_id = Word.max(:word_id)
    @relation_size = Relation_code.max(:relation_id) 
    
    @connect_length = 8

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
  Warden::Manager.serialize_from_session{|id| User[id] }
 
  # ユーザー情報からセッションに格納する ID を取り出す
  Warden::Manager.serialize_into_session{|user| user.user_id}

end


get '/' do
  if request.env["warden"].user.nil?
    if params[:status]
	  if params[:status] == "login"
	    haml :top_login, :layout => false
	  else
		haml :top_register, :layout => false
	  end
	else  
      haml :top, :layout => false
    end
  else
    redirect '/main'
  end
end

# 認証を実行する。
post "/login" do
  request.env["warden"].authenticate!
  redirect "/main"
end


# 認証に失敗したとき呼ばれるルート。
# ログイン失敗ページを表示してみる。
post "/unauthenticated" do
  #erb :fail_login
  @msg = "ログインできませんでした。"
  haml :fail_login, :layout => false
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
	    :mail => params[:mail],
        :password => hexpass,
	  })
	  #登録と同時にログイン処理をしておく
	  request.env["warden"].authenticate!
      redirect "/main"
    else
      redirect "/fail_register"
    end
  else
    redirect "/fail_register"
  end
end

get "/fail_register" do
  @msg = "登録できませんでした。"
  haml :fail_register, :layout => false

end

get "/logout" do
  request.env["warden"].logout
  redirect to ("/")
end


get '/main' do

  if request.env["warden"].user.nil?
    #p "notlogin"
    @backdrop_height = "90px"
  else
    user = User.select(:name).filter(:user_id => current_user.user_id).first
	@username = user.name
	@backdrop_height = "60px"
	#p @username
  end


  #order by rand() を使用せずにランダム抽出をしている！
  @word_list = Array.new
  
  while @word_list.length < @connect_length + 1
    rand_list = Array.new
    10.times do
      rand_id = rand(@max_id.to_i) + 1
      rand_id_s = sprintf("%06d", rand_id.to_s)
      rand_list.push(rand_id_s)
    end
    rand_list.uniq!
    
    len = @connect_length + 1 - @word_list.length
    #p rand_list
    
    arr = Word.filter("word_id IN ?", rand_list).limit(len).all;
    
    #p arr
    arr.each do |elem|
     
      str =  elem.direction.split(//)
      len = str.length
  
      if len < 5
        size = 90
      elsif len < 7
        size = 61
      elsif len < 10
        size = 60
      elsif len < 13
        size = 45
      elsif len < 17
        size = 44
      elsif len < 21
        size = 36
      elsif len < 26
        size = 35
      else
        size = 30
      end
      
      if request.env["warden"].user.nil?
        
        arr_elem = {:word_id => elem.word_id, :direction => elem.direction, :relation_id => "9", :size => size}
	
	  else
	
		favs = Favs.filter(:user_id => current_user.user_id, :word_id => elem.word_id).first
	
	    if favs
		  fav_icon = "icon-heart-1"
		else
		  fav_icon = "icon-heart-2"
	    end
	    
	    arr_elem = {:word_id => elem.word_id, :direction => elem.direction, :relation_id => "9", :size => size, :fav_icon => fav_icon}
	    
	  end
      
      @word_list.push(arr_elem)
      #p elem.direction
    end
    @word_list.uniq!
    #p word_list
    
  end

  haml :main2
end


get "/word" do

  if request.env["warden"].user.nil?
    #p "notlogin"
    @backdrop_height = "90px"
  else
    user = User.select(:name).filter(:user_id => current_user.user_id).first
	@username = user.name
	@backdrop_height = "60px"
	#p @username
  end


  word_id = params[:word_id]
  related = params[:relation_id]

  word_data = Word.where(:word_id => word_id).first
  related_set = Relation_code.where(:relation_id => related).first
  
 if word_data && related_set
	 
	  str =  word_data.direction.split(//)
	  len = str.length
	  
	  if len < 5
	    main_size = 90
	  elsif len < 7
	    main_size = 61
	  elsif len < 10
	    main_size = 60
	  elsif len < 13
	    main_size = 45
	  elsif len < 17
	    main_size = 44
	  elsif len < 21
	    main_size = 36
	  elsif len < 26
	    main_size = 35
	  else
	    main_size = 30
	  end

	  related_w = related_set.relation_name
	 
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
	      #comb = @connect_length.divmod(relation_hash.length)
	    
	      ofset = 0
		  
		  begin
		    ofset += relation_hash.length
		    relation_hash.each do |key, val|
		   
	          select= val.sample
	          val.delete(select)
	          
	          if val.length == 0
	          
	            relation_hash.delete(key)
	          
	          end
	        
	          each_word = {:relation_id => key, :word_id => select}
	          @relate_word_list.push(each_word)
	        
	        end
	     end while ofset < @connect_length + 1  
	  
	    else
	   
	      relation_hash.each do |key, val|
	        key_list.push(key)
	      end
	     
	    
	      samp = key_list.sample(@connect_length)
	    
	      samp.each do |elem|
	        each_word = {:relation_id => elem.to_s, :word_id => relation_hash[elem].sample}
	        @relate_word_list.push(each_word)
	        #@relate_word_list[relation_hash[elem].sample] = elem
	      end
	    
	    end
	  end
	  
	  @relate_word_list.each do |elem|
	    p elem[:word_id]
	    r_word_data = Word.where(:word_id => elem[:word_id]).first
	    elem[:direction] = r_word_data.direction
	    p r_word_data.direction
	    str =  r_word_data.direction.split(//)
	    len = str.length
	  
	    if len < 5
	      size = 90
	    elsif len < 7
	      size = 61
	    elsif len < 10
	      size = 60
	    elsif len < 13
	      size = 45
	    elsif len < 17
	      size = 44
	    elsif len < 21
	      size = 36
	    elsif len < 26
	      size = 35
	    else
	      size = 30
	    end
	    
	    elem[:size] = size
	    
        if request.env["warden"].user.nil?
	
   	    else
	
		  favs = Favs.filter(:user_id => current_user.user_id, :word_id => elem[:word_id]).first
	
	      if favs
		    fav_icon = "icon-heart-1"
		  else
		    fav_icon = "icon-heart-2"
	      end
	    
	      elem[:fav_icon] = fav_icon
	    
	    end
	    
	
	  end
	  
	  i = 0
	  odd = @connect_length - total_val
	  while i < odd
	    
	     null_hash = {:relation_id => "", :word_id => "", :size => ""} 
	     @relate_word_list.push(null_hash)
	     i += 1
	     
	  end  
	    
	    #p @relate_word_list
	  
	  @data_hash = Hash.new
	  @data_hash[:direction] = word_data.direction
	  @data_hash[:spell] = word_data.spell
	  @data_hash[:relation_id] = related
	  @data_hash[:related_w] = related_w
	  @data_hash[:word_id] = word_id
	  @data_hash[:size] = main_size
	  
	  if request.env["warden"].user.nil?
	
	  else
	
		 favs = Favs.filter(:user_id => current_user.user_id, :word_id => word_id).first
	
	     if favs
		   @fav_icon = "icon-heart-1"
		 else
		   @fav_icon = "icon-heart-2"
	     end
	  
	     @data_hash[:fav_icon] = @fav_icon
	    
	  end
	  #data_hash["children"] = @relate_word_list
	  p @data_hash
	  
	  #data_json = JSON.generate(data_hash)
	  
	  haml :word
  else
     p "notfound"
     # haml :error_word
  end
	
end

post "/fav_add" do
 
  time = Time.now

  Favs.create({
	:user_id => current_user.user_id,
	:word_id => params[:id],
    :time => time,
  })
  
  return "ok"
end

post "/fav_remove" do

  Favs.where(:user_id => current_user.user_id, :word_id => params[:id]).delete
  
  return "ok"

end

get "/fav_list" do

  if request.env["warden"].user.nil?
    #p "notlogin"
  else
    user = User.select(:name).filter(:user_id => current_user.user_id).first
	@username = user.name
	#p @username
  end

  page = params[:page].to_i
  all_list = Favs.select(:word_id).filter(:user_id => current_user.user_id)
  @paginated = all_list.paginate(page, 2)
  
  @page_list = Array.new
  
  @paginated.each do |elem|
    word_data = Word.where(:word_id => elem.word_id).first
    arr_elem = {:word_id => elem.word_id, :direction => word_data.direction, :relation_id => "11"} 
    @page_list.push(arr_elem)
  end

  haml :fav_list
end

get "/search" do

  if request.env["warden"].user.nil?
    #p "notlogin"
  else
    user = User.select(:name).filter(:user_id => current_user.user_id).first
	@username = user.name
	#p @username
  end
  
  @query = params[:query]
  page = params[:page].to_i
  
  throw_query = "direction like '%" + @query.to_s + "%'"
  all_list = Word.filter(throw_query)
  #p all_list
  @paginated = all_list.paginate(page, 10)
  
  @page_list = Array.new
  
  @paginated.each do |elem|
    word_data = Word.where(:word_id => elem.word_id).first
    arr_elem = {:word_id => elem.word_id, :direction => word_data.direction, :relation_id => "10"} 
    @page_list.push(arr_elem)
  end

  haml :search_list  
end

