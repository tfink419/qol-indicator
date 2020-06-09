import React from "react";
import { Route, Redirect } from "react-router-dom";

import FlashNotice from '../containers/FlashNotice'
import AdminBar from "../containers/AdminBar";
import AdminNav from "../components/AdminNav";

import UserTable from './UserTable'

export default ({}) => {
  return (
  <React.Fragment>
    <AdminBar/>
    <AdminNav/>
    <Route path={'/admin'} exact render={() => (<Redirect to="/admin/users" />) }/>
    <Route path={'/admin/users'} component={UserTable}/>
    <FlashNotice />
  </React.Fragment>
)};