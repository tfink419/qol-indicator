import React from "react";
import { Dialog, DialogContent, DialogTitle } from '@material-ui/core/';

import LoginForm from "./LoginForm";


export default ({onClose}) => (
  <Dialog open={true} onClose={onClose}>
    <DialogTitle>Update Your Map Preferences</DialogTitle>
    <DialogContent>
      <LoginForm onClose={onClose} />
    </DialogContent>
  </Dialog>
);