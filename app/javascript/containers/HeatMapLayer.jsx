import React from "react";
import _ from 'lodash';

import { getMapData } from '../fetch'

const buildHeatMapData = (points) => (
  {
    "type": "FeatureCollection",
    "crs": { "type": "name", "properties": { "name": "urn:ogc:def:crs:OGC:1.3:CRS84" } },
    "features": points.map((point,ind) => (
      { "type": "Feature", "properties": { "id": "heatmap-point-"+ind, "quality":point[2] }, "geometry": { "type": "Point", "coordinates": [ point[1], point[0], 0.0 ] } }
    ))
  }
)

export default ({ map, currentLocation, mapPreferences }) => {
  let [hasLoaded, setHasLoaded] = React.useState(false)
  let [groceryStores, setGroceryStores] = React.useState([])
  const markers = React.useRef([])
  const prevAbortController = React.useRef(null)

  const loadMapData = React.useRef(_.throttle((map, currentLocation, mapPreferences, hasLoaded) => {
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
      setGroceryStores(response.grocery_stores)
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
      if(!hasLoaded) {
        map.addSource('quality-heat', {
          'type': 'geojson',
          data: {
            'type': 'FeatureCollection',
            'features': []
          }
        });
  
        map.addLayer({
          'id': 'quality-heat',
          'type': 'heatmap',
          'source': 'quality-heat',
          'minZoom': 8,
          'paint': {
            'heatmap-weight': [
              'interpolate',
              ['exponential',1.5],
              ['get', 'quality'],
              0,
              0,
              10,
              1
            ],
            'heatmap-intensity': [
              'interpolate',
              ['linear'],
              ['zoom'],
              0,
              1,
              9,
              3
              ],
            'heatmap-color': [
              'interpolate',
              ['linear'],
              ['heatmap-density'],
              0,
              'red',
              0.2,
              'red',
              0.6,
              'yellow',
              1,
              'green'
            ],
            'heatmap-opacity': 0.5,
            'heatmap-radius': {
              "base": 2.1,
              "stops": [
                [
                  10,
                  4
                ],
                [
                  19,
                  1512.9
                ]
              ]
            }
          }
        });
      }
      map.getSource('quality-heat').setData(buildHeatMapData(response.heatmap_points));
      setHasLoaded(true);
    })
  }, 500)).current;

  React.useEffect(() => loadMapData(map, currentLocation, mapPreferences, hasLoaded), [map, currentLocation, mapPreferences, hasLoaded])

  return (
    <div/>
  );
}