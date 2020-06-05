function getMeta(metaName) {
  const metas = document.getElementsByTagName('meta');

  for (let i = 0; i < metas.length; i++) {
    if (metas[i].getAttribute('name') === metaName) {
      return metas[i].getAttribute('content');
    }
  }

  return null;
}

export const getCsrf = () => getMeta('csrf-token')

export const postLogin = (username, password) => {
  return fetch('/login', { method:'POST', body: JSON.stringify({username, password, authenticity_token: getCsrf()}), 
    headers: {
      'Content-Type': 'application/json'
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
  return fetch('/register', { method:'POST', body: JSON.stringify({user :{"first_name":firstName, "last_name":lastName, email, username, password, "password_confirmation": passwordConfirmation}, authenticity_token: getCsrf()}), 
    headers: {
      'Content-Type': 'application/json'
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

export const getLogout = () => {
  return fetch('/logout')
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