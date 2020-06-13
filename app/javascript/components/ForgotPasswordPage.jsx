import React from "react";
import { TextField, Button, Typography, Container } from '@material-ui/core'
import { useHistory } from "react-router-dom";
import { postForgotPassword } from "../fetch";

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
        <div>
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
        </div>
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
        </form>}
    </Container>
  )
}