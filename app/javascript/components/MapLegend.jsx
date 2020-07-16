import React from "react";
import { Card, CardContent, Typography, makeStyles } from '@material-ui/core'

const useStyles = makeStyles({
  legendLabels: {
    display:'inline',
    position:'absolute'
  },
  legendLabel: {
    marginBottom:'1.2em'
  },
  gradient: {
    width:'25px',
    height:'150px'
  },
  card: {
    width:"20ex"
  },
  fixCardPadding: {
    paddingBottom:'16px !important'
  }
});

export default ({map}) => {
  const classes = useStyles();
  const gradient = React.useRef(null);
  const component = React.useRef(null);
  React.useEffect(() => {
    if(!map) return;
    let ctx = gradient.current.getContext("2d");
    let grd = ctx.createLinearGradient(0, 0, 0, 150);
    
    grd.addColorStop(0, "#00FFFF");
    grd.addColorStop(0.2, "#00FF00");
    grd.addColorStop(0.5, "#FFFF00");
    grd.addColorStop(0.8, "#FFA500");
    grd.addColorStop(1, "#FF0000");

    ctx.fillStyle = grd;
    ctx.fillRect(0, 0, 100, 150);

    map.controls[window.google.maps.ControlPosition.RIGHT_TOP].push(component.current);
  }, [map]);
  return (
  <Card ref={component} classes={{root:classes.card}}>
    <CardContent classes={{root:classes.fixCardPadding}}>
      <canvas ref={gradient} className={classes.gradient}/>
      <div className={classes.legendLabels}>
        <Typography classes={{root:classes.legendLabel}}>
          Great
        </Typography>
        <Typography classes={{root:classes.legendLabel}}>
          Good
        </Typography>
        <Typography classes={{root:classes.legendLabel}}>
          Adequate
        </Typography>
        <Typography>
          Bad
        </Typography>
      </div>
    </CardContent>
  </Card>
)};