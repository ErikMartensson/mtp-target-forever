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

#include <string>

#include <nel/misc/path.h>

#include "lua_nel.h"


//
// Namespaces
//

using namespace std;
using namespace NLMISC;


//
// Classes
//

#define method(class, name) {#name, &class::name}

const char CLuaVector::className[] = "CVector";

int CLuaVector::getX(lua_State *L)
{
	lua_pushnumber(L, (lua_Number)this->x);
	return 1;
}

int CLuaVector::getY(lua_State *L)
{
	lua_pushnumber(L, (lua_Number)this->y);
	return 1;
}

int CLuaVector::getZ(lua_State *L)
{
	lua_pushnumber(L, (lua_Number)this->z);
	return 1;
}

int CLuaVector::setX(lua_State *L)
{
	this->x = (float)luaL_checknumber(L, 1);
	return 0;
}

int CLuaVector::setY(lua_State *L)
{
	this->y = (float)luaL_checknumber(L, 1);
	return 0;
}

int CLuaVector::setZ(lua_State *L)
{
	this->z = (float)luaL_checknumber(L, 1);
	return 0;
}

Lunar<CLuaVector>::RegType CLuaVector::methods[] = {
	bind_method(CLuaVector, getX),
	bind_method(CLuaVector, getY),
	bind_method(CLuaVector, getZ),
	bind_method(CLuaVector, setX),
	bind_method(CLuaVector, setY),
	bind_method(CLuaVector, setZ),
	{0,0}
};


const char CLuaAngleAxis::className[] = "CAngleAxis";

Lunar<CLuaAngleAxis>::RegType CLuaAngleAxis::methods[] = {
	{0,0}
};


const char CLuaRGBA::className[] = "CRGBA";

Lunar<CLuaRGBA>::RegType CLuaRGBA::methods[] = {
	{0,0}
};


