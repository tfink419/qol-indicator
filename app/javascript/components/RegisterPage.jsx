import React from "react";
import { Container, Typography } from '@material-ui/core'

import FlashNotice from '../containers/FlashNotice'
import RegisterForm from "../containers/RegisterForm";

const preventDefault = (event) => event.preventDefault();

export default () => (
  <Container component="main" maxWidth="xs">
    <Typography variant="h4">
      myQOLi Register User
    </Typography>
    <RegisterForm />
    <FlashNotice />
  </Container>
);