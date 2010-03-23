/* This program spins a string.						*/


#include <stdio.h>
#include <tools.h>
#include <FS.h>

char str[] = "The quick brown fox jumps over the lazy dog.";

FontSpec fontSpec = {	"swiss742",	/* typeface	*/
			24.0,		/* bodysize	*/
			1.0,		/* arf		*/
			1.0,		/* aspect ratio	*/
			0.0,		/* rotation	*/
			0.0,		/* slant	*/
			"ascii",	/* char map	*/
			FS_NO_KERN | FS_ALL_BITMAPS | FS_NO_PLAID | FS_DEMAND
		    };

main (argc, argv)
int argc;
char *argv[];
{
    FontId font[512];
    int window, i, spokes, vs, dbAbility;
    long event;
    double x, y, atof();
    char *string;
    struct scr_info screenInfo[MAX_SCREENS];

    if (argc > 1)
	fontSpec.typeface = argv[1];

    if (argc > 2)
	fontSpec.bodySize = atof (argv[2]);

    spokes = 32;
    if (argc > 3)
	spokes = atoi (argv[3]);

    if (argc > 4)
	fontSpec.flags = atoi (argv[4]);

    string = str;
    if (argc > 5)
	string = argv[5];

    memset (font, 0, 512 * sizeof (FontId));

    Enter_tools_no_act ();
    Enable_events (DELETE_EVENT);

    FSEnter (0);

    for (i = 0; i < spokes; i++)
    {
	fontSpec.rotation = (float) (i * 360 / spokes);
	FSNewFont (&fontSpec, NULL, &font[i]);
	FSSetKernMode (font[i], 0);
    }

    Inq_displayed_vs (&vs);
    Inq_screen_info (screenInfo);
    dbAbility = screenInfo[vs].vsi_flags & VSI_DB_ABILITY;

    Create_win (vs, "Fonts!", 20, 40, 1019, 819, &window);
    Set_win_button_mode (window, 3);
    Display_win (window);

    for (;;)
    {
	for (i = 0; i < spokes; i++)
	{
	    if (dbAbility)
		enter_db (vs, 0);
	    else
		hidecursor (window);

	    fgcolor (window, 0);
	    rectf (window, 0, 0, 1000, 780);

	    fgcolor (window, -1);
	    x = 500.0;	y = 400.0;
	    FSDrawString (window, font[i], string, x, y, NULL, NULL);

	    if (dbAbility)
		exit_db (vs, 0);
	    else
		showcursor (window);
	    flushbuffer (window);

	    Inq_events (&event);
	    if (event & DELETE_EVENT)
		goto DONE;
	}
    }

DONE:
    for (i = 0; i < spokes; i++)
	if (font[i] != NULL)
	    FSDeleteFont (font[i]);

    FSExit ();
    Exit_tools ();
}
