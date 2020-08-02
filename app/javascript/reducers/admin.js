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
  apiKeys: { ...defaultTable },
  csvUpload: {},
  buildQualityMapStatuses: {
    page:0,
    rowsPerPage:10,
    loaded: false
  },
  groceryStoreUploadStatuses: {
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
    case 'LOADED_API_KEYS':
      return {
        ...state,
        apiKeys:{ 
          ...state.apiKeys,
          rows:action.apiKeys,
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
        buildQualityMapStatuses:{ 
          ...state.buildQualityMapStatuses,
          rows:action.buildQualityMapStatuses,
          count:action.count,
          current:action.currentBuildQualityMapStatus,
          loaded: true
        }
      }
    case 'LOADED_CURRENT_BUILD_HEATMAP_STATUS':
      return {
        ...state,
        buildQualityMapStatuses:{ 
          ...state.buildQualityMapStatuses,
          current:action.currentBuildQualityMapStatus,
          loaded: true
        }
      }

    case 'LOADED_GROCERY_STORE_UPLOAD_STATUSES':
      return {
        ...state,
        groceryStoreUploadStatuses:{ 
          ...state.groceryStoreUploadStatuses,
          rows:action.groceryStoreUploadStatuses,
          count:action.count,
          current:action.currentGroceryStoreUploadStatus,
          loaded: true
        }
      }
    case 'LOADED_CURRENT_GROCERY_STORE_UPLOAD_STATUS':
      return {
        ...state,
        groceryStoreUploadStatuses:{ 
          ...state.groceryStoreUploadStatuses,
          current:action.currentGroceryStoreUploadStatus,
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
        buildQualityMapStatuses: {
          ...state.buildQualityMapStatuses,
          page:action.page,
          loaded: false
        }
      }
    case 'UPDATE_BUILD_HEATMAP_STATUSES_ROWSPERPAGE':
      {
        let {page} = state.buildQualityMapStatuses;
        if(state.buildQualityMapStatuses.rowsPerPage != action.rowsPerPage) {
          page = Math.floor(state.buildQualityMapStatuses.rowsPerPage/action.rowsPerPage*page);
        }
        return {
          ...state,
          buildQualityMapStatuses: {
            ...state.buildQualityMapStatuses,
            rowsPerPage:action.rowsPerPage,
            page,
            loaded: false
          }
        }
      }

    case 'UPDATE_API_KEYS_ORDERDIR':
      return {
        ...state,
        apiKeys: {
          ...state.apiKeys,
          orderDir:action.orderDir,
          loaded: false
        }
      }
    case 'UPDATE_API_KEYS_ORDER':
      return {
        ...state,
        apiKeys: {
          ...state.apiKeys,
          order:action.order,
          loaded: false
        }
      }
    case 'UPDATE_API_KEYS_PAGE':
      return {
        ...state,
        apiKeys: {
          ...state.apiKeys,
          page:action.page,
          loaded: false
        }
      }
    case 'UPDATE_API_KEYS_ROWSPERPAGE':
    {
      let {page} = state.apiKeys;
      if(state.apiKeys.rowsPerPage != action.rowsPerPage) {
        page = Math.floor(state.apiKeys.rowsPerPage/action.rowsPerPage*page);
      }
      return {
        ...state,
        apiKeys: {
          ...state.apiKeys,
          rowsPerPage:action.rowsPerPage,
          page,
          loaded: false
        }
      }
    }

    case 'UPDATE_GROCERY_STORE_UPLOAD_STATUSES_PAGE':
      return {
        ...state,
        groceryStoreUploadStatuses: {
          ...state.groceryStoreUploadStatuses,
          page:action.page,
          loaded: false
        }
      }
    case 'UPDATE_GROCERY_STORE_UPLOAD_STATUSES_ROWSPERPAGE':
      {
        let {page} = state.groceryStoreUploadStatuses;
        if(state.groceryStoreUploadStatuses.rowsPerPage != action.rowsPerPage) {
          page = Math.floor(state.groceryStoreUploadStatuses.rowsPerPage/action.rowsPerPage*page);
        }
        return {
          ...state,
          groceryStoreUploadStatuses: {
            ...state.groceryStoreUploadStatuses,
            rowsPerPage:action.rowsPerPage,
            page,
            loaded: false
          }
        }
      }
    case 'SET_BUILD_HEATMAP_STATUS_RELOAD_INTERVAL_ID':
      return {
        ...state,
        buildQualityMapStatuses: {
          ...state.buildQualityMapStatuses,
          reloadIntervalId: action.reloadIntervalId
        }
      }
    case 'SET_GROCERY_STORE_UPLOAD_STATUS_RELOAD_INTERVAL_ID':
      return {
        ...state,
        groceryStoreUploadStatuses: {
          ...state.groceryStoreUploadStatuses,
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
    case 'CLEAR_API_KEYS':
      return {
        ...state,
        apiKeys:{...defaultTable}
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