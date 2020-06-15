import React from "react";
import { BrowserRouter as Router, Switch } from "react-router-dom";
import LoginPage from "../components/LoginPage";
import RegisterPage from "../components/RegisterPage";
import AdminPage from "../components/AdminPage";
import MapPage from "../components/MapPage";
import UserProtectedRoute from "../containers/UserProtectedRoute";
import LoginRoute from "../containers/LoginRoute";
import AdminProtectedRoute from "../containers/AdminProtectedRoute";
import ForgotPasswordPage from "../components/ForgotPasswordPage";
import ResetPasswordPage from "../components/ResetPasswordPage";


export default (
  <Router>
    <Switch>
      <AdminProtectedRoute path="/admin" component={AdminPage} />
      <LoginRoute path="/login" component={LoginPage} />
      <LoginRoute path="/register" component={RegisterPage} />
      <LoginRoute path="/forgot-password" component={ForgotPasswordPage} />
      <LoginRoute path="/reset-password" component={ResetPasswordPage} />
      <UserProtectedRoute path="/" component={MapPage} />
    </Switch>
  </Router>
);