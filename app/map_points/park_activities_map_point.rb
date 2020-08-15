class ParkActivitiesMapPoint < MapPoint
  TRANSIT_TYPE_MAP = [
    [nil, nil], # shouldn't be used
    ['walking', 8],
    ['walking', 16],
    ['walking', 24],
    ['cycling', 8],
    ['cycling', 16],
    ['cycling', 24]
  ]
  LOW = 0
  HIGH = 12.5
  SCALE = 42000000
  SHORT_NAME = 'park-activities'
end
