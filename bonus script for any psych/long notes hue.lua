function onCreatePost()
    for i=0, getProperty('unspawnNotes.length')-1 do
        if getPropertyFromGroup('unspawnNotes', ia, 'isSustainNote') == false then
            local tailLength = getProperty('unspawnNotes[' .. i .. '].tail.length')
            if tailLength > 0 then --//average haxe user
                for j=0, tailLength-1 do
                    setPropertyFromGroup('unspawnNotes[' .. i .. '].tail', j, 'colorSwap.hue', getPropertyFromGroup('unspawnNotes[' .. i .. '].tail', j, 'colorSwap.hue')+(j+1)*(1/tailLength))
                end
            end
        end
    end
end

function goodNoteHit(membersIndex, noteData, noteType, isSustainNote)
    setPropertyFromGroup('playerStrums', noteData, 'colorSwap.hue', getPropertyFromGroup('notes', membersIndex, 'colorSwap.hue'))
end
function opponentNoteHit(membersIndex, noteData, noteType, isSustainNote)
    setPropertyFromGroup('opponentStrums', noteData, 'colorSwap.hue', getPropertyFromGroup('notes', membersIndex, 'colorSwap.hue'))
end