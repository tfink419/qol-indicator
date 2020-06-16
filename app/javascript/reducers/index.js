import { combineReducers } from 'redux'
import user from './user'
import messages from './messages'
import file from './file'
import admin from './admin'
import mapPreferences from './map-preferences'

export default combineReducers({
  user,
  messages,
  file,
  admin,
  mapPreferences
})