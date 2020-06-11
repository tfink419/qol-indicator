import React from 'react';
import { FormControl, FormHelperText, Select, MenuItem, InputLabel } from '@material-ui/core';

const stateList = [
  { value: "AK", text: "Alaska" },
  { value: "AL", text: "Alabama" },
  { value: "AR", text: "Arkansas" },
  { value: "AS", text: "American Samoa" },
  { value: "AZ", text: "Arizona" },
  { value: "CA", text: "California" },
  { value: "CO", text: "Colorado" },
  { value: "CT", text: "Connecticut" },
  { value: "DC", text: "District of Columbia" },
  { value: "DE", text: "Delaware" },
  { value: "FL", text: "Florida" },
  { value: "GA", text: "Georgia" },
  { value: "GU", text: "Guam" },
  { value: "HI", text: "Hawaii" },
  { value: "IA", text: "Iowa" },
  { value: "ID", text: "Idaho" },
  { value: "IL", text: "Illinois" },
  { value: "IN", text: "Indiana" },
  { value: "KS", text: "Kansas" },
  { value: "KY", text: "Kentucky" },
  { value: "LA", text: "Louisiana" },
  { value: "MA", text: "Massachusetts" },
  { value: "MD", text: "Maryland" },
  { value: "ME", text: "Maine" },
  { value: "MI", text: "Michigan" },
  { value: "MN", text: "Minnesota" },
  { value: "MO", text: "Missouri" },
  { value: "MS", text: "Mississippi" },
  { value: "MT", text: "Montana" },
  { value: "NC", text: "North Carolina" },
  { value: "ND", text: "North Dakota" },
  { value: "NE", text: "Nebraska" },
  { value: "NH", text: "New Hampshire" },
  { value: "NJ", text: "New Jersey" },
  { value: "NM", text: "New Mexico" },
  { value: "NV", text: "Nevada" },
  { value: "NY", text: "New York" },
  { value: "OH", text: "Ohio" },
  { value: "OK", text: "Oklahoma" },
  { value: "OR", text: "Oregon" },
  { value: "PA", text: "Pennsylvania" },
  { value: "PR", text: "Puerto Rico" },
  { value: "RI", text: "Rhode Island" },
  { value: "SC", text: "South Carolina" },
  { value: "SD", text: "South Dakota" },
  { value: "TN", text: "Tennessee" },
  { value: "TX", text: "Texas" },
  { value: "UT", text: "Utah" },
  { value: "VA", text: "Virginia" },
  { value: "VI", text: "Virgin Islands" },
  { value: "VT", text: "Vermont" },
  { value: "WA", text: "Washington" },
  { value: "WI", text: "Wisconsin" },
  { value: "WV", text: "West Virginia" },
  { value: "WY", text: "Wyoming" }
];

export default function StateSelect({onChange, value, error}) {
  return (
    <FormControl error={Boolean(error)} fullWidth margin="dense">
      <InputLabel htmlFor="state-select" id="state-select-label">State</InputLabel>
      <Select
        value={value}
        onChange={onChange}
        displayEmpty
        autoWidth
        labelId="state-select-label"
        inputProps={{
          id: 'state-select',
        }}
      >
        <MenuItem value=''>&nbsp;</MenuItem>
        {stateList.map(state => (
          <MenuItem value={state.value} key={state.value}>
            {state.text}
          </MenuItem>
        ))}
      </Select>
      {error && <FormHelperText>{error}</FormHelperText>}
    </FormControl>
  )
}