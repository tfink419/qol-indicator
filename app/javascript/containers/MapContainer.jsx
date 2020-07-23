import React from "react";
import _ from 'lodash'
import { makeStyles } from '@material-ui/core/styles'
import { connect } from "react-redux";
import { Loader } from '@googlemaps/js-api-loader';
import { getMapPreferences } from '../fetch'
import { updateMapPreferences } from "../actions/map-preferences";

import QualityMapLayer from './QualityMapLayer'
import GroceryStoreLayer from './GroceryStoreLayer'
import MapLegend from "../components/MapLegend";

const loader = new Loader({
  apiKey: GOOGLE_KEY,
  version: "weekly",
  libraries: ["places"]
});

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

const startLocation = {
  center: [39.743, -104.988],
  zoom:12,
  southWest:[39.721, -105.042],
  northEast:[39.765, -104.927]
}

const MapContainer = ({mapPreferences, updateMapPreferences, isAdminLayer = false}) => {
  const classes = useStyles();
  let [currentLocation, setCurrentLocation] = React.useState({...startLocation});
  const currentLocationRef = React.useRef(currentLocation);
  let [map, setMap] = React.useState(null);
  const mapRef = React.useState(map);
  const mapContainer = React.useRef(null);

  const handleMapMove = () => {
    let center = mapRef.current.getCenter();
    let bounds = mapRef.current.getBounds();
    setCurrentLocation(currentLocationRef.current = {
      center: [center.lat().toFixed(3), center.lng().toFixed(3)],
      zoom: mapRef.current.getZoom().toFixed(2),
      southWest: [bounds.getSouthWest().lat(), bounds.getSouthWest().lng()],
      northEast: [bounds.getNorthEast().lat(), bounds.getNorthEast().lng()]
    });
  }
  
  const loadMapPreferences = () => {
    if(!mapPreferences.loaded) {
      getMapPreferences().then(response => {
        updateMapPreferences(response.map_preferences)
      })
    }
  }

  React.useEffect(loadMapPreferences, [mapPreferences]);

  const loadMap = () => {
    const mapOptions = {
      center: {
        lat: currentLocation.center[0],
        lng: currentLocation.center[1]
      },
      streetViewControl: false,
      fullScreenControl: false,
      mapTypeControl: false,
      mapTypeId: 'roadmap',
      zoom: currentLocation.zoom,
      minZoom: 7,
      maxZoom: 16
    };
    loader
    .load()
    .then(() => {
      let _map = new window.google.maps.Map(mapContainer.current, mapOptions);
      setMap(mapRef.current = _map);
      _map.addListener('bounds_changed', () => handleMapMove());
    })
  }

  React.useEffect(loadMap, [])

  return (
    <div className={classes.mapContainer} ref={mapContainer}>
      <QualityMapLayer map={map} mapPreferences={mapPreferences} currentLocation={currentLocation} />
      <GroceryStoreLayer map={map} currentLocation={currentLocation} mapPreferences={mapPreferences} isAdmin={isAdminLayer} />
      { !isAdminLayer && <MapLegend map={map}/> }
    </div>
  )};
    
const mapStateToProps = state => ({
  mapPreferences: state.mapPreferences
})

const mapDispatchToProps = {
  updateMapPreferences
}


export default connect(mapStateToProps, mapDispatchToProps)(MapContainer)