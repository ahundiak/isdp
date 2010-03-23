/* This program allows you to mess with the blocks in shared memory	*/
/* while another program is creating and using shared fonts.  It tests	*/
/* the robustness of the shared font code.				*/
/* It must be linked with a debug version of the Font Server.		*/
/* Unfortunately, since shared memory is normally controlled by the	*/
/* daemon, and since the debug version of the library has extra		*/
/* information stored in the memory storage data structures, it is	*/
/* necessary for the daemon to be linked with the same debug library.	*/
/* Otherwise, this program will crash!!!!				*/


#include <stdio.h>
#include <tools.h>
#include <FS.h>


main (argc, argv)
int argc;
char *argv[];
{
    long event;
    char buffer[1];

    FSEnter (0);

    Enter_tools ();
    Enable_events (KEYBOARD_EVENT);
    Set_keyboard_buffer (buffer, 1);

    /* Initialize shared memory data structures.  This is normally	*/
    /* done by FSNewFont, FSReadFont, etc.  It makes sure this process	*/
    /* knows about the shared memory data structures.			*/
    _FSShEnter ();

    for (;;)
    {
	Wait_for_events (KEYBOARD_EVENT, &event);

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

		    case 'n':
			printf ("Lock & unlock shmem...\n");
			_GCSetMemory (1);
			_GCLockSem (1);
			_GCUnlockSem (1);
			break;

		    case 'q':
			goto Exit;
		}
	    }
	}
    }

Exit:
    Exit_tools ();
    FSExit ();
}
