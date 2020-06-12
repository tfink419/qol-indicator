const UNWANTED_PARAMETERS = ['id', 'created_at', 'updated_at']

function handleResponse(response) {
  if(response.status != 0 && response.status != 200) {
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

const parseLatLng = (latLng) => `[${latLng.lat},${latLng.lng}]`


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

export const getUsers = (page, rowsPerPage, sortOrder, dir) => {
  let url = "/users",
    params = { limit: rowsPerPage, page, order: sortOrder, dir:dir.toUpperCase() };
  // Turn object into http params
  url += '?'+Object.keys(params).map(key => `${key}=${encodeURIComponent(params[key])}`).join('&')

  return fetch(url, {
    headers: {
      'Accept': 'application/json'
  }})
  .then(response => response.json())
  .then(handleResponse)
}

export const getGroceryStores = (page, rowsPerPage, sortOrder, dir) => {
  let url = "/grocery_stores",
    params = { limit: rowsPerPage, page, order: sortOrder, dir:dir.toUpperCase() };
  // Turn object into http params
  url += '?'+Object.keys(params).map(key => `${key}=${encodeURIComponent(params[key])}`).join('&')

  return fetch(url, {
    headers: {
      'Accept': 'application/json'
  }})
  .then(response => response.json())
  .then(handleResponse)
}


export const getUser = (userId) => {
  return fetch('/users/'+userId, { 
    headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json'
  }})
  .then(response => response.json())
  .then(handleResponse)
}

export const putUser = (user) => {
  return fetch('/users/'+user.id, { method:'PUT', body: JSON.stringify({user: filterUnwantedParams(user)}), 
    headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json'
  }})
  .then(response => response.json())
  .then(handleResponse)
}

export const postUser = (user) => {
  return fetch('/users', { method:'POST', body: JSON.stringify({user}), 
    headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json'
  }})
  .then(response => response.json())
  .then(handleResponse)
}

export const deleteUser = (userId) => {
  let url = "/users/"+userId;

  return fetch(url, {
    method: 'DELETE',
    headers: {
      'Accept': 'application/json'
  }})
  .then(response => response.json())
  .then(handleResponse)
}

export const postGroceryStoreUploadCsv = (file) => {
  const formData = new FormData();
  formData.append('csv_file', file);
  return fetch('/grocery_stores/upload_csv', { method:'POST', body: formData, 
    headers: {
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

export const postGroceryStore = (groceryStore) => {
  let obj = { grocery_store: groceryStore};
  return fetch('/grocery_stores', { method:'POST', body: JSON.stringify(obj), 
    headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json'
  }})
  .then(response => response.json())
  .then(handleResponse)
}

export const putGroceryStore = (groceryStore) => {
  let obj = { grocery_store: filterUnwantedParams(groceryStore)};
  return fetch('/grocery_stores/'+groceryStore.id, { method:'PUT', body: JSON.stringify(obj), 
    headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json'
  }})
  .then(response => response.json())
  .then(handleResponse)
}

export const deleteGroceryStore = (groceryStoreId) => {
  let url = "/grocery_stores/"+groceryStoreId;

  return fetch(url, {
    method: 'DELETE',
    headers: {
      'Accept': 'application/json'
  }})
  .then(response => response.json())
  .then(handleResponse)
}

export const getMapData = (southWest, northEast) => {
  let url = `/map_data?south_west=${parseLatLng(southWest)}&north_east=${parseLatLng(northEast)}`;

  return fetch(url, {
    headers: {
      'Accept': 'application/json'
  }})
  .then(response => response.json())
  .then(handleResponse)
}