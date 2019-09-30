--- Baseclass for Spy.
-- @classmod Spy

-- pure libs
local libUtil = require 'libraryUtil'

-- lookup
local checkType = libUtil.checkType
local makeCheckSelfFunction = libUtil.makeCheckSelfFunction


-- @var lib var
local Spy = {}

-- @var structure used as metatable for spy
local Meta = {}

--- Instance is callable.
-- This call may not return at all.
-- @tparam string text for a last minute message
-- @treturn self
function Meta:__call( str )
	return self:eval( str )
end

local function makeSpy( ... )

	local obj = setmetatable( {}, Meta )

	--- Check whether method is part of self.
	-- @local
	-- @function checkSelf
	-- @raise if called from a method not part of self
	local checkSelf = makeCheckSelfFunction( 'doppelganger', 'obj', obj, 'spy object' )

	-- keep in closure
	local _callbacks = {}
	local _data = {}

	for _,v in ipairs( { ... } ) do
		if type( v ) == 'function' then
			table.insert( _callbacks, v )
		else
			table.insert( _data, v )
		end
	end

	--- Evaluate
	function obj:eval( str )
		checkSelf( self, 'eval' )
		checkType( 'spy object', 1, str, 'string', true )
		local t = { str }
		for _,v in ipairs( ) do
			v( t, unpack( _data ) )
		end
		return obj
	end

	--- Log a traceback
	function obj:log( str, lvl )
		checkSelf( self, 'log' )
		checkType( 'spy object', 1, str, 'string', true )
		checkType( 'spy object', 2, lvl, 'number', true )
		local f = function( t )
			table.insert( t, str, -1 )
			mw.log( debug.traceback( table.concat( t, ': ' ), lvl or 1 ) )
		end
		table.insert( _callbacks, f )
	end

	--- Rise an exception
	function obj:raise( str, lvl )
		checkSelf( self, 'raise' )
		checkType( 'spy object', 1, str, 'string', true )
		checkType( 'spy object', 2, lvl, 'number', true )
		local f = function( t )
			table.insert( t, str, -1 )
			error( table.concat( t, ': ' ), lvl or 1 )
		end
		table.insert( _callbacks, f )
	end

	return obj
end

--- Create a new instance.
-- @tparam vararg ... arguments to be passed on
-- @treturn self
function Spy.new( ... )
	return makeSpy( ... )
end

--- Create a new carp instance.
-- @tparam vararg ... arguments to be passed on
-- @treturn self
function Spy.newCarp( ... )
	local obj = makeSpy( ... )
	obj:log( mw.message.new( 'doppelganger-carp-final' ):plain(), 0 )
	return obj
end

--- Create a new cluck instance.
-- @tparam vararg ... arguments to be passed on
-- @treturn self
function Spy.newCluck( ... )
	local obj = makeSpy( ... )
	obj:log( mw.message.new( 'doppelganger-cluck-final' ):plain(), 0 )
	return obj
end

--- Create a new croak instance.
-- @tparam vararg ... arguments to be passed on
-- @treturn self
function Spy.newCroak( ... )
	local obj = makeSpy( ... )
	obj:rise( mw.message.new( 'doppelganger-croak-final' ):plain(), 0 )
	return obj
end

--- Create a new confess instance.
-- @tparam vararg ... arguments to be passed on
-- @treturn self
function Spy.newConfess( ... )
	local obj = makeSpy( ... )
	obj:rise( mw.message.new( 'doppelganger-confess-final' ):plain(), 0 )
	return obj
end

-- Return the final lib
return Spy
