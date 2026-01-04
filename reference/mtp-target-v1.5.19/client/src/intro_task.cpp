// This file is part of Mtp Target.
// Copyright (C) 2008 Vialek
//
// This program is free software; you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation; either version 2 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License along
// with this program; if not, write to the Free Software Foundation, Inc.,
// 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
//
// Vianney Lecroart - gpl@vialek.com


//
// Includes
//

#include "stdpch.h"

#include <nel/misc/md5.h>

#include <nel/net/callback_client.h>

#include "3d_task.h"
#include "gui_task.h"
#include "time_task.h"
#include "game_task.h"
#include "gui_check.h"
#include "intro_task.h"
#include "mtp_target.h"
#include "login_client.h"
#include "font_manager.h"
#include "network_task.h"
#include "task_manager.h"
#include "background_task.h"
#include "config_file_task.h"
#include "../../common/async_job.h"


//
// Namespaces
//

using namespace NL3D;
using namespace NLMISC;
using namespace NLNET;



//
// Variables
//

//guiSPG<CGuiFrame> testFrame;


uint32	ServerId = -1;
bool		TryToLog = false;
bool		AutoLogin;
bool		ReloadInterfaces = false;

//
// Classes
//


//
// Functions
//

void CIntroTask::displayLoginFrame()
{
	CGuiObjectManager::instance().displayFrame("login");
	CGuiObjectManager::instance().addFrame("donation");
}

void CIntroTask::init()
{
	CTaskManager::instance().add(CBackgroundTask::instance(), 59);
	AutoLogin = CConfigFileTask::instance().configFile().getVar("AutoLogin").asInt() == 1;
	AutoServerId = CConfigFileTask::instance().configFile().getVar("AutoServerId").asInt();

	bool langexists = loadLang();

	loadInterfaces();

	//
	// Set the default frame
	//

	if(langexists)
	{
	 	displayLoginFrame();
	}
	else
	{
		CGuiObjectManager::instance().displayFrame("languages");
	}

	if(LatestVersion > CurrentVersion)
	{
		// need to get the latest version of the game to play
		string ext;
#ifdef NL_OS_WINDOWS
		ext = "exe";
#elif defined(NL_OS_MAC)
		ext = "dmg";
#elif defined(NL_OS_UNIX)
		ext = "tar.bz2";
#endif
		string url("http://www.mtp-target.org/files/mtp-target-setup."+toString(LatestVersion)+"."+ext);

		displayMessage(ucstring("GuiNewVersion"), new CGuiOpenUrlButtonEventBehaviour(url, true), new CGuiExitButtonEventBehaviour);
	}

	//CGuiObjectManager::instance().displayFrame("help1");

	//	if(CConfigFileTask::instance().configFile().getVar("CustomGui").asInt()>0)
	//		CGuiCustom::instance().load("data/gui/custom/");
}

bool CIntroTask::loadLang()
{
	// load the translation file
	bool exists = false;
	string lang("en");
	string cf(CConfigFileTask::instance().tempDirectory()+"lang.txt");
	if(!cf.empty())
	{
		FILE *fp = fopen(cf.c_str(), "rb");
		if(fp)
		{
			char line[20];
			fgets(line, 20, fp);
			uint l = strlen(line);
			if(l > 0)
			{
				if(line[l-1] == '\n') line[l-1] = '\0';
				lang = line;
				exists = true;
			}
			fclose(fp);
		}
	}
	CI18N::load(lang, "en");
	return exists;
}

void CIntroTask::render()
{
	CFontManager::instance().print(CFontManager::TCDebug, 0, 0, "v" + ucstring(ReleaseVersion));
}

void CIntroTask::update() 
{
	if(ReloadInterfaces)
	{
		loadLang();
		loadInterfaces();
		displayLoginFrame();
		ReloadInterfaces = false;
	}

	if(TryToLog && ServerId != -1)
	{
		CGuiObjectManager::instance().clear();

		CInetAddress ip;
		string cookie;
		//nlinfo("CLoginClientMtp::connectToShard(%d)",ServerId);
		ucstring reason = CLoginClientMtp::connectToShard(ServerId,ip,cookie);
		if(!reason.empty())
		{
			AutoLogin = false;
			TryToLog = false;
			CIntroTask::instance().displayLoginFrame();
			error(reason);
			return;
		}

		//nlinfo("CNetworkTask::instance().connect()");
		reason = CNetworkTask::instance().connect(ip, cookie);
		if(!reason.empty())
		{
			AutoLogin = false;
			TryToLog = false;
			CIntroTask::instance().displayLoginFrame();
			error(reason);
			return;
		}

		CGuiObjectManager::instance().clear();
		AutoLogin = false; // autologin only once

		// stop the interface task
		CIntroTask::instance().stop();

		// stop the background task
		CBackgroundTask::instance().stop();

		// go to the game task
		CTaskManager::instance().add(CGameTask::instance(), 5);

		TryToLog = false;
	}
}

void CIntroTask::loadInterfaces() 
{
	loadFrameDonation();
	loadFrameError();
	loadFrameHelp();
	loadFrameLanguages();
	loadFrameLogin();
	loadFrameMessage();
	loadFrameRegister();
	loadFrameSettings();
}

void CIntroTask::doConnection( uint32 serverId ) 
{
	ServerId = serverId;
	TryToLog = true;
}