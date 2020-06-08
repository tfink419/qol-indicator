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
