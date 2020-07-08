import React from 'react';
import { getGroceryStore } from 'fetch';
import { CircularProgress } from '@material-ui/core/';

const cityZipPrint = (city, state, zip) => {
  if(!city && state && zip) {
    return `${state} ${zip}`
  }
  else if(city && state && !zip) {
    return `${city}, ${state}`
  }
  else {
    return `${city}, ${state} ${zip}`
  }
}

export default ({groceryStoreId, open}) => {
  let [groceryStore, setGroceryStore] = React.useState(null);

  const loadGroceryStore = () => {
    if(open) {
      getGroceryStore(groceryStoreId)
      .then(response => {
        setGroceryStore(response.grocery_store);
      });
    }
  }

  React.useEffect(loadGroceryStore, [open])

  return (
      groceryStore ?
      <React.Fragment>
        {groceryStore.name} <br/>
        {groceryStore.address} <br/>
        {cityZipPrint(groceryStore.city, groceryStore.state, groceryStore.zip)}
        <br />
      </React.Fragment>
      :
      <CircularProgress/>
    )
}