export const loadedUsers = (users, count) => ({
  type: 'LOADED_USERS',
  users,
  count
})

export const loadedGroceryStores = (groceryStores, count) => ({
  type: 'LOADED_GROCERY_STORES',
  groceryStores,
  count
})

export const clearUsers = () => ({
  type: 'CLEAR_USERS'
})

export const clearGroceryStores = () => ({
  type: 'CLEAR_GROCERY_STORES'
})

export const updateUsersOrderDir = (orderDir) => ({
  type:'UPDATE_USERS_ORDERDIR',
  orderDir
})

export const updateUsersOrder = (order) => ({
  type:'UPDATE_USERS_ORDER',
  order
})

export const updateUsersPage = (page) => ({
  type:'UPDATE_USERS_PAGE',
  page
})

export const updateUsersRowsPerPage = (rowsPerPage) => ({
  type:'UPDATE_USERS_ROWSPERPAGE',
  rowsPerPage
})

export const updateGroceryStoresOrderDir = (orderDir) => ({
  type:'UPDATE_GROCERY_STORES_ORDERDIR',
  orderDir
})

export const updateGroceryStoresOrder = (order) => ({
  type:'UPDATE_GROCERY_STORES_ORDER',
  order
})

export const updateGroceryStoresPage = (page) => ({
  type:'UPDATE_GROCERY_STORES_PAGE',
  page
})

export const updateGroceryStoresRowsPerPage = (rowsPerPage) => ({
  type:'UPDATE_GROCERY_STORES_ROWSPERPAGE',
  rowsPerPage
})

export const updateGroceryStoresSearchField = (searchField) => ({
  type:'UPDATE_GROCERY_STORES_SEARCHFIELD',
  searchField
})