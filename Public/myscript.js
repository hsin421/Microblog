$(document).ready(function(){

//a=11;
$("#slidedown").hide();
$("#slidedown2").hide();

//$("#post_submit").click(function(){


	//$(".post").animate({"top":"+=100px"}, 1000);

//$(".post:last-child").remove();

//$("#feed").prepend("<div class='post' id='f"+a+"'></div>");
//$("#f"+(a-1)).html($("#write").val());
//a = a+1;

//});

$("#followinglist").click(function(){
	if ($("#slidedown").is(":hidden")){
       $("#slidedown").slideDown("slow");
	}else {
		$("#slidedown").hide();
	};

});

$("#followerlist").click(function(){
	if ($("#slidedown2").is(":hidden")){
       $("#slidedown2").slideDown("slow");
	}else {
		$("#slidedown2").hide();
	};
});

for(a=1; a<11; a++){
	if ($("#f"+a).contents()[0] == undefined){
        
         $("#f"+a).css("border","white")
	}
}

function User(){

	
	$("#profileSidebar").fadeOut("slow")
};



	// turn border off of empty post divs
	$('div.post:empty').hide();

});

