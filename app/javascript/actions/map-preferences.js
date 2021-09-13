export const updateMapPreferences = (mapPreferences) => ({
  type:'UPDATE_MAP_PREFERENCES',
  mapPreferences
})

export const tempUpdateMapPreferences = (mapPreferences) => ({
  type:'TEMP_UPDATE_MAP_PREFERENCES',
  mapPreferences
})

export const resetMapPreferences = () => ({
  type:'RESET_MAP_PREFERENCES'
})

export const setDefaultMapPreferences = () => ({
  type:'SET_DEFAULT_MAP_PREFERENCES'
})