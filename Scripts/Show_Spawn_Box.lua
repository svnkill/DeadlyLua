--<<Show spawn boxes blocking areas>>
require("libs.Utils")
require("libs.ScriptConfig")

local config = ScriptConfig.new()
config:SetParameter("Hotkey", "L", config.TYPE_HOTKEY)
config:Load()

local toggleKey = config.Hotkey

local check = false
local play = false

local spots = {
--radian
{2240,-4288,3776,-5312}, -- easy
{2688,-2944, 3776,-4096,1}, -- medium near rune
{1088,-3200,2304,-4544}, -- hard near rune
{-3520,768,-2560,-256,2}, -- ancient
{-1026,-2368,62,-3451}, -- medium camp
{-1728,-3522,-706,-4478,1}, -- hard camp

--dire
{-3459,4928,-2688,3968,1}, -- easy
{-5056, 4352,-3712, 3264}, -- hard pull
{3390,-105,4739,-1102}, -- ancient
{-1921,3138,-964,2308}, -- camp by rune
{-832,4098,-3,3203,1}, -- medium camp
{447,3778,1659,2822,1} -- hard camp by mid

}
local eff = {}
local eff1 = {}
local eff2 = {}
local eff3 = {}
local eff4 = {}

local effec = "candle_flame_medium" -- ambient_gizmo_model

--[[

	a----b
	|	 |
	|	 |
	d----c
	
	a 2240;-4288
	c 3776;-5312

]]

function Key(msg,code)

	if msg ~= KEY_UP or code ~= toggleKey or client.chat or client.console then
    	return
    end
	
	check = (not check)

	for i,k in ipairs(spots) do
		
		if not eff[i] then
			
			local coint1 = math.floor(math.floor(k[3]-k[1])/50)
			local coint2 = math.floor(math.floor(k[2]-k[4])/50)
			
			eff[i] = {}		
			
			for a = 1,math.max(coint1,coint2) do
				eff[i].eff1 = {} eff[i].eff2 = {}	
				eff[i].eff3 = {} eff[i].eff4 = {}
			end		
			
			if k[5] == 1 then
				ground = GetGround(Vector(k[1], k[2], 0),k[5])
			elseif k[5] == 2 then
				ground = GetGround(Vector(k[3], k[4], 0),k[5])
			else
				ground = nil
			end
			
			for a = 1,coint1 do				
				local first = Vector(k[1]+a*50, k[4], 0)
				local second = Vector(k[1]+a*50, k[2], 0)				
				eff[i].eff1[a] = Effect(first,effec)
				eff[i].eff1[a]:SetVector(0,GetVector(first,ground))				
				eff[i].eff3[a] = Effect(second,effec)
				eff[i].eff3[a]:SetVector(0,GetVector(second,ground))
			end
			
			for a = 1,coint2 do		
				local first = Vector(k[1], k[4]+a*50, 0)
				local second = Vector(k[3], k[4]+a*50, 0)				
				eff[i].eff2[a] = Effect(first,effec)
				eff[i].eff2[a]:SetVector(0,GetVector(first,ground))				
				eff[i].eff4[a] = Effect(second,effec)
				eff[i].eff4[a]:SetVector(0,GetVector(second,ground))
			end
			
		elseif eff[i] then
			eff[i] = nil
			collectgarbage("collect")
		end
	
	end
	
end

function GetVector(Vec,zet)
	local retVector = Vec
	client:GetGroundPosition(retVector)
	if not zet or (zet and retVector.z == zet) then
		return retVector
	end 
	return Vector(-10000,-10000,-100)
end

function GetGround(Vec)
	local retVector = Vec
	client:GetGroundPosition(retVector)	
	return retVector.z
end

function Load()
	if PlayingGame() then
		play = true
		script:RegisterEvent(EVENT_KEY,Key)
		script:UnregisterEvent(Load)
	end
end

function GameClose()
	eff = {}
	eff1 = {}
	eff2 = {}
	eff3 = {}
	eff4 = {}
	collectgarbage("collect")
	if play then
		script:UnregisterEvent(Key)
		script:RegisterEvent(EVENT_TICK,Load)
		play = false
	end
end

script:RegisterEvent(EVENT_TICK,Load)
script:RegisterEvent(EVENT_CLOSE,GameClose)
