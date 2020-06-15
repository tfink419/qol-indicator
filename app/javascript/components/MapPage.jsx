import React from "react";
import { Container, Typography } from '@material-ui/core'
import { Route, useHistory } from "react-router-dom";

import FlashNotice from '../containers/FlashNotice'
import TopBar from "../containers/TopBar";
import MapContainer from "../containers/MapContainer"
import UpdateUserSelfDialog from "./UpdateUserSelfDialog";

export default ({match}) => {
  let history = useHistory();
  const handleCloseDialog = () => {
    history.push(match.path)
  }
  return (
  <Container maxWidth="lg">
    <TopBar />
    <MapContainer />
    <FlashNotice />
    <Route path={`${match.path}user`} exact component={() => (<UpdateUserSelfDialog onClose={handleCloseDialog}/> )}/>
  </Container>
)};