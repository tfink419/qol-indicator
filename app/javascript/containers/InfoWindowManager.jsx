import React from "react";
import { connect } from 'react-redux'
import _ from 'lodash';

import PointDataPopup from '../components/PointDataPopup'
import GroceryStorePopup from '../components/GroceryStorePopup'

const InfoWindowManager = ({map, infoWindows}) => {
  let [currentInfoWindow, setCurrentInfoWindow] = React.useState(null);
  const pointDataPopupRef = React.useRef(null);
  const groceryStorePopupRef = React.useRef(null);

  React.useEffect(() => {
    if(infoWindows.activeInfoWindow)
    {
      if(currentInfoWindow) {
        currentInfoWindow.close();
      }
      let infoWindow = null;
      switch(infoWindows.activeInfoWindow.type) {
        case 'point-data':
          infoWindow = new window.google.maps.InfoWindow({
            content: pointDataPopupRef.current,
            position: infoWindows.activeInfoWindow.position
          });
          infoWindow.open(map);
          break;
        case 'grocery-store':
          infoWindow = new window.google.maps.InfoWindow({
            content: groceryStorePopupRef.current
          });
          infoWindow.open(map, infoWindows.activeInfoWindow.marker);
          break;
        default:
          break;
      }
      setCurrentInfoWindow(infoWindow);
    }
  }, [infoWindows])

  if(!infoWindows.activeInfoWindow)
    return <div/>;

  return (
    <React.Fragment>
      <div ref={pointDataPopupRef}>
        {infoWindows.activeInfoWindow.type == 'point-data' &&
          <PointDataPopup data={infoWindows.activeInfoWindow.data}/>
        }
      </div>
      <div ref={groceryStorePopupRef}>
        {infoWindows.activeInfoWindow.type == 'grocery-store' &&
          <GroceryStorePopup data={infoWindows.activeInfoWindow.data} isAdminPanel={isAdminPanel} /> /* onGroceryStoreChange={onGroceryStoreChange}/> */
        }
      </div>
    </React.Fragment>
)}

const mapStateToProps = state => ({
  infoWindows: state.infoWindows
})


export default connect(mapStateToProps)(InfoWindowManager)