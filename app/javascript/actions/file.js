export const fileProcessing = (fileType, fileName) => ({
  type: 'FILE_PROCESSING',
  fileType,
  fileName
})

export const fileDone = () => ({
  type: 'FILE_DONE'
})