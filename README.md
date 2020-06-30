# myQOLi
## My Quality of Life Indicator

### About
This site shows you the quality of life in a given area

### Why
This site was created as a demo for Snapdocs inc. It is based on a need that I had wanted from when researching to live in Denver, moving all the way from Florida and only knowing 2 people in the area. It's difficult to know how your life will be in an area without doing a lot of research and being aware of the factors that you would consider important.


### Future Goals
- Incorporate other types of quality indicators (e.g. access to transit)
- Use google maps or other, higher quality map and geocode API
- Use isochrone instead of heatmap
  - Save API calls
  - Merge and difference isochrone polygons
  - Decide how to handle quality of stores for isochrone (maybe a more advanced calculation converts isochrone data into quality maps, then inverts the quality data into heatmaps of quality points at regular intervals)
- It's own domain and ad's 🤔
- Understand what helpers are and use them if needed
- Tests would be good

### How to compile assets for production
`RAILS_ENV=development NODE_ENV=production bundle exec rails assets:precompile; bundle exex rails assets:fix-precompile`
