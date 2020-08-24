export const loadState = () => {
  try {
    const serializedState = localStorage.getItem('redux-state');
    if(serializedState == null) {
      return undefined;
    }
    return JSON.parse(serializedState)
  }
  catch {
    return undefined;
  }
}

export const saveState = (state) => {
  const serializedState = JSON.stringify(state);
  localStorage.setItem('redux-state', serializedState)
}

export const drawerWidth = 240;

export const foodQuantityMarks = [
  {
    value: 1,
    label: 'Some Goods     '.replace(/ /g, "\u00a0"),
  },
  {
    value: 3,
    label: 'Convenience Store',
  },
  {
    value: 6,
    label: 'Food market',
  },
  {
    value: 10,
    label: 'Supermarket',
  },
];  

export const defaultPreferences = {
  grocery_store_transit_type:2,
  grocery_store_tags:2,
  census_tract_poverty_low:5,
  census_tract_poverty_high:40,
  grocery_store_ratio:50,
  census_tract_poverty_ratio:50,
  park_transit_type:2,
  park_ratio:50
};

let infoWindowId = 0;
export const incrementInfoWindowId = () => infoWindowId++