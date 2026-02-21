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

#ifndef MTPT_GRAPH_H
#define MTPT_GRAPH_H


//
// Includes
//

#include <deque>
#include <string>

#include <nel/misc/rgba.h>
#include <nel/misc/time_nl.h>


//
// Classes
//

class CGraph
{
public:
	std::string Name;
	float X, Y, Width, Height;
	NLMISC::CRGBA BackColor;
	float MaxValue;

	std::deque<float> Values;

	NLMISC::TTime Quantum;

	NLMISC::TTime CurrentQuantumStart;

	CGraph (std::string name, float x, float y, float width, float height, NLMISC::CRGBA backColor, NLMISC::TTime quantum, float maxValue)
		: Name(name), X(x), Y(y), Width(width), Height(height), BackColor(backColor), Quantum(quantum),
		CurrentQuantumStart(NLMISC::CTime::getLocalTime()), MaxValue(maxValue)
	{
	}

	void render ();
	void addOneValue (float value = 0.0f);
	void addValue (float value);
};

//
// External variables
//

extern CGraph FpsGraph;
extern CGraph MSpfGraph;

extern CGraph NbKeysGraph;
extern CGraph LCTGraph;
extern CGraph PacketDTGraph;
extern CGraph DTGraph;
extern CGraph PingGraph;


//
// External functions
//

void renderGraphs ();

#endif
