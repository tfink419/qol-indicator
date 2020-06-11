import React from 'react';
import { connect } from 'react-redux'
import { useHistory } from 'react-router-dom'

import { makeStyles } from '@material-ui/core/styles';
import { Table, TableBody, TableCell, TableContainer, TablePagination, TableSortLabel, Menu, MenuItem,
  TableHead, TableRow, Paper, CircularProgress, IconButton, Tooltip, Toolbar, Typography } from '@material-ui/core';
import EditIcon from '@material-ui/icons/Edit';
import DeleteIcon from '@material-ui/icons/Delete';
import AddIcon from '@material-ui/icons/AddCircle';

import { getGroceryStores, deleteGroceryStore } from '../fetch'
import { loadedGroceryStores, updateGroceryStoresOrder, updateGroceryStoresOrderDir, updateGroceryStoresPage, updateGroceryStoresRowsPerPage} from '../actions/admin'
import { drawerWidth } from '../common'
import DeleteDialog from '../components/DeleteDialog';
import UpdateGroceryStoreDialog from '../components/UpdateGroceryStoreDialog';
import CreateGroceryStoreDialog from '../components/CreateGroceryStoreDialog';

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
  actionsCell:{
    minWidth:'96px', // 2x icon size
  },
  topBarFlex: {
    flexGrow: 1,
  },
});

function GroceryStoreTable({groceryStores, loadedGroceryStores, updateGroceryStoresOrder, updateGroceryStoresOrderDir, updateGroceryStoresPage, updateGroceryStoresRowsPerPage}) {
  const classes = useStyles();
  const { loaded, rows, count, page, rowsPerPage, order, orderDir } = groceryStores;
  let history = useHistory();

  let [currentDialogOpen, setCurrentDialogOpen] = React.useState(null);
  let [selectedGroceryStore, setSelectedGroceryStore] = React.useState(null);
  let [anchorEl, setAnchorEl] = React.useState(null);

  const loadGroceryStores = () => {
    ;
    getGroceryStores(page, rowsPerPage, order, orderDir).then(response => {
      if(response.status == 0) {
        loadedGroceryStores(response.grocery_stores, response.grocery_store_count)
      }
    })
  }

  const handleChangePage = (event, newPage) => {
    updateGroceryStoresPage(newPage);
  };

  const handleChangeRowsPerPage = (event) => {
    let prevRowsPerPage = rowsPerPage;
    let newRowsPerPage = parseInt(event.target.value, 10);
    updateGroceryStoresRowsPerPage(newRowsPerPage);
    if(prevRowsPerPage != newRowsPerPage) {
      updateGroceryStoresPage(Math.floor(prevRowsPerPage/newRowsPerPage*page));
    }
  };

  const handleCloseDialogs = (groceryStoreChange) => {
    setCurrentDialogOpen(null);
    setSelectedGroceryStore(null);
    if(groceryStoreChange) {
      loadGroceryStores()
    }
  }

  const handleOpenDialog = (type, groceryStore) => {
    setAnchorEl(null);
    setSelectedGroceryStore(groceryStore)
    setCurrentDialogOpen(type);
  }

  const flipOrderDir = () => {
    updateGroceryStoresOrderDir((orderDir === 'asc') ? 'desc' : 'asc');
  }

  const handleClickSort = (key) => {
    if(key === order) {
      flipOrderDir();
    }
    else {
      // Updated Date is Flipped Visually
      if(key == 'updated_at') {
        updateGroceryStoresOrderDir('desc');
      }
      else {
        updateGroceryStoresOrderDir('asc');
      }
      updateGroceryStoresOrder(key);
    }
  }

  const handleCreateMenu = (event) => {
    setAnchorEl(event.currentTarget);
  };

  const handleCloseMenu = (event) => {
    setAnchorEl(null);
  };


  React.useEffect(loadGroceryStores, [page, rowsPerPage, order, orderDir]);

  const dense = (rowsPerPage == 25);

  return (
    <Paper className={classes.pushRight}>
      <Toolbar>
        <Typography variant="h6" component="div" className={classes.topBarFlex}>
          Grocery Stores
        </Typography>
        <div>
        <Tooltip title="Create Grocery Store">
          <IconButton aria-label="create grocery store" className={classes.createUserIcon} onClick={handleCreateMenu}>
            <AddIcon />
          </IconButton>
        </Tooltip>
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
            open={Boolean(anchorEl)} onClose={handleCloseMenu}
          >
            <MenuItem onClick={() => handleOpenDialog('create')}>Single Store</MenuItem>
            <MenuItem onClick={() => history.push('/admin/grocery_stores/upload')}>Upload CSV file</MenuItem>
          </Menu>
        </div>
      </Toolbar>
      <TableContainer>
        <Table aria-label="Grocery Stores"
            size={dense ? 'small' : 'medium'}>
          <TableHead>
            <TableRow>
              <TableCell>Actions</TableCell>
              <TableCell sortDirection={order === 'name' ? orderDir : false}>
                <TableSortLabel
                  active={order === 'name'}
                  direction={order === 'name' ? orderDir : 'asc'}
                  onClick={() => handleClickSort('name')}
                >
                  Grocery Store Name
                </TableSortLabel>
              </TableCell>
              <TableCell sortDirection={order === 'address' ? orderDir : false}>
                <TableSortLabel
                  active={order === 'address'}
                  direction={order === 'address' ? orderDir : 'asc'}
                  onClick={() => handleClickSort('address')}
                >
                  Address
                </TableSortLabel>
              </TableCell>
              <TableCell sortDirection={order === 'city' ? orderDir : false}>
                <TableSortLabel
                  active={order === 'city'}
                  direction={order === 'city' ? orderDir : 'asc'}
                  onClick={() => handleClickSort('city')}
                >
                  City
                </TableSortLabel>
              </TableCell>
              <TableCell sortDirection={order === 'state' ? orderDir : false}>
                <TableSortLabel
                  active={order === 'state'}
                  direction={order === 'state' ? orderDir : 'asc'}
                  onClick={() => handleClickSort('state')}
                >
                  State
                </TableSortLabel>
              </TableCell>
              <TableCell sortDirection={order === 'zip' ? orderDir : false}>
                <TableSortLabel
                  active={order === 'zip'}
                  direction={order === 'zip' ? orderDir : 'asc'}
                  onClick={() => handleClickSort('zip')}
                >
                  Zip
                </TableSortLabel>
              </TableCell>
              <TableCell sortDirection={order === 'lat' ? orderDir : false}>
                <TableSortLabel
                  active={order === 'lat'}
                  direction={order === 'lat' ? orderDir : 'asc'}
                  onClick={() => handleClickSort('lat')}
                >
                  Latitude
                </TableSortLabel>
              </TableCell>
              <TableCell sortDirection={order === 'long' ? orderDir : false}>
                <TableSortLabel
                  active={order === 'long'}
                  direction={order === 'long' ? orderDir : 'asc'}
                  onClick={() => handleClickSort('long')}
                >
                  Longitude
                </TableSortLabel>
              </TableCell>
            </TableRow>
          </TableHead>
          <TableBody>
            {loaded ?
            rows.map(groceryStore => (
              <TableRow key={groceryStore.id}>
                <TableCell padding={'none'} className={classes.actionsCell}>
                  <IconButton className={dense ? classes.iconButton : ''} onClick={() => handleOpenDialog('update', groceryStore)}><EditIcon className={classes.editIcon} /></IconButton>
                  <IconButton className={dense ? classes.iconButton : ''} onClick={() => handleOpenDialog('delete', groceryStore)}>
                    <DeleteIcon className={classes.deleteIcon}/>
                  </IconButton>
                </TableCell>
                <TableCell component="th" scope="row">{groceryStore.name}</TableCell>
                <TableCell>{groceryStore.address}</TableCell>
                <TableCell>{groceryStore.city}</TableCell>
                <TableCell>{groceryStore.state}</TableCell>
                <TableCell>{groceryStore.zip}</TableCell>
                <TableCell>{groceryStore.lat}</TableCell>
                <TableCell>{groceryStore.long}</TableCell>
              </TableRow>
            )) :
            new Array(rowsPerPage).fill(1).map((nothing, ind) => (
              <TableRow key={ind}>
                <TableCell><CircularProgress /></TableCell>
                <TableCell><CircularProgress /></TableCell>
                <TableCell><CircularProgress /></TableCell>
                <TableCell><CircularProgress /></TableCell>
                <TableCell><CircularProgress /></TableCell>
                <TableCell><CircularProgress /></TableCell>
                <TableCell><CircularProgress /></TableCell>
                <TableCell><CircularProgress /></TableCell>
              </TableRow>
            ))
            }
          </TableBody>
        </Table>
      </TableContainer>
      {loaded && 
      <TablePagination
        rowsPerPageOptions={[10, 25]}
        component="div"
        count={count}
        rowsPerPage={rowsPerPage}
        page={page}
        onChangePage={handleChangePage}
        onChangeRowsPerPage={handleChangeRowsPerPage}
      />}
      <DeleteDialog open={currentDialogOpen == 'delete'} onClose={handleCloseDialogs} objectId={selectedGroceryStore && selectedGroceryStore.id} 
        objectName={selectedGroceryStore && `${selectedGroceryStore.name} at ${selectedGroceryStore.address}`} objectType="Grocery Store"  deleteAction={deleteGroceryStore} />
      <UpdateGroceryStoreDialog open={currentDialogOpen == 'update'} onClose={handleCloseDialogs} groceryStoreId={selectedGroceryStore && selectedGroceryStore.id} />
      <CreateGroceryStoreDialog open={currentDialogOpen == 'create'} onClose={handleCloseDialogs}/>
    </Paper>
  );
}
const mapDispatchToProps = {
    loadedGroceryStores,
  updateGroceryStoresOrder,
  updateGroceryStoresOrderDir,
  updateGroceryStoresPage,
  updateGroceryStoresRowsPerPage
}

const mapStateToProps = state => ({
  groceryStores: state.admin.groceryStores
})

export default connect(mapStateToProps, mapDispatchToProps)(GroceryStoreTable)