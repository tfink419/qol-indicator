import React from "react";
import _ from 'lodash'
import { makeStyles } from '@material-ui/core/styles'
import { connect } from "react-redux";
import { getMapPreferences } from '../fetch'
import { updateMapPreferences } from "../actions/map-preferences";

import HeatmapLayer from './HeatmapLayer'
mapboxgl.accessToken = 'pk.eyJ1IjoidGZpbms0MTkiLCJhIjoiY2tibWhvYTFzMWlwNzJxcWk5Z2I2ajExcSJ9.kNmK4p8B3GOXf6OWMNXcoQ';

const useStyles = makeStyles({
  map: {
    height: 'calc(100vh - 64px)'
  },
  mapContainer: {
    position: 'absolute',
    top: '64px',
    bottom: 0,
    width: 'calc(100vw - 48px)',
    maxWidth: '1232px'
  }
});

const cityZipPrint = (city, state, zip) => {
  if(!city && state && zip) {
    return `${state} ${zip}`
  }
  else if(city && state && !zip) {
    return `${city}, ${state}`
  }
  else {
    return `${city}, ${state} ${zip}`
  }
}

const startLocation = {
  center: [-104.988, 39.743],
  zoom:13
}

const MapContainer = ({mapPreferences, updateMapPreferences}) => {
  const classes = useStyles();
  let [currentLocation, setCurrentLocation] = React.useState({...startLocation});
  let [map, setMap] = React.useState(null);
  const mapContainer = React.useRef(null);

  const handleMapMove = (event) => {
    let map = event.target;
    let bounds = map.getBounds();
    let center = map.getCenter();
    setCurrentLocation({
      center: [center.lng.toFixed(3), center.lat.toFixed(3)],
      zoom: map.getZoom().toFixed(2)
    });
  }
  
  React.useEffect(() => {
    let map = new mapboxgl.Map({
      container: mapContainer.current,
      style: 'mapbox://styles/mapbox/streets-v11',
      center: currentLocation.center,
      zoom: currentLocation.zoom,
      maxZoom: 16
    });
    map.on('move', handleMapMove);
    setMap(map);
  },[])
  
  const loadMapPreferences = () => {
    if(!mapPreferences.loaded) {
      getMapPreferences().then(response => {
        updateMapPreferences(response.map_preferences)
      })
    }
  }

  React.useEffect(loadMapPreferences, [mapPreferences]);

  return (
    <div ref={mapContainer} className={classes.mapContainer}>
      <HeatmapLayer currentLocation={currentLocation} map={map} mapPreferences={mapPreferences} />
    </div>
  )};
    
const mapStateToProps = state => ({
  mapPreferences: state.mapPreferences
})

const mapDispatchToProps = {
  updateMapPreferences
}


export default connect(mapStateToProps, mapDispatchToProps)(MapContainer)