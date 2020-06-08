import React from "react";
import { Container, Typography } from '@material-ui/core'

import FlashNotice from '../containers/FlashNotice'
import TopBar from "../containers/TopBar";
import { getUsers } from "../fetch";

export default ({}) => {
  return (
  <Container maxWidth="md">
    <TopBar />
    <Typography variant="h3">
      myQOLi:
    </Typography>
    <Typography variant="h6">
      My Quality of Life Indicator
    </Typography>
    <FlashNotice />
  </Container>
)};