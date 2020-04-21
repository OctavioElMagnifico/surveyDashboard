// This binary partitioning is still a little hardcoded. The fundamental remaining parametrization needed is taking a list of keys as arguments for the CSV nesting when it is transformed into a tree. This will be done soon.

// What this visualization does is representing a hierarchical dataset through the succesive partiotion of areas relative in their surface to a chosen variable that can be recursed through the tree. We designed it to help us give visual feedback during a survey design.

// Probably functionality should be broken between a pre procesing stage when the tree is generated and another that, fed with the tree, keys and variable name draws the partitioning.
// Two scales should be arguemnts too: one for the hierarchy stacking and another one for the topmost surfaces.

// Should take container div as argument, actually it is "#partition"

var wes_palettes = {"BottleRocket1":["#A42820","#5F5647","#9B110E","#3F5151","#4E2A1E","#550307","#0C1707"],"BottleRocket2":["#FAD510","#CB2314","#273046","#354823","#1E1E1E"],"Cavalcanti1":["#D8B70A","#02401B","#A2A475","#81A88D","#972D15"],"Chevalier1":["#446455","#FDD262","#D3DDDC","#C7B19C"],"Darjeeling1":["#FF0000","#00A08A","#F2AD00","#F98400","#5BBCD6"],"Darjeeling2":["#ECCBAE","#046C9A","#D69C4E","#ABDDDE","#000000"],"FantasticFox1":["#DD8D29","#E2D200","#46ACC8","#E58601","#B40F20"],"GrandBudapest1":["#F1BB7B","#FD6467","#5B1A18","#D67236"],"GrandBudapest2":["#E6A0C4","#C6CDF7","#D8A499","#7294D4"],"IsleofDogs1":["#9986A5","#79402E","#CCBA72","#0F0D0E","#D9D0D3","#8D8680"],"IsleofDogs2":["#EAD3BF","#AA9486","#B6854D","#39312F","#1C1718"],"Moonrise1":["#F3DF6C","#CEAB07","#D5D5D3","#24281A"],"Moonrise2":["#798E87","#C27D38","#CCC591","#29211F"],"Moonrise3":["#85D4E3","#F4B5BD","#9C964A","#CDC08C","#FAD77B"],"Royal1":["#899DA4","#C93312","#FAEFD1","#DC863B"],"Royal2":["#9A8822","#F5CDB4","#F8AFA8","#FDDDA0","#74A089"],"Rushmore":["#E1BD6D","#EABE94","#0B775E","#35274A","#F2300F"],"Rushmore1":["#E1BD6D","#EABE94","#0B775E","#35274A","#F2300F"],"Zissou1":["#3B9AB2","#78B7C5","#EBCC2A","#E1AF00","#F21A00"]};

// Tooltip is implemented as a unique floating div.
// All CCSeing is done through dymanic drawing via D3 as I wasn't sure if another way exist.

tooltip = d3.select("#partition")
    .append("div")
    .attr("id","tooltip")
    .classed("tooltip",true);

/* dynamic CSS styles */

tooltip.style("position","absolute")
    .style("text-align","center")
    .style("width","200px")
    .style("height","auto")
    .style("padding","3px")
    .style("background", "lightgray")
    .style("border-radius","10px")
    .style("pointer-events","none")
    .style("font-family","sans-serif")
    .style("display","none")
    .style("word-wrap","break-word");

tooltipTitle = tooltip.append("p")
                    .attr("id","title")
                    .append("span");

d3.select("#title")
  .style("font-size","8")
  .style("font-family","sans-serif")
  .style("font-weight","bold");

d3.select("#tooltip").selectAll("p")
  .style("margin","0")
  .style("line-height","20px");


tooltipValue = tooltip.append("p")
                      .attr("id","value")
                      .append("span")
                      .style("font-size","12px");

//To be called on hover.
var populateTooltip = function(d) {

    let xPosition = ( d.x1 - d.x0 ) * 0.5 + d3.event.pageX;
    let yPosition = ( d.y1 - d.y0 ) * 0.5 + d3.event.pageY;

    d3.select("#tooltip")
        .transition()
        .duration(300)
        .style("left", xPosition+"px" )
        .style("top", yPosition+"px" )
        .select("#value")
        .text(d.value);

    d3.select("#tooltip")
        .select("#title")
        .text(d.Id);

    d3.select("#tooltip")
        .style("display","block");
};

// Drawing of the container SVG.

var svgWidth = 500;
var svgHeight = 600;
var padding = 10;

var root;
var filterTreemap;

//generalize
var catScale = d3.scaleOrdinal()
    .domain(["grape","carrot","spinach"])
    .range( wes_palettes.Darjeeling1.slice(1) );

var wesS = wes_palettes.Darjeeling2;

var depthScale = d3.scaleLinear()
                .interpolate( d3.interpolateLab )
                .domain([0,5])
                .range([wesS[1],wesS[0]]);

// We'll use one scale for hierarchy and another one for the topmost surfaces: the current tree leaves ( with current we refer to the fact that deepness could be variable ).

var treeColoring = function(d,depth0) {
    if ( d.depth + depth0 < 4 ) { return depthScale(d.depth + depth0); }
    else { return catScale(d.data.key); }
}

//generalize: filterTreemap should be an independent const, to get that done, "visualize" <- change name! will return an object with all needed info.

var categoriesEx = [
  "climateRegion",
  "bioregion",
  "farmType",
  "crop"
];

var visualize = function( dataTree ) {

  var treeLayout = d3.treemap()
      .size([svgWidth,svgHeight])
      .padding(5)
      .paddingTop(15);

  //change "expected" name
  root = d3.hierarchy( dataTree, d => d.values )
    .sum( d => d.expected ? ( d.expected + 1 ) : undefined );

  //change svg name
    svg = d3.select("#partition")
      .append("svg")
      .attr("width",svgWidth + padding )
      .attr("height",svgHeight + padding );

    var newRoot = root;
  root.each( d => d.Id = d.path(root).filter( d => d != null ).map( d => d.data.key ).reverse().join("/") );
  newRoot.each( d => d.Id = d.path(root).filter( d => d != null ).map( d => d.data.key ).reverse().join("/") );

  var textConditionalToArea = function( d ) {
    let h = d.y1 - d.y0;
    let w = d.x1 - d.x0;
    if ( h > 10 && w > 40 ) {
      return d.data.key;
    }
  };

  // This one is in charge of drawing the actual tree and also it is able to redraw the deeper selections.

  filterTreemap = function(selArea) {
    let Id0 = selArea.parent ? selArea.parent.Id : "Target Farms" ;

    // The trouble with name generations lies here: in Id0 Î

    newRoot = selArea.copy();

    treeLayout(newRoot);
    newRoot.each( function( d ) { let array = d.path(root)
                                      .filter( d => d != null )
                                      .map( d => d.data.key )
                                      .reverse()
                                  array = uniq(array);
                                  d.Id = Id0 + '/' + array.join("/");
                                  return d;}
                );

    let depth0 = selArea.depth;

    var areas = svg.selectAll("g")
        .data(newRoot.descendants(),
              d => d.Id);

    areas.exit()
      .remove();


    /* This is the only remaining rect, the "background" */

    svg.select("rect.treeArea")
      .transition()
      .duration(300)
      .style("fill",  depthScale(depth0));

    // Here maxdepth is maxnumbered. It is not the only place. The constant to search and destroy is "5"

    areas.enter()
      .filter( d => d.depth < 5 - depth0 )
      .append("g")
      .append("rect")
      .classed("treeArea",true);

    svg.selectAll("rect.treeArea")
      .data(newRoot.descendants(),
            d => d.Id)
      .on("mouseover", d => populateTooltip(d) )
      .on("mouseout", function() {
        d3.select("#tooltip")
          .style("display","none");
      } )
      .on("click", selArea === root ?
          (p) => filterTreemap(p) : () => filterTreemap(root))
      .style("fill", d => treeColoring(d,depth0))
      .transition()
      .duration(500)
      .attr("rx","5px")
            .attr("ry","5px")
            .attr("x", d => d.x0 )
            .attr("y", d => d.y0 )
            .attr("width", d => d.x1 - d.x0 + 1 )
            .attr("height", d => d.y1 - d.y0 + 1 );

        /* .style("stroke","black"); */


        /* if the area is too small, we won't add a label, but the name would be accesible on hover */

        svg.selectAll("text")
            .transition()
            .duration(300)
            .attr("opacity",0);

        let labels = svg.selectAll("g")
                        .data(newRoot.descendants(),
                            d => d.Id)
                        .append("text");

        labels.enter()
            .append("text")
            .merge(labels)
            .text( d => textConditionalToArea(d) )
            .style("text-anchor","right")
            .attr("font-size","12")
            .attr("font-family","sans-serif")
            .style("font-weight","bold")
            .style("fill","white")
            .style("pointer-events","none")
            .attr("x", d => d.x0 + 10 )
            .attr("y", d => d.y0 + 10 )
            .text( d => textConditionalToArea(d) )
            .transition()
            .duration(600)
            .attr("opacity",1);
    };

    filterTreemap(newRoot);
}

// getting a node through searching its name on the root
// root.each( function(d) { if (d.Id == "Target Farms/stickyHot") { algo = d; } } )

// getting the same effect than with a click: filterTreemap( algo ) <---- algo is defined in the example above

d3.csv("/csv/mockupSurveyDesign.csv")
  .then( function( data )  {
    // this will be done manually at the "render" stage of the dashboard.

    let rootKey = "Target Farms";

    // function tendTree( dataset, ...ourKeys) {
    //   let tree = d3.nest();
    //   ourKeys.forEach( key => { tree =  tree.key( p => p[`${key}`] )}   )
    //   return tree.entries( dataset )
    // }
    
    // function tendTree( dataset, ...ourKeys) {
    //   let tree = d3.nest();
    //   ourKeys.reduce( (tree, key) => { return tree.key( p => p[key] ) } )
    //   return tree.entries( dataset )
    // }

    nestedData = d3.nest()
      .key( d => d.climateRegion )
      .key( d => d.bioregion )
      .key( d => d.farmType )
      .key( d => d.crop )
      .entries( data );

    var packagedNestedData = { key: rootKey, values: nestedData };

    visualize(packagedNestedData);
  }
       );

  <!-- Example of farm area selection: d3.selectAll("rect").filter( d => d.data.climateRegion == "coldButComfy" && d.data.crop == "carrot" ).style("stroke","red").attr("stroke-width",3) -->
  /* example name construction: path to root console.log(d.path(root).map( d => d.data.key )) */
/* seleccinoar todas las hojas d3.selectAll("rect").filter( d => d.depth > 3).style("fill","black") */
