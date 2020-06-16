import React from "react";
import { Container, Typography } from '@material-ui/core'
import { Route, useHistory, Switch } from "react-router-dom";

import FlashNotice from '../containers/FlashNotice'
import TopBar from "../containers/TopBar";
import MapContainer from "../containers/MapContainer"
import UpdateUserSelfDialog from "./UpdateUserSelfDialog";
import UpdateMapPreferencesDialog from "./UpdateMapPreferencesDialog";

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
    <Switch>
      <Route path={`/user`} exact component={() => (<UpdateUserSelfDialog onClose={handleCloseDialog}/> )}/>
      <Route path={`/map/preferences`} exact component={() => (<UpdateMapPreferencesDialog onClose={handleCloseDialog}/> )}/>
    </Switch>
  </Container>
)};