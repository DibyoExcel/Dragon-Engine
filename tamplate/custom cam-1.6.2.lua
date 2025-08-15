local camName = {'hud'}
function onCreatePost()
    for i=0, 1 do
        table.insert(camName, 'crazy' .. i)
        addCamera('crazy' .. i, 0, 0, screenWidth, screenHeight, 1)
    end
    addCamera('pauseCaam')--i recommended to add this at very last cuz pause menu might use last cam
    for i=0, getProperty('opponentStrums.length')-1 do
        setPropertyFromGroup('opponentStrums', i, 'camTarget', table.concat(camName, ','))
        setPropertyFromGroup('opponentStrums', i, 'scrollFactorCam', {1, 1})
    end
end

function onUpdatePost(elapsed)
    songPos = getSongPosition() /1000
    for i=0, 1 do
        setProperty('camera:crazy' .. i .. '.angle', math.sin(songPos-i)*10)
    end
end
function onStepHit()
    if curStep == 100 then--exxample remove mid camera in song
        for i=0, 1 do
            removeCamera('crazy' .. i)
        end
        for i=0, getProperty('opponentStrums.length')-1 do
            setPropertyFromGroup('opponentStrums', i, 'camTarget', 'hud')--besure when delete set cam to default or else the notes flying on camGame
            setPropertyFromGroup('opponentStrums', i, 'scrollFactorCam', {0, 0})--optional
        end
    end
end