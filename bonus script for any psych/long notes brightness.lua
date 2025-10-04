function onCreatePost()
    for i=0, getProperty('unspawnNotes.length')-1 do
        if getPropertyFromGroup('unspawnNotes', ia, 'isSustainNote') == false then
            local tailLength = getProperty('unspawnNotes[' .. i .. '].tail.length')
            if tailLength > 3 then --//average haxe user
                for j=0, tailLength-1 do
                    setPropertyFromGroup('unspawnNotes[' .. i .. '].tail', j, 'colorSwap.brightness', getPropertyFromGroup('unspawnNotes[' .. i .. '].tail', j, 'colorSwap.brightness')+(j+1)*(1/tailLength))
                    setPropertyFromGroup('unspawnNotes[' .. i .. '].tail', j, 'colorSwap.saturation', getPropertyFromGroup('unspawnNotes[' .. i .. '].tail', j, 'colorSwap.saturation')-(j+1)*(1/tailLength))
                end
            end
        end
    end
end

function goodNoteHit(membersIndex, noteData, noteType, isSustainNote)
    setPropertyFromGroup('playerStrums', noteData, 'colorSwap.brightness', getPropertyFromGroup('notes', membersIndex, 'colorSwap.brightness'))
    setPropertyFromGroup('playerStrums', noteData, 'colorSwap.saturation', getPropertyFromGroup('notes', membersIndex, 'colorSwap.saturation'))
end
function opponentNoteHit(membersIndex, noteData, noteType, isSustainNote)
    setPropertyFromGroup('opponentStrums', noteData, 'colorSwap.brightness', getPropertyFromGroup('notes', membersIndex, 'colorSwap.brightness'))
    setPropertyFromGroup('opponentStrums', noteData, 'colorSwap.saturation', getPropertyFromGroup('notes', membersIndex, 'colorSwap.saturation'))
end