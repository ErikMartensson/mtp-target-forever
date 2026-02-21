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

#ifndef MTPT_TEXT_EDITOR_H
#define MTPT_TEXT_EDITOR_H

#include <string>
#include <vector>
#include "nel/misc/types_nl.h"

class CTextEditor
{
public:
	CTextEditor();

	// Text access
	const std::string &getText() const { return _text; }
	void setText(const std::string &text);
	void clear();

	// Cursor
	uint getCursor() const { return _cursor; }
	void setCursor(uint pos);

	// Max length (0 = unlimited)
	void setMaxLength(uint maxLen) { _maxLength = maxLen; }
	uint getMaxLength() const { return _maxLength; }

	// Editing
	void insertText(const std::string &str);
	void insertChar(char c);
	void deleteBack();
	void deleteForward();
	void deleteWordBack();

	// Cursor movement (shift extends selection)
	void moveLeft(bool shift = false);
	void moveRight(bool shift = false);
	void moveWordLeft(bool shift = false);
	void moveWordRight(bool shift = false);
	void moveHome(bool shift = false);
	void moveEnd(bool shift = false);

	// Clipboard
	void copy();
	void cut();
	void paste();

	// Selection
	bool hasSelection() const { return _selAnchor >= 0; }
	uint getSelectionStart() const;
	uint getSelectionEnd() const;
	std::string getSelectedText() const;
	void selectAll();
	void clearSelection();

	// Undo
	void undo();

	// Main input processing - reads keyboard state for one frame
	// Returns true if text or cursor changed
	bool processInput(bool allowMultiline);

	// ESC / Enter detection
	bool wasEscPressed() const { return _escPressed; }
	bool wasReturnPressed() const { return _returnPressed; }

private:
	struct UndoState
	{
		std::string text;
		uint cursor;
		sint32 selAnchor;
	};

	void deleteSelection();
	void moveCursor(uint pos, bool shift);
	void saveUndoState();
	uint findWordBoundaryLeft(uint pos) const;
	uint findWordBoundaryRight(uint pos) const;
	static bool isWordChar(char c);

	std::string _text;
	uint _cursor;
	sint32 _selAnchor; // -1 = no selection
	uint _maxLength;
	bool _escPressed;
	bool _returnPressed;
	std::vector<UndoState> _undoStack;
};

#endif
