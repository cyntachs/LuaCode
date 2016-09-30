

local PID = {}

local PID_Settings = {
  Altitude = {
    Current = I:GetConstructPosition().y,
    Aim = 100,
    kp = 0.5, ki = 0.08, kd = 0.2,
    Interval = 1
  },
  
  Roll = {
    Current = 0, Aim = 180,
    kp = 0.08, ki = 0.08, kd = 0.08,
    Interval = 1 
  },
  
  Pitch = {
    Current = 0, Aim = 0,
    kp = 0.05, ki = 0.05, kd = 0.05,
    Interval = 1
  },
  
  Yaw = {
    Current = 0, Aim = 0,
    kp = 0.05, ki = 0, kd = 0,
    Interval = 1
  }
}

local function newPID()
  local pid = {}
  pid.State = {
    Aim = 0, Integral = 0,
    PrevInput = 0, PrevOutput = 0,
    kp = 0, ki = 0, kd = 0,
    Interval = 1, PrevTime = 0,
    --NewMin = 0, NewMax = 0
  }
  function pid.Init(Current, Aim, kp, ki, kd, Interval)
    if type(Current) == 'table' then
      pid.State.PrevInput = Current[Current]
      pid.State.Integral = Current[Current]
      pid.State.Aim = Current[Aim]
      pid.State.kp = Current[kp]
      pid.State.ki = Current[ki]
      pid.State.kd = Current[kd]
      pid.State.Interval = Current[Interval]
    else
      pid.State.PrevInput = Current
      pid.State.Integral = Current
      pid.State.Aim = Aim
      pid.State.kp = kp
      pid.State.ki = ki
      pid.State.kd = kd
      pid.State.Interval = Interval
    end
  end
  function pid.SetAimValue(v) pid.State.Aim = v end
  function pid.SetInterval(int)
    local IntRatio = int / pid.State.Interval
    pid.State.Interval = int
    pid.State.ki = pid.State.ki * IntRatio
    pid.State.kd = pid.State.kd / IntRatio
  end
  function pid.TunePID(p,i,d)
    if (p < 0) or (i < 0) or (d < 0) then return end
    pid.State.kp = p
    pid.State.ki = i * pid.State.Interval
    pid.State.kd = d / pid.State.Interval
  end
  function pid.Update(CurTime,Current)
    local Now = CurTime--I:GetTimeSinceSpawn()
    local DeltaTime = Now - pid.State.PrevTime
    if DeltaTime >= pid.State.Interval then
      local s = pid.State
      local error = s.Aim - Current
      s.Integral = s.Integral + (s.ki * error)
      --if s.Integral > s.NewMax then s.Integral = s.NewMax
      --elseif s.Integral < s.NewMin then s.Integral = s.NewMin end
      local Deriv = (Current - s.PrevInput)
      local p,i,d = (s.kp * error), (s.Integral), (s.kd * Deriv)
      local New = p + i + d
      --if New > s.NewMax then New = s.NewMax
      --elseif New < s.NewMin then New = s.NewMin end
      s.PrevInput = Current
      s.PrevOutput = New
      s.PrevTime = Now
      pid.State = s
      return New
    end
  end
  function pid.GetNewValue() return pid.State.PrevOutput end
  return pid
end

local function CreatePIDs()
  for k,v in pairs(PID_Settings) do
    PID[k] = newPID()
    PID[k].Init(v)
  end
end