import React from "react";
import _ from 'lodash';
import { connect } from 'react-redux'

import { infoWindowOpen, infoWindowLoaded } from '../actions/info-windows'
import { Container, Paper, TextField, makeStyles } from "@material-ui/core";

import { getMapDataPoint } from '../fetch'
import { incrementInfoWindowId } from '../common'

const useStyles = makeStyles({
  textField: {
    backgroundColor:"white"
  }
});

const MapSearchBox = ({ map, infoWindowOpen, mapPreferences, infoWindowLoaded }) => {
  const classes = useStyles();
  let [searchText, setSearchText] = React.useState("");
  const inputRef = React.useRef(null);
  const mapPreferencesRef = React.useRef(mapPreferences);
  const fullElementRef = React.useRef(null);
  
  React.useEffect(() => {
    if(map) {
      const searchBox = new google.maps.places.SearchBox(inputRef.current);
      map.controls[google.maps.ControlPosition.TOP_LEFT].push(fullElementRef.current);
      // Bias the SearchBox results towards current map's viewport.
      map.addListener("bounds_changed", () => {
        searchBox.setBounds(map.getBounds());
      });
      // Listen for the event fired when the user selects a prediction and retrieve
      // more details for that place.
      searchBox.addListener("places_changed", () => {
        const places = searchBox.getPlaces();

        if (places.length == 0) {
          return;
        }
        const place = places[0];
        // Clear out the old markers.

        console.log(place);

        // For each place, get the icon, name and location.
        const bounds = new google.maps.LatLngBounds();
        if (!place.geometry) {
          console.log("Returned place contains no geometry");
          return;
        }

        let id = incrementInfoWindowId();
        infoWindowOpen('point-data', id, place.geometry.location);
        getMapDataPoint(place.geometry.location.lat(), place.geometry.location.lng(), mapPreferencesRef.current.preferences)
        .then(response => infoWindowLoaded(id, {...response, placeName:place.name}));

        if (place.geometry.viewport) {
          // Only geocodes have viewport.
          bounds.union(place.geometry.viewport);
        } else {
          bounds.extend(place.geometry.location);
        }
        map.fitBounds(bounds);
      });
    }
  }, [map]);

  React.useEffect(() => {
    mapPreferencesRef.current = mapPreferences;
  }, [mapPreferences]);

  return (
    <Container
      ref={fullElementRef}
      maxWidth='xs'
    >
      <Paper
        elevation={0}
      >
        <TextField
          classes={{root:classes.textField}}
          value={searchText}
          onChange={(e) => setSearchText(e.target.value)}
          variant="outlined"
          margin="normal"
          id="map_search"
          label="Search For Location"
          name="find_place"
          fullWidth
          inputRef={inputRef}
        />
      </Paper>
    </Container>
  );
}

const mapStateToProps = state => ({
  infoWindows: state.infoWindows,
  mapPreferences: state.mapPreferences
})

const mapDispatchToProps = {
  infoWindowOpen,
  infoWindowLoaded
}

export default connect(mapStateToProps, mapDispatchToProps)(MapSearchBox)