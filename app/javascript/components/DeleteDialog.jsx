import React from 'react';
import { connect } from 'react-redux';
import { makeStyles } from '@material-ui/core/styles';
import { Button, Dialog, DialogActions, DialogContent,
  DialogContentText, DialogTitle, CircularProgress } from '@material-ui/core/';

import { flashMessage } from '../actions/messages'

const useStyles = makeStyles({
  cancelButton: {
    color: 'green'
  },
  deleteButton: {
    color: 'red'
  },
  circularProgress: {
    color: 'red'
  }
});

const DeleteDialog = ({open, objectType, objectName, objectId, onClose, flashMessage, deleteAction}) => {
  const classes = useStyles();
  let [loading, setLoading] = React.useState(false);
  
  const handleClose = () => {
    onClose(false);
  };

  const handleDelete = () => {
    setLoading(true)
    deleteAction(objectId)
    .then(response => {
      setLoading(false)
      onClose(true);
    })
    .catch(error => {
      if(error.status == 403) {
        flashMessage('error', error.message)
        setLoading(false)
      }
    })
  }

  return (
    <div>
      <Dialog open={open} onClose={handleClose}>
        <DialogTitle>Delete {objectType}?</DialogTitle>
        <DialogContent>
          <DialogContentText>
            Are you sure you want to delete {objectType} '{objectName}'?
          </DialogContentText>
          { loading && <CircularProgress className={classes.circularProgress} />}
        </DialogContent>
        <DialogActions>
          <Button onClick={handleClose} color="primary" className={classes.cancelButton} autoFocus>
            Cancel
          </Button>
          <Button onClick={handleDelete} color="primary"  className={classes.deleteButton}>
            Delete
          </Button>
        </DialogActions>
      </Dialog>
    </div>
  );
}

const mapDispatchToProps = {
  flashMessage
}

export default connect(null, mapDispatchToProps)(DeleteDialog)