import React from 'react';
import { makeStyles } from '@material-ui/core/styles';
import { Table, TableBody, TableCell, TableContainer, TablePagination,
  TableHead, TableRow, Paper, CircularProgress, IconButton } from '@material-ui/core';
import EditIcon from '@material-ui/icons/Edit';
import DeleteIcon from '@material-ui/icons/Delete';

import { getUsers } from '../fetch'
import { drawerWidth } from '../common'
import DeleteUserDialog from './DeleteUserDialog';
import UpdateUserDialog from './UpdateUserDialog';

const useStyles = makeStyles({
  iconButton: {
    padding: '6px'
  },
  editIcon: {
    color: 'green',
  },
  deleteIcon: {
    color: 'red',
  },
  table: {
    width: `calc(100% - ${drawerWidth}px)`,
    marginLeft: drawerWidth,
  }
});

export default function SimpleTable() {
  const classes = useStyles();
  const [orderDir, setOrderDir] = React.useState('asc');
  const [order, setOrder] = React.useState('created_date');
  let [users, setUsers] = React.useState(null);
  let [userCount, setUserCount] = React.useState(0);
  let [page, setPage] = React.useState(0);
  let [rowsPerPage, setRowsPerPage] = React.useState(10);
  let [deleteDialogOpen, setDeleteDialogOpen] = React.useState(false);
  let [updateDialogOpen, setUpdateDialogOpen] = React.useState(false);
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

  const handleCloseDeleteDialog = (userDeleted) => {
    setDeleteDialogOpen(false);
    setSelectedUser(null);
    if(userDeleted) {
      loadUsers()
    }
  }

  const handleSelectDeleteUser = (user) => {
    setSelectedUser(user)
    setDeleteDialogOpen(true);
  }

  const handleCloseUpdateDialog = (userUpdated) => {
    setUpdateDialogOpen(false);
    setSelectedUser(null);
    if(userUpdated) {
      loadUsers()
    }
  }

  const handleSelectUpdateUser = (user) => {
    setSelectedUser(user)
    setUpdateDialogOpen(true);
  }


  React.useEffect(loadUsers, [page, rowsPerPage, order, orderDir]);

  const dense = (rowsPerPage == 25);

  return (
    <Paper>
      <TableContainer>
        <Table className={classes.table} aria-label="Users"
            size={dense ? 'small' : 'medium'}>
          <TableHead>
            <TableRow>
              <TableCell>Actions</TableCell>
              <TableCell>Username</TableCell>
              <TableCell>First Name</TableCell>
              <TableCell>Last Name</TableCell>
              <TableCell>Email</TableCell>
            </TableRow>
          </TableHead>
          <TableBody>
            {users ?
            users.map((user) => (
              <TableRow key={user.id}>
                <TableCell padding={'none'}>
                  <IconButton className={dense ? classes.iconButton : ''} onClick={() => handleSelectUpdateUser(user)}><EditIcon className={classes.editIcon} /></IconButton>
                  <IconButton className={dense ? classes.iconButton : ''} onClick={() => handleSelectDeleteUser(user)}>
                    <DeleteIcon className={classes.deleteIcon}/>
                  </IconButton>
                </TableCell>
                <TableCell component="th" scope="row">{user.username}</TableCell>
                <TableCell>{user.first_name}</TableCell>
                <TableCell>{user.last_name}</TableCell>
                <TableCell>{user.email}</TableCell>
              </TableRow>
            )) :
            <TableRow>
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
      <DeleteUserDialog open={deleteDialogOpen} onClose={handleCloseDeleteDialog} userId={selectedUser && selectedUser.id} username={selectedUser && selectedUser.username} />
      <UpdateUserDialog open={updateDialogOpen} onClose={handleCloseUpdateDialog} userId={selectedUser && selectedUser.id} />
    </Paper>
  );
}