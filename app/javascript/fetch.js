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
  return fetch('/register', { method:'POST', body: JSON.stringify({user :{first_name:user.first_name, last_name:user.last_name, email:user.email, username:user.username, password:user.password, password_confirmation: user.password_confirmation}}), 
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
  return fetch('/users/'+user.id, { method:'PUT', body: JSON.stringify({user :{first_name:user.first_name, last_name:user.last_name, email:user.email, username:user.username, is_admin:user.is_admin}}), 
    headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json'
  }})
  .then(response => response.json())
  .then(handleResponse)
}

export const postUser = (user) => {
  return fetch('/users', { method:'POST', body: JSON.stringify({user :{first_name:user.first_name, last_name:user.last_name, email:user.email, username:user.username, password:user.password, password_confirmation: user.password_confirmation, is_admin: user.is_admin}}), 
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