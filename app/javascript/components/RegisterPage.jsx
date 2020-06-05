import React from "react";
import { TextField, Checkbox, FormControlLabel, Button, Grid, Link, Container, Typography } from '@material-ui/core'

import FlashNotice from './FlashNotice'

const preventDefault = (event) => event.preventDefault();

export default () => (
  <Container component="main" maxWidth="xs">
    <Typography variant="h4">
      myQOLi Register User
    </Typography>
    <form action="/register" method="post">
      { AUTH_TOKEN &&
        <input type="hidden" name="authenticity_token" value={AUTH_TOKEN}/>
      }
      <TextField
        variant="outlined"
        margin="normal"
        fullWidth
        id="user_first_name"
        label="First Name"
        name="user[first_name]"
        autoComplete="first_name"
        autoFocus
      />
      <TextField
        variant="outlined"
        margin="normal"
        fullWidth
        id="last_name"
        label="Last Name"
        name="user[last_name]"
        autoComplete="last_name"
        autoFocus
      />
      <TextField
        variant="outlined"
        margin="normal"
        required
        fullWidth
        id="user_username"
        label="Username"
        name="user[username]"
        autoComplete="username"
        autoFocus
      />
      <TextField
        variant="outlined"
        margin="normal"
        required
        fullWidth
        id="email"
        label="Email"
        name="user[email]"
        autoComplete="email"
        autoFocus
      />
      <TextField
        variant="outlined"
        margin="normal"
        required
        fullWidth
        name="user[password]"
        label="Password"
        type="password"
        id="user_password"
      />
      <TextField
        variant="outlined"
        margin="normal"
        required
        fullWidth
        name="user[password_confirmation]"
        label="Confirm Password"
        type="password"
        id="user_password_confirmation"
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
    <FlashNotice />
  </Container>
);