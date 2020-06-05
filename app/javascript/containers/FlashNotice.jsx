import React from "react";
import { connect } from 'react-redux'
import _ from 'lodash';
import { Snackbar } from '@material-ui/core'

import { deleteMessage } from '../actions/messages'

import Alert from '@material-ui/lab/Alert';


const FlashNotice = ({messages, deleteMessage}) => {
  const message = messages[0];
  return (
    <React.Fragment>
      { message && 
        <Snackbar key={message[0]} open={true} autoHideDuration={6000} onClose={() => deleteMessage(message[0])}>
          <Alert severity={message[1]} onClose={() => deleteMessage(message[0])}>
            {messages[0][2]}
          </Alert>
        </Snackbar>
      }
    </React.Fragment>
)};

const mapStateToProps = state => ({
  messages: state.messages
})

const mapDispatchToProps = {
  deleteMessage
}

export default connect(
  mapStateToProps,
  mapDispatchToProps
)(FlashNotice)