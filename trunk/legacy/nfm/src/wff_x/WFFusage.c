#include "machine.h"
#include <stdio.h>
#include <string.h>

void _WFFinit_usage (program_name, usage)
  char	*program_name;  /*  i - name of program                */
  char	*usage;         /*  o - string to store usage message  */
  {
	/*  Initialize "usage" string  */

	sprintf (usage, "Usage:  %s [options]\n", program_name);
	strcat (usage, "Options:\n");
/*
	strcat (usage, "  -s server          ");
	strcat (usage, "I/NFM server to connect to\n");
*/
	strcat (usage, "  -u username        ");
	strcat (usage, "I/NFM username to log in with\n");
	strcat (usage, "  -p password        ");
	strcat (usage, "I/NFM password to log in with (default is username)\n");
	strcat (usage, "  -e environment     ");
	strcat (usage, "I/NFM environment to log in to (default is server)\n");
/*
	strcat (usage, "  -A                 ");
	strcat (usage, "Use administrative menus (default is user menus)\n\n");
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
	strcat (usage, "  -S timestamp_file  ");
	strcat (usage, "Filename to store command timestamp information in\n\n");
	strcat (usage, "  -n NETdebug_file   ");
	strcat (usage, "Filename for I/NFM network interface debug output\n");
*/
	strcat (usage, "  -r NFIdebug_file   ");
	strcat (usage, "Filename for I/NFM Work Flow interface debug output\n");
	strcat (usage, "  -d NFMdebug_file   ");
	strcat (usage, "Filename for I/NFM server debug output\n");
	strcat (usage, "  -S SQLdebug_file   ");
	strcat (usage, "Filename for I/NFM sql subsystem debug output\n");
	strcat (usage, "  -m MEMdebug_file   ");
	strcat (usage, "Filename for I/NFM memory subsystem debug output\n");
	strcat (usage, "  -E ERRdebug_file   ");
	strcat (usage, "Filename for I/NFM error processor debug output\n");

	return;
  }
