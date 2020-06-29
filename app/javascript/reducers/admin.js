const defaultTable = {
  orderDir:'asc',
  order:'created_at',
  page:0,
  rowsPerPage:10,
  loaded: false,
  searchField:''
};
const admin = (state = {
  users:{...defaultTable},
  groceryStores:{...defaultTable},
  csvUpload: {},
  buildHeatmapStatuses: {
    page:0,
    rowsPerPage:10,
    loaded: false
  },
  uploadCsvStatuses: {
    page:0,
    rowsPerPage:10,
    loaded: false
  }
}, action) => {
  switch (action.type) {
    case 'LOADED_USERS':
      return {
        ...state,
        users: {
          ...state.users,
          rows:action.users,
          count:action.count,
          loaded: true
        }
      }
    case 'LOADED_GROCERY_STORES':
      return {
        ...state,
        groceryStores:{ 
          ...state.groceryStores,
          rows:action.groceryStores,
          count:action.count,
          loaded: true
        }
      }
    case 'UPDATED_GROCERY_STORES':
      return {
        ...state,
        groceryStores:{ 
          ...state.groceryStores,
          loaded: false
        }
      }
    case 'LOADED_BUILD_HEATMAP_STATUSES':
      return {
        ...state,
        buildHeatmapStatuses:{ 
          ...state.buildHeatmapStatuses,
          rows:action.buildHeatmapStatuses,
          count:action.count,
          current:action.currentBuildHeatmapStatus,
          loaded: true
        }
      }
    case 'LOADED_CURRENT_BUILD_HEATMAP_STATUS':
      return {
        ...state,
        buildHeatmapStatuses:{ 
          ...state.buildHeatmapStatuses,
          current:action.currentBuildHeatmapStatus,
          loaded: true
        }
      }

    case 'LOADED_UPLOAD_CSV_STATUSES':
      return {
        ...state,
        uploadCsvStatuses:{ 
          ...state.uploadCsvStatuses,
          rows:action.uploadCsvStatuses,
          count:action.count,
          current:action.currentUploadCsvStatus,
          loaded: true
        }
      }
    case 'LOADED_CURRENT_UPLOAD_CSV_STATUS':
      return {
        ...state,
        uploadCsvStatuses:{ 
          ...state.uploadCsvStatuses,
          current:action.currentUploadCsvStatus,
          loaded: true
        }
      }
    case 'UPDATE_USERS_ORDERDIR':
      return {
        ...state,
        users: {
          ...state.users,
          orderDir:action.orderDir,
          loaded: false
        }
      }
    case 'UPDATE_USERS_ORDER':
      return {
        ...state,
        users: {
          ...state.users,
          order:action.order,
          loaded: false
        }
      }
    case 'UPDATE_USERS_PAGE':
      return {
        ...state,
        users: {
          ...state.users,
          page:action.page,
          loaded: false
        }
      }
    case 'UPDATE_USERS_ROWSPERPAGE':
    {
      let {page} = state.users;
      if(state.users.rowsPerPage != action.rowsPerPage) {
        page = Math.floor(state.users.rowsPerPage/action.rowsPerPage*page);
      }
      return {
        ...state,
        users: {
          ...state.users,
          rowsPerPage:action.rowsPerPage,
          page,
          loaded: false
        }
      }
    }

    case 'UPDATE_GROCERY_STORES_ORDERDIR':
      return {
        ...state,
        groceryStores: {
          ...state.groceryStores,
          orderDir:action.orderDir,
          loaded: false
        }
      }
    case 'UPDATE_GROCERY_STORES_ORDER':
      return {
        ...state,
        groceryStores: {
          ...state.groceryStores,
          order:action.order,
          loaded: false
        }
      }
    case 'UPDATE_GROCERY_STORES_PAGE':
      return {
        ...state,
        groceryStores: {
          ...state.groceryStores,
          page:action.page,
          loaded: false
        }
      }
    case 'UPDATE_GROCERY_STORES_ROWSPERPAGE':
    {
      let {page} = state.groceryStores;
      if(state.groceryStores.rowsPerPage != action.rowsPerPage) {
        page = Math.floor(state.groceryStores.rowsPerPage/action.rowsPerPage*page);
      }
      return {
        ...state,
        groceryStores: {
          ...state.groceryStores,
          rowsPerPage:action.rowsPerPage,
          page,
          loaded: false
        }
      }
    }
    case 'UPDATE_GROCERY_STORES_SEARCHFIELD':
      return {
        ...state,
        groceryStores: {
          ...state.groceryStores,
          searchField:action.searchField,
          loaded: false,
          page:0
        }
      }

    case 'UPDATE_BUILD_HEATMAP_STATUSES_PAGE':
      return {
        ...state,
        buildHeatmapStatuses: {
          ...state.buildHeatmapStatuses,
          page:action.page,
          loaded: false
        }
      }
    case 'UPDATE_BUILD_HEATMAP_STATUSES_ROWSPERPAGE':
      {
        let {page} = state.buildHeatmapStatuses;
        if(state.buildHeatmapStatuses.rowsPerPage != action.rowsPerPage) {
          page = Math.floor(state.buildHeatmapStatuses.rowsPerPage/action.rowsPerPage*page);
        }
        return {
          ...state,
          buildHeatmapStatuses: {
            ...state.buildHeatmapStatuses,
            rowsPerPage:action.rowsPerPage,
            page,
            loaded: false
          }
        }
      }


    case 'UPDATE_UPLOAD_CSV_STATUSES_PAGE':
      return {
        ...state,
        uploadCsvStatuses: {
          ...state.uploadCsvStatuses,
          page:action.page,
          loaded: false
        }
      }
    case 'UPDATE_UPLOAD_CSV_STATUSES_ROWSPERPAGE':
      {
        let {page} = state.uploadCsvStatuses;
        if(state.uploadCsvStatuses.rowsPerPage != action.rowsPerPage) {
          page = Math.floor(state.uploadCsvStatuses.rowsPerPage/action.rowsPerPage*page);
        }
        return {
          ...state,
          uploadCsvStatuses: {
            ...state.uploadCsvStatuses,
            rowsPerPage:action.rowsPerPage,
            page,
            loaded: false
          }
        }
      }
    case 'SET_BUILD_HEATMAP_STATUS_RELOAD_INTERVAL_ID':
      return {
        ...state,
        buildHeatmapStatuses: {
          ...state.buildHeatmapStatuses,
          reloadIntervalId: action.reloadIntervalId
        }
      }
    case 'SET_UPLOAD_CSV_STATUS_RELOAD_INTERVAL_ID':
      return {
        ...state,
        uploadCsvStatuses: {
          ...state.uploadCsvStatuses,
          reloadIntervalId: action.reloadIntervalId
        }
      }
    case 'CSV_PROCESSING':
      return {
        ...state,
        csvUpload: {
          type: action.fileType,
          name: action.fileName
        }
      }
    case 'CSV_DONE':
      return {
        ...state,
        csvUpload: {}
      }
      
    case 'CLEAR_USERS':
      return {
        ...state,
        users:{...defaultTable}
      }
    case 'CLEAR_GROCERY_STORES':
      return {
        ...state,
        groceryStores:{...defaultTable}
      }
    case 'USER_LOGOUT':
      return {
        users:{...defaultTable},
        groceryStores:{...defaultTable},
        csvUpload: {}
      }
    default:
      return state
  }
}

export default admin