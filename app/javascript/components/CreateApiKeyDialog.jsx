import React from 'react';
import { connect } from 'react-redux';
import _ from 'lodash'
import { makeStyles } from '@material-ui/core/styles';
import { Button, Dialog, DialogActions, DialogContent, DialogTitle, CircularProgress } from '@material-ui/core/';

import { flashMessage } from '../actions/messages'
import { postAdminApiKey } from '../fetch';

const useStyles = makeStyles({
  cancelButton: {
    color: 'green'
  }
});

const CreateApiKeyDialog = ({open, onClose, flashMessage}) => {
  const blankApiKey = {
  };
  const classes = useStyles();
  let [loading, setLoading] = React.useState(false);
  let [apiKey, setApiKey] = React.useState(blankApiKey);
  let [apiKeyErrors, setApiKeyErrors] = React.useState({})
  
  const handleClose = () => {
    onClose(false);
  };

  const handleCreate = (event) => {
    event.preventDefault();
    setApiKeyErrors({});
    setLoading(true)
    postAdminApiKey(apiKey)
    .then(response => {
      flashMessage('info', 'ApiKey created successfully')
      setLoading(false)
      onClose(true);
    })
    .catch(error => {
      setLoading(false)
      if(error.status == 401) 
      {
        flashMessage('error', error.message);
        if(error.details) {
          setApiKeyErrors(_.mapValues(error.details, (messages, key) => {
            return messages.map(message => _.startCase(key) + " " +message).join("\n")
          }));
        }
      }
      if(error.status == 403) 
      {
        flashMessage('error', error.message);
      }
    })
  }
  
  const clearForm = () => {
    if(!open) {
      setApiKey(blankApiKey)
    }
  }

  React.useEffect(clearForm, [open])

  return (
    <Dialog open={open} disableBackdropClick={true} onClose={handleClose}>
      <form onSubmit={handleCreate}>
        <DialogTitle>Create New Api Key</DialogTitle>
        <DialogContent>
          { loading && <CircularProgress className={classes.circularProgress} />}
        </DialogContent>
        <DialogActions>
          <Button onClick={handleClose} color="primary" className={classes.cancelButton} autoFocus>
            Cancel
          </Button>
          <Button type="submit" color="primary">
            Create
          </Button>
        </DialogActions>
      </form>
    </Dialog>
  );
}

const mapDispatchToProps = {
  flashMessage
}

export default connect(null, mapDispatchToProps)(CreateApiKeyDialog)