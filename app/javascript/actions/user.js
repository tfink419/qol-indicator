export const userLogin = (user) => ({
  type: 'USER_LOGIN',
  user
})

export const userLogout = () => ({
  type: 'USER_LOGOUT'
})