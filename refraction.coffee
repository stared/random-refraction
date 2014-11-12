#
# initialization
#

SIZE = 10
N_X = 61
N_Y = 61
RAY_NO = 200
MAX_ITER = 1000
FLUCT = 0.3


refraction = for i in [0...N_X]
               for j in [0...N_Y]
                 1 + FLUCT * (1 - 2*Math.random())

## other refraction arrays
# 
# refraction = for i in [0...N_X]
#                for j in [0...N_Y]
#                  1 - 1.1 * (2*i/N_X - 1)*(2 * i/N_X - 1)
#
# refraction = for i in [0...N_X]
#                for j in [0...N_Y]
#                  if Math.abs(2*i/N_X - 1) < 0.5 then 1 else 0.3
#
# # not smooth enough
# refraction = for i in [0...N_X]
#                for j in [0...N_Y]
#                  if ((2*i/N_X - 1)*(2*i/N_X - 1) + (2*j/N_Y - 1.5)*(2*j/N_Y - 1.5)) < 0.04 then 1.5 else 1


#
# functions
#

raytrace = (x, y, vx, vy, maxIter) ->

  [vx, vy] = [vx/Math.sqrt(vx*vx + vy*vy), vy/Math.sqrt(vx*vx + vy*vy)]

  i = Math.floor(x)
  j = Math.floor(y)
  ray = [{x: x, y: y}]

  # or maybe alpha and vx, vy only post factum
  
  for k in [0...maxIter]

    # no refreaction in the first step
    if k != 0  
   
      # is it on board?
      if not ((0 <= i < N_X) and (0 <= j < N_Y))
        break
      
      refrRatio = refraction[i][j]/refraction[iPrev][jPrev]
      
      if i != iPrev        # vertical layer
        if Math.abs(vy) > Math.abs(refrRatio)  # total internal reflection
          vx = -vx
          i = iPrev
        else
          vy = vy * Math.sign(refrRatio) * Math.sqrt( (1 - vy*vy) / (refrRatio*refrRatio - vy*vy))
      else  # j != jPrev   # horizontal layer 
        if Math.abs(vx) > Math.abs(refrRatio)  # total internal reflection
          vy = -vy
          j = jPrev
        else
          vx = vx * Math.sign(refrRatio) * Math.sqrt( (1 - vx*vx) / (refrRatio*refrRatio - vx*vx))
      
      [vx, vy] = [vx/Math.sqrt(vx*vx + vy*vy), vy/Math.sqrt(vx*vx + vy*vy)]

    iPrev = i
    jPrev = j

    # closest horizontal and vertical lines 
    dx = if vx >= 0 then (i + 1 - x) else (x - i)
    dy = if vy >= 0 then (j + 1 - y) else (y - j)

    vxa = Math.abs(vx)
    vya = Math.abs(vy)

    if vya * dx < vxa * dy  # hitting left or right
      y += vy * dx / vxa
      if vx > 0
        x = i + 1
        i += 1
      else
        x = i
        i += -1
    else                    # hitting top or bottom
      x += vx * dy / vya
      if vy > 0
        y = j + 1
        j += 1
      else
        y = j
        j += -1

    ray.push({x: x, y: y})
       
  ray


# or also multy by n?
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


#
# calculating
#

rays = for alpha in [0...2*Math.PI] by 2*Math.PI/RAY_NO
         raytrace(N_X/2, N_Y/2, Math.cos(alpha), Math.sin(alpha), MAX_ITER)


#
# drawing
#

svg = d3.select('body').append('svg')
  .attr('width', N_X * SIZE)
  .attr('height', N_Y * SIZE)   


for i in [0...N_X]
    for j in [0...N_Y]
        svg.append('rect')
          .attr('class', 'tile')
          .attr('x', i * SIZE)
          .attr('y', (N_Y - j - 1) * SIZE)
          .attr('width', SIZE)
          .attr('height', SIZE)
          .style('fill', if refraction[i][j] > 0 then 'steelblue' else 'green')
          .style('opacity', Math.abs(refraction[i][j]/2))


lineFunction = d3.svg.line()
  .x((d) -> SIZE * d.x)
  .y((d) -> SIZE * (N_Y - d.y))
  .interpolate("linear")


svg.selectAll("path")
  .data(rays)
  .enter()
  .append("path")
    .attr('class', 'ray')
    .attr('d', (d) -> lineFunction(d))