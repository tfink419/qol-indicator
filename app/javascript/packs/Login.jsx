import React from 'react'
import ReactDOM from 'react-dom'
import PropTypes from 'prop-types'

import LoginApp from "../components/LoginApp";

document.addEventListener('DOMContentLoaded', () => {
  ReactDOM.render(<LoginApp/>,
    document.body.appendChild(document.getElementById('root')),
  )
})
