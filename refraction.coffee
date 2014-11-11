SIZE = 10
N_X = 61
N_Y = 61
RAY_NO = 200
MAX_ITER = 1000
FLUCT = 0.1
LOG = false

svg = d3.select('body').append('svg')
  .attr('width', N_X * SIZE)
  .attr('height', N_Y * SIZE)   

refraction = for i in [0...N_X]
               for j in [0...N_Y]
                 1 + FLUCT * (1 - 2*Math.random())

for i in [0...N_X]
    for j in [0...N_Y]
        svg.append('rect')
          .attr('x', i * SIZE)
          .attr('y', (N_Y - j - 1) * SIZE)
          .attr('width', SIZE)
          .attr('height', SIZE)
          .style('fill', 'steelblue')
        #  .style('stroke-width', 0.5)
        #  .style('stroke', 'black')
          .style('opacity', refraction[i][j]/2)

            
# illumination = (rays) -> 
#   res = for i in [1..n_X]
#           for j in [1..N_Y]
#             0
#   for ray in rays
#     [pos0, poss...] = ray
#     xPrev = pos0.x
#     yPrev = pos0.y
#     for pos in poss
#       x = pos.x
#       y = pos.y
#       dist = Math.sqrt((x-xPrev)**2 + (y-yPrev)**2)
#       i = Math.floor((x + xPrev)/2)
#       j = Math.floor((y + yPrev)/2)
#       res[i][j] += dist
#       xPrev = x
#       yPrev = y
#   res        

raytrace = (x, y, vx, vy, maxIter) ->

  [vx, vy] = [vx/Math.sqrt(vx*vx + vy*vy), vy/Math.sqrt(vx*vx + vy*vy)]

  i = Math.floor(x)
  j = Math.floor(y)
  res = [{x: x, y: y}]
  
  for k in [0...maxIter]
    
    if LOG then console.log("i: #{i}, j: #{j}")

    if k != 0
   
        if not ((0 <= i < N_X) and (0 <= j < N_Y))
            break
         
        refrRatio = refraction[i][j]/refraction[iPrev][jPrev]
        
        if LOG
          console.log("Refr ratio: #{refrRatio}")
          console.log("vx: #{vx}, vy: #{vy}")
        
        if i != iPrev
          if Math.abs(vy) > refrRatio
            vx = -vx
            i = iPrev
            if LOG then console.log("Internal!")
          else
            vy = vy * Math.sqrt( (1 - vy*vy) / (refrRatio*refrRatio - vy*vy))
        else if j != jPrev
          if Math.abs(vx) > refrRatio
            vy = -vy
            j = jPrev
            if LOG then console.log("Internal!")
          else
            vx = vx * Math.sqrt( (1 - vx*vx) / (refrRatio*refrRatio - vx*vx))
        
        [vx, vy] = [vx/Math.sqrt(vx*vx + vy*vy), vy/Math.sqrt(vx*vx + vy*vy)]

    iPrev = i
    jPrev = j
        
    if vx >= 0 and vy >= 0
      if vy*(i + 1 - x) < vx*(j + 1 - y)
         y = y + vy*(i + 1 - x)/vx
         x = i + 1
         i += 1
      else
         x = x + vx*(j + 1 - y)/vy
         y = j + 1
         j += 1
      res.push({x: x, y: y})
      continue
    else if vx >= 0 and vy < 0
      if -vy*(i+1-x) < vx*(y-j)
         y = y + vy*(i+1-x)/vx
         x = i + 1
         i += 1
      else
         x = x - vx*(y-j)/vy
         y = j
         j += -1
      res.push({x: x, y: y})
      continue
    else if vx < 0 and vy >= 0
      if vy*(x-i) < -vx*(j+1-y)
         y = y - vy*(x-i)/vx
         x = i
         i += -1
      else
         x = x + vx*(j+1-y)/vy
         y = j + 1
         j += 1
      res.push({x: x, y: y})
      continue
    else if vx < 0 and vy < 0
      if -vy*(x-i) < -vx*(y-j)
         y = y - vy*(x-i)/vx
         x = i
         i += -1
      else
         x = x - vx*(y-j)/vy
         y = j
         j += -1
      res.push({x: x, y: y})
      continue
  res

lineFunction = d3.svg.line()
  .x((d) -> SIZE * d.x)
  .y((d) -> SIZE * (N_Y - d.y))
  .interpolate("linear");
        

rays = (raytrace(N_X/2, N_Y/2, Math.cos(alpha), Math.sin(alpha), MAX_ITER) for alpha in [0...(2*Math.PI)] by (2*Math.PI)/RAY_NO)


svg.selectAll("path")
  .data(rays)
  .enter()
  .append("path")
    .attr('class', 'ray')
    .attr('d', (d) -> lineFunction(d))