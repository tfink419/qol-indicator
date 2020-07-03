import React from "react";
import _ from 'lodash'
import { makeStyles } from '@material-ui/core/styles'
import { connect } from "react-redux";
import { getMapData } from '../fetch'
import { getMapPreferences } from '../fetch'
import { updateMapPreferences } from "../actions/map-preferences";
import { Container } from "@material-ui/core";
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

const buildHeatMapData = (points) => (
  {
    "type": "FeatureCollection",
    "crs": { "type": "name", "properties": { "name": "urn:ogc:def:crs:OGC:1.3:CRS84" } },
    "features": points.map((point,ind) => (
      { "type": "Feature", "properties": { "id": "heatmap-point-"+ind, "quality":point[2] }, "geometry": { "type": "Point", "coordinates": [ point[1], point[0], 0.0 ] } }
    ))
  }
)

const startLocation = {
  lat:39.743,
  long:-104.988,
  zoom:13
}

const MapContainer = ({mapPreferences, updateMapPreferences}) => {
  const classes = useStyles();
  let [groceryStores, setGroceryStores] = React.useState([])
  let [currentLocation, setCurrentLocation] = React.useState({...startLocation})
  const mapContainer = React.useRef(null);
  const map = React.useRef(null);
  const markers = React.useRef([])
  const hasLoaded = React.useRef(false)
  const mapPreferencesRef = React.useRef(mapPreferences)

  const loadMapData = React.useRef(_.throttle(() => {
    // Lots of Refs used here because of closure issue with event being handled by mapbox
    if(!map.current) {
      return;
    }
    let bounds = map.current.getBounds();
    getMapData(bounds._sw, bounds._ne, map.current.getZoom().toFixed(2), mapPreferencesRef.current.loaded ? mapPreferencesRef.current.preferences.transit_type : null)
    .then(response => {
      setGroceryStores(response.grocery_stores)
      markers.current.forEach(marker => marker.remove());
      markers.current = [];
      if(map.current.getZoom() > 11) {
        response.grocery_stores.forEach((gStore) => {
          var marker = new mapboxgl.Marker({
          });
          var lngLat = {
            lon: gStore[2],
            lat: gStore[1]
          };
          marker.setLngLat(lngLat).addTo(map.current);
          markers.current.push(marker);
        })
      }
      if(!hasLoaded.current) {
        map.current.addSource('quality-heat', {
          'type': 'geojson',
          data: {
            'type': 'FeatureCollection',
            'features': []
          }
        });
  
        map.current.addLayer({
          'id': 'quality-heat',
          'type': 'heatmap',
          'source': 'quality-heat',
          'minZoom': 8,
          'paint': {
            'heatmap-weight': [
              'interpolate',
              ['exponential',1.5],
              ['get', 'quality'],
              0,
              0,
              10,
              1
            ],
            'heatmap-intensity': [
              'interpolate',
              ['linear'],
              ['zoom'],
              0,
              1,
              9,
              3
              ],
            'heatmap-color': [
              'interpolate',
              ['linear'],
              ['heatmap-density'],
              0,
              'red',
              0.9,
              'yellow',
              1,
              'green'
            ],
            'heatmap-opacity': 0.5,
            'heatmap-radius': {
              "base": 2,
              "stops": [
                [
                  10,
                  4.4
                ],
                [
                  19,
                  1126.4
                ]
              ]
            }
          }
        });
      }
      map.current.getSource('quality-heat').setData(buildHeatMapData(response.heatmap_points));
      hasLoaded.current = true;
    })
  }, 500)).current;

  const handleMapMove = (event) => {
    setCurrentLocation({
      long: map.current.getCenter().lng.toFixed(4),
      lat: map.current.getCenter().lat.toFixed(4),
      zoom: map.current.getZoom().toFixed(2)
    });
  }
  
  
  React.useEffect(() => {
    map.current = new mapboxgl.Map({
      container: mapContainer.current,
      style: 'mapbox://styles/mapbox/streets-v11',
      center: [currentLocation.long, currentLocation.lat],
      zoom: currentLocation.zoom
    });
    map.current.on('move', handleMapMove);
    map.current.on('moveend', () => {
      loadMapData();
    });
    loadMapData();
  },[])
  
  const onUpdateMapPreferences = () => {
    if(mapPreferences.preferences.transit_type != mapPreferencesRef.current.preferences.transit_type) {
      mapPreferencesRef.current = mapPreferences;
      loadMapData()
    }
  }
  
  const loadMapPreferences = () => {
    if(!mapPreferences.loaded) {
      getMapPreferences().then(response => {
        updateMapPreferences(response.map_preferences)
      })
    }
    onUpdateMapPreferences();
  }

  React.useEffect(loadMapPreferences, [mapPreferences]);

  return (
    <div ref={mapContainer} className={classes.mapContainer}/>
  )};
    
const mapStateToProps = state => ({
  mapPreferences: state.mapPreferences
})

const mapDispatchToProps = {
  updateMapPreferences
}


export default connect(mapStateToProps, mapDispatchToProps)(MapContainer)