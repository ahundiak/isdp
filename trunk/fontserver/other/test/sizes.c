/* This program displays incremental sizes of a font.			*/


#include <stdio.h>
#include <tools.h>
#include <FS.h>

char *string = "The quick brown fox jumps over the lazy dog.";

FontSpec fontSpec = {	"swiss742",	/* typeface	*/
			8.0,		/* bodysize	*/
			1.0,		/* arf		*/
			1.0,		/* aspect ratio	*/
			0.0,		/* rotation	*/
			0.0,		/* slant	*/
			"ascii",	/* char map	*/
			FS_DEMAND	/* flags	*/
		    };

main (argc, argv)
int argc;
char *argv[];
{
    FontId font;
    int tmp, wno, i, j, len, vs;
    double x, y, sizeInc, atof ();
    char sizeStr[10];

    if (argc > 1)
	fontSpec.typeface = argv[1];

    if (argc > 2)
	fontSpec.bodySize = atof (argv[2]);

    sizeInc = 2.0;
    if (argc > 3)
	sizeInc = atof (argv[3]);

    if (argc > 4)
	fontSpec.charMap = argv[4];

    if (argc > 5)
	fontSpec.flags = atoi (argv[5]);

    if (argc > 6)
	string = argv[6];

    FSEnter (0);

    Enter_tools_no_act ();
    Enable_events (DELETE_EVENT);

    Inq_displayed_vs (&vs);
    Create_win (vs, "Fonts!", 20, 30, 1020, 820, &wno);
    Set_win_sys_icon (wno, REFRESH_ICON_VALUE, 0);
    Display_win (wno);

    hidecursor (wno);

    y = 0.0;
    for (; y < 800.0; fontSpec.bodySize += sizeInc)
    {
	if (FSNewFont (&fontSpec, NULL, &font) != FS_NO_ERROR)
	{
	    printf ("Can't create font!\n");
	    goto DONE;
	}

	x = 10.0;	y += fontSpec.bodySize;
	sprintf (sizeStr, "%d:  ", (int) fontSpec.bodySize);
	FSDrawString (wno, font, sizeStr, x, y, &x, &y);
	FSDrawString (wno, font, string, x, y, NULL, NULL);
	flushbuffer (wno);

	FSDeleteFont (font);
    }

    showcursor (wno);
    flushbuffer (wno);

    Wait_for_events (DELETE_EVENT, &tmp);

DONE:
    Exit_tools ();

    FSExit ();
}
