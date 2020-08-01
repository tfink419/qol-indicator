const SECTOR_SIZE = 256;
const PRECISION = Math.pow(2,20);
const MAX_VALUE = 180.0; //The highest lat or long number possible
const STEP = MAX_VALUE/PRECISION;
const STEP_INVERT = PRECISION/MAX_VALUE;
export const getSectors = (southWest, northEast, zoom) => {
  let scale = 1 << (12-zoom);
  let numSectors = 2 << zoom;
  let southWestSector = {
    latSector: coordFloorToSector(southWest[0], scale),
    lngSector: coordFloorToSector(southWest[1], scale)%numSectors
  };
  let northEastSector = {
    latSector: coordCeilToSector(northEast[0], scale),
    lngSector: coordCeilToSector(northEast[1], scale)%numSectors
  };
  let sectors = [];
  for(let lat = southWestSector.latSector; lat <= northEastSector.latSector; lat++) {
    for(let lng = southWestSector.lngSector; lng != northEastSector.lngSector; lng = (lng+1)%numSectors) {
      sectors.push([lat, lng]);
    }
    if(zoom != 0) {
      sectors.push([lat, northEastSector.lngSector]);
    }
  }
  if(zoom != 0) {
    sectors.push([northEastSector.latSector, northEastSector.lngSector]);
  }
  return sectors;
}

export const getSectorBounds = (lat_sector, lng_sector, zoom) => {
  let scale = 1 << (12-zoom);
  let amount = SECTOR_SIZE*scale;
  let obj =  {
    south:(lat_sector-PRECISION/amount)*amount*STEP,
    west:(lng_sector-PRECISION/amount)*amount*STEP,
    north:((lat_sector+1-PRECISION/amount)*amount)*STEP,
    east:((lng_sector+1-PRECISION/amount)*amount)*STEP
  };
  if(obj.west == -180) {
    obj.west = -179.999;
  }
  if(obj.east == 180) {
    obj.east = 179.999;
  }
  return obj;
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
  zoom = zoom - 2;
  if(zoom > 12) {
    zoom = 12;
  }
  if(zoom < 0) {
    zoom = 0;
  }
  return zoom;
}