require('media.lua.client.Utils.TDLZ_NumSet')
local test = require('media.lua.test.common.luaunit')
TEST_TDLZ_NumSet = {}
if test ~= nil and os.getenv("env")=="test"then
    function TEST_TDLZ_NumSet.test_TDLZ_NumSet_New_NotNilReturnValue()
        local set = TDLZ_NumSet:new()
        test.assertNotIsNil(set)
    end
    function TEST_TDLZ_NumSet.test_TDLZ_NumSet_table_NotNil()
        local set = TDLZ_NumSet:new()
        test.assertNotIsNil(set._table)
    end
    function TEST_TDLZ_NumSet.test_TDLZ_NumSet_Add_ValueIsStored()
        local set = TDLZ_NumSet:new()
        set:add(1)
        test.assertIsTrue(set._table[1])
        test.assertIsFalse(set._empty)
    end
    function TEST_TDLZ_NumSet.test_TDLZ_NumSet_Remove_ValueIsRemoved()
        local set = TDLZ_NumSet:new()
        set:add(1)
        test.assertIsTrue(set._table[1])
        set:remove(1)
        test.assertIsNil(set._table[1])
        test.assertIsTrue(set._empty)
    end
    function TEST_TDLZ_NumSet.test_TDLZ_NumSet_Remove_RemoveSameTwice_ValueIsRemoved()
        local set = TDLZ_NumSet:new()
        set:add(1)
        test.assertIsTrue(set._table[1])
        set:remove(1)
        set:remove(1)
        test.assertIsNil(set._table[1])
        test.assertIsTrue(set._empty)
    end
    function TEST_TDLZ_NumSet.test_TDLZ_NumSet_Contains()
        local set = TDLZ_NumSet:new()
        set:add(1)
        test.assertIsTrue(set:contains(1))
    end
    function TEST_TDLZ_NumSet.test_TDLZ_NumSet_Max()
        local set = TDLZ_NumSet:new()
        set:add(2)
        set:add(1)
        set:add(3)
        test.assertEquals(3,set._max)
    end
    function TEST_TDLZ_NumSet.test_TDLZ_NumSet_Min()
        local set = TDLZ_NumSet:new()
        set:add(2)
        set:add(1)
        set:add(3)
        test.assertEquals(1,set._min)
    end
else
    error("luaunit not loaded")
end
