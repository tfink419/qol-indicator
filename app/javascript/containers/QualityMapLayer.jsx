import React from "react";
import ReactDOM from "react-dom";
import _ from 'lodash';
import { connect } from 'react-redux'

import { getMapDataQualityMap, getMapDataPoint } from '../fetch'
import { infoWindowOpened } from '../actions/info-windows'
import { getSectors, getSectorBounds } from '../models/map-sector'

import PointDataPopup from '../components/PointDataPopup'

const QualityMapLayer = ({ map, currentLocation, mapPreferences, infoWindowOpened, infoWindows }) => {
  const prevAbortControllers = React.useRef([])
  const prevOverlays = React.useRef([])
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
    let zoom = currentLocation.zoom-4;
    prevAbortControllers.current.forEach(abortController => abortController.abort());
    prevOverlays.current.forEach(overlay => overlay.setMap(null));
    prevAbortControllers.current = [];
    prevOverlays.current = [];

    getSectors(currentLocation.southWest, currentLocation.northEast, zoom).forEach(sector =>{
      let controller = new AbortController();
      prevAbortControllers.current.push(controller);
      getMapDataQualityMap(sector[0], sector[1], zoom, mapPreferences.preferences, controller.signal)
      .then(responseBlob => {
        console.log(responseBlob)
        let url = URL.createObjectURL(responseBlob);
        let bounds = getSectorBounds(sector[0], sector[1], zoom);
        let qualityMapOverlay = new google.maps.GroundOverlay(url, bounds);
        qualityMapOverlay.addListener('click', handleClick);
        qualityMapOverlay.setMap(map);
        prevOverlays.current.push(qualityMapOverlay);
      })
      .catch(error => {
        if(error.name != 'AbortError') {
          throw error;
        }
      });
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