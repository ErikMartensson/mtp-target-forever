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

//#include "web.h"
#include "3d_task.h"
#include "end_task.h"
#include "gui_task.h"
#include "time_task.h"
#include "game_task.h"
#include "gui_check.h"
#include "swap_3d_task.h"
#include "mtp_target.h"
#include "login_client.h"
#include "font_manager.h"
#include "network_task.h"
#include "task_manager.h"
#include "background_task.h"
#include "config_file_task.h"


//
// Namespaces
//

using namespace NL3D;
using namespace NLMISC;
using namespace NLNET;


//
// Variables
//


//
// Classes
//

// doesn't work on fullscreen
#if 0

MSG			msg;

extern "C"
{
	void webClickCallback(OLECHAR *url)
	{
		static uint i = 0;
		if(i++==1)
		{
			ucstring u((ucchar*)url);
			openURL(u.toUtf8().c_str());
			exit(0);
		}
	}
};


//
// Functions
//

uint32 BeginTime, CurrentTime, TimeLeft;

void print(float x, float y, const ucstring &str)
{
	CFontManager::TextContext tc = CFontManager::TCBig;
	CViewport vp = C3DTask::instance().scene().getViewport();
	float onePixelX = 1.0f;
	float onePixelY = 1.0f;
	float fs2 = float(CFontManager::instance().textContext(tc).getFontSize())+5;
	float fs = float(CFontManager::instance().textContext(tc).getFontSize());
	CFontManager::instance().textContext(tc).setShaded(false);
	float x1 = (x*fs2+onePixelX)/fs;
	float y1 = (y*fs2+onePixelY)/fs;
	float x2 = (x*fs2-onePixelX)/fs;
	float y2 = (y*fs2-onePixelY)/fs;
	float x3 = (x*fs2)/fs;
	float y3 = (y*fs2)/fs;
	CFontManager::instance().print(tc, CRGBA(0,0,0), x1, y3, str, false);
	CFontManager::instance().print(tc, CRGBA(0,0,0), x2, y3, str, false);
	CFontManager::instance().print(tc, CRGBA(0,0,0), x3, y1, str, false);
	CFontManager::instance().print(tc, CRGBA(0,0,0), x3, y2, str, false);
	CFontManager::instance().print(tc, CRGBA(255,255,255), x3, y3, str, false);
}

void CEndTask::init()
{
	//CBackgroundTask::instance().restart();
	BeginTime = CurrentTime = CTime::getSecondsSince1970();

	C3DTask::instance().clear();

	CFontManager::instance().print(CFontManager::TCDebug, 0, 0, "v" + ucstring(ReleaseVersion));
	float y = 15.0f;
	CRGBA col (255,255,255);
	print(7, y++, ucstring("Don't forget to buy the full version (15 euro) of Mtp Target to :"));
	print(10, y++, ucstring(" - Help developers to add new features and levels"));
	print(10, y++, ucstring(" - Play new levels"));
	print(10, y++, ucstring(" - Customize your avatar"));
	print(10, y++, ucstring(" - Remove all advertisement"));
	print(10, y++, ucstring(" - Quit the game immediately"));

	y+=2;

	print(10, y++, ucstring(toString("The game will close in 5 seconds")));

	C3DTask::instance().driver().swapBuffers();
	CSwap3DTask::instance().stop();

	// web integration test
	//CScissor s;
	//s.init(0,0,1,0.5);
	//C3DTask::instance().driver().setScissor(s);

	// Initialize the OLE interface. We do this once-only.
	if (OleInitialize(NULL) == S_OK)
	{
		WNDCLASSW wc;
		memset (&wc,0,sizeof(wc));
		wc.style			= CS_HREDRAW | CS_VREDRAW ;//| CS_DBLCLKS;
		wc.lpfnWndProc		= (WNDPROC)WebWindowProc;
		wc.cbClsExtra		= 0;
		wc.cbWndExtra		= 0;
		wc.hInstance		= GetModuleHandleW(NULL);
		wc.hIcon			= NULL;
		wc.hCursor			= LoadCursorW(NULL,(LPWSTR)IDC_ARROW);
		wc.hbrBackground	= (HBRUSH)COLOR_WINDOW;
		wc.lpszClassName	= L"foobar";
		wc.lpszMenuName		= NULL;
		if ( !RegisterClassW(&wc) ) return;

		ULONG	WndFlags;
		RECT	WndRect;
		WndFlags = WS_POPUPWINDOW;// | WS_CLIPCHILDREN | WS_CLIPSIBLINGS;
		WndRect.left = 0;
		WndRect.top = 0;
		WndRect.right = 400;
		WndRect.bottom = 200;
		AdjustWindowRect(&WndRect,WndFlags,FALSE);

		// Create another window with another browser object embedded in it.
		//msg.hwnd = CreateWindowEx(0, LPCWSTR(""), LPCWSTR("Microsoft's web site"), WS_OVERLAPPEDWINDOW, CW_USEDEFAULT, 0, CW_USEDEFAULT, 0, HWND_DESKTOP, NULL, NULL, 0);
		//msg.hwnd = CreateWindowW (L"toto", L"test", WS_OVERLAPPEDWINDOW, CW_USEDEFAULT, CW_USEDEFAULT, 400, 200, hWnd, NULL, GetModuleHandle(NULL), NULL);
		msg.hwnd = CreateWindowW (L"STATIC", L"", WS_CHILD | WS_VISIBLE | SS_SIMPLE, 0, 0, 800, 120, (HWND)C3DTask::instance().driver().getDisplay(), NULL, (HINSTANCE) GetWindowLong((HWND)C3DTask::instance().driver().getDisplay(), GWL_HINSTANCE), NULL);
		if (msg.hwnd)
		{
			if (EmbedBrowserObject(msg.hwnd)) nlstop;

			// For this window, display a URL. This could also be a HTML file on disk such as "c:\\myfile.htm".
			DisplayHTMLPage(msg.hwnd, "http://www.mtp-target.org/t/ad.php");

			// Show the window.
			ShowWindow(msg.hwnd, 1);
			UpdateWindow(msg.hwnd);
		}
	}
}

void CEndTask::update()
{
	CurrentTime = CTime::getSecondsSince1970();
	TimeLeft = 15-(CurrentTime-BeginTime);
 	if(TimeLeft == 0)
 		CTaskManager::instance().exit();
}

void CEndTask::render()
{
	nlSleep (10);
}

#endif
