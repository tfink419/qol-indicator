import React from "react";
import ReactDOM from "react-dom";
import _ from 'lodash';
import { connect } from 'react-redux'

import { getMapDataQualityMap, getMapDataPoint } from '../fetch'
import { infoWindowOpened } from '../actions/info-windows'

import PointDataPopup from '../components/PointDataPopup'

const QualityMapLayer = ({ map, currentLocation, mapPreferences, infoWindowOpened, infoWindows }) => {
  const prevAbortController = React.useRef(null)
  const prevOverlay = React.useRef(null)
  const mapPreferencesRef = React.useRef(mapPreferences)
  const mapRef = React.useRef(map)
  let currentPointDataInfoWindowRef = React.useRef(null);

  const handleClick = (event) => {
    getMapDataPoint(event.latLng.lat(), event.latLng.lng(), mapPreferencesRef.current.preferences)
    .then((response) => {
      let infoWindowPlaceholder = document.createElement('div');

      ReactDOM.render(<PointDataPopup results={response}/>, infoWindowPlaceholder);
      let infoWindow = new window.google.maps.InfoWindow({
        content: infoWindowPlaceholder,
        position: event.latLng
      });
      infoWindow.open(mapRef.current);
      if(currentPointDataInfoWindowRef.current) currentPointDataInfoWindowRef.current.close();
      currentPointDataInfoWindowRef.current = infoWindow;
      infoWindowOpened('point-data')
    })
  };

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
      qualityMapOverlay.addListener('click', handleClick);
      qualityMapOverlay.setMap(map);
      prevOverlay.current = qualityMapOverlay;
    })
    .catch(error => {
      if(error.name != 'AbortError') {
        throw error;
      }
    })
  }, 1000)).current;

  React.useEffect(() => {
    if(infoWindows.activeInfoWindow && currentPointDataInfoWindowRef.current && infoWindows.activeInfoWindow.infoWindowType != 'point-data') {
        currentPointDataInfoWindowRef.current.close();
        currentPointDataInfoWindowRef.current = null;
      }
  }, [infoWindows])

  React.useEffect(() => {
    mapPreferencesRef.current = mapPreferences
  }, [mapPreferences]);
  React.useEffect(() => {
    mapRef.current = map
  }, [map]);

  React.useEffect(() => loadMapData(map, currentLocation, mapPreferences), [map, currentLocation, mapPreferences])

  return (
    <div/>
  );
}

const mapStateToProps = state => ({
  infoWindows: state.infoWindows
})

const mapDispatchToProps = {
  infoWindowOpened
}

export default connect(mapStateToProps, mapDispatchToProps)(QualityMapLayer)