export const flashMessage = (severity, message) => ({
  type: 'MESSAGE_FLASH',
  severity,
  message
})

export const deleteMessage = (messageId) => ({
  type: 'MESSAGE_DELETE',
  messageId
})