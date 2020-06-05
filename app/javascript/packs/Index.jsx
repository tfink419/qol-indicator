import React from 'react'
import ReactDOM from 'react-dom'
import PropTypes from 'prop-types'
import { createStore } from 'redux'
import { Provider } from 'react-redux'
import rootReducer from '../reducers'

import App from "../components/App";
import { saveState, loadState } from '../common'

const persistedState = loadState();
const store = createStore(rootReducer)

store.subscribe(() => {
  saveState({
    user:store.getState().user
  })
})

document.addEventListener('DOMContentLoaded', () => {
  ReactDOM.render(
    <Provider store={store}>
      <App/>
    </Provider>,
    document.body.appendChild(document.getElementById('root')),
  )
})
