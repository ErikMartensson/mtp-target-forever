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


//
// Includes
//

#include "stdpch.h"

#include "gate.h"
#include "gate_lua_proxy.h"


//
// Namespaces
//

using namespace std;
using namespace NLMISC;


//
// Lunar registration
//

const char CGateProxy::className[] = "CGateProxy";

Lunar<CGateProxy>::RegType CGateProxy::methods[] =
{
	{"getUserData", &CGateProxy::getUserData},
	{"setUserData", &CGateProxy::setUserData},
	{"position", &CGateProxy::getPos},
	{"setPosition", &CGateProxy::setPos},
	{"scale", &CGateProxy::getScale},
	{"setScale", &CGateProxy::setScale},
	{"score", &CGateProxy::getScore},
	{"setScore", &CGateProxy::setScore},
	{0, 0}
};


//
// Functions
//

int CGateProxy::setMetatable(lua_State *L)
{
	int res = lua_setmetatable(L, -2);
	if (res == 0)
		nlwarning("CGateProxy: cannot set metatable");
	return 0;
}

int CGateProxy::getUserData(lua_State *L)
{
	lua_getref(L, LuaUserDataRef);
	return 1;
}

int CGateProxy::setUserData(lua_State *L)
{
	LuaUserData = lua_touserdata(L, 1);
	LuaUserDataRef = lua_ref(L, 1);
	return 0;
}

int CGateProxy::getPos(lua_State *L)
{
	if (!_gate)
		return 0;

	Pos.x = _gate->position().x;
	Pos.y = _gate->position().y;
	Pos.z = _gate->position().z;
	Lunar<CLuaVector>::push(L, &Pos);
	return 1;
}

int CGateProxy::setPos(lua_State *L)
{
	if (!_gate)
		return 0;

	CLuaVector *v = Lunar<CLuaVector>::check(L, 1);
	if (v)
	{
		_gate->setPosition(CVector(v->x, v->y, v->z));
	}
	return 0;
}

int CGateProxy::getScale(lua_State *L)
{
	if (!_gate)
		return 0;

	ScaleVec.x = _gate->scale().x;
	ScaleVec.y = _gate->scale().y;
	ScaleVec.z = _gate->scale().z;
	Lunar<CLuaVector>::push(L, &ScaleVec);
	return 1;
}

int CGateProxy::setScale(lua_State *L)
{
	if (!_gate)
		return 0;

	CLuaVector *v = Lunar<CLuaVector>::check(L, 1);
	if (v)
	{
		_gate->setScale(CVector(v->x, v->y, v->z));
	}
	return 0;
}

int CGateProxy::getScore(lua_State *L)
{
	if (!_gate)
		return 0;

	lua_pushnumber(L, _gate->score());
	return 1;
}

int CGateProxy::setScore(lua_State *L)
{
	if (!_gate)
		return 0;

	sint32 score = (sint32)luaL_checknumber(L, 1);
	_gate->setScore(score);
	return 0;
}
