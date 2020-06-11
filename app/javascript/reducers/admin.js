const defaultTable = {
  orderDir:'asc',
  order:'created_at',
  page:0,
  rowsPerPage:10,
  loaded: false
};
const admin = (state = {
  users:{...defaultTable},
  groceryStores:{...defaultTable}
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
      return {
        ...state,
        users: {
          ...state.users,
          rowsPerPage:action.rowsPerPage,
          loaded: false
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
      return {
        ...state,
        groceryStores: {
          ...state.groceryStores,
          rowsPerPage:action.rowsPerPage,
          loaded: false
        }
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
        groceryStores:{...defaultTable}
      }
    default:
      return state
  }
}

export default admin