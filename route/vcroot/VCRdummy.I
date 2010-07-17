
/* $Id: VCRdummy.I,v 1.1.1.1 2001/01/04 21:12:37 cvs Exp $  */

/*************************************************************************
 * I/CABLE
 *
 * File:        vcroot / VCRdummy.I
 *
 * Description:
 *   This file contains the dummy methods to be overridden 
 *
 * Dependencies:
 *
 * Revision History:
 *        $Log: VCRdummy.I,v $
 *        Revision 1.1.1.1  2001/01/04 21:12:37  cvs
 *        Initial import to CVS
 *
# Revision 1.1  1998/04/30  10:52:34  pinnacle
# ROUTE 2.5.1
#
# Revision 1.1  1997/10/30  05:23:10  pinnacle
# Integ into Route 02040304
#
# Revision 1.4  1997/03/19  15:52:38  pinnacle
# Replaced: vcroot/VCRdummy.I for:  by hverstee for cabling
#
# Revision 1.3  1996/10/25  13:48:18  pinnacle
# Replaced: vcroot/VCRdummy.I for:  by hverstee for cabling
#
# Revision 1.2  1996/10/16  20:37:32  pinnacle
# Replaced: vcroot/VCRdummy.I for:  by hverstee for cabling
#
# Revision 1.1  1996/08/28  21:12:06  pinnacle
# Created: vcroot/VCRdummy.I by hverstee for cabling
#
 *
 * History:
 *        05/29/96        hv         Initial
 *
 *************************************************************************/

class implementation VCRoot;

/*    must be overridden to return connectpoints    */

method  VCGetCpts   (IGRlong    *msg;
              struct GRid       *RefId;
                     IGRshort   *nRefCp;
                     IGRshort   *nMyCp;
                     IGRshort   *nPass)
{
  *msg = MSFAIL;

  *nRefCp = -1;
  *nMyCp  = -1;
  *nPass  =  0;

  return (OM_S_SUCCESS);
}

method  VCGetTopology (IGRlong   *msg;
                       IGRshort   nCpt;    /*I  my CPT or ALL              */
                       IGRshort  *nConn;   /*O  number output              */
                struct GRid      *ConId;   /*O  list of GRids              */
                       IGRshort  *nConCp;  /*O  list of cpts on GRids      */
                       IGRshort  *nMyCp;   /*O  list of cpts on me         */
                       IGRshort  *nPass)   /*O  list of passthru counters  */

{
  *msg = MSFAIL;

  *nConn = 0;
  
  return (OM_S_SUCCESS);
}

method  VCGetSupports (IGRlong   *msg;
                       IGRshort  *nNbSupps;
                struct GRid      *SuppIds)

{
  *msg = MSFAIL;

  *nNbSupps = 0;

  return (OM_S_SUCCESS);
}

method  VCGetCompart (IGRlong    *msg;
                      IGRshort   *nNum;
               struct GRid       *Compart;
               struct GRmd_env   *md_env)
{
  *msg = MSFAIL;

  *nNum = 0;

  return (OM_S_SUCCESS);
}

end implementation VCRoot;

