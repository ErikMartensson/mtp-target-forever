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

#include "text_editor.h"
#include "3d_task.h"

using namespace std;
using namespace NLMISC;

CTextEditor::CTextEditor()
	: _cursor(0), _selAnchor(-1), _maxLength(0), _escPressed(false), _returnPressed(false)
{
}

void CTextEditor::setText(const string &text)
{
	_text = text;
	if (_cursor > (uint)_text.size())
		_cursor = (uint)_text.size();
	_selAnchor = -1;
}

void CTextEditor::clear()
{
	_text.clear();
	_cursor = 0;
	_selAnchor = -1;
}

void CTextEditor::setCursor(uint pos)
{
	if (pos > (uint)_text.size())
		pos = (uint)_text.size();
	_cursor = pos;
}

void CTextEditor::insertText(const string &str)
{
	if (str.empty()) return;

	if (hasSelection())
		deleteSelection();

	string filtered;
	for (uint i = 0; i < str.size(); i++)
	{
		char c = str[i];
		if (c >= 32 || c == '\n')
			filtered += c;
	}

	if (_maxLength > 0 && _text.size() + filtered.size() > _maxLength)
		filtered = filtered.substr(0, _maxLength - _text.size());

	if (filtered.empty()) return;

	_text = _text.substr(0, _cursor) + filtered + _text.substr(_cursor);
	_cursor += (uint)filtered.size();
}

void CTextEditor::insertChar(char c)
{
	string s;
	s += c;
	insertText(s);
}

void CTextEditor::deleteBack()
{
	if (hasSelection())
	{
		deleteSelection();
		return;
	}
	if (_cursor > 0)
	{
		_text = _text.substr(0, _cursor - 1) + _text.substr(_cursor);
		_cursor--;
	}
}

void CTextEditor::deleteForward()
{
	if (hasSelection())
	{
		deleteSelection();
		return;
	}
	if (_cursor < _text.size())
	{
		_text = _text.substr(0, _cursor) + _text.substr(_cursor + 1);
	}
}

void CTextEditor::deleteWordBack()
{
	if (hasSelection())
	{
		deleteSelection();
		return;
	}
	uint target = findWordBoundaryLeft(_cursor);
	if (target < _cursor)
	{
		_text = _text.substr(0, target) + _text.substr(_cursor);
		_cursor = target;
	}
}

void CTextEditor::moveCursor(uint pos, bool shift)
{
	if (pos > (uint)_text.size())
		pos = (uint)_text.size();

	if (shift)
	{
		if (_selAnchor < 0)
			_selAnchor = (sint32)_cursor;
		_cursor = pos;
		if ((uint)_selAnchor == _cursor)
			_selAnchor = -1;
	}
	else
	{
		_selAnchor = -1;
		_cursor = pos;
	}
}

void CTextEditor::moveLeft(bool shift)
{
	if (!shift && hasSelection())
	{
		_cursor = getSelectionStart();
		_selAnchor = -1;
		return;
	}
	if (_cursor > 0)
		moveCursor(_cursor - 1, shift);
}

void CTextEditor::moveRight(bool shift)
{
	if (!shift && hasSelection())
	{
		_cursor = getSelectionEnd();
		_selAnchor = -1;
		return;
	}
	if (_cursor < _text.size())
		moveCursor(_cursor + 1, shift);
}

void CTextEditor::moveWordLeft(bool shift)
{
	moveCursor(findWordBoundaryLeft(_cursor), shift);
}

void CTextEditor::moveWordRight(bool shift)
{
	moveCursor(findWordBoundaryRight(_cursor), shift);
}

void CTextEditor::moveHome(bool shift)
{
	moveCursor(0, shift);
}

void CTextEditor::moveEnd(bool shift)
{
	moveCursor((uint)_text.size(), shift);
}

void CTextEditor::copy()
{
	if (!hasSelection()) return;
	string sel = getSelectedText();
	C3DTask::getInstance().driver().copyTextToClipboard(sel);
}

void CTextEditor::cut()
{
	if (!hasSelection()) return;
	copy();
	deleteSelection();
}

void CTextEditor::paste()
{
	string clipText;
	if (!C3DTask::getInstance().driver().pasteTextFromClipboard(clipText))
		return;
	if (clipText.empty()) return;

	// Filter to printable chars only (no newlines in single-line mode, but we let insertText handle filtering)
	insertText(clipText);
}

uint CTextEditor::getSelectionStart() const
{
	if (_selAnchor < 0) return _cursor;
	return (_cursor < (uint)_selAnchor) ? _cursor : (uint)_selAnchor;
}

uint CTextEditor::getSelectionEnd() const
{
	if (_selAnchor < 0) return _cursor;
	return (_cursor > (uint)_selAnchor) ? _cursor : (uint)_selAnchor;
}

string CTextEditor::getSelectedText() const
{
	if (!hasSelection()) return "";
	return _text.substr(getSelectionStart(), getSelectionEnd() - getSelectionStart());
}

void CTextEditor::selectAll()
{
	if (_text.empty()) return;
	_selAnchor = 0;
	_cursor = (uint)_text.size();
}

void CTextEditor::clearSelection()
{
	_selAnchor = -1;
}

void CTextEditor::deleteSelection()
{
	if (!hasSelection()) return;
	uint start = getSelectionStart();
	uint end = getSelectionEnd();
	_text = _text.substr(0, start) + _text.substr(end);
	_cursor = start;
	_selAnchor = -1;
}

void CTextEditor::saveUndoState()
{
	UndoState state;
	state.text = _text;
	state.cursor = _cursor;
	state.selAnchor = _selAnchor;
	_undoStack.push_back(state);
	if (_undoStack.size() > 50)
		_undoStack.erase(_undoStack.begin());
}

void CTextEditor::undo()
{
	if (_undoStack.empty()) return;
	UndoState state = _undoStack.back();
	_undoStack.pop_back();
	_text = state.text;
	_cursor = state.cursor;
	_selAnchor = state.selAnchor;
}

bool CTextEditor::isWordChar(char c)
{
	return isalnum((unsigned char)c) || c == '_';
}

uint CTextEditor::findWordBoundaryLeft(uint pos) const
{
	if (pos == 0) return 0;
	// Skip spaces first
	while (pos > 0 && _text[pos - 1] == ' ')
		pos--;
	if (pos == 0) return 0;
	// If previous char is a word char, skip word chars
	if (isWordChar(_text[pos - 1]))
	{
		while (pos > 0 && isWordChar(_text[pos - 1]))
			pos--;
	}
	else
	{
		// Skip non-word, non-space chars (punctuation)
		while (pos > 0 && !isWordChar(_text[pos - 1]) && _text[pos - 1] != ' ')
			pos--;
	}
	return pos;
}

uint CTextEditor::findWordBoundaryRight(uint pos) const
{
	uint len = (uint)_text.size();
	if (pos >= len) return len;
	// If on a word char, skip word chars
	if (isWordChar(_text[pos]))
	{
		while (pos < len && isWordChar(_text[pos]))
			pos++;
	}
	else if (_text[pos] != ' ')
	{
		// Skip non-word, non-space chars (punctuation)
		while (pos < len && !isWordChar(_text[pos]) && _text[pos] != ' ')
			pos++;
	}
	// Skip trailing spaces
	while (pos < len && _text[pos] == ' ')
		pos++;
	return pos;
}

bool CTextEditor::processInput(bool allowMultiline)
{
	_escPressed = false;
	_returnPressed = false;
	string oldText = _text;
	uint oldCursor = _cursor;
	sint32 oldSel = _selAnchor;

	bool ctrl = C3DTask::getInstance().kbDown(KeyCONTROL);
	bool shift = C3DTask::getInstance().kbDown(KeySHIFT);

	// Always consume kbPressed state for shortcut keys to prevent stale key events
	// from firing when Ctrl is pressed later (kbPressed state persists until read)
	bool pressedZ = C3DTask::getInstance().kbPressed(KeyZ);
	bool pressedV = C3DTask::getInstance().kbPressed(KeyV);
	bool pressedC = C3DTask::getInstance().kbPressed(KeyC);
	bool pressedX = C3DTask::getInstance().kbPressed(KeyX);
	bool pressedA = C3DTask::getInstance().kbPressed(KeyA);

	// Clipboard and editing shortcuts
	if (ctrl && pressedZ)
	{
		undo();
	}
	else if (ctrl && pressedV)
	{
		saveUndoState();
		paste();
	}
	else if (ctrl && pressedC)
	{
		copy();
	}
	else if (ctrl && pressedX)
	{
		saveUndoState();
		cut();
	}
	else if (ctrl && pressedA)
	{
		selectAll();
	}

	// Navigation keys
	if (C3DTask::getInstance().kbPressed(KeyLEFT))
	{
		if (ctrl)
			moveWordLeft(shift);
		else
			moveLeft(shift);
	}
	if (C3DTask::getInstance().kbPressed(KeyRIGHT))
	{
		if (ctrl)
			moveWordRight(shift);
		else
			moveRight(shift);
	}
	if (C3DTask::getInstance().kbPressed(KeyHOME))
	{
		moveHome(shift);
	}
	if (C3DTask::getInstance().kbPressed(KeyEND))
	{
		moveEnd(shift);
	}
	if (C3DTask::getInstance().kbPressed(KeyDELETE))
	{
		saveUndoState();
		deleteForward();
	}

	// Character input from kbGetString
	string res = C3DTask::getInstance().kbGetString();
	bool savedForChars = false;
	for (const char *src = res.c_str(); *src != '\0'; src++)
	{
		unsigned char c = (unsigned char)*src;

		if (c == 27) // ESC
		{
			_escPressed = true;
			continue;
		}

		if (c == 8) // Backspace
		{
			saveUndoState();
			deleteBack();
			continue;
		}

		if (c == 0x7F) // Ctrl+Backspace
		{
			saveUndoState();
			deleteWordBack();
			continue;
		}

		if (c == '\r') // Enter/Return
		{
			if (allowMultiline)
			{
				saveUndoState();
				insertChar('\n');
			}
			else
			{
				_returnPressed = true;
			}
			continue;
		}

		// Skip control chars (including 0x16 from Ctrl+V, 0x01 from Ctrl+A, etc.)
		if (c < 32)
			continue;

		// Save undo once for a batch of typed chars in the same frame
		if (!savedForChars)
		{
			saveUndoState();
			savedForChars = true;
		}
		insertChar((char)c);
	}

	return _text != oldText || _cursor != oldCursor || _selAnchor != oldSel;
}
