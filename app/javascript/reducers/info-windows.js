const infoWindows = (state = { activeInfoWindow: null }, action) => {
  switch (action.type) {
    case 'INFO_WINDOW_OPEN':
      return {
        ...state,
        activeInfoWindow: {
          id: action.id,
          type: action.infoWindowType,
          position: action.position,
          marker: action.marker
        }
      }
    case 'INFO_WINDOW_LOADED':
      if(action.id == state.activeInfoWindow.id) {
        return {
          ...state,
          activeInfoWindow: {
            ...state.activeInfoWindow,
            data: action.data
          }
        }
      }
      return state;
    default:
      return state
  }
}

export default infoWindows