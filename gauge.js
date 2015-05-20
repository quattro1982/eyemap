function Gauge(placeholderName, configuration, svgObj)
{
    this.placeholderName = placeholderName;
    
    var self = this; // for internal d3 functions


    this.configure = function(configuration)
    {
        this.config = configuration;
        
        this.config.size = this.config.size * 0.9;
        
        this.config.raduis = this.config.size * 0.97 / 2;
        this.config.cx = configuration.cx;
        this.config.cy = configuration.cy;
        //this.config.cy = this.config.size /2;
        //this.config.cx = this.config.size /2;
        //this.config.cy = this.config.size /2;
        
        this.config.min = undefined != configuration.min ? configuration.min : 0; 
        this.config.max = undefined != configuration.max ? configuration.max : 100; 
        this.config.range = this.config.max - this.config.min;
        
        this.config.majorTicks = configuration.majorTicks || 5;
        this.config.minorTicks = configuration.minorTicks || 2;
        
        this.config.greenColor  = configuration.greenColor || "#109618";
        this.config.yellowColor = configuration.yellowColor || "#FF9900";
        this.config.redColor    = configuration.redColor || "#DC3912";
        
        this.config.transitionDuration = configuration.transitionDuration || 500;
    }



    this.render = function()
    {
        this.body = svgObj;
        //this.body = svgObj.append("svg:svg")
        //                 .attr("class", "gauge")
        //                  .attr("width", this.config.size)
        //                  .attr("height", this.config.size);
        
        this.body.append("svg:circle")
                    .attr("cx", this.config.cx)
                    .attr("cy", this.config.cy)
                    .attr("r", this.config.raduis)
                    .style("fill", "#000")
                    .style("stroke", "#000")
                    .style("stroke-width", "0.5px");
                    
        this.body.append("svg:circle")
                    .attr("cx", this.config.cx)
                    .attr("cy", this.config.cy)
                    .attr("r", 0.9 * this.config.raduis)
                    .style("fill", "#fff")
                    .style("stroke", "#e0e0e0")
                    .style("stroke-width", "2px");
                    
        for (var index in this.config.greenZones)
        {
            this.drawBand(this.config.greenZones[index].from, this.config.greenZones[index].to, self.config.greenColor);
        }
        
        for (var index in this.config.yellowZones)
        {
            this.drawBand(this.config.yellowZones[index].from, this.config.yellowZones[index].to, self.config.yellowColor);
        }
        
        for (var index in this.config.redZones)
        {
            this.drawBand(this.config.redZones[index].from, this.config.redZones[index].to, self.config.redColor);
        }

        //Label Text
        if (undefined != this.config.label)
        {
            var fontSize = Math.round(this.config.size / 8);
            this.body.append("svg:text")
                        .attr("x", this.config.cx)
                        .attr("y", this.config.cy  - (fontSize / 2) - (this.config.size/2) )
                        .attr("dy", fontSize / 2)
                        .attr("text-anchor", "middle")
                        .text(this.config.label)
                        .style("font-size", fontSize + "px")
                        .style("fill", "#333")
                        .style("stroke-width", "0px")
                        .style("font-weight", "bold");
        }




        //Append Text for Max value
        var point = this.valueToPoint(this.config.max, 0.63);



        var fontSize = Math.round(this.config.size / 12);


        //this.generateLines(fontSize);

        this.body.append("svg:text")
            .attr("id", "maxlabel")
            .attr("x", this.config.cx)
            .attr("y", this.config.cy + ((this.config.size /2) * 0.7))
            .attr("dy", fontSize / 3)
            .attr("text-anchor", "middle")
            .text(this.config.max)
            .style("font-size", fontSize + "px")
            .style("fill", "#333")
            .style("stroke-width", "0px");


        
        var pointerContainer = this.body.append("svg:g").attr("class", "pointerContainer");
        
        var midValue = (this.config.min + this.config.max) / 2;
        
        var pointerPath = this.buildPointerPath(midValue);
        console.log(pointerPath)
        
        var pointerLine = d3.svg.line()
                                    .x(function(d) { return d.x })
                                    .y(function(d) { return d.y })
                                    .interpolate("basis");
        //Needle
       pointerContainer.selectAll("path")
                           .data([pointerPath])
                           .enter()
                               .append("svg:path")
                                   .attr("d", pointerLine)
                                   //.style("fill", "#dc3912")
                                   .style("fill","#000000")
                                   .style("stroke", "#000000")
                                   //.style("fill-opacity", 0.7)
                   
       pointerContainer.append("svg:circle")
                           .attr("cx", this.config.cx)
                           .attr("cy", this.config.cy)
                           //.attr("r", 0.12 * this.config.raduis)
                           .attr("r", 0.6 * this.config.raduis)
                           //.style("fill", "#4684EE")
                           .style("fill", "#000")
                           //.style("stroke", "#666")
                           .style("stroke", "#000")
                           .style("opacity", 1);
        
        var fontSize = Math.round(this.config.size / 4);
        pointerContainer.selectAll("text")
                            .data([midValue])
                            .enter()
                                .append("svg:text")
                                    .attr("id", "g_value")
                                    .attr("x", this.config.cx)
                                    //.attr("y", this.config.size - this.config.cy / 4 - fontSize)
                                    .attr("y", this.config.cy)
                                    .attr("dy", fontSize / 3)
                                    .attr("text-anchor", "middle")
                                    .style("font-size", fontSize + "px")
                                    .style("fill", "#fff")
                                    .style("stroke-width", "0px");


        
        this.redraw(this.config.min, 0);
    }
    
    this.buildPointerPath = function(value)
    {
        var delta = this.config.range / 13;
        
        var head = valueToPoint(value, 0.85);
        var head1 = valueToPoint(value - delta, 0.12);
        var head2 = valueToPoint(value + delta, 0.12);
        
        var tailValue = value - (this.config.range * (1/(270/360)) / 2);
        var tail = valueToPoint(tailValue, 0.28);
        var tail1 = valueToPoint(tailValue - delta, 0.12);
        var tail2 = valueToPoint(tailValue + delta, 0.12);

        //console.log("Head :"+head+" Head1: "+head1+" Head2: "+head2+" Tail: "+tail+" Tail1: "+tail1+" Tail2: "+tail2)
        
        return [head, head1, tail2, tail, tail1, head2, head];
        
        function valueToPoint(value, factor)
        {

            var point = self.valueToPoint(value, factor);
            point.x -= self.config.cx;
            point.y -= self.config.cy;
            return point;
        }
    }
    
    this.drawBand = function(start, end, color)
    {
        if (0 >= end - start) return;
        
        this.body.append("svg:path")
                    .style("fill", color)
                    .attr("d", d3.svg.arc()
                        .startAngle(this.valueToRadians(start))
                        .endAngle(this.valueToRadians(end))
                        .innerRadius(0.65 * this.config.raduis)
                        .outerRadius(0.85 * this.config.raduis))
                    .attr("transform", function() { return "translate(" + self.config.cx + ", " + self.config.cy + ") rotate(270)" });
    }
    
    this.redraw = function(value, transitionDuration, maxVal)
    {
        //If there is a max value, remove all ticks and label from the meter and regenerate them
         var textVal;
         var pointerContainer = this.body.select(".pointerContainer");
        if (maxVal != undefined)
        {
            //
            //console.log("maxVal is defined. Updating meter");
            //this.body.selectAll("line").remove();
            //document.getElementById("maxlabel").remove();
            //document.getElementById("minlabel").remove();
            // minmaxlabel.nodeValue=maxVal;
            this.config.max = maxVal;
            this.config.range = this.config.max - this.config.min;
            
            document.getElementById("maxlabel").firstChild.nodeValue = this.config.max
            //pointerContainer.getElementById("maxlabel").text(Math.round(maxVal));

            //Use svg attribute updates instead of deleting the svg elements
            //this.generateLines(Math.round(this.config.size / 16));
            //this.updateTickLines();

            //var midValue = (this.config.min + this.config.max) / 2;
            //pointerContainer.selectAll("text").data([midValue])
        }

        if (value >= 1000)
        {
            textVal = String(Number(value/1000).toFixed(1))+"k"; 
        }
        else
        {
           textVal = String(Math.round(value));
        }

        //var pointerContainer = this.body.select(".pointerContainer");
        pointerContainer.selectAll("text").text(textVal);
        //pointerContainer.getElementById("g_value").text(value);
        //document.getElementById("g_value").firstChild.nodeValue = value

        var pointer = pointerContainer.selectAll("path");
        pointer.transition()
                    .duration(undefined != transitionDuration ? transitionDuration : this.config.transitionDuration)
                    //.delay(0)
                    //.ease("linear")
                    //.attr("transform", function(d) 
                    .attrTween("transform", function()
                    {
                        var pointerValue = value;
                        if (value > self.config.max) pointerValue = self.config.max + 0.02*self.config.range;
                        else if (value < self.config.min) pointerValue = self.config.min - 0.02*self.config.range;
                        var targetRotation = (self.valueToDegrees(pointerValue) - 90);
                        var currentRotation = self._currentRotation || targetRotation;
                        self._currentRotation = targetRotation;
                        
                        return function(step) 
                        {
                            var rotation = currentRotation + (targetRotation-currentRotation)*step;
                            return "translate(" + self.config.cx + ", " + self.config.cy + ") rotate(" + rotation + ")"; 
                        }
                    });
    }
    
    this.valueToDegrees = function(value)
    {
        // thanks @closealert
        //return value / this.config.range * 270 - 45;
        return value / this.config.range * 270 - (this.config.min / this.config.range * 270 + 45);
    }
    
    this.valueToRadians = function(value)
    {
        return this.valueToDegrees(value) * Math.PI / 180;
    }
    
    this.valueToPoint = function(value, factor)
    {
        return {    x: this.config.cx - this.config.raduis * factor * Math.cos(this.valueToRadians(value)),
                    y: this.config.cy - this.config.raduis * factor * Math.sin(this.valueToRadians(value))      };
    }

    //Function to draw Gauge ticks
    this.generateLines = function(lineFontSize)
    {
     var fontSize = lineFontSize;
     var majorDelta = this.config.range / (this.config.majorTicks - 1);
     var id_count=0;
        for (var major = this.config.min; major <= this.config.max; major += majorDelta)
        {
            var minorDelta = majorDelta / this.config.minorTicks;
            var minor_id_count =0;
            for (var minor = major + minorDelta; minor < Math.min(major + majorDelta, this.config.max); minor += minorDelta)
            {
                var point1 = this.valueToPoint(minor, 0.75);
                var point2 = this.valueToPoint(minor, 0.85);
                
                this.body.append("svg:line")
                            .attr("id","minticks"+String(minor_id_count))
                            .attr("x1", point1.x)
                            .attr("y1", point1.y)
                            .attr("x2", point2.x)
                            .attr("y2", point2.y)
                            .style("stroke", "#666")
                            .style("stroke-width", "1px");
                minor_id_count+=1;
            }
            
            var point1 = this.valueToPoint(major, 0.7);
            var point2 = this.valueToPoint(major, 0.85);    
            
            this.body.append("svg:line")
                        .attr("id","majticks"+String(id_count))
                        .attr("x1", point1.x)
                        .attr("y1", point1.y)
                        .attr("x2", point2.x)
                        .attr("y2", point2.y)
                        .style("stroke", "#333")
                        .style("stroke-width", "2px");

            //Text label for Minimum and Maximum value
            //if (major == this.config.min || major == this.config.max)
            // if (major == this.config.min)
            // {
            //     var point = this.valueToPoint(major, 0.63);
            //     this.body.append("svg:text")
            //                 .attr("id", "minlabel")
            //                 .attr("x", point.x)
            //                 .attr("y", point.y)
            //                 .attr("dy", fontSize / 3)
            //                 .attr("text-anchor", "start")
            //                 .text(major)
            //                 .style("font-size", fontSize + "px")
            //                 .style("fill", "#333")
            //                 .style("stroke-width", "0px");
            // }
            id_count+=1;
        }

        //Append Text for Max value
        //var point = this.valueToPoint(this.config.max, 0.63);
        this.body.append("svg:text")
                    .attr("id", "maxlabel")
                    .attr("x", this.config.cx)
                    .attr("y", this.config.cy + ((this.config.size /2) * 0.7))
                    .attr("dy", fontSize / 3)
                    .attr("text-anchor", "middle")
                    .text(this.config.max)
                    .style("font-size", fontSize + "px")
                    .style("fill", "#333")
                    .style("stroke-width", "0px");



    }

    //Test Function to update attributes of the Gauge ticks instead of redrawing the svg elements
    this.updateTickLines = function()
    {
     //var fontSize = lineFontSize;
     var id_count=0;
     var majorDelta = this.config.range / (this.config.majorTicks - 1);
     var svg = this
        for (var major = this.config.min; major <= this.config.max; major += majorDelta)
        {
            var minorDelta = majorDelta / this.config.minorTicks;
            var minor_id_count=0;
            //Update the Minor ticks
            for (var minor = major + minorDelta; minor < Math.min(major + majorDelta, this.config.max); minor += minorDelta)
            {
                var point1 = this.valueToPoint(minor, 0.75);
                var point2 = this.valueToPoint(minor, 0.85);
                
                
               // this.body.append("svg:line")
                var minortick = document.getElementById("minorticks"+String(minor_id_count));
                minortick.setAttribute("x1", point1.x);
                minortick.setAttribute("y1", point1.y);
                minortick.setAttribute("x2", point2.x);
                minortick.setAttribute("y2", point2.y);
                           //.style("stroke", "#666")
                           //.style("stroke-width", "1px");
                minor_id_count+=1;
            }
            
            var point1 = this.valueToPoint(major, 0.7);
            var point2 = this.valueToPoint(major, 0.85);    
            
            //this.body.append("svg:line")
                svg = document.getElementById("majorticks"+String(id_count));
                var majortick = document.getElementById("majorticks"+String(id_count));
                //majortick.setAttribute("x1", point1.x);
                //majortick.setAttribute("y1", point1.y);
                //majortick.setAttribute("x2", point2.x);
                //majortick.setAttribute("y2", point2.y);
                        //.style("stroke", "#333")
                        //.style("stroke-width", "2px");
            id_count+=1;
        }
        //Update the max value label on the gauge
        document.getElementById("maxlabel").firstChild.nodeValue = this.config.max;

    }

    this.fadeSwitchElements = function(svgElement, newValue)
    {
        element1 = svgElement.selectAll("text").text(newValue);
        element1.animate({fontSize: "3em"});
        element1.animate({fontSize: "1em"});
    }

    
    // initialization
    this.configure(configuration);  
}