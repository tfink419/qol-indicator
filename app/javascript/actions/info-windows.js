export const infoWindowOpen = (infoWindowType, id, position, marker) => ({
  type:'INFO_WINDOW_OPEN',
  infoWindowType,
  id,
  position,
  marker
})

export const infoWindowLoaded = (id, data) => ({
  type:'INFO_WINDOW_LOADED',
  id,
  data
})