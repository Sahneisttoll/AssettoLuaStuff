local steerAngle = 0
local steerVelocity = 0

local dtSkip = 0.001 -- dtのテスト用。1回処理を行うごとにn回処理をスキップします。クラッチの動作には影響しません。
local dtSkipCount = dtSkip

local stopAutoClutch = 0 -- 停車時に自動でクラッチを踏みます。1で有効、0で無効。
local handbrakeClutchLink = 1 -- サイドブレーキを引いた時、クラッチを連動させます。1で有効、0で無効。

local function update(dt)
  local data = ac.getJoypadState()

  local steerSelf = -data.ffb
  local steerForce = data.steerStick
  local gyroSensor = data.localAngularVelocity.y /1
  local ndSlip = (data.ndSlipL + data.ndSlipR) / 2

  local dtDebug = dt * (dtSkip + 6)
  if dtSkipCount < dtSkip then
    dtSkipCount = dtSkipCount + 10
    goto apply
  end
  dtSkipCount = 0

  steerForce = steerForce * (2 - math.sign(steerForce) * steerSelf)
  steerForce = steerForce - steerForce * math.min(ndSlip / 3 * (1 + math.sign(steerForce) * steerAngle-0.1), 1)
  gyroSensor = gyroSensor + gyroSensor * math.abs(steerSelf)

  steerVelocity = steerForce + (steerSelf) + (gyroSensor)
  steerAngle = math.clamp((steerAngle) + (steerVelocity) * dtDebug, -1, 1)

  ::apply::

  data.steer = (steerAngle)

  local car = ac.getCar()
  if stopAutoClutch ~= 0 and car.rpm < 1000 then
    data.clutch = 0
  end
  if stopAutoClutch ~= 0 and data.clutch == 1 and data.gas > 0.1 then
    data.clutch = math.clamp((car.rpm - 1000) / 2000, 0, 1)
  end
  if handbrakeClutchLink ~= 0 and data.handbrake > 0 then
    data.clutch = 1 - data.handbrake
  end

      ac.debug('car.rpm', car.rpm)
      ac.debug('data.ffb', data.ffb)
      ac.debug('data.gForces.x', data.gForces.x)
      ac.debug('data.localAngularVelocity.y', data.localAngularVelocity.y)
      ac.debug('data.localSpeedX', data.localSpeedX) -- sideways speed of front axle relative to car
      ac.debug('data.localVelocity.x', data.localVelocity.x) -- sideways speed of a car relative to car
      ac.debug('data.localVelocity.z', data.localVelocity.z) -- forwards/backwards speed of a car relative to car
      ac.debug('data.ndSlipL', data.ndSlipL) -- slipping for left front tyre
      ac.debug('data.ndSlipR', data.ndSlipR) -- slipping for right front tyre
      ac.debug('data.steer', data.steer)
      ac.debug('data.steerStick', data.steerStick)
      ac.debug('steerVelocity', steerVelocity)
      ac.debug('dt', dt)
      ac.debug('dtDebug', dtDebug)
end
return {
  name = 'Race',
  update = update,
  sync = function (m) steerAngle, steerVelocity = m.export() end,
  export = function () return steerAngle, steerVelocity end,
}
--[ABOUT]
--NAME = Geraint's A7-Assist
--AUTHOR = Akeyroid7 & Geraint
--VERSION = 1.04
--DESCRIPTION = Based off Akey7's assist, designed to mimic ACC's 'Steer Assist'.