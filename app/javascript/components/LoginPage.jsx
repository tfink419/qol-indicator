import React from "react";
import { Container, Typography } from '@material-ui/core'

import FlashNotice from '../containers/FlashNotice'
import LoginForm from "../containers/LoginForm";


export default () => (
  <Container component="main" maxWidth="xs">
    <Typography variant="h3">
      myQOLi Login
    </Typography>
    <LoginForm />
    <FlashNotice />
  </Container>
);