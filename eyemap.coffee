class Dashing.Eyemap extends Dashing.Widget


  #Create dictionary of site with format [name, label, lat, long] 
  #New sites should be added here
  sites = []
  sites.push ({'name':'SG', 'label':'Singapore','lat':'0','long':'99'})
  sites.push ({'name':'JP', 'label':'Tokyo','lat':'35','long':'150'})
  sites.push ({'name':'DE', 'label':'Frankfurt', 'lat':'53','long':'20'})
  sites.push ({'name':'EU', 'label':'Ireland', 'lat':'53','long':'-13'})
  
  sites.push ({'name':'USE', 'label':'US East','lat':'37','long':'-79'})
  sites.push ({'name':'USW', 'label':'US West','lat':'37','long':'-120'})
  sites.push ({'name':'AU', 'label':'Sydney', 'lat':'-38','long':'161'})
  sites.push ({'name':'SA', 'label':'Sao Paulo', 'lat':'-34','long':'-56'})
  sites.push ({'name':'KDDI', 'label':'KDDI','lat':'-65','long':'90'})

  #Default gauge radius 
  gauge_radius = 160


  vpn_paths = [{"origin":{"latitude":sites[0].lat,"longitude":sites[0].long}, "destination":{"latitude":sites[1].lat,"longitude":sites[1].long}}] 

  gauges =[]
  config = {}

  #Create Gauge function to render SVG Gauge
  #Uses heavily modified gauge.js class
  createNewGauge = (name, label, min, max, pos_x, pos_y, svgObj) ->
    #console.log("Calling createNewGauge")
    config = 
    {
        size: gauge_radius
        label: label
        #min: undefined != min ? min : 0
        #max: undefined != max ? max : 100
        majorTicks: 4
        minorTicks: 0
        cx: pos_x
        cy: pos_y
    }
    config.min = min
    config.max = max
    range = config.max - config.min
    config.yellowZones = [{ from: config.min + range*0.75, to: config.min + range*0.9 }]
    config.redZones = [{ from: config.min + range*0.9, to: config.max }]
    gauges[name] = new Gauge(name + "GaugeContainer", config, svgObj)

    
  #Placeholder to create random data for testing
  getRandomValue = (gauge) ->
    overflow = 0
    #return gauge.config.min - overflow + (gauge.config.max - gauge.config.min + overflow*2) *  Math.random()
    return (gauge.config.max + 10000 )* Math.random()

  getPathMidPoint = (pathObj) ->
   bbox = pathObj[0][0].getBBox()
   line_center =[(Math.floor(bbox.x + bbox.width/2.0)), (Math.floor(bbox.y + bbox.height/2.0))]

  #Helper Method to update the arcs with new values
  updateArcs = (svgObj, sites, prefix, data) ->
    #Pull out vpn values from data
    for s in sites
     if(s.name == 'KDDI')
      #Do nothing
     else
      country_key = s.name.toLowerCase()

      #Update the TO value
      el_id = prefix+"_to_"+s.name
      data_key = "vpn_to_"+country_key
      kb_val = (data[data_key]/1024).toFixed(2)
     
      if(s.name == 'JP' || s.name == 'AU' || s.name == 'SG' )
       kb_val = kb_val + " KB/s  >>"
      else
       kb_val = "<< "+ kb_val + " KB/s"

      svgObj.getElementById(el_id).innerHTML = kb_val

      #Update the FROM value
      el_id = prefix+"_fro_"+s.name
      data_key = "vpn_fro_"+country_key
      kb_val = (data[data_key]/1024).toFixed(2)

      if(s.name == 'JP' || s.name == 'AU' || s.name == 'SG')
       kb_val = "<< "+ kb_val + " KB/s"
      else
       kb_val = kb_val + " KB/s  >>"

      svgObj.getElementById(el_id).innerHTML = kb_val

 
  ready: ->
    container = $(@node).parent()
    width = (Dashing.widget_base_dimensions[0] * container.data("sizex")) + Dashing.widget_margins[0] * 2 * (container.data("sizex") - 1)
    height = (Dashing.widget_base_dimensions[1] * container.data("sizey"))
    console.log("Container width would have been "+ String(width)+"px")
    console.log("Container width would have been "+ String(height)+"px")


    #Create datamap
    #map_container = document.getElementById('map_container')
    map_container = document.getElementsByClassName('widget widget-eyemap eyemap').item(0)
    #map_container.style.width= "1850px"
    #map_container.style.height= "1100px"

    #console.log("Width in px is :")
    #map_container.style.width=String(width)+"px"
    #map_container.style.height=String(height)+"px"


    map = new Datamap({element: map_container, geographyConfig: {
              borderWidth: 0,
              borderColor: '#FFFFFF',
              highlightOnHover: false,
              popupOnHover: false
            }, fills: {
              defaultFill: '#FFFFFF' 
            }
        })

    #window.addEventListener('resize', () ->
    #    map.resize();
    #)

    #Create arc representations of VPN links from SG AWS site to the other AWS sites
    #Super messy hack 
    map.addPlugin('createVPNLinksToSG',(layer, data) ->
     #Set origin as Singapore
     origin = this.latLngToXY(data[0].lat,data[0].long)

     #Generate VPN links paths from Singapore to all 7 sites
     for k in data
      origin = this.latLngToXY(data[0].lat,data[0].long)
      dest = this.latLngToXY(k.lat,k.long)
      path = layer.append("svg:path")

      #Put element names into variables
      el_id1 = "val_vpn_fro_"+k.name
      el_id2 = "val_vpn_to_"+k.name

      #Put the
      el_dy1 = "-10"
      el_dy2 = "20"

      #Configure individual Path d element. Hate this part coz its messy 
      if (k.name == 'JP')
       d_arc = "M"+origin[0]+","+origin[1]+" A 20 30 90 0 0 "+dest[0]+","+dest[1]

      else if (k.name == 'AU')
       #d_arc = "M"+origin[0]+","+origin[1]+" A 20 10 45 0 0 "+dest[0]+","+dest[1]
       d_arc = "M"+origin[0]+","+origin[1]+" L"+dest[0]+","+dest[1]

      else if (k.name =='DE')
       #Reverse the origin and destination point so the arc will show the text right side up
       d_arc = "M"+dest[0]+","+dest[1]+" A 10 20 -45 0 1 "+origin[0]+","+origin[1]

      else if (k.name == 'USW')
       d_arc = "M"+dest[0]+","+dest[1]+" A 100 30 5 0 0 "+origin[0]+","+origin[1]

      else if (k.name == 'SA')
       d_arc = "M"+dest[0]+","+dest[1]+" A 100 50 -15 0 0 "+origin[0]+","+origin[1]

      else if (k.name == 'EU' || k.name == 'USE')
       d_arc = "M"+dest[0]+","+dest[1]+" L"+origin[0]+","+origin[1]

      else
        d_arc = "M"+origin[0]+","+origin[1]+" L "+dest[0]+","+dest[1]


      #Generate Paths
      if(k.name == 'KDDI')
       #No need to create KDDI link
      else if (k.name == 'SG')
       #Create a text field instead of a link path to show KDDI links
       path_text = layer.append("svg:text").attr("text-anchor","middle").attr("x",origin[0]).attr("y",origin[1]).attr("dx",gauge_radius).attr("dy","-"+(gauge_radius-70)).style("font-size", gauge_radius/8+"px").style("font-weight", "bold");
       path_text.text("KDDI")
       path_text.append("svg:tspan").attr("x",origin[0]).attr("dy",gauge_radius/8).attr("dx",gauge_radius).attr("id",el_id1)
       path_text.append("svg:tspan").attr("x",origin[0]).attr("dy",gauge_radius/8).attr("dx",gauge_radius).attr("id",el_id2)
      else 
       path.attr("id","vpn"+k.name)
       path.attr("d",d_arc)
       #Create 2 text properties on the arc lines to show the throughput
       path_text = layer.append("svg:text").attr("text-anchor","middle").attr("dy",el_dy1)
       path_text.append("svg:textPath").attr("id",el_id1).attr("startOffset","50%").attr("xlink:href","#vpn"+k.name).attr("class","textPath")
       #path_text.append("animate").attr("xlink:href","#"+el_id1).attr("attributeName","startOffset").attr("values","0;.5;1").attr("dur","8s").attr("repeatCount","indefinite").attr("keyTimes","0;.5;1")

       path_text = layer.append("svg:text").attr("text-anchor","middle").attr("dy",el_dy2)
       path_text.append("svg:textPath").attr("id",el_id2).attr("startOffset","50%").attr("xlink:href","#vpn"+k.name).attr("class","textPath")
       #path_text.append("animate").attr("xlink:href","#"+el_id2).attr("attributeName","startOffset").attr("values","1;.5;0").attr("dur","8s").attr("repeatCount","indefinite").attr("keyTimes","0;.5;1")
    )

    #Call the custom datamap plugin
    map.createVPNLinksToSG(sites)

    #map.addPlugin('createVPNLinksBetweenSites',(layer, data) ->

      

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

    # map.addPlugin('createGaugeKDDI', ( layer, data) ->   
    #     name = data.name
    #     label = data.label
    #     coords = this.latLngToXY(data.lat,data.long)
    #     kddi_circle = layer.append("svg:circle").attr("cx",coords[0]).attr("cy",coords[1]).attr("r",20)
    #     kddi_circle.attr("fill","blue")
    #     kddi_circle.style("stroke-linecap","round")
    #     kddi_circle.style("stroke","white")
    #     #kddi_circle.style
    #     kddi_text = layer.append("svg:text").attr("x",coords[0]).attr("y",coords[1]).text("KDDI")
    #     kddi_text.attr("text-anchor","middle")
    #     kddi_text.attr("dy", 40)
    # )


    #Initialize the gauge object for each site into the Datamap element
    map.createGaugeSG(sites[0])
    map.createGaugeJP(sites[1])
    map.createGaugeDE(sites[2])
    map.createGaugeEU(sites[3])
    map.createGaugeUSE(sites[4])
    map.createGaugeUSW(sites[5])
    map.createGaugeAU(sites[6])
    map.createGaugeSA(sites[7])
    #map.createGaugeKDDI(sites[8])


    #Render Gauges
    gauges["SG"].render()
    gauges["JP"].render()
    gauges["DE"].render()
    gauges["EU"].render()
    gauges["USE"].render()
    gauges["USW"].render()
    gauges["AU"].render()
    gauges["SA"].render()


  onData: (data) ->
    #Update each gauges every time there is new data sent from the Dashing job scheduler
    gauges["SG"].redraw(data.value_sg)
    gauges["JP"].redraw(data.value_jp)
    gauges["DE"].redraw(data.value_de)
    gauges["EU"].redraw(data.value_eu)
    gauges["USE"].redraw(data.value_us_e)
    gauges["USW"].redraw(data.value_us_w)
    gauges["AU"].redraw(data.value_au)
    gauges["SA"].redraw(data.value_sa)

    #Get the Container element for the arc Paths
    arc_container = document.getElementsByClassName('datamap').item(0)

    #Set the Element name prefix
    prefix = "val_vpn_"

    el_jp = prefix+"to_"+"JP"
    data_key = "vpn_to_"+"jp"
    kb_val = (data[data_key]/1024)

    #arc_container.getElementById(el_jp).innerHTML = kb_val.toString() + " bytes/s >"

    updateArcs(arc_container, sites, "val_vpn",data)





      

