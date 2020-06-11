const file = (state = {}, action) => {
  switch (action.type) {
    case 'FILE_PROCESSING':
      return {
        type: action.fileType,
        name: action.fileName
      }
    case 'FILE_DONE':
      return {}
    default:
      return state
  }
}

export default file