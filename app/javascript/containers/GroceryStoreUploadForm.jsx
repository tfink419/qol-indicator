import React from "react";
import { connect } from 'react-redux'
import { makeStyles } from '@material-ui/core/styles'
import { Typography, Paper, Input, Button, CircularProgress, Slider, Box, LinearProgress } from '@material-ui/core'

import { flashMessage } from '../actions/messages'
import { setGroceryStoreUploadStatusReloadIntervalId, loadedGroceryStoreUploadStatuses, loadedCurrentGroceryStoreUploadStatus, 
  updateUploadStatusesPage, updateUploadStatusesRowsPerPage, updatedGroceryStores } from '../actions/admin'
import { postAdminGroceryStoreUpload, getAdminGroceryStoreUploadStatuses, getAdminGroceryStoreUploadStatus } from '../fetch'
import { qualityMarks } from '../common'

const STATE_MAP = {
  'initialized': 'Job Sent to Sidekiq',
  'received': 'Job Received By Sidekiq',
  'overpass': 'Retrieving Overpass Response',
  'processing': 'Processing Grocery Stores',
  'complete': 'Completed'
}

const useStyles = makeStyles({
  buttonMargin: {
    marginLeft: '2em',
  },
  slider: {
    width:'40%'
  }
});

const preventDefault = (event) => event.preventDefault();

const GroceryStoreUploadForm = ({ groceryStoreUploadStatuses, setGroceryStoreUploadStatusReloadIntervalId, loadedGroceryStoreUploadStatuses, loadedCurrentGroceryStoreUploadStatus, 
updateGroceryStoreUploadStatusesPage, updateGroceryStoreUploadStatusesRowsPerPage, updatedGroceryStores, flashMessage }) => {
  const classes = useStyles();
  const { page, rowsPerPage, rows, current, loaded, reloadIntervalId } = groceryStoreUploadStatuses;
  
  const handleSubmit = (event) => {
    event.preventDefault();
    postAdminGroceryStoreUpload()
    .then((response) => {
      flashMessage('info', response.message);
      loadGroceryStoreUploadStatuses(true)
    })
    .catch(error => {
      if(error.status == 400 || error.status == 403) 
      {
        flashMessage('error', error.message);
      }
    })
  }

  const loadGroceryStoreUploadStatuses = (force) => {
    if(!loaded || force) {
      getAdminGroceryStoreUploadStatuses(page, rowsPerPage).then(response => {
        if(response.status == 0) {
          loadedGroceryStoreUploadStatuses(response.grocery_store_upload_statuses.all, response.grocery_store_upload_status_count, response.grocery_store_upload_statuses.current)
        }
      })
    }
  }
  
  const reloadCurrentUploadStatus = () => {
    getAdminGroceryStoreUploadStatus(current.id).then(response => {
      if(response.status == 0) {
        loadedCurrentGroceryStoreUploadStatus(response.grocery_store_upload_status)
      }
    })
  }
  
  const clearStatusReloadInterval = () => {
    clearInterval(reloadIntervalId);
    setGroceryStoreUploadStatusReloadIntervalId(null);
  }
  
  React.useEffect(loadGroceryStoreUploadStatuses, [page, rowsPerPage]);
  React.useEffect(() => {
    if(current && (current.state == 'complete' || current.error)) {
      clearStatusReloadInterval();
      loadedCurrentGroceryStoreUploadStatus(null)
      if(current.error) {
        flashMessage('error', current.error);
      }
      updatedGroceryStores();
    }
    if(!reloadIntervalId && current) {
      setGroceryStoreUploadStatusReloadIntervalId(setInterval(reloadCurrentUploadStatus, 5000))
    }
    else if(reloadIntervalId && !current) {
      clearInterval(reloadIntervalId);
      setGroceryStoreUploadStatusReloadIntervalId(null);
    }
    // return () => {
    //   console.log('2should get here eventually')
    //   clearInterval(intervalId);
    //   setIntervalId(null);
    // }
  }, [current]);

  return (
    <Paper>
      <Typography variant="h3">Start Grocery Store Upload</Typography>
      { !loaded && <CircularProgress />}
      { loaded && current &&
        <React.Fragment>
          <Typography variant="h5">
            Currently Building Grocery Store
          </Typography>
          <Typography variant="subtitle1">
            Current State: <strong>{STATE_MAP[current.state]}</strong>
          </Typography>
          <Box display="flex" alignItems="center">
            <Box width="100%" mr={1}>
              <LinearProgress variant="determinate" value={current.percent} />
            </Box>
            <Box minWidth={35}>
              <Typography variant="body2">
                {`${current.percent}%`}
              </Typography>
            </Box>
          </Box>
        </React.Fragment>
      }
      { loaded && !current &&
        <Button variant="contained" onClick={handleSubmit}>Start</Button>
      }
    </Paper>
  )
}

const mapStateToProps = state => ({
  groceryStoreUploadStatuses: state.admin.groceryStoreUploadStatuses
})

const mapDispatchToProps = {
  flashMessage,
  setGroceryStoreUploadStatusReloadIntervalId,
  loadedGroceryStoreUploadStatuses,
  loadedCurrentGroceryStoreUploadStatus,
  updateUploadStatusesPage,
  updateUploadStatusesRowsPerPage,
  updatedGroceryStores
}

export default connect(mapStateToProps, mapDispatchToProps)(GroceryStoreUploadForm)