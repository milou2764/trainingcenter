if game.GetMap() ~= "trainingcenter" then return end

local config = {
    targetRoom = {
        { -- target room of the fist circuit
            Vector()
        }
    },
    parcoursRoom = {
        [1] = {
            spawnPos = Vector()
        }
    }
}

local waitingTrainees = {}

local room = {
    spawnPos,
    trainee,
    remainingTime,
    waitingTrainees
}

local rooms = {
    targetRoom = table.Copy(room),
    parcoursRoom = table.Copy(room),
    grenadeRoom = table.Copy(room)
}

local circuits = {}

local function makeCircuits(n)
    for conf in config do
        -- TODO
    end
end
makeCircuits()

local function onRegister(ply)
    table.insert(fifoList, ply)
end