import React from "react";
import { makeStyles } from '@material-ui/core/styles'
import { connect } from "react-redux";

import { Map, TileLayer, Marker, Popup } from 'react-leaflet'
import { IconButton } from '@material-ui/core';
import EditIcon from '@material-ui/icons/Edit';
import DeleteIcon from '@material-ui/icons/Delete';

import { drawerWidth } from '../common'
import { updatedGroceryStores } from '../actions/admin'
import { getMapData, deleteGroceryStore } from '../fetch'
import DeleteDialog from '../components/DeleteDialog';
import UpdateGroceryStoreDialog from '../components/UpdateGroceryStoreDialog';
import HeatMapLayer from './HeatMapLayer'

const useStyles = makeStyles({
  map: {
    height: 'calc(100vh - 64px)',
    width: `calc(100% - ${drawerWidth}px)`,
    marginLeft: drawerWidth,
  },
  editIcon: {
    color: 'green',
  },
  deleteIcon: {
    color: 'red',
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

const AdminMapContainer = ({updatedGroceryStores}) => {
  const classes = useStyles();
  let [groceryStores, setGroceryStores] = React.useState([])
  let [selectedGroceryStore, setSelectedGroceryStore] = React.useState(null)
  let [currentLocation, setCurrentLocation] = React.useState([])
  let [currentDialogOpen, setCurrentDialogOpen] = React.useState(null);
  let [currentBounds, setCurrentBounds] = React.useState(null)

  const handleMapMove = (event) => {
    let map = event.target;
    let bounds = map.getBounds();
    setCurrentBounds(bounds);
    setCurrentLocation( {...map.getCenter(), zoom:map.getZoom()})
    loadMapData(bounds);
  }

  const loadMapData = (bounds) => {
    bounds = bounds || currentBounds;
    getMapData(bounds._southWest, bounds._northEast)
    .then(response => {
      setGroceryStores(response.grocery_stores)
    })
  }

  const handleCloseDialogs = (groceryStoreChange) => {
    setCurrentDialogOpen(null);
    setSelectedGroceryStore(null);
    if(groceryStoreChange) {
      loadMapData();
      updatedGroceryStores();
    }
  }

  const handleOpenDialog = (type, groceryStore) => {
    setSelectedGroceryStore(groceryStore)
    setCurrentDialogOpen(type);
  }

  const startPosition = [startLocation.lat, startLocation.long]
  return (
    <Map center={startPosition} zoom={startLocation.zoom} className={classes.map} onMoveEnd={handleMapMove} whenReady={handleMapMove}>
      <TileLayer
        attribution='&amp;copy <a href="http://osm.org/copyright">OpenStreetMap</a> contributors'
        url="https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png"
      />
      <HeatMapLayer groceryStores={groceryStores} />
      { currentLocation.zoom > 12 && groceryStores.map(groceryStore => (
        <Marker position={[groceryStore.lat, groceryStore.long]} key={groceryStore.id}>
          <Popup>
            {groceryStore.name} <br/>
            {groceryStore.address} <br/>
            {cityZipPrint(groceryStore.city, groceryStore.state, groceryStore.zip)}
            <br />
            <IconButton onClick={() => handleOpenDialog('update', groceryStore)}>
              <EditIcon className={classes.editIcon} />
            </IconButton>
            <IconButton onClick={() => handleOpenDialog('delete', groceryStore)}>
              <DeleteIcon className={classes.deleteIcon}/>
            </IconButton>
          </Popup>
        </Marker>
      ))}
      <DeleteDialog open={currentDialogOpen == 'delete'} onClose={handleCloseDialogs} objectId={selectedGroceryStore && selectedGroceryStore.id} 
        objectName={selectedGroceryStore && `${selectedGroceryStore.name} at ${selectedGroceryStore.address}`} objectType="Grocery Store"  deleteAction={deleteGroceryStore} />
      <UpdateGroceryStoreDialog open={currentDialogOpen == 'update'} onClose={handleCloseDialogs} groceryStoreId={selectedGroceryStore && selectedGroceryStore.id} />
    </Map>
)};


const mapDispatchToProps = {
  updatedGroceryStores
}

export default connect(null, mapDispatchToProps)(AdminMapContainer)