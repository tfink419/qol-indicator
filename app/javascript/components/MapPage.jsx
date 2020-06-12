import React from "react";
import { Container, Typography } from '@material-ui/core'

import FlashNotice from '../containers/FlashNotice'
import TopBar from "../containers/TopBar";
import MapContainer from "../containers/MapContainer"

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
    <MapContainer />
    <FlashNotice />
  </Container>
)};