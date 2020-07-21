import React from "react";
import _ from 'lodash';

import { getMapDataQualityMap } from '../fetch'

export default ({ map, currentLocation, mapPreferences }) => {
  const prevAbortController = React.useRef(null)
  const prevOverlay = React.useRef(null)

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
    getMapDataQualityMap(currentLocation.southWest, currentLocation.northEast, currentLocation.zoom, mapPreferences.preferences, controller.signal)
    .then(({responseBlob, southWest, northEast}) => {
      let north = northEast[0], south = southWest[0],
        west = southWest[1], east = northEast[1];
      let url = URL.createObjectURL(responseBlob);

      if(prevOverlay.current) {
        prevOverlay.current.setMap(null);
      }

      let imageBounds = { north, south, east, west };
      let qualityMapOverlay = new google.maps.GroundOverlay(url, imageBounds);
      qualityMapOverlay.setMap(map);
      prevOverlay.current = qualityMapOverlay;
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