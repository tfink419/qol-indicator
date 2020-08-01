import React from 'react';
import { connect } from 'react-redux';
import { CircularProgress, IconButton, makeStyles } from '@material-ui/core/';
import EditIcon from '@material-ui/icons/Edit';
import DeleteIcon from '@material-ui/icons/Delete';

import DeleteDialog from './DeleteDialog'
import UpdateGroceryStoreDialog from './UpdateGroceryStoreDialog'

import { deleteAdminGroceryStore } from 'fetch';

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

const GroceryStorePopup = ({data, user, onGroceryStoreChange}) => {
  const classes = useStyles();
  let [currentDialogOpen, setCurrentDialogOpen] = React.useState(null);

  const handleCloseDialogs = (groceryStoreChange) => {
    setCurrentDialogOpen(null);
    if(groceryStoreChange) {
      onGroceryStoreChange(groceryStoreId);
    }
  }

  return (
      data ?
      <React.Fragment>
        {data.grocery_store.name} <br/>
        {data.grocery_store.address} <br/>
        {cityZipPrint(data.grocery_store.city, data.grocery_store.state, data.grocery_store.zip)}
        <br />
        {user.is_admin &&
          <React.Fragment>
            <IconButton onClick={() => setCurrentDialogOpen('update')}>
              <EditIcon className={classes.editIcon} />
            </IconButton>
            <IconButton onClick={() => setCurrentDialogOpen('delete')}>
              <DeleteIcon className={classes.deleteIcon}/>
            </IconButton>
            <DeleteDialog open={currentDialogOpen == 'delete'} onClose={handleCloseDialogs} objectId={data.grocery_store.id} 
              objectName={`${data.grocery_store.name} at ${data.grocery_store.address}`} objectType="Grocery Store"  deleteAction={deleteAdminGroceryStore} />
            <UpdateGroceryStoreDialog open={currentDialogOpen == 'update'} onClose={handleCloseDialogs} groceryStoreId={data.grocery_store.id} />
          </React.Fragment>
        }
      </React.Fragment>
      :
      <CircularProgress/>
    )
}

const mapStateToProps = state => ({
  user: state.user
})

export default connect(mapStateToProps) (GroceryStorePopup);