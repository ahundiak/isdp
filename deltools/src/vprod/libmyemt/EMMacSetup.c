#include	<malloc.h>
#include	<items.h>
#include	"../hfiles/EMDefines.h"
#include	"../hfiles/EMTCB.h"
#include	"../hfiles/EMMenu.h"
#include	"../hfiles/EMGlobals.h"


#define	SET	1
#define	GET	2
#define	DRAW	3
#define	ERASE	4

#define	KEYIN_ID	1000
#define	BACKSPACE_ID	1001
#define	CLEAR_ID	1002
#define	MODIFIERS_ID	1003
#define	SHIFTS_ID	1004
#define	KEYS_ID		1005
#define	LABEL_LIST_ID	1006
#define	CHAR_LIST_ID	1007

#define	CLEAR_OK_ID	1


static	Char16	*macro[512], **currMacro;

static	ITItem	MacroMenu, macroKeyin, Backspace, Keys, LabelList, CharList,
		PreviousModifier = NULL,
		PreviousShift = NULL,
		PreviousKey = NULL;

static	int	currKey,
		keyOffset = 0,
		modifier = 0,
		shift = 0,
		numShiftStates;

static	int	(*OldGetWidth)(), (*OldDrawString)();



static ClearCompletion(Clear)
ITItem	Clear;
{
	int	m, window, id, *memory;
	short	mText;
	float	xSize, ySize;
	ITItem	clearMenu, button;

	/* Display the "Are you sure..." menu */
	ITReadFile (CLEAR_MENU_FILE, &clearMenu, &memory);
	ITSetWindow (clearMenu, _EMMenuWindow);
	ITGetSize (clearMenu, &xSize, &ySize);
	Create_SR_area (_EMMenuWindow, 550, 150, (int) (550 + xSize - 1),
			(int) (150 + ySize - 1));

	ITImmediateInc (clearMenu);
	hidecursor (_EMMenuWindow);
	ITDraw (clearMenu);
	showcursor (_EMMenuWindow);
	flushbuffer (_EMMenuWindow);

	ITProcess (clearMenu, &button);

	ITImmediateDec (clearMenu);
	Delete_SR_area (_EMMenuWindow);
	ITDelete (clearMenu);
	ITFreeMemory (memory);

	/* Clear the macros if the OK button was pressed */
	ITGetId (button, &id);
	if (id == CLEAR_OK_ID)
	{
		ITGetWindow(Clear,&window);
		hidecursor(window);
		mText = 0;
		ITKeyinSetText (macroKeyin, &mText, 0, 0);
		for (m = 0; m < 512; m++)
		{
			macro[m] = (Char16 *)realloc(macro[m],1);
			macro[m][0] = 0;
		}
		showcursor(window);
		flushbuffer(window);
	}
}


static KeyFilter (keyin, key)
ITItem	keyin;
int	*key;
{
	int		complete;
	static int	membrane = FALSE, keypad = FALSE;

	if (membrane)
	{
		membrane = FALSE;
		(*key) += 256;
	}
	else if (keypad)
	{
		keypad = FALSE;
		(*key) += 384;
	}
	else if (*key == 0xFE)
	{
		membrane = TRUE;
		*key = 0;
		return;
	}
	else if (*key == 0x8F)
	{
		keypad = TRUE;
		*key = 0;
		return;
	}

	if (*key != 0)
	{
		/* Precede the key with a ctrl Q in order to quote it */
		ITKeyinSetFilter (keyin, NULL);
		ITTrackKeyboard (keyin, 17, &complete);
		ITKeyinSetFilter (keyin, KeyFilter);
	}
}


static BSCompletion (item)
ITItem	item;
{
	int	complete;

	ITKeyinSetFilter (macroKeyin, NULL);
	ITTrackKeyboard (macroKeyin, 0x8, &complete);	/* backspace */
	ITKeyinSetFilter (macroKeyin, KeyFilter);
}


static MakeString (string, length, newString, newLength)
Char16	*string;
int	length;
Char8	*newString;
int	*newLength;
{
	int	index, data;
	Char16	*ptr, *endPtr;
	Char8	*newPtr;

	newPtr = newString;
	endPtr = &string[length];
	for (ptr = string; ptr < endPtr; ptr++)
	{
		index = *ptr;
		ITListGetCellData (CharList, index, 0, &data);
		switch (atoi (data))
		{
			case 0:
			{
				Char8	*sData;

				ITListGetCellData (CharList, index, 1, &sData);
				strcpy (newPtr, sData);
				newPtr += strlen (sData);
				break;
			}

			case 1:
				*newPtr++ = *ptr;
				break;
		}
	}
	*newLength = newPtr - newString;
}


static int GetWidth (font, string, length, width)
long	font;
Char16	*string;
int	length;
int	*width;
{
	int	newLength;
	Char8	newString[4096];

	MakeString (string, length, newString, &newLength);
	(*OldGetWidth) (font, newString, newLength, width);
}


static int DrawString (window, font, x, y, string, length)
int	window;
long	font;
int	x, y;
Char16	*string;
int	length;
{
	int	newLength;
	Char8	newString[4096];

	MakeString (string, length, newString, &newLength);
	(*OldDrawString) (window, font, x, y, newString, newLength);
}


static KeyCompletion(Key)
ITItem	Key;
{
	int	window, depressed, size;
	char	*temp;
	Char16	mText;

	ITGetWindow(Key,&window);
	hidecursor(window);
	ITSwitchGetValue(Key,&depressed);
	if (depressed)
	{
		if (PreviousKey)
		{
			ITSwitchSetValue(PreviousKey,FALSE);
			ITKeyinGetText(macroKeyin,&temp);
			size = (_EMStrLen16 (temp) + 1) * sizeof (Char16);
			*currMacro = (Char16 *) realloc (*currMacro, size);
			memcpy (*currMacro, temp, size);
		}
		else
		{
			ITSetEnable(macroKeyin,TRUE);
			ITSetKeyboard(macroKeyin,TRUE);
		}
		PreviousKey = Key;
		ITGetSpecial (Key, &currKey);
		ITListGetCellData(LabelList,currKey,keyOffset,&temp);
		currMacro = &macro[atoi(temp)];
		ITKeyinSetText (macroKeyin, *currMacro, 0,
				_EMStrLen16 (*currMacro));
	}
	else
	{
		ITKeyinGetText(macroKeyin,&temp);
		size = (_EMStrLen16 (temp) + 1) * sizeof (Char16);
		*currMacro = (Char16 *) realloc (*currMacro, size);
		memcpy (*currMacro, temp, size);
		mText = 0;
		ITKeyinSetText (macroKeyin, &mText, 0, 0);
		ITSetEnable(macroKeyin,FALSE);
		PreviousKey = NULL;
	}
	showcursor(window);
	flushbuffer(window);
}


static UpdateKeys ()
{
	ITItem	keyItem;
	char	*label, *oldLabel, *number;
	int	keyId, enabled;

	ITGroupGetFirst(Keys,&keyItem);
	while (keyItem != NULL)
	{
		ITGetSpecial (keyItem, &keyId);
		ITListGetCellData (LabelList, keyId, keyOffset, &number);
		if (atoi (number) < 0)
		{
			ITGetEnable (keyItem, &enabled);
			if (enabled)
				ITSetEnable (keyItem, FALSE);
		}
		else
		{
			ITListGetCellData (LabelList, keyId, keyOffset + 1,
					   &label);
			ITSwitchGetLabelFalse (keyItem, &oldLabel);
			if (strcmp (label, oldLabel))
			{
				ITImmediateDec (keyItem);
				ITSetEnable (keyItem, TRUE);
				ITSwitchSetLabelFalse(keyItem,label);
				ITSwitchSetLabelTrue(keyItem,label);
				ITImmediateInc (keyItem);
				ITDraw (keyItem);
			}
			else	/* make sure it's enabled */
			{
				ITGetEnable (keyItem, &enabled);
				if (!enabled)
					ITSetEnable (keyItem, TRUE);
			}
		}
		ITGroupGetNext(Keys,&keyItem);
	}
}


static ModifierCompletion(Modifier)
ITItem	Modifier;
{
	int	window, depressed, index, size;
	char	*temp;

	ITGetWindow(Modifier,&window);
	hidecursor(window);
	ITSwitchGetValue(Modifier,&depressed);
	if (depressed)
	{
		ITGetSpecial (Modifier, &modifier);
		if (PreviousModifier)
			ITSwitchSetValue(PreviousModifier,FALSE);
		PreviousModifier = Modifier;
	}
	else
	{
		modifier = 0;
		PreviousModifier = NULL;
	}
	keyOffset = 2 * (modifier * numShiftStates + shift);
	UpdateKeys ();
	if (PreviousKey)
	{
		ITKeyinGetText(macroKeyin,&temp);
		size = (_EMStrLen16 (temp) + 1) * sizeof (Char16);
		*currMacro = (Char16 *) realloc (*currMacro, size);
		memcpy (*currMacro, temp, size);

		ITListGetCellData(LabelList,currKey,keyOffset,&temp);
		if ((index = atoi (temp)) < 0)
		{
			ITSwitchSetValue (PreviousKey, FALSE);
			PreviousKey = NULL;
			ITSetEnable (macroKeyin, FALSE);
		}
		else
		{
			currMacro = &macro[index];
			ITKeyinSetText (macroKeyin, *currMacro, 0,
					_EMStrLen16 (*currMacro));
		}
	}
	showcursor(window);
	flushbuffer(window);
}


static ShiftCompletion(Shift)
ITItem	Shift;
{
	int	window, size, value, index;
	char	*temp;

	ITGetWindow(Shift,&window);
	hidecursor(window);
	ITSwitchGetValue(Shift,&value);
	if (value)
	{
		ITGetSpecial (Shift, &shift);
		if (PreviousShift)
			ITSwitchSetValue(PreviousShift,FALSE);
		PreviousShift = Shift;
	}
	else
	{
		shift = 0;
		UpdateKeys ();
		PreviousShift = NULL;
	}
	keyOffset = 2 * (modifier * numShiftStates + shift);
	UpdateKeys ();
	if (PreviousKey)
	{
		ITKeyinGetText(macroKeyin,&temp);
		size = (_EMStrLen16 (temp) + 1) * sizeof (Char16);
		*currMacro = (Char16 *) realloc (*currMacro, size);
		memcpy (*currMacro, temp, size);

		ITListGetCellData(LabelList,currKey,keyOffset,&temp);
		if ((index = atoi (temp)) < 0)
		{
			ITSwitchSetValue (PreviousKey, FALSE);
			PreviousKey = NULL;
			ITSetEnable (macroKeyin, FALSE);
		}
		else
		{
			currMacro = &macro[index];
			ITKeyinSetText (macroKeyin, *currMacro, 0,
					_EMStrLen16 (*currMacro));
		}
	}
	showcursor(window);
	flushbuffer(window);
}


static SetMacro(TCB)
EM_TCB	*TCB;
{
	int	row,type;
	Char16	mText;

	mText = 0;
	ITKeyinSetText (macroKeyin, & mText, 0, 0);
	ITSetEnable (macroKeyin, FALSE);
	if (PreviousModifier)
	{
		ITSwitchSetValue(PreviousModifier,FALSE);
		PreviousModifier = NULL;
		modifier = 0;
		keyOffset = 0;
	}

	if (PreviousShift)
	{
		ITSwitchSetValue(PreviousShift,FALSE);
		PreviousShift = NULL;
		shift = 0;
		keyOffset = 0;
	}

	if (PreviousKey)
	{
		ITSwitchSetValue(PreviousKey,FALSE);
		PreviousKey = NULL;
	}

	for (row = 0; row < 512; row++)
	{
		type = TCB->key_type[row];
		if (type == NORMAL_CHAR)
		{
			macro[row] = (Char16 *) malloc (sizeof (Char16));
			macro[row][0] = 0;
		}
		else if (type == SINGLE_CHAR)
		{
			macro[row] = (Char16 *) malloc (2 * sizeof (Char16));
			macro[row][0] = TCB->key_macro[row].chr;
			macro[row][1] = 0;
		}
		else
		{
			int	size;

			size = (_EMStrLen16 (TCB->key_macro[row].ptr) + 1) *
				sizeof (Char16);
			macro[row] = (Char16 *) malloc (size);
			memcpy (macro[row], TCB->key_macro[row].ptr, size);
		}
	}
}


static GetMacro(TCB)
EM_TCB	*TCB;
{
	int	row, size, length;
	char	*temp;

	if (PreviousKey)
	{
		ITKeyinGetText(macroKeyin,&temp);
		size = (_EMStrLen16 (temp) + 1) * sizeof (Char16);
		*currMacro = (Char16 *) realloc (*currMacro, size);
		memcpy (*currMacro, temp, size);
	}

	for (row = 0; row < 512; row++)
	{
		if (TCB->key_type[row] == STRING_CHAR)
			free (TCB->key_macro[row].ptr);

		length = _EMStrLen16 (macro[row]);
		if (length == 0)
		{
			TCB->key_type[row] = NORMAL_CHAR;
			TCB->key_macro[row].ptr = NULL;
			free (macro[row]);
		}
		else if (length == 1)
		{
			TCB->key_type[row] = SINGLE_CHAR;
			TCB->key_macro[row].chr = macro[row][0];
			free (macro[row]);
		}
		else
		{
			TCB->key_type[row] = STRING_CHAR;
			TCB->key_macro[row].ptr = macro[row];
		}
	}
}


static DrawMacro(window)
int	window;
{
	UpdateKeys ();
	ITImmediateInc(MacroMenu);
	hidecursor(window);
	ITDraw(MacroMenu);
	showcursor(window);
	flushbuffer(window);
}


static EraseMacro(window)
int	window;
{
	ITImmediateDec(MacroMenu);
}


_EMMacro(action,parameter)
int	action,parameter;
{
	switch (action)
	{
		case SET:	SetMacro(parameter);
				break;
		case GET:	GetMacro(parameter);
				break;
		case DRAW:	DrawMacro(parameter);
				break;
		case ERASE:	EraseMacro(parameter);
				break;
	}
}


int	_EMCreateMacro(Menus,name)
ITItem	Menus;
char	*name;
{
	ITItem	Item;
	int	memory, tmp, id;
	int	(*tmpf)();

	if (ITReadFile(name,&MacroMenu,&memory))
		return(FALSE);

	ITGetId (MacroMenu, &id);
	_EMMenuDriver[id - 100] = _EMMacro;
	ITGroupAdd(Menus,MacroMenu,NULL);

	ITGroupFindItemNo (MacroMenu, KEYIN_ID, &macroKeyin);
	ITKeyinSetFilter (macroKeyin, KeyFilter);
	ITGetFontFunc (macroKeyin, &tmpf, &tmpf, &OldGetWidth, &OldDrawString,
		       &tmp);
	ITSetFontFunc (macroKeyin, NULL, NULL, GetWidth, DrawString, 0);

	ITGroupFindItemNo (MacroMenu, BACKSPACE_ID, &Backspace);
	ITSetCompletion (Backspace, BSCompletion);
	ITGroupFindItemNo(MacroMenu,CLEAR_ID,&Item);
	ITSetCompletion(Item,ClearCompletion);
	ITGroupFindItemNo(MacroMenu,MODIFIERS_ID,&Item);
	ITSetCompletion(Item,ModifierCompletion);

	ITGroupFindItemNo(MacroMenu,SHIFTS_ID,&Item);
	ITGetSpecial (Item, &numShiftStates);
	ITSetCompletion(Item,ShiftCompletion);

	ITGroupFindItemNo(MacroMenu,KEYS_ID,&Keys);
	ITSetCompletion(Keys,KeyCompletion);
	ITGroupFindItemNo(MacroMenu,LABEL_LIST_ID,&LabelList);
	ITGroupRemove(LabelList);
	ITGroupFindItemNo(MacroMenu,CHAR_LIST_ID,&CharList);
	ITGroupRemove(CharList);

	return(TRUE);
}
