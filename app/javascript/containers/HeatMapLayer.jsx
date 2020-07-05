import React from "react";
import _ from 'lodash';

import { getMapData } from '../fetch'

const buildSquare = (point, zoom) => {
  zoom = Math.floor(zoom);
  let radius;
  if(zoom > 10) {
    radius = 0.0005;
  }
  else if(zoom > 4) {
    radius = _.round(0.001 * Math.pow(2,9-zoom),3)
  }
  else {
    radius = 0.016;
  }
  let diameter = _.round(radius*2,3);
  let southWest = [point[1]-radius, point[0]-radius];
  return [southWest, [southWest[0]+diameter, southWest[1]], [southWest[0]+diameter, southWest[1]+diameter],
    [southWest[0], southWest[1]+diameter], southWest];
}

const buildHeatMapData = (points, zoom) => (
  {
    "type": "FeatureCollection",
    "features": points.map((point,ind) => (
      { "type": "Feature", "properties": { "id": "heatmap-point-"+ind, "quality":point[2] }, "geometry": { "type": "Polygon", "coordinates": [buildSquare(point,zoom)] } }
    ))
  }
)

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
            'fill-color':[
              'case',
              ['all', ['>', ['get', 'quality'], 7]],
              '#0F0',                 
              ['>', ['get', 'quality'], 4],
              '#FF0', 
              '#F00'
            ],
            'fill-opacity': 0.15
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