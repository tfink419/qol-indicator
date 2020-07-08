import React from 'react';
import { CircularProgress, IconButton, makeStyles } from '@material-ui/core/';
import EditIcon from '@material-ui/icons/Edit';
import DeleteIcon from '@material-ui/icons/Delete';

import DeleteDialog from './DeleteDialog'
import UpdateGroceryStoreDialog from './UpdateGroceryStoreDialog'

import { getGroceryStore, deleteAdminGroceryStore } from 'fetch';

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

const useStyles = makeStyles({
  editIcon: {
    color: 'green',
  },
  deleteIcon: {
    color: 'red',
  }
});

export default ({groceryStoreId, open, isAdmin, onGroceryStoreChange}) => {
  const classes = useStyles();
  let [groceryStore, setGroceryStore] = React.useState(null);
  let [currentDialogOpen, setCurrentDialogOpen] = React.useState(null);

  const loadGroceryStore = () => {
    if(open) {
      setGroceryStore(null);
      getGroceryStore(groceryStoreId)
      .then(response => {
        setGroceryStore(response.grocery_store);
      });
    }
  }

  const handleCloseDialogs = (groceryStoreChange) => {
    setCurrentDialogOpen(null);
    if(groceryStoreChange) {
      onGroceryStoreChange();
    }
  }

  const handleOpenDialog = (type, groceryStore) => {
    setCurrentDialogOpen(type);
  }

  React.useEffect(loadGroceryStore, [open])

  return (
      groceryStore ?
      <React.Fragment>
        {groceryStore.name} <br/>
        {groceryStore.address} <br/>
        {cityZipPrint(groceryStore.city, groceryStore.state, groceryStore.zip)}
        <br />
        {
          isAdmin &&
          <React.Fragment>
            <IconButton onClick={() => handleOpenDialog('update', groceryStore)}>
              <EditIcon className={classes.editIcon} />
            </IconButton>
            <IconButton onClick={() => handleOpenDialog('delete', groceryStore)}>
              <DeleteIcon className={classes.deleteIcon}/>
            </IconButton>
            <DeleteDialog open={currentDialogOpen == 'delete'} onClose={handleCloseDialogs} objectId={groceryStore.id} 
              objectName={`${groceryStore.name} at ${groceryStore.address}`} objectType="Grocery Store"  deleteAction={deleteAdminGroceryStore} />
            <UpdateGroceryStoreDialog open={currentDialogOpen == 'update'} onClose={handleCloseDialogs} groceryStoreId={groceryStore.id} />
          </React.Fragment>
        }
      </React.Fragment>
      :
      <CircularProgress/>
    )
}