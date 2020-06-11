import React from 'react';
import { connect } from 'react-redux';
import _ from 'lodash'
import { makeStyles } from '@material-ui/core/styles';
import { Button, Dialog, DialogActions, DialogContent, DialogTitle,
  TextField, FormControlLabel, Checkbox, CircularProgress } from '@material-ui/core/';

import { flashMessage } from '../actions/messages'
import { userLogin } from '../actions/user'
import { postUser } from '../fetch';

const useStyles = makeStyles({
  cancelButton: {
    color: 'green'
  }
});

const CreateUserDialog = ({open, onClose, flashMessage, userLogin}) => {
  const blankUser = {
    first_name: '',
    last_name: '',
    email: '',
    username: '',
    password:'',
    password_confirmation:'',
    is_admin:false
  };
  const classes = useStyles();
  let [loading, setLoading] = React.useState(false);
  let [user, setUser] = React.useState(blankUser);
  let [userErrors, setUserErrors] = React.useState({})
  
  const handleClose = () => {
    onClose(false);
  };

  const handleCreate = (event) => {
    event.preventDefault();
    setUserErrors({});
    setLoading(true)
    postUser(user)
    .then(response => {
      flashMessage('info', 'User created successfully')
      setLoading(false)
      onClose(true);
    })
    .catch(error => {
      setLoading(false)
      if(error.status == 401) 
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
  
  const clearForm = () => {
    if(!open) {
      setUser(blankUser)
    }
  }

  React.useEffect(clearForm, [open])

  return (
    <Dialog open={open} disableBackdropClick={true} onClose={handleClose}>
      <form onSubmit={handleCreate}>
        <DialogTitle>Create New User</DialogTitle>
        <DialogContent>
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
              margin="dense"
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
              margin="dense"
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
              margin="dense"
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
              margin="dense"
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
              label="Password"
              type="password"
              id="password"
              margin="dense"
            />
            <TextField
              value={user.password_confirmation}
              onChange={(e) => setUser({ ...user, password_confirmation:e.target.value })}
              error={Boolean(userErrors.passwordConfirmation)}
              helperText={userErrors.password_confirmation}
              variant="outlined"
              margin="normal"
              required
              fullWidth
              name="password_confirmation"
              label="Confirm Password"
              type="password"
              id="password_confirmation"
              margin="dense"
            />
            <FormControlLabel
              control={<Checkbox checked={user.is_admin} onChange={(e) => setUser({ ...user, is_admin:e.target.checked })} name="is_admin" />}
              label="Admin"
              margin="dense"
            />
          { loading && <CircularProgress className={classes.circularProgress} />}
        </DialogContent>
        <DialogActions>
          <Button onClick={handleClose} color="primary" className={classes.cancelButton} autoFocus>
            Cancel
          </Button>
          <Button type="submit" color="primary">
            Create
          </Button>
        </DialogActions>
      </form>
    </Dialog>
  );
}

const mapDispatchToProps = {
  flashMessage,
  userLogin
}

export default connect(null, mapDispatchToProps)(CreateUserDialog)