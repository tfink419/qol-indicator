import React from "react";
import { connect } from 'react-redux'
import { Route, Redirect } from "react-router-dom";

const AdminProtectedRoute = ({ component: Component, user, ...rest }) => {
  return (
    <Route {...rest} render={(props) => (
      (user && user.is_admin)
        ? <Component {...props} />
        : <Redirect to='/' />
    )} />
  );
}

const mapStateToProps = state => ({
  user: state.user
})

export default connect(mapStateToProps)(AdminProtectedRoute);
