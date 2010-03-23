/* This program reads the specified Font Server font file and displays	*/
/* characters from it.							*/


#include <stdio.h>
#include <tools.h>
#include <FS.h>
#include <FSBmap.h>

char str[] = "The quick brown fox jumps over the lazy dog. 0123456789 !@#$%^&*()[]{}<>";


main (argc, argv)
int argc;
char *argv[];
{
    FontId font;
    BmapInfo info;
    int vs, tmp, window, i, j, len, stat;
    double x, y, atof ();
    char *string, *fileName;

    fileName = "afont";
    if (argc > 1)
	fileName = argv[1];

    string = str;
    if (argc > 2)
	string = argv[2];

    FSEnter (0);

    if ((stat = FSReadFontFile (fileName, &font)) != FS_NO_ERROR)
    {
	printf ("Can't read font: %d\n", stat);
	goto DONE;
    }

    if (FSGetBmapInfo (font, &info) != FS_NO_ERROR)
	FSGetOutlInfo (font, &info);

    Enter_tools_no_act ();
    Enable_events (DELETE_EVENT);

    Inq_displayed_vs (&vs);
    Create_win (vs, "A font file", 20, 40, 1019, 439, &window);
    Set_win_sys_icon (window, REFRESH_ICON_VALUE, 0);
    Display_win (window);

    len = strlen (string);
    hidecursor (window);

    x = 10.0;	y = info.bodySize - info.descent;
    FSDrawString (window, font, string, x, y, &x, &y);

    x = 10.0;	y += info.bodySize;
    FSDrawString (window, font, "Now is the time for all good men.", x, y, &x, &y);

    showcursor (window);
    flushbuffer (window);

    Wait_for_events (DELETE_EVENT, &tmp);

    FSDeleteFont (font);

    Exit_tools ();

DONE:
    FSExit ();
}
