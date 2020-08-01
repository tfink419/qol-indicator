import React from "react";
import ReactDOM from "react-dom";
import _ from 'lodash';
import { connect } from 'react-redux'

import { incrementInfoWindowId } from '../common'
import { getMapDataQualityMap, getMapDataPoint } from '../fetch'
import { infoWindowOpen, infoWindowLoaded } from '../actions/info-windows'
import { getSectors, getSectorBounds, fixZoom } from '../models/map-sector'

const QualityMapLayer = ({ map, currentLocation, mapPreferences, infoWindowOpen, infoWindowLoaded }) => {
  const prevAbortControllers = React.useRef([])
  const prevOverlays = React.useRef([])
  const loadedSectors = React.useRef([])
  const mapPreferencesRef = React.useRef(mapPreferences)
  const mapRef = React.useRef(map)
  const prevZoom = React.useRef(currentLocation.zoom);

  const handleClick = (event) => {
    let id = incrementInfoWindowId();
    infoWindowOpen('point-data', id, event.latLng);
    getMapDataPoint(event.latLng.lat(), event.latLng.lng(), mapPreferencesRef.current.preferences)
    .then(response => infoWindowLoaded(id, response));
  };

  const loadMapData = React.useRef(_.throttle((map, currentLocation, mapPreferences) => {
    // Lots of Refs and passed params used here because of closure issue with throttle
    if(!map) {
      return;
    }
    let zoom = fixZoom(currentLocation.zoom);
    if(mapPreferencesRef.current.changedAndNotLoaded || prevZoom.current != zoom) {
      prevAbortControllers.current.forEach(abortController => abortController.abort());
      prevOverlays.current.forEach(overlay => overlay.setMap(null));
      loadedSectors.current = [];
      prevOverlays.current = [];
      prevAbortControllers.current = [];
    }
    mapPreferencesRef.current.changedAndNotLoaded = false;
    prevZoom.current = zoom;

    getSectors(currentLocation.southWest, currentLocation.northEast, zoom).forEach(sector =>{
      if(_.every(loadedSectors.current, (loadedSector) => (loadedSector[0] != sector[0] || loadedSector[1] != sector[1]))) {
        loadedSectors.current.push(sector);
        let controller = new AbortController();
        prevAbortControllers.current.push(controller);
        getMapDataQualityMap(sector[0], sector[1], zoom, mapPreferences.preferences, controller.signal)
        .then(responseBlob => {
          let url = URL.createObjectURL(responseBlob);
          let bounds = getSectorBounds(sector[0], sector[1], zoom);
          let qualityMapOverlay = new google.maps.GroundOverlay(url, bounds, { opacity: 0.9999 });
          qualityMapOverlay.addListener('click', handleClick);
          qualityMapOverlay.setMap(map);
          prevOverlays.current.push(qualityMapOverlay);
        })
        .catch(error => {
          if(error.name != 'AbortError') {
            throw error;
          }
        });
      }
    })
  }, 1000)).current;

  React.useEffect(() => {
    mapPreferencesRef.current = { ...mapPreferences, changedAndNotLoaded:true };
  }, [mapPreferences]);
  React.useEffect(() => {
    mapRef.current = map
  }, [map]);

  React.useEffect(() => loadMapData(map, currentLocation, mapPreferences), [map, currentLocation, mapPreferences])

  return (
    <div/>
  );
}

const mapDispatchToProps = {
  infoWindowOpen,
  infoWindowLoaded
}

export default connect(null, mapDispatchToProps)(QualityMapLayer)