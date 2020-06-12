import React from 'react';
import { makeStyles } from '@material-ui/core/styles';
import { Drawer, CssBaseline, List, Divider, Collapse,
  ListItem, ListItemIcon, ListItemText } from '@material-ui/core';
import PeopleIcon from '@material-ui/icons/People';
import NoteAddIcon from '@material-ui/icons/NoteAdd';
import MapIcon from '@material-ui/icons/Map';
import GroceryStoreIcon from '@material-ui/icons/LocalGroceryStore';
import { useLocation, useHistory } from 'react-router-dom'

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
  nested: {
    paddingLeft: theme.spacing(4),
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
  }
}));

export default () => {
  const currentPath = useLocation().pathname;
  const classes = useStyles();
  let history = useHistory();

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
          <ListItem onClick={() => history.push('/admin/users')} selected={currentPath === '/admin/users'} button>
            <ListItemIcon><PeopleIcon /></ListItemIcon>
            <ListItemText primary={'Users'} />
          </ListItem>

          <ListItem onClick={() => history.push('/admin/grocery_stores')} selected={currentPath === '/admin/grocery_stores'} button>
            <ListItemIcon><GroceryStoreIcon /></ListItemIcon>
            <ListItemText primary={'Grocery Stores'} />
          </ListItem>
          <Collapse in={currentPath === '/admin/grocery_stores/upload'} timeout="auto" unmountOnExit>
            <List component="div" disablePadding>
              <ListItem className={classes.nested} selected={currentPath === '/admin/grocery_stores/upload'} button>
                <ListItemIcon>
                  <NoteAddIcon /> 
                </ListItemIcon>
                <ListItemText primary="Upload CSV" />
              </ListItem>
            </List>
          </Collapse>
          <ListItem onClick={() => history.push('/admin/map')} selected={currentPath === '/admin/map'} button>
            <ListItemIcon><MapIcon /></ListItemIcon>
            <ListItemText primary={'Administrate Map'} />
          </ListItem>
        </List>
      </Drawer>
    </div>
  );
}