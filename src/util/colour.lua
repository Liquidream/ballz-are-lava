-- helper function
function fromRGB(red, green, blue) -- alpha?
 return {red/255, green/255, blue/255}
end

-- EDG32 Palette
local cols={
 -- from left-to-right
[0]=fromRGB(190,74,47),    --1
    fromRGB(216,118,68),
    fromRGB(234,212,170),
    fromRGB(228,166,114),
    fromRGB(184,111,80),
    fromRGB(116,63,57),
    fromRGB(63,40,50),
    fromRGB(158,40,53),
    fromRGB(228,59,68),
    fromRGB(247,118,34),
    fromRGB(254,174,52),  --10
    fromRGB(254,231,97),
    fromRGB(99,199,77),
    fromRGB(62,137,72),
    fromRGB(38,92,66),
    fromRGB(25,60,62),   --15
    fromRGB(18,78,137),
    fromRGB(0,149,233),
    fromRGB(44,232,245),
    fromRGB(255,255,255),
    fromRGB(192,203,220), --20
    fromRGB(139,155,180),
    fromRGB(90,105,136),
    fromRGB(58,68,102),
    fromRGB(38,43,68),
    fromRGB(255,00,68),   --25
    fromRGB(24,20,37),
    fromRGB(104,56,108),
    fromRGB(181,80,136),
    fromRGB(246,117,122),
    fromRGB(232,183,150),
    fromRGB(194,133,105)
}


-- function getColour(index)
 
-- end

return cols