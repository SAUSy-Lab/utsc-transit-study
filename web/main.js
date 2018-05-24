
// initial data to display and arrays for the type ids
current_type = "all"
type_ids = ["t_students","t_staff","t_faculty","t_all"]
type_names = ["students","staff","faculty","all"]

// input data for top routes and travel times
top_routes = {
  "all": [["TTC 95", 28],["TTC 198", 21],["TTC 38", 18],["GO 51", 17],["DRT 900", 9]],
  "students": [["TTC 95", 29],["TTC 198", 20],["TTC 38", 20],["GO 51", 18],["DRT 900", 8]],
  "staff": [["TTC 198", 25],["DRT 900", 22],["TTC 95", 17],["TTC 38", 16],["GO 51", 16]],
  "faculty": [["TTC 198", 62],["TTC 2", 51],["TTC 95", 11],["GO LE", 10],["TTC 38", 10]]
}
durations = {
  "students": [61,55],
  "staff": [65,61],
  "faculty": [69,70],
  "all": [61,57]
}
summary_n = {
  "students": 12298,
  "staff": 631,
  "faculty": 392,
  "all": 13321
}
summary_name = {
  "students": "students",
  "staff": "staff",
  "faculty": "faculty",
  "all": "commuters"
}

// map params per type
map_opacity = {
  "students": 0.04,
  "staff": 0.1,
  "faculty": 0.13,
  "all": 0.04
}
map_type = {
  "students": "S",
  "staff": "E",
  "faculty": "F",
}


// utsc point geojson
utsc_json = {
"type": "FeatureCollection",
"features":[{
  "type": "Feature",
  "geometry": {
      "type": "Point",
      "coordinates": [-79.1857, 43.78423]
  }
}]
}


// setup the map
mapboxgl.accessToken = 'pk.eyJ1IjoiamVmZmFsbGVuIiwiYSI6ImNqaGloMHpmYTF2emgzNm83amdseDJocXkifQ.vrUb7K0pS9AeEx8K7aQV7Q';
var map = new mapboxgl.Map({
    container: 'map', // container id
    style: 'mapbox://styles/jeffallen/cjhfikt2j3i7w2soc0tx8taml', // stylesheet location
    center: [-79.1857, 43.78423], // starting position [lng, lat]
    zoom: 10, // starting zoom
    bearing: -17, // bearing in degrees
    maxZoom: 13.5,
    minZoom: 9,
    attributionControl: false,
});


map.on('load', function () {

  map.addSource('utsc_pt', {
        "type": "geojson",
        "data": utsc_json
    });
  map.addLayer({
      "id": "utsc_pt3",
      "source": "utsc_pt",
      "type": "circle",
      "paint": {
          "circle-radius": 12,
          "circle-color": "#080d16",
      }
  });
  map.addLayer({
      "id": "utsc_pt",
      "source": "utsc_pt",
      "type": "circle",
      "paint": {
          "circle-radius": 10,
          "circle-color": "#ffffff",
      }
  });
  map.addLayer({
      "id": "utsc_pt2",
      "source": "utsc_pt",
      "type": "circle",
      "paint": {
          "circle-radius": 6,
          "circle-color": "#f44242",
      }
  });

})



// functions for when hovering over buttons
function m_on(type_id) {
  document.getElementById(type_id).style.opacity = 1;
}
function m_off(type_id) {
  var type_index = type_ids.indexOf(type_id);
  if (type_names[type_index] == current_type) {
    document.getElementById(type_id).style.opacity = '1.0';
  }
  else {
    document.getElementById(type_id).style.opacity = '0.7';
  }
}

// function for swithcing type
function type_switch(type_id) {
  current_type = type_id
  console.log(current_type)
  // set opacity of button
  for (var qq = 0; qq < 4; qq++) {
    if (type_id == type_names[qq]) {
      // changing opacity of buttons
      document.getElementById(type_ids[qq]).style.opacity = '1.0';
      }
    else {
      document.getElementById(type_ids[qq]).style.opacity = '0.7';
      }
  }

  console.log(map_type[type_id])

  // switching map stuff
  if (type_id != "all") {
    map.setFilter('utsc_r_in_all', ["all",[ "==", "type", map_type[type_id] ],["<", "duration", 10800]]);
    map.setFilter('utsc_r_out_all', ["all",[ "==", "type", map_type[type_id] ],["<", "duration", 10800]]);
    map.setFilter('utsc_r_in_all_thin', [ "==", "type", map_type[type_id]]);
  } else {
    console.log("meow")
    map.setFilter('utsc_r_in_all', ["all",[ "!=", "type", "meow" ],["<", "duration", 10800]]);
    map.setFilter('utsc_r_out_all', ["all",[ "!=", "type", "meow" ],["<", "duration", 10800]]);
    map.setFilter('utsc_r_in_all_thin', [ "!=", "type", "meow" ]);
  }

  map.setPaintProperty('utsc_r_in_all', 'line-opacity', map_opacity[type_id]);
  map.setPaintProperty('utsc_r_out_all', 'line-opacity', map_opacity[type_id]);

  // switching the duration bars
  document.getElementById("d_mean").style.width = String(durations[current_type][0] * 2) + "px"
  document.getElementById("d_median").style.width = String(durations[current_type][1] * 2) + "px"
  document.getElementById("d_mean_text").innerHTML = "<p>&nbsp&nbsp" + String(durations[current_type][0]) + "&nbspminutes</p>"
  document.getElementById("d_median_text").innerHTML = "<p>&nbsp&nbsp" + String(durations[current_type][1]) + "&nbspminutes</p>"

  // switching the transit routes
  document.getElementById("r_1").style.width = String(top_routes[current_type][0][1] * 3) + "px"
  document.getElementById("r_1_text").innerHTML = "<p>&nbsp " + String(top_routes[current_type][0][0]) + "</p>"
  document.getElementById("r_2").style.width = String(top_routes[current_type][1][1] * 3) + "px"
  document.getElementById("r_2_text").innerHTML = "<p>&nbsp " + String(top_routes[current_type][1][0]) + "</p>"
  document.getElementById("r_3").style.width = String(top_routes[current_type][2][1] * 3) + "px"
  document.getElementById("r_3_text").innerHTML = "<p>&nbsp " + String(top_routes[current_type][2][0]) + "</p>"
  document.getElementById("r_4").style.width = String(top_routes[current_type][3][1] * 3) + "px"
  document.getElementById("r_4_text").innerHTML = "<p>&nbsp " + String(top_routes[current_type][3][0]) + "</p>"
  document.getElementById("r_5").style.width = String(top_routes[current_type][4][1] * 3) + "px"
  document.getElementById("r_5_text").innerHTML = "<p>&nbsp " + String(top_routes[current_type][4][0]) + "</p>"

  document.getElementById("summary").innerHTML = "<p>n =&nbsp" + String(summary_n[current_type]) + "&nbsp" + summary_name[current_type] + "</p>"

}

//
map.addControl(new mapboxgl.NavigationControl());

// initial showing
type_switch("all")
