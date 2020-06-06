import React from "react";
import { connect } from 'react-redux'
import { TextField, Checkbox, FormControlLabel, Button, Grid, Link } from '@material-ui/core'
import { useHistory } from "react-router-dom";
import { userLogin } from '../actions/user'
import { flashMessage } from '../actions/messages'
import { postRegister } from "../fetch";

const preventDefault = (event) => event.preventDefault();

const RegisterForm = ({ userLogin, flashMessage }) => {
  let history = useHistory();
  let [firstName, setFirstName] = React.useState([''])
  let [firstNameError, setFirstNameError] = React.useState(null)
  let [lastName, setLastName] = React.useState('')
  let [lastNameError, setLastNameError] = React.useState(null)
  let [email, setEmail] = React.useState('')
  let [emailError, setEmailError] = React.useState(null)
  let [username, setUsername] = React.useState('')
  let [usernameError, setUsernameError] = React.useState(null)
  let [password, setPassword] = React.useState('')
  let [passwordError, setPasswordError] = React.useState(null)
  let [passwordConfirmation, setPasswordConfirmation] = React.useState('')
  let [passwordConfirmationError, setPasswordConfirmationError] = React.useState(null)

  const attemptRegister = (event) => {
    event.preventDefault();
    postRegister(firstName, lastName, email, username, password, passwordConfirmation)
    .then(response => {
      userLogin(response.user);
      flashMessage('info', 'Your account was successfully registered and you have logged in.');
      history.push('/')
      
    })
    .catch(error => {
      flashMessage('error', error.message);
      //{:password_confirmation=>["doesn't match Password"], 
      // :first_name=>["can't be blank"], :last_name=>["can't be blank"], 
      // :email=>["is invalid"]} 
      if(error.details) {
        if(error.details['first_name']) {
          setFirstNameError(error.details['first_name'].map(message => 'First Name '+message).join("\n"))
        }
        else {
          setFirstNameError(null)
        }
        if(error.details['last_name']) {
          setLastNameError(error.details['last_name'].map(message => 'Last Name '+message).join("\n"))
        }
        else {
          setLastNameError(null)
        }
        if(error.details['username']) {
          setUsernameError(error.details['username'].map(message => 'Username '+message).join("\n"))
        }
        else {
          setUsernameError(null)
        }
        if(error.details['email']) {
          setEmailError(error.details['email'].map(message => 'Email '+message).join("\n"))
        }
        else {
          setEmailError(null)
        }
        if(error.details['password']) {
          setPasswordError(error.details['password'].map(message => 'Password '+message).join("\n"))
        }
        else {
          setPasswordError(null)
        }
        if(error.details['password_confirmation']) {
          setPasswordConfirmationError(error.details['password_confirmation'].map(message => 'Password Confirmation '+message).join("\n"))
        }
        else {
          setPasswordConfirmationError(null)
        }
      }
    })
  }

  return (
    <form onSubmit={attemptRegister}>
      <TextField
        value={firstName}
        onChange={(e) => setFirstName(e.target.value)}
        error={Boolean(firstNameError)}
        helperText={firstNameError}
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
        value={lastName}
        onChange={(e) => setLastName(e.target.value)}
        error={Boolean(lastNameError)}
        helperText={lastNameError}
        variant="outlined"
        margin="normal"
        fullWidth
        id="last_name"
        label="Last Name"
        name="last_name"
      />
      <TextField
        value={username}
        onChange={(e) => setUsername(e.target.value)}
        error={Boolean(usernameError)}
        helperText={usernameError}
        variant="outlined"
        margin="normal"
        required
        fullWidth
        id="username"
        label="Username"
        name="username"
      />
      <TextField
        value={email}
        onChange={(e) => setEmail(e.target.value)}
        error={Boolean(emailError)}
        helperText={emailError}
        variant="outlined"
        margin="normal"
        required
        fullWidth
        id="email"
        label="Email"
        name="email"
      />
      <TextField
        value={password}
        onChange={(e) => setPassword(e.target.value)}
        error={Boolean(passwordError)}
        helperText={passwordError}
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
        value={passwordConfirmation}
        onChange={(e) => setPasswordConfirmation(e.target.value)}
        error={Boolean(passwordConfirmationError)}
        helperText={passwordConfirmationError}
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