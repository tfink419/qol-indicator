import React from "react";
import ReactDOM from 'react-dom'
import _ from 'lodash';
import { Provider, useStore } from 'react-redux'
import GroceryStorePopup from '../components/GroceryStorePopup';

import { getMapDataGroceryStores } from '../fetch';

export default ({ map, currentLocation, isAdmin }) => {
  const groceryStores = React.useRef([])
  const store = useStore();
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
      if(currentLocation.zoom > 10) {
        markers.current = response.grocery_stores.map((groceryStore) => {
          let color = 'orange';
          if(groceryStore[3] > 10) {
            color = 'blue';
          } else if(groceryStore[3] > 7) {
            color = 'green'
          }
          else if(groceryStore[3] > 3)  {
            color = 'yellow';
          }
          let relativeIconSize = Math.pow(1.3, (currentLocation.zoom-12));
          let svgStyle = {
            cursor:'pointer',
            transform: `scale(${relativeIconSize})`,
            "msTransform": `scale(${relativeIconSize})`,
            "WebkitTransform": `scale(${relativeIconSize})`
          };
          let markerPlaceholder = document.createElement('div');
          ReactDOM.render((
            <svg style={svgStyle} xmlns="http://www.w3.org/2000/svg" width='24' height='24'>
              <path fill={color} stroke='black' d="M7 18c-1.1 0-1.99.9-1.99 2S5.9 22 7 22s2-.9 2-2-.9-2-2-2zM1 2v2h2l3.6 7.59-1.35 2.45c-.16.28-.25.61-.25.96 0 1.1.9 2 2 2h12v-2H7.42c-.14 0-.25-.11-.25-.25l.03-.12.9-1.63h7.45c.75 0 1.41-.41 1.75-1.03l3.58-6.49c.08-.14.12-.31.12-.48 0-.55-.45-1-1-1H5.21l-.94-2H1zm16 16c-1.1 0-1.99.9-1.99 2s.89 2 1.99 2 2-.9 2-2-.9-2-2-2z"/>
            </svg>
          ), markerPlaceholder);
          let marker = new mapboxgl.Marker(markerPlaceholder);
          let lngLat = {
            lon: groceryStore[2],
            lat: groceryStore[1]
          };
          let popupPlaceholder = document.createElement('div');
          ReactDOM.render(<Provider store={store}><GroceryStorePopup groceryStoreId={groceryStore[0]} open={false} isAdmin={isAdmin}/></Provider>, popupPlaceholder);
          let popup = new mapboxgl.Popup({ offset: 25 })
          .setDOMContent(popupPlaceholder)
          .on('open', () => ReactDOM.render(<Provider store={store}><GroceryStorePopup groceryStoreId={groceryStore[0]} open={true} isAdmin={isAdmin}/></Provider>, popupPlaceholder))
          .on('close', () => ReactDOM.render(<Provider store={store}><GroceryStorePopup groceryStoreId={groceryStore[0]} open={false} isAdmin={isAdmin}/></Provider>, popupPlaceholder))

          marker.setLngLat(lngLat)
          .setPopup(popup)
          .addTo(map);
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