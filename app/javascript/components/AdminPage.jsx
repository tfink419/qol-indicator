import React from "react";
import { Route, Redirect } from "react-router-dom";

import FlashNotice from '../containers/FlashNotice'
import AdminBar from "../containers/AdminBar";
import AdminNav from "../components/AdminNav";

import UserTable from '../containers/UserTable'
import GroceryStoreTable from "../containers/GroceryStoreTable";
import GroceryStoreUploadForm from "../containers/GroceryStoreUploadForm";
import AdminMapContainer from "../containers/AdminMapContainer";

export default ({match}) => {
  return (
  <React.Fragment>
    <AdminBar/>
    <AdminNav/>
    <Route path={`${match.path}`} exact render={() => (<Redirect to={`${match.path}/users`} />) }/>
    <Route path={`${match.path}/users`} exact component={UserTable}/>
    <Route path={`${match.path}/grocery_stores`} exact component={GroceryStoreTable}/>
    <Route path={`${match.path}/grocery_stores/upload`} exact component={GroceryStoreUploadForm}/>
    <Route path={`${match.path}/map`} exact component={AdminMapContainer}/>
    <FlashNotice />
  </React.Fragment>
)};