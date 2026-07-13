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

#include "3d_task.h"
#include "hud_task.h"
#include "time_task.h"
#include "game_task.h"
#include "chat_task.h"
#include "intro_task.h"
#include "score_task.h"
#include "mtp_target.h"
#include "font_manager.h"
#include "task_manager.h"
#include "network_task.h"
#include "sound_manager.h"
#include "entity_manager.h"
#include "background_task.h"
#include "level_manager.h"
#include "config_file_task.h"
#include "resource_manager2.h"


//
// Namespaces
//

using namespace std;
using namespace NL3D;
using namespace NLMISC;


//
// Variables
//


//
// Functions
//
	
void CGameTask::init()
{
	CTaskManager::getInstance().add(CLevelManager::getInstance(), 60);
	CTaskManager::getInstance().add(CHudTask::getInstance(), 1020);
	CTaskManager::getInstance().add(CScoreTask::getInstance(), 1030);
	CTaskManager::getInstance().add(CChatTask::getInstance(), 1040);

	bool tocFound = false;
	//tocFound = CGuiCustom::getInstance().load("data/gui/custom/");
	tocFound =  CGuiCustom::getInstance().count()>0;
	if(!tocFound && CConfigFileTask::getInstance().configFile().getVar("CaptureMouse").asInt() == 1)
		C3DTask::getInstance().captureCursor(true);

	// Initialize pause menu state
	_pauseMenuActive = false;
	_pauseMenuLoaded = false;
}

void CGameTask::update()
{
	// Handle options menu if active
	if(COptionsMenu::getInstance().isActive())
	{
		COptionsMenu::getInstance().update();
		return;
	}

	// Handle pause menu if active
	if(_pauseMenuActive)
	{
		// Handle Resume button
		if(_resumeButton->pressed())
		{
			togglePauseMenu();
			return;
		}

		// Handle Options button - show options menu
		if(_optionsButton->pressed())
		{
			COptionsMenu::getInstance().show(this);
			return;
		}

		// Handle Disconnect button - return to main menu
		if(_disconnectButton->pressed())
		{
			// Hide pause menu
			CGuiObjectManager::getInstance().objects.clear();
			_pauseMenuActive = false;

			// Use the existing error handling to properly disconnect and return to menu
			// This triggers a clean shutdown and restart of the intro task
			CMtpTarget::getInstance().error(string("Disconnected."));
			return;
		}

		// Handle Quit button - exit game entirely
		if(_quitButton->pressed())
		{
			CTaskManager::getInstance().exit();
			return;
		}
	}
}

void CGameTask::render()
{
	C3DTask::getInstance().clear();
}

void CGameTask::release()
{
}

void CGameTask::stop()
{
	ITask::stop();
	CLevelManager::getInstance().stop();
	CHudTask::getInstance().stop();
	CScoreTask::getInstance().stop();
	CChatTask::getInstance().stop();

	// Clear pause/options menu state
	if(_pauseMenuActive || COptionsMenu::getInstance().isActive())
	{
		CGuiObjectManager::getInstance().objects.clear();
		_pauseMenuActive = false;
		COptionsMenu::getInstance().hide();
	}
}

void CGameTask::togglePauseMenu()
{
	// If options menu is active, close it and return to pause menu
	if(COptionsMenu::getInstance().isActive())
	{
		COptionsMenu::getInstance().hide();
		CGuiObjectManager::getInstance().objects.clear();
		CGuiObjectManager::getInstance().objects.push_back(_pauseFrame);
		return;
	}

	// Load pause menu XML on first use
	if(!_pauseMenuLoaded)
	{
		guiSPG<CGuiXml> xml = CGuiXmlManager::getInstance().Load("pause_menu.xml");
		_pauseFrame = (CGuiFrame *)xml->get("pauseFrame");
		_resumeButton = (CGuiButton *)xml->get("bResume");
		_optionsButton = (CGuiButton *)xml->get("bOptions");
		_disconnectButton = (CGuiButton *)xml->get("bDisconnect");
		_quitButton = (CGuiButton *)xml->get("bQuit");
		_pauseMenuLoaded = true;
	}

	if(_pauseMenuActive)
	{
		// Hide pause menu
		CGuiObjectManager::getInstance().objects.clear();
		_pauseMenuActive = false;
	}
	else
	{
		// Show pause menu
		CGuiObjectManager::getInstance().objects.push_back(_pauseFrame);
		_pauseMenuActive = true;
	}
}

void CGameTask::onOptionsBack()
{
	// Return to pause menu
	CGuiObjectManager::getInstance().objects.clear();
	CGuiObjectManager::getInstance().objects.push_back(_pauseFrame);
}

void CGameTask::onOptionsApply()
{
	// From the pause menu, just save settings - don't restart
	// User will need to restart manually (which would disconnect them anyway)
	nlinfo("Video settings saved. Changes will take effect on next restart.");
	CChatTask::getInstance().addLine("Video settings saved. They will take effect on next game restart.");
}

