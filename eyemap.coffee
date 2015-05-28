class Dashing.Eyemap extends Dashing.Widget


  #Create dictionary of site with format [name, label, lat, long] 
  #New sites should be added here
  sites = []
  sites.push ({'name':'SG', 'label':'Singapore','lat':'0','long':'99'})
  sites.push ({'name':'JP', 'label':'Tokyo','lat':'35','long':'150'})
  sites.push ({'name':'DE', 'label':'Frankfurt', 'lat':'53','long':'40'})
  sites.push ({'name':'EU', 'label':'Ireland', 'lat':'53','long':'-35'})
  
  sites.push ({'name':'USE', 'label':'US East','lat':'34','long':'-70'})
  sites.push ({'name':'USW', 'label':'US West','lat':'34','long':'-135'})
  sites.push ({'name':'AU', 'label':'Sydney', 'lat':'-38','long':'161'})
  sites.push ({'name':'SA', 'label':'Sao Paulo', 'lat':'-38','long':'-56'})
  sites.push ({'name':'KDDI', 'label':'KDDI','lat':'-65','long':'90'})

  #Default gauge radius 
  gauge_radius = 200


  vpn_paths = [{"origin":{"latitude":sites[0].lat,"longitude":sites[0].long}, "destination":{"latitude":sites[1].lat,"longitude":sites[1].long}}] 

  gauges =[]
  config = {}

  #Create Gauge function to render SVG Gauge
  #Uses heavily modified gauge.js class
  createNewGauge = (name, label, min, max, pos_x, pos_y, g_radius, svgObj) ->
    #console.log("Calling createNewGauge")
    config = 
    {
        size: g_radius
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

    
  fadeSwitchElements = (svgElement, id, newValue) ->
    element1 = svgElement.getElementById(id)
    element1.innerHTML = newValue
    parent = element1.parentNode
    parent.animate({fontSize: "3em"})
    parent.animate({fontSize: "1.5em"})

  #Helper Method to update the arcs with new values
  updateArcs = (svgObj, sites, prefix, d_key, data) ->
    #Pull out vpn values from data
    for s in sites
     if(s.name == 'KDDI')
      #Do nothing
     else
      country_key = s.name.toLowerCase()

      #Update the TO value
      el_id = prefix+"_to_"+s.name
      console.log(el_id)
      data_key = d_key+"_to_"+country_key
      #kb_val = (data[data_key]/1024).toFixed(2)
      kb_val = Math.round(data[data_key]/1024)

      unit = "KB/s"

      if (kb_val >= 1024)
        kb_val = (kb_val/1024).toFixed(1)
        unit = "MB/s"

      if(s.name == 'JP' || s.name == 'AU' || s.name == 'SG' )
       kb_val = kb_val + " "+unit+"  >>"
      else
       kb_val = "<< "+ kb_val + " "+unit
      
      if(svgObj.getElementById(el_id) != null)
        svgObj.getElementById(el_id).innerHTML = kb_val
        #fadeSwitchElements(svgObj, el_id, kb_val)

      #Update the FROM value
      el_id = prefix+"_fro_"+s.name
      data_key = d_key+"_fro_"+country_key
      #kb_val = (data[data_key]/1024).toFixed(2)
      kb_val = Math.round(data[data_key]/1024)

      unit = "KB/s"

      if (kb_val >= 1024)
        kb_val = (kb_val/1024).toFixed(1)
        unit = "MB/s"

      if(s.name == 'JP' || s.name == 'AU' || s.name == 'SG')
       kb_val = "<< "+ kb_val + " "+unit
      else
       kb_val = kb_val + " "+unit+"  >>"

      if(svgObj.getElementById(el_id) != null)
        svgObj.getElementById(el_id).innerHTML = kb_val

  #Helper Method to update the arcs with new values
  updateSiteArcs = (svgObj, sites, prefix, d_key, data) ->
    #Pull out vpn values from data
    for s in sites
     if(s.name == 'KDDI')
      #Do nothing
     else
      country_key = s.name.toLowerCase()

      #Update the TO value
      el_id = prefix+"_to_"+s.name
      console.log(el_id)
      data_key = d_key+"_to_"+country_key
      kb_val = Math.round(data[data_key]/1024)

      unit = "KB/s"

      if (kb_val >= 1024)
        kb_val = (kb_val/1024).toFixed(1)
        unit = "MB/s"

      if(s.name == "USW" || s.name == "EU")
        kb_val = "<< "+ kb_val + " "+unit
      else 
        kb_val = kb_val + " "+unit+"  >>"     

    
      if(svgObj.getElementById(el_id) != null)
        svgObj.getElementById(el_id).innerHTML = kb_val

      #Update the FROM value
      el_id = prefix+"_fro_"+s.name
      data_key = d_key+"_fro_"+country_key
      kb_val = Math.round(data[data_key]/1024)
      unit = "KB/s"

      if (kb_val >= 1024)
        kb_val = (kb_val/1024).toFixed(1)
        unit = "MB/s"

      if(s.name == "USW" || s.name == "EU")
        kb_val = kb_val + " "+unit+" >>"   
      else 
        kb_val = "<< "+ kb_val + " "+unit
      
      if(svgObj.getElementById(el_id) != null)
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
      path_offset = "50%"

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
       path_offset = "70%"

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
       origin = this.latLngToXY("-40","-130")
       g_radius = 300
       path_text = layer.append("svg:text").attr("text-anchor","middle").attr("x",origin[0]).attr("y",origin[1])
                                           #.attr("dx",g_radius/2)
                                           .attr("dy",(g_radius/2)+30)
                                           .style("font-size", g_radius/12+"px").style("font-weight", "bold");
       path_text.text("KDDI - Singapore")
       path_text.append("svg:tspan").attr("x",origin[0])
                                   .attr("dy",g_radius/10)
                                   #.attr("dx",g_radius/2)
                                   .attr("id",el_id1)
       path_text.append("svg:tspan").attr("x",origin[0])
                                   .attr("dy",g_radius/10)
                                   #.attr("dx",g_radius/2)
                                   .attr("id",el_id2)
      else 
       path.attr("id","vpn"+k.name)
       path.attr("d",d_arc)
       #Create 2 text properties on the arc lines to show the throughput
       path_text = layer.append("svg:text").attr("text-anchor","middle").attr("dy",el_dy1)
       path_text.append("svg:textPath").attr("id",el_id1).attr("startOffset",path_offset).attr("xlink:href","#vpn"+k.name).attr("class","textPath")
       #path_text.append("animate").attr("xlink:href","#"+el_id1).attr("attributeName","startOffset").attr("values","0;.5;1").attr("dur","8s").attr("repeatCount","indefinite").attr("keyTimes","0;.5;1")

       path_text = layer.append("svg:text").attr("text-anchor","middle").attr("dy",el_dy2)
       path_text.append("svg:textPath").attr("id",el_id2).attr("startOffset",path_offset).attr("xlink:href","#vpn"+k.name).attr("class","textPath")
       #path_text.append("animate").attr("xlink:href","#"+el_id2).attr("attributeName","startOffset").attr("values","1;.5;0").attr("dur","8s").attr("repeatCount","indefinite").attr("keyTimes","0;.5;1")
    )

    #Call the custom datamap plugin
    map.createVPNLinksToSG(sites)

    map.addPlugin('createVPNLinksToSites',( layer, data) -> 
     #Set the origin points
     #US - East
     origin_use = this.latLngToXY(data[4].lat,data[4].long)
     #DE
     origin_de = this.latLngToXY(data[2].lat,data[2].long)
     
     for k in data     
      #Put element names into variables
      el_id1 = "val_vpn_site_fro_"+k.name
      el_id2 = "val_vpn_site_to_"+k.name

      #Put the
      el_dy1 = "-10"
      el_dy2 = "20"
      path_offset = "50%"
      path = layer.append("svg:path")

      #Create links between US East, US West and South America
      if (k.name == 'SA')
        dest = origin_use
        origin = this.latLngToXY(k.lat,k.long)
        
        el_dy1 = "20"
        el_dy2 = "-10"

        d_arc = "M"+dest[0]+","+dest[1]+" A 50 20 50 0 1 "+origin[0]+","+origin[1]
        path.attr("id","vpn_site"+k.name)
        path.attr("d",d_arc)
        path_offset = "30%"

        #Create 2 text properties on the arc lines to show the throughput
        path_text = layer.append("svg:text").attr("text-anchor","middle").attr("dy",el_dy1)
        path_text.append("svg:textPath").attr("id",el_id1).attr("startOffset",path_offset).attr("xlink:href","#vpn_site"+k.name).attr("class","textPath")

        path_text = layer.append("svg:text").attr("text-anchor","middle").attr("dy",el_dy2)
        path_text.append("svg:textPath").attr("id",el_id2).attr("startOffset",path_offset).attr("xlink:href","#vpn_site"+k.name).attr("class","textPath")


      else if (k.name == 'USW')
        dest = origin_use
        origin = this.latLngToXY(k.lat,k.long)

        d_arc = "M"+origin[0]+","+origin[1]+" L"+dest[0]+","+dest[1]
        path.attr("id","vpn_site"+k.name)
        path.attr("d",d_arc)

        #Create 2 text properties on the arc lines to show the throughput
        path_text = layer.append("svg:text").attr("text-anchor","middle").attr("dy",el_dy1)
        path_text.append("svg:textPath").attr("id",el_id1).attr("startOffset",path_offset).attr("xlink:href","#vpn_site"+k.name).attr("class","textPath")

        path_text = layer.append("svg:text").attr("text-anchor","middle").attr("dy",el_dy2)
        path_text.append("svg:textPath").attr("id",el_id2).attr("startOffset",path_offset).attr("xlink:href","#vpn_site"+k.name).attr("class","textPath")

      else if (k.name == 'EU')
        dest = origin_de  
        origin = this.latLngToXY(k.lat,k.long)

        d_arc = "M"+origin[0]+","+origin[1]+" L"+dest[0]+","+dest[1]
        path.attr("id","vpn_site"+k.name)
        path.attr("d",d_arc)

        #Create 2 text properties on the arc lines to show the throughput
        path_text = layer.append("svg:text").attr("text-anchor","middle").attr("dy",el_dy1)
        path_text.append("svg:textPath").attr("id",el_id1).attr("startOffset",path_offset).attr("xlink:href","#vpn_site"+k.name).attr("class","textPath")

        path_text = layer.append("svg:text").attr("text-anchor","middle").attr("dy",el_dy2)
        path_text.append("svg:textPath").attr("id",el_id2).attr("startOffset",path_offset).attr("xlink:href","#vpn_site"+k.name).attr("class","textPath")

      else
        #Do nothing



    )
    
    map.createVPNLinksToSites(sites)

      

    #Create the gauges for each site by using the Datamaps Plugin functionality.
    #This will append a <g> element to the main svg element created by Datamaps
    map.addPlugin('createGaugeSG', ( layer, data) ->   
        name = data.name
        label = data.label
        coords = this.latLngToXY(data.lat,data.long)
        createNewGauge(name, label, 0, 2000, coords[0], coords[1], gauge_radius, layer)
    )

    map.addPlugin('createGaugeJP', ( layer, data) ->   
        name = data.name
        label = data.label
        coords = this.latLngToXY(data.lat,data.long)
        createNewGauge(name, label, 0, 2000, coords[0], coords[1], gauge_radius, layer) 
    )

    map.addPlugin('createGaugeDE', ( layer, data) ->   
        name = data.name
        label = data.label
        coords = this.latLngToXY(data.lat,data.long)
        createNewGauge(name, label, 0, 2000, coords[0], coords[1], gauge_radius, layer) 
    )

    map.addPlugin('createGaugeEU', ( layer, data) ->   
        name = data.name
        label = data.label
        coords = this.latLngToXY(data.lat,data.long)
        createNewGauge(name, label, 0, 2000, coords[0], coords[1], gauge_radius, layer) 
    )

    map.addPlugin('createGaugeUSE', ( layer, data) ->   
        name = data.name
        label = data.label
        coords = this.latLngToXY(data.lat,data.long)
        createNewGauge(name, label, 0, 2000, coords[0], coords[1], gauge_radius, layer) 
    )

    map.addPlugin('createGaugeUSW', ( layer, data) ->   
        name = data.name
        label = data.label
        coords = this.latLngToXY(data.lat,data.long)
        createNewGauge(name, label, 0, 2000, coords[0], coords[1], gauge_radius, layer) 
    )

    map.addPlugin('createGaugeAU', ( layer, data) ->   
        name = data.name
        label = data.label
        coords = this.latLngToXY(data.lat,data.long)
        createNewGauge(name, label, 0, 2000, coords[0], coords[1], gauge_radius, layer) 
    )

    map.addPlugin('createGaugeSA', ( layer, data) ->   
        name = data.name
        label = data.label
        coords = this.latLngToXY(data.lat,data.long)
        createNewGauge(name, label, 0, 2000, coords[0], coords[1], gauge_radius, layer) 
    )

    map.addPlugin('createGaugeGlobal', (layer) ->   
        name = "GLB"
        label = "Global"
        coords = this.latLngToXY("-40","-130")
        createNewGauge(name, label, 0, 16000, coords[0], coords[1], 360, layer) 
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
    map.createGaugeGlobal()


    #Render Gauges
    gauges["SG"].render()
    gauges["JP"].render()
    gauges["DE"].render()
    gauges["EU"].render()
    gauges["USE"].render()
    gauges["USW"].render()
    gauges["AU"].render()
    gauges["SA"].render()
    gauges["GLB"].render()


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
    gauges["GLB"].redraw(data.value_global)

    #Get the Container element for the arc Paths
    arc_container = document.getElementsByClassName('datamap').item(0)

    #arc_container.getElementById(el_jp).innerHTML = kb_val.toString() + " bytes/s >"

    updateArcs(arc_container, sites, "val_vpn","vpn",data)
    updateSiteArcs(arc_container, sites, "val_vpn_site","vpn_site",data)
    #updateSiteArcs(arc_container, sites, "val_vpn_site","vpn_de",data)




      

