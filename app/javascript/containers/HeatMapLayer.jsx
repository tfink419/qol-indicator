import React from "react";
import { makeStyles } from '@material-ui/core/styles'
import { connect } from "react-redux";
import { useLeaflet } from 'react-leaflet'
import heatmap from 'heatmap.js/build/heatmap'
import HeatmapOverlay from 'leaflet-heatmap/leaflet-heatmap'

const defaultCfg = {
  // radius should be small ONLY if scaleRadius is true (or small radius is intended)
  // if scaleRadius is false it will be the constant radius used in pixels
  "radius": 0.01,
  "maxOpacity": .7,
  "minOpacity": .4,
  // scales the radius based on map zoom
  "scaleRadius": true,
  // if set to false the heatmap uses the global maximum for colorization
  // if activated: uses the data maximum within the current map boundaries
  //   (there will always be a red spot with useLocalExtremas true)
  "useLocalExtrema": false,
  latField: 'lat',
  lngField: 'long',
  valueField: 'quality',
  defaultColor: 'red',
  gradient: {
    // enter n keys between 0 and 1 here
    // for gradient color customization
    '0.1': 'red',
    '.5': 'yellow',
    '.75': 'blue',
    '.9': 'green'
  }
};

const HeatmapLayer = ({groceryStores, config}) => {
  let leafletContext = useLeaflet();
  const [heatmapLayer, setHeatmapLayer] = React.useState(null);
  const data = { min:0, max:10, data:groceryStores || []};

  
  React.useEffect(() => {
    console.log({ ...defaultCfg, ...config})
    if(heatmapLayer) {
      leafletContext.layerContainer.removeLayer(heatmapLayer)
    }
    const hml = new HeatmapOverlay({ ...defaultCfg, ...config});
    hml.setData(data);
  
    leafletContext.layerContainer.addLayer(hml)
    setHeatmapLayer(hml);
  },[groceryStores, config])

  return (<div id='heatmap-layer-react'></div>)
};


export default connect()(HeatmapLayer)