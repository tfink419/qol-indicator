class ParkActivitiesMapPoint < MapPoint
  TRANSIT_TYPE_MAP = [
    [nil, nil], # shouldn't be used
    ['walking', 6],
    ['walking', 12],
    ['walking', 18],
    ['cycling', 6],
    ['cycling', 12],
    ['cycling', 18]
  ]
  LOW = 0
  HIGH = 12.5
  SCALE = 42000000
  SHORT_NAME = 'park-activities'
end
