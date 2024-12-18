local HRLib <const>, config <const> = HRLib --[[@as HRLibClientFunctions]], HRLib.require(('@%s/config.lua'):format(GetCurrentResourceName())) --[[@as HRNPCDialgueConfig]]
local currentOptions, dialogueStarted, currentCam

---@param targetPed integer? you can only set this to nil if you want the function to create the ped instead of you
---@param options HRNPCDialogueOptions
---@param createPed { model: string|integer, animation: { dict: string, anim: string }?, coords: vector4 }? don't fill this if you don't wanna use its function to create ped instead of you
---@return integer? ped it only returns that if you used createPed parameter (and you used it correctly)
local startNPCDialogue = function(targetPed, options, createPed)
    if not dialogueStarted then
        if createPed and IsModelValid(joaat(createPed.model)) then
            HRLib.RequestModel(createPed.model)

            targetPed = CreatePed(4, joaat(createPed.model), createPed.coords, false, true) ---@diagnostic disable-line: missing-parameter, param-type-mismatch

            if createPed.animation then
                HRLib.RequestAnimDict(createPed.animation.dict)
                TaskPlayAnim(targetPed, createPed.animation.dict, createPed.animation.anim, 8.0, 8.0, -1, 2, 0, true, true, true)
            end

            FreezeEntityPosition(targetPed, true)
            SetEntityInvincible(targetPed, true)
            SetBlockingOfNonTemporaryEvents(targetPed, true)
            SetEntityProofs(targetPed, true, true, true, true, true, true, true, true)
        end

        currentOptions = HRLib.table.deepclone(options)

        local nuiOptions <const> = HRLib.table.deepclone(options)
        nuiOptions.action = 'show'
        nuiOptions.onCancel = nil

        for i=1, #nuiOptions.questions do
            for l=1, #nuiOptions.questions[i].possibleAnswers do
                nuiOptions.questions[i].possibleAnswers[l].onSelect = nil
            end
        end

        SetNuiFocus(true, true)

        -- Cam creation
        TaskTurnPedToFaceEntity(PlayerPedId(), targetPed --[[@as integer]], 0)
        local cam <const>, pedRotation <const> = CreateCam('DEFAULT_SCRIPTED_CAMERA', true), GetEntityRotation(targetPed --[[@as integer]], 5) + vector3(0.0, 0.0, 181.0)
        SetCamCoord(cam, (GetEntityCoords(targetPed, true) + vector3(GetEntityForwardX(targetPed) / 1.5, GetEntityForwardY(targetPed) / 1.5, 0.75))) ---@diagnostic disable-line: missing-parameter, param-type-mismatch
        SetCamRot(cam, pedRotation, 5) ---@diagnostic disable-line: missing-parameter, param-type-mismatch
        RenderScriptCams(true, true, config.transitionDuration, true, true)
        SetTimeout(config.transitionDuration, function()
            SetEntityVisible(PlayerPedId(), false, false)
            DisplayRadar(false)
            SendNUIMessage(nuiOptions)
        end)

        currentCam = cam
        dialogueStarted = true

        if createPed then
            return targetPed
        end
    end
end

RegisterNUICallback('answerSelected', function(data)
    if currentOptions then
        local currAnswer <const> = currentOptions.questions[data.questionIndex].possibleAnswers[data.answerIndex]
        if type(currAnswer.onSelect) == 'function' then
            currAnswer.onSelect()
        elseif type(currAnswer.onSelect) == 'table' and currAnswer.onSelect.__cfx_functionReference ~= nil then
            Citizen.InvokeFunctionReference(currAnswer.onSelect.__cfx_functionReference, msgpack.pack(''))
        end

        if currAnswer.closeOnSelect then
            SendNUIMessage({
                action = 'hide'
            })
            SetNuiFocus(false, false)
            DestroyCam(currentCam, true)
            ClearFocus()
            RenderScriptCams(false, true, 1000, false, false)
            SetEntityVisible(PlayerPedId(), true, false)
            DisplayRadar(true)

            currentOptions = nil
            currentCam = nil
            dialogueStarted = nil
        end
    end
end)

RegisterNUICallback('hide', function()
    SetNuiFocus(false, false)
    DestroyCam(currentCam, true)
    ClearFocus()
    RenderScriptCams(false, true, 1000, false, false)
    SetEntityVisible(PlayerPedId(), true, false)
    DisplayRadar(true)

    if currentOptions.onCancel and type(currentOptions.onCancel) == 'function' or (type(currentOptions.onCancel) == 'table' and currentOptions.onCancel.__cfx_functionReference ~= nil) then
        if type(currentOptions.onCancel) == 'function' then
            currentOptions.onCancel()
        elseif type(currentOptions.onCancel) == 'table' and currentOptions.onCancel.__cfx_functionReference ~= nil then
            Citizen.InvokeFunctionReference(currentOptions.onCancel.__cfx_functionReference, msgpack.pack(''))
        end
    end

    dialogueStarted = nil
end)

RegisterNUICallback('getThemeColor', function(_, cb)
    cb(config.themeColor)
end)

exports('startDialogue', startNPCDialogue)
RegisterNetEvent('HRNPCDialogue:startDialogue', startNPCDialogue)