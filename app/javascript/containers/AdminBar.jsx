import React from "react";
import { connect } from 'react-redux'
import { makeStyles } from '@material-ui/core/styles';
import { Typography, Toolbar, AppBar, IconButton, Menu, MenuItem } from '@material-ui/core'
import { useHistory } from "react-router-dom";

import { drawerWidth } from '../common'
import { userLogout, userLogin } from '../actions/user'

import AccountCircle from '@material-ui/icons/AccountCircle';

const useStyles = makeStyles((theme) => ({
  root: {
    flexGrow: 1,
  },
  appBar: {
    width: `calc(100% - ${drawerWidth}px)`,
    marginLeft: drawerWidth,
  }
}));

const AdminBar = ({user, userLogout}) => {
  let history = useHistory();
  const classes = useStyles();
  const [anchorEl, setAnchorEl] = React.useState(null);
  
  const handleMenu = (event) => {
    setAnchorEl(event.currentTarget);
  };

  const handleClose = () => {
    setAnchorEl(null);
  };

  const handleLogout = () => {
    userLogout();
    window.location.href = 'logout';
  }

  return (
  <AppBar position="static" className={classes.appBar}>
    <Toolbar>
      <div className={classes.root}>
        <Typography><strong>myQOLi Admin</strong></Typography>
      </div>
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
          <MenuItem component="a" href="/">Main Site</MenuItem>
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

export default connect(mapStateToProps, mapDispatchToProps)(AdminBar)