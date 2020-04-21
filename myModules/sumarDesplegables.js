// This content should be extracted from parameters and the CSV.
// Should input container div, hardcoded to #form 
const defaultFieldValue = "Not Selected"
const climateOpts = [ defaultFieldValue, "coldButComfy","stickyHot","justPerfectButWithBees" ];
const biomeOpts = [ defaultFieldValue, "mostlyPandas","racoonsAndStuff","justWildKale" ];
const practiceOpts = [ defaultFieldValue, "hydro", "organic", "regen", "notill" ]
const productOpts = [ defaultFieldValue, "carrot","grape","spinach" ];

const basePath = "Target Farms"; 

const categories = [
    { name: "climateRegion", display:"Climate Region", type: "dropdown", values: climateOpts },
    { name: "biome", display: "Biome" , type: "dropdown", values: biomeOpts },
    { name: "practice", display: "Farm Practice" , type: "dropdown", values: practiceOpts },
    { name: "product", display:"Product", type: "dropdown", values: productOpts }
];

const catNames = categories.map( d => d.name );

// This should be a parameter div
const formulary = d3.select("#form").append("form").classed("treePartForm",true);

let formArray = { biome: biomeOpts[0], 
                  climateRegion: climateOpts[0],
                  practice: practiceOpts[0],
                  product: productOpts[0]
                };

let formFields = formulary.selectAll("p")
                        .data(categories)
                        .enter()
                        .append("p")
                        .each( function(d) {
                            let self = d3.select(this);

                            let label = self.append("label")
                                            .text(d.display)
                                            .style("width","100px")
                                            .style("display","inline-block");
                            /* for now, just dropdowns */
                            if ( d.type == "dropdown" ) {
                                let dropdownSel = self.append("select")
                                    .attr("name",d.display)
                                    .attr("id", d => ( d.name) )
                                    .attr("value",d.values[1])
                                    .selectAll("option")
                                    .data(d.values)
                                    .enter()
                                    .append("option")
                                    .text( function(d) { return d;} );


                                d3.selectAll("select").on( "change", function(d) { formArray[d.name] = this.value; changeCaption(); highlightSelection(formArray); } );

                                var names;

                                const changeCaption= function() {
                                    let names  = catNames.map( d => formArray[d] );
                                    caption = names.join("/");
                                    d3.select("#caption").text(caption);
                                };
                            }
                        } ) ;


// formulary.append("button").attr("type","submit").text("save").on( "submit", function(d) { console.log("aaaa"); return false; } )

d3.select("#form").append("p").append("h1").text("Select Options").attr("id","caption");

// Take care with the initial path (basePath)!
const buildTreeId = function( array ) {
    let names = catNames.map( d => array[d] );
    names.unshift(basePath);
    return names.join("/");
}

// Take care with the initial path (basePath)!
//We will search just unto the first "Not Selected" value.
const buildSearchPath = function( array ) {
    let index = catNames.map( d => formArray[d] ).findIndex( d => d == defaultFieldValue );
    let names = catNames.map( d => array[d] );
    names.unshift(basePath);
    index++;
    return names.slice(0,index).join("/");
}

// Take care with the initial path!
const refineTree = function( array ) {
    let path = buildSearchPath( array );
    var selectedNode;
    root.each( function(d) { if ( d.Id == path ) { selectedNode = d; } } );
    filterTreemap( selectedNode );
};

//This function wil build all succesive paths until the full path is reached. It will be consumed by the proceeding function.
const ladderPaths = function( array ) {
    let index = catNames.map( d => formArray[d] ).findIndex( d => d == defaultFieldValue );
    let names = catNames.map( d => array[d] );
    names.unshift(basePath);
    index =  ( index == -1 ? catNames.length+1 : ( index+1 ) ) ;
    let ladder = d3.range(index).map( function(i) {
        if ( i <= index ) { return names.slice(0, i+1 ); }
        else { return names; }
    } );
    ladder = ladder.map( d => d.join("/") );
    return ladder;
}
// To highlit a single rect, given its path
const highlightPath = function( path ) {
    d3.selectAll("rect.treeArea")
        .filter( d => d.Id == path )
        .transition()
        .duration(300)
        .attr("stroke-width","3px")
        .attr("stroke","crimson");
}

//This will receive a viable path and higlight every node involved (the "ladder" ascending up to it).
//This should be added to a listener on the treemap so selection is not lost when zooming
const highlightSelection = function( array ) {
    noHighlight();
    let ladder = ladderPaths( array );
    ladder.forEach( highlightPath );
}

const noHighlight = function() {
    d3.selectAll("rect.treeArea").attr("stroke-width","0px").attr("stroke","black")
}


// getting the same effect than with a click: filterTreemap( algo ) <---- algo is defined in the example above

