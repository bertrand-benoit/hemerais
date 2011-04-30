<!--
  Hemera - Intelligent System (https://sourceforge.net/projects/hemerais)
  Copyright (C) 2010-2011 Bertrand Benoit <projettwk@users.sourceforge.net>
 
  This program is free software; you can redistribute it and/or modify
  it under the terms of the GNU General Public License as published by
  the Free Software Foundation; either version 3 of the License, or
  (at your option) any later version.
 
  This program is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
  GNU General Public License for more details.
 
  You should have received a copy of the GNU General Public License
  along with this program; if not, see http://www.gnu.org/licenses
  or write to the Free Software Foundation,Inc., 51 Franklin Street,
  Fifth Floor, Boston, MA 02110-1301  USA 
-->

<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ taglib prefix="s" uri="/struts-tags" %>
<%@ taglib prefix="sx" uri="/struts-dojo-tags" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
 <head>
   <sx:head />
   <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">  
   <link rel="stylesheet" href="<s:url value="pages/styles/default.css"/>" type="text/css" />
   <script src="<s:url value="pages/scripts/jquery-1.5.2/jquery.min.js"/>" type="text/javascript" /></script>
   <script src="<s:url value="pages/scripts/highcharts-2.1.4/highcharts.js"/>" type="text/javascript" /></script>
   <title><s:text name="hemera.title"/> - <s:text name="menu.processing"/></title>
   <h1><s:text name="hemera.title"/> - <s:text name="menu.processing"/></h1>
 </head>

 <body>
 
  <script type="text/javascript">
    /**
     * Request data from the server, add it to the graph and set a timeout to request again
     */
    function requestData() {
        $.ajax({
            url: '<s:url action="processingData" />',
            success: function(data) {
              // Defines if shift is needed.
              var shift = initialShift || hemeraChart.series[0].data.length > 15;
              
              // Adds specified data.
              hemeraChart.series[0].addPoint(data["data"]["new"], false, shift);
              hemeraChart.series[1].addPoint(data["data"]["error"], false, shift);
              hemeraChart.series[2].addPoint(data["data"]["pspeech"], false, shift);
              hemeraChart.series[3].addPoint(data["data"]["precordedSpeech"], false, shift);
              hemeraChart.series[4].addPoint(data["data"]["precognitionResult"], true, shift);
    
              // Schedules this method.
              setTimeout(requestData, initialShift ? 500 : 3000);
              initialShift = false;    
            },
            cache: false
        });
    }

    var initialShift=true;
    var hemeraChart; // globally available
    $(document).ready(function() {
      hemeraChart = new Highcharts.Chart({
      chart: {
         renderTo: 'hemeraChartDiv',
         defaultSeriesType: 'line',
         marginRight: 220,
         marginBottom: 35,
         events: {
            load: requestData
         }
      },
      credits: {
        text: "Powered with Highcharts",
        position: {
          y: -2
        }
      },      
      title: {
         text: 'Processing systems',
         x: -90 //center
      },
      xAxis: {
         type: 'datetime',
         title: {
            text: 'Time'
         }
      },
      yAxis: {
         title: {
            text: 'Input or Processing operation count'
         },
         min: 0,
         plotLines: [{
            value: 0,
            width: 1,
            color: '#808080'
         }]
      },
      tooltip: {
         formatter: function() {
                   return '<b>'+ this.series.name +'</b><br/>'+
               'At ' + Highcharts.dateFormat('%H:%M.%S', this.x) +': '+ this.y +' count/operation(s)';
         }
      },
      legend: {
         layout: 'vertical',
         align: 'right',
         verticalAlign: 'top',
         x: 0,
         y: 150,
         borderWidth: 0
      },
      series: [{
         name: 'new input',
         data: [0]
      },{
         name: 'error input',
         data: [0]
      },{
         name: 'processing speech',
         data: [0]
      }, {
         name: 'processing recorded speech',
         data: [0]
      }, {
         name: 'processing recognition result',
         data: [0]
      }]
    });
   });
  </script>

  <div id="hemeraChartDiv" style="width: 100%; height: 400px"></div>

  <s:include value="/pages/part_back2index.jsp"/>
  <s:include value="/pages/part_languages_select.jsp"/>
 </body>
</html>
