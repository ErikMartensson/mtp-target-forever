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

#ifndef MTPT_EXTERNAL_CAMERA_TASK_H
#define MTPT_EXTERNAL_CAMERA_TASK_H


//
// Includes
//

#include <nel/misc/singleton.h>


//
// Classes
//

class CExternalCameraTask : public NLMISC::CSingleton<CExternalCameraTask>, public ITask
{
public:

	CExternalCameraTask() { }

	virtual void init();
	virtual void update() { }
	virtual void render();
	virtual void release() { }

	virtual std::string name() const { return "CExternalCameraTask"; }

	void setExternalCamera(bool on, bool followEntities = true) { EnableExternalCamera = on; FollowEntities = followEntities; }
	void switchExternalCamera() { EnableExternalCamera = !EnableExternalCamera; }
	bool isEnabled() const { return EnableExternalCamera; }

private:

	bool EnableExternalCamera;
	bool FollowEntities;
};

#endif
