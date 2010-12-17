
/* machine.h included to take care of platform variencies MVR 23 Dec 1993 */
#include "machine.h"

#include "NFF.h"

void _NFFinit_usage (program_name, usage)
  char    *program_name;  /*  i - name of program                */
  char    *usage;         /*  o - string to store usage message  */
  {
    /*  Initialize "usage" string  */

    sprintf (usage, "Usage:  %s [options]\n", program_name);
    strcat (usage, "Options:\n");
#ifndef COMBINED_CLIENT_SERVER
    strcat (usage, "  -s server          ");
    strcat (usage, "I/NFM server to connect to\n");
#endif
    strcat (usage, "  -u username        ");
    strcat (usage, "I/NFM username to log in with\n");
    strcat (usage, "  -p password        ");
    strcat (usage, "I/NFM password to log in with\n");
    strcat (usage, "  -e environment     ");
#ifdef COMBINED_CLIENT_SERVER
    strcat (usage, "I/NFM environment to log in to\n");
#else
    strcat (usage, "I/NFM environment to log in to (default is server)\n");
#endif
    strcat (usage, "  -A                 ");
    strcat (usage, "Use administrative menus (default is user menus)\n");
    strcat (usage, "  -c                 ");
    strcat (usage, "Collapse menus and forms at startup\n\n");

/* X-Windows based versions of NFM still have not been provided with
   Recording and Playback features   - Jujare-IGI-15 FEB 1995 */

#ifndef XWINDOWS
    strcat (usage, "  -R recording_file  ");
    strcat (usage, "Filename to store recording information in\n");
    strcat (usage, "  -P playback_file   ");
    strcat (usage, "Filename to read playback information from\n");
    strcat (usage, "  -T playback_time   ");
    strcat (usage, "Playback time in 1/60 second increments\n");
    strcat (usage, "                     ");
    strcat (usage, " (default is 30, i.e., 1/2 second between commands)\n");
    strcat (usage, "  -D delay_time      ");
    strcat (usage, "Seconds to delay until playback session begins\n");
#endif

    strcat (usage, "  -S timestamp_file  ");
    strcat (usage, "Filename to store command timestamp information in\n\n");
    strcat (usage, "  -d NFIdebug_file   ");
    strcat (usage, "Filename for I/NFM forms interface debug output\n");
#ifndef COMBINED_CLIENT_SERVER
    strcat (usage, "  -r NFMRdebug_file  ");
    strcat (usage, "Filename for I/NFM requestor interface debug output\n");
#endif
#ifdef COMBINED_CLIENT_SERVER
    strcat (usage, "  -N NFMdebug_file   ");
    strcat (usage, "Filename for I/NFM database interface debug output\n");
    strcat (usage, "  -Q SQLdebug_file   ");
    strcat (usage,
        "Filename for I/NFM query language interface debug output\n");
#endif
    strcat (usage, "  -n NETdebug_file   ");
    strcat (usage, "Filename for I/NFM network interface debug output\n");
    strcat (usage, "  -m MEMdebug_file   ");
    strcat (usage, "Filename for I/NFM memory subsystem debug output\n");
    strcat (usage, "  -E ERRdebug_file   ");
    strcat (usage, "Filename for I/NFM error processor debug output\n");

    return;
  }
