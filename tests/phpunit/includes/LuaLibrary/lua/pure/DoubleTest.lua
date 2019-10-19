--- Tests for the double module.

local testframework = require 'Module:TestFramework'

local Double = require 'double'
assert( Double )

local function testExists()
	return type( Double )
end

local tests = {

}

return testframework.getTestProvider( tests )
