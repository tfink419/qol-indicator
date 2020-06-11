import { combineReducers } from 'redux'
import user from './user'
import messages from './messages'
import file from './file'

export default combineReducers({
  user,
  messages,
  file
})