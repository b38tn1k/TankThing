Projectile = {}
Projectile.__index = Projectile


-- INIT PROJECTILE/MISSILE CLASS
function Projectile.create( speed, img_pth, x_pos, y_pos, rotation )
  local p = {}
  setmetatable( p, Projectile )
  p.x = {}
  p.y = {}
  p.sprite = {}
  p.x.position, p.y.position = x_pos, y_pos
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
end

return Projectile
