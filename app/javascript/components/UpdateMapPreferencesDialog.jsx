import React from 'react';
import { connect } from 'react-redux';
import _ from 'lodash'
import { makeStyles } from '@material-ui/core/styles';
import { Button, Dialog, DialogActions, DialogContent, DialogTitle, Grid, FormControl, FormGroup, FormControlLabel, Checkbox, FormHelperText,
Slider, CircularProgress, Typography, ExpansionPanel, ExpansionPanelSummary, ExpansionPanelDetails } from '@material-ui/core/';

import { flashMessage } from '../actions/messages'
import { updateMapPreferences, tempUpdateMapPreferences, resetMapPreferences } from '../actions/map-preferences'
import { getMapPreferences, putMapPreferences } from '../fetch';

const groceryStoreTransitTypeMarks = [
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
const parkTransitTypeMarks = [
  {
    value: 1,
    label: 'Walking',
  },
  {
    value: 4,
    label: 'Biking',
  }
];  

const useStyles = makeStyles({
  cancelButton: {
    color: 'green'
  },
  transitTypeSlider:{
    marginLeft:'12.5%'
  }
});

const totalRatio = (mapPreferences) => (
  mapPreferences.grocery_store_ratio +
  mapPreferences.census_tract_poverty_ratio +
  mapPreferences.park_ratio
)

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

  const handleGroceryStoreTagChange = (amount, checked) => {
    let tags;
    if(checked) {
      tags = mapPreferences.preferences.grocery_store_tags | (1 << amount);
    }
    else {
      tags =  mapPreferences.preferences.grocery_store_tags & ~(1 << amount);
    }
    tempUpdateMapPreferences({ ...mapPreferences.preferences, grocery_store_tags:tags })
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
          <ExpansionPanel>
            <ExpansionPanelSummary>
              <Typography>Grocery Store</Typography>
            </ExpansionPanelSummary>
            <ExpansionPanelDetails>
              <Grid container>
                <Grid item xs={12}>
                  <Typography gutterBottom>
                    Ratio
                  </Typography>
                  <Slider
                      value={mapPreferences.preferences.grocery_store_ratio}
                      onChange={(e, val) => tempUpdateMapPreferences({ ...mapPreferences.preferences, grocery_store_ratio:val })}
                      step={1}
                      min={0}
                      max={100}
                      valueLabelDisplay="auto"
                      valueLabelFormat={(val) => val+"/"+totalRatio(mapPreferences.preferences)}
                    />
                </Grid>
                <Grid item xs={12}>
                  <Typography gutterBottom>
                    Proximity (minutes)
                  </Typography>
                  <Slider
                    classes={{markLabel:classes.transitTypeSlider}}
                    value={mapPreferences.preferences.grocery_store_transit_type}
                    onChange={(e, val) => tempUpdateMapPreferences({ ...mapPreferences.preferences, grocery_store_transit_type:val })}
                    step={1}
                    min={1}
                    max={9}
                    valueLabelDisplay="auto"
                    marks={groceryStoreTransitTypeMarks}
                    valueLabelFormat={(val) => ((val-1)%3+1)*8}
                  />
                </Grid>
                <Grid item xs={12}>
                  <FormControl component="fieldset" className={classes.formControl}>
                    <FormGroup>
                      <FormControlLabel
                        control={<Checkbox checked={(mapPreferences.preferences.grocery_store_tags & 1) == 1} onChange={e => handleGroceryStoreTagChange(0, e.target.checked)} name="organic" />}
                        label="Organic"
                      />
                      <FormControlLabel
                        control={<Checkbox checked={((mapPreferences.preferences.grocery_store_tags >> 1) & 1) == 1} onChange={e => handleGroceryStoreTagChange(1, e.target.checked)} name="grocery_and_wholesale" />}
                        label="Grocery Stores"
                      />
                      <FormControlLabel
                        control={<Checkbox checked={((mapPreferences.preferences.grocery_store_tags >> 2) & 1) == 1} onChange={e => handleGroceryStoreTagChange(2, e.target.checked)} name="grocery_and_wholesale" />}
                        label="Wholesale Stores"
                      />
                      <FormControlLabel
                        control={<Checkbox checked={((mapPreferences.preferences.grocery_store_tags >> 4) & 1) == 1} onChange={e => handleGroceryStoreTagChange(4, e.target.checked)} name="non_vegan_specialty" />}
                        label="Butchers and Seafood Vendors"
                      />
                      <FormControlLabel
                        control={<Checkbox checked={((mapPreferences.preferences.grocery_store_tags >> 5) & 1) == 1} onChange={e => handleGroceryStoreTagChange(5, e.target.checked)} name="non_vegan_specialty" />}
                        label="Cheese Vendors"
                      />
                      <FormControlLabel
                        control={<Checkbox checked={((mapPreferences.preferences.grocery_store_tags >> 6) & 1) == 1} onChange={e => handleGroceryStoreTagChange(6, e.target.checked)} name="vegan_specialty" />}
                        label="Bakeries and Pastries"
                      />
                      <FormControlLabel
                        control={<Checkbox checked={((mapPreferences.preferences.grocery_store_tags >> 3) & 1) == 1} onChange={e => handleGroceryStoreTagChange(3, e.target.checked)} name="convenience_stores" />}
                        label="Convenience Stores"
                      />
                      <FormControlLabel
                        control={<Checkbox checked={((mapPreferences.preferences.grocery_store_tags >> 7) & 1) == 1} onChange={e => handleGroceryStoreTagChange(7, e.target.checked)} name="others" />}
                        label="Others"
                      />
                    </FormGroup>
                  </FormControl>
                </Grid>
              </Grid>
            </ExpansionPanelDetails>
          </ExpansionPanel>
          <ExpansionPanel>
            <ExpansionPanelSummary>
              <Typography>Park</Typography>
            </ExpansionPanelSummary>
            <ExpansionPanelDetails>
              <Grid container>
                <Grid item xs={12}>
                  <Typography gutterBottom>
                    Ratio
                  </Typography>
                  <Slider
                      value={mapPreferences.preferences.park_ratio}
                      onChange={(e, val) => tempUpdateMapPreferences({ ...mapPreferences.preferences, park_ratio:val })}
                      step={1}
                      min={0}
                      max={100}
                      valueLabelDisplay="auto"
                      valueLabelFormat={(val) => val+"/"+totalRatio(mapPreferences.preferences)}
                    />
                </Grid>
                <Grid item xs={12}>
                  <Typography gutterBottom>
                    Proximity (minutes)
                  </Typography>
                  <Slider
                    classes={{markLabel:classes.transitTypeSlider}}
                    value={mapPreferences.preferences.park_transit_type}
                    onChange={(e, val) => tempUpdateMapPreferences({ ...mapPreferences.preferences, park_transit_type:val })}
                    step={1}
                    min={1}
                    max={6}
                    valueLabelDisplay="auto"
                    marks={parkTransitTypeMarks}
                    valueLabelFormat={(val) => ((val-1)%3+1)*6}
                  />
                </Grid>
              </Grid>
            </ExpansionPanelDetails>
          </ExpansionPanel>
          <ExpansionPanel>
            <ExpansionPanelSummary>
              <Typography>Poverty Percent</Typography>
            </ExpansionPanelSummary>
            <ExpansionPanelDetails>
              <Grid container>
                <Grid item xs={12}>
                  <Typography gutterBottom>
                    Ratio
                  </Typography>
                  <Slider
                      value={mapPreferences.preferences.census_tract_poverty_ratio}
                      onChange={(e, val) => tempUpdateMapPreferences({ ...mapPreferences.preferences, census_tract_poverty_ratio:val })}
                      step={1}
                      min={0}
                      max={100}
                      valueLabelDisplay="auto"
                      valueLabelFormat={(val) => val+"/"+totalRatio(mapPreferences.preferences)}
                    />
                </Grid>
                <Grid item xs={12}>
                  <Typography gutterBottom>
                    Percent Range
                  </Typography>
                  <Slider
                    value={[mapPreferences.preferences.census_tract_poverty_low, mapPreferences.preferences.census_tract_poverty_high]}
                    onChange={(e, val) => tempUpdateMapPreferences({ ...mapPreferences.preferences, census_tract_poverty_low:val[0], census_tract_poverty_high:val[1] })}
                    step={1}
                    min={0}
                    max={100}
                    valueLabelDisplay="auto"
                    valueLabelFormat={(val) => val+"%"}
                  />
                </Grid>
              </Grid>
            </ExpansionPanelDetails>
          </ExpansionPanel>
          <ExpansionPanel>
            <ExpansionPanelSummary>
              <Typography>Ratios</Typography>
            </ExpansionPanelSummary>
            <ExpansionPanelDetails>
              <Grid container>
                <Grid item xs={12}>
                  <Typography gutterBottom>
                    Grocery Store
                  </Typography>
                </Grid>
                <Grid item xs={12}>
                  <Slider
                    value={mapPreferences.preferences.grocery_store_ratio}
                    onChange={(e, val) => tempUpdateMapPreferences({ ...mapPreferences.preferences, grocery_store_ratio:val })}
                    step={1}
                    min={0}
                    max={100}
                    valueLabelDisplay="auto"
                    valueLabelFormat={(val) => val+"/"+totalRatio(mapPreferences.preferences)}
                  />
                </Grid>
                <Grid item xs={12}>
                  <Typography gutterBottom>
                    Park
                  </Typography>
                </Grid>
                <Grid item xs={12}>
                  <Slider
                    value={mapPreferences.preferences.park_ratio}
                    onChange={(e, val) => tempUpdateMapPreferences({ ...mapPreferences.preferences, park_ratio:val })}
                    step={1}
                    min={0}
                    max={100}
                    valueLabelDisplay="auto"
                    valueLabelFormat={(val) => val+"/"+totalRatio(mapPreferences.preferences)}
                  />
                </Grid>
                <Grid item xs={12}>
                  <Typography gutterBottom>
                    Poverty Percent
                  </Typography>
                </Grid>
                <Grid item xs={12}>
                  <Slider
                    value={mapPreferences.preferences.census_tract_poverty_ratio}
                    onChange={(e, val) => tempUpdateMapPreferences({ ...mapPreferences.preferences, census_tract_poverty_ratio:val })}
                    step={1}
                    min={0}
                    max={100}
                    valueLabelDisplay="auto"
                    valueLabelFormat={(val) => val+"/"+totalRatio(mapPreferences.preferences)}
                  />
                </Grid>
              </Grid>
            </ExpansionPanelDetails>
          </ExpansionPanel>
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