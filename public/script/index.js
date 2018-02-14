var map;

function initMap() {

  // Create map centred on Zurich
map = new google.maps.Map(document.getElementById('map'), {
  center: {lat: 47.3744694, lng: 8.5348776},
  zoom: 12
  });

  var marker;
  var info_markers = [];

  // Save instance variable defined in the app, containing all locations that are not hidden, into JS variable
  var locations = <%= @garden_locations %>;

  // Create a marker for each garden in database
  for (i = 0; i < locations.length; i++) {

    var infowindow = new google.maps.InfoWindow();

    marker = new google.maps.Marker({
      position: {lat: locations[i][2], lng: locations[i][3]},
      map: map
    });

    // Define content for each garden infowindow when marker is clicked on
    // Save each into an array with infowindows info for each marker
    var info_window_content = '<div class="garden-marker-box"><img class="garden-marker-picture" src="http://www.schweiztipps.ch/wp-content/uploads/2012/08/kleingarten.jpg" alt="Garden profile picture"><a class="garden-marker-text" href="/gardens/'+locations[i][0]+'">'+locations[i][1]+'</a></br>'+locations[i][4]+'</div>'
    info_markers.push(info_window_content);

    // Add listener function rendering the relevant infowindow content to each marker on click
    google.maps.event.addListener(marker, 'click', (function(marker, i) {
      return function() {
        infowindow.setContent(info_markers[i]);
        infowindow.open(map, marker);
        }
    })(marker, i));

    google.maps.event.addListener(infowindow, 'domready', function() {

      // Reference to the default DIV which receives the contents of the infowindow using jQuery
      var iwOuter = $('.gm-style-iw');

      /* The DIV we want to change is above the .gm-style-iw DIV.
      * Use jQuery and create a iwBackground variable,
      * taking advantage of the existing reference to .gm-style-iw for the previous DIV with .prev().
      */
      var iwBackground = iwOuter.prev();

      // Remove the background shadow DIV
      iwBackground.children(':nth-child(2)').css({'display' : 'none'});

      // Remove the white background DIV
      iwBackground.children(':nth-child(4)').css({'display' : 'none'});

      // Moves the infowindow a bit more to the right and down, as the 2 operations below make it seem not centred
      iwOuter.parent().parent().css({left: '2.5vw', top: '3vw'});

      // Hides the arrow
      iwBackground.children(':nth-child(3)').attr('style', function(i,s){ return s + 'display: none;'});
    });
  }
  }
