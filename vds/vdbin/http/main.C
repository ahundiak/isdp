/* $Id: main.C,v 1.1.1.1 2001/01/04 21:07:56 cvs Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        vdbin/http/main.C
 *
 * Description:	HTTP Test Program
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: main.C,v $
 *      Revision 1.1.1.1  2001/01/04 21:07:56  cvs
 *      Initial import to CVS
 *
 * Revision 1.1  2000/03/07  14:40:56  pinnacle
 * ah
 *
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 04/06/00  ah      Creation
 ***************************************************************************/

#include "VDhttp.h"

/* -----------------------------------------------
 * Main traffic director
 * For standalone program
 */
int main(int argc, char *argv[])
{
  char hostName[128];
  char getStr  [128];
  char buf    [8192];
  
  // Arg check
  if (argc != 3) {
    printf("Usage - %s host get\n",argv[0]);
    return 1;
  }
  strcpy(hostName,argv[1]);
  strcpy(getStr,  argv[2]);

  printf("---- HTTP Get Test %s %s----\n",hostName,getStr);

  //VDhttpDoGet(hostName, -1, getStr, sizeof(buf), buf);

  vdhttp$DoGet(hostName = hostName,
	       getStr   = getStr,
	       bufLen   = sizeof(buf),
	       buf      = buf);
  
  printf("### Data ###\n%s\n",buf);
  
  // Done
  return 0;
}

