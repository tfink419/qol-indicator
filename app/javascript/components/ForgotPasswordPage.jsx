import React from "react";
import { TextField, Button, Typography, Container, Grid, Link } from '@material-ui/core'
import { useHistory } from "react-router-dom";
import { postForgotPassword } from "../fetch";
import FlashNotice from '../containers/FlashNotice';

export default ({ userLogin, flashMessage }) => {
  let history = useHistory();
  let [email, setEmail] = React.useState('')
  let [sent, setSent] = React.useState(false)
  const sendEmail = (event) => {
    event.preventDefault();
    postForgotPassword(email)
    .then(response => {
      setSent(true);
    })
  }

  return (
    <Container maxWidth={"sm"}>
      {sent ?
        <React.Fragment>
          <Typography>Email has been sent, please check your email for the link to reset your password. If you remember your password now, click the button below to go back to the login page</Typography>
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
      :
        <form onSubmit={sendEmail}>
          <Typography>
            Enter the email of the account for forgotten password.
          </Typography>
          <TextField
            value={email}
            onChange={(e) => setEmail(e.target.value)}
            variant="outlined"
            margin="normal"
            required
            fullWidth
            id="email"
            label="Email"
            name="email"
            autoFocus
          />
          <Button
            type="submit"
            fullWidth
            variant="contained"
            color="primary"
          >
            Send password reset email
          </Button>
          <Grid container>
            <Grid item xs>
            </Grid>
            <Grid item>
              <Link href="/login" onClick={(e) => {e.preventDefault(); history.push('/login')}} variant="body2">
                Remember Password? Login
              </Link>
            </Grid>
          </Grid>
        </form>
      }
      <FlashNotice />
    </Container>
  )
}