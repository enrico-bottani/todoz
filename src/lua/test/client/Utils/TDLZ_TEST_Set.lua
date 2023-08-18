require('src.lua.client.Utils.TDLZ_Set')
local test = require('src.lua.test.common.luaunit')
TEST_TDLZ_Set = {}
if test ~= nil then
    function TEST_TDLZ_Set.test_TDLZ_Set_New_NotNilReturnValue()
        local set = TDLZ_Set:new()
        test.assertNotIsNil(set)
    end
    function TEST_TDLZ_Set.test_TDLZ_Set_table_NotNil()
        local set = TDLZ_Set:new()
        test.assertNotIsNil(set._table)
    end
    function TEST_TDLZ_Set.test_TDLZ_Set_Add_ValueIsStored()
        local set = TDLZ_Set:new()
        set:add("somevalue")
        test.assertIsTrue(set._table.somevalue)
        test.assertIsFalse(set._empty)
    end
    function TEST_TDLZ_Set.test_TDLZ_Set_Remove_ValueIsRemoved()
        local set = TDLZ_Set:new()
        set:add("somevalue")
        test.assertIsTrue(set._table.somevalue)
        set:remove("somevalue")
        test.assertIsNil(set._table.somevalue)
        test.assertIsTrue(set._empty)
    end
    function TEST_TDLZ_Set.test_TDLZ_Set_Remove_RemoveSameTwice_ValueIsRemoved()
        local set = TDLZ_Set:new()
        set:add("somevalue")
        test.assertIsTrue(set._table.somevalue)
        set:remove("somevalue")
        set:remove("somevalue")
        test.assertIsNil(set._table.somevalue)
        test.assertIsTrue(set._empty)
    end
    function TEST_TDLZ_Set.test_TDLZ_Set_Contains()
        local set = TDLZ_Set:new()
        set:add("somevalue")
        test.assertIsTrue(set:contains("somevalue"))
    end
    function TEST_TDLZ_Set.test_TDLZ_Set_Max()
        local set = TDLZ_Set:new()
        set:add("somevalue2")
        set:add("somevalue1")
        set:add("somevalue3")
        test.assertEquals("somevalue3", set._max)
    end
    function TEST_TDLZ_Set.test_TDLZ_Set_Min()
        local set = TDLZ_Set:new()
        set:add("somevalue2")
        set:add("somevalue1")
        set:add("somevalue3")
        test.assertEquals("somevalue1", set._min)
    end
else
    error("luaunit not loaded")
end
