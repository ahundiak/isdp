/** This program is an exerciser that tests the Font Server's		**/
/** capability of creating a font, writing it to a file, reading it	**/
/** back in, and displaying it.  Memory leaks can be found by		**/
/** montioring its memory usage with ps.				**/
/** Note:  This program does is not for testing shared fonts		**/
/** because it writes to the same font file over and over.		**/


#include <stdio.h>
#include <tools.h>
#include <math.h>
#include <FS.h>

char string[] = "The quick brown fox jumps over the lazy dog.  Now is the time for all good men to come to the aid of their country.  A man, a plan, a canal, panama.";

FontSpec fontSpec = {	"mono821",	/* typeface	*/
			24.0,		/* bodysize	*/
			1.0,		/* arf		*/
			1.0,		/* aspect ratio	*/
			0.0,		/* rotation	*/
			0.0		/* slant	*/
			"ascii",	/* char map	*/
			FS_NO_KERN | FS_ALL_BITMAPS | FS_NO_PLAID
		    };

RangeSpec rangeSpec[] = { { 32, 1 },
			  { -1, -1 } };

main (argc, argv)
int argc;
char *argv[];
{
    FontId font;
    int tmp, window, i, j, len, vs, num;
    double x, y, dangle, dsize, extraWidth, atof ();

    if (argc > 1)
	fontSpec.typeface = argv[1];

    dangle = -12.0;
    if (argc > 2)
	dangle = atof (argv[2]);

    dsize = 1.0;
    if (argc > 3)
	dsize = atof (argv[3]);

    extraWidth = 0.0;
    if (argc > 4)
	extraWidth = atof (argv[4]);

    if (argc > 5)
	fontSpec.flags = atoi (argv[5]);

    num = 1;
    if (argc > 6)
	num = atoi (argv[6]);

    Enter_tools_no_act ();
    Enable_events (DELETE_EVENT);

    FSEnter (0);

    len = strlen (string);

    Inq_displayed_vs (&vs);
    Create_win (vs, "Exercise!", 40, 40, 840, 800, &window);
    Set_win_sys_icon (REFRESH_ICON_VALUE, 0);
    Display_win (window);

    for (j = 0; j < num; j++)
    {
	Erase_win (window);

	x = 400.0;	y = 400.0;
	fontSpec.rotation = 0.0;
	fontSpec.bodySize = 10;
	for (i = 0; i < len; i++)
	{
	    rangeSpec[0].start = string[i];
	    FSNewFont (&fontSpec, rangeSpec, &font);
	    FSWriteFontFile (font, "exerfont");
	    FSDeleteFont (font);
	    FSReadFontFile ("exerfont", &font);

	    FSSetExtraWidth (font, extraWidth * fontSpec.bodySize / 10.0);
	    hidecursor (window);
	    FSDrawChar (window, font, string[i], x, y, &x, &y);
	    showcursor (window);
	    flushbuffer (window);

	    FSDeleteFont (font);

	    fontSpec.rotation += dangle;
	    fontSpec.bodySize += dsize;
	}
    }

    Wait_for_events (DELETE_EVENT, &tmp);

    FSExit ();
    Exit_tools ();
}
