import React from 'react';
import { makeStyles } from '@material-ui/core/styles';
import { Drawer, CssBaseline, List, Divider, 
  ListItem, ListItemIcon, ListItemText } from '@material-ui/core';
import PeopleIcon from '@material-ui/icons/People';
import GroceryStoreIcon from '@material-ui/icons/LocalGroceryStore';
import { useLocation } from 'react-router-dom'

import { drawerWidth } from '../common'

const useStyles = makeStyles((theme) => ({
  root: {
    display: 'flex',
  },
  appBar: {
    width: `calc(100% - ${drawerWidth}px)`,
    marginLeft: drawerWidth,
  },
  drawer: {
    width: drawerWidth,
    flexShrink: 0,
  },
  drawerPaper: {
    width: drawerWidth,
  },
  // necessary for content to be below app bar
  toolbar: theme.mixins.toolbar,
  content: {
    flexGrow: 1,
    backgroundColor: theme.palette.background.default,
    padding: theme.spacing(3),
  },
}));

export default () => {
  const currentPath = useLocation().pathname;
  const classes = useStyles();

  return (
    <div className={classes.root}>
      <CssBaseline />
      <Drawer className={classes.drawer} variant="permanent" anchor="left"
        classes={{
          paper: classes.drawerPaper,
        }}
      >
        <div className={classes.toolbar} />
        <Divider />
        <List>
          <ListItem selected={currentPath === '/admin/users'} button>
            <ListItemIcon><PeopleIcon /></ListItemIcon>
            <ListItemText primary={'Users'} />
          </ListItem>

          <ListItem selected={currentPath === '/admin/grocery_stores'} button>
            <ListItemIcon><GroceryStoreIcon /></ListItemIcon>
            <ListItemText primary={'Grocery Stores'} />
          </ListItem>
        </List>
      </Drawer>
    </div>
  );
}