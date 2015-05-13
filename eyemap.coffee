class Dashing.Eyemap extends Dashing.Widget

  #Create dictionary of site with format [name, label, lat, long] 
  #New sites should be added here
  sites = []
  sites.push ({'name':'SG', 'label':'Singapore','lat':'1','long':'108'})
  sites.push ({'name':'JP', 'label':'Tokyo','lat':'35','long':'139'})
  sites.push ({'name':'DE', 'label':'Frankfurt', 'lat':'52','long':'20'})
  sites.push ({'name':'EU', 'label':'Ireland', 'lat':'53','long':'-13'})
  
  sites.push ({'name':'USE', 'label':'US East','lat':'37','long':'-79'})
  sites.push ({'name':'USW', 'label':'US West','lat':'38','long':'-120'})
  sites.push ({'name':'AU', 'label':'Sydney', 'lat':'-33','long':'151'})
  sites.push ({'name':'SA', 'label':'Sao Paulo', 'lat':'-23','long':'-46'})

  gauges =[]
  config = {}

  #Create Gauge function to render SVG Gauge
  #Uses heavily modified gauge.js class
  createNewGauge = (name, label, min, max, pos_x, pos_y, svgObj) ->
    console.log("Calling createNewGauge")
    config = 
    {
        size: 120
        label: label
        #min: undefined != min ? min : 0
        #max: undefined != max ? max : 100
        majorTicks: 10
        minorTicks: 5
        cx: pos_x
        cy: pos_y
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

    

  #Placeholder to create random data for testing
  getRandomValue = (gauge) ->
    overflow = 0
    #return gauge.config.min - overflow + (gauge.config.max - gauge.config.min + overflow*2) *  Math.random()
    return (gauge.config.max + 10000 )* Math.random()
  
 
  ready: ->
    container = $(@node).parent()
    width = (Dashing.widget_base_dimensions[0] * container.data("sizex")) + Dashing.widget_margins[0] * 2 * (container.data("sizex") - 1)
    height = (Dashing.widget_base_dimensions[1] * container.data("sizey"))


    #Create datamap
    map_container = document.getElementById('map_container')
    map_container.style.width= "1860px"
    map_container.style.height= "720px"

    #console.log("Width in px is :")
    #map_container.style.width= '\"'+width.toString+'px\"'
    #map_container.style.height= '\"'+height.toString+'px\"'


    map = new Datamap({element: map_container,   geographyConfig: {
            highlightOnHover: false,
            popupOnHover: false
            }
        })

    #Create the gauges for each site by using the Datamaps Plugin functionality.
    #This will append a <g> element to the main svg element created by Datamaps
    map.addPlugin('createGaugeSG', ( layer, data) ->   
        name = data.name
        label = data.label
        coords = this.latLngToXY(data.lat,data.long)
        createNewGauge(name, label, 0, 2000, coords[0], coords[1], layer) 
    )

    map.addPlugin('createGaugeJP', ( layer, data) ->   
        name = data.name
        label = data.label
        coords = this.latLngToXY(data.lat,data.long)
        createNewGauge(name, label, 0, 2000, coords[0], coords[1], layer) 
    )

    map.addPlugin('createGaugeDE', ( layer, data) ->   
        name = data.name
        label = data.label
        coords = this.latLngToXY(data.lat,data.long)
        createNewGauge(name, label, 0, 2000, coords[0], coords[1], layer) 
    )

    map.addPlugin('createGaugeEU', ( layer, data) ->   
        name = data.name
        label = data.label
        coords = this.latLngToXY(data.lat,data.long)
        createNewGauge(name, label, 0, 2000, coords[0], coords[1], layer) 
    )

    map.addPlugin('createGaugeUSE', ( layer, data) ->   
        name = data.name
        label = data.label
        coords = this.latLngToXY(data.lat,data.long)
        createNewGauge(name, label, 0, 2000, coords[0], coords[1], layer) 
    )

    map.addPlugin('createGaugeUSW', ( layer, data) ->   
        name = data.name
        label = data.label
        coords = this.latLngToXY(data.lat,data.long)
        createNewGauge(name, label, 0, 2000, coords[0], coords[1], layer) 
    )

    map.addPlugin('createGaugeAU', ( layer, data) ->   
        name = data.name
        label = data.label
        coords = this.latLngToXY(data.lat,data.long)
        createNewGauge(name, label, 0, 2000, coords[0], coords[1], layer) 
    )

    map.addPlugin('createGaugeSA', ( layer, data) ->   
        name = data.name
        label = data.label
        coords = this.latLngToXY(data.lat,data.long)
        createNewGauge(name, label, 0, 2000, coords[0], coords[1], layer) 
    )


    #Initialize the gauge object for each site into the Datamap element
    map.createGaugeSG(sites[0])
    map.createGaugeJP(sites[1])
    map.createGaugeDE(sites[2])
    map.createGaugeEU(sites[3])
    map.createGaugeUSE(sites[4])
    map.createGaugeUSW(sites[5])
    map.createGaugeAU(sites[6])
    map.createGaugeSA(sites[7])



    gauges["SG"].render()
    gauges["JP"].render()
    gauges["DE"].render()
    gauges["EU"].render()
    gauges["USE"].render()
    gauges["USW"].render()
    gauges["AU"].render()
    gauges["SA"].render()



  onData: (data) ->

    sg_max_val = parseInt getRandomValue(gauges["SG"])
    #Update each gauges every time there is new data sent from the Dashing job scheduler
    gauges["SG"].redraw(parseInt(data.value_sg), null, sg_max_val)
    gauges["JP"].redraw(parseInt(data.value_jp))
    gauges["DE"].redraw(parseInt(data.value_de))
    gauges["EU"].redraw(parseInt(data.value_eu))

    gauges["USE"].redraw(parseInt(data.value_us_e))
    gauges["USW"].redraw(parseInt(data.value_us_w))
    gauges["AU"].redraw(parseInt(data.value_au))
    gauges["SA"].redraw(parseInt(data.value_sa))
      

