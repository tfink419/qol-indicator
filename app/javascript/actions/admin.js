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

export const updatedGroceryStores = () => ({
  type: 'UPDATED_GROCERY_STORES'
})

export const loadedBuildQualityMapStatuses = (buildQualityMapStatuses, count, currentBuildQualityMapStatus) => ({
  type: 'LOADED_BUILD_HEATMAP_STATUSES',
  buildQualityMapStatuses,
  count,
  currentBuildQualityMapStatus
})

export const loadedGroceryStoreUploadStatuses = (groceryStoreUploadStatuses, count, currentGroceryStoreUploadStatus) => ({
  type: 'LOADED_GROCERY_STORE_UPLOAD_STATUSES',
  groceryStoreUploadStatuses,
  count,
  currentGroceryStoreUploadStatus
})

export const loadedCurrentBuildQualityMapStatus = (currentBuildQualityMapStatus) => ({
  type: 'LOADED_CURRENT_BUILD_HEATMAP_STATUS',
  currentBuildQualityMapStatus
})

export const loadedCurrentGroceryStoreUploadStatus = (currentGroceryStoreUploadStatus) => ({
  type: 'LOADED_CURRENT_GROCERY_STORE_UPLOAD_STATUS',
  currentGroceryStoreUploadStatus
})

export const setBuildQualityMapStatusReloadIntervalId = (reloadIntervalId) => ({
  type: 'SET_BUILD_HEATMAP_STATUS_RELOAD_INTERVAL_ID',
  reloadIntervalId
})

export const setGroceryStoreUploadStatusReloadIntervalId = (reloadIntervalId) => ({
  type: 'SET_GROCERY_STORE_UPLOAD_STATUS_RELOAD_INTERVAL_ID',
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

export const updateBuildQualityMapStatusesPage = (page) => ({
  type:'UPDATE_BUILD_HEATMAP_STATUSES_PAGE',
  page
})

export const updateBuildQualityMapStatusesRowsPerPage = (rowsPerPage) => ({
  type:'UPDATE_BUILD_HEATMAP_STATUSES_ROWSPERPAGE',
  rowsPerPage
})

export const updateGroceryStoreUploadStatusesPage = (page) => ({
  type:'UPDATE_GROCERY_STORE_UPLOAD_STATUSES_PAGE',
  page
})

export const updateGroceryStoreUploadStatusesRowsPerPage = (rowsPerPage) => ({
  type:'UPDATE_GROCERY_STORE_UPLOAD_STATUSES_ROWSPERPAGE',
  rowsPerPage
})

export const csvProcessing = (fileType, fileName) => ({
  type: 'GROCERY_STORE_PROCESSING',
  fileType,
  fileName
})

export const csvDone = () => ({
  type: 'GROCERY_STORE_DONE'
})

export const loadedApiKeys = (apiKeys, count) => ({
  type: 'LOADED_API_KEYS',
  apiKeys,
  count
})

export const clearApiKeys = () => ({
  type: 'CLEAR_API_KEYS'
})

export const updateApiKeysOrderDir = (orderDir) => ({
  type:'UPDATE_API_KEYS_ORDERDIR',
  orderDir
})

export const updateApiKeysOrder = (order) => ({
  type:'UPDATE_API_KEYS_ORDER',
  order
})

export const updateApiKeysPage = (page) => ({
  type:'UPDATE_API_KEYS_PAGE',
  page
})

export const updateApiKeysRowsPerPage = (rowsPerPage) => ({
  type:'UPDATE_API_KEYS_ROWSPERPAGE',
  rowsPerPage
})
