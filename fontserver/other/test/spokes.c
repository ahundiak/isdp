/* This program draws a number of spokes made up of a string and the	*/
/* width and height of the string, in pixels.				*/


#include <stdio.h>
#include <tools.h>
#include <FS.h>

char string[] = "Howdy there!";

FontSpec fontSpec = {	"swiss742",	/* typeface	*/
			24.0,		/* bodysize	*/
			1.0,		/* arf		*/
			1.0,		/* aspect ratio	*/
			0.0,		/* rotation	*/
			0.0,		/* slant	*/
			"ascii",
			FS_NO_KERN | FS_ALL_BITMAPS | FS_DEMAND
		    };

main (argc, argv)
int argc;
char *argv[];
{
    FontId font[64];
    int vs, tmp, w_no, i, j, len, spokes, newLen;
    double x, y, atof ();
    char newString[512];
    
    if (argc > 1)
	fontSpec.typeface = argv[1];

    if (argc > 2)
	fontSpec.bodySize = atof (argv[2]);
	
    spokes = 3;
    if (argc > 3)
	spokes = atoi (argv[3]);

    Enter_tools_no_act ();
    Enable_events (DELETE_EVENT);

    FSEnter(0);

    for (i = 0; i < spokes; i++)
    {
	fontSpec.rotation = i * 360.0 / spokes;
	FSNewFont (&fontSpec, NULL, &font[i]);
    }
    
    Inq_displayed_vs (&vs);
    Create_win (vs, "String sizes", 20, 40, 1020, 840, &w_no);
    Set_win_sys_icon (w_no, REFRESH_ICON_VALUE, 0);
    Display_win (w_no);

    len = strlen (string);
    hidecursor (w_no);
    for (i = 0; i < spokes; i++)
    {
	FSGetTextVect (font[i], string, len, 0.0, 0.0, &x, &y);
	sprintf (newString, "%s  %6.2f %6.2f", string, x, y);
	newLen = strlen (newString);

	x = 500.0;	y = 400.0;
	FSDrawText (w_no, font[i], newString, newLen, x, y, &x, &y);
	FSDrawString (w_no, font[i], "!!!!", x, y, NULL, NULL);
    }
    showcursor (w_no);
    flushbuffer (w_no);

    Wait_for_events (DELETE_EVENT, &tmp);

    FSExit ();
    Exit_tools ();
}
