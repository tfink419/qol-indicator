import _ from 'lodash'

import { userLogout } from 'actions/user';
const UNWANTED_PARAMETERS = ['id', 'created_at', 'updated_at']

var store = null;

export const setStore = (sto) => store = sto;

export const paramify = (params) => '?'+Object.keys(params).map(key => `${key}=${encodeURIComponent(params[key])}`).join('&')

function handleResponse(response) {
  if(response.status != 0 && response.status != 200) {
    if(response.status == 401 && response.error == 'Please log in.') {
      store.dispatch(userLogout());
    }
    throw {
      status: response.status,
      message: response.error,
      details: response.error_details
    };
  }
  return response
}

function filterUnwantedParams(obj) {
  let newObj = { ...obj }
  UNWANTED_PARAMETERS.forEach((param) => delete newObj[param]);
  return newObj;
}

export const parseLatLng = (latLng) => `[${_.round(latLng[0],3)},${_.round(latLng[1],3)}]`


export const postLogin = (username, password) => {
  return fetch('/login', { method:'POST', body: JSON.stringify({username, password}), 
    headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json'
  }})
  .then(response => response.json())
  .then(handleResponse)
}

export const postRegister = (user) => {
  return fetch('/register', { method:'POST', body: JSON.stringify({ user }), 
    headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json'
  }})
  .then(response => response.json())
  .then(handleResponse)
}

export const getAdminUsers = (page, rowsPerPage, sortOrder, dir) => {
  let url = "/api/admin/users",
    params = { limit: rowsPerPage, page, order: sortOrder, dir:dir.toUpperCase() };
  // Turn object into http params
  url += paramify(params)

  return fetch(url, {
    headers: {
      'Accept': 'application/json'
  }})
  .then(response => response.json())
  .then(handleResponse)
}

export const getAdminGroceryStores = (page, rowsPerPage, sortOrder, dir, search) => {
  let url = "/api/admin/grocery_stores",
    params = { limit: rowsPerPage, page, order: sortOrder, dir:dir.toUpperCase(), search };
  // Turn object into http params
  url += paramify(params)

  return fetch(url, {
    headers: {
      'Accept': 'application/json'
  }})
  .then(response => response.json())
  .then(handleResponse)
}


export const getAdminUser = (userId) => {
  return fetch('/api/admin/users/'+userId, { 
    headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json'
  }})
  .then(response => response.json())
  .then(handleResponse)
}

export const putAdminUser = (user) => {
  return fetch('/api/admin/users/'+user.id, { method:'PUT', body: JSON.stringify({user: filterUnwantedParams(user)}), 
    headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json'
  }})
  .then(response => response.json())
  .then(handleResponse)
}

export const postAdminUser = (user) => {
  return fetch('/api/admin/users', { method:'POST', body: JSON.stringify({user}), 
    headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json'
  }})
  .then(response => response.json())
  .then(handleResponse)
}

export const deleteAdminUser = (userId) => {
  let url = "/api/admin/users/"+userId;

  return fetch(url, {
    method: 'DELETE',
    headers: {
      'Accept': 'application/json'
  }})
  .then(response => response.json())
  .then(handleResponse)
}

export const postAdminGroceryStoreUploadCsv = (file, quality) => {
  const formData = new FormData();
  formData.append('csv_file', file);
  formData.append('filename', file.name);
  formData.append('default_quality', quality);
  return fetch('/api/admin/grocery_stores/upload_csv', { method:'POST', body: formData, 
    headers: {
      'Accept': 'application/json'
  }})
  .then(response => response.json())
  .then(handleResponse)
}

export const getAdminGroceryStore = (groceryStoreId) => {
  return fetch('/api/admin/grocery_stores/'+groceryStoreId, { 
    headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json'
  }})
  .then(response => response.json())
  .then(handleResponse)
}

export const postAdminGroceryStore = (groceryStore) => {
  let obj = { grocery_store: groceryStore};
  return fetch('/api/admin/grocery_stores', { method:'POST', body: JSON.stringify(obj), 
    headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json'
  }})
  .then(response => response.json())
  .then(handleResponse)
}

export const putAdminGroceryStore = (groceryStore) => {
  let obj = { grocery_store: filterUnwantedParams(groceryStore)};
  return fetch('/api/admin/grocery_stores/'+groceryStore.id, { method:'PUT', body: JSON.stringify(obj), 
    headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json'
  }})
  .then(response => response.json())
  .then(handleResponse)
}

export const deleteAdminGroceryStore = (groceryStoreId) => {
  let url = "/api/admin/grocery_stores/"+groceryStoreId;

  return fetch(url, {
    method: 'DELETE',
    headers: {
      'Accept': 'application/json'
  }})
  .then(response => response.json())
  .then(handleResponse)
}

export const getAdminBuildQualityMapStatuses = (page, rowsPerPage) => {
  let url = "/api/admin/build_quality_map/status",
    params = { limit: rowsPerPage, page };
  url += paramify(params)
  return fetch(url, {
    method:'GET', 
    headers: {
      'Accept': 'application/json'
  }})
  .then(response => response.json())
  .then(handleResponse)
}

export const getAdminGroceryStoreUploadCsvStatuses = (page, rowsPerPage) => {
  let url = "/api/admin/grocery_stores/upload_csv/status",
    params = { limit: rowsPerPage, page };
  url += paramify(params)
  return fetch(url, {
    method:'GET', 
    headers: {
      'Accept': 'application/json'
  }})
  .then(response => response.json())
  .then(handleResponse)
}

export const getAdminGroceryStoreUploadCsvStatus = (id) => {
  return fetch("/api/admin/grocery_stores/upload_csv/status/"+id, {
    method:'GET', 
    headers: {
      'Accept': 'application/json'
  }})
  .then(response => response.json())
  .then(handleResponse)
}

export const getAdminBuildQualityMapStatus = (id) => {
  return fetch("/api/admin/build_quality_map/status/"+id, {
    method:'GET', 
    headers: {
      'Accept': 'application/json'
  }})
  .then(response => response.json())
  .then(handleResponse)
}

export const postAdminBuildQualityMap = (rebuild, mapPointType) => {
  let url = '/api/admin/build_quality_map',
    params = { rebuild, point_type: mapPointType };
  url += paramify(params);
  return fetch(url, {
    method:'POST', 
    headers: {
      'Accept': 'application/json'
  }})
  .then(response => response.json())
  .then(handleResponse)
}


export const getMapDataQualityMap = (southWest, northEast, zoom, transit_type, abortSignal) => {
  let url = "/map_data/quality_map",
    params = { south_west: parseLatLng(southWest), north_east: parseLatLng(northEast), zoom};
  if(transit_type) {
    params.transit_type = transit_type;
  }
  // Turn object into http params
  url += paramify(params)

  return fetch(url, {
    signal: abortSignal,
    headers: {
      'Accept': 'application/json'
  }})
  .then(response => {
    let range = response.headers.get('Content-Range');
    let bounds = range.match(/Coordinates (\[.+\])-(\[.+\])/)
    return response.blob().then(responseBlob => ({
      responseBlob,
      southWest: bounds && JSON.parse(bounds[1]),
      northEast: bounds && JSON.parse(bounds[2])
    }))
  })
}

export const getMapDataGroceryStores = (southWest, northEast, abortSignal) => {
  let url = "/map_data/grocery_stores",
    params = { south_west: parseLatLng(southWest), north_east: parseLatLng(northEast) };
  // Turn object into http params
  url += paramify(params)

  return fetch(url, {
    signal: abortSignal,
    headers: {
      'Accept': 'application/json'
  }})
  .then(response => response.json())
  .then(handleResponse)
}

export const getUserSelf = () => {
  return fetch('/user/self', { 
    headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json'
  }})
  .then(response => response.json())
  .then(handleResponse)
}

export const putUserSelf = (user) => {
  return fetch('/user/self', { method:'PUT', body: JSON.stringify({user: filterUnwantedParams(user)}), 
    headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json'
  }})
  .then(response => response.json())
  .then(handleResponse)
}

export const postForgotPassword = (email) => {
  return fetch('/forgot-password', { method:'POST', body: JSON.stringify({email}), 
    headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json'
  }})
  .then(response => response.json())
  .then(handleResponse)
}

export const getResetPasswordDetails = (uuid) => {
  return fetch('/reset-password-details?uuid='+uuid, { 
    headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json'
  }})
  .then(response => response.json())
  .then(handleResponse)
}

export const postResetPassword = (uuid, password, password_confirmation) => {
  return fetch('/reset-password', { method:'POST', body: JSON.stringify({uuid, password, password_confirmation}), 
    headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json'
  }})
  .then(response => response.json())
  .then(handleResponse)
}

export const getMapPreferences = () => {
  return fetch('/map_preferences', { 
    headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json'
  }})
  .then(response => response.json())
  .then(handleResponse)
}

export const putMapPreferences = (user) => {
  return fetch('/map_preferences', { method:'PUT', body: JSON.stringify({map_preferences: filterUnwantedParams(user)}), 
    headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json'
  }})
  .then(response => response.json())
  .then(handleResponse)
}

export const getGroceryStore = (groceryStoreId) => {
  return fetch('/grocery_stores/'+groceryStoreId, { 
    headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json'
  }})
  .then(response => response.json())
  .then(handleResponse)
}



export const getAdminApiKeys = (page, rowsPerPage, sortOrder, dir) => {
  let url = "/api/admin/api_keys",
    params = { limit: rowsPerPage, page, order: sortOrder, dir:dir.toUpperCase() };
  // Turn object into http params
  url += paramify(params);

  return fetch(url, {
    headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json'
  }})
  .then(response => response.json())
  .then(handleResponse)
}

export const getAdminApiKey = (apiKey) => {
  return fetch('/api/admin/api_keys/'+apiKey, { 
    headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json'
  }})
  .then(response => response.json())
  .then(handleResponse)
}

export const postAdminApiKey = (apiKey) => {
  return fetch('/api/admin/api_keys', { method:'POST', body: JSON.stringify({apiKey}), 
    headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json'
  }})
  .then(response => response.json())
  .then(handleResponse)
}

export const deleteAdminApiKey = (apiKey) => {
  let url = "/api/admin/api_keys/"+apiKey;

  return fetch(url, {
    method: 'DELETE',
    headers: {
      'Accept': 'application/json'
  }})
  .then(response => response.json())
  .then(handleResponse)
}