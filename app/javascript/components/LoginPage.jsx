import React from "react";
import { TextField, Checkbox, FormControlLabel, Button, Grid, Link, Container, Typography } from '@material-ui/core'
import { Link as RouterLink } from "react-router-dom";

import FlashNotice from './FlashNotice'

const preventDefault = (event) => event.preventDefault();

export default () => (
  <Container component="main" maxWidth="xs">
    <Typography variant="h3">
      myQOLi Login
    </Typography>
    <form action="/login" method="post">
      { AUTH_TOKEN &&
        <input type="hidden" name="authenticity_token" value={AUTH_TOKEN}/>
      }
      <TextField
        variant="outlined"
        margin="normal"
        required
        fullWidth
        id="username"
        label="Username"
        name="username"
        autoComplete="username"
        autoFocus
      />
      <TextField
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
          <Link href="#" onClick={preventDefault} variant="body2">
            Forgot password?
          </Link>
        </Grid>
        <Grid item>
          <Link href="/register" variant="body2">
            Don't have an account? Sign Up
          </Link>
        </Grid>
      </Grid>
    </form>
    <FlashNotice />
  </Container>
);