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
#include <string>
#include <fstream>
#include <algorithm>

#include "sound_manager.h"
#include "config_file_task.h"
#include "resource_manager2.h"
#include "3d_task.h"
#include "hud_task.h"

#include <nel/misc/file.h>
#include <nel/misc/path.h>
#include <nel/sound/u_listener.h>

//
// Namespaces
//

using namespace std;
using namespace NLMISC;
using namespace NLSOUND;

//
// Variables
//

//
// Functions
//

EntitySource *CSoundManager::playSound (TSound soundID)
{
	if(!isInit || !PlaySound)
		return 0;

	// Try low-level approach first (direct WAV playback)
	if(SoundDriver && soundID >= 0 && soundID < SoundCount && SoundBuffers[soundID])
	{
		ISource *lowLevelSource = SoundDriver->createSource();
		if(lowLevelSource)
		{
			lowLevelSource->setStaticBuffer(SoundBuffers[soundID]);
			EntitySource *Pom = new EntitySource(lowLevelSource);
			return Pom;
		}
	}

	// Fall back to high-level approach (requires sound sheets)
	USource *source=createTTSource(soundID);
	if(0==source)
		return 0;

	EntitySource *Pom = new EntitySource(source);
	return Pom;
}

USource *CSoundManager::createTTSource (TSound soundID)
{
	USource *source = 0;
	const char *soundName = "";

	if(soundID==BallOpen)
	{
		soundName = "open";
		source = AudioMixer->createSource(CStringMapper::map(soundName));
	}
	else if(soundID==BallClose)
	{
		soundName = "close";
		source = AudioMixer->createSource(CStringMapper::map(soundName));
	}
	else if(soundID==Splash)
	{
		soundName = "splash";
		source = AudioMixer->createSource(CStringMapper::map(soundName));
	}
	else if(soundID==Impact)
	{
		soundName = "impact";  // Fixed: was "beep"
		source = AudioMixer->createSource(CStringMapper::map(soundName));
	}

	if(source == 0)
	{
		nlwarning("Failed to create sound source for '%s' (soundID=%d). Sound banks may not be loaded.", soundName, (int)soundID);
	}

	return source;
}

CSoundManager::CSoundManager()
{
	isInit = false;
	musicState = Stoped;
	m3uNowPlaying = 0;
	PlaySound = false;
	SoundDriver = NULL;
	for(int i = 0; i < SoundCount; i++)
		SoundBuffers[i] = NULL;
}

void CSoundManager::init()
{

//	CPath::addSearchPath("/home/xnovak5/c/sound_sources/data", true, false);

	/*
	 * 1. Create the audio mixer object and init it.
	 * If the sound driver cannot be loaded, an exception is thrown.
	 */
	AudioMixer = UAudioMixer::createAudioMixer();

	// NOTE: Sample bank and packed sheets disabled - causes crashes with our sound files.
	// The NeL sound bank system expects specific DFN formats that don't match our setup.
	// Sound effects will use the music playback API as a workaround.
	// AudioMixer->setSamplePath("data/sound/samplebank");
	// AudioMixer->setPackedSheetOption("cache", true);

	UAudioMixer::TDriver driverType;
	string driverName = CConfigFileTask::getInstance().configFile().getVar("SoundDriver").asString();
	if (driverName == "OpenAL") driverType = UAudioMixer::DriverOpenAl;
	else if (driverName == "FMod") driverType = UAudioMixer::DriverFMod;
	else if (driverName == "XAudio2") driverType = UAudioMixer:: DriverXAudio2;
	else if (driverName == "DSound") driverType = UAudioMixer::DriverDSound;
	else
	{
		driverType = UAudioMixer::DriverAuto;
		nlwarning("SoundDriver value '%s' is invalid.", driverName.c_str());
	}

	AudioMixer->init(
		CConfigFileTask::getInstance().configFile().exists("SoundMaxTracks") ? CConfigFileTask::getInstance().configFile().getVar("SoundMaxTracks").asInt() : 32,
		CConfigFileTask::getInstance().configFile().exists("SoundUseEax") ? CConfigFileTask::getInstance().configFile().getVar("SoundUseEax").asBool() : true,
		CConfigFileTask::getInstance().configFile().exists("SoundUseADPCM") ? CConfigFileTask::getInstance().configFile().getVar("SoundUseADPCM").asBool() : false,
		NULL, true, driverType,
		CConfigFileTask::getInstance().configFile().exists("SoundForceSoftware") ? CConfigFileTask::getInstance().configFile().getVar("SoundForceSoftware").asBool() : true);

	if (CConfigFileTask::instance().configFile().getVar("Sound").asInt() == 1)
	{
		PlaySound = true;
	}

	// NOTE: Direct WAV playback via separate sound driver is disabled for now.
	// Creating a second ISoundDriver instance conflicts with the AudioMixer's driver
	// on most sound backends (OpenAL, DirectSound, etc.).
	// Sound effects will not play until we find a way to access the AudioMixer's
	// internal driver or use a different approach.
	//
	// TODO: Investigate alternatives:
	// 1. Use CAudioMixerUser::getSoundDriver() (requires fixing C++17 header issues)
	// 2. Create proper .sound sheet files for NeL's sound bank system
	// 3. Use playMusic() API for one-shot sounds (hacky but might work)
	SoundDriver = NULL;
	nlwarning("Direct WAV sound effects disabled - would require second sound driver instance");

	loadPlayList();

	isInit = true;

	// Apply saved volume settings (must be after isInit = true)
	setMusicVolume(CConfigFileTask::instance().configFile().getVar("MusicVolume").asFloat());
	setSoundVolume(CConfigFileTask::instance().configFile().getVar("SoundVolume").asFloat());

	play();
}

void CSoundManager::update()
{
	if(!isInit) return;

	const CMatrix &cameraMatrix = C3DTask::instance().scene().getCam().getMatrix();
	updateListener(cameraMatrix.getPos(), CVector::Null, cameraMatrix.getJ(), cameraMatrix.getK());

	AudioMixer->update();

	if(!m3uVector.empty() && AudioMixer->isMusicEnded())
	{
		playNextMusic();
	}
}

void CSoundManager::updateListener(const NLMISC::CVector &position, const NLMISC::CVector &velocity, const NLMISC::CVector &atVector, const NLMISC::CVector &upVector)
{
	if(!isInit) return;

	AudioMixer->getListener()->setPos(position);
	AudioMixer->getListener()->setOrientation(atVector, upVector);
	AudioMixer->getListener()->setVelocity(velocity);
}

void CSoundManager::render()
{
}

void CSoundManager::release()
{
	if(!isInit) return;

	// Clean up sound effect buffers first (they reference the driver)
	for(int i = 0; i < SoundCount; i++)
	{
		if(SoundBuffers[i])
		{
			delete SoundBuffers[i];
			SoundBuffers[i] = NULL;
		}
	}

	// Delete our separate sound driver
	if(SoundDriver)
	{
		delete SoundDriver;
		SoundDriver = NULL;
	}

	delete AudioMixer;
	AudioMixer = NULL;
}

// -----------------------------------------------------------------------------
// Sound effects loading - direct WAV file approach
// -----------------------------------------------------------------------------

void CSoundManager::loadSoundEffects()
{
	if(!SoundDriver)
	{
		nlwarning("Sound driver not available, cannot load sound effects");
		return;
	}

	// Map sound IDs to WAV filenames
	const char *soundFiles[SoundCount] = {
		"open.wav",    // BallOpen
		"close.wav",   // BallClose
		"splash.wav",  // Splash
		"impact.wav"   // Impact
	};

	for(int i = 0; i < SoundCount; i++)
	{
		// Try to find the WAV file
		string wavPath = CPath::lookup(soundFiles[i], false, false, false);
		if(wavPath.empty())
		{
			// Try in data/sound directory
			wavPath = "data/sound/" + string(soundFiles[i]);
			if(!CFile::fileExists(wavPath))
			{
				nlwarning("Sound effect '%s' not found", soundFiles[i]);
				continue;
			}
		}

		// Read the WAV file
		CIFile file;
		if(!file.open(wavPath))
		{
			nlwarning("Cannot open sound file '%s'", wavPath.c_str());
			continue;
		}

		uint32 fileSize = file.getFileSize();
		vector<uint8> wavData(fileSize);
		file.serialBuffer(&wavData[0], fileSize);
		file.close();

		// Parse WAV data
		vector<uint8> pcmData;
		IBuffer::TBufferFormat bufferFormat;
		uint8 channels;
		uint8 bitsPerSample;
		uint32 frequency;

		if(!IBuffer::readWav(&wavData[0], fileSize, pcmData, bufferFormat, channels, bitsPerSample, frequency))
		{
			nlwarning("Failed to parse WAV file '%s'", wavPath.c_str());
			continue;
		}

		// Create the buffer
		IBuffer *buffer = SoundDriver->createBuffer();
		if(!buffer)
		{
			nlwarning("Failed to create sound buffer for '%s'", wavPath.c_str());
			continue;
		}

		// Set the buffer name
		buffer->setName(CStringMapper::map(soundFiles[i]));

		// Set format and fill with data
		buffer->setFormat(bufferFormat, channels, bitsPerSample, frequency);
		if(!buffer->fill(&pcmData[0], (uint)pcmData.size()))
		{
			nlwarning("Failed to fill buffer with data for '%s'", wavPath.c_str());
			delete buffer;
			continue;
		}

		SoundBuffers[i] = buffer;
		nlinfo("Loaded sound effect '%s' (%d bytes, %d Hz, %d ch, %d bits)",
			soundFiles[i], (int)pcmData.size(), frequency, channels, bitsPerSample);
	}
}

// -----------------------------------------------------------------------------
// gui methods
// -----------------------------------------------------------------------------

void CSoundManager::playGUISound (string soundName)
{
	if(!isInit || !PlaySound)
		return;

	USource *soundSource = AudioMixer->createSource(CStringMapper::map(soundName), true);
	if (NULL == soundSource)
	{
		nlwarning("----can't find GUI sound: %s", soundName.c_str());
		return;
	}
	soundSource->setSourceRelativeMode(true);
	soundSource->play();
	return;
}

// -----------------------------------------------------------------------------

void CSoundManager::loadPlayList()
{
	if (CConfigFileTask::instance().configFile().getVar("Music").asInt() != 1) return;

	string m3uFileName = CConfigFileTask::instance().configFile().getVar("M3UList").asString();

	if(!CFile::fileExists(m3uFileName) && CPath::exists(CFile::getFilename(m3uFileName)))
	{
		m3uFileName = CPath::lookup(CFile::getFilename(m3uFileName));
	}

	string m3uDirectory = CFile::getPath(m3uFileName);
	nlinfo("Loading playlist '%s'", m3uFileName.c_str());
	ifstream M3uFile;
	M3uFile.open(m3uFileName.c_str());
	if (!M3uFile.good())
	{
		nlwarning("Can't load playlist '%s'", m3uFileName.c_str());
		return;
	}

	while (!M3uFile.eof() && M3uFile.good())
	{
		string cline;
		getline(M3uFile, cline);
		if(cline.size() > 0 && cline[0] != '#' && cline[0] != ' ')
		{
			while(cline.size() > 0 && (cline[cline.size()-1] == '\n' || cline[cline.size()-1] == '\r')) cline.resize(cline.size()-1)
				;

			if (CFile::isExists(cline))
			{
				nlinfo("Adding music '%s' in the playlist", cline.c_str());
				m3uVector.push_back(cline);
			}
			else if (CFile::isExists(m3uDirectory+cline))
			{
				nlinfo("Adding music '%s' in the playlist", (m3uDirectory+cline).c_str());
				m3uVector.push_back(m3uDirectory+cline);
			}
			else
			{
				nlwarning("Music '%s' is not found", cline.c_str());
			}
		}
	}
	if (CConfigFileTask::instance().configFile().getVar("M3UShuffle").asInt() == 1)
	{
		random_shuffle(m3uVector.begin(), m3uVector.end());
		/*
		srand (CTime::getSecondsSince1970());
		for(uint32 i = 0; i < m3uVector.size(); i++)
		{
			uint32 j = rand()%m3uVector.size();
			string tmp = m3uVector[j];
			m3uVector[j] = m3uVector[i];
			m3uVector[i] = tmp;
		}
		*/
	}
}

// -----------------------------------------------------------------------------

void CSoundManager::playNextMusic()
{
	if (m3uVector.empty())
		return;

	m3uNowPlaying++;
	m3uNowPlaying%=m3uVector.size();
	play();
}

void CSoundManager::playPreviousMusic()
{
	if (m3uVector.empty())
		return;

	if(m3uNowPlaying == 0)
		m3uNowPlaying = m3uVector.size()-1;
	else
		m3uNowPlaying--;

	play();
}

void CSoundManager::switchPauseMusic()
{
	if(!isInit) return;

	if (musicState == Playing)
	{
		AudioMixer->pauseMusic();
		musicState = Paused;
	}
	else if (musicState == Paused )
	{
		AudioMixer->resumeMusic();
		musicState = Playing;
	}
}

void CSoundManager::setMusicVolume(float volume)
{
	MusicVolume = volume;

	if(isInit)
		AudioMixer->setMusicVolume(volume);
}

void CSoundManager::setSoundVolume(float volume)
{
	SoundVolume = volume;

	if(isInit)
		AudioMixer->getListener()->setGain(SoundVolume);
}

void CSoundManager::play ()
{
	if(!isInit)
		return;

	if (!m3uVector.empty())
	{
		nlassert (m3uNowPlaying<m3uVector.size());

		/* If the player is paused, resume, else, play the current song */
		if (musicState == Paused)
		{
			AudioMixer->resumeMusic();
			musicState = Playing;
		}
		else
		{
			if(AudioMixer->playMusic(m3uVector[m3uNowPlaying], 0, true, false))
			{
				string SongTitle;
				float SongLength;
				if(AudioMixer->getSongTitle(m3uVector[m3uNowPlaying], SongTitle, SongLength))
				{
					CHudTask::getInstance().addSysMessage("Now playing " + SongTitle );
				}
				musicState = Playing;
			}
			else
			{
				nlwarning("Play music '%s' failed", m3uVector[m3uNowPlaying].c_str());
				vector<string>::iterator it = m3uVector.begin() + m3uNowPlaying;
				m3uVector.erase(it);
				if(m3uNowPlaying >= m3uVector.size())
				{
					m3uNowPlaying=0;
				}
			}
		}
	}
}
