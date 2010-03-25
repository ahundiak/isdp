#include <stdio.h>
#include <sys/types.h>
#include <sys/stat.h>
#include "defs.h"
#include "main.h"

char *tape_device;
char *ldirname;
char *resultstr;
extern short	srcmedia;
extern char	*net_connect();

extern char	tapecmd[];

/*****************************************************************************
 * Function:		media_connect
 *
 * Purpose:		Establish "connection" with delivery media -
 *			For network or remote CD-ROM, perform network
 *			    connection
 *			For local tape, perform device open
 *			For local floppy or CD-ROM, perform device mount
 *
 * Globals used:	srcmedia - delivery media type
 *                      (NOTE: For NETWORK, value of "srcmedia" will be
 *			    changed to reflect the type of connection -
 *			    VAX, WORKSTATION, or TCPIP)
 *
 * Parameter(s):	connstr - device node name or network connect string
 *
 * Return Value:	NULL pointer if successful,
 *			pointer to error message string if unsuccessful.
 *
 * History:		01/17/91  01.00.00	Initial development
 *****************************************************************************/

char	*media_connect(connstr)
char	*connstr;
{
    char *tape_error_str = "Cannot open tape device ";
    char *envstr;
    struct stat statbuf;

    /* clear this out so that you won't get the same error again */
    resultstr = NULL;

    switch (srcmedia) {
	case TAPE:		/* Local tape drive */
	    strcpy(tapecmd, connstr);
	    tape_device = tapecmd;
	    get_tape_file();
	    if (open_tape() < 0) {
		resultstr = (char *)malloc(strlen(tape_error_str) + strlen(connstr));
		if (resultstr != NULL) {
		    strcpy(resultstr, tape_error_str);
		    strcat(resultstr, connstr);
		}
		else
		    resultstr = "Memory allocation error";
	    }
	    break;

	case CDROM:		/* Local CD-ROM drive */
	    if (mountfs(CDROM_DEVICE, MNTDIR, 1))
		resultstr = "Cannot mount CD-ROM drive.\nMake sure that a newprod CD-ROM is inserted in the drive.";
	    break;

	case FLOPPY:		/* Local floppy drive */
	    if (mountfs(FLOP_DEVICE, FMNTDIR, 1))
		resultstr = "Cannot mount floppy drive.\nMake sure that a newprod floppy is inserted in the drive.";
	    break;

	case NETWORK:		/* Network or Remote CD-ROM drive */
	case NETCDROM:
	    chek_connstr(connstr);	/* assure reasonable connstr */
	    envstr = (char *)malloc(strlen(connstr) + 9);
	    if (envstr != NULL) {
		sprintf(envstr,"SRCDATA=%s", connstr);
		putenv(envstr);
		/* If srcmedia was NETWORK, net_connect will now set it
		 * to VAX, WORKSTATION, or TCPIP
		 */
		resultstr = net_connect(connstr);
	    }
	    else
		resultstr = "Memory allocation error";

	    break;

	case LOCAL_DIR:		/* Local directory */
	    ldirname = connstr;
	    if (access(ldirname, 00) < 0) {
		resultstr = "Directory does not exist.";
	    }
	    else {
		if (stat(ldirname, &statbuf) < 0) {
		    resultstr = "Directory does not exist.";
		}
		else if (!(statbuf.st_mode & S_IFDIR)) {
		    resultstr = "Directory does not exist.";
		}
	    }
	    break;

	default:
	    resultstr = "Unknown media type";
	    break;
    }
    return(resultstr);
}
