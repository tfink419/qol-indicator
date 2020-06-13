import React from 'react';
import { connect } from 'react-redux';
import _ from 'lodash'
import { makeStyles } from '@material-ui/core/styles';
import { Button, Dialog, DialogActions, DialogContent, DialogTitle, ExpansionPanel, ExpansionPanelSummary,
  Typography, TextField, FormControlLabel, Checkbox, CircularProgress } from '@material-ui/core/';

import { flashMessage } from '../actions/messages'
import { userLogin } from '../actions/user'
import { getUserSelf, putUserSelf } from '../fetch';

const useStyles = makeStyles({
  cancelButton: {
    color: 'green'
  }
});

const UpdateUserSelfDialog = ({onClose, flashMessage, userLogin}) => {
  const blankUser = {
    first_name: '',
    last_name: '',
    email: '',
    username: '',
    password:'',
    prev_password:'',
    password_confirmation:''
  };
  const classes = useStyles();
  let [loading, setLoading] = React.useState(false);
  let [user, setUser] = React.useState(blankUser);
  let [userErrors, setUserErrors] = React.useState({})

  const loadUser = () => {
    if(open) {
      setLoading(true);
      setUser(blankUser);
      setUserErrors({});
      
      getUserSelf().then(response => {
        setLoading(false);
        setUser({ ...blankUser, ...response.user})
      })
    }
  }
  
  const handleClose = () => {
    onClose(false);
  };

  const handleUpdate = () => {
    setUserErrors({});
    setLoading(true)
    putUserSelf(user)
    .then(response => {
      setLoading(false)
      onClose(true);
      flashMessage('info', response.message);
      
      if(userId == currentUserId) {
        userLogin(response.user)
      }
    })
    .catch(error => {
      setLoading(false)
      if(error.status == 401) 
      {
        flashMessage('error', error.message);
        console.log(error.details)
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

  React.useEffect(loadUser, [])

  return (
    <form onSubmit={handleUpdate}>
      <Dialog open={true} disableBackdropClick={true} onClose={handleClose}>
        <DialogTitle>Update Your Profile</DialogTitle>
        <DialogContent>
          <form onSubmit={handleUpdate}>
            <TextField
              value={user.first_name}
              onChange={(e) => setUser({ ...user, first_name:e.target.value })}
              error={Boolean(userErrors.first_name)}
              helperText={userErrors.first_name}
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
              error={Boolean(userErrors.last_name)}
              helperText={userErrors.last_name}
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
            <ExpansionPanel>
              <ExpansionPanelSummary>
                <Typography>Update Password</Typography>
              </ExpansionPanelSummary>
              <TextField
                value={user.prev_password}
                onChange={(e) => setUser({ ...user, prev_password:e.target.value })}
                error={Boolean(userErrors.prev_password)}
                helperText={userErrors.prev_password}
                variant="outlined"
                margin="normal"
                required
                fullWidth
                name="prev_password"
                label="Old Password"
                type="password"
                id="prev-password"
              />
              <TextField
                value={user.password}
                onChange={(e) => setUser({ ...user, password:e.target.value })}
                error={Boolean(userErrors.password)}
                helperText={userErrors.password}
                variant="outlined"
                margin="normal"
                required
                fullWidth
                name="password"
                label="New Password"
                type="password"
                id="password"
              />
              <TextField
                value={user.password_confirmation}
                onChange={(e) => setUser({ ...user, password_confirmation:e.target.value })}
                error={Boolean(userErrors.password_confirmation)}
                helperText={userErrors.password_confirmation}
                variant="outlined"
                margin="normal"
                required
                fullWidth
                name="password_confirmation"
                label="Confirm New Password"
                type="password"
                id="password_confirmation"
              />
            </ExpansionPanel>
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

const mapDispatchToProps = {
  flashMessage,
  userLogin
}

export default connect(null, mapDispatchToProps)(UpdateUserSelfDialog)