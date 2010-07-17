
/* $Id: VCCmdAnXQ.I,v 1.1.1.1 2001/01/04 21:12:30 cvs Exp $  */

/*************************************************************************
 * I/CABLE
 *
 * File:        vccmdutil/VCCmdAnXQ.I
 *
 * Description:
 *      Command implementation of analysis
 *
 *
 * Dependencies:
 *
 * Revision History:
 *        $Log: VCCmdAnXQ.I,v $
 *        Revision 1.1.1.1  2001/01/04 21:12:30  cvs
 *        Initial import to CVS
 *
# Revision 1.1  1998/04/30  10:52:34  pinnacle
# ROUTE 2.5.1
#
# Revision 1.1  1997/10/30  04:17:36  pinnacle
# Integration of Cable into 02.04.03.04
#
# Revision 1.2  1997/03/12  22:26:20  pinnacle
# Replaced: vccmdutil/VCCmdAnXQ.I for:  by hverstee for cabling
#
# Revision 1.1  1996/08/28  22:01:24  pinnacle
# Created: vccmdutil/VCCmdAnXQ.I by hverstee for cabling
#
 *
 * History:
 *        07/10/96        hv        Initial
 *
 *************************************************************************/

class implementation VCCmdAnal;

#include "VCproto.h"

/*
#define MY_DEBUG
*/



/*=======================================================================*/


method VCAnalyze ( long * sts )
{

  IGRint          i;
  IGRlong         retmsg;
  IGRchar         szDate[80];
  FILE           *ftosend;

#ifdef MY_DEBUG
  printf   (" Signal    %s\n",me->szSigId);
  for (i=0; i<me->nTrac; i++)
    printf (" Trace tab %s %d  <%d %d>\n",me->TracTab[i].szOutId,
                                          me->TracTab[i].ClassId,
                                          me->TracTab[i].OutGRid.objid,
                                          me->TracTab[i].OutGRid.osnum);
#endif

  VD_DLO_SetIndx (NULL, szDate, NULL, NULL);

  if (me->bToFile)
  {
    me->pFile = (FILE *) fopen (me->szFilNam, "a");
    if (me->pFile == NULL)
    {
      printf (" FILE CANNOT BE OPENED, revert to display\n");
    }
  }

  if (me->pFile)
  {
    fprintf (me->pFile,
     "=================================================================\n");
    if (me->MyType == 0)
      fprintf (me->pFile,
     "                 FIBEROPTIC Analysis/Report   %s\n",szDate);
    else
      fprintf (me->pFile,
     "                 ELECTRICAL Analysis/Report   %s\n",szDate);
    fprintf (me->pFile,
     "=================================================================\n");

    ftosend = me->pFile;
  }
  else
    ftosend = stdout;

  for (i=0; i< NO_CHECKLIST; i++)
  {
   if (me->bSetCheck[i])
   {
    if (me->MyType == 0)
    {
#ifdef MY_DEBUG
      printf ("Execute Fiberoptic analysis %d\n", i);
#endif
      VC_FoAnalyze (&retmsg, me->nTrac, me->TracTab, ftosend, i,
                    &me->RefId, &me->ModuleInfo);
    }
    else
    {
#ifdef MY_DEBUG
      printf ("Execute Electrical analysis %d\n", i);
#endif
       VC_ElAnalyze (&retmsg, me->nTrac, me->TracTab, ftosend, i,
                     &me->RefId, &me->ModuleInfo);
    }
   }
  }

  if (me->pFile) fclose (me->pFile);
  me->pFile = NULL;

  return OM_S_SUCCESS;
}

end implementation VCCmdAnal;
