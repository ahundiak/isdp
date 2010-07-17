/* $Id: aimsir.cmd,v 1.6 2002/05/29 21:04:26 ylong Exp $ */

/*************************************************************************
 * I/AIM
 *
 * File:        aim/config/aimsir.cmd
 *
 * Description:
 *		Command Table list entries
 *
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: aimsir.cmd,v $
 *      Revision 1.6  2002/05/29 21:04:26  ylong
 *      *** empty log message ***
 *
 *      Revision 1.5  2002/05/29 16:06:38  ylong
 *      *** empty log message ***
 *
 *      Revision 1.4  2002/05/29 16:04:04  ylong
 *      *** empty log message ***
 *
 *      Revision 1.3  2002/05/29 13:52:30  ylong
 *      *** empty log message ***
 *
 *      Revision 1.2  2002/05/28 19:13:03  ylong
 *      Make AimSir being loaded per file session.
 *
 *      Revision 1.1  2002/05/02 18:15:59  ahundiak
 *      *** empty log message ***
 *
 *
 * History
 *      MM/DD/YY        AUTHOR          DESCRIPTION
 *
 */

"AimSir Session Startup",AIMstartup0,AIMCmdStrt,0,256,,,AIMSIR.o
"AIM File Startup",AIMstartup1,AIMCmdStrt,1,512,,,AIMSIR.o
^"Aimsir",IMTkAim,COci,0,0,,"Aimsir"
