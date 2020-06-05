import React from "react";
import { makeStyles } from '@material-ui/core/styles';
import { Container, Typography, Toolbar, AppBar, IconButton, Menu, MenuItem } from '@material-ui/core'

import AccountCircle from '@material-ui/icons/AccountCircle';

import FlashNotice from './FlashNotice'

const useStyles = makeStyles((theme) => ({
  root: {
    flexGrow: 1,
  },
}));

export default () => {
  const classes = useStyles();
  const [anchorEl, setAnchorEl] = React.useState(null);
  
  const handleMenu = (event) => {
    setAnchorEl(event.currentTarget);
  };

  const handleClose = () => {
    setAnchorEl(null);
  };

  return (
  <Container maxWidth="md">
    <AppBar position="static">
      <Toolbar>
        <div className={classes.root}>
          <Typography>Welcome <strong>{window.USER_USERNAME}</strong></Typography>
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