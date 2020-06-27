import React from "react";
import { connect } from 'react-redux'
import { makeStyles } from '@material-ui/core/styles'
import { Typography, Paper, Input, Button, CircularProgress, LinearProgress, Box } from '@material-ui/core'

import { flashMessage } from '../actions/messages'
import { loadedBuildHeatmapStatuses, loadedCurrentBuildHeatmapStatus, updateBuildHeatmapStatusesPage, updateBuildHeatmapStatusesRowsPerPage } from '../actions/admin'
import { getBuildHeatmapStatuses, getBuildHeatmapStatus, postBuildHeatmap } from '../fetch'
import { drawerWidth } from '../common'

const useStyles = makeStyles({
  pushRight: {
    width: `calc(100% - ${drawerWidth}px)`,
    marginLeft: drawerWidth,
  }
});

const BuildHeatmapPage = ({ buildHeatmapStatuses, flashMessage, loadedBuildHeatmapStatuses, loadedCurrentBuildHeatmapStatus, updateBuildHeatmapStatusesPage, updateBuildHeatmapStatusesRowsPerPage }) => {
  const classes = useStyles();
  const { page, rowsPerPage, rows, current, loaded } = buildHeatmapStatuses;
  let [intervalId, setIntervalId] = React.useState(null);

  const handleBuildHeatmap = (event) => {
    event.preventDefault();
    buildingHeatmap();
    postBuildHeatmap()
    .then((response) => {
      buildHeatmapDone()
      flashMessage('info', response.message);
    })
    .catch(error => {
      if(error.status == 400 || error.status == 403) 
      {
        flashMessage('error', error.message);
      }
    })
  }

  const loadBuildHeatmapStatuses = () => {
    if(!loaded) {
      getBuildHeatmapStatuses(page, rowsPerPage).then(response => {
        if(response.status == 0) {
          loadedBuildHeatmapStatuses(response.build_heatmap_statuses.all, response.build_heatmap_status_count, response.build_heatmap_statuses.current)
        }
      })
    }
  }
  
  const reloadCurrentBuildHeatmapStatus = () => {
    getBuildHeatmapStatus(current.id).then(response => {
      if(response.status == 0) {
        loadedCurrentBuildHeatmapStatus(response.build_heatmap_status)
      }
    })
  }
  
  React.useEffect(loadBuildHeatmapStatuses, [page, rowsPerPage]);
  React.useEffect(() => {
    return () => {
      clearInterval(intervalId);
      setIntervalId(null);
    }
  }, [])
  React.useEffect(() => {
    if(!intervalId && current) {
      setIntervalId(setInterval(reloadCurrentBuildHeatmapStatus, 5000))
    }
    else if(intervalId && !current) {
      clearInterval(intervalId);
      setIntervalId(null);
    }
  }, [current]);
  
  return (
    <Paper className={classes.pushRight}>
      <Typography variant="h3">Build Heatmap</Typography>
      { !loaded && <CircularProgress/>}
      {loaded && current &&
        <React.Fragment>
          <Typography variant="h5">
            Currently Building Heatmap
          </Typography>
          <Typography variant="subtitle1">
            {current.state}
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
      {loaded && !current &&
        <React.Fragment>
          <Typography variant="body1">This will Build the Heatmap</Typography>
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
  loadedBuildHeatmapStatuses,
  loadedCurrentBuildHeatmapStatus,
  updateBuildHeatmapStatusesPage,
  updateBuildHeatmapStatusesRowsPerPage
}

export default connect(mapStateToProps, mapDispatchToProps)(BuildHeatmapPage)