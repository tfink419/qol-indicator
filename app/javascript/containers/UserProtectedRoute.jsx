import React from "react";
import { connect } from 'react-redux'
import { Route, Redirect } from "react-router-dom";

const UserProtectedRoute = ({ component: Component, user, ...rest }) => {
  return (
    <Route {...rest} render={(props) => (
      user
        ? <Component {...props} />
        : <Redirect to='/logout' />
    )} />
  );
}

const mapStateToProps = state => ({
  user: state.user
})

export default connect(mapStateToProps)(UserProtectedRoute);
