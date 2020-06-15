import React from "react";
import { connect } from 'react-redux'
import { useHistory } from "react-router-dom";
import _ from 'lodash';
import { TextField, Checkbox, FormControlLabel, Button, Grid, Link } from '@material-ui/core'

import { userLogin } from '../actions/user'
import { flashMessage } from '../actions/messages'
import { postRegister } from "../fetch";

const preventDefault = (event) => event.preventDefault();

const RegisterForm = ({ userLogin, flashMessage }) => {
  let history = useHistory();
  let [user, setUser] = React.useState({
    password: '',
    password_confirmation: ''
  });
  let [userErrors, setUserErrors] = React.useState({});

  const attemptRegister = (event) => {
    setUserErrors({});
    event.preventDefault();
    postRegister(user)
    .then(response => {
      userLogin(response.user);
      flashMessage('info', 'Your account was successfully registered and you have logged in.');
      history.push('/')
    })
    .catch(error => {
      if(error.status == 401) 
      {
        flashMessage('error', error.message);
        if(error.details) {
          setUserErrors(_.mapValues(error.details, (messages, key) => {
            return messages.map(message => _.startCase(key) + " " +message).join("\n")
          }));
        }
      }
    })
  }

  return (
    <form onSubmit={attemptRegister}>
      <TextField
        value={user.first_name}
        onChange={(e) => setUser({ ...user, first_name:e.target.value })}
        error={Boolean(userErrors.first_name)}
        helperText={userErrors.first_name}
        variant="outlined"
        margin="normal"
        fullWidth
        id="first_name"
        label="First Name"
        name="first_name"
        autoComplete="first_name"
        autoFocus
      />
      <TextField
        value={user.last_name}
        onChange={(e) => setUser({ ...user, last_name:e.target.value })}
        error={Boolean(userErrors.lastName)}
        helperText={userErrors.last_name}
        variant="outlined"
        margin="normal"
        fullWidth
        id="last_name"
        label="Last Name"
        name="last_name"
      />
      <TextField
        value={user.username}
        onChange={(e) => setUser({ ...user, username:e.target.value })}
        error={Boolean(userErrors.username)}
        helperText={userErrors.username}
        variant="outlined"
        margin="normal"
        required
        fullWidth
        id="username"
        label="Username"
        name="username"
      />
      <TextField
        value={user.email}
        onChange={(e) => setUser({ ...user, email:e.target.value })}
        error={Boolean(userErrors.email)}
        helperText={userErrors.email}
        variant="outlined"
        margin="normal"
        required
        fullWidth
        id="email"
        label="Email"
        name="email"
      />
      <TextField
        value={user.password}
        onChange={(e) => setUser({ ...user, password:e.target.value })}
        error={Boolean(userErrors.password)}
        helperText={userErrors.password}
        variant="outlined"
        margin="normal"
        required
        fullWidth
        name="password"
        label="Password"
        type="password"
        id="password"
      />
      <TextField
        value={user.password_confirmation}
        onChange={(e) => setUser({ ...user, password_confirmation:e.target.value })}
        error={Boolean(userErrors.password_confirmation)}
        helperText={userErrors.password_confirmation}
        variant="outlined"
        margin="normal"
        required
        fullWidth
        name="password_confirmation"
        label="Confirm Password"
        type="password"
        id="password_confirmation"
      />
      <Button
        type="submit"
        fullWidth
        variant="contained"
        color="primary"
      >
        Register
      </Button>
    </form>
  )
}

const mapDispatchToProps = {
  userLogin,
  flashMessage
}

export default connect(null, mapDispatchToProps)(RegisterForm)