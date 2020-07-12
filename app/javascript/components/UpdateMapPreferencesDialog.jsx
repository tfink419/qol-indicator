import React from 'react';
import { connect } from 'react-redux';
import _ from 'lodash'
import { makeStyles } from '@material-ui/core/styles';
import { Button, Dialog, DialogActions, DialogContent, DialogTitle, Slider, CircularProgress, Typography } from '@material-ui/core/';

import { flashMessage } from '../actions/messages'
import { updateMapPreferences, tempUpdateMapPreferences, resetMapPreferences } from '../actions/map-preferences'
import { getMapPreferences, putMapPreferences } from '../fetch';

const transitTypeMarks = [
  {
    value: 1,
    label: 'Walking',
  },
  {
    value: 4,
    label: 'Biking',
  },
  {
    value: 7,
    label: 'Driving',
  }
];  

const useStyles = makeStyles({
  cancelButton: {
    color: 'green'
  },
  markLabel:{
    marginLeft:'12.5%'
  }
});

const UpdateMapPreferencesDialog = ({mapPreferences, onClose, flashMessage, updateMapPreferences, tempUpdateMapPreferences, resetMapPreferences}) => {
  const classes = useStyles();
  let [loading, setLoading] = React.useState(false);
  let [mapPreferenceErrors, setMapPreferenceErrors] = React.useState({})

  const loadMapPreferences = () => {
    if(!mapPreferences.loaded) {
      getMapPreferences().then(response => {
        updateMapPreferences(response.map_preferences)
      })
    }
    
  }

  const handleClose = () => {
    resetMapPreferences();
    onClose(false);
  };

  const handleUpdate = () => {
    setMapPreferenceErrors({});
    setLoading(true)
    putMapPreferences(mapPreferences.preferences)
    .then(response => {
      setLoading(false)
      onClose(true);
      flashMessage('info', response.message);
      updateMapPreferences(response.map_preferences);
    })
    .catch(error => {
      setLoading(false)
      if(error.status == 401) 
      {
        flashMessage('error', error.message);
        if(error.details) {
          setMapPreferenceErrors(_.mapValues(error.details, (messages, key) => {
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

  React.useEffect(loadMapPreferences, [mapPreferences]);

  return (
    <form onSubmit={handleUpdate}>
      <Dialog open={true} disableBackdropClick={true} onClose={handleClose}>
        <DialogTitle>Update Your Map Preferences</DialogTitle>
        <DialogContent>
          <form onSubmit={handleUpdate}>
            <Typography id="grcoery-store-label" gutterBottom>
              Grocery Store Proximity (minutes)
            </Typography>
            <Slider
              classes={{markLabel:classes.markLabel}}
              value={mapPreferences.preferences.transit_type}
              onChange={(e, val) => tempUpdateMapPreferences({ ...mapPreferences.preferences, transit_type:val })}
              step={1}
              min={1}
              max={9}
              valueLabelDisplay="auto"
              marks={transitTypeMarks}
              valueLabelFormat={(val) => ((val-1)%3+1)*8}
            />
          </form>
          { loading && <CircularProgress className={classes.circularProgress} />}
        </DialogContent>
        <DialogActions>
          <Button onClick={handleClose} color="primary" className={classes.cancelButton} autoFocus>
            Cancel
          </Button>
          <Button onClick={handleUpdate} color="primary">
            Update
          </Button>
        </DialogActions>
      </Dialog>
    </form>
  );
}

const mapStateToProps = state => ({
  mapPreferences: state.mapPreferences
})

const mapDispatchToProps = {
  flashMessage,
  updateMapPreferences,
  tempUpdateMapPreferences,
  resetMapPreferences
}

export default connect(mapStateToProps, mapDispatchToProps)(UpdateMapPreferencesDialog)