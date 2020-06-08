export const postLogin = (username, password) => {
  return fetch('/login', { method:'POST', body: JSON.stringify({username, password}), 
    headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json'
  }})
  .then(response => response.json())
  .then(response => {
    if(response.status != 0) {
      throw new Error(response.error);
    }
    return response
  })
}

export const postRegister = (firstName, lastName, email, username, password, passwordConfirmation) => {
  return fetch('/register', { method:'POST', body: JSON.stringify({user :{"first_name":firstName, "last_name":lastName, email, username, password, "password_confirmation": passwordConfirmation}}), 
    headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json'
  }})
  .then(response => response.json())
  .then(response => {
    if(response.status != 0) {
      throw {
        message: response.error,
        details: response.error_details
      };
    }
    return response
  })
}

export const getUsers = () => {
  return fetch('/users', {
    headers: {
      'Accept': 'application/json'
  }})
  .then(response => response.json())
  .then(response => {
    if(response.status != 0) {
      throw {
        message: response.error,
        details: response.error_details
      };
    }
    return response
  })
}