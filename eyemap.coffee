class Dashing.Eyemap extends Dashing.Widget
  loc_sg =[1,108]

  gauges =[]

  #Create Gauge function
  createNewGauge = (name, label, min, max, svgObj) ->
    console.log("Calling createGauge")
    config = 
    {
        size: 120,
        label: label,
        #min: undefined != min ? min : 0,
        #max: undefined != max ? max : 100,
        minorTicks: 5
        cx: 120
        cy: 360
    }
    config.min = min
    config.max = max
    console.log(config.cx)
    console.log(config.cy)
    range = config.max - config.min
    config.yellowZones = [{ from: config.min + range*0.75, to: config.min + range*0.9 }]
    config.redZones = [{ from: config.min + range*0.9, to: config.max }]
    console.log(config.yellowZones)
    console.log(config.redZones)
    gauges[name] = new Gauge(name + "GaugeContainer", config, svgObj)
    gauges[name].render()

  #Placeholder for data
  getRandomValue = (gauge) ->
    overflow = 0
    return gauge.config.min - overflow + (gauge.config.max - gauge.config.min + overflow*2) *  Math.random()
  
  #Update gauge value
  updateGauges =  ->
    for key in gauges
       value = getRandomValue(gauges[key])
       gauges[key].redraw(value)

  
 

  ready: ->
    container = $(@node).parent()
    width = (Dashing.widget_base_dimensions[0] * container.data("sizex")) + Dashing.widget_margins[0] * 2 * (container.data("sizex") - 1)
    height = (Dashing.widget_base_dimensions[1] * container.data("sizey"))


    #Create SVG Map Object
    map_container = d3.select(@node).append("svg:svg")
        .attr("width", width)
        .attr("height", height)
 

    #Set projection
    projection = d3.geo.mercator()
        .center([0,20])
        .scale(250)
        .translate([width / 2, height / 2]);

    path = d3.geo.path()
      .projection(projection)
         
    g = map_container.append("g")

    #Load Map JSON
    d3.json("/world-10m.json", (error, topology) -> 
       g.selectAll("path")
        .data(topojson.feature(topology, topology.objects.countries)
               .features)
         .enter()
           .append("path")
           .attr("d", path))

    #Create canvas
    #gauge_canvas = document.createElement('canvas')
    #gauge_canvas.width = 1850
    #gauge_canvas.height = 720
    #container.append(gauge_canvas)

    meter = $(@node).find(".meter")
    #meter.attr("data-bgcolor", "#FF0000")
    #meter.attr("data-fgcolor", "#66FFCC")
    meter.knob()




    gauge_container = d3.select(@node).append("gauge_container")
            .attr("width", width)
            .attr("height",height)

    createNewGauge("SG", "Singapore", 0, 200, gauge_container)
    


  #onData: (data) ->
  #  if (Dashing.widget_base_dimensions)
  #    container = $(@node).parent()

