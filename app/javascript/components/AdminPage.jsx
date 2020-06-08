import React from "react";
import { Container, Typography } from '@material-ui/core'

import FlashNotice from '../containers/FlashNotice'
import AdminBar from "../containers/AdminBar";
import AdminNav from "../components/AdminNav";
import { getUsers } from '../fetch'

export default ({}) => {
  React.useEffect(() => {
    getUsers()
  }, []);

  return (
  <React.Fragment>
    <AdminBar/>
    <AdminNav/>
    <FlashNotice />
  </React.Fragment>
)};