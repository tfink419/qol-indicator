import React from "react";
import _ from 'lodash';
import { connect } from 'react-redux'
import { makeStyles } from '@material-ui/core/styles'
import { Typography, Paper, Input, Button, CircularProgress, LinearProgress, Box, Checkbox, FormControlLabel } from '@material-ui/core'

import { flashMessage } from '../actions/messages'
import { setBuildHeatmapStatusReloadIntervalId, loadedBuildHeatmapStatuses, loadedCurrentBuildHeatmapStatus, updateBuildHeatmapStatusesPage, updateBuildHeatmapStatusesRowsPerPage } from '../actions/admin'
import { getAdminBuildHeatmapStatuses, getAdminBuildHeatmapStatus, postAdminBuildHeatmap } from '../fetch'
import { drawerWidth } from '../common'

const STATE_MAP = {
  'initialized': 'Job Sent to Sidekiq',
  'received': 'Job Received By Sidekiq',
  'branching': 'Branching Into Parellel Sidekiq\'s',
  'isochrones': 'Checking/Fetching Isochrone Polygons',
  'heatmap-points': 'Building Heatmap Points',
  'complete': 'Completed'
}

const BuildHeatmapPage = ({ setBuildHeatmapStatusReloadIntervalId, buildHeatmapStatuses, flashMessage, 
loadedBuildHeatmapStatuses, loadedCurrentBuildHeatmapStatus, updateBuildHeatmapStatusesPage, updateBuildHeatmapStatusesRowsPerPage }) => {
  let [rebuild, setRebuild] = React.useState(false);
  const { page, rowsPerPage, rows, current, loaded, reloadIntervalId } = buildHeatmapStatuses;

  const handleBuildHeatmap = (event) => {
    event.preventDefault();
    postAdminBuildHeatmap(rebuild)
    .then((response) => {
      flashMessage('info', response.message);
      loadBuildHeatmapStatuses(true);
    })
    .catch(error => {
      if(error.status == 400 || error.status == 403) 
      {
        flashMessage('error', error.message);
      }
    })
  }

  const loadBuildHeatmapStatuses = (force) => {
    if(!loaded || force) {
      getAdminBuildHeatmapStatuses(page, rowsPerPage).then(response => {
        if(response.status == 0) {
          loadedBuildHeatmapStatuses(response.build_heatmap_statuses.all, response.build_heatmap_status_count, response.build_heatmap_statuses.current)
        }
      })
    }
  }
  
  const reloadCurrentBuildHeatmapStatus = () => {
    getAdminBuildHeatmapStatus(current.id).then(response => {
      if(response.status == 0) {
        loadedCurrentBuildHeatmapStatus(response.build_heatmap_status)
      }
    })
  }
  
  const clearStatusReloadInterval = () => {
    clearInterval(reloadIntervalId);
    setBuildHeatmapStatusReloadIntervalId(null);
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
  
  React.useEffect(loadBuildHeatmapStatuses, [page, rowsPerPage]);
  React.useEffect(() => {
    if(current && (current.state == 'complete' || current.error)) {
      clearStatusReloadInterval();
      loadedCurrentBuildHeatmapStatus(null);
    }
    if(!reloadIntervalId && current) {
      setBuildHeatmapStatusReloadIntervalId(setInterval(reloadCurrentBuildHeatmapStatus, 5000))
    }
    else if(reloadIntervalId && !current) {
      clearInterval(reloadIntervalId);
      setBuildHeatmapStatusReloadIntervalId(null);
    }
    // return () => {
    //   console.log('2should get here eventually')
    //   clearInterval(intervalId);
    //   setIntervalId(null);
    // }
  }, [current]);
  
  return (
    <Paper>
      <Typography variant="h3">Build Heatmap</Typography>
      { !loaded && <CircularProgress/>}
      {loaded && current &&
        <React.Fragment>
          <Typography variant="h5">
            Currently Building Heatmap
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
          { current.build_heatmap_segment_statuses && _.sortBy(current.build_heatmap_segment_statuses, 'segment').map(segment_status => (
            <React.Fragment>
              <Typography variant="subtitle1">
                Segment #{segment_status.segment}
              </Typography>
              <Typography variant="subtitle2">
                Current State: <strong>{STATE_MAP[segment_status.state]}</strong>
              </Typography>
              { segment_status.state == 'heatmap-points' && (
                <Typography variant="subtitle2">
                  Current Lat: <strong>{segment_status.current_lat}</strong>
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
          <Typography variant="body1">This will Build the Heatmap</Typography>
          <FormControlLabel
            control={<Checkbox checked={rebuild} onChange={(e) => setRebuild(e.target.checked)} name="rebuild" />}
            label="Rebuild"
          />
          <form onSubmit={handleBuildHeatmap}>
            <Button type="submit"
              color="primary"
              variant="contained">
              Build Heatmap
            </Button>
          </form>
        </React.Fragment>
      }
    </Paper>
  )
}

const mapStateToProps = state => ({
  buildHeatmapStatuses: state.admin.buildHeatmapStatuses
})

const mapDispatchToProps = {
  flashMessage,
  setBuildHeatmapStatusReloadIntervalId,
  loadedBuildHeatmapStatuses,
  loadedCurrentBuildHeatmapStatus,
  updateBuildHeatmapStatusesPage,
  updateBuildHeatmapStatusesRowsPerPage
}

export default connect(mapStateToProps, mapDispatchToProps)(BuildHeatmapPage)