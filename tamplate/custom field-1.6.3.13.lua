--tamplate move gf note to custom field strum(in camGame/game camera) and follow gf and behind gf

function onCreatePost()
    createCustomStrum("tamplateStrum", 4, "game", 1, 1, false)--tag, many note, camType, scrollX, scrollY, downScroll
    for i=0, getProperty("unspawnNotes.length")-1 do
        if getPropertyFromGroup("unspawnNotes", i, "gfNote") == true and getPropertyFromGroup("unspawnNotes", i, "mustPress") == false then
            setPropertyFromGroup("unspawnNotes", i, "customField", true)--set true if want use custom field
            setPropertyFromGroup("unspawnNotes", i, "fieldTarget", "tamplateStrum")--set field target(be sure the custom field exits or else it will disable 'customField')
        end
    end
    --make custom strum behind gf
    setObjectOrder('customStrums@tamplateStrum', getObjectOrder('gfGroup'))--also old code still work
    setObjectOrder('notesGroupMap@tamplateStrum', getObjectOrder('gfGroup'))
    setObjectOrder('noteSplashGroupMap@tamplateStrum', getObjectOrder('gfGroup'))
end

function onUpdate(elapsed)
    local songPos = getSongPosition()
    --make "tamplateStrum" always follow gf(this only example and might not accurate in some character)
    for i=0, getProperty('strumGroupMap@tamplateStrum.length')-1 do
        setPropertyFromGroup("strumGroupMap@tamplateStrum", i, "x", getGraphicMidpointX('gf')+(i*112))
        setPropertyFromGroup("strumGroupMap@tamplateStrum", i, "y", ((getGraphicMidpointY('gf')-(getProperty('gf.height')/2))-100)+(math.sin((songPos/1000)-i)*100))
    end
    
end

function onStepHit()
    if (curStep == 666) then--some example mid song
        removeStrum("tamplateStrum")--remove strum in mid song
        --[[for i=0, getProperty('unspawnNotes.length')-1 do
            change back to hud
            setPropertyFromGroup("unspawnNotes", i, "camTarget", 'hud')
            setPropertyFromGroup("unspawnNotes", i, "noteSplashCam", 'hud')
        end]]
    end
end