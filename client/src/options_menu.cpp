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

#include "stdpch.h"

#include "options_menu.h"
#include "3d_task.h"
#include "sound_manager.h"
#include "config_file_task.h"

#include <set>
#include <algorithm>

using namespace std;
using namespace NLMISC;

COptionsMenu::COptionsMenu()
	: _loaded(false)
	, _active(false)
	, _callback(0)
	, _selectedResolutionIndex(0)
	, _originalResolutionIndex(0)
	, _pendingFullscreen(false)
	, _originalFullscreen(false)
	, _pendingVSync(false)
	, _originalVSync(false)
	, _pendingParticle(true)
	, _originalParticle(true)
{
}

void COptionsMenu::load()
{
	if(_loaded)
		return;

	guiSPG<CGuiXml> xml = CGuiXmlManager::getInstance().Load("options.xml");
	_optionsFrame = (CGuiFrame *)xml->get("optionsFrame");
	_resolutionButton = (CGuiButton *)xml->get("bResolution");
	_resolutionText = (CGuiText *)xml->get("txtResolution");
	_fullscreenButton = (CGuiButton *)xml->get("bFullscreen");
	_fullscreenText = (CGuiText *)xml->get("txtFullscreen");
	_vsyncButton = (CGuiButton *)xml->get("bVSync");
	_vsyncText = (CGuiText *)xml->get("txtVSync");
	_particleButton = (CGuiButton *)xml->get("bParticle");
	_particleText = (CGuiText *)xml->get("txtParticle");
	_musicVolumeSlider = (CGuiHScale *)xml->get("sMusicVolume");
	_musicVolumeText = (CGuiText *)xml->get("txtMusicVolume");
	_soundVolumeSlider = (CGuiHScale *)xml->get("sSoundVolume");
	_soundVolumeText = (CGuiText *)xml->get("txtSoundVolume");
	_applyButton = (CGuiButton *)xml->get("bApply");
	_backButton = (CGuiButton *)xml->get("bOptionsBack");

	_loaded = true;
}

void COptionsMenu::populateResolutions()
{
	std::vector<NL3D::UDriver::CMode> modes;
	C3DTask::getInstance().driver().getModes(modes);

	// Get current resolution from config
	int currentWidth = CConfigFileTask::getInstance().configFile().getVar("ScreenWidth").asInt();
	int currentHeight = CConfigFileTask::getInstance().configFile().getVar("ScreenHeight").asInt();

	// Build list of unique resolutions (800x600 minimum)
	_resolutions.clear();
	std::set<std::pair<int, int>> addedResolutions;

	for(size_t i = 0; i < modes.size(); i++)
	{
		if(modes[i].Width >= 800 && modes[i].Height >= 600)
		{
			std::pair<int, int> res(modes[i].Width, modes[i].Height);
			if(addedResolutions.find(res) == addedResolutions.end())
			{
				addedResolutions.insert(res);
				_resolutions.push_back(res);
			}
		}
	}

	// Sort resolutions
	std::sort(_resolutions.begin(), _resolutions.end());

	// Find current resolution index
	_selectedResolutionIndex = 0;
	for(size_t i = 0; i < _resolutions.size(); i++)
	{
		if(_resolutions[i].first == currentWidth && _resolutions[i].second == currentHeight)
		{
			_selectedResolutionIndex = (int)i;
			break;
		}
	}
	_originalResolutionIndex = _selectedResolutionIndex;

	// Update the resolution text
	if(!_resolutions.empty())
	{
		_resolutionText->text = toString("%dx%d",
			_resolutions[_selectedResolutionIndex].first,
			_resolutions[_selectedResolutionIndex].second);
	}
}

void COptionsMenu::show(IOptionsMenuCallback *callback)
{
	if(!_loaded)
		load();

	_callback = callback;
	_active = true;

	// Populate resolutions
	populateResolutions();

	// Load current settings from config
	_pendingFullscreen = CConfigFileTask::getInstance().configFile().getVar("Fullscreen").asInt() == 1;
	_pendingVSync = CConfigFileTask::getInstance().configFile().getVar("VSync").asInt() == 1;
	_originalFullscreen = _pendingFullscreen;
	_originalVSync = _pendingVSync;

	// Load particle setting
	_pendingParticle = CConfigFileTask::getInstance().configFile().getVar("DisplayParticle").asInt() == 1;
	_originalParticle = _pendingParticle;

	// Update UI to reflect current settings
	_fullscreenText->text = _pendingFullscreen ? "ON" : "OFF";
	_vsyncText->text = _pendingVSync ? "ON" : "OFF";
	_particleText->text = _pendingParticle ? "ON" : "OFF";

	// Initialize volume sliders
	float musicVol = CConfigFileTask::getInstance().configFile().getVar("MusicVolume").asFloat();
	float soundVol = CConfigFileTask::getInstance().configFile().getVar("SoundVolume").asFloat();
	_musicVolumeSlider->percent(musicVol);
	_soundVolumeSlider->percent(soundVol);
	_musicVolumeText->text = toString("%d%%", (int)(musicVol * 100.0f));
	_soundVolumeText->text = toString("%d%%", (int)(soundVol * 100.0f));

	// Add to GUI
	CGuiObjectManager::getInstance().objects.clear();
	CGuiObjectManager::getInstance().objects.push_back(_optionsFrame);
}

void COptionsMenu::hide()
{
	_active = false;
	_callback = 0;
}

bool COptionsMenu::update()
{
	if(!_active)
		return false;

	// Handle Back button
	if(_backButton->pressed())
	{
		// Save volume settings before leaving
		CConfigFileTask::getInstance().configFile().getVar("MusicVolume").setAsFloat(_musicVolumeSlider->percent());
		CConfigFileTask::getInstance().configFile().getVar("SoundVolume").setAsFloat(_soundVolumeSlider->percent());
		CConfigFileTask::getInstance().configFile().save();

		_active = false;
		if(_callback)
			_callback->onOptionsBack();
		return false;
	}

	// Handle Resolution button - left-click cycles forward, right-click cycles backward
	if(_resolutionButton->pressed())
	{
		if(!_resolutions.empty())
		{
			_selectedResolutionIndex = (_selectedResolutionIndex + 1) % (int)_resolutions.size();
			_resolutionText->text = toString("%dx%d",
				_resolutions[_selectedResolutionIndex].first,
				_resolutions[_selectedResolutionIndex].second);
		}
	}
	if(_resolutionButton->rightPressed())
	{
		if(!_resolutions.empty())
		{
			_selectedResolutionIndex = (_selectedResolutionIndex - 1 + (int)_resolutions.size()) % (int)_resolutions.size();
			_resolutionText->text = toString("%dx%d",
				_resolutions[_selectedResolutionIndex].first,
				_resolutions[_selectedResolutionIndex].second);
		}
	}

	// Handle Fullscreen toggle
	if(_fullscreenButton->pressed())
	{
		_pendingFullscreen = !_pendingFullscreen;
		_fullscreenText->text = _pendingFullscreen ? "ON" : "OFF";
	}

	// Handle VSync toggle
	if(_vsyncButton->pressed())
	{
		_pendingVSync = !_pendingVSync;
		_vsyncText->text = _pendingVSync ? "ON" : "OFF";
	}

	// Handle Particle toggle
	if(_particleButton->pressed())
	{
		_pendingParticle = !_pendingParticle;
		_particleText->text = _pendingParticle ? "ON" : "OFF";
	}

	// Handle volume sliders - apply changes immediately
	{
		float musicVol = _musicVolumeSlider->percent();
		float soundVol = _soundVolumeSlider->percent();

		CSoundManager::getInstance().setMusicVolume(musicVol);
		CSoundManager::getInstance().setSoundVolume(soundVol);

		_musicVolumeText->text = toString("%d%%", (int)(musicVol * 100.0f));
		_soundVolumeText->text = toString("%d%%", (int)(soundVol * 100.0f));
	}

	// Handle Apply button
	if(_applyButton->pressed())
	{
		bool settingsChanged = (_selectedResolutionIndex != _originalResolutionIndex) ||
		                       (_pendingFullscreen != _originalFullscreen) ||
		                       (_pendingVSync != _originalVSync) ||
		                       (_pendingParticle != _originalParticle);

		if(settingsChanged && !_resolutions.empty())
		{
			// Save video settings
			CConfigFileTask::getInstance().configFile().getVar("ScreenWidth").setAsInt(_resolutions[_selectedResolutionIndex].first);
			CConfigFileTask::getInstance().configFile().getVar("ScreenHeight").setAsInt(_resolutions[_selectedResolutionIndex].second);
			CConfigFileTask::getInstance().configFile().getVar("Fullscreen").setAsInt(_pendingFullscreen ? 1 : 0);
			CConfigFileTask::getInstance().configFile().getVar("VSync").setAsInt(_pendingVSync ? 1 : 0);
			CConfigFileTask::getInstance().configFile().getVar("DisplayParticle").setAsInt(_pendingParticle ? 1 : 0);

			// Save volume settings too
			CConfigFileTask::getInstance().configFile().getVar("MusicVolume").setAsFloat(_musicVolumeSlider->percent());
			CConfigFileTask::getInstance().configFile().getVar("SoundVolume").setAsFloat(_soundVolumeSlider->percent());

			CConfigFileTask::getInstance().configFile().save();

			// Update original values so we don't trigger again
			_originalResolutionIndex = _selectedResolutionIndex;
			_originalFullscreen = _pendingFullscreen;
			_originalVSync = _pendingVSync;
			_originalParticle = _pendingParticle;

			// Notify callback about the change
			if(_callback)
				_callback->onOptionsApply();
		}
	}

	return true;
}
