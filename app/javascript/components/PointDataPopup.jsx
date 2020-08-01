import React from 'react';
import { Typography, TableHead, TableBody, Table, TableRow, TableCell, CircularProgress } from '@material-ui/core/';

export default ({data}) => (
  data ?
    <React.Fragment>
      {data.placeName && 
        <Typography variant="h6">{data.placeName}</Typography>
      }
      <Table aria-label="Coordinate">
        <TableBody>
          <TableRow>
            <TableCell variant="head">Coordinate</TableCell>
            <TableCell>{data.lat},{data.long}</TableCell>
          </TableRow>
        </TableBody>
      </Table>
      <Table aria-label="Quality">
        <TableBody>
          <TableRow>
            <TableCell variant="head">Quality</TableCell>
            <TableCell>{data.quality}%</TableCell>
          </TableRow>
        </TableBody>
      </Table>
      { data.data.grocery_stores && (
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
                data.data.grocery_stores.map((groceryStore, ind) => (
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
      { data.data.census_tract && (
        <React.Fragment>
          <Typography variant='h6'>
            Census Tract Data
          </Typography>
          <Table aria-label="Census Tract Data" size='small'>
            <TableBody>
              <TableRow>
                <TableCell variant="head">Land Area (sq mi)</TableCell>
                <TableCell>{data.data.census_tract.land_area}</TableCell>
              </TableRow>
              <TableRow>
                <TableCell variant="head">Percent Poverty</TableCell>
                <TableCell>{data.data.census_tract.poverty_percent}</TableCell>
              </TableRow>
              <TableRow>
                <TableCell variant="head">Population</TableCell>
                <TableCell>{data.data.census_tract.population}</TableCell>
              </TableRow>
              <TableRow>
                <TableCell variant="head">Population Density</TableCell>
                <TableCell>{data.data.census_tract.population_density}</TableCell>
              </TableRow>
            </TableBody>
          </Table>
        </React.Fragment>
      )}
    </React.Fragment>
    :
    <CircularProgress />
)