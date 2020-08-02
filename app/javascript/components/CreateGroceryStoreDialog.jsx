import React from 'react';
import { connect } from 'react-redux';
import _ from 'lodash'
import { makeStyles } from '@material-ui/core/styles';
import { Button, Dialog, DialogActions, DialogContent, DialogTitle, Card, CardContent, TextField, Slider,
  CircularProgress, Grid, Typography, ExpansionPanel, ExpansionPanelSummary, ExpansionPanelDetails } from '@material-ui/core/';

import { flashMessage } from '../actions/messages'
import { postAdminGroceryStore } from '../fetch';
import StateSelect from './StateSelect';
import { foodQuantityMarks } from '../common'

const useStyles = makeStyles({
  cancelButton: {
    color: 'green'
  },
  slider: {
    marginLeft:'5%',
    width:'90%'
  }
});

const CreateGroceryStoreDialog = ({open, onClose, flashMessage}) => {
  const blankGroceryStore = {
    name: '',
    address: '',
    city: '',
    state: '',
    zip:'',
    lat:'',
    long:'',
    food_quantity: 5
  };
  const classes = useStyles();
  let [loading, setLoading] = React.useState(false);
  let [groceryStore, setGroceryStore] = React.useState(blankGroceryStore);
  let [groceryStoreErrors, setGroceryStoreErrors] = React.useState({})
  
  const handleClose = () => {
    onClose(false);
  };

  const handleCreate = (event) => {
    event.preventDefault();
    setGroceryStoreErrors({});
    setLoading(true)
    postAdminGroceryStore(groceryStore)
    .then(response => {
      flashMessage('info', 'GroceryStore created successfully')
      setLoading(false)
      onClose(true);
    })
    .catch(error => {
      setLoading(false)
      if(error.status == 401) 
      {
        flashMessage('error', error.message);
        if(error.details) {
          setGroceryStoreErrors(_.mapValues(error.details, (messages, key) => {
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
      setGroceryStore(blankGroceryStore)
    }
  }

  React.useEffect(clearForm, [open])

  return (
    <Dialog open={open} disableBackdropClick={true} onClose={handleClose}>
      <form onSubmit={handleCreate}>
        <DialogTitle>Create New GroceryStore</DialogTitle>
        <DialogContent>
            <TextField
              value={groceryStore.name}
              onChange={(e) => setGroceryStore({ ...groceryStore, name:e.target.value })}
              error={Boolean(groceryStoreErrors.name)}
              helperText={groceryStoreErrors.name}
              variant="outlined"
              margin="normal"
              fullWidth
              id="name"
              label="Store Name"
              name="name"
              autoComplete="name"
              margin="dense"
              autoFocus
            />
            <Slider
              className={classes.slider}
              value={groceryStore.food_quantity}
              onChange={(e, val) => setGroceryStore({ ...groceryStore, food_quantity:val })}
              step={1}
              min={0}
              max={10}
              valueLabelDisplay="auto"
              marks={foodQuantityMarks}
            />
            <TextField
              value={groceryStore.address}
              onChange={(e) => setGroceryStore({ ...groceryStore, address:e.target.value })}
              error={Boolean(groceryStoreErrors.address)}
              helperText={groceryStoreErrors.address}
              variant="outlined"
              margin="normal"
              id="address"
              label="Address"
              name="address"
              margin="dense"
              fullWidth
              required
              />
            <Card>
              <CardContent>
                <Grid container>
                  <Grid item xs={6}>
                    <TextField
                      value={groceryStore.city}
                      onChange={(e) => setGroceryStore({ ...groceryStore, city:e.target.value })}
                      error={Boolean(groceryStoreErrors.city)}
                      helperText={groceryStoreErrors.city}
                      margin="normal"
                      id="city"
                      label="City"
                      name="city"
                      fullWidth
                      margin="dense"
                    />
                  </Grid>
                  <Grid item xs={6}>
                    <StateSelect value={groceryStore.state} onChange={(e) => setGroceryStore({ ...groceryStore, state:e.target.value })} error={groceryStoreErrors.state} />
                  </Grid>
                </Grid>
                <Typography variant="h6">OR</Typography>
                <TextField
                  value={groceryStore.zip}
                  onChange={(e) => setGroceryStore({ ...groceryStore, zip:e.target.value })}
                  error={Boolean(groceryStoreErrors.zip)}
                  helperText={groceryStoreErrors.zip}
                  variant="outlined"
                  margin="normal"
                  fullWidth
                  id="zip"
                  label="Zip"
                  name="zip"
                  margin="dense"
                />
              </CardContent>
            </Card>
            <ExpansionPanel>
              <ExpansionPanelSummary>
                <Typography>Coordinates</Typography>
              </ExpansionPanelSummary>
              <ExpansionPanelDetails>
                <Grid container>
                  <Grid item>
                    <TextField
                      value={groceryStore.lat}
                      onChange={(e) => setGroceryStore({ ...groceryStore, lat:e.target.value })}
                      error={Boolean(groceryStoreErrors.lat)}
                      helperText={groceryStoreErrors.lat}
                      variant="outlined"
                      margin="normal"
                      fullWidth
                      id="lat"
                      label="Latitude"
                      name="lat"
                      margin="dense"
                    />
                  </Grid>
                  <Grid item>
                    <TextField
                      value={groceryStore.long}
                      onChange={(e) => setGroceryStore({ ...groceryStore, long:e.target.value })}
                      error={Boolean(groceryStoreErrors.long)}
                      helperText={groceryStoreErrors.long}
                      variant="outlined"
                      margin="normal"
                      fullWidth
                      id="long"
                      label="Longitude"
                      name="long"
                      margin="dense"
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

export default connect(null, mapDispatchToProps)(CreateGroceryStoreDialog)