import React from "react";
import { connect } from 'react-redux'
import { makeStyles } from '@material-ui/core/styles';
import { Container, Typography, Toolbar, AppBar, IconButton, Menu, MenuItem } from '@material-ui/core'
import { useHistory } from "react-router-dom";

import AccountCircle from '@material-ui/icons/AccountCircle';

import FlashNotice from '../containers/FlashNotice'

const useStyles = makeStyles((theme) => ({
  root: {
    flexGrow: 1,
  },
}));

const MapPage = ({user}) => {
  let history = useHistory();
  const classes = useStyles();
  const [anchorEl, setAnchorEl] = React.useState(null);
  
  const handleMenu = (event) => {
    setAnchorEl(event.currentTarget);
  };

  const handleClose = () => {
    setAnchorEl(null);
  };
  if(!user) window.location.href = '/logout'

  return (
  <Container maxWidth="md">
    <AppBar position="static">
      <Toolbar>
        <div className={classes.root}>
          <Typography>Welcome <strong>{user.username}</strong></Typography>
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
            <MenuItem onClick={handleClose}>Profile</MenuItem>
            <MenuItem onClick={handleClose}>My account</MenuItem>
            { user.is_admin &&
              <MenuItem onClick={() => window.location.href = 'admin'}>Admin Area</MenuItem>
            }
            <MenuItem onClick={() => window.location.href = 'logout'}>Logout</MenuItem>
          </Menu>
        </div>
      </Toolbar>
    </AppBar>
    <Typography variant="h3">
      myQOLi:
    </Typography>
    <Typography variant="h6">
      My Quality of Life Indicator
    </Typography>
    <FlashNotice />
  </Container>
)};

const mapStateToProps = state => ({
  user: state.user
})

export default connect(mapStateToProps,null)(MapPage)