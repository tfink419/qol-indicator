import React from 'react';
import { Typography, TableHead, TableBody, Table, TableRow, TableCell } from '@material-ui/core/';

export default ({results}) => {
  if(!results) return null;
  
  return (
    <React.Fragment>
    <Table aria-label="Coordinate">
      <TableBody>
        <TableRow>
          <TableCell variant="head">Coordinate</TableCell>
          <TableCell>{results.lat},{results.long}</TableCell>
        </TableRow>
      </TableBody>
    </Table>
    <Table aria-label="Quality">
      <TableBody>
        <TableRow>
          <TableCell variant="head">Quality</TableCell>
          <TableCell>{results.quality}%</TableCell>
        </TableRow>
      </TableBody>
    </Table>
      { results.data.grocery_stores && (
        <React.Fragment>
          <Table aria-label="Grocery Stores" size='small'>
            <TableHead>
              <TableRow>
                <TableCell>Store</TableCell>
                <TableCell>Quality</TableCell>
              </TableRow>
            </TableHead>
            <TableBody>
              {
                results.data.grocery_stores.map((groceryStore, ind) => (
                  <TableRow key={ind}>
                    <TableCell>{groceryStore.name} at {groceryStore.address}</TableCell>
                    <TableCell>{groceryStore.quality}/10</TableCell>
                  </TableRow>
                ))
              }
            </TableBody>
          </Table>
        </React.Fragment>
      )}
      { results.data.census_tract && (
        <React.Fragment>
          <Typography variant='h6'>
            Census Tract Data
          </Typography>
          <Table aria-label="Census Tract Data" size='small'>
            <TableBody>
              <TableRow>
                <TableCell variant="head">Land Area (sq mi)</TableCell>
                <TableCell>{results.data.census_tract.land_area}</TableCell>
              </TableRow>
              <TableRow>
                <TableCell variant="head">Percent Poverty</TableCell>
                <TableCell>{results.data.census_tract.poverty_percent}</TableCell>
              </TableRow>
              <TableRow>
                <TableCell variant="head">Population</TableCell>
                <TableCell>{results.data.census_tract.population}</TableCell>
              </TableRow>
              <TableRow>
                <TableCell variant="head">Population Density</TableCell>
                <TableCell>{results.data.census_tract.population_density}</TableCell>
              </TableRow>
            </TableBody>
          </Table>
        </React.Fragment>
      )}
    </React.Fragment>
  )
}