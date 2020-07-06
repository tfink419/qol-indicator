import React from "react";
import _ from 'lodash';

import { getMapData } from '../fetch'

const buildColorSetup = () => {
  //Create linear gradient and extract colors from it for heatmap
  let c = document.createElement("CANVAS");
  let ctx = c.getContext("2d");

  const NUM_GRADIENT_STEPS=100;

  let grd = ctx.createLinearGradient(0,0,200,0);
  let colorStops = [
    [0,"#F00"],
    [0.5,"#FF0"],
    [1, "#0F0"]
  ]

  colorStops.forEach(cs => grd.addColorStop(cs[0], cs[1]))

  let colorMap = colorStops.slice();

  ctx.fillStyle = grd;
  ctx.fillRect(0,0,200,1);
  let p;
  for(let i = 1, pixel = 200/NUM_GRADIENT_STEPS-1; i < NUM_GRADIENT_STEPS; i++, pixel+=200/NUM_GRADIENT_STEPS) {
    p = ctx.getImageData(pixel, 0, 1, 1).data;
    colorMap.push([i/NUM_GRADIENT_STEPS, ['rgb'].concat(_.slice(p,0,3))])
  }
  let colorSetup = ['case'].concat(colorMap.sort((a,b) => b[0]-a[0]).reduce((arr, colorValue) => {
    arr.push(['>=', ['get', 'quality'], colorValue[0]*10])
    arr.push(colorValue[1])
    return arr;
  },[]));

  colorSetup.push(colorSetup[colorSetup.length-1])
  return colorSetup;
}

const buildSquare = (point, radius, diameter) => {
  let southWest = [point[1]-radius, point[0]-radius];
  return [[southWest[0], southWest[1]], [southWest[0]+diameter, southWest[1]], [southWest[0]+diameter, southWest[1]+diameter],
    [southWest[0], southWest[1]+diameter], southWest];
}

const buildHeatMapData = (points, zoom) => {
  zoom = Math.floor(zoom);
  let radius;
  if(zoom > 12) {
    radius = 0.0005;
  }
  else if(zoom > 5) {
    radius = _.round(0.0005 * Math.pow(2,12-zoom),4)
  }
  else {
    radius = 0.016;
  }
  let diameter = _.round(radius*2,3);
  return {
    "type": "FeatureCollection",
    "features": points.map((point,ind) => (
      { "type": "Feature", "properties": { "id": "heatmap-point-"+ind, "quality":point[2] }, "geometry": { "type": "Polygon", "coordinates": [buildSquare(point, radius, diameter)] } }
    ))
  }
}

export default ({ map, currentLocation, mapPreferences }) => {
  const hasLoaded = React.useRef(false)
  const groceryStores = React.useRef([])
  const markers = React.useRef([])
  const prevAbortController = React.useRef(null)

  const loadMapData = React.useRef(_.throttle((map, currentLocation, mapPreferences) => {
    // Lots of Refs used here because of closure issue with event being handled by mapbox
    if(!map) {
      return;
    }
    if(prevAbortController.current) {
      prevAbortController.current.abort();
    }
    let controller = new AbortController();
    prevAbortController.current = controller;
    let bounds = map.getBounds();
    getMapData(bounds._sw, bounds._ne, currentLocation.zoom, mapPreferences.loaded ? mapPreferences.preferences.transit_type : null, controller.signal)
    .then(response => {
      groceryStores.current = response.grocery_stores;
      markers.current.forEach(marker => marker.remove());
      markers.current = [];
      if(map.getZoom() > 11) {
        markers.current = response.grocery_stores.map((gStore) => {
          let marker = new mapboxgl.Marker({
          });
          let lngLat = {
            lon: gStore[2],
            lat: gStore[1]
          };
          marker.setLngLat(lngLat).addTo(map);
          return marker;
        })
      }
      if(!hasLoaded.current) {
        map.addSource('quality-heat', {
          'type': 'geojson',
          data: {
            'type': 'FeatureCollection',
            'features': []
          }
        });
        
        map.addLayer({
          'id': 'quality-heatpoints',
          'type': 'fill',
          'source': 'quality-heat',
          'paint': {
            'fill-color':buildColorSetup(),
            'fill-opacity': 0.5
          }
          // 'paint': {
          //   'fill-color': '#0F0',
          //   'fill-opacity': 0.5
          // },
          // 'filter': ['==', '$type', 'Polygon']
        });
      }
      
      let data = buildHeatMapData(response.heatmap_points, currentLocation.zoom);

      map.getSource('quality-heat').setData(data);
      
      hasLoaded.current = true;
    })
    .catch(error => {
      if(error.name != 'AbortError') {
        throw error;
      }
    })
  }, 500)).current;

  React.useEffect(() => loadMapData(map, currentLocation, mapPreferences), [map, currentLocation, mapPreferences])

  return (
    <div/>
  );
}