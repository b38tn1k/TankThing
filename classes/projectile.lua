Projectile = {}
Projectile.__index = Projectile

-- INIT PROJECTILE/MISSILE CLASS
function Projectile.create( data )
  local p = {}
  setmetatable( p, Projectile )
  parent_id, parent_team, x_bound, y_bound, speed, lifespan, img_pth, x_pos, y_pos, rotation = data[1], data[2], data[3], data[4], data[5], data[6], data[7], data[8], data[9], data[10]
  p.x = {}
  p.y = {}
  p.x_bound = x_bound
  p.y_bound = y_bound
  p.age = 0
  p.life_span = lifespan
  p.sprite = {}
  p.rotation = rotation
  p.parent_id = parent_id
  p.parent_team = parent_team
  p.sprite.img = lg.newImage(img_pth)
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
function Projectile:draw(offset)
  lg.draw(self.sprite.img, self.x.position- math.floor( self.sprite.width/2 ) + offset.x, self.y.position - math.floor( self.sprite.height/2 ) + offset.y, self.rotation, 1, 1, self.sprite.width/2, self.sprite.height/2)
end

-- UPDATE MISSILES
function Projectile:update(dt)
  self.age = self.age + dt
  self.x.position = self.x.position + self.x.velocity * dt
  self.y.position = self.y.position + self.y.velocity * dt
end

function Projectile:removable(screen)
  return self.x.position > self.x_bound or self.x.position < 0 or self.y.position > self.y_bound or self.y.position < 0 or self.age > self.life_span
end

return Projectile
