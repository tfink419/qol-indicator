import React from "react";
import { connect } from "react-redux";
import { useHistory } from 'react-router-dom';
import { Container, Typography, TextField, Button, CircularProgress } from '@material-ui/core'

import FlashNotice from '../containers/FlashNotice'

import { flashMessage } from '../actions/messages'

import { getResetPasswordDetails, postResetPassword } from '../fetch'

const ResetPasswordPage = ({flashMessage}) => {
  let history = useHistory();
  let [password, setPassword] = React.useState('')
  let [username, setUsername] = React.useState('')
  let [passwordConfirmation, setPasswordConfirmation] = React.useState('')
  let [errors, setErrors] = React.useState({});
  let [status, setStatus] = React.useState('loading');
  const urlParams = new URLSearchParams(window.location.search);

  const loadResetPasswordDetails = () => {
      setStatus('loading');
      getResetPasswordDetails(urlParams.get('uuid'))
    .then(response => {
      setStatus('code-found');
      setUsername(response.username);
    })
    .catch(error => {
      if(error.status == 404) 
      {
        flashMessage('error', "Invalid Reset Code");
        setStatus('invalid-code');
      }
    })
  }

  const sendResetPassword = (event) => {
    event.preventDefault();
    setErrors({});
    postResetPassword(urlParams.get('uuid'), password, passwordConfirmation)
    .then(response => {
      setStatus('password-submitted');
    })
    .catch(error => {
      if(error.status == 401) 
      {
        flashMessage('error', error.message);
        if(error.details) {
          setErrors(_.mapValues(error.details, (messages, key) => {
            return messages.map(message => _.startCase(key) + " " +message).join("\n")
          }));
        }
      }
    })
  }

  React.useEffect(loadResetPasswordDetails, []);

  return (
    <Container component="main" maxWidth="xs">
    {status == 'loading' && 
      <React.Fragment>
        <CircularProgress />
        <FlashNotice />
      </React.Fragment>
    }
    {status == 'invalid-code' && 
      <React.Fragment>
        <Typography variant="h4">
          Invalid Reset Code
        </Typography>
        <Typography variant="body1">
          The reset code you have used is invalid or expired. Please go back to the Forgot Password page to send a new email to your account
        </Typography>
        <Button
          component="a"
          href="/forgot-password"
          fullWidth
          variant="contained"
          color="primary"
          onClick={(e) => { e.preventDefault(); history.push('/forgot-password')}}
        >
          Forgot Password
        </Button>
        <FlashNotice />
      </React.Fragment>
    }
    { status == 'code-found' &&
      <React.Fragment>
        <Typography variant="h4">
          Reset Password for User '{username}'
        </Typography>
        <form onSubmit={sendResetPassword}>
          <TextField
            value={password}
            onChange={(e) => setPassword(e.target.value )}
            error={Boolean(errors.password)}
            helperText={errors.password}
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
            onChange={(e) => setPasswordConfirmation(e.target.value )}
            error={Boolean(errors.password_confirmation)}
            helperText={errors.password_confirmation}
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
            Reset Password
          </Button>
        </form>
      </React.Fragment>
    }
    {status == 'password-submitted' && 
        <React.Fragment>
        <Typography>Password has been reset. Please click the button below to go back to the login page</Typography>
        <Button
          component="a"
          href="/login"
          fullWidth
          variant="contained"
          color="primary"
          onClick={(e) => { e.preventDefault(); history.push('/login')}}
        >
          Back To Login
        </Button>
      </React.Fragment>
    }
    <FlashNotice />
    </Container>
  );
}

const mapDispatchToProps = {
  flashMessage
}

export default connect(null, mapDispatchToProps)(ResetPasswordPage)