import { combineReducers } from 'redux'
import user from './user'
import messages from './messages'
import file from './file'
import admin from './admin'

export default combineReducers({
  user,
  messages,
  file,
  admin
})