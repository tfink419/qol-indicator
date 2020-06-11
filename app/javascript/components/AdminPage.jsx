import React from "react";
import { Route, Redirect } from "react-router-dom";

import FlashNotice from '../containers/FlashNotice'
import AdminBar from "../containers/AdminBar";
import AdminNav from "../components/AdminNav";

import UserTable from './UserTable'
import GroceryStoreTable from "./GroceryStoreTable";
import GroceryStoreUploadForm from "../containers/GroceryStoreUploadForm";

export default ({match}) => {
  return (
  <React.Fragment>
    <AdminBar/>
    <AdminNav/>
    <Route path={`${match.path}`} exact render={() => (<Redirect to={`${match.path}/users`} />) }/>
    <Route path={`${match.path}/users`} exact component={UserTable}/>
    <Route path={`${match.path}/grocery_stores`} exact component={GroceryStoreTable}/>
    <Route path={`${match.path}/grocery_stores/upload`} exact component={GroceryStoreUploadForm}/>
    <FlashNotice />
  </React.Fragment>
)};