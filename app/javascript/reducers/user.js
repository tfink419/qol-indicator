const user = (state = null, action) => {
  switch (action.type) {
    case 'USER_LOGIN':
      console.log(action.user)
      return {
        ...action.user
      }
    case 'USER_LOGOUT':
      return {}
    default:
      return state
  }
}

export default user