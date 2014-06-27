$(document).ready(function(){
	a=11;
	$("#post_submit").click(function(){

	//$(".post").animate({"top":"+=100px"}, 1000);

	$(".post:last-child").remove();

	$("#feed").prepend("<div class='post' id='f"+a+"'></div>");
	$("#f"+(a-1)).html($("#write").val());
	a = a+1;

	});

	// turn border off of empty post divs
	$('div.post:empty').hide();

});

