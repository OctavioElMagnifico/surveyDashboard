// location is hardcoded to a div called #mapDiv

var h = 300;
var w = 500;
var projection = d3.geoAlbersUsa()
            .translate([0,0])

<!-- notar cómo no definimos el dominio hasta no cargar los datos -=>
var color = d3.scaleQuantize()
            .range( d3.schemeAccent.slice(0,4) );

var formatAsThousands = d3.format(",");
path = d3.geoPath()
        .projection( projection );

d3.select("#mapDiv")
    .append("svg")
    .attr("id","map")
    .attr("height",h)
    .attr("width",w);

var svgMap = d3.selectAll("#map")


var dragging = function(d) {
    var offset = projection.translate();
    offset[0] += d3.event.dx;
    offset[1] += d3.event.dy;
    projection.translate(offset);
    svgMap.selectAll("path")
        .attr("d",path);

    svgMap.selectAll("circle")
        .transition()
        .attr("cx", d => ( projection([d.lon,d.lat])[0] ))
        .attr("cy", d => ( projection([d.lon,d.lat])[1] ));

};

const magnificationCenter = 2000;

const zooming = function(d) {
    var offset = [d3.event.transform.x, d3.event.transform.y];

    var newScale = d3.event.transform.k * magnificationCenter;
    
    projection.translate(offset)
        .scale(newScale);

    svgMap.selectAll("path")
        .attr("d",path)

    svgMap.selectAll("circle")
				.attr("cx", function(d) {
						return projection([d.lon, d.lat])[0];
				})
				.attr("cy", function(d) {
						return projection([d.lon, d.lat])[1];
				});
        // .attr("cx", d => ( projection( [d.lon, d.lat] )[0] ) )
        // .attr("cy", d => ( projection( [d.lon, d.lat] )[1] ) )
};

//we'll need to go to given points

const recenter = function(p) {
    projection.translate( [ -p[0], -p[1] ] ).translate( [ w/2, h/2] );

    svgMap.selectAll("circle")
        .transition()
        .duration(1000)
        .attr("cx", d => ( projection([d.lon,d.lat])[0] ))
        .attr("cy", d => ( projection([d.lon,d.lat])[1] ));

    svgMap.selectAll("path")
        .transition()
        .duration(1000)
        .attr("d",path);

};

const zoom = d3.zoom()
      .on("zoom", zooming);

// some initial center
var center = projection([-97.0, 39.0]);

var map = svgMap.append("g")
            .attr("id","mapG")
    .call(zoom)
    .call(zoom.transform, d3.zoomIdentity // This object is useful to call the initial state. Clever technique.
          .translate(w/2,h/2)
          .scale(0.25)
          .translate(-center[0],-center[1]));

// background to allow dragging


d3.csv("./us-ag-productivity.csv")
.then( function( data ) {
    color.domain([
        d3.min( data, d => ( d.value ) ),
        d3.max( data, d => ( d.value ) )
    ]);
    <!--  añadimos el geoJson-=>
    d3.json("./us-states.json")
        .then( function(json) {

            for (var i = 0; i < data.length; i++) {
                var dataState = data[i].state;
                var dataValue = parseFloat( data[i].value );
                for ( var j = 0; j < json.features.length; j++ ) {
                    var jsonState = json.features[j].properties.name;
                    if ( dataState == jsonState ) {
                        json.features[j].properties.value = dataValue;
                        break;
                    };
                };
            };

            map.selectAll("#map.path")
            .data(json.features)
            .enter()
            .append("path")
                .attr("d",path)
            .style("fill", function(d) {
                var value = d.properties.value;
                if (value) {
                    return color(value);
                } else {
                    return "#ccc";
                }
            })
            .style("stroke","gray");
        });

    map.append("rect")
        .attr("x",0)
        .attr("y",0)
        .attr("width",w)
        .attr("height",h)
        .attr("opacity",0);

    d3.csv("./us-cities.csv")
        .then( function(cities) {

            d3.scaleLinear()
            .domain( [
                d3.max( cities, d => ( d.population ) ),
                d3.min( cities, d => ( d.population ) )
            ] )
                .range( [0.5,10] );

            map.selectAll("#map.circle")
            .data(cities)
            .enter()
            .append("circle")
            .attr("cx", ( d ) => ( projection([d.lon,d.lat])[0] ))
            .attr("cy", ( d ) => ( projection([d.lon,d.lat])[1] ))
            .attr("r", d => ( Math.sqrt( parseInt(d.population) * 0.00004 ) ) )
            .style("fill",d3.schemeAccent[5])
            .style("stroke","gray")
            .style("stroke-width",0.25)
            .style("opacity",0.75)
            .append("title")
            .text( d => ( d.place + ": Pop. " + formatAsThousands(d.population) ) );

            createPanButtons();
        });

} );

var createPanButtons = function() {
    var north = svgMap.append("g")
                .attr("class","pan")
                .attr("id","north");
    north.append("rect")
        .attr("x",0)
        .attr("y",0)
        .attr("width",w)
        .attr("height",30);
    north.append("text")
        .attr("x",w/2)
        .attr("y",20)
        .html("&uarr;");

    var south = svgMap.append("g")
                .attr("class","pan")
                .attr("id","south");
    south.append("rect")
        .attr("x",0)
        .attr("y", h - 30 )
        .attr("width",w)
        .attr("height",30);
    south.append("text")
        .attr("x",w/2)
        .attr("y",h-10)
        .html("&darr;");

    var east = svgMap.append("g")
                .attr("class","pan")
                .attr("id","east");
    east.append("rect")
        .attr("x",w-30)
        .attr("y", 30 )
        .attr("width", 30 )
        .attr("height", h-60 );
    east.append("text")
        .attr("x",w-14)
        .attr("y",h/2)
        .html("&rarr;");

    var west = svgMap.append("g")
                .attr("class","pan")
                .attr("id","west");
    west.append("rect")
        .attr("x",0)
        .attr("y", 30 )
        .attr("width", 30 )
        .attr("height", h - 60 );
    west.append("text")
        .attr("x",14)
        .attr("y",h/2)
        .html("&larr;");

    d3.selectAll(".pan")
        .on("click", function() {
            var offset = projection.translate();
            var moveAmount = 50;
            var direction = d3.select(this).attr("id");
            <!-- recordar que para mover el mapa al norte la proyección se desplaza hacia abajo -->
            switch(direction) {
                case "north":
                    offset[1] += moveAmount;
                    break;
                case "south":
                    offset[1] -= moveAmount;
                    break;
                case "east":
                    offset[0] -= moveAmount;
                    break;
                case "west":
                    offset[0] += moveAmount;
                    break;
                default:
                    break;

            };
            projection.translate(offset);

            map.selectAll("path")
            .transition()
            .attr("d",path);
            
            svgMap.selectAll("circle")
                .transition()
                .attr("cx", d => ( projection([d.lon,d.lat])[0] ))
                .attr("cy", d => ( projection([d.lon,d.lat])[1] ));

        });
};
