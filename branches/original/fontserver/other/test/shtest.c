/* This program gives the shared memory font code a workout.		*/
/* It must be linked with a debug version of the Font Server.		*/
/* Unfortunately, since shared memory is normally controlled by the	*/
/* daemon, and since the debug version of the library has extra		*/
/* information stored in the memory storage data structures, it is	*/
/* necessary for the daemon to be linked with the same debug library.	*/
/* Otherwise, this program will crash!!!!				*/


#include <stdio.h>
#include <tools.h>
#include <FS.h>
#include <FSBmap.h>

char str[] = "Hello.";

FontSpec fontSpec = {	"swiss742",	/* typeface	*/
			32.0,		/* bodysize	*/
			1.0,		/* arf		*/
			1.0,		/* aspect ratio	*/
			0.0,		/* rotation	*/
			0.0,		/* slant	*/
			"ascii",	/* char map	*/
			FS_SHARED | FS_DEMAND
		    };

main (argc, argv)
int argc;
char *argv[];
{
    FontId font;
    BmapInfo info;
    int window, i, vs, x, y, num;
    long event;
    double atof ();
    char *string, buffer[1];

    num = 0;
    if (argc > 1)
	num = atoi (argv[1]);

    if (argc > 2)
	fontSpec.typeface = argv[2];

    if (argc > 3)
	fontSpec.bodySize = atof (argv[3]);

    if (argc > 4)
	fontSpec.resFactor = atof (argv[4]);

    if (argc > 5)
	fontSpec.aspect = atof (argv[5]);

    if (argc > 6)
	fontSpec.rotation = atof (argv[6]);

    if (argc > 7)
	fontSpec.slant = atof (argv[7]);

    if (argc > 8)
	fontSpec.charMap = argv[8];

    if (argc > 9)
	fontSpec.flags = atoi (argv[9]);

    string = str;
    if (argc > 10)
	string = argv[10];

    FSEnter (0);

    if (FSNewFont (&fontSpec, NULL, &font) != FS_NO_ERROR)
    {
	printf ("Can't create font!\n");
	goto Done;
    }

    if (FSGetBmapInfo (font, &info) != FS_NO_ERROR)
	FSGetOutlInfo (font, &info);

    Enter_tools ();
    Enable_events (DELETE_EVENT | KEYBOARD_EVENT);
    Set_keyboard_buffer (buffer, 1);

    Inq_displayed_vs (&vs);
    x = 40 + num * 10;
    y = 40 + num * (int) fontSpec.bodySize;
    Create_win (vs, "Fonts!", x, y, x + 1000, y + (int) fontSpec.bodySize + 20,
		&window);
    Set_win_sys_icon (window, REFRESH_ICON_VALUE, 0);
    Set_win_button_mode (window, 3);
    Display_win (window);

    for (;;)
    {
	Erase_win (window);

	hidecursor (window);
	FSDrawString (window, font, string, 10.0,
		      info.bodySize - info.descent + 10.0, NULL, NULL);
	showcursor (window);
	flushbuffer (window);

	Wait_timer (10);

	Inq_events (&event);

	if (event & DELETE_EVENT)
	    break;

	if (event & KEYBOARD_EVENT)
	{
	    int	count;

	    Get_keyboard_data (&count);

	    if (count > 0)
	    {
		switch (buffer[0])
		{
		    case 'c':
			printf ("Compact...\n");
			_GCSetMemory (1);
			_GCLockSem (1);
			_GCShCompact ();
			_GCUnlockSem (1);
			break;

		    case 'r':
			printf ("Relocate all...\n");
			_GCSetMemory (1);
			_GCLockSem (1);
			_GCRelocateAll ();
			_GCUnlockSem (1);
			break;

		    case 'k':
			printf ("Check...\n");
			_GCSetMemory (1);
			_GCLockSem (1);
			_GCShCheck ();
			_GCUnlockSem (1);
			break;

		    case 'p':
			_GCSetMemory (1);
			_GCLockSem (1);
			_GCShPrint ();
			_GCUnlockSem (1);
			break;

		    case 'q':
			goto Exit;
		}
	    }
	}
    }

Exit:
    FSDeleteFont (font);

    Exit_tools ();

Done:
    FSExit ();
}
