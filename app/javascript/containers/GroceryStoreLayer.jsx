import React from "react";
import ReactDOM from 'react-dom'
import { connect } from 'react-redux'
import _ from 'lodash';
import { Provider, useStore } from 'react-redux'

import GroceryStorePopup from '../components/GroceryStorePopup';

import { incrementInfoWindowId } from '../common'
import { infoWindowOpen, infoWindowLoaded } from '../actions/info-windows'
import { getMapDataGroceryStores, getGroceryStore } from '../fetch';

const MAX_STORES_TO_HOLD = 10000;

const ICON_BASE_URL = 'https://my-qoli-icons.s3-us-west-1.amazonaws.com/';

const GroceryStoreLayer = ({ map, currentLocation, mapPreferences, infoWindowOpen, infoWindowLoaded, infoWindows }) => {
  const groceryStores = React.useRef([]);
  const justRetrievedGroceryStores = React.useRef([]);
  const store = useStore();
  const prevAbortController = React.useRef(null)

  const removeAllMarkers = () => {
    groceryStores.current.forEach(groceryStore => {
      groceryStore.marker.setMap(null);
    });
  }

  const onGroceryStoreChange = (id) => {
    justRetrievedGroceryStores.current = justRetrievedGroceryStores.current.filter(groceryStore => groceryStore != id);
    groceryStores.current = groceryStores.current.filter(groceryStore => {
      if(groceryStore.groceryStore[0] == id) {
        groceryStore.marker.setMap(null);
        return false;
      }
      return true;
    });
    loadMapData(map, currentLocation)
  };

  const loadMapData = React.useRef(_.throttle((map, currentLocation, mapPreferences) => {
    if(!map) {
      return;
    }
    if(prevAbortController.current) {
      prevAbortController.current.abort();
    }
    let controller = new AbortController();
    prevAbortController.current = controller;
    if(mapPreferences.preferences.grocery_store_quality_ratio > 0 && currentLocation.zoom > 10) {
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

          marker.addListener('click', () => {
            let id = incrementInfoWindowId();
            infoWindowOpen('grocery-store', id, null, marker);
            getGroceryStore(groceryStore[0])
            .then(response => infoWindowLoaded(id, response));
          });
          
          groceryStores.current.push({ marker, groceryStore });
        })
        if(groceryStores.current.length > MAX_STORES_TO_HOLD) {
          let amountToDelete = groceryStores.current.length - MAX_STORES_TO_HOLD;
          let deleted = 0;
          groceryStores.current = groceryStores.current.reduce((newArr, groceryStore) => {
            if(deleted < amountToDelete && justRetrievedGroceryStores.current.findIndex(groceryStore[0]) == -1) {
              groceryStore.marker.setMap(null);
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
      removeAllMarkers();
    }
  }, 500)).current;

  React.useEffect(() => loadMapData(map, currentLocation, mapPreferences), [map, currentLocation, mapPreferences])

  return (
    <div/>
  );
}

const mapDispatchToProps = {
  infoWindowOpen,
  infoWindowLoaded
}

export default connect(null, mapDispatchToProps)(GroceryStoreLayer)