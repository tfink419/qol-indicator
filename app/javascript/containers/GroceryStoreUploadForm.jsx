import React from "react";
import { connect } from 'react-redux'
import { makeStyles } from '@material-ui/core/styles'
import { Typography, Paper, Input, Button, CircularProgress, Slider, Box, LinearProgress } from '@material-ui/core'

import { flashMessage } from '../actions/messages'
import { setUploadCsvStatusReloadIntervalId, loadedUploadCsvStatuses, loadedCurrentUploadCsvStatus, 
  updateUploadCsvStatusesPage, updateUploadCsvStatusesRowsPerPage } from '../actions/admin'
import { postGroceryStoreUploadCsv, getGroceryStoreUploadCsvStatuses, getGroceryStoreUploadCsvStatus } from '../fetch'
import { drawerWidth, qualityMarks } from '../common'

const STATE_MAP = {
  'initialized': 'Job Sent to Resque',
  'received': 'Job Received By Resque',
  'parsing-csv': 'Parsing CSV File',
  'processing': 'Processing Grocery Stores',
  'complete': 'Completed'
}

const useStyles = makeStyles({
  pushRight: {
    width: `calc(100% - ${drawerWidth}px)`,
    marginLeft: drawerWidth,
  },
  buttonMargin: {
    marginLeft: '2em',
  },
  slider: {
    width:'40%'
  }
});

const preventDefault = (event) => event.preventDefault();

const GroceryStoreUploadForm = ({ uploadCsvStatuses, setUploadCsvStatusReloadIntervalId, loadedUploadCsvStatuses, loadedCurrentUploadCsvStatus, 
updateUploadCsvStatusesPage, updateUploadCsvStatusesRowsPerPage, flashMessage }) => {
  const classes = useStyles();
  const { page, rowsPerPage, rows, current, loaded, reloadIntervalId } = uploadCsvStatuses;

  let [selectedFile, setSelectedFile] = React.useState(null);
  let [quality, setQuality] = React.useState(5);

  const handleFileSelect = (event) => {
    setSelectedFile(event.target.files[0])
  }

  const handleFileSubmit = (event) => {
    event.preventDefault();
    postGroceryStoreUploadCsv(selectedFile, quality)
    .then((response) => {
      flashMessage('info', response.message);
      loadUploadCsvStatuses(true)
    })
    .catch(error => {
      if(error.status == 400 || error.status == 403) 
      {
        flashMessage('error', error.message);
      }
    })
  }

  const loadUploadCsvStatuses = (force) => {
    if(!loaded || force) {
      getGroceryStoreUploadCsvStatuses(page, rowsPerPage).then(response => {
        if(response.status == 0) {
          loadedUploadCsvStatuses(response.upload_csv_statuses.all, response.upload_csv_status_count, response.upload_csv_statuses.current)
        }
      })
    }
  }
  
  const reloadCurrentUploadCsvStatus = () => {
    getGroceryStoreUploadCsvStatus(current.id).then(response => {
      if(response.status == 0) {
        loadedCurrentUploadCsvStatus(response.upload_csv_status)
      }
    })
  }
  
  const clearStatusReloadInterval = () => {
    clearInterval(reloadIntervalId);
    setUploadCsvStatusReloadIntervalId(null);
  }
  
  React.useEffect(loadUploadCsvStatuses, [page, rowsPerPage]);
  React.useEffect(() => {
    if(current && (current.state == 'complete' || current.error)) {
      clearStatusReloadInterval();
      loadedCurrentUploadCsvStatus(null)
    }
    if(!reloadIntervalId && current) {
      setUploadCsvStatusReloadIntervalId(setInterval(reloadCurrentUploadCsvStatus, 5000))
    }
    else if(reloadIntervalId && !current) {
      clearInterval(reloadIntervalId);
      setUploadCsvStatusReloadIntervalId(null);
    }
    // return () => {
    //   console.log('2should get here eventually')
    //   clearInterval(intervalId);
    //   setIntervalId(null);
    // }
  }, [current]);

  return (
    <Paper className={classes.pushRight}>
      <Typography variant="h3">Upload CSV</Typography>
      { !loaded && <CircularProgress />}
      { loaded && current &&
        <React.Fragment>
          <Typography variant="h5">
            Currently awaiting csv file '{current.filename}'
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
        <React.Fragment>
          <Typography variant="body1">Please Upload a CSV file containing the following fields with header names:</Typography>
          <Typography variant="body2">Name, Address, City, State, Zip, Latitude (Optional), Longitude (Optional), Quality (Optional)</Typography>
          <form onSubmit={handleFileSubmit}>
            <Input type="file" onChange={handleFileSelect} inputProps={{accept:'.csv'}}/>
            <Button type="submit" className={classes.buttonMargin}
              color="primary"
              variant="contained">
              Upload CSV
            </Button>
            <Typography variant="subtitle1">
              Default Quality
            </Typography>
            <Slider
                className={classes.slider}
                value={quality}
                onChange={(e, val) => setQuality(val)}
                step={1}
                min={0}
                max={10}
                valueLabelDisplay="auto"
                marks={qualityMarks}
            />
          </form>
        </React.Fragment>
      }
    </Paper>
  )
}

const mapStateToProps = state => ({
  uploadCsvStatuses: state.admin.uploadCsvStatuses
})

const mapDispatchToProps = {
  flashMessage,
  setUploadCsvStatusReloadIntervalId,
  loadedUploadCsvStatuses,
  loadedCurrentUploadCsvStatus,
  updateUploadCsvStatusesPage,
  updateUploadCsvStatusesRowsPerPage
}

export default connect(mapStateToProps, mapDispatchToProps)(GroceryStoreUploadForm)