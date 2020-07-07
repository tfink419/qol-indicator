import React from "react";
import _ from 'lodash';

import { getMapDataHeatmap } from '../fetch'

export default ({ map, currentLocation, mapPreferences }) => {
  const hasLoaded = React.useRef(false)
  const prevAbortController = React.useRef(null)

  const loadMapData = React.useRef(_.throttle((map, currentLocation, mapPreferences) => {
    // Lots of Refs and passed params used here because of closure issue with throttle
    if(!map) {
      return;
    }
    if(prevAbortController.current) {
      prevAbortController.current.abort();
    }
    let controller = new AbortController();
    prevAbortController.current = controller;
    getMapDataHeatmap(currentLocation.southWest, currentLocation.northEast, currentLocation.zoom, mapPreferences.loaded ? mapPreferences.preferences.transit_type : null, controller.signal)
    .then(({responseBlob, southWest, northEast}) => {
      let north = northEast[0], south = southWest[0],
        west = southWest[1], east = northEast[1];
      let url = URL.createObjectURL(responseBlob);
      let coordinates = [
        [west, north],
        [east, north],
        [east, south],
        [west, south]
      ];

      if(hasLoaded.current) {
        map.getSource('heatmap').updateImage({ url, coordinates })
      }
      else {
        map.addSource('heatmap',{
          'type': 'image',
          url,
          coordinates
        });
        map.addLayer({
          'id': 'heatmap-layer',
          'source': 'heatmap',
          'type': 'raster',
          'paint': { 'raster-opacity': 0.50 }
        })
      }
      
      hasLoaded.current = true;
    })
    .catch(error => {
      if(error.name != 'AbortError') {
        throw error;
      }
    })
  }, 1000)).current;

  React.useEffect(() => loadMapData(map, currentLocation, mapPreferences), [map, currentLocation, mapPreferences])

  return (
    <div/>
  );
}