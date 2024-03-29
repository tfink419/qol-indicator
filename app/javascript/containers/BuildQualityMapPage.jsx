import React from "react";
import _ from 'lodash';
import { connect } from 'react-redux'
import { makeStyles } from '@material-ui/core/styles'
import { Typography, Paper, Input, Button, CircularProgress, LinearProgress, Box, Checkbox, FormControlLabel, Select, MenuItem } from '@material-ui/core'

import { flashMessage } from '../actions/messages'
import { setBuildQualityMapStatusReloadIntervalId, loadedBuildQualityMapStatuses, loadedCurrentBuildQualityMapStatus, updateBuildQualityMapStatusesPage, updateBuildQualityMapStatusesRowsPerPage } from '../actions/admin'
import { getAdminBuildQualityMapStatuses, getAdminBuildQualityMapStatus, postAdminBuildQualityMap } from '../fetch'

const STATE_MAP = {
  'initialized': 'Job Sent to Sidekiq',
  'received': 'Job Received By Sidekiq',
  'branching': 'Branching Into Parellel Sidekiq\'s',
  'isochrones': 'Checking/Fetching Isochrone Polygons',
  'isochrones-complete': 'Finished Isochrone Polygons, Waiting For Others',
  'quality-map-points': 'Building Quality Map Points',
  'waiting-shrink': 'Waiting for Next Shrink Phase',
  'shrink': 'Shrinking',
  'complete': 'Completed'
}

const BuildQualityMapPage = ({ setBuildQualityMapStatusReloadIntervalId, buildQualityMapStatuses, flashMessage, 
loadedBuildQualityMapStatuses, loadedCurrentBuildQualityMapStatus, updateBuildQualityMapStatusesPage, updateBuildQualityMapStatusesRowsPerPage }) => {
  let [mapPointType, setMapPointType] = React.useState("GroceryStoreFoodQuantityMapPoint");
  const { page, rowsPerPage, rows, current, loaded, reloadIntervalId } = buildQualityMapStatuses;

  const handleBuildQualityMap = (event) => {
    event.preventDefault();
    postAdminBuildQualityMap(mapPointType)
    .then((response) => {
      flashMessage('info', response.message);
      loadBuildQualityMapStatuses(true);
    })
    .catch(error => {
      if(error.status == 400 || error.status == 403) 
      {
        flashMessage('error', error.message);
      }
    })
  }

  const loadBuildQualityMapStatuses = (force) => {
    if(!loaded || force) {
      getAdminBuildQualityMapStatuses(page, rowsPerPage).then(response => {
        if(response.status == 0) {
          loadedBuildQualityMapStatuses(response.build_quality_map_statuses.all, response.build_quality_map_status_count, response.build_quality_map_statuses.current)
        }
      })
    }
  }
  
  const reloadCurrentBuildQualityMapStatus = () => {
    getAdminBuildQualityMapStatus(current.id).then(response => {
      if(response.status == 0) {
        loadedCurrentBuildQualityMapStatus(response.build_quality_map_status)
      }
    })
  }
  
  const clearStatusReloadInterval = () => {
    clearInterval(reloadIntervalId);
    setBuildQualityMapStatusReloadIntervalId(null);
  }

  const calcEta = () => {
    let estimatedEta = Math.round(((Date.now()-new Date(current.created_at))*((100-current.percent)/current.percent))/1000);
    let etaString = [];
    let currentCalc = estimatedEta%60;
    if(currentCalc != 0) {
      etaString = [currentCalc + " second"+(currentCalc>1 ? "s" : "")].concat(etaString)
    }
    estimatedEta = Math.floor(estimatedEta/60);
    currentCalc = estimatedEta%60;
    if(currentCalc != 0) {
      etaString = [currentCalc + " minute"+(currentCalc>1 ? "s" : "")].concat(etaString);
    }
    estimatedEta = Math.floor(estimatedEta/60);
    currentCalc = estimatedEta%24;
    if(currentCalc != 0) {
      etaString = [currentCalc + " hour"+(currentCalc>1 ? "s" : "")].concat(etaString);
    }
    estimatedEta = Math.floor(estimatedEta/24);
    if(estimatedEta != 0) {
      etaString = [estimatedEta + " day"+(estimatedEta>1 ? "s" : "")].concat(etaString);
    }
    return etaString.join(' ');
  }
  
  React.useEffect(loadBuildQualityMapStatuses, [page, rowsPerPage]);
  React.useEffect(() => {
    if(current && (current.state == 'complete' || current.error)) {
      clearStatusReloadInterval();
      loadedCurrentBuildQualityMapStatus(null);
      loadBuildQualityMapStatuses(true);
      if(current.error) {
        flashMessage('error', current.error);
      }
    }
    if(!reloadIntervalId && current) {
      setBuildQualityMapStatusReloadIntervalId(setInterval(reloadCurrentBuildQualityMapStatus, 5000))
    }
    else if(reloadIntervalId && !current) {
      clearInterval(reloadIntervalId);
      setBuildQualityMapStatusReloadIntervalId(null);
    }
  }, [current]);
  
  return (
    <Paper>
      <Typography variant="h3">Build Quality Map</Typography>
      { !loaded && <CircularProgress/>}
      {loaded && current &&
        <React.Fragment>
          <Typography variant="h5">
            Currently Building Quality Map
          </Typography>
          <Typography variant="subtitle1">
            Current State: <strong>{STATE_MAP[current.state]}</strong>
          </Typography>
          <Typography variant="subtitle2">
            ETA: <strong>{calcEta()}</strong>
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
          { current.segment_statuses && _.sortBy(current.segment_statuses, 'segment').map(segment_status => (
            <React.Fragment key={segment_status.id}>
              <Typography variant="subtitle1">
                Segment #{segment_status.segment}
              </Typography>
              <Typography variant="subtitle2">
                Current State: <strong>{STATE_MAP[segment_status.state]}</strong>
              </Typography>
              { (segment_status.state == 'quality-map-points' || segment_status.state == 'shrink') && (
                <Typography variant="subtitle2">
                  Current Lat: <strong>{segment_status.current_lat}</strong>
                  &nbsp; Current Lat Sector: <strong>{segment_status.current_lat_sector}</strong>
                </Typography>
              )}
              <Box display="flex" alignItems="center">
                <Box width="100%" mr={1}>
                  <LinearProgress variant="determinate" value={segment_status.percent} />
                </Box>
                <Box minWidth={35}>
                  <Typography variant="body2">
                    {`${segment_status.percent}%`}
                  </Typography>
                </Box>
              </Box>
            </React.Fragment>
          ))}
        </React.Fragment>
      }
      {loaded && !current &&
        <React.Fragment>
          <Typography variant="body1">This will Build the QualityMap</Typography>
          <Select value={mapPointType}  onChange={(e) => setMapPointType(e.target.value)}>
            <MenuItem value={"GroceryStoreFoodQuantityMapPoint"}>Grocery Store Quality</MenuItem>
            <MenuItem value={"CensusTractPovertyMapPoint"}>Census Tract Poverty</MenuItem>
            <MenuItem value={"ParkActivitiesMapPoint"}>Park Activities</MenuItem>
          </Select>
          <form onSubmit={handleBuildQualityMap}>
            <Button type="submit"
              color="primary"
              variant="contained">
              Build Quality Map
            </Button>
          </form>
        </React.Fragment>
      }
    </Paper>
  )
}

const mapStateToProps = state => ({
  buildQualityMapStatuses: state.admin.buildQualityMapStatuses
})

const mapDispatchToProps = {
  flashMessage,
  setBuildQualityMapStatusReloadIntervalId,
  loadedBuildQualityMapStatuses,
  loadedCurrentBuildQualityMapStatus,
  updateBuildQualityMapStatusesPage,
  updateBuildQualityMapStatusesRowsPerPage
}

export default connect(mapStateToProps, mapDispatchToProps)(BuildQualityMapPage)