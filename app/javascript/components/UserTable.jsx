import React from 'react';
import moment from 'moment';

import { makeStyles } from '@material-ui/core/styles';
import { Table, TableBody, TableCell, TableContainer, TablePagination, TableSortLabel, 
  TableHead, TableRow, Paper, CircularProgress, IconButton, Tooltip, Toolbar, Typography } from '@material-ui/core';
import EditIcon from '@material-ui/icons/Edit';
import DeleteIcon from '@material-ui/icons/Delete';
import AddIcon from '@material-ui/icons/AddCircle';

import { getUsers } from '../fetch'
import { drawerWidth } from '../common'
import DeleteUserDialog from './DeleteUserDialog';
import UpdateUserDialog from './UpdateUserDialog';
import CreateUserDialog from './CreateUserDialog';

const useStyles = makeStyles({
  iconButton: {
    padding: '6px'
  },
  createUserIcon: {
    color: 'green',
  },
  editIcon: {
    color: 'green',
  },
  deleteIcon: {
    color: 'red',
  },
  pushRight: {
    width: `calc(100% - ${drawerWidth}px)`,
    marginLeft: drawerWidth,
  },
  topBarFlex: {
    flexGrow: 1,
  },
});

export default function SimpleTable() {
  const classes = useStyles();
  let [orderDir, setOrderDir] = React.useState('asc');
  let [order, setOrder] = React.useState('created_at');
  let [users, setUsers] = React.useState(null);
  let [userCount, setUserCount] = React.useState(0);
  let [page, setPage] = React.useState(0);
  let [rowsPerPage, setRowsPerPage] = React.useState(10);
  let [currentDialogOpen, setCurrentDialogOpen] = React.useState(null);
  let [selectedUser, setSelectedUser] = React.useState(null);

  const loadUsers = () => {
    setUsers(null);
    setUserCount(0);
    getUsers(page, rowsPerPage, order, orderDir).then(response => {
      if(response.status == 0) {
        setUsers(response.users)
        setUserCount(response.user_count)
      }
    })
  }

  const handleChangePage = (event, newPage) => {
    setPage(newPage);
  };

  const handleChangeRowsPerPage = (event) => {
    let prevRowsPerPage = rowsPerPage;
    let newRowsPerPage = parseInt(event.target.value, 10);
    setRowsPerPage(newRowsPerPage);
    if(prevRowsPerPage != newRowsPerPage) {
      setPage(Math.floor(prevRowsPerPage/newRowsPerPage*page));
    }
  };

  const handleCloseDialogs = (usersChange) => {
    setCurrentDialogOpen(null);
    setSelectedUser(null);
    if(usersChange) {
      loadUsers()
    }
  }

  const handleOpenDialog = (type, user) => {
    setSelectedUser(user)
    setCurrentDialogOpen(type);
  }

  const flipOrderDir = () => {
    setOrderDir((orderDir === 'asc') ? 'desc' : 'asc');
  }

  const handleClickSort = (key) => {
    if(key === order) {
      flipOrderDir();
    }
    else {
      setOrderDir('asc');
      setOrder(key);
    }
  }


  React.useEffect(loadUsers, [page, rowsPerPage, order, orderDir]);

  const dense = (rowsPerPage == 25);

  return (
    <Paper className={classes.pushRight}>
      <Toolbar>
        <Typography variant="h6" component="div" className={classes.topBarFlex}>
          Users
        </Typography>

        <Tooltip title="Create User">
          <IconButton aria-label="create user" className={classes.createUserIcon} onClick={() => handleOpenDialog('create')}>
            <AddIcon />
          </IconButton>
        </Tooltip>
      </Toolbar>
      <TableContainer>
        <Table aria-label="Users"
            size={dense ? 'small' : 'medium'}>
          <TableHead>
            <TableRow>
              <TableCell>Actions</TableCell>
              <TableCell sortDirection={order === 'username' ? orderDir : false}>
                <TableSortLabel
                  active={order === 'username'}
                  direction={order === 'username' ? orderDir : 'asc'}
                  onClick={() => handleClickSort('username')}
                >
                  Username
                </TableSortLabel>
              </TableCell>
              <TableCell sortDirection={order === 'first_name' ? orderDir : false}>
                <TableSortLabel
                  active={order === 'first_name'}
                  direction={order === 'first_name' ? orderDir : 'asc'}
                  onClick={() => handleClickSort('first_name')}
                >
                  First Name
                </TableSortLabel>
              </TableCell>
              <TableCell sortDirection={order === 'last_name' ? orderDir : false}>
                <TableSortLabel
                  active={order === 'last_name'}
                  direction={order === 'last_name' ? orderDir : 'asc'}
                  onClick={() => handleClickSort('last_name')}
                >
                  Last Name
                </TableSortLabel>
              </TableCell>
              <TableCell sortDirection={order === 'email' ? orderDir : false}>
                <TableSortLabel
                  active={order === 'email'}
                  direction={order === 'email' ? orderDir : 'asc'}
                  onClick={() => handleClickSort('email')}
                >
                  Email
                </TableSortLabel>
              </TableCell>
              <TableCell sortDirection={order === 'updated_at' ? orderDir : false}>
                <TableSortLabel
                  active={order === 'updated_at'}
                  direction={order === 'updated_at' ? orderDir : 'asc'}
                  onClick={() => handleClickSort('updated_at')}
                >
                  Last Updated
                </TableSortLabel>
              </TableCell>
              <TableCell sortDirection={order === 'created_at' ? orderDir : false}>
                <TableSortLabel
                  active={order === 'created_at'}
                  direction={order === 'created_at' ? orderDir : 'asc'}
                  onClick={() => handleClickSort('created_at')}
                >
                  Created Date
                </TableSortLabel>
              </TableCell>
            </TableRow>
          </TableHead>
          <TableBody>
            {users ?
            users.map((user) => (
              <TableRow key={user.id}>
                <TableCell padding={'none'}>
                  <IconButton className={dense ? classes.iconButton : ''} onClick={() => handleOpenDialog('update', user)}><EditIcon className={classes.editIcon} /></IconButton>
                  <IconButton className={dense ? classes.iconButton : ''} onClick={() => handleOpenDialog('delete', user)}>
                    <DeleteIcon className={classes.deleteIcon}/>
                  </IconButton>
                </TableCell>
                <TableCell component="th" scope="row">{user.username}</TableCell>
                <TableCell>{user.first_name}</TableCell>
                <TableCell>{user.last_name}</TableCell>
                <TableCell>{user.email}</TableCell>
                <TableCell>{moment(user.updated_at).fromNow()}</TableCell>
                <TableCell>{moment(user.created_at).calendar()}</TableCell>
              </TableRow>
            )) :
            <TableRow>
              <TableCell><CircularProgress /></TableCell>
              <TableCell><CircularProgress /></TableCell>
              <TableCell><CircularProgress /></TableCell>
              <TableCell><CircularProgress /></TableCell>
              <TableCell><CircularProgress /></TableCell>
              <TableCell><CircularProgress /></TableCell>
              <TableCell><CircularProgress /></TableCell>
            </TableRow>
            }
          </TableBody>
        </Table>
      </TableContainer>
      {users && 
      <TablePagination
        rowsPerPageOptions={[10, 25]}
        component="div"
        count={userCount}
        rowsPerPage={rowsPerPage}
        page={page}
        onChangePage={handleChangePage}
        onChangeRowsPerPage={handleChangeRowsPerPage}
      />}
      <DeleteUserDialog open={currentDialogOpen == 'delete'} onClose={handleCloseDialogs} userId={selectedUser && selectedUser.id} username={selectedUser && selectedUser.username} />
      <UpdateUserDialog open={currentDialogOpen == 'update'} onClose={handleCloseDialogs} userId={selectedUser && selectedUser.id} />
      <CreateUserDialog open={currentDialogOpen == 'create'} onClose={handleCloseDialogs}/>
    </Paper>
  );
}