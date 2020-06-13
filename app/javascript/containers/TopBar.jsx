import React from "react";
import { connect } from 'react-redux'
import { makeStyles } from '@material-ui/core/styles';
import { Typography, Toolbar, AppBar, IconButton, Menu, MenuItem, CssBaseline, Hidden } from '@material-ui/core'
import { useHistory } from "react-router-dom";

import { userLogout } from '../actions/user'

import AccountCircle from '@material-ui/icons/AccountCircle';

const useStyles = makeStyles((theme) => ({
  root: {
    flexGrow: 1,
  },
  flexGrowABit: {
    flexGrow: 0.05,
  },
}));

const TopBar = ({user, userLogout}) => {
  let history = useHistory();
  const classes = useStyles();
  const [anchorEl, setAnchorEl] = React.useState(null);
  
  const handleMenu = (event) => {
    setAnchorEl(event.currentTarget);
  };

  const handleClose = () => {
    setAnchorEl(null);
  };

  const handleLogout = (event) => {
    event.preventDefault();
    userLogout();
    window.location.href = 'logout';
  }

  return (
  <AppBar position="static">
    <CssBaseline />
    <Toolbar>
      <Typography className={classes.root}>Welcome <strong>{user.first_name + ' ' + user.last_name}</strong></Typography>
      <Hidden mdUp><Typography className={classes.root} variant="h6">myQOLi</Typography></Hidden>
      <Hidden smDown><Typography className={classes.flexGrowABit} variant="h6">myQOLi</Typography></Hidden>
      <Hidden smDown><Typography className={classes.root} variant="subtitle1">My Quality of Life Index</Typography></Hidden>
      <div>
        <IconButton aria-label="account of current user" aria-controls="menu-appbar" aria-haspopup="true" onClick={handleMenu} color="inherit">
          <AccountCircle />
        </IconButton>
        <Menu id="menu-appbar" anchorEl={anchorEl}
          anchorOrigin={{
            vertical: 'top',
            horizontal: 'right',
          }}
          keepMounted
          transformOrigin={{
            vertical: 'top',
            horizontal: 'right',
          }}
          open={Boolean(anchorEl)} onClose={handleClose}
        >
          <MenuItem component="a" href="/user" onClick={(e) => { e.preventDefault(); history.push('/user')}}>Profile</MenuItem>
          <MenuItem onClick={handleClose}>My Settings</MenuItem>
          { user.is_admin &&
            <MenuItem component="a" href="/admin" onClick={(e) => { e.preventDefault(); history.push('/admin')}}>Admin Area</MenuItem>
          }
          <MenuItem component="a" href="/logout" onClick={handleLogout}>Logout</MenuItem>
        </Menu>
      </div>
    </Toolbar>
  </AppBar>
)};

const mapStateToProps = state => ({
  user: state.user
})

const mapDispatchToProps = {
  userLogout
}

export default connect(mapStateToProps, mapDispatchToProps)(TopBar)