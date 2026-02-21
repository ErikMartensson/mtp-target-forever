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

#ifndef MTPT_GATE_H
#define MTPT_GATE_H


//
// Includes
//

#include <nel/misc/vector.h>
#include <nel/misc/matrix.h>
#include <nel/3d/u_instance.h>

#include "../../common/editable_element_common.h"

class CGateProxy;


//
// Classes
//

class CGate : public CEditableElementCommon
{
public:
	CGate();
	virtual ~CGate();

	virtual void update(const NLMISC::CVector &pos, const NLMISC::CVector &rot);
	virtual std::string toLuaString();

	void setPosition(const NLMISC::CVector &pos);
	NLMISC::CVector scale() const { return Scale; }
	void setScale(const NLMISC::CVector &scale);

	sint32 score() const { return Score; }
	void setScore(sint32 s) { Score = s; }

	uint8 id() const { return Id; }
	void setId(uint8 i) { Id = i; }

	void show();
	void hide();

	CGateProxy *LuaProxy;

private:
	sint32 Score;
	uint8 Id;
};

#endif
