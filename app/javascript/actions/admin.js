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

export const loadedBuildHeatmapStatuses = (buildHeatmapStatuses, count, currentBuildHeatmapStatus) => ({
  type: 'LOADED_BUILD_HEATMAP_STATUSES',
  buildHeatmapStatuses,
  count,
  currentBuildHeatmapStatus
})

export const loadedCurrentBuildHeatmapStatus = (currentBuildHeatmapStatus) => ({
  type: 'LOADED_CURRENT_BUILD_HEATMAP_STATUS',
  currentBuildHeatmapStatus
})

export const setBuildHeatmapStatusReloadIntervalId = (reloadIntervalId) => ({
  type: 'SET_BUILD_HEATMAP_STATUS_RELOAD_INTERVAL_ID',
  reloadIntervalId
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

export const updateBuildHeatmapStatusesPage = (page) => ({
  type:'UPDATE_BUILD_HEATMAP_STATUSES_PAGE',
  page
})

export const updateBuildHeatmapStatusesRowsPerPage = (rowsPerPage) => ({
  type:'UPDATE_BUILD_HEATMAP_STATUSES_ROWSPERPAGE',
  rowsPerPage
})

export const csvProcessing = (fileType, fileName) => ({
  type: 'CSV_PROCESSING',
  fileType,
  fileName
})

export const csvDone = () => ({
  type: 'CSV_DONE'
})