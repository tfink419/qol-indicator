import React from "react";
import ReactDOM from 'react-dom'
import _ from 'lodash';
import { Provider, useStore } from 'react-redux'
import GroceryStorePopup from '../components/GroceryStorePopup';

import { getMapDataGroceryStores } from '../fetch';

const MAX_STORES_TO_HOLD = 10000;

const ICON_BASE_URL = 'https://my-qoli-icons.s3-us-west-1.amazonaws.com/';

export default ({ map, currentLocation, isAdmin }) => {
  const groceryStores = React.useRef([]);
  const justRetrievedGroceryStores = React.useRef([]);
  const store = useStore();
  const prevAbortController = React.useRef(null)

  const closeOtherWindows = (groceryStoreId) => {
    groceryStores.current.forEach((groceryStore) => {
      if(groceryStore.groceryStore[0] != groceryStoreId) {
        groceryStore.infoWindow.close();
      }
    });
  }

  const loadMapData = React.useRef(_.throttle((map, currentLocation) => {
    if(!map) {
      return;
    }
    if(prevAbortController.current) {
      prevAbortController.current.abort();
    }
    let controller = new AbortController();
    prevAbortController.current = controller;
    if(currentLocation.zoom > 10) {
      getMapDataGroceryStores(currentLocation.southWest, currentLocation.northEast, controller.signal)
      .then(response => {
        justRetrievedGroceryStores.current = [];
        response.grocery_stores.forEach((groceryStore) => {
          justRetrievedGroceryStores.current.push(groceryStore[0]);
          let scale = Math.pow(1.3, (currentLocation.zoom-12));
          let color = 'redorange';
          if(groceryStore[3] > 7) {
            color = 'green'
          }
          else if(groceryStore[3] > 3)  {
            color = 'yellow';
          }
          let url = ICON_BASE_URL+`grocery_store_${color}.png`;
          console.log(scale, 24*scale);
          let icon = {
            url,
            scaledSize: new google.maps.Size(24*scale, 24*scale),
            origin: new google.maps.Point(0, 0),
            anchor: new google.maps.Point(12*scale, 12*scale)
          }
          let foundIndex = groceryStores.current.findIndex(storeToFind => storeToFind.groceryStore[0] == groceryStore[0]);
          if(foundIndex >= 0) {
            groceryStores.current[foundIndex].marker.setIcon(icon);
            return;
          }
          let latLng = {lat:groceryStore[1], lng:groceryStore[2]};
          let marker = new window.google.maps.Marker({
            position: latLng,
            draggable: false,
            icon: icon
          });

          let infoWindowPlaceholder = document.createElement('div');

          let infoWindow = new window.google.maps.InfoWindow({
            content: infoWindowPlaceholder
          });

          const onGroceryStoreChange = () => loadMapData(map, currentLocation);
          
          marker.addListener('click', () => {
            infoWindow.open(map, marker);
            ReactDOM.render(<Provider store={store}><GroceryStorePopup groceryStoreId={groceryStore[0]} open={true} isAdmin={isAdmin} onGroceryStoreChange={onGroceryStoreChange}/></Provider>, infoWindowPlaceholder);
            closeOtherWindows(groceryStore[0]);
          });
          
          infoWindow.addListener('closeclick', () => ReactDOM.render(<div/>, infoWindowPlaceholder));

          groceryStores.current.push({ marker, groceryStore, infoWindow });
        })
        if(groceryStores.current.length > MAX_STORES_TO_HOLD) {
          let amountToDelete = groceryStores.current.length - MAX_STORES_TO_HOLD;
          let deleted = 0;
          groceryStores.current = groceryStores.current.reduce((newArr, groceryStore) => {
            if(deleted < amountToDelete && justRetrievedGroceryStores.current.findIndex(groceryStore[0]) == -1) {
              groceryStores.current.marker.setMap(null);
              deleted++;
            }
            else {
              newArr.push(groceryStore);
            }
            return newArr;
          }, []);
        }
        groceryStores.current.forEach(groceryStore => groceryStore.marker.setMap(map));
      })
      .catch(error => {
        if(error.name != 'AbortError') {
          throw error;
        }
      })
    }
    else {
      groceryStores.current.forEach(groceryStore => groceryStore.marker.setMap(null));
    }
  }, 500)).current;

  React.useEffect(() => loadMapData(map, currentLocation), [map, currentLocation])

  return (
    <div/>
  );
}