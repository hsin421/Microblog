$(document).ready(function(){

$("#f10").html("Hello World");



$("#post_submit").click(function(){

//$(".post").animate({"top":"+=100px"}, 1000);

$(".post:last-child").remove();

$("#feed").prepend("<div class='post'> hahaha</div>")


});



});

