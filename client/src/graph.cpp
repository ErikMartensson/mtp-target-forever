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

#include <deque>

#include <nel/misc/path.h>
#include <nel/misc/vector.h>
#include <nel/misc/matrix.h>
#include <nel/misc/command.h>
#include <nel/misc/types_nl.h>

#include <nel/3d/u_camera.h>
#include <nel/3d/u_driver.h>
#include <nel/3d/u_texture.h>
#include <nel/3d/u_material.h>
#include <nel/3d/u_text_context.h>

#include "graph.h"
#include "3d_task.h"
#include "config_file_task.h"


//
// Namespaces
//

using namespace std;
using namespace NLMISC;
using namespace NL3D;


//
// Variables
//

static UTextContext *GraphTextContext = 0;


//
// Classes
//

void CGraph::render ()
{
	if(!GraphTextContext)
	{
		GraphTextContext = C3DTask::getInstance().driver().createTextContext(CPath::lookup(CConfigFileTask::getInstance().configFile().getVar("LittleFont").asString()));
		GraphTextContext->setFontSize (10);
		nlassert(GraphTextContext);
	}

	// Display the background
	uint32 w, h;
	C3DTask::getInstance().driver().getWindowSize (w, h);
	float ScreenWidth = (float) w;
	float ScreenHeight = (float) h;
	C3DTask::getInstance().driver().setMatrixMode2D (CFrustum (0.0f, ScreenWidth, 0.0f, ScreenHeight, 0.0f, 1.0f, false));
	C3DTask::getInstance().driver().drawQuad (X, Y, X+Width, Y+Height, BackColor);

	float pos = X+Width-1;
	float mean = 0.0f, peak = 0.0f;
	for (deque<float>::reverse_iterator it = Values.rbegin(); it != Values.rend(); it++)
	{
		float value = (*it) * Height / MaxValue;
		if (value > Height) value = Height;
		if (value < 0) value = 0;
		C3DTask::getInstance().driver().drawLine (pos, Y, pos, Y+value, CRGBA (255,255,255,BackColor.A));
		pos--;
		mean += (*it);
		if((*it) > peak) peak = (*it);
	}
	if (Values.size() > 0)
		mean /= Values.size();

	float valuem = mean * Height / MaxValue;
	if (valuem > Height) valuem = Height;
	if (valuem < 0) valuem = 0;
	CRGBA frontCol (min(BackColor.R*2,255),min(BackColor.G*2,255),min(BackColor.B*2,255),min(BackColor.A*2,255));
	C3DTask::getInstance().driver().drawLine (X, Y+valuem, X+Width, Y+valuem, frontCol);
	GraphTextContext->setHotSpot (UTextContext::MiddleLeft);
	GraphTextContext->setColor (frontCol);
	GraphTextContext->printfAt ((X+Width+2)/ScreenWidth, (Y+valuem)/ScreenHeight, toString("%.2f",mean).c_str());

	float value = peak * Height / MaxValue;
	if (value > Height) value = Height;
	if (value < 0) value = 0;
	C3DTask::getInstance().driver().drawLine (X, Y+value, X+Width, Y+value, frontCol);
	if(abs(value-valuem)>10)
	{
		GraphTextContext->printfAt ((X+Width+2)/ScreenWidth, (Y+value)/ScreenHeight, toString("p%.2f",peak).c_str());
	}

	GraphTextContext->setHotSpot (UTextContext::TopLeft);
	GraphTextContext->printfAt ((X+1)/ScreenWidth, (Y+Height-1)/ScreenHeight, Name.c_str());
}

void CGraph::addOneValue (float value)
{
	Values.push_back (value);
	while (Values.size () > (size_t)Width)
		Values.pop_front ();
}


void CGraph::addValue (float value)
{
	TTime currentTime = CTime::getLocalTime ();

	while (currentTime > CurrentQuantumStart + Quantum)
	{
		CurrentQuantumStart += Quantum;
		addOneValue ();
	}

	if(Values.size() > 0)
		Values.back() += value;
	else
		Values.push_back (value);
}

//
// Variables
//

CGraph NbKeysGraph ("nbkeys", 10.0f, 10.0f, 100.0f, 100.0f, CRGBA(128,0,128,128), 0, 10.0f);
CGraph LCTGraph ("lct", 150.0f, 10.0f, 100.0f, 100.0f, CRGBA(128,0,128,128), 0, 300.0f);
CGraph PacketDTGraph ("packetdt", 290.0f, 10.0f, 100.0f, 100.0f, CRGBA(128,0,128,128), 0, 150.0f);
CGraph DTGraph ("dt", 440.0f, 10.0f, 100.0f, 100.0f, CRGBA(128,0,128,128), 0, 150.0f);
CGraph PingGraph ("ping", 580.0f, 10.0f, 100.0f, 100.0f, CRGBA(128,0,128,128), 0, 300.0f);

CGraph FpsGraph ("fps", 10.0f, 120.0f, 100.0f, 100.0f, CRGBA(128,0,0,128), 1000, 100.0f);
CGraph MSpfGraph ("mspf", 150.0f, 120.0f, 100.0f, 100.0f, CRGBA(128,0,0,128), 0, 100.0f);


//
// Functions
//

void renderGraphs ()
{
	FpsGraph.render ();
	MSpfGraph.render ();

	NbKeysGraph.render();
	LCTGraph.render();
	PacketDTGraph.render();
	DTGraph.render();
	PingGraph.render();
}
