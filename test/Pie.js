var ChartVal = JSON.parse(document.getElementById("txtMyVal").value);
//alert(ChartVal);
//var objSecGraph = JSON.parse(strVal);
var chart = new CanvasJS.Chart("chartContainer",
{		
  title:{
    text: "Sector wise Asset Allocation"
  },
  animationEnabled: true,
  legend:{
    verticalAlign: "center",
    horizontalAlign: "left",
    fontSize: 12,
    fontFamily: "Helvetica"        
  },
  theme: "theme2",
  data: [
    {        
      type: "pie",       
      indexLabelFontFamily: "Garamond",       
      indexLabelFontSize: 12,
      indexLabel: "{label} {y}%",
      startAngle:-20,      
      showInLegend: true,
      toolTipContent:"{legendText} {y}%",
      dataPoints: ChartVal
    }
  ]
});
chart.render();