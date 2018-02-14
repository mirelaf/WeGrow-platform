$(document).ready(function() {
  // link elements of navbar to sections on page
  $("#intro #find-on-map #benefits #contact").localScroll({
    target: 'body'})
  });

// assign and remove active class when selecting links
$(".nav a").on("click", function(){
 $(".nav").find(".active").removeClass("active");
  $(this).parent().addClass("active");
});
