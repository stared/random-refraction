// Generated by CoffeeScript 1.6.3
var FLUCT, LOG, MAX_ITER, N_X, N_Y, RAY_NO, SIZE, alpha, i, j, lineFunction, rays, raytrace, refraction, svg, _i, _j;

SIZE = 10;

N_X = 61;

N_Y = 61;

RAY_NO = 200;

MAX_ITER = 1000;

FLUCT = 0.3;

LOG = false;

refraction = (function() {
  var _i, _results;
  _results = [];
  for (i = _i = 0; 0 <= N_X ? _i < N_X : _i > N_X; i = 0 <= N_X ? ++_i : --_i) {
    _results.push((function() {
      var _j, _results1;
      _results1 = [];
      for (j = _j = 0; 0 <= N_Y ? _j < N_Y : _j > N_Y; j = 0 <= N_Y ? ++_j : --_j) {
        _results1.push(1 + FLUCT * (1 - 2 * Math.random()));
      }
      return _results1;
    })());
  }
  return _results;
})();

raytrace = function(x, y, vx, vy, maxIter) {
  var dx, dy, iPrev, jPrev, k, ray, refrRatio, vxa, vya, _i, _ref, _ref1;
  _ref = [vx / Math.sqrt(vx * vx + vy * vy), vy / Math.sqrt(vx * vx + vy * vy)], vx = _ref[0], vy = _ref[1];
  i = Math.floor(x);
  j = Math.floor(y);
  ray = [
    {
      x: x,
      y: y
    }
  ];
  for (k = _i = 0; 0 <= maxIter ? _i < maxIter : _i > maxIter; k = 0 <= maxIter ? ++_i : --_i) {
    if (LOG) {
      console.log("i: " + i + ", j: " + j);
    }
    if (k !== 0) {
      if (!(((0 <= i && i < N_X)) && ((0 <= j && j < N_Y)))) {
        break;
      }
      refrRatio = refraction[i][j] / refraction[iPrev][jPrev];
      if (LOG) {
        console.log("Refr ratio: " + refrRatio);
        console.log("vx: " + vx + ", vy: " + vy);
      }
      if (i !== iPrev) {
        if (Math.abs(vy) > Math.abs(refrRatio)) {
          vx = -vx;
          i = iPrev;
          if (LOG) {
            console.log("Internal!");
          }
        } else {
          vy = vy * Math.sign(refrRatio) * Math.sqrt((1 - vy * vy) / (refrRatio * refrRatio - vy * vy));
        }
      } else if (j !== jPrev) {
        if (Math.abs(vx) > Math.abs(refrRatio)) {
          vy = -vy;
          j = jPrev;
          if (LOG) {
            console.log("Internal!");
          }
        } else {
          vx = vx * Math.sign(refrRatio) * Math.sqrt((1 - vx * vx) / (refrRatio * refrRatio - vx * vx));
        }
      }
      _ref1 = [vx / Math.sqrt(vx * vx + vy * vy), vy / Math.sqrt(vx * vx + vy * vy)], vx = _ref1[0], vy = _ref1[1];
    }
    iPrev = i;
    jPrev = j;
    dx = vx >= 0 ? i + 1 - x : x - i;
    dy = vy >= 0 ? j + 1 - y : y - j;
    vxa = Math.abs(vx);
    vya = Math.abs(vy);
    if (vya * dx < vxa * dy) {
      y += vy * dx / vxa;
      if (vx > 0) {
        x = i + 1;
        i += 1;
      } else {
        x = i;
        i += -1;
      }
    } else {
      x += vx * dy / vya;
      if (vy > 0) {
        y = j + 1;
        j += 1;
      } else {
        y = j;
        j += -1;
      }
    }
    ray.push({
      x: x,
      y: y
    });
  }
  return ray;
};

rays = (function() {
  var _i, _ref, _ref1, _results;
  _results = [];
  for (alpha = _i = 0, _ref = 2 * Math.PI, _ref1 = (2 * Math.PI) / RAY_NO; _ref1 > 0 ? _i < _ref : _i > _ref; alpha = _i += _ref1) {
    _results.push(raytrace(N_X / 2, N_Y / 2, Math.cos(alpha), Math.sin(alpha), MAX_ITER));
  }
  return _results;
})();

svg = d3.select('body').append('svg').attr('width', N_X * SIZE).attr('height', N_Y * SIZE);

for (i = _i = 0; 0 <= N_X ? _i < N_X : _i > N_X; i = 0 <= N_X ? ++_i : --_i) {
  for (j = _j = 0; 0 <= N_Y ? _j < N_Y : _j > N_Y; j = 0 <= N_Y ? ++_j : --_j) {
    svg.append('rect').attr('class', 'tile').attr('x', i * SIZE).attr('y', (N_Y - j - 1) * SIZE).attr('width', SIZE).attr('height', SIZE).style('fill', refraction[i][j] > 0 ? 'steelblue' : 'green').style('opacity', Math.abs(refraction[i][j] / 2));
  }
}

lineFunction = d3.svg.line().x(function(d) {
  return SIZE * d.x;
}).y(function(d) {
  return SIZE * (N_Y - d.y);
}).interpolate("linear");

svg.selectAll("path").data(rays).enter().append("path").attr('class', 'ray').attr('d', function(d) {
  return lineFunction(d);
});
