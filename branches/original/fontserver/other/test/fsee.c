/** This program is an exerciser that tests the Font Server's		**/
/** capability of initializing, creating a font, displaying the font,	**/
/** and cleaning up.  Memory leaks can be found by montioring its	**/
/** memory usage with ps.						**/
/** It also tests the rangeSpec parameter of the FSNewFont() routine.	**/


#include <stdio.h>
#include <tools.h>
#include <FS.h>

char str[] = "A man, a plan.";

FontSpec fontSpec = {	"swiss742",	/* typeface	*/
			24.0,		/* bodysize	*/
			1.0,		/* arf		*/
			1.0,		/* aspect ratio	*/
			0.0,		/* rotation	*/
			0.0,		/* slant	*/
			"ascii",
			FS_NO_KERN | FS_ALL_BITMAPS
		    };

main (argc, argv)
int argc;
char *argv[];
{
    FontId font, font2;
    RangeSpec *range;
    int tmp, window, i, j, len, vs;
    double x, y, atof ();
    char *string;
    long event;

    if (argc > 1)
	fontSpec.typeface = argv[1];

    if (argc > 2)
	fontSpec.bodySize = atof (argv[2]);

    if (argc > 3)
	fontSpec.charMap = argv[3];

    if (argc > 4)
	fontSpec.flags = atoi (argv[4]);

    string = str;
    if (argc > 5)
	string = argv[5];

    range = (RangeSpec *) malloc ((strlen (string) + 1) * sizeof (RangeSpec));
    for (i = 0; i < strlen (string); i++)
    {
	range[i].start = (CharId) string[i];
	range[i].count = 1;
    }
    range[i].start = (CharId) -1;

    Enter_tools_no_act ();
    Enable_events (DELETE_EVENT);

    Inq_displayed_vs (&vs);
    Create_win (vs, "Enter & exit", 40, 40, 1040, 820, &window);
    Set_win_sys_icon (REFRESH_ICON_VALUE, 0);
    Display_win (window);

    srand (getpid () + time (NULL));

    for (i = 0; i < 100; i++)
    {
	FSEnter (0);

	if (FSNewFont (&fontSpec, range, &font) != FS_NO_ERROR)
	{
	    printf ("Can't create font!\n");
	    FSExit ();
	    goto DONE;
	}

	x = (double) (rand () % 1000);
	y = (double) (rand () % 780);
	hidecursor (window);
	FSDrawString (window, font, string, x, y, &x, &y);
	showcursor (window);
	flushbuffer (window);

	FSDeleteFont (font);
	FSExit ();

	Inq_events (&event);
	if (event & DELETE_EVENT)
	    break;
    }

DONE:
    if (range != NULL)
	free (range);

    Exit_tools ();
}
