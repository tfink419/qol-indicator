const infoWindows = (state = { activeInfoWindow: null }, action) => {
  switch (action.type) {
    case 'INFO_WINDOW_OPENED':
      return {
        ...state,
        activeInfoWindow: {
          infoWindowType:action.infoWindowType
        }
      }
    default:
      return state
  }
}

export default infoWindows