MRP = MRP or {}
MRP.lang = MRP.lang or "FR"
MRP.translation = {
    FR = {
        countDown = "Téléportation dans %s s",
        noFreeRoom = "Veuillez patienter que la salle suivante se libère s'il vous plaît",
        trainingCenter = {
            timeOut = "Vous avez dépassé le temps imparti",
            hint = "Vous pouvez vous inscrire à la formation en intéragissant avec le réceptionniste",
            congrats = "Félicitations, vous avez terminé la formation, vous allez maitenant être déployé sur le terrain"
        },
        trainingIsOver = "La formation est terminée"
    },
    EN = {
        countDown = "Teleporting in %s s",
        noFreeRoom = "Please wait for the next room to be free",
        trainingCenter = {
            timeOut = "You exceeded the time limit",
            hint = "You can sign up for the training by interacting with the receptionist",
            congrats = "Congratulations, you have completed the training, you will now be deployed on the field"
        },
        trainingIsOver = "The training is over"
    }
}

---@class target
---@field mapId number The map id of the target
---@field entity Entity The entity of the target
---@field hit boolean If the target has been hit
---@field doorMapId number The map id of the door
---@field doorEntity Entity The entity of the door
local function target(targetId, doorId)
    return {
        mapId = targetId,
        entity = nil,
        hit = false,
        doorMapId = doorId,
        doorEntity = nil
    }
end
MRP.waitingTrainees = {}
MRP.trainingCenter = {
    receptionnistPos = Vector(2480, -179, 8),
    receptionnistAng = Angle(5, 44, 0),
    spawnPos = Vector(2247, -153, 8),
    spawnAng = Angle(8, 11, 0),
    targetRooms = {
        { -- target room of the fist circuit
            spawnPos = Vector(2659, 3360, -635),
            spawnAng = Angle(6, 0, 0),
            targets = {
                target(1237, 1236),
                target(1242, 1243),
                target(1238, 1239),
                target(1240, 1241)
            }
        }
    },
    courseRooms = {
        { -- course room of the fist circuit
            spawnPos = Vector(1672, 3338, -635),
            spawnAng = Angle(2, -2, 0),
            buttonPos = Vector(1621, 3480, -599)
        }
    },
    grenadeRooms = {
        { -- course room of the fist circuit
            spawnPos = Vector(744, 3339, -635),
            spawnAng = Angle(10, 0, 0),
            targets = {
                target(1251, 1252),
                target(1250, 1249),
                target(1256, 1255),
                target(1253, 1254)
            }
        }
    }
}