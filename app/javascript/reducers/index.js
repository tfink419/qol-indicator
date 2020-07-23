import { combineReducers } from 'redux'
import user from './user'
import messages from './messages'
import admin from './admin'
import infoWindows from './info-windows'
import mapPreferences from './map-preferences'

export default combineReducers({
  user,
  messages,
  admin,
  infoWindows,
  mapPreferences
})