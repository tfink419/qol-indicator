import React from "react";
import { connect } from 'react-redux'
import { makeStyles } from '@material-ui/core/styles'
import { Typography, Paper, Input, Button, CircularProgress, Slider } from '@material-ui/core'

import { flashMessage } from '../actions/messages'
import { fileDone, fileProcessing } from '../actions/file'
import { postGroceryStoreUploadCsv } from '../fetch'
import { drawerWidth, qualityMarks } from '../common'

const useStyles = makeStyles({
  pushRight: {
    width: `calc(100% - ${drawerWidth}px)`,
    marginLeft: drawerWidth,
  },
  buttonMargin: {
    marginLeft: '2em',
  },
  slider: {
    width:'40%'
  }
});

const preventDefault = (event) => event.preventDefault();

const GroceryStoreUploadForm = ({ file, fileProcessing, fileDone, flashMessage }) => {
  const classes = useStyles();

  let [selectedFile, setSelectedFile] = React.useState(null);
  let [quality, setQuality] = React.useState(5);

  const handleFileSelect = (event) => {
    setSelectedFile(event.target.files[0])
  }

  const handleFileSubmit = (event) => {
    event.preventDefault();
    fileProcessing('Grocery Store CSV', selectedFile.name);
    postGroceryStoreUploadCsv(selectedFile, quality)
    .then((response) => {
      fileDone()
      flashMessage('info', response.message);
    })
    .catch(error => {
      setLoading(false)
      if(error.status == 400 || error.status == 403) 
      {
        flashMessage('error', error.message);
      }
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
          <Typography variant="body2">Name, Address, City, State, Zip, Latitude (Optional), Longitude (Optional), Quality (Optional)</Typography>
          <form onSubmit={handleFileSubmit}>
            <Input type="file" onChange={handleFileSelect} inputProps={{accept:'.csv'}}/>
            <Button type="submit" className={classes.buttonMargin}
              color="primary"
              variant="contained">
              Upload CSV
            </Button>
            <Typography variant="subtitle1">
              Default Quality
            </Typography>
            <Slider
                className={classes.slider}
                value={quality}
                onChange={(e, val) => setQuality(val)}
                step={1}
                min={0}
                max={10}
                valueLabelDisplay="auto"
                marks={qualityMarks}
            />
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