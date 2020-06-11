import React from "react";
import { connect } from 'react-redux'
import { makeStyles } from '@material-ui/core/styles'
import { Typography, Paper, Input, Button, CircularProgress } from '@material-ui/core'

import { flashMessage } from '../actions/messages'
import { fileDone, fileProcessing } from '../actions/file'
import { postGroceryStoreUploadCsv } from '../fetch'
import { drawerWidth } from '../common'

const useStyles = makeStyles({
  pushRight: {
    width: `calc(100% - ${drawerWidth}px)`,
    marginLeft: drawerWidth,
  },
  buttonMargin: {
    marginLeft: '2em',
  }
});

const preventDefault = (event) => event.preventDefault();

const GroceryStoreUploadForm = ({ file, fileProcessing, fileDone, flashMessage }) => {
  const classes = useStyles();

  let [selectedFile, setSelectedFile] = React.useState(null);

  const handleFileSelect = (event) => {
    setSelectedFile(event.target.files[0])
  }

  const handleFileSubmit = (event) => {
    event.preventDefault();
    fileProcessing('Grocery Store CSV', selectedFile.name);
    postGroceryStoreUploadCsv(selectedFile)
    .then((response) => {
      fileDone()
      flashMessage('info', response.message);
    })
  }

  return (
    <Paper className={classes.pushRight}>
      <Typography variant="h3">Upload CSV</Typography>
      {file.type ?
        <React.Fragment>
          <Typography variant="h5">
            Currently awaiting {file.type} file '{file.name}'
          </Typography>
          <CircularProgress />
        </React.Fragment>
        :
        <React.Fragment>
          <Typography variant="body1">Please Upload a CSV file containing the following fields with header names:</Typography>
          <Typography variant="body2">Name, Address, City, State, Zip, Latitude (Optional), Longitude (Optional)</Typography>
          <form onSubmit={handleFileSubmit}>
            <Input type="file" onChange={handleFileSelect} inputProps={{accept:'.csv'}}/>
            <Button type="submit" className={classes.buttonMargin}
              color="primary"
              variant="contained">
              Upload CSV
            </Button>
          </form>
        </React.Fragment>
      }
    </Paper>
  )
}

const mapStateToProps = state => ({
  file: state.file
})

const mapDispatchToProps = {
  flashMessage,
  fileProcessing,
  fileDone
}

export default connect(mapStateToProps, mapDispatchToProps)(GroceryStoreUploadForm)