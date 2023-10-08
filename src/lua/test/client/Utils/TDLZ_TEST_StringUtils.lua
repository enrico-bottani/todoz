require 'src.lua.client.Utils.TDLZ_StringUtils'
local test = require('src.lua.test.common.luaunit')
TEST_TDLZ_StringUtils = {}
if test ~= nil then
    -- │#│2│3│ │5│6│7│ │#│P│e│n│c│i│l│ │2│
    -- └0└1└2└3└4└5└6└7└8└9└0└1└2└3└4└5└6└7
    local strToCheck = "#23 567 #Pencil 2"
    function TEST_TDLZ_StringUtils.test_TDLZ_Set_New_NotNilReturnValue()
        local str = TDLZ_StringUtils.findHashTagName(strToCheck, 0)
        test.assertEquals(str.text, "")
    end

    function TEST_TDLZ_StringUtils.test_TDLZ_Set_New_NotNilReturnValue12()
        local str = TDLZ_StringUtils.findHashTagName(strToCheck, 7)
        test.assertEquals(str.text, "")
        test.assertEquals(str.startIndex, -1)
    end

    function TEST_TDLZ_StringUtils.test_TDLZ_Set_New_NotNilReturnValue1()
        local str = TDLZ_StringUtils.findHashTagName(strToCheck, 15)
        test.assertEquals(str.text, "#Pencil")
    end

    function TEST_TDLZ_StringUtils.test_TDLZ_Set_New_NotNilReturnValue2()
        local str = TDLZ_StringUtils.findHashTagName(strToCheck, 16)
        test.assertEquals(str.text, "")
        test.assertEquals(str.startIndex, -1)
    end

    function TEST_TDLZ_StringUtils.test_TDLZ_Set_New_NotNilReturnValue3()
        local str = TDLZ_StringUtils.findHashTagName(strToCheck, 17)
        test.assertEquals(str.text, "")
        test.assertEquals(str.startIndex, -1)
    end

    function TEST_TDLZ_StringUtils.test_TDLZ_Set_New_NotNilReturnValue13()
        local str = TDLZ_StringUtils.findHashTagName(strToCheck, 8)
        test.assertEquals(str.text, "")
        test.assertEquals(str.startIndex, -1)
    end

    function TEST_TDLZ_StringUtils.test_TDLZ_Set_New_NotNilReturnValue113()
        local str = TDLZ_StringUtils.findHashTagName(strToCheck, 9)
        test.assertEquals(str.text, "#Pencil")
    end

    function TEST_TDLZ_StringUtils.test_TDLZ_Set_New_NotNilReturnValue4()
        local s = "123 #2"
        local str = TDLZ_StringUtils.findHashTagName(s, 1)
        test.assertEquals(str.text, "")
        test.assertEquals(str.startIndex, -1)
    end

    function TEST_TDLZ_StringUtils.test_TDLZ_Set_New_NotNilReturnValue5()
        local s = "#123 2"
        local str = TDLZ_StringUtils.findHashTagName(s, 1)
        test.assertEquals(str.text, "#123")
        test.assertEquals(str.startIndex, 1)
        test.assertEquals(str.endIndex, 4)
    end

    function TEST_TDLZ_StringUtils.findHashTagNameOutOfBound()
        local s = "#123 2"
        local str = TDLZ_StringUtils.findHashTagName(s, 111)
        test.assertEquals(str.text, "")
        test.assertEquals(str.startIndex, -1)
        test.assertEquals(str.endIndex, -1)
    end
end
