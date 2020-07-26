const SECTOR_SIZE = 256;
const PRECISION = Math.pow(2,19);
const MAX_VALUE = 180.0; //The highest lat or long number possible
const STEP = MAX_VALUE/PRECISION;
const STEP_INVERT = PRECISION/MAX_VALUE;
const MAX = MAX_VALUE*PRECISION;
export const getSectors = (southWest, northEast, zoom) => {
  console.log(zoom);
  zoom = 10;
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
  zoom = 10;
  let scale = Math.pow(2,10-zoom);
  let amount = SECTOR_SIZE*scale;
  return {
    south:(lat_sector-MAX/amount)*amount/STEP_INVERT,
    west:(lng_sector-MAX/amount)*amount/STEP_INVERT,
    north:((lat_sector-MAX/amount)*amount+(SECTOR_SIZE+0.2)*scale)/STEP_INVERT,
    east:((lng_sector-MAX/amount)*amount+(SECTOR_SIZE+0.2)*scale)/STEP_INVERT
  }
}

const coordFloorToSector = (coord, scale) => {
  let amount = SECTOR_SIZE*scale;
  return (Math.floor((coord*STEP_INVERT)/amount)*amount+MAX)/amount;
}

const coordCeilToSector = (coord, scale) => {
  let amount = SECTOR_SIZE*scale;
  return (Math.ceil((coord*STEP_INVERT)/amount)*amount+MAX)/amount
}