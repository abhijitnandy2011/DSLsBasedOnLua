-- A simple DSL for a C++ like language
-- that supports creation of classes similarly to C++
-- Creates classes in the global ENV
-- Also puts a reference within the 'cpp' table
-- TODO Implement private access using metatables

local print = print
local type = type
local _G = _G
local pairs = pairs
local tostring = tostring
local tonumber = tonumber
cpp = {}

-- Context Trackers
cpp.ACCESS_INFO = {}
cpp.CURRENT_ACCESS_TYPE = ''
cpp.CURRENT_CLASS_NAME = ''
cpp.CURRENT_VAR_TYPE = ''
cpp.CURRENT_VAR_NAME = ''


cpp.baseParser = {}

-- This actually gets the whole declaration table
function cpp.classDeclParser(declTbl)
    print 'Compilation successful!'
    
    --print("---- Class Decl -----")
    
    -- Add any functions
    for key,value in pairs(declTbl) do
        --print(tostring(key) .. ' = ' .. tostring(value))
        
        if type(key) == 'string' then
            local globalClassTable = _G[CURRENT_CLASS_NAME]
            globalClassTable[key] = value
        end        
    end    
    
    -- Reset trackers
    CURRENT_ACCESS_TYPE = ''
    CURRENT_CLASS_NAME = ''
end

function cpp.baseParser:public(base)
    print(base)
    return classDeclParser
end

function cpp.class(className)
    print(className)
    ACCESS_INFO[className] = {}
    CURRENT_CLASS_NAME = className
    
    -- create the class in global env & drag a ref to cpp ENV
    _G[className] = {} 
    _ENV[className] = _G[className]
    return baseParser
end

function cpp.defaultValueParser(value)
    --print(value .. ' is a ' .. CURRENT_VAR_TYPE)
    
    if CURRENT_ACCESS_TYPE == '' then
        -- global context
        _ENV[CURRENT_VAR_NAME] = value    
    else     
        local globalClassTable = _G[CURRENT_CLASS_NAME]
        if CURRENT_VAR_TYPE == 'str' then
            globalClassTable[CURRENT_VAR_NAME] = value
        elseif CURRENT_VAR_TYPE == 'int' then
            globalClassTable[CURRENT_VAR_NAME] = tonumber(value)
        end
    end
end

cpp.int = function(varName)
    print(varName)
    
    if CURRENT_ACCESS_TYPE == '' then
        -- global context
        _ENV[varName] = 0    
    else      
        -- Create the variable in the class's table
        local globalClassTable = _G[CURRENT_CLASS_NAME]
        globalClassTable[varName] = '<not set>'
    
        -- Record access info
        local clsAccessTbl = ACCESS_INFO[CURRENT_CLASS_NAME]
        clsAccessTbl[CURRENT_ACCESS_TYPE] = clsAccessTbl[CURRENT_ACCESS_TYPE] or {}
        clsAccessTbl[CURRENT_ACCESS_TYPE][varName] = 1 -- just a dummy value, only the key is important
    end      
    
    CURRENT_VAR_TYPE = 'int'
    CURRENT_VAR_NAME = varName
      
    return defaultValueParser
end

cpp.private = {
  str = function(self, varName)
      print(varName)
      CURRENT_ACCESS_TYPE = 'private'
      
      -- Create the variable in the class's table
      local globalClassTable = _G[CURRENT_CLASS_NAME]
      globalClassTable[varName] = '<not set>'
      
      -- Record access info
      local clsAccessTbl = ACCESS_INFO[CURRENT_CLASS_NAME]
      clsAccessTbl[CURRENT_ACCESS_TYPE] = clsAccessTbl[CURRENT_ACCESS_TYPE] or {}
      clsAccessTbl[CURRENT_ACCESS_TYPE][varName] = 1 -- just a dummy value, only the key is important
      
      CURRENT_VAR_TYPE = 'str'
      CURRENT_VAR_NAME = varName    
      
      return defaultValueParser
  end,
  int = function(self, varName)
      print(varName)
      CURRENT_ACCESS_TYPE = 'private'
      
      -- Create the variable in the class's table
      local globalClassTable = _G[CURRENT_CLASS_NAME]
      globalClassTable[varName] = 0
      
      -- Record access info
      local clsAccessTbl = ACCESS_INFO[CURRENT_CLASS_NAME]
      clsAccessTbl[CURRENT_ACCESS_TYPE] = clsAccessTbl[CURRENT_ACCESS_TYPE] or {}
      clsAccessTbl[CURRENT_ACCESS_TYPE][varName] = 1 -- just a dummy value, only the key is important
      
      CURRENT_VAR_TYPE = 'int'
      CURRENT_VAR_NAME = varName    
      
      return defaultValueParser
  end,

}

cpp.public = {
  str = function(self, varName)
      print(varName)
      CURRENT_ACCESS_TYPE = 'public'
      
      -- Create the variable in the class's table
      local globalClassTable = _G[CURRENT_CLASS_NAME]
      globalClassTable[varName] = '<not set>'
      
      -- Record access info
      local clsAccessTbl = ACCESS_INFO[CURRENT_CLASS_NAME]
      clsAccessTbl[CURRENT_ACCESS_TYPE] = clsAccessTbl[CURRENT_ACCESS_TYPE] or {}
      clsAccessTbl[CURRENT_ACCESS_TYPE][varName] = 1 -- just a dummy value, only the key is important
      
      CURRENT_VAR_TYPE = 'str'
      CURRENT_VAR_NAME = varName    
      
      return defaultValueParser
  end,
  int = function(self, varName)
      print(varName)
      CURRENT_ACCESS_TYPE = 'public'
      
      -- Create the variable in the class's table
      local globalClassTable = _G[CURRENT_CLASS_NAME]
      globalClassTable[varName] = 0
      
      -- Record access info
      local clsAccessTbl = ACCESS_INFO[CURRENT_CLASS_NAME]
      clsAccessTbl[CURRENT_ACCESS_TYPE] = clsAccessTbl[CURRENT_ACCESS_TYPE] or {}
      clsAccessTbl[CURRENT_ACCESS_TYPE][varName] = 1 -- just a dummy value, only the key is important
      
      CURRENT_VAR_TYPE = 'int'
      CURRENT_VAR_NAME = varName    
      
      return defaultValueParser
  end,

}


-- Test code

_ENV = cpp

class 'A': public 'B'
{
public: 
    int 'm',
    int 'n' '10',
    foo = function() 
        print("function foo called!") 
    end,
    
private:
    str 's' 'hi',
    int 'i' '3',
    bar = function() 
        print("function foo called!") 
    end,
}


int 'g' '20'

print(g)

--print(A)
print(g+A.n)
