import React from "react";
import { BrowserRouter as Router, Route, Switch } from "react-router-dom";
import MapPage from "../components/MapPage";

export default (
  <Router>
    <Switch>
      <Route path="/" exact component={MapPage} />
    </Switch>
  </Router>
);