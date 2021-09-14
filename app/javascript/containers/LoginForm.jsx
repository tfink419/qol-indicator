import React from "react";
import { connect } from 'react-redux'
import { TextField, Checkbox, FormControlLabel, Button, Grid, Link } from '@material-ui/core'
import { useHistory } from "react-router-dom";
import { userLogin } from '../actions/user'
import { flashMessage } from '../actions/messages'
import { postLogin } from "../fetch";

const LoginForm = ({ userLogin, flashMessage, onClose }) => {
  let history = useHistory();
  let [username, setUsername] = React.useState('')
  let [password, setPassword] = React.useState('')
  const attemptLogin = (event) => {
    event.preventDefault();
    postLogin(username, password)
    .then(response => {
      userLogin(response.user);
      flashMessage('info', 'You have been logged in.');
      onClose();
      history.push('/');
    })
    .catch(error => {
      if(error.status == 401) 
      {
        flashMessage('error', error.message);
      }
    })
  }
  return (
    <form onSubmit={attemptLogin}>
      <TextField
        value={username}
        onChange={(e) => setUsername(e.target.value)}
        variant="outlined"
        margin="normal"
        required
        fullWidth
        id="username"
        label="Username"
        name="username"
        autoFocus
      />
      <TextField
        value={password}
        onChange={(e) => setPassword(e.target.value)}
        variant="outlined"
        margin="normal"
        required
        fullWidth
        name="password"
        label="Password"
        type="password"
        id="password"
        autoComplete="current-password"
      />
      <FormControlLabel
        control={<Checkbox value="remember" color="primary" />}
        label="Remember me"
      />
      <Button
        type="submit"
        fullWidth
        variant="contained"
        color="primary"
      >
        Sign In
      </Button>
      <Grid container>
        <Grid item xs>
          <Link href="/forgot-password" onClick={(e) => {e.preventDefault(); onClose(); history.push('/forgot-password')}} variant="body2">
            Forgot password?
          </Link>
        </Grid>
        <Grid item>
          <Link href="/register" onClick={(e) => {e.preventDefault(); onClose(); history.push('/register')}} variant="body2">
            Don't have an account? Sign Up
          </Link>
        </Grid>
      </Grid>
    </form>
  )
}

const mapDispatchToProps = {
  userLogin,
  flashMessage
}

export default connect(null, mapDispatchToProps)(LoginForm)