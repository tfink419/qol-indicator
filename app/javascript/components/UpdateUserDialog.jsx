import React from 'react';
import { connect } from 'react-redux';
import _ from 'lodash'
import { makeStyles } from '@material-ui/core/styles';
import { Button, Dialog, DialogActions, DialogContent, DialogTitle,
  TextField, FormControlLabel, Checkbox, CircularProgress } from '@material-ui/core/';

import { flashMessage } from '../actions/messages'
import { userLogin } from '../actions/user'
import { getAdminUser, putAdminUser } from '../fetch';

const useStyles = makeStyles({
  cancelButton: {
    color: 'green'
  }
});

const UpdateUserDialog = ({currentUserId, open, userId, onClose, flashMessage, userLogin}) => {
  const blankUser = {
    first_name: '',
    last_name: '',
    email: '',
    username: '',
    is_admin:false
  };
  const classes = useStyles();
  let [loading, setLoading] = React.useState(false);
  let [user, setUser] = React.useState(blankUser);
  let [originalUsername, setOriginalUsername] = React.useState('Username');
  let [userErrors, setUserErrors] = React.useState({})

  const loadUser = () => {
    if(open) {
      setLoading(true);
      setUser(blankUser);
      setOriginalUsername('Username');
      setUserErrors({});
      
      getAdminUser(userId).then(response => {
        setLoading(false);
        setUser(response.user)
        setOriginalUsername(response.user.username);
      })
    }
  }
  
  const handleClose = () => {
    onClose(false);
  };

  const handleUpdate = () => {
    setUserErrors({});
    setLoading(true)
    putAdminUser(user)
    .then(response => {
      setLoading(false)
      onClose(true);
      
      if(userId == currentUserId) {
        userLogin(response.user)
      }
    })
    .catch(error => {
      setLoading(false)
      if(error.status == 400) 
      {
        flashMessage('error', error.message);
        if(error.details) {
          setUserErrors(_.mapValues(error.details, (messages, key) => {
            return messages.map(message => _.startCase(key) + " " +message).join("\n")
          }));
        }
      }
      if(error.status == 403) 
      {
        flashMessage('error', error.message);
      }
    })
  }

  React.useEffect(loadUser, [open])

  return (
    <form onSubmit={handleUpdate}>
      <Dialog open={open} disableBackdropClick={true} onClose={handleClose}>
        <DialogTitle>Update User '{originalUsername}'</DialogTitle>
        <DialogContent>
          <form onSubmit={handleUpdate}>
            <TextField
              value={user.first_name}
              onChange={(e) => setUser({ ...user, first_name:e.target.value })}
              error={Boolean(userErrors.firstName)}
              helperText={userErrors.firstName}
              variant="outlined"
              margin="normal"
              fullWidth
              id="first_name"
              label="First Name"
              name="first_name"
              autoComplete="first_name"
              autoFocus
            />
            <TextField
              value={user.last_name}
              onChange={(e) => setUser({ ...user, last_name:e.target.value })}
              error={Boolean(userErrors.lastName)}
              helperText={userErrors.lastName}
              variant="outlined"
              margin="normal"
              fullWidth
              id="last_name"
              label="Last Name"
              name="last_name"
            />
            <TextField
              value={user.username}
              onChange={(e) => setUser({ ...user, username:e.target.value })}
              error={Boolean(userErrors.username)}
              helperText={userErrors.username}
              variant="outlined"
              margin="normal"
              required
              fullWidth
              id="username"
              label="Username"
              name="username"
            />
            <TextField
              value={user.email}
              onChange={(e) => setUser({ ...user, email:e.target.value })}
              error={Boolean(userErrors.email)}
              helperText={userErrors.email}
              variant="outlined"
              margin="normal"
              required
              fullWidth
              id="email"
              label="Email"
              name="email"
            />
            <FormControlLabel
              control={<Checkbox checked={user.is_admin} onChange={(e) => setUser({ ...user, is_admin:e.target.checked })} name="is_admin" />}
              label="Admin"
            />
          </form>
          { loading && <CircularProgress className={classes.circularProgress} />}
        </DialogContent>
        <DialogActions>
          <Button onClick={handleClose} color="primary" className={classes.cancelButton} autoFocus>
            Cancel
          </Button>
          <Button onClick={handleUpdate} color="primary">
            Update
          </Button>
        </DialogActions>
      </Dialog>
    </form>
  );
}

const mapStateToProps = (state) => ({
  currentUserId:state.user.id
});

const mapDispatchToProps = {
  flashMessage,
  userLogin
}

export default connect(mapStateToProps, mapDispatchToProps)(UpdateUserDialog)