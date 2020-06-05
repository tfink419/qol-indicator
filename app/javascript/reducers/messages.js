import _ from 'lodash'

let currentMessageId = 0;

const user = (state = [], action) => {
  switch (action.type) {
    case 'MESSAGE_FLASH':
      if(_.isArray(action.message)) {
        return [
          ...state,
          ...action.message.map((message) => [currentMessageId++, action.severity, message])
        ]
      }
      return [
        ...state,
        [currentMessageId++, action.severity, action.message]
      ]
    case 'MESSAGE_DELETE':
      return _.filter(state, message => message[0] != action.messageId)
    default:
      return state
  }
}

export default user