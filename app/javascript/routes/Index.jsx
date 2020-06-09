import React from "react";
import { BrowserRouter as Router, Route, Switch } from "react-router-dom";
import LoginPage from "../components/LoginPage";
import RegisterPage from "../components/RegisterPage";
import AdminPage from "../components/AdminPage";
import MapPage from "../components/MapPage";
import UserProtectedRoute from "../containers/UserProtectedRoute";
import LoginRoute from "../containers/LoginRoute";
import AdminProtectedRoute from "../containers/AdminProtectedRoute";


export default (
  <Router>
    <Switch>
      <UserProtectedRoute path="/" exact component={MapPage} />
      <AdminProtectedRoute path="/admin" component={AdminPage} />
      <LoginRoute path="/login" component={LoginPage} />
      <LoginRoute path="/register" component={RegisterPage} />
    </Switch>
  </Router>
);