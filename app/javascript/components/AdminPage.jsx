import React from "react";
import { Route, Redirect } from "react-router-dom";
import { makeStyles } from "@material-ui/core";

import { drawerWidth } from '../common'

import FlashNotice from '../containers/FlashNotice'
import AdminBar from "../containers/AdminBar";
import AdminNav from "../containers/AdminNav";
import UserTable from '../containers/UserTable'
import ApiKeyTable from '../containers/ApiKeyTable'
import GroceryStoreTable from "../containers/GroceryStoreTable";
import GroceryStoreUploadForm from "../containers/GroceryStoreUploadForm";
import AdminMapContainer from "../containers/AdminMapContainer";
import BuildHeatmapPage from "../containers/BuildHeatmapPage";

const useStyles = makeStyles({
  pushRight: {
    width: `calc(100% - ${drawerWidth}px)`,
    marginLeft: drawerWidth,
  }
});
export default ({match}) => {
  const classes = useStyles();
  return (
  <React.Fragment>
    <AdminBar/>
    <AdminNav/>
    <div className={classes.pushRight}>
      <Route path={`${match.path}`} exact render={() => (<Redirect to={`${match.path}/users`} />) }/>
      <Route path={`${match.path}/users`} exact component={UserTable}/>
      <Route path={`${match.path}/api-keys`} exact component={ApiKeyTable}/>
      <Route path={`${match.path}/grocery_stores`} exact component={GroceryStoreTable}/>
      <Route path={`${match.path}/grocery_stores/upload`} exact component={GroceryStoreUploadForm}/>
      <Route path={`${match.path}/map`} exact component={AdminMapContainer}/>
      <Route path={`${match.path}/build-heatmap`} exact component={BuildHeatmapPage}/>
    </div>
    <FlashNotice />
  </React.Fragment>
)};