import React from 'react';
import { connect } from 'react-redux';
import moment from 'moment';

import { makeStyles } from '@material-ui/core/styles';
import { Table, TableBody, TableCell, TableContainer, TablePagination, TableSortLabel, 
  TableHead, TableRow, Paper, CircularProgress, IconButton, Tooltip, Toolbar, Typography } from '@material-ui/core';
import DeleteIcon from '@material-ui/icons/Delete';
import AddIcon from '@material-ui/icons/AddCircle';

import { getAdminApiKeys, deleteAdminApiKey, createAdminApiKey } from '../fetch'
import { loadedApiKeys, clearApiKeys, updateApiKeysOrderDir, updateApiKeysOrder, updateApiKeysPage, updateApiKeysRowsPerPage } from '../actions/admin'

import CreateApiKeyDialog from '../components/CreateApiKeyDialog'
import DeleteDialog from '../components/DeleteDialog';

const useStyles = makeStyles({
  iconButton: {
    padding: '6px'
  },
  createIcon: {
    color: 'green',
  },
  deleteIcon: {
    color: 'red',
  },
  actionsCell:{
    minWidth:'48px', // 1x icon size
  },
  topBarFlex: {
    flexGrow: 1,
  },
});

function ApiKeyTable({apiKeys, loadedApiKeys, updateApiKeysOrder, updateApiKeysOrderDir, updateApiKeysPage, updateApiKeysRowsPerPage}) {
  const classes = useStyles();
  let [currentDialogOpen, setCurrentDialogOpen] = React.useState(null);
  let [selectedApiKey, setSelectedApiKey] = React.useState(null);

  const { loaded, rows, count, page, rowsPerPage, order, orderDir } = apiKeys;

  const loadApiKeys = (force) => {
    if(!loaded || force) {
      getAdminApiKeys(page, rowsPerPage, order, orderDir).then(response => {
        if(response.status == 0) {
          loadedApiKeys(response.api_keys, response.api_key_count)
        }
      })
    }
  }

  const handleChangePage = (event, newPage) => {
    updateApiKeysPage(newPage);
  };

  const handleChangeRowsPerPage = (event) => {
    let newRowsPerPage = parseInt(event.target.value, 10);
    updateApiKeysRowsPerPage(newRowsPerPage);
  };

  const handleCloseDialogs = (apiKeysChange) => {
    setCurrentDialogOpen(null);
    setSelectedApiKey(null);
    if(apiKeysChange) {
      loadApiKeys(true)
    }
  }

  const handleOpenDialog = (type, apiKey) => {
    setSelectedApiKey(apiKey)
    setCurrentDialogOpen(type);
  }

  const oppositeDir = () => (orderDir === 'asc') ? 'desc' : 'asc';

  const flipOrderDir = () => {
    updateApiKeysOrderDir(oppositeDir());
  }

  const handleClickSort = (key) => {
    if(key === order) {
      flipOrderDir();
    }
    else {
      // Updated Date is Flipped Visually
      if(key == 'updated_at') {
        updateApiKeysOrderDir('desc');
      }
      else {
        updateApiKeysOrderDir('asc');
      }
      updateApiKeysOrder(key);
    }
  }

  React.useEffect(loadApiKeys, [page, rowsPerPage, order, orderDir]);

  const dense = (rowsPerPage == 25);

  return (
    <Paper>
      <Toolbar>
        <Typography variant="h6" component="div" className={classes.topBarFlex}>
          Api Keys
        </Typography>

        <Tooltip title="Create Api Key">
          <IconButton aria-label="Create Api Key" className={classes.createIcon} onClick={() => handleOpenDialog('create')}>
            <AddIcon />
          </IconButton>
        </Tooltip>
      </Toolbar>
      <TableContainer>
        <Table aria-label="Api Keys"
            size={dense ? 'small' : 'medium'}>
          <TableHead>
            <TableRow>
              <TableCell>Actions</TableCell>
              <TableCell sortDirection={order === 'apiKeyname' ? orderDir : false}>
                <TableSortLabel
                  active={order === 'key'}
                  direction={order === 'key' ? orderDir : 'asc'}
                  onClick={() => handleClickSort('key')}
                >
                  Key
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
            {loaded ?
            rows.map((apiKey) => (
              <TableRow key={apiKey.id}>
                <TableCell padding={'none'} className={classes.actionsCell}>
                  <IconButton className={dense ? classes.iconButton : ''} onClick={() => handleOpenDialog('delete', apiKey)}>
                    <DeleteIcon className={classes.deleteIcon}/>
                  </IconButton>
                </TableCell>
                <TableCell component="th" scope="row">{apiKey.key}</TableCell>
                <TableCell>{moment(apiKey.created_at).calendar()}</TableCell>
              </TableRow>
            )) :
            new Array(rowsPerPage).fill(1).map((nothing, ind) => (
              <TableRow key={ind}>
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
      <DeleteDialog open={currentDialogOpen == 'delete'} onClose={handleCloseDialogs} objectId={selectedApiKey && selectedApiKey.id} 
        objectName={selectedApiKey && selectedApiKey.apiKeyname} objectType={'Api Key'} deleteAction={deleteAdminApiKey} />
      <CreateApiKeyDialog open={currentDialogOpen == 'create'} onClose={handleCloseDialogs}/>
    </Paper>
  );
}

const mapDispatchToProps = {
  clearApiKeys,
  loadedApiKeys,
  updateApiKeysOrder,
  updateApiKeysOrderDir,
  updateApiKeysPage,
  updateApiKeysRowsPerPage
}

const mapStateToProps = state => ({
  apiKeys: state.admin.apiKeys
})


export default connect(mapStateToProps, mapDispatchToProps)(ApiKeyTable)