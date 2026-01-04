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

#ifdef NL_OS_WINDOWS
#	define NOMINMAX
#	include <windows.h>
#endif

#include <set>
#include <nel/net/callback_client.h>

#include "3d_task.h"
#include "gui_task.h"
#include "time_task.h"
#include "game_task.h"
#include "intro_task.h"
#include "mtp_target.h"
#include "login_client.h"
#include "font_manager.h"
#include "network_task.h"
#include "task_manager.h"
#include "background_task.h"
#include "resource_manager2.h"
#include "config_file_task.h"


//
// Namespaces
//

using namespace std;
using namespace NL3D;
using namespace NLMISC;
using namespace NLNET;


//
// Variables
//


//
// Classes
//
class CGuiServerButtonEventBehaviour : public CGuiButtonEventBehaviour
{
public:
	CGuiServerButtonEventBehaviour(uint32 serverId)
	{
		_serverId = serverId;
	}

	virtual ~CGuiServerButtonEventBehaviour()
	{
		
	}

	virtual void onPressed()
	{
		CIntroTask::getInstance().doConnectionOnLine(_serverId);
	}
private:
	uint32 _serverId;
};

class CGuiExitButtonEventBehaviour : public CGuiButtonEventBehaviour
{
public:
	CGuiExitButtonEventBehaviour(){}
	virtual ~CGuiExitButtonEventBehaviour() {}
	virtual void onPressed()
	{
		CTaskManager::getInstance().exit();
	}
private:
};

class CGuiServerListConnectButtonEventBehaviour : public CGuiButtonEventBehaviour
{
public:
	CGuiServerListConnectButtonEventBehaviour(CGuiListView *serverListView) {_serverListView=serverListView;}
	virtual ~CGuiServerListConnectButtonEventBehaviour() {}
	virtual void onPressed()
	{
		int rowId = _serverListView->selectedRow();
		nlinfo("user want to connect to server : %d",rowId);
		if(rowId>=0)
			CIntroTask::getInstance().doConnectionOnLine(rowId);
	}
private:
	guiSPG<CGuiListView> _serverListView;
};

class CGuiLaunchServerEventBehaviour : public CGuiListViewEventBehaviour
{
public:
	CGuiLaunchServerEventBehaviour() {}
	virtual ~CGuiLaunchServerEventBehaviour() {}
	virtual void onPressed(int rowId)
	{
		nlinfo("user want to connect to server : %d",rowId);
		if(rowId>=0)
			CIntroTask::getInstance().doConnectionOnLine(rowId);
	}
private:
};

//
// Functions
//


void CIntroTask::reset()
{
	CGuiObjectManager::getInstance().objects.clear();
	State=eInit;
}

void CIntroTask::init()
{
	CTaskManager::getInstance().add(CBackgroundTask::getInstance(), 59);
	_autoLogin = CConfigFileTask::getInstance().configFile().getVar("AutoLogin").asInt();
	if(_autoLogin!=0)
		AutoServerId = CConfigFileTask::getInstance().configFile().getVar("AutoServerId").asInt();
	else if(AutoServerId!=-1)
		_autoLogin = 1; //auto online login

	// Check for LAN auto-connect via command line
	if(!AutoLanHost.empty())
	{
		_autoLogin = 2; // Use 2 for LAN auto-connect
		CConfigFileTask::getInstance().configFile().getVar("ServerHost").setAsString(AutoLanHost);
		if(!AutoLanUser.empty())
			CConfigFileTask::getInstance().configFile().getVar("Login").setAsString(AutoLanUser);
	}

	reset();
}

void CIntroTask::error(string &reason)
{
	guiSPG<CGuiXml> xml = CGuiXmlManager::getInstance().Load("error_server.xml");
	_errorServerFrame = (CGuiFrame *)xml->get("errorServerFrame");
	guiSPG<CGuiText>  errorServerReason = (CGuiText *)xml->get("errorServerReason");
	CGuiObjectManager::getInstance().objects.push_back(_errorServerFrame);

	errorServerReason->text = reason;
}


void CIntroTask::updateInit()
{
	if(State!=eInit) return;

#if 0
	testFrame = new CGuiFrame();
	/*
	testFrame->minWidth(100);
	testFrame->minHeight(100);
	*/

	guiSPG<CGuiListView> listView = new CGuiListView;
	testFrame->element(listView);
	listView->eventBehaviour = new CGuiLaunchServerEventBehaviour;

	guiSPG<CGuiHBox> header = new CGuiHBox;
	header->elements.push_back(new CGuiText(string("Server")));
	header->elements.push_back(new CGuiText(string("Players")));
	header->elements.push_back(new CGuiText(string("Ping")));
	listView->rows.push_back(header);
	
	guiSPG<CGuiHBox> row1 = new CGuiHBox;
	row1->elements.push_back(new CGuiText(string("Easy")));
	row1->elements.push_back(new CGuiText(string("12")));
	row1->elements.push_back(new CGuiText(string("34")));
	listView->rows.push_back(row1);
	
	guiSPG<CGuiHBox> row2 = new CGuiHBox;
	row2->elements.push_back(new CGuiText(string("Expert")));
	row2->elements.push_back(new CGuiText(string("56")));
	row2->elements.push_back(new CGuiText(string("78")));
	listView->rows.push_back(row2);
	
	guiSPG<CGuiHBox> row3 = new CGuiHBox;
	row3->elements.push_back(new CGuiText(string("Testing")));
	row3->elements.push_back(new CGuiText(string("01")));
	row3->elements.push_back(new CGuiText(string("120")));
	listView->rows.push_back(row3);
	
	guiSPG<CGuiHBox> row4 = new CGuiHBox;
	row4->elements.push_back(new CGuiText(string("Fake one")));
	row4->elements.push_back(new CGuiText(string("0")));
	row4->elements.push_back(new CGuiText(string("3")));
	listView->rows.push_back(row4);
	
	
	CGuiObjectManager::getInstance().objects.push_back(testFrame);
	State = eNone;
	
#else
	guiSPG<CGuiXml> xml = 0;
	xml = CGuiXmlManager::getInstance().Load("menu.xml");
	menuFrame = (CGuiFrame *)xml->get("menuFrame");
	howToPlay = (CGuiButton *)xml->get("bHowToPlay");
	playOnLineButton = (CGuiButton *)xml->get("bPlayOnline");
	playOnLanButton = (CGuiButton *)xml->get("bPlayOnlan");
	optionsButton = (CGuiButton *)xml->get("bOptions");
	exitButton3 = (CGuiButton *)xml->get("bExit");
	exitButton3->eventBehaviour = new CGuiExitButtonEventBehaviour();
	
	xml = CGuiXmlManager::getInstance().Load("login.xml");
	loginFrame = (CGuiFrame *)xml->get("loginFrame");
	loginText = (CGuiText*)xml->get("loginEntry");
	loginText->text = CConfigFileTask::getInstance().configFile().getVar("Login").asString();
	passwordText = (CGuiText*)xml->get("passwordEntry");
	passwordText->text = CConfigFileTask::getInstance().configFile().getVar("Password").asString();
	loginButton = (CGuiButton *)xml->get("bLogin");
	backButton1 = (CGuiButton *)xml->get("bBack");

	xml = CGuiXmlManager::getInstance().Load("login_lan.xml");
	loginLanFrame = (CGuiFrame *)xml->get("loginFrame");
	loginLanText = (CGuiText*)xml->get("loginEntry");
	loginLanText->text = CConfigFileTask::getInstance().configFile().getVar("Login").asString();
	passwordLanText = (CGuiText*)xml->get("passwordEntry");
	passwordLanText->text = CConfigFileTask::getInstance().configFile().getVar("Password").asString();
	serverLanText = (CGuiText*)xml->get("serverEntry");
	serverLanText->text = CConfigFileTask::getInstance().configFile().getVar("ServerHost").asString();
	loginLanButton = (CGuiButton *)xml->get("bLogin");
	backLanButton1 = (CGuiButton *)xml->get("bBack");
	
	xml = CGuiXmlManager::getInstance().Load("server_list.xml");
	serverListFrame = (CGuiFrame *)xml->get("serverListFrame");
	serverVbox = (CGuiVBox *)xml->get("serverVbox");
	backButton2 = (CGuiButton *)xml->get("bBack");

	xml = CGuiXmlManager::getInstance().Load("options.xml");
	optionsFrame = (CGuiFrame *)xml->get("optionsFrame");
	resolutionButton = (CGuiButton *)xml->get("bResolution");
	resolutionText = (CGuiText *)xml->get("txtResolution");
	fullscreenButton = (CGuiButton *)xml->get("bFullscreen");
	fullscreenText = (CGuiText *)xml->get("txtFullscreen");
	vsyncButton = (CGuiButton *)xml->get("bVSync");
	vsyncText = (CGuiText *)xml->get("txtVSync");
	applyButton = (CGuiButton *)xml->get("bApply");
	optionsBackButton = (CGuiButton *)xml->get("bOptionsBack");
	pendingFullscreen = false;
	pendingVSync = false;
	selectedResolutionIndex = 0;
	originalResolutionIndex = 0;
	originalFullscreen = false;
	originalVSync = false;

	serverListBackButton	= new CGuiButton();
	serverListBackButton->element(new CGuiText("Back"));
	serverListBackButton->minWidth(80);
	
	serverListView = new CGuiListView;

	if(_autoLogin==1)
	{
		CGuiObjectManager::getInstance().objects.push_back(loginFrame);
		State = eLoginOnline;
	}
	else if(_autoLogin==2)
	{
		CGuiObjectManager::getInstance().objects.push_back(loginLanFrame);
		State = eLoginOnlan;
	}
	else
	{
		CGuiObjectManager::getInstance().objects.push_back(menuFrame);
		State = eMenu;
	}
#endif
	
	if(CConfigFileTask::getInstance().configFile().getVar("CustomGui").asInt()>0)
		CGuiCustom::getInstance().load("data/gui/custom/");
	
}

void CIntroTask::updateMenu()
{
	if(State!=eMenu) return;

	if(howToPlay->pressed())
	{
		openURL("http://www.mtp-target.org/index.php?page=./lang/en/howto-play.php");
	}
	if(playOnLineButton->pressed())
	{
		CGuiObjectManager::getInstance().objects.clear();
		CGuiObjectManager::getInstance().objects.push_back(loginFrame);
		State = eLoginOnline;
	}
	if(playOnLanButton->pressed())
	{
		CGuiObjectManager::getInstance().objects.clear();
		CGuiObjectManager::getInstance().objects.push_back(loginLanFrame);
		State = eLoginOnlan;
	}
	if(optionsButton->pressed())
	{
		CGuiObjectManager::getInstance().objects.clear();
		populateResolutions();

		// Load current fullscreen/vsync state from config
		pendingFullscreen = CConfigFileTask::getInstance().configFile().getVar("Fullscreen").asInt() == 1;
		pendingVSync = CConfigFileTask::getInstance().configFile().getVar("VSync").asInt() == 1;

		// Store original settings to detect changes
		originalResolutionIndex = selectedResolutionIndex;
		originalFullscreen = pendingFullscreen;
		originalVSync = pendingVSync;

		// Update button text to show current state
		fullscreenText->text = pendingFullscreen ? "ON" : "OFF";
		vsyncText->text = pendingVSync ? "ON" : "OFF";

		CGuiObjectManager::getInstance().objects.push_back(optionsFrame);
		State = eOptions;
	}

}

void CIntroTask::updateLoginOnline()
{
	if(State!=eLoginOnline) return;

	if(backButton1->pressed())
	{
		State = eMenu;
		CGuiObjectManager::getInstance().objects.clear();
		CGuiObjectManager::getInstance().objects.push_back(menuFrame);	
		return;
	}

	if(loginButton->pressed() || _autoLogin==1)
	{
		loginText->text = NLMISC::strlwr(loginText->text);
		passwordText->text = NLMISC::strlwr(passwordText->text);
		CConfigFileTask::getInstance().configFile().getVar("Login").setAsString(loginText->text);
		CConfigFileTask::getInstance().configFile().getVar("Password").setAsString(passwordText->text);
		CConfigFileTask::getInstance().configFile().save();
		_errorServerFrame = 0;

		string loginServer = CConfigFileTask::getInstance().configFile().getVar("LSHost").asString();
		string reason = CLoginClientMtp::authenticate(loginServer, loginText->text, passwordText->text, 0);
		if(!reason.empty())
		{
			_autoLogin = 0;
			error(reason);
			CGuiObjectManager::getInstance().objects.push_back(loginFrame);
		}
		else
		{
			ServerId = 0;

			// TODO skeet: if CLoginClientMtp::ShardList.size() is 0 then you must
			// handle the case where no shard are available

			serverListFrame = new CGuiFrame();

			guiSPG<CGuiVBox> serverListVBox = new CGuiVBox;
			serverListFrame->element(serverListVBox);

			serverListView->rows.clear();
			serverListVBox->elements.push_back(serverListView);
			serverListView->eventBehaviour = new CGuiLaunchServerEventBehaviour;
			
			guiSPG<CGuiHBox> header = new CGuiHBox;
			header->elements.push_back(new CGuiText(string("Server")));
			header->elements.push_back(new CGuiText(string("Players")));
			//header->elements.push_back(new CGuiText(string("Ping")));
			serverListView->rows.push_back(header);
			
			
			//serverVbox->elements.clear();
			for(uint i = 0; i < CLoginClientMtp::ShardList.size(); i++)
			{
				guiSPG<CGuiHBox> row = new CGuiHBox;
				row->elements.push_back(new CGuiText(CLoginClientMtp::ShardList[i].ShardName));
				row->elements.push_back(new CGuiText(toString(CLoginClientMtp::ShardList[i].ShardNbPlayers)));
				//row->elements.push_back(new CGuiText(string("34"))); //ping
				serverListView->rows.push_back(row);
				/*
				guiSPG<CGuiXml> xml = 0;
				xml = CGuiXmlManager::getInstance().Load("server_item.xml");
				{
					guiSPG<CGuiHBox> serverItemHBox = (CGuiHBox *)xml->get("serverItemHBox");
					guiSPG<CGuiText> btextServer = (CGuiText *)xml->get("btextServer");
					guiSPG<CGuiButton> serverButton = (CGuiButton *)xml->get("bServer");
					serverButton->eventBehaviour = new CGuiServerButtonEventBehaviour(i);
					btextServer->text = CLoginClientMtp::ShardList[i].ShardName;
					serverVbox->elements.push_back(serverItemHBox);
				}
				*/
			}


			guiSPG<CGuiButton> serverListConnectButton	= new CGuiButton();
			serverListConnectButton->element(new CGuiText("Connect"));
			serverListConnectButton->minWidth(80);
			serverListConnectButton->eventBehaviour = new CGuiServerListConnectButtonEventBehaviour(serverListView);
			guiSPG<CGuiHBox> serverListButtonBox = new CGuiHBox;
			serverListButtonBox->elements.push_back(serverListConnectButton);
			serverListButtonBox->elements.push_back(serverListBackButton);
			
			CGuiSpacer *sp = new CGuiSpacer;
			sp->minHeight(10);
			serverListVBox->elements.push_back(sp);

			serverListVBox->elements.push_back(serverListButtonBox);

			CGuiObjectManager::getInstance().objects.clear();
			CGuiObjectManager::getInstance().objects.push_back(serverListFrame);
			State = eServerList;
		}

	}
		
}

void CIntroTask::updateLoginOnlan()
{
	if(State!=eLoginOnlan) return;
	
	if(backLanButton1->pressed())
	{
		State = eMenu;
		CGuiObjectManager::getInstance().objects.clear();
		CGuiObjectManager::getInstance().objects.push_back(menuFrame);	
		return;
	}
	
	if(loginLanButton->pressed() || _autoLogin)
	{
		loginLanText->text = NLMISC::strlwr(loginLanText->text);
		passwordLanText->text = NLMISC::strlwr(passwordLanText->text);
		serverLanText->text = NLMISC::strlwr(serverLanText->text);
		CConfigFileTask::getInstance().configFile().getVar("Login").setAsString(loginLanText->text);
		CConfigFileTask::getInstance().configFile().getVar("Password").setAsString(passwordLanText->text);
		CConfigFileTask::getInstance().configFile().getVar("ServerHost").setAsString(serverLanText->text);
		CConfigFileTask::getInstance().configFile().save();
		
		CGuiObjectManager::getInstance().objects.clear();
		State = eConnectionOnlan;
	}
	
}

void CIntroTask::updateServerList()
{
	if(State!=eServerList) return;

	if(_autoLogin==1)
		doConnectionOnLine(CLoginClientMtp::shardIdToIndex(AutoServerId));

	if(backButton2->pressed() || serverListBackButton->pressed())
	{
		State = eMenu;
		CGuiObjectManager::getInstance().objects.clear();
		CGuiObjectManager::getInstance().objects.push_back(menuFrame);
		return;
	}
}

void CIntroTask::updateConnectionOnLine()
{
	if(State!=eConnectionOnline) return;
	
	CGuiObjectManager::getInstance().objects.clear();
	
	CInetAddress ip;
	string cookie;
	nlinfo("CLoginClientMtp::connectToShard(%d)",ServerId);
	string reason = CLoginClientMtp::connectToShard(ServerId,ip,cookie);
	if(!reason.empty())
	{
		_autoLogin = 0;
		error(reason);
		CGuiObjectManager::getInstance().objects.push_back(loginFrame);
		State = eLoginOnline;
		return;
	}

	nlinfo("CNetworkTask::getInstance().connect()");
	reason = CNetworkTask::getInstance().connect(ip, cookie);
	if(!reason.empty())
	{
		_autoLogin = 0;
		error(reason);
		CGuiObjectManager::getInstance().objects.push_back(loginFrame);
		State = eLoginOnline;
		return;
	}

	CResourceManager::getInstance().connected(true);
	_autoLogin = 0;//autologin only once
	stop();
	// stop the background
	CBackgroundTask::getInstance().stop();
	// go to the game task
	CTaskManager::getInstance().add(CGameTask::getInstance(), 60);
	
	CGuiObjectManager::getInstance().objects.clear();
	State = eNone;
}


void CIntroTask::updateConnectionOnLan()
{
	if(State!=eConnectionOnlan) return;
	
	CGuiObjectManager::getInstance().objects.clear();
	
	string res = CNetworkTask::getInstance().connect(CInetAddress(CConfigFileTask::getInstance().configFile().getVar("ServerHost").asString()+":"+toString(CConfigFileTask::getInstance().configFile().getVar("TcpPort").asInt())));
	if(res.empty())
	{
		//no internet patch on lan
		//CResourceManager::getInstance().connected(true);
		_autoLogin = 0;//autologin only once
		stop();
		// stop the background
		CBackgroundTask::getInstance().stop();
		// go to the game task
		CTaskManager::getInstance().add(CGameTask::getInstance(), 60);
		
		CGuiObjectManager::getInstance().objects.clear();
		State = eNone;
		return;		
	}
	else
	{
		_autoLogin = 0;
		error(res);
		CGuiObjectManager::getInstance().objects.push_back(loginLanFrame);
		State = eLoginOnlan;
		return;
	}
}

void CIntroTask::doConnectionOnLine(uint32 serverId)
{
	ServerId = serverId;
	State = eConnectionOnline;
}

void CIntroTask::doConnectionOnLan()
{
	State = eConnectionOnlan;
}

void CIntroTask::update()
{
	updateMenu();
	updateInit();
	updateLoginOnline();
	updateLoginOnlan();
	updateServerList();
	updateConnectionOnLine();
	updateConnectionOnLan();
	updateOptions();

	if(C3DTask::getInstance().kbPressed(KeyESCAPE))
	{
		// want to quit
		CTaskManager::getInstance().exit();
	}

	
}

void CIntroTask::render()
{
	CFontManager::getInstance().littlePrintf(0.0f, 0.0f, toString("v%s %s",MTPT_RELEASE_VERSION_NUMBER,MTPT_RELEASE_VERSION_NAME).c_str());
}

void CIntroTask::populateResolutions()
{
	std::vector<NL3D::UDriver::CMode> availableModes;
	C3DTask::getInstance().driver().getModes(availableModes);

	// Get current resolution from config
	int currentWidth = CConfigFileTask::getInstance().configFile().getVar("ScreenWidth").asInt();
	int currentHeight = CConfigFileTask::getInstance().configFile().getVar("ScreenHeight").asInt();
	selectedResolutionIndex = 0;

	// Build list of unique resolutions
	uniqueResolutions.clear();
	std::set<std::pair<int, int>> addedResolutions;

	for(uint i = 0; i < availableModes.size(); i++)
	{
		NL3D::UDriver::CMode &mode = availableModes[i];

		// Skip duplicates (same width/height, different frequency)
		std::pair<int, int> resPair = std::make_pair(mode.Width, mode.Height);
		if(addedResolutions.find(resPair) != addedResolutions.end())
			continue;
		addedResolutions.insert(resPair);

		uniqueResolutions.push_back(resPair);

		// Find current resolution index
		if(mode.Width == currentWidth && mode.Height == currentHeight)
		{
			selectedResolutionIndex = (int)uniqueResolutions.size() - 1;
		}
	}

	// Update the resolution text to show current selection
	if(selectedResolutionIndex >= 0 && selectedResolutionIndex < (int)uniqueResolutions.size())
	{
		resolutionText->text = toString("%dx%d",
			uniqueResolutions[selectedResolutionIndex].first,
			uniqueResolutions[selectedResolutionIndex].second);
	}
}

void CIntroTask::updateOptions()
{
	if(State != eOptions) return;

	// Handle Back button
	if(optionsBackButton->pressed())
	{
		State = eMenu;
		CGuiObjectManager::getInstance().objects.clear();
		CGuiObjectManager::getInstance().objects.push_back(menuFrame);
		return;
	}

	// Handle Resolution button - left-click cycles forward, right-click cycles backward
	if(resolutionButton->pressed())
	{
		if(!uniqueResolutions.empty())
		{
			selectedResolutionIndex = (selectedResolutionIndex + 1) % (int)uniqueResolutions.size();
			resolutionText->text = toString("%dx%d",
				uniqueResolutions[selectedResolutionIndex].first,
				uniqueResolutions[selectedResolutionIndex].second);
		}
	}
	if(resolutionButton->rightPressed())
	{
		if(!uniqueResolutions.empty())
		{
			selectedResolutionIndex = (selectedResolutionIndex - 1 + (int)uniqueResolutions.size()) % (int)uniqueResolutions.size();
			resolutionText->text = toString("%dx%d",
				uniqueResolutions[selectedResolutionIndex].first,
				uniqueResolutions[selectedResolutionIndex].second);
		}
	}

	// Handle Fullscreen toggle
	if(fullscreenButton->pressed())
	{
		pendingFullscreen = !pendingFullscreen;
		fullscreenText->text = pendingFullscreen ? "ON" : "OFF";
	}

	// Handle VSync toggle
	if(vsyncButton->pressed())
	{
		pendingVSync = !pendingVSync;
		vsyncText->text = pendingVSync ? "ON" : "OFF";
	}

	// Handle Apply button - only works if settings have changed
	if(applyButton->pressed())
	{
		// Check if any settings have changed
		bool settingsChanged = (selectedResolutionIndex != originalResolutionIndex) ||
		                       (pendingFullscreen != originalFullscreen) ||
		                       (pendingVSync != originalVSync);

		if(settingsChanged)
		{
			// Save selected resolution
			if(selectedResolutionIndex >= 0 && selectedResolutionIndex < (int)uniqueResolutions.size())
			{
				CConfigFileTask::getInstance().configFile().getVar("ScreenWidth").setAsInt(uniqueResolutions[selectedResolutionIndex].first);
				CConfigFileTask::getInstance().configFile().getVar("ScreenHeight").setAsInt(uniqueResolutions[selectedResolutionIndex].second);
			}

			// Save fullscreen and vsync
			CConfigFileTask::getInstance().configFile().getVar("Fullscreen").setAsInt(pendingFullscreen ? 1 : 0);
			CConfigFileTask::getInstance().configFile().getVar("VSync").setAsInt(pendingVSync ? 1 : 0);

			// Save config file
			CConfigFileTask::getInstance().configFile().save();

			nlinfo("Video settings saved. Restarting game...");

#ifdef NL_OS_WINDOWS
			// Get the current executable path
			char exePath[MAX_PATH];
			GetModuleFileNameA(NULL, exePath, MAX_PATH);

			// Launch a new instance
			STARTUPINFOA si;
			PROCESS_INFORMATION pi;
			ZeroMemory(&si, sizeof(si));
			si.cb = sizeof(si);
			ZeroMemory(&pi, sizeof(pi));

			if(CreateProcessA(exePath, NULL, NULL, NULL, FALSE, 0, NULL, NULL, &si, &pi))
			{
				CloseHandle(pi.hProcess);
				CloseHandle(pi.hThread);
			}
#endif

			// Exit the current instance
			CTaskManager::getInstance().exit();
		}
	}
}

void CIntroTask::release()
{
}
