
/* $Id: VCAN_xq.I,v 1.1.1.1 2001/01/04 21:12:30 cvs Exp $  */

/*************************************************************************
 * I/CABLE
 *
 * File:        vccmdutil/VCAN_xq.I
 *
 * Description:
 *      Calculation/report interface for cabling analysis
 *
 *
 * Dependencies:
 *
 * Revision History:
 *        $Log: VCAN_xq.I,v $
 *        Revision 1.1.1.1  2001/01/04 21:12:30  cvs
 *        Initial import to CVS
 *
# Revision 1.1  1998/04/30  10:52:34  pinnacle
# ROUTE 2.5.1
#
# Revision 1.1  1997/10/30  04:17:36  pinnacle
# Integration of Cable into 02.04.03.04
#
# Revision 1.8  1997/03/28  21:20:44  pinnacle
# Replaced: vccmdutil/VCAN_xq.I for:  by hverstee for cabling
#
# Revision 1.7  1997/03/20  21:16:12  pinnacle
# Replaced: vccmdutil/VCAN_xq.I for:  by hverstee for cabling
#
# Revision 1.6  1997/03/14  18:25:06  pinnacle
# Replaced: vccmdutil/VCAN_xq.I for:  by hverstee for cabling
#
# Revision 1.5  1997/03/12  22:25:18  pinnacle
# Replaced: vccmdutil/VCAN_xq.I for:  by hverstee for cabling
#
# Revision 1.4  1997/01/31  23:45:34  pinnacle
# Replaced: vccmdutil/VCAN_xq.I for:  by hverstee for cabling
#
# Revision 1.3  1996/12/16  17:39:56  pinnacle
# Replaced: vccmdutil/VCAN_xq.I for:  by hverstee for cabling
#
# Revision 1.2  1996/10/29  22:26:14  pinnacle
# Replaced: vccmdutil/VCAN_xq.I for:  by hverstee for cabling
#
# Revision 1.1  1996/10/25  19:14:16  pinnacle
# Created: vccmdutil/VCAN_xq.I by hverstee for cabling
#
 *
 * History:
 *        07/10/96        hv        Initial
 *
 *************************************************************************/

class implementation VCRoot;

#include "VCproto.h"

/*     placeholder for real dynamic IF coming from api and loaded
       separately at startup    */

/*
#define  MY_DEBUG
*/

/**************************************************************************/
/**************************************************************************/
/*   declare here all analysis/reports functions available   */

extern int  VC_AN_execute();

/**************************************************************************/
/**************************************************************************/


/*=======================================================================*/

int VC_AN_getfunc (int          select,
                   int         *num,
            struct VC_anproc   *table)

{
  int    ii;
  int    ct;

  struct VC_anproc  Processes[] = {

/**************************************************************************/
/*           insert specification of available functions                  */
/**************************************************************************/
/**************************************************************************/
/* select code   - Description                        - function name     */
/*               -                                    -                   */

  VC_DEFAN_ALL   , "Template cabling analysis function", VC_AN_execute,

/**************************************************************************/
/**************************************************************************/

  VC_DEFAN_NONE, "-------  END MARKER -----------",   NULL   };

  ii = ct = 0;
  
  /*   fill table and set *num according to the select number   */

  while ((Processes[ii].Type != VC_DEFAN_NONE) &&
         (Processes[ii].fcn  != NULL))
  {
    if ((Processes[ii].Type == select) ||
        (Processes[ii].Type == VC_DEFAN_ALL))
    {
      if (table != NULL)
        table[ct] = Processes[ii];

      ct++;
    }

    ii++;
  }

  *num = ct;

  return (OM_S_SUCCESS);
}


/**************************************************************************/
/**************************************************************************/
/*                  Insert custom functions here                          */
/*                             NOTE                                       */
/*                   retain calling sequence!!!!                          */
/**************************************************************************/
/**************************************************************************/

extern
int  VC_AN_execute    (int          *msg)
{
  IGRint          iindex;

  *msg = MSSUCC;

  /*   dummy function for base state implementation, print the buffers  */

  /*    place notice in result field for form display     */

  strcpy (VCANGLB_result, "Base implementation -- print");

  printf (" File Name   %s\n",VCANGLB_filenam);
  printf (" Signal Name %s\n",VCANGLB_signam);
  printf (" selectstate %d\n",VCANGLB_select);
  printf (" recordnum   %d\n",VCANGLB_ntrace);

  iindex = 0;

  while (iindex < VCANGLB_ntrace)
  {
     /*    print trace as an example       */
     printf ("REC %d, trans,index, GRid %d %d %d %d",
             iindex, VCANGLB_trac[iindex].nTrans, VCANGLB_trac[iindex].nIndex,
             VCANGLB_trac[iindex].GRid.objid, VCANGLB_trac[iindex].GRid.osnum);

     if (VCANGLB_trac[iindex].OutId.nType == VC_TERM_TYPE)
       printf (" --TERM         %s - %s\n",
                         VCANGLB_trac[iindex].OutId.Conn.Term.szModId,
                         VCANGLB_trac[iindex].OutId.Conn.Term.szPosId);
     else
     if (VCANGLB_trac[iindex].OutId.nType == VC_CABLE_TYPE)
       printf (" --CABLE end %d lead %s\n",
                         VCANGLB_trac[iindex].OutId.Conn.Cable.nCpt,
                         VCANGLB_trac[iindex].OutId.Conn.Cable.szLeadId);
     else
       printf (" --TYPE %d\n",VCANGLB_trac[iindex].OutId.nType);

     iindex = iindex + 1;
  }

  return (OM_S_SUCCESS);
}

end implementation VCRoot;

