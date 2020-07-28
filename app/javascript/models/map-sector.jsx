const SECTOR_SIZE = 256;
const PRECISION = Math.pow(2,19);
const MAX_VALUE = 180.0; //The highest lat or long number possible
const STEP = MAX_VALUE/PRECISION;
const STEP_INVERT = PRECISION/MAX_VALUE;
export const getSectors = (southWest, northEast, zoom) => {
  let scale = Math.pow(2,10-zoom);
  let southWestSector = {
    latSector: coordFloorToSector(southWest[0], scale),
    lngSector: coordFloorToSector(southWest[1], scale)
  };
  let northEastSector = {
    latSector: coordCeilToSector(northEast[0], scale),
    lngSector: coordCeilToSector(northEast[1], scale)
  };
  let sectors = [];
  for(let lat = southWestSector.latSector; lat <= northEastSector.latSector; lat++) {
      for(let lng = southWestSector.lngSector; lng <= northEastSector.lngSector; lng++) {
      sectors.push([lat, lng]);
    }
  }
  return sectors;
}

export const getSectorBounds = (lat_sector, lng_sector, zoom) => {
  let scale = Math.pow(2,10-zoom);
  let amount = SECTOR_SIZE*scale;
  return {
    south:(lat_sector-PRECISION/amount)*amount/STEP_INVERT,
    west:(lng_sector-PRECISION/amount)*amount/STEP_INVERT,
    north:((lat_sector+1-PRECISION/amount)*amount)/STEP_INVERT,
    east:((lng_sector+1-PRECISION/amount)*amount)/STEP_INVERT
  }
}

const coordFloorToSector = (coord, scale) => {
  let amount = SECTOR_SIZE*scale;
  return (Math.floor((coord*STEP_INVERT)/amount)*amount+PRECISION)/amount;
}

const coordCeilToSector = (coord, scale) => {
  let amount = SECTOR_SIZE*scale;
  return (Math.ceil((coord*STEP_INVERT)/amount)*amount+PRECISION)/amount
}

export const fixZoom = zoom => {
  zoom = zoom - 3;
  if(zoom > 10) {
    zoom = 10;
  }
  if(zoom < 0) {
    zoom = 0;
  }
  return zoom;
}