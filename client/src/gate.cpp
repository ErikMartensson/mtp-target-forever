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

#include <nel/misc/path.h>

#include "gate.h"
#include "3d_task.h"
#include "gate_lua_proxy.h"


//
// Namespaces
//

using namespace std;
using namespace NLMISC;
using namespace NL3D;


//
// Functions
//

CGate::CGate() : CEditableElementCommon()
{
	LuaProxy = 0;
	Score = 0;
	Id = 0;

	// Use a simple box shape for the gate visual
	ShapeName = CPath::lookup("col_box.shape", false);

	if (!ShapeName.empty())
	{
		Mesh = C3DTask::getInstance().scene().createInstance(ShapeName);
		if (Mesh.empty())
		{
			nlwarning("CGate: Can't load '%s'", ShapeName.c_str());
		}
	}
}

CGate::~CGate()
{
	if (!Mesh.empty())
	{
		C3DTask::getInstance().scene().deleteInstance(Mesh);
	}
	if (LuaProxy)
	{
		delete LuaProxy;
		LuaProxy = 0;
	}
}

void CGate::update(const CVector &pos, const CVector &rot)
{
	setPosition(pos);
}

string CGate::toLuaString()
{
	string res;
	res = "{ Position = CVector(" + toString(Position.x) + ", " + toString(Position.y) + ", " + toString(Position.z) + ")";
	res += ", Scale = CVector(" + toString(Scale.x) + ", " + toString(Scale.y) + ", " + toString(Scale.z) + ")";
	res += ", Score = " + toString(Score);
	res += " }";
	return res;
}

void CGate::setPosition(const CVector &pos)
{
	Position = pos;
	if (!Mesh.empty())
	{
		Mesh.setPos(pos);
	}
}

void CGate::setScale(const CVector &scale)
{
	Scale = scale;
	if (!Mesh.empty())
	{
		Mesh.setScale(scale);
	}
}

void CGate::show()
{
	if (!Mesh.empty())
	{
		Mesh.show();
	}
}

void CGate::hide()
{
	if (!Mesh.empty())
	{
		Mesh.hide();
	}
}
