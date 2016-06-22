Projectile = {}
Projectile.__index = Projectile


-- INIT PROJECTILE/MISSILE CLASS
function Projectile.create( data )
  local p = {}
  setmetatable( p, Projectile )
  speed, img_pth, x_pos, y_pos, rotation = data[1], data[2], data[3], data[4], data[5]

  p.x = {}
  p.y = {}
  p.sprite = {}
  p.arm_radius = 28
  p.arm_radius = p.arm_radius * p.arm_radius
  p.armed = false
  p.x.position, p.y.position = x_pos, y_pos
  p.x.origin, p.y.origin = x_pos, y_pos
  p.rotation = rotation
  p.sprite.img = love.graphics.newImage(img_pth)
  p.sprite.width = p.sprite.img:getWidth()
  p.sprite.height = p.sprite.img:getHeight()
  p.x.velocity = -1 * speed * math.cos( rotation + math.rad( 90 ) ) -- TODO sprites are drawn wrong hence math.rad(90) everywhere
  p.y.velocity = -1 * speed * math.sin( rotation + math.rad( 90 ) )
  return p
end

-- DRAW THE MISSILES
function Projectile:draw()
  love.graphics.draw( self.sprite.img, self.x.position- math.floor( self.sprite.width/2 ), self.y.position - math.floor( self.sprite.height/2 ), self.rotation, 1, 1, self.sprite.width/2, self.sprite.height/2)
end

-- UPDATE MISSILES
function Projectile:update(dt)
  self.x.position = self.x.position + self.x.velocity * dt
  self.y.position = self.y.position + self.y.velocity * dt
  if not self.armed then
    x_displacement = self.x.position - self.x.origin
    y_displacement = (self.y.position - self.y.origin) * (self.y.position - self.y.origin)
    if  x_displacement * x_displacement + y_displacement * y_displacement > self.arm_radius then
      self.armed = true
    end
  end
end

return Projectile
