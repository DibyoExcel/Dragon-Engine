function onCreatePost()
    for i=0, getProperty('unspawnNotes.length')-1 do
        setPropertyFromGroup('unspawnNotes', i, "useRGBPalette", false)
        setPropertyFromGroup('unspawnNotes', i, "noteSplashUseRGBPalette", false)
    end
    for i=0, getProperty('strumLineNotes.length')-1 do
        setPropertyFromGroup('strumLineNotes', i, "useRGBPalette", false)
    end
end