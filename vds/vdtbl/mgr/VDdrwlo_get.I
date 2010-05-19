
/* $Id: VDdrwlo_get.I,v 1.1.1.1 2001/01/04 21:09:28 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:        vds/vdtbl/mgr/VDdrwlo_get.I
 *
 * Description:
 *
 * Implementation file for table manager get table/get rectangle
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDdrwlo_get.I,v $
 *      Revision 1.1.1.1  2001/01/04 21:09:28  cvs
 *      Initial import to CVS
 *
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
# Revision 1.1  1997/05/08  13:20:44  pinnacle
# New project VDS 250
#
# Revision 1.1  1996/07/19  20:33:52  pinnacle
# Create VDS 241 project
#
# Revision 1.3  1995/09/12  23:22:34  pinnacle
# Replaced: vdtbl/mgr/VDdrwlo_get.I for:  by hverstee for vds.240
#
# Revision 1.2  1995/06/19  19:31:28  pinnacle
# Replaced: vdtbl/mgr/VDdrwlo_get.I for:  by hverstee for vds.240
#
# Revision 1.1  1995/04/13  14:34:38  pinnacle
# Created: vdtbl/mgr/* by tdumbach r#
# rno
#
# Revision 1.7  1995/04/12  15:29:36  pinnacle
# Replaced: vdtbl/mgr/VDdrwlo_get.I by hverstee r#
#
# Revision 1.6  1995/03/25  15:40:04  pinnacle
# Replaced: vdtbl/mgr/VDdrwlo_get.I by hverstee r#
#
# Revision 1.5  1995/03/20  17:24:38  pinnacle
# Replaced: vdtbl/mgr/VDdrwlo_get.I by hverstee r#
#
# Revision 1.3  1995/03/10  00:29:08  pinnacle
# Replaced: vdtbl/mgr/VDdrwlo_get.I by hverstee r#
#
# Revision 1.2  1995/03/08  15:11:48  pinnacle
# Replaced: vdtbl/mgr/VDdrwlo_get.I by hverstee r#
#
# Revision 1.1  1995/03/06  16:41:00  pinnacle
# Created: vdtbl/mgr/VDdrwlo_get.I by hverstee r#
# rno
#
 *
 * History:
 *      MM/DD/YY        AUTHOR          DESCRIPTION
 *
 *      03/03/95          HV            New
 *
 * -------------------------------------------------------------------*/

class implementation VDdrwlo;

#include "OMmacros.h"
#include "OMprimitives.h"
#include "igetypedef.h"
#include "gr.h"
#include "ASmatrix.h"
#include "asdef.h"
#include "asmacros.h"
#include "asbox.h"
#include "AS_status.h"
#include "macro.h"
#include "parametric.h"
#include "msdef.h"
#include "nddef.h"
#include "acrepdef.h"

/*
#define  MY_DEBUG
*/


method   VDdrwlo_gtab   (IGRlong         *msg;
                  struct VDdrwlo_tab     *Tabrec)
{

  *msg = MSSUCC;

  if (Tabrec)
  {
    strcpy (Tabrec->Tabnam,  me->Ltbrec.Tabnam);
    strcpy (Tabrec->Tabtyp,  me->Ltbrec.Tabtyp);
    strcpy (Tabrec->Timest,  me->Ltbrec.Timest);
    strcpy (Tabrec->Userid,  me->Ltbrec.Userid);
    strcpy (Tabrec->Shdesc,  me->Ltbrec.Shdesc);
    strcpy (Tabrec->SumFil,  me->Ltbrec.SumFil);
    strcpy (Tabrec->SortFil, me->Ltbrec.SortFil);

    Tabrec->direct = me->Ltbrec.direct;
    Tabrec->Local  = me->Ltbrec.Local;
  }

  return (OM_S_SUCCESS);
}



method   VDdrwlo_grect (IGRlong         *msg;
                        IGRshort         nGrptyp;
                        IGRshort         nColno;
                        IGRchar         *pFieldid;
                        IGRshort         nExt;
                 struct VDdrwlo_extrec  *Exrec;
                        IGRdouble       *xLow;
                        IGRdouble       *yLow;
                        IGRdouble       *xHig;
                        IGRdouble       *yHig)
{
  IGRdouble    xL, xH, yL, yH;
  IGRshort     nNumcol;

  *msg    = MSSUCC;
  xL = xH = yL = yH = 0.0;

  nNumcol = om$dimension_of (varray = me->Lcolrec);
  if (nNumcol <= 0) goto wrapup;

  if (nGrptyp == VD_DRWLO_EN_DATA)
  {    /*  data column type  */
    IGRshort     i;
    IGRshort     iCol;

    iCol    = -1;

#ifdef MY_DEBUG
    printf ("rect col %d %d\n",nColno,nNumcol);
#endif

    if ((nColno > 0) && (nColno <= nNumcol))
    {   /*   single column datafield  */
      iCol = nColno - 1;

      xL = me->Lcolrec[iCol].col_x1;
      xH = me->Lcolrec[iCol].col_x2;
      yL = 0.0;
      yH = me->Lcolrec[iCol].col_db.col_hgt;

      for (i = 0; i < nExt; i++)
      {
        if (Exrec[i].excol == nColno)
        {
          yH += (Exrec[i].exlin *
                  VD_DLO_M_LCL(me->Lcolrec[iCol].col_db.col_charhgt,
                               me->Lcolrec[iCol].col_db.col_linspc));
/*
                          (me->Lcolrec[iCol].col_db.col_linspc *
                           me->Lcolrec[iCol].col_db.col_charhgt +
                           me->Lcolrec[iCol].col_db.col_charhgt));
*/
          break;
        }
      }
      goto wrapup;
    }
    else
    if (nColno < 0)
    { /*   entire row of columns    */
      IGRdouble    yHloc;
      IGRshort     iLoop;
      IGRshort     iCol;

      xL = me->Lcolrec[0].col_x1;
      xH = me->Lcolrec[nNumcol-1].col_x2;
      yL = 0.0;
      yH = me->Lcolrec[0].col_db.col_hgt;

      for (iLoop = 0; iLoop < nNumcol; iLoop++)
      {
#ifdef MY_DEBUG
        printf ("rect allcols %f %f %f\n",me->Lcolrec[iLoop].col_x1,
                                          me->Lcolrec[iLoop].col_x2,
                                          me->Lcolrec[iLoop].col_db.col_hgt);
#endif

        iCol  = me->Lcolrec[iLoop].col_db.col_seqno;
        yHloc = me->Lcolrec[iLoop].col_db.col_hgt;
        for (i = 0; i < nExt; i++)
        {
          if (Exrec[i].excol == iCol)
          {
            yHloc += (Exrec[i].exlin *
                  VD_DLO_M_LCL(me->Lcolrec[iLoop].col_db.col_charhgt,
                               me->Lcolrec[iLoop].col_db.col_linspc));
/*
                          (me->Lcolrec[iLoop].col_db.col_linspc *
                           me->Lcolrec[iLoop].col_db.col_charhgt +
                           me->Lcolrec[iLoop].col_db.col_charhgt));
*/
            break;
          }
        }

        if (yHloc > yH)     yH = yHloc;
      }
      goto wrapup;
    }
  }
  else
  {    /*    header/trailer datafield   */
    IGRshort     nNumhtf;
    IGRshort     iLoop;

    nNumhtf = om$dimension_of (varray = me->Lhtfrec);

    if (pFieldid == NULL)
    {   /*   encompassing rectangle for entire header/trailer    */

      IGRboolean      bSet;

      bSet = FALSE;

      for (iLoop = 0; iLoop < nNumhtf; iLoop++)
      {
        if (me->Lhtfrec[iLoop].htf_db.hdtr_type != nGrptyp)           continue;

        if (bSet)
        {
          if (me->Lhtfrec[iLoop].htf_x1 < xL) xL = me->Lhtfrec[iLoop].htf_x1;
          if (me->Lhtfrec[iLoop].htf_x2 > xH) xH = me->Lhtfrec[iLoop].htf_x2;
          if (me->Lhtfrec[iLoop].htf_y1 < yL) yL = me->Lhtfrec[iLoop].htf_y1;
          if (me->Lhtfrec[iLoop].htf_y2 > yH) yH = me->Lhtfrec[iLoop].htf_y2;
        }
        else
        {
          bSet = TRUE;
          xL = me->Lhtfrec[iLoop].htf_x1;
          xH = me->Lhtfrec[iLoop].htf_x2;
          yL = me->Lhtfrec[iLoop].htf_y1;
          yH = me->Lhtfrec[iLoop].htf_y2;
        }
      }
      goto wrapup;
    }
    else
    {   /* rectangle for specific header/trailer field   */
      for (iLoop = 0; iLoop < nNumhtf; iLoop++)
      {
        if (me->Lhtfrec[iLoop].htf_db.hdtr_type != nGrptyp)           continue;
        if (strcmp (pFieldid,me->Lhtfrec[iLoop].htf_db.fieldid) != 0) continue;

        xL = me->Lhtfrec[iLoop].htf_x1;
        xH = me->Lhtfrec[iLoop].htf_x2;
        yL = me->Lhtfrec[iLoop].htf_y1;
        yH = me->Lhtfrec[iLoop].htf_y2;
        goto wrapup;
      }
    }
  }

  /*   fall through, non existing column or headerfield    */

  *msg = MSFAIL;

  wrapup:
  *xLow = xL;
  *yLow = yL;
  *xHig = xH;
  *yHig = yH;

  return (OM_S_SUCCESS);
}

end implementation VDdrwlo;

