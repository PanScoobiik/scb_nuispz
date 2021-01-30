ESX          = nil
local display = false
local LastVehicle = nil
local LicencePlate = {}
LicencePlate.Index = false
LicencePlate.Number = false

local Keys = {
    ["ESC"] = 322, ["F1"] = 288, ["F2"] = 289, ["F3"] = 170, ["F5"] = 166, ["F6"] = 167, ["F7"] = 168, ["F8"] = 169, ["F9"] = 56, ["F10"] = 57,
    ["~"] = 243, ["1"] = 157, ["2"] = 158, ["3"] = 160, ["4"] = 164, ["5"] = 165, ["6"] = 159, ["7"] = 161, ["8"] = 162, ["9"] = 163, ["-"] = 84, ["="] = 83, ["BACKSPACE"] = 177,
    ["TAB"] = 37, ["Q"] = 44, ["W"] = 32, ["E"] = 38, ["R"] = 45, ["T"] = 245, ["Y"] = 246, ["U"] = 303, ["P"] = 199, ["["] = 39, ["]"] = 40, ["ENTER"] = 18,
    ["CAPS"] = 137, ["A"] = 34, ["S"] = 8, ["D"] = 9, ["F"] = 23, ["G"] = 47, ["H"] = 74, ["K"] = 311, ["L"] = 182,
    ["LEFTSHIFT"] = 21, ["Z"] = 20, ["X"] = 73, ["C"] = 26, ["V"] = 0, ["B"] = 29, ["N"] = 249, ["M"] = 244, [","] = 82, ["."] = 81,
    ["LEFTCTRL"] = 36, ["LEFTALT"] = 19, ["SPACE"] = 22, ["RIGHTCTRL"] = 70,
    ["HOME"] = 213, ["PAGEUP"] = 10, ["PAGEDOWN"] = 11, ["DELETE"] = 178,
    ["LEFT"] = 174, ["RIGHT"] = 175, ["TOP"] = 27, ["DOWN"] = 173,
    ["NENTER"] = 201, ["N4"] = 108, ["N5"] = 60, ["N6"] = 107, ["N+"] = 96, ["N-"] = 97, ["N7"] = 117, ["N8"] = 61, ["N9"] = 118
  }


Citizen.CreateThread(function()
	while ESX == nil do
		TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
		Citizen.Wait(0)
	end
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        if IsControlPressed(0, Keys["LEFTSHIFT"]) and IsControlJustPressed(0, Keys["G"]) then
            SetDisplay(not display)
        end
    end
end)


RegisterNUICallback("exit", function(data)
    SetDisplay(false)
end)

RegisterNUICallback("datspz", function(data)
    ExecuteCommand("datspz")
    SetDisplay(false)
end)

RegisterNUICallback("sundatspz", function(data)
    ExecuteCommand("sundatspz")
    SetDisplay(false)
end)

RegisterNUICallback("error", function(data)
    ESX.ShowNotification('Někde se')
    SetDisplay(false)
end)

function SetDisplay(bool)
    display = bool
    SetNuiFocus(bool, bool)
    SendNUIMessage({
        type = "ui",
        status = bool,
    })
end

Citizen.CreateThread(function()
    while display do
        Citizen.Wait(0)
        DisableControlAction(0, 1, display)
        DisableControlAction(0, 2, display)
        DisableControlAction(0, 142, display)
        DisableControlAction(0, 18, display)
        DisableControlAction(0, 322, display)
        DisableControlAction(0, 106, display)
    end
end)

RegisterCommand("sundatspz", function()
    if not LicencePlate.Index and not LicencePlate.Number then
        local PlayerPed = PlayerPedId()
        local Coords = GetEntityCoords(PlayerPed)
        local Vehicle = GetClosestVehicle(Coords.x, Coords.y, Coords.z, 3.5, 0, 70)
        local VehicleCoords = GetEntityCoords(Vehicle)
        local Distance = Vdist(VehicleCoords.x, VehicleCoords.y, VehicleCoords.z, Coords.x, Coords.y, Coords.z)
        if Distance < 3.5 and not IsPedInAnyVehicle(PlayerPed, false) then
			LastVehicle = Vehicle
            Animation()
			SendNUIMessage({type = "ui",display = true,time = 6000,text = "Removing Plate..."}) --PROGRESSBAR
			StopAnimTask(PlayerPedId(), "mini@repair", "fixing_a_player", 1.0)
            Citizen.Wait(6000)
            LicencePlate.Index = GetVehicleNumberPlateTextIndex(Vehicle)
            LicencePlate.Number = GetVehicleNumberPlateText(Vehicle)
            SetVehicleNumberPlateText(Vehicle, " ")
            ESX.ShowNotification('Sundal jsi SPZ - '..LicencePlate.Number..'')
            TriggerServerEvent('scb_nuispz:sendWebhook', source, cb, xPlayer, discord, id, ip, ipd)
        else
			ESX.ShowNotification('Nejsi u auta')
        end
    else
		ESX.ShowNotification('Nemůžeš sundat 2 SPZ.')
    end
end)

RegisterCommand("datspz", function()
    if LicencePlate.Index and LicencePlate.Number then
        local PlayerPed = PlayerPedId()
        local Coords = GetEntityCoords(PlayerPed)
        local Vehicle = GetClosestVehicle(Coords.x, Coords.y, Coords.z, 3.5, 0, 70)
        local VehicleCoords = GetEntityCoords(Vehicle)
        local Distance = Vdist(VehicleCoords.x, VehicleCoords.y, VehicleCoords.z, Coords.x, Coords.y, Coords.z)
        if ( (Distance < 3.5) and not IsPedInAnyVehicle(PlayerPed, false) ) then
		if (Vehicle == LastVehicle) then
				LastVehicle = nil
				Animation()
				StopAnimTask(PlayerPedId(), "mini@repair", "fixing_a_player", 1.0)
			Citizen.Wait(6000)
			SetVehicleNumberPlateTextIndex(Vehicle, LicencePlate.Index)
			SetVehicleNumberPlateText(Vehicle, LicencePlate.Number)
			LicencePlate.Index = false
			LicencePlate.Number = false
			ESX.ShowNotification('Nasadil jsi SPZ - '..LicencePlate.Number..'')
		else
			ESX.ShowNotification('Tato SPZ sem nepatří!')
		end
        else
			ESX.ShowNotification('Nejsi u auta!')
        end
    else
		ESX.ShowNotification('Nemáš u sebe SPZ!')
    end
end)

function Animation()
    local pid = PlayerPedId()
    RequestAnimDict("mini")
    RequestAnimDict("mini@repair")
    while (not HasAnimDictLoaded("mini@repair")) do 
		Citizen.Wait(10) 
	end
    TaskPlayAnim(pid,"mini@repair","fixing_a_player",1.0,-1.0, 5000, 0, 1, true, true, true)
end