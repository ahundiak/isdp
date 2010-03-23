/* This program exercises the FSPutBmap*() routines.  It offsets the	*/
/* bitmaps of every character in the font, and it shuffles the		*/
/* characters in the font.						*/


#include <stdio.h>
#include <tools.h>
#include <math.h>
#include <FS.h>
#include <FSBmap.h>

char str[] = "The quick brown fox jumps over the lazy dog!";

FontSpec fontSpec = {	"swiss742",	/* typeface	*/
			24.0,		/* bodysize	*/
			1.0,		/* arf		*/
			1.0,		/* aspect ratio	*/
			0.0,		/* rotation	*/
			0.0,		/* slant	*/
			"ascii",	/* ASCII	*/
			0
		    };

main (argc, argv)
int argc;
char *argv[];
{
    FontId font;
    int tmp, window, i, vs, hModulus, vModulus, hAddend, vAddend, numChar;
    int bmapSize;
    char *string;
    double x, y, atof();
    BmapHeader header;
    BmapCharInfo *charInfo, cInfo, cInfoSave;
    BmapBitmap *bitmap, *bitmapSave;
    RangeSpec *range;

    if (argc > 1)
	fontSpec.typeface = argv[1];

    if (argc > 2)
	fontSpec.bodySize = atof (argv[2]);

    string = str;
    if (argc > 3)
	string = argv[3];

    Enter_tools_no_act ();
    Enable_events (DELETE_EVENT);

    FSEnter (0);

    range = (RangeSpec *) malloc (sizeof (RangeSpec) * (strlen (string) + 1));
    for (i = 0; i < strlen (string); i++)
    {
	range[i].start = string[i];
	range[i].count = 1;
    }
    range[i].start = range[i].count = -1;

    if (FSNewFont (&fontSpec, range, &font))
	goto DONE;

    if (FSGetBmapCharInfo (font, ' ', &cInfo) == FS_NO_ERROR)
    {
	cInfo.setWid *= 2;
	FSPutBmapCharInfo (font, ' ', &cInfo);
	FSUpdateBmapFont (font);
    }

    FSGetBmapAllCharInfo (font, NULL, &numChar);
    charInfo = (BmapCharInfo *) malloc (numChar * sizeof (BmapCharInfo));

    bitmap = (BmapBitmap *) malloc (1024);
    bitmapSave = (BmapBitmap *) malloc (1024);

    Inq_displayed_vs (&vs);
    Create_win (vs, "Fonts!", 20, 40, 1020, 800, &window);
    Display_win (window);

    srand (getpid () + time (NULL));
    hModulus = vModulus = 3;
    hAddend = vAddend = -1;

    for (tmp = 0; tmp < 100; tmp++)
    {

/*** Offset the bitmaps a random amount */

	FSGetBmapAllCharInfo (font, &charInfo, &numChar);
	for (i = 0; i < numChar; i++)
	{
	    charInfo[i].hOff += (rand () % hModulus) + hAddend;
	    charInfo[i].vOff += (rand () % vModulus) + vAddend;
	    FSPutBmapCharInfo (font, charInfo[i].charId, &charInfo[i]);
	}
/***/


/*** Shuffle the bitmaps between characters */

	FSGetBmapBitmap (font, charInfo[0].charId, &bitmapSave, &bmapSize);
	FSGetBmapCharInfo (font, charInfo[0].charId, &cInfoSave);
	cInfoSave.charId = charInfo[numChar - 1].charId;
	for (i = 0; i < numChar; i++)
	{
	    FSGetBmapBitmap (font, charInfo[(i + 1) % numChar].charId, &bitmap,
			     &bmapSize);
	    FSGetBmapCharInfo (font, charInfo[(i + 1) % numChar].charId, &cInfo);
	    cInfo.charId = charInfo[i].charId;
	    FSPutBmapBitmap (font, cInfo.charId, bitmap, cInfo.nMap);
	    FSPutBmapCharInfo (font, cInfo.charId, &cInfo);
	}
	FSPutBmapBitmap (font, cInfoSave.charId, bitmapSave, cInfoSave.nMap);
	FSPutBmapCharInfo (font, cInfoSave.charId, &cInfoSave);
/***/

	FSUpdateBmapFont (font);

	enter_db (vs, 0);
 	Erase_win (window);
	x = 40.0;	y = 380.0;
	FSDrawString (window, font, string, x, y, &x, &y);
	exit_db (vs, 0);
    }
    free (charInfo);

DONE:
    free (range);
    FSExit ();
    Exit_tools ();
}
