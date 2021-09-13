import { defaultPreferences } from '../common'

const mapPreferences = (state = { preferences:defaultPreferences, loaded:false}, action) => {
  switch (action.type) {
    case 'UPDATE_MAP_PREFERENCES':
      return {
        preferences:action.mapPreferences,
        original:action.mapPreferences,
        loaded:true
      }
    case 'TEMP_UPDATE_MAP_PREFERENCES':
      return {
        ...state,
        preferences:action.mapPreferences
      }
    case 'RESET_MAP_PREFERENCES':
      return {
        ...state,
        preferences:state.original
      }
    case 'SET_DEFAULT_MAP_PREFERENCES':
      return {
        ...state,
        preferences:defaultPreferences,
        original:defaultPreferences
      }
    case 'USER_LOGOUT':
      return {
        preferences:defaultPreferences,
        loaded:false
      }
    default:
      return state
  }
}

export default mapPreferences