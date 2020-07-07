import React from "react";
import _ from 'lodash';

import { getMapDataGroceryStores } from '../fetch'

export default ({ map, currentLocation }) => {
  const groceryStores = React.useRef([])
  const markers = React.useRef([])
  const prevAbortController = React.useRef(null)

  const loadMapData = React.useRef(_.throttle((map, currentLocation) => {
    if(!map) {
      return;
    }
    if(prevAbortController.current) {
      prevAbortController.current.abort();
    }
    let controller = new AbortController();
    prevAbortController.current = controller;
    getMapDataGroceryStores(currentLocation.southWest, currentLocation.northEast, controller.signal)
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
    })
    .catch(error => {
      if(error.name != 'AbortError') {
        throw error;
      }
    })
  }, 500)).current;

  React.useEffect(() => loadMapData(map, currentLocation), [map, currentLocation])

  return (
    <div/>
  );
}