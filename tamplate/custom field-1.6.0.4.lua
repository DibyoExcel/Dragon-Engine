--tamplate move gf note to custom field strum(in camGame/game camera) and follow gf

function onCreatePost()
    createCustomStrum("tamplateStrum", 4, "game", 1, 1, false)--tag, many note, camType, scrollX, scrollY, downScroll
    for i=0, getProperty("unspawnNotes.length")-1 do
        if getPropertyFromGroup("unspawnNotes", i, "gfNote") == true and getPropertyFromGroup("unspawnNotes", i, "mustPress") == false then
            setPropertyFromGroup("unspawnNotes", i, "customField", true)--set true if want use custom field
            setPropertyFromGroup("unspawnNotes", i, "fieldTarget", "tamplateStrum")--set field target(be sure the custom field exits or else it will disable 'customField')
            --not need this on 1.6.0.4 cuz is autoset to current strums using(also if want change use in onUpdatePost() recommended)(sorry if bad english:v)
            --[[setPropertyFromGroup("unspawnNotes", i, "camTarget", 'game')--set to specific cam
            setPropertyFromGroup("unspawnNotes", i, "scrollFactorCam", {1, 1})--set scroll factor
            setPropertyFromGroup("unspawnNotes", i, "noteSplashScrollFactor", {1, 1})--scroll factor note splash(optional only use if want change scroll factor)
            setPropertyFromGroup("unspawnNotes", i, "noteSplashCam", 'game')--set note splash cam]]

        end
    end
end

function onUpdate(elapsed)
    --make "tamplateStrum" always follow gf(this only example and might not accurate in some character)
    for i=0, getProperty("customStrum.length")-1 do
        if getPropertyFromGroup("customStrum", i, "fieldName") == "tamplateStrum" then--target field name
            local noteData = getPropertyFromGroup("customStrum", i, "memberID")
            setPropertyFromGroup("customStrum", i, "x", getGraphicMidpointX('gf')+(noteData*112))
            setPropertyFromGroup("customStrum", i, "y", (getGraphicMidpointY('gf')-(getProperty('gf.height')/2))-100)
        end
    end
end

function onStepHit()
    if (curStep == 666) then--some example mid song
        removeStrum("tamplateStrum")--remove strum in mid song
        for i=0, getProperty('unspawnNotes.length')-1 do
            --change back to hud
            --setPropertyFromGroup("unspawnNotes", i, "camTarget", 'hud')
            --setPropertyFromGroup("unspawnNotes", i, "noteSplashCam", 'hud')
        end
    end
end