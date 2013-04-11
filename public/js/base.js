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
