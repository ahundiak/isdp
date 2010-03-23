/* This program draws a spiral using the characters contained in the	*/
/* text string.								*/


#include <stdio.h>
#include <tools.h>
#include <math.h>
#include <FS.h>

char string[] = "The quick brown fox jumps over the lazy dog.";

FontSpec fontSpec = {	"swiss742",	/* typeface	*/
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
    int tmp, window, i, j, len, vs, stat;
    char *str;
    double x, y, dangle, dsize, extraWidth, atof ();

    if (argc > 1)
	fontSpec.typeface = argv[1];

    dangle = -10.0;
    if (argc > 2)
	dangle = atof (argv[2]);

    dsize = 1.0;
    if (argc > 3)
	dsize = atof (argv[3]);

    extraWidth = 0;
    if (argc > 4)
	extraWidth = atof (argv[4]);

    if (argc > 5)
	fontSpec.flags = atoi (argv[5]);

    str = string;
    if (argc > 6)
	str = argv[6];

    Enter_tools_no_act ();
    Enable_events (DELETE_EVENT);

    FSEnter (0);

    len = strlen (str);
    x = 320.0;	y = 320.0;

    Inq_displayed_vs (&vs);
    Create_win (vs, "Spiral fonts!", 20, 30, 620, 630, &window);
    Set_win_sys_icon (window, REFRESH_ICON_VALUE, 0);
    Display_win (window);

    hidecursor (window);

    fontSpec.rotation = 0.0;
    fontSpec.bodySize = 10;
    for (i = 0; i < len; i++)
    {
	rangeSpec[0].start = str[i];
	if ((stat = FSNewFont (&fontSpec, rangeSpec, &font)) != FS_NO_ERROR)
	{
	    printf ("Can't create font!  Error = %d.\n", stat);
	    goto Done;
	}
	FSSetExtraWidth (font, extraWidth * fontSpec.bodySize / 10.0);
	FSDrawChar (window, font, str[i], x, y, &x, &y);
	flushbuffer (window);
	FSDeleteFont (font);

	fontSpec.rotation += dangle;
	fontSpec.bodySize += dsize;
    }

    showcursor (window);
    flushbuffer (window);

    Wait_for_events (DELETE_EVENT, &tmp);

Done:
    FSExit ();
    Exit_tools ();
}
