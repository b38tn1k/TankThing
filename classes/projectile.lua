Projectile = {}
Projectile.__index = Projectile

-- INIT PROJECTILE/MISSILE CLASS
function Projectile.create( data )
  local p = {}
  setmetatable( p, Projectile )
  parent_id, speed, lifespan, img_pth, x_pos, y_pos, rotation = data[1], data[2], data[3], data[4], data[5], data[6], data[7]
  p.x = {}
  p.y = {}
  p.age = 0
  p.life_span = lifespan
  p.sprite = {}
  p.rotation = rotation
  p.parent_id = parent_id
  p.sprite.img = love.graphics.newImage(img_pth)
  p.sprite.width = p.sprite.img:getWidth()
  p.sprite.height = p.sprite.img:getHeight()
  p.x.position = x_pos + p.sprite.width/2
  p.y.position = y_pos + p.sprite.height/2
  p.x.origin = x_pos + p.sprite.width/2
  p.y.origin = y_pos + p.sprite.height/2
  p.x.velocity = -1 * speed * math.cos( rotation + math.rad( 90 ) ) -- TODO sprites are drawn wrong hence math.rad(90) everywhere
  p.y.velocity = -1 * speed * math.sin( rotation + math.rad( 90 ) )
  return p
end

-- DRAW THE MISSILES
function Projectile:draw(shader)
  love.graphics.setShader(shader)
  love.graphics.draw( self.sprite.img, self.x.position- math.floor( self.sprite.width/2 ), self.y.position - math.floor( self.sprite.height/2 ), self.rotation, 1, 1, self.sprite.width/2, self.sprite.height/2)
  love.graphics.setShader()
end

-- UPDATE MISSILES
function Projectile:update(dt)
  self.age = self.age + dt
  self.x.position = self.x.position + self.x.velocity * dt
  self.y.position = self.y.position + self.y.velocity * dt
end

function Projectile:removable()
  return self.x.position > screen.width or self.x.position < 0 or self.y.position > screen.height or self.y.position < 0 or self.age > self.life_span
end

return Projectile
