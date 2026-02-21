/* Copyright, 2010 Tux Target
 * Copyright, 2003 Melting Pot
 *
 * This file is part of Tux Target.
 * Tux Target is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2, or (at your option)
 * any later version.

 * Tux Target is distributed in the hope that it will be useful, but
 * WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
 * General Public License for more details.

 * You should have received a copy of the GNU General Public License
 * along with Tux Target; see the file COPYING. If not, write to the
 * Free Software Foundation, Inc., 59 Temple Place - Suite 330, Boston,
 * MA 02111-1307, USA.
 */

#ifndef _GATE_LUA_PROXY_H_
#define _GATE_LUA_PROXY_H_

#include "../../common/lunar.h"
#include "../../common/lua_nel.h"

class CGate;

class CGateProxy
{

public:
	CGateProxy(lua_State *luaSession)
	{
		_gate = 0;
		LuaUserData = 0;
		LuaUserDataRef = 0;
	}

	CGateProxy(lua_State *luaSession, CGate *gate)
	{
		_gate = gate;
		LuaUserData = 0;
		LuaUserDataRef = 0;
	}

	~CGateProxy()
	{
	}

	int setMetatable(lua_State *L);
	int getUserData(lua_State *luaSession);
	int setUserData(lua_State *luaSession);

	int getPos(lua_State *luaSession);
	int setPos(lua_State *luaSession);
	int getScale(lua_State *luaSession);
	int setScale(lua_State *luaSession);
	int getScore(lua_State *luaSession);
	int setScore(lua_State *luaSession);

	static const char className[];
	static Lunar<CGateProxy>::RegType methods[];
private:
	void		*LuaUserData;
	int			 LuaUserDataRef;
	CGate *_gate;
	CLuaVector Pos;
	CLuaVector ScaleVec;
};


#endif
