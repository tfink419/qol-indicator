import React from "react";
import { makeStyles } from '@material-ui/core/styles'
import { connect } from "react-redux";
import { Map, TileLayer, Marker, Popup } from 'react-leaflet'
import { getMapData } from '../fetch'
import HeatMapLayer from './HeatMapLayer'
import { getMapPreferences } from '../fetch'
import { updateMapPreferences } from "../actions/map-preferences";

const useStyles = makeStyles({
  map: {
    height: 'calc(100vh - 64px)'
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
  lat:39.743,
  long:-104.988,
  zoom:13
}

const MapContainer = ({mapPreferences, updateMapPreferences}) => {
  const classes = useStyles();
  let [groceryStores, setGroceryStores] = React.useState([])
  let [currentLocation, setCurrentLocation] = React.useState([])

  const handleMapMove = (event) => {
    let map = event.target;
    let bounds = map.getBounds();
    setCurrentLocation( {...map.getCenter(), zoom:map.getZoom()})
    getMapData(bounds._southWest, bounds._northEast)
    .then(response => {
      setGroceryStores(response.grocery_stores)
    })
  }

  const loadMapPreferences = () => {
    if(!mapPreferences.loaded) {
      getMapPreferences().then(response => {
        updateMapPreferences(response.map_preferences)
      })
    }
  }

  const startPosition = [startLocation.lat, startLocation.long]

  React.useEffect(loadMapPreferences, [mapPreferences]);

  let heatmapLayerConfig = { 
    radius: 0.005 * mapPreferences.preferences.transit_type
  }

  return (
    <Map center={startPosition} zoom={startLocation.zoom} className={classes.map} onMoveEnd={handleMapMove} whenReady={handleMapMove}>
      <TileLayer
        attribution='&amp;copy <a href="http://osm.org/copyright">OpenStreetMap</a> contributors'
        url="https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png"
      />
      <HeatMapLayer groceryStores={groceryStores} config={heatmapLayerConfig}/>
      { currentLocation.zoom > 12 && groceryStores.map(groceryStore => (
        <React.Fragment key={groceryStore.id}>
          <Marker position={[groceryStore.lat, groceryStore.long]}>
            <Popup>
              {groceryStore.name} <br/>
              {groceryStore.address} <br/>
              {cityZipPrint(groceryStore.city, groceryStore.state, groceryStore.zip)}
            </Popup>
          </Marker>
        </React.Fragment>
      ))}
    </Map>
)};

const mapStateToProps = state => ({
  mapPreferences: state.mapPreferences
})

const mapDispatchToProps = {
  updateMapPreferences
}


export default connect(mapStateToProps, mapDispatchToProps)(MapContainer)