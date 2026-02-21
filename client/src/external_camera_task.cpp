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

#include <nel/misc/variable.h>

#include "level.h"
#include "3d_task.h"
#include "sky_task.h"
#include "mtp_target.h"
#include "level_manager.h"
#include "entity_manager.h"
#include "external_camera_task.h"


//
// Namespaces
//

using namespace std;
using namespace NLMISC;
using namespace NL3D;


//
// Variables
//

// Runtime-configurable viewport and scissor positions (v1.5.19 style)
static CVariable<float> ViewportX("mtp", "x1", "External camera viewport X position", 590.0f, 0, true);
static CVariable<float> ViewportY("mtp", "y1", "External camera viewport Y position", 350.0f, 0, true);
static CVariable<float> ViewportW("mtp", "w1", "External camera viewport width", 200.0f, 0, true);
static CVariable<float> ViewportH("mtp", "h1", "External camera viewport height", 150.0f, 0, true);
static CVariable<float> ScissorX("mtp", "x2", "External camera scissor X position", 587.0f, 0, true);
static CVariable<float> ScissorY("mtp", "y2", "External camera scissor Y position", 347.0f, 0, true);
static CVariable<float> ScissorW("mtp", "w2", "External camera scissor width", 206.0f, 0, true);
static CVariable<float> ScissorH("mtp", "h2", "External camera scissor height", 156.0f, 0, true);
static CVariable<float> NameScale("mtp", "sc", "External camera name scale factor", 4.0f, 0, true);
static CVariable<float> DistToFollowInExternalCam("mtp", "DistToFollowInExternalCam", "Distance threshold for entity-following mode", 10.0f, 0, true);
static CVariable<bool> DisplayExternalCamera("mtp", "DisplayExternalCamera", "Enable external camera display", true, 0, true);


//
// Functions
//

void CExternalCameraTask::init()
{
	EnableExternalCamera = false;
	FollowEntities = true;
}

void CExternalCameraTask::render()
{
	// Skip if disabled or no level/external cameras defined
	if (!DisplayExternalCamera || !EnableExternalCamera || !CLevelManager::getInstance().levelPresent())
		return;

	if (CLevelManager::getInstance().currentLevel().ExternalCameras.empty())
		return;

	// Save the current camera matrix
	CMatrix oldmat = C3DTask::getInstance().scene().getCam().getMatrix();

	// Reference resolution for viewport calculations
	float w = 800.0f;
	float h = 600.0f;

	// Setup viewport and scissor for the picture-in-picture window
	CViewport vp;
	CScissor s;
	vp.init(ViewportX/w, ViewportY/h, ViewportW/w, ViewportH/h);
	s.init(ScissorX/w, ScissorY/h, ScissorW/w, ScissorH/h);

	// Find the nearest entity that's above or at the same height as us
	CVector MyPos = CEntityManager::getInstance()[CMtpTarget::getInstance().controler().getControledEntity()].interpolator().currentPosition();

	float mindist = 99999.0f;
	CVector mindistpos;

	for (uint i = 0; i < 256; i++)
	{
		CEntity *e = CEntityManager::getInstance().entities()[i];
		// Check if entity is valid, not ourselves, still in flight (not collided), and not a spectator
		if (e->type() != CEntity::Unknown &&
			e->id() != CMtpTarget::getInstance().controler().getControledEntity() &&
			!e->collided() &&
			!e->spectator())
		{
			CVector epos = e->interpolator().currentPosition();
			CVector tmp = MyPos - epos;
			if (tmp.norm() < mindist && epos.z + 0.1f >= MyPos.z)
			{
				mindist = tmp.norm();
				mindistpos = epos;
			}
		}
	}

	// Setup the camera matrix
	CMatrix m;
	m.identity();

	if (FollowEntities && mindist < DistToFollowInExternalCam)
	{
		// Entity-following mode: look from our position toward the nearest entity
		lookAt(m, MyPos + CVector(0.0f, 0.0f, 0.04f), mindistpos, CVector(0.0f, 0.0f, 1.0f));
	}
	else
	{
		// Fixed position mode: use the first external camera defined in the level
		m.setPos(CLevelManager::getInstance().currentLevel().ExternalCameras[0].first);
		m.setRot(CLevelManager::getInstance().currentLevel().ExternalCameras[0].second);
	}

	// Apply the camera matrix and viewport settings to main scene
	C3DTask::getInstance().scene().getCam().setMatrix(m);
	C3DTask::getInstance().scene().setViewport(vp);
	C3DTask::getInstance().driver().setViewport(vp);
	C3DTask::getInstance().driver().setScissor(s);

	// Apply to sky scene as well
	CSkyTask::getInstance().skyScene()->getCam().setMatrix(m);
	CSkyTask::getInstance().skyScene()->setViewport(vp);

	// Clear buffers and render sky first (fog disabled)
	C3DTask::getInstance().driver().clearBuffers();
	C3DTask::getInstance().driver().enableFog(false);
	CSkyTask::getInstance().skyScene()->render();

	// Render main scene with fog
	C3DTask::getInstance().driver().enableFog(true);
	C3DTask::getInstance().scene().render();

	// Render entity names with scaled font (fog disabled)
	C3DTask::getInstance().driver().enableFog(false);
	CEntityManager::getInstance().renderNames(NameScale);

	// Restore full viewport and camera for main scene
	vp.init(0, 0, 1, 1);
	s.init(0, 0, 1, 1);
	C3DTask::getInstance().scene().setViewport(vp);
	C3DTask::getInstance().driver().setViewport(vp);
	C3DTask::getInstance().driver().setScissor(s);
	C3DTask::getInstance().scene().getCam().setMatrix(oldmat);

	// Restore sky scene viewport
	CSkyTask::getInstance().skyScene()->setViewport(vp);
	CSkyTask::getInstance().skyScene()->getCam().setMatrix(oldmat);
}
