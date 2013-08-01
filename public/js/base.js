$(document).ready(function(){
    
  $("g.word").click(function(){
  	id = $(this).attr("id");
  	this_class = $(this).attr('class');
  	relation_id = this_class.split(" ");
  	//alert(relation_id[2]);
  	data = {word_id:id,related:relation_id[2]}
  	//alert(id)
    $.ajax({
      url: "/word",
      type: 'POST',
      timeout: 1000,
      data: data,
      error: function(){alert('ERROR');},
      success: function(str){
      	var obj = JSON.parse(str);
      	relate_draw(obj);
      	
      		//モーダルモードをつくる
	
	$("body").append('<div id="myModal" class="modal hide fade" tabindex="-1" role="dialog" aria-labelledby="myModalLabel" aria-hidden="true"><div class="modal-header"><button type="button" class="close" data-dismiss="modal" aria-hidden="true">×</button><h3 id="myModalLabel">'+obj.direction+'</h3></div><div class="modal-body"><p>'+ obj.spell+'</p></div><div class="modal-footer"><button class="btn" data-dismiss="modal" aria-hidden="true">Close</button><button class="btn btn-primary">Save changes</button></div></div>');  
	
	
      }
    });
    return false;
  });
  
  $(".center_data").click(function(){
  	//alert("a");
  	$('#myModal').modal();
  })
  
  //large_width = $("button.css_btn_class_green").outerWidth();
  //alert(large_width)
  //$("button.css_btn_class").css("width", large_width + "px");
  //$(".alert").css("width", large_width + "px");
  $("button.css_btn_class").css("width", "420px");
  $("button.css_btn_alert").css("width", "420px");
  
  $(document).on("click", "button.css_btn_class_green", function(){
  	location.href = ("/main");
  });
  
  $(document).on("click", "li#search", function(){
  	$("#searchModal").modal();
  })
  
  $( '#cd-dropdown' ).dropdown();
  
  $(document).on("click", "li#fav", function(){
  	location.href = ("./fav_list?page=1");
  })
  
  $(document).on("click", "li#logout", function(){
  	location.href = ("./logout");
  })
  
  $(document).on("click", "li#login", function(){
  	location.href = ("./?status=login");
  })
  
  $(document).on("click", "li#register", function(){
  	location.href = ("./?status=register");
  })
  
  $(document).on("click", "li#rand", function(){
  	location.href = ("./main");
  })
  
  $(document).on("click", "div.backdrop_fav > span.icon-heart-2, div.backdrop_fav > p.fav_msg2", function(){
  	id = $(this).attr("id");
  	send_id = id.split("_");
  	send_data = {id : send_id[1]}
  	
  	span_id = "span#favbd_" + send_id[1]
  	p_id = "p#favbdmsg_" + send_id[1]
  	
  	$.ajax({
      url: "/fav_add",
      type: 'POST',
      timeout: 1000,
      data: send_data,
      error: function(){alert('ERROR');},
      success: function(str){
      	//alert($(this).attr("class"));
      	$(span_id).removeClass("icon-heart-2");
  		$(span_id).addClass("icon-heart-1");
  		$(p_id).html("お気に入りを解除");
  		$(p_id).removeClass("fav_msg2");
  		$(p_id).addClass("fav_msg1");
      }
    });
    return false;
  	
  })

  $(document).on("click", "div.modal-header > span.icon-heart-2", function(){
  	id = $(this).attr("id");
  	send_id = id.split("_");
  	send_data = {id : send_id[1]}
  	
  	span_id = "span#modalfav_" + send_id[1]
  	//alert(span_id)
    	
  	$.ajax({
      url: "/fav_add",
      type: 'POST',
      timeout: 1000,
      data: send_data,
      error: function(){alert('ERROR');},
      success: function(str){
      	//alert($(this).attr("class"));
      	$(span_id).removeClass("icon-heart-2");
  		$(span_id).addClass("icon-heart-1");
      }
    });
    return false;
  	
  })
  
  $(document).on("click", "div.backdrop_fav > span.icon-heart-1, div.backdrop_fav > p.fav_msg1", function(){
  	id = $(this).attr("id");
  	send_id = id.split("_");
  	send_data = {id : send_id[1]}
  	
  	span_id = "span#favbd_" + send_id[1]
  	p_id = "p#favbdmsg_" + send_id[1]
  	
  	$.ajax({
      url: "/fav_remove",
      type: 'POST',
      timeout: 1000,
      data: send_data,
      error: function(){alert('ERROR');},
      success: function(str){
	  	$(span_id).removeClass("icon-heart-1");
  		$(span_id).addClass("icon-heart-2");
  		$(p_id).html("お気に入りに追加");
  		$(p_id).removeClass("fav_msg1");
  		$(p_id).addClass("fav_msg2");
      }
    });
    return false;
  })
  
  $(document).on("click", "div.modal-header > span.icon-heart-1", function(){
  	id = $(this).attr("id");
  	send_id = id.split("_");
  	send_data = {id : send_id[1]}
  	
  	span_id = "span#modalfav_" + send_id[1]
  	
  	$.ajax({
      url: "/fav_remove",
      type: 'POST',
      timeout: 1000,
      data: send_data,
      error: function(){alert('ERROR');},
      success: function(str){
	  	$(span_id).removeClass("icon-heart-1");
  		$(span_id).addClass("icon-heart-2");
      }
    });
    return false;
  })
  
  $(document).on("click", "div.backdrop_semantic > span.icon-book-alt2, div.backdrop_semantic > p.semantic_msg", function(){
  	//str = $(this).closest("div.word > p.box_str").text();
  	oldstr = $(this).closest("div.word").children("p").text();
  	str = oldstr.replace(/（.*）/, "")
  	word_id = $(this).closest("div.word").attr("id");
  	bd_id = "#favbd_" + word_id
  	//alert(str);
  	
  	relate_href = $(this).closest("div").next("div").children("a").attr("href");
  	//alert(relate_href);
  	relate_id = relate_href.split("=")[2]
  	//alert(relate_id);
  	
  	var relate_caption = "";
  	
  	switch(relate_id){
  		case "1":
  			relate_caption = "同音異義語";
  			break;
  		case "2":
  			relate_caption = "同じ漢字を含む";
  			break;
  		case "3":
  			relate_caption = "同じ音を含む";
  			break;
  		case "4":
  			relate_caption = "同じ分類";
  			break;  		
  		case "5":
  			relate_caption = "反義語";
  			break;
  		case "6":
   			relate_caption = "故事ことわざに共起";
  			break;
  		case "7":
  			relate_caption = "有名フレーズに共起";
  			break;
  		case "8":
  			relate_caption = "なし（履歴より）";
  			break;
  		case "9":
  			relate_caption = "なし（ランダム選択）";
  			break;  		
  		case "10":
  			relate_caption = "なし（検索機能の利用）";
  			break;  		
  		case "11":
  			relate_caption = "なし（お気に入りより）";
  			break;
  	}
  	
  	
  	if (!$("span.fav_icon")){
  	  
  	  default_classes = $(bd_id).attr("class");
  	  default_class = default_classes.split(" ")[0]
  	  //alert(default_class);
  	  
  	  $("span.fav_icon").attr("id", "modalfav_" + word_id)
  	  
  	  if(default_class == "icon-heart-2"){
  	  	
  	  	$("span.fav_icon").addClass("icon-heart-2");
  	  	
  	  }
  	  else{
  	  	
  	  	$("span.fav_icon").addClass("icon-heart-1");
  	  	
  	  }
  	
  	}
  	
  	
  	
  	$("#semantic_label").remove();
  	$("#semantic_relate").remove();
  	$("#frame").remove();
  	
  	//spell, relateどうしよう
  	$("div#semantic_modal > .modal-header").append("<h3 id ='semantic_label'>" + oldstr + "</h3>")
  	$("div#semantic_modal > .modal-header").append("<h4 id ='semantic_relate'>前の語との関係：" + relate_caption + "</h4>")
  	$("div#semantic_modal > .modal-body").append("<iframe src='http://kotobank.jp/word/" + str + "' id = 'frame'>")
  	$('#semantic_modal').modal();
  	
  })
  


 $("div.word").mouseenter(function(){
 	
 	$("div.backdrop", this).css("display", "block");

  }).mouseleave(function(){
    
    $("div.backdrop", this).css("display", "none");
  	
  });
    

  
  $("form#register").submit(function(){
  		
      username = $("#register_name").val();
      email = $("#register_mail").val();
      pass = $("#register_pass").val();
      repass = $("#register_re_pass").val();

      if ((username == "") || (email == "") || (pass == "") || (repass == "")) {
       	alert('記入していない項目があります。')
        return false;
      }
      else {
      	
      	if(pass != repass){
      	  alert("確認用パスワードが間違っています。")
      	  return false;
      	}
      	else {	
          return true;
      	}
      }

  }) 

  
  $("form#login").submit(function(){
  		
      username = $("#login_name").val();
      pass = $("#login_pass").val();
      

      if ((username == "") || (pass == "") ) {
       	alert('記入していない項目があります。')
        return false;
      }
      else {
        return true;
      }

  })   

  //timer = setTimeout(function(){  
    $("div.word").each(function(i){
  	  $(this).delay(1000*i).flip({
  	  	  onEnd: function(){
	  	    if(i == 4){
	  	   	  $("span.center_data").css("color", "black");
	  	    }
  	      },
  	      direction: 'tb',
  	  	  color: "#ffffff"
  	  })
    })  	   
  //}, 3000);
  
});

function rand_draw(dataset){
	//alert(str[0][1]);
    var width = $(window).width()
	var height = $(window).height()      

	var svg = d3.select("body").append("svg")
    	.attr("width", width)
    	.attr("height", height)
    	.attr("style", "position:absolute; top:0; left:0; z-index:-1;")
    	.append("g");

	var node = svg.selectAll(".node")
    	.data(dataset)
    	.enter().append("g")
    	.attr("class", function(d) { return d[0] == "" ? "word root id_10": "word root id_9";})
    	.attr("id", function(d){return d[0] == "" ? "search" : d[0];})
    	.attr("transform", function(d) { return "translate(" + d[2]*width + ", " +  d[3] * height+")";});

	node.append("circle")
    	.attr("r", 100);

	node.append("text")
    	.attr("dy", ".31em")
    	.text(function(d) { return d[1]; });
    	
    $("g.word").hover(function(){
    	$(this).addClass("hover");
    },function(){
    	$(this).removeClass("hover");
    })
    
    $("body").append('<form class="search_form"><input type="text" name="name" maxlength="20" style="width: 150px; left:'+( width*3 /4-75)+'px; top:'+ (height * 2 /3-20)+'px;"><button type="submit" class="btn search_btn" style= "left:'+( width*3 /4-20)+'px; top:'+ (height * 2 /3+20)+'px;">検索!</form>');
  	

}

function relate_draw(dataset){
	console.log(dataset.direction);
	console.log(dataset.spell);
	console.log(dataset.word_id)
	console.log(dataset.children[0].direction);
	$("svg").remove();
	$('#myModal').remove();
    $('form').remove(); 
	//alert(typeof dataset);
	
	var diameter = 700;
	var width = $(window).width()
	var height = $(window).height()      

	var tree = d3.layout.tree()
    	.size([360, diameter / 2 - 120])
    	.separation(function(a, b) { return (a.parent == b.parent ? 1 : 2) / a.depth; });

	var diagonal = d3.svg.diagonal.radial()
    	.projection(function(d) { return [d.y, d.x / 180 * Math.PI]; });


	var svg = d3.select("body").append("svg")
    	.attr("width", width)
    	.attr("height", height)
  		.append("g")
    	.attr("transform", "translate(" + width / 2 + "," + height / 2 + ")");

	var nodes = tree.nodes(dataset),
		links = tree.links(nodes);
		
	var link = svg.selectAll(".link")
		.data(links)
		.enter().append("path")
		.attr("class", "link")
		.attr("d", diagonal);
      //.attr("transform", function(d) { return "rotate(" + (d.source.x) + ")translate(" + d.source.y + ")"; });
	
	var node = svg.selectAll(".node")
      	.data(nodes)
      	.enter()
      	.append("g")
      	.attr("class", function(d) { return d.relation_id ? "word relate id_" + d.relation_id : "word root " + d.related;})
      	.attr("id", function(d){return d.word_id;})
      	.attr("transform", function(d) { return "rotate(" + (d.x - 90) + ")translate(" + d.y + ")"; });
    
    node.append("circle")
      	.attr("r", function(d) { return d.depth == 0 ? 100 : 50;});
      //.attr("r", 50);
      //.attr("r", function(d) { return d.depth + 20; });
      	
    node.append("text")
      	.attr("dy", ".31em")
      //.attr("text-anchor", function(d) { return d.x < 180 ? "start" : "end"; })
      	.attr("text-anchor", "middle")
      	.attr("transform", function(d) { return "rotate(" + ((d.x-90) * -1) + ")"; })
      //.attr("transform", function(d) { return d.x < 180 ? "translate(8)" : "rotate(180)translate(-8)"; })
      	.text(function(d) { return d.direction; });
	//});

	
  $("g.relate").click(function(){
  	id = $(this).attr("id");
  	this_class = $(this).attr('class');
  	relation_id = this_class.split(" ");
  	//alert(relation_id[2]);
  	data = {word_id:id,related:relation_id[2]}
  	//alert(id)
    $.ajax({
      url: "/word",
      type: 'POST',
      timeout: 1000,
      data: data,
      error: function(){alert('ERROR');},
      success: function(str){
      	var obj = JSON.parse(str);
      	relate_draw(obj);
      	      		//モーダルモードをつくる
	
	$("body").append('<div id="myModal" class="modal hide fade" tabindex="-1" role="dialog" aria-labelledby="myModalLabel" aria-hidden="true"><div class="modal-header"><button type="button" class="close" data-dismiss="modal" aria-hidden="true">×</button><h3 id="myModalLabel">'+obj.direction+'</h3></div><div class="modal-body"><p>'+ obj.spell+'</p></div><div class="modal-footer"><button class="btn" data-dismiss="modal" aria-hidden="true">Close</button><button class="btn btn-primary">Save changes</button></div></div>');  
	
      }
    });
    return false;
  });
  
	
  $("g.root").click(function(){
  	//alert("aaa");
  	$('#myModal').modal();
  })
  
	
}
