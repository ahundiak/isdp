/* This program tests the FS_THICKEN flag, which is a kludgy way to	*/
/* thicken bitmap fonts for white-writer printers.			*/


#include <stdio.h>
#include <tools.h>
#include <FS.h>
#include <FSBmap.h>

char str[] = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz";

FontSpec fontSpec = {	"dutch801",	/* typeface	*/
			14.0,		/* bodysize	*/
			1.0,		/* arf		*/
			1.0,		/* aspect ratio	*/
			0.0,		/* rotation	*/
			0.0,		/* slant	*/
			"ascii",
			FS_DEMAND
		    };

main (argc, argv)
int argc;
char *argv[];
{
    FontId font0, font1;
    BmapInfo info;
    int vs, tmp, wno, i, j, len, stat;
    double x, y, atof ();
    char *string;

    if (argc > 1)
	fontSpec.typeface = argv[1];

    if (argc > 2)
	fontSpec.bodySize = atof (argv[2]);

    string = str;
    if (argc > 6)
	string = argv[6];

    FSEnter (0);

    fontSpec.flags &= ~FS_THICKEN;
    if ((stat = FSNewFont (&fontSpec, NULL, &font0)) != FS_NO_ERROR)
    {
	printf ("Can't create font 0!  Error = %d\n", stat);
	goto Done;
    }

    fontSpec.flags |= FS_THICKEN;
    if ((stat = FSNewFont (&fontSpec, NULL, &font1)) != FS_NO_ERROR)
    {
	printf ("Can't create font 1!  Error = %d\n", stat);
	goto Done;
    }

    FSGetBmapInfo (font0, &info);

    Enter_tools_no_act ();
    Enable_events (DELETE_EVENT);

    Inq_displayed_vs (&vs);
    Create_win (vs, "Fonts!", 20, 40, 1020, 420, &wno);
    Set_win_sys_icon (wno, REFRESH_ICON_VALUE, 0);
    Display_win (wno);

    len = strlen (string);
    hidecursor (wno);

    x = 10.0;
    y = info.maxExtent;
    FSDrawString (wno, font0, string, x, y, &x, &y);

    x = 10.0;
    y += info.maxExtent - info.minExtent;
    FSDrawString (wno, font1, string, x, y, &x, &y);

    showcursor (wno);
    flushbuffer (wno);

    Wait_for_events (DELETE_EVENT, &tmp);

    Exit_tools ();

Done:
    FSExit ();
}
