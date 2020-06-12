import React from "react";
import { Container, Typography } from '@material-ui/core'

import FlashNotice from '../containers/FlashNotice'
import TopBar from "../containers/TopBar";
import MapContainer from "../containers/MapContainer"

export default ({}) => {
  return (
  <Container maxWidth="lg">
    <TopBar />
    <MapContainer />
    <FlashNotice />
  </Container>
)};