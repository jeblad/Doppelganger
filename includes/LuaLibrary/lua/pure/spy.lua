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
-- Redirects to objects eval method.
-- @tparam string text for a last minute message
-- @treturn self
function Meta:__call( text )
	return self:eval( text )
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

	-- dispatch on type
	for _,v in ipairs( { ... } ) do
		if type( v ) == 'function' then
			table.insert( _callbacks, v )
		else
			table.insert( _data, v )
		end
	end

	--- Evaluate graph.
	-- @tparam nil|string text to be reported on evaluation of the compute grap
	-- @treturn self
	function obj:eval( text )
		checkSelf( self, 'eval' )
		checkType( 'spy object', 1, text, 'string', true )
		local t = { text }
		for _,v in ipairs( _callbacks ) do
			v( t, unpack( _data ) )
		end
		return self
	end

	--- Add a callback.
	-- @tparam function func to be registered on the compute graph.
	-- @tparam nil|number index to inject the callbak
	-- @treturn self
	function obj:addCallback( func, index )
		checkSelf( self, 'eval' )
		checkType( 'spy object', 1, func, 'function', false )
		checkType( 'spy object', 2, index, 'number', true )
		if index then
			table.insert( _callbacks, index, func )
		else
			table.insert( _callbacks, func )
		end
		return self
	end

	--- Log a traceback.
	-- @tparam nil|string text to be reported on evaluation of the compute grap
	-- @tparam nil|number level to start reporting
	-- @treturn self
	function obj:log( text, level )
		checkSelf( self, 'log' )
		checkType( 'spy object', 1, text, 'string', true )
		checkType( 'spy object', 2, level, 'number', true )
		local f = function( t )
			local tmp = { text }
			for _,v in ipairs( t ) do
				table.insert( tmp, v )
			end
			if (level or 4) == 0 then
				mw.log( table.concat( tmp, ': ' ) )
			else
				mw.log( debug.traceback( table.concat( tmp, ': ' ), level or 4 ) )
			end
		end
		table.insert( _callbacks, f )
		return self
	end

	--- Rise an exception.
	-- The Scribunto implementation makes it difficult to do this correctly.
	-- @tparam nil|string text to be reported on evaluation of the compute grap
	-- @tparam nil|number level to start reporting
	-- @treturn self
	function obj:raise( text, level )
		checkSelf( self, 'raise' )
		checkType( 'spy object', 1, text, 'string', true )
		checkType( 'spy object', 2, level, 'number', true )
		local f = function( t )
			local tmp = { text }
			for _,v in ipairs( t ) do
				table.insert( tmp, v )
			end
			error( table.concat( tmp, ': ' ), level or 4 )
		end
		table.insert( _callbacks, f )
		return self
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
-- This convenience function register a log callback.
-- @tparam vararg ... arguments to be passed on
-- @treturn self
function Spy.newCarp( ... )
	local obj = makeSpy( ... )
	obj:log( mw.message.new( 'doppelganger-carp-final' ):plain(), 0 )
	return obj
end

--- Create a new cluck instance.
-- This convenience function register a log callback.
-- @tparam vararg ... arguments to be passed on
-- @treturn self
function Spy.newCluck( ... )
	local obj = makeSpy( ... )
	obj:log( mw.message.new( 'doppelganger-cluck-final' ):plain(), 4 )
	return obj
end

--- Create a new croak instance.
-- This convenience function register a raise callback.
-- The Scribunto implementation makes it difficult to do this correctly.
-- @raise unconditionally
-- @tparam vararg ... arguments to be passed on
-- @treturn self
function Spy.newCroak( ... )
	local obj = makeSpy( ... )
	obj:raise( mw.message.new( 'doppelganger-croak-final' ):plain(), 0 )
	return obj
end

--- Create a new confess instance.
-- This convenience function register a raise callback.
-- The Scribunto implementation makes it difficult to do this correctly.
-- @raise unconditionally
-- @tparam vararg ... arguments to be passed on
-- @treturn self
function Spy.newConfess( ... )
	local obj = makeSpy( ... )
	obj:raise( mw.message.new( 'doppelganger-confess-final' ):plain(), 4 )
	return obj
end

-- Return the final lib
return Spy
