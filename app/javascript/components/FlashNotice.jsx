import React from "react";
import _ from 'lodash';
import { Snackbar } from '@material-ui/core'

import Alert from '@material-ui/lab/Alert';


export default () => {
  const [notice, setNotice] = React.useState(window.FLASH_NOTICE);
  const [error, setError] = React.useState(window.FLASH_ERROR);

  const handleCloseNotice = (event, reason) => {
    if (reason === 'clickaway') {
      return;
    }
    setNotice(null);
  };

  const handleCloseError = (event, reason) => {
    if (reason === 'clickaway') {
      return;
    }
    setError(null);
  };

  let notices = _.flatten([notice]);
  let errors = _.flatten([error]);
  

  return (
    <React.Fragment>
      <Snackbar open={Boolean(notice)} autoHideDuration={6000} onClose={handleCloseNotice}>
        <Alert severity="info" elevation={6} variant="filled" onClose={handleCloseNotice}>
          {notices.map((n, ind) => (
            <span key={ind}>
              {n}
              {(ind != notices.length-1) && <br />}
            </span>
          ))}
        </Alert>
      </Snackbar>
      <Snackbar open={Boolean(error)} autoHideDuration={10000} onClose={handleCloseError}>
        <Alert severity="error" elevation={6} variant="filled" onClose={handleCloseError}>
          {errors.map((e, ind) => (
            <React.Fragment>
              {e}
              {(ind != errors.length-1) && <br />}
            </React.Fragment>
          ))}
        </Alert>
      </Snackbar>
    </React.Fragment>
)};