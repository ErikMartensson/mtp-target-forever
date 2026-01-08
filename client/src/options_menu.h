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

#ifndef MTPT_OPTIONS_MENU_H
#define MTPT_OPTIONS_MENU_H

#include "gui.h"
#include "gui_scale.h"
#include <nel/3d/u_driver.h>
#include <vector>

// Callback interface for options menu events
class IOptionsMenuCallback
{
public:
	virtual ~IOptionsMenuCallback() {}
	virtual void onOptionsBack() = 0;
	virtual void onOptionsApply() = 0;  // Called when video settings changed
};

class COptionsMenu : public NLMISC::CSingleton<COptionsMenu>
{
public:
	COptionsMenu();

	// Load the options XML (call once during init)
	void load();

	// Show/hide the options menu
	void show(IOptionsMenuCallback *callback);
	void hide();

	// Check if active
	bool isActive() const { return _active; }

	// Update - call every frame when active, returns true if still active
	bool update();

	// Get the frame for adding to GUI manager
	guiSPG<CGuiFrame> frame() { return _optionsFrame; }

private:
	void populateResolutions();

	bool _loaded;
	bool _active;
	IOptionsMenuCallback *_callback;

	// GUI elements
	guiSPG<CGuiFrame> _optionsFrame;
	guiSPG<CGuiButton> _resolutionButton;
	guiSPG<CGuiText> _resolutionText;
	guiSPG<CGuiButton> _fullscreenButton;
	guiSPG<CGuiText> _fullscreenText;
	guiSPG<CGuiButton> _vsyncButton;
	guiSPG<CGuiText> _vsyncText;
	guiSPG<CGuiButton> _particleButton;
	guiSPG<CGuiText> _particleText;
	guiSPG<CGuiHScale> _musicVolumeSlider;
	guiSPG<CGuiText> _musicVolumeText;
	guiSPG<CGuiHScale> _soundVolumeSlider;
	guiSPG<CGuiText> _soundVolumeText;
	guiSPG<CGuiButton> _applyButton;
	guiSPG<CGuiButton> _backButton;

	// State
	std::vector<std::pair<int, int>> _resolutions;
	int _selectedResolutionIndex;
	int _originalResolutionIndex;
	bool _pendingFullscreen;
	bool _originalFullscreen;
	bool _pendingVSync;
	bool _originalVSync;
	bool _pendingParticle;
	bool _originalParticle;
};

#endif
