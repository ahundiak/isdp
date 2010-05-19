
/* $Id: VDdrwlo_gdat.I,v 1.1.1.1 2001/01/04 21:09:28 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:        vds/vdtbl/mgr/VDdrwlo_gdat.I
 *
 * Description:
 *
 * Implementation file for table manager getdata method
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDdrwlo_gdat.I,v $
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
# Revision 1.5  1995/09/25  23:44:24  pinnacle
# Replaced: vdtbl/mgr/VDdrwlo_gdat.I for:  by sundar for vds.240
#
# Revision 1.4  1995/08/25  15:17:58  pinnacle
# Replaced: vdtbl/mgr/VDdrwlo_gdat.I for:  by hverstee for vds.240
#
# Revision 1.3  1995/07/06  14:40:06  pinnacle
# Replaced: vdtbl/mgr/VDdrwlo_gdat.I for:  by hverstee for vds.240
#
# Revision 1.2  1995/06/19  19:29:40  pinnacle
# Replaced: vdtbl/mgr/VDdrwlo_gdat.I for:  by hverstee for vds.240
#
# Revision 1.6  1995/05/15  13:29:22  pinnacle
# Replaced: vdtbl/mgr/VDdrwlo_gdat.I by hverstee r#
#
# Revision 1.4  1995/05/10  22:08:26  pinnacle
# Replaced: vdtbl/mgr/VDdrwlo_gdat.I by hverstee r#
#
# Revision 1.3  1995/04/28  03:45:12  pinnacle
# Replaced: vdtbl/mgr/VDdrwlo_gdat.I by hverstee r#
#
# Revision 1.2  1995/04/25  22:30:46  pinnacle
# Replaced: vdtbl/mgr/VDdrwlo_gdat.I by hverstee r#
#
# Revision 1.1  1995/04/13  14:34:38  pinnacle
# Created: vdtbl/mgr/* by tdumbach r#
# rno
#
# Revision 1.4  1995/04/12  15:28:24  pinnacle
# Replaced: vdtbl/mgr/VDdrwlo_gdat.I by hverstee r#
#
# Revision 1.3  1995/03/25  15:39:28  pinnacle
# Replaced: vdtbl/mgr/VDdrwlo_gdat.I by hverstee r#
#
# Revision 1.2  1995/03/20  17:23:58  pinnacle
# Replaced: vdtbl/mgr/VDdrwlo_gdat.I by hverstee r#
#
# Revision 1.1  1995/03/06  16:40:20  pinnacle
# Created: vdtbl/mgr/VDdrwlo_gdat.I by hverstee r#
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
#include "griodef.h"
#include "gotextdef.h"
#include "VDmem.h"

/*
#define MY_DEBUG
*/


method   VDdrwlo_gdata (IGRlong         *msg;
                        IGRshort         nGrptyp;
                        IGRdouble        xLode;
                        IGRdouble        yLode;
                        IGRshort         nExt;
                 struct VDdrwlo_extrec  *Exrec;
                        IGRdouble       *dHgt;
                        IGRshort        *nCount;
                 struct VDdrwlo_data    *Fldrec)
{
  IGRlong         status;
  IGRlong         retmsg;
  IGRshort        iLoop;
  IGRshort        jLoop;
  IGRshort        jCnt, jfld;
  IGRshort        jExt, jTot;
  IGRshort        jLocalj;
  IGRshort        nNumcol;
  IGRshort        nNumhtf;
  IGRshort        nNumfld;
  IGRshort        nMAXfld;
  IGRshort        nMAXinc;

  IGRdouble      *yValues;
  IGRdouble       xValues[3];

  IGRshort        nLcolor, nLlevel;

  struct  VDdrwlo_db_fld   *fBuff;

  *msg    = MSFAIL;
  *nCount = 0;
  nMAXfld = 0;
  nMAXinc = 0;
  *dHgt   = 0.0;
  status  = OM_S_SUCCESS;

  nLcolor = nLlevel = 0; /*  initialize color & level, to be adjusted later */

  nNumcol = om$dimension_of (varray = me->Lcolrec);
  nNumhtf = om$dimension_of (varray = me->Lhtfrec);
  nNumfld = om$dimension_of (varray = me->Lfldrec);

#ifdef MY_DEBUG
  printf (" gdata enter\n");
#endif

  for (iLoop=0; iLoop<nNumfld; iLoop++)
  {
    if (me->Lfldrec[iLoop].lin_seqno > nMAXfld) 
      nMAXfld = me->Lfldrec[iLoop].lin_seqno;
  }

  for (iLoop=0; iLoop<nExt; iLoop++)
  {
    if (Exrec[iLoop].exlin > nMAXinc)
      nMAXinc = Exrec[iLoop].exlin;
  }

  nMAXfld += nMAXinc;

  yValues = _MALLOC (nMAXfld ,IGRdouble);
  fBuff   = _MALLOC (nMAXfld ,struct VDdrwlo_db_fld);

  /*    _Checkmem ???   */
  if ((yValues == NULL) || (fBuff == NULL)) return (OM_E_NODYNMEM);

  *msg    = MSSUCC;

  if (nGrptyp == VD_DRWLO_EN_DATA)
  { /*  collect replaceable data for column/row part    */
    IGRdouble       xltot, yltot, xhtot, yhtot;
    IGRdouble       x1, y1, x2, y2;

    status =
    om$send (msg = message VDdrwlo.VDdrwlo_grect
                            (&retmsg, nGrptyp, VD_DRWLO_EN_ALL, NULL,
                              nExt, Exrec, &xltot, &yltot, &xhtot, &yhtot),
        targetid = my_id);

    *dHgt = yhtot;

    for (iLoop = 0; iLoop < nNumcol; iLoop++)
    { /*   for every column   */
      IGRshort      nLseq, nLjust;
      IGRshort      iColseq;
      IGRdouble     dYalign;
      IGRdouble     dYhight;

      iColseq = me->Lcolrec[iLoop].col_db.col_seqno;

      status =
      om$send (msg = message VDdrwlo.VDdrwlo_grect
                              (&retmsg, nGrptyp, iColseq, NULL,
                                nExt, Exrec, &x1, &y1, &x2, &y2),
          targetid = my_id);

      dYhight = y2 - y1;
      dYalign = *dHgt - dYhight;

      /*   find defined datalines   */

      status =
      om$send (msg = message VDdrwlo.VDdrwlo_gfld
                                (&retmsg, nGrptyp, iColseq, NULL,
                                  VD_DRWLO_EN_ALL, &jCnt, fBuff),
          targetid = my_id);

      /*   find number of extensions    */

      jExt = 0;
      for (jLoop = 0; jLoop < nExt; jLoop++)
      {
        if (Exrec[jLoop].excol == me->Lcolrec[iLoop].col_db.col_seqno)
        {
          jExt = Exrec[jLoop].exlin;
          break;
        }
      }

      jTot  = jCnt + jExt;
      nLseq = 0;

      /*   now calculate the text displacements     */

      status = VD_drwlo_getx (nGrptyp,&me->Lcolrec[iLoop],NULL, xValues);

      status = VD_drwlo_gtty (me->Lcolrec[iLoop].col_db.col_charhgt,
                              me->Lcolrec[iLoop].col_db.col_linspc,
                              jTot, dYhight, yValues);

      for (jfld = 0; jfld < jTot; jfld++)
      {
        if (jfld >= jCnt)
        {
          jLocalj = jCnt - 1;
          nLseq++;
        }
        else
        {
          jLocalj = jfld;
          nLseq = fBuff[jfld].lin_seqno;
        }

        if (fBuff[jLocalj].fieldtype == VD_DRWLO_EN_TEXT) continue;

        /*     position datafield .....  */

        if (Fldrec)
        {
          IGRdouble     xtext, ytext;

          nLjust = fBuff[jLocalj].justification;

          switch (nLjust)
          {
            case GRIO_LEFT_JUSTIFY:
            default:
              xtext = xValues[0];
	      Fldrec[*nCount].justif  = LEFT_BASE;
              break;
            case GRIO_CENTER_JUSTIFY:
              xtext = xValues[1];
	      Fldrec[*nCount].justif  = CENTER_BASE;
              break;
            case GRIO_RIGHT_JUSTIFY:
              xtext = xValues[2];
	      Fldrec[*nCount].justif  = RIGHT_BASE;
              break;
          }

          ytext = yValues[jfld] + dYalign;

	  Fldrec[*nCount].grptyp  = nGrptyp;
	  Fldrec[*nCount].datatyp = me->Lfldrec[jLocalj].datatype;
	  Fldrec[*nCount].xcor    = xtext + xLode;
	  Fldrec[*nCount].ycor    = ytext + yLode;
	  Fldrec[*nCount].colno   = me->Lcolrec[iLoop].col_db.col_seqno;
	  Fldrec[*nCount].lineno  = nLseq;
	  Fldrec[*nCount].ch_wdt  = me->Lcolrec[iLoop].col_db.col_charwdt;
	  Fldrec[*nCount].ch_hgt  = me->Lcolrec[iLoop].col_db.col_charhgt;
	  Fldrec[*nCount].ch_spc  = me->Lcolrec[iLoop].col_db.col_charspc;
	  Fldrec[*nCount].numchr  = me->Lcolrec[iLoop].col_db.col_chars;
	  Fldrec[*nCount].decplace= fBuff[jLocalj].f_decimal;
	  Fldrec[*nCount].weight  = fBuff[jLocalj].id_weight;

	  strcpy (Fldrec[*nCount].font, fBuff[jLocalj].id_Font);

          if (jfld >= jCnt)
          {
	    Fldrec[*nCount].rectyp = VD_DRWLO_EN_AUTOWRAP;
          }
          else
          {
            Fldrec[*nCount].rectyp  = fBuff[jLocalj].fieldtype;

	    strcpy (Fldrec[*nCount].Text,  fBuff[jLocalj].Ftext);
	    strcpy (Fldrec[*nCount].ExAtt, fBuff[jLocalj].id_name);
          }
	}

        (*nCount)++;
      }
    }
  }
  else
  { /*  collect fixed data for header/trailer field part    */
    IGRdouble       xltot, yltot, xhtot, yhtot;
    IGRdouble       x1, y1, x2, y2;
    IGRchar         szLocfld[VD_DRWLO_CHR_IDFLD];

    status =
    om$send (msg = message VDdrwlo.VDdrwlo_grect
                            (&retmsg, nGrptyp, VD_DRWLO_EN_ALL, NULL,
                              nExt, Exrec, &xltot, &yltot, &xhtot, &yhtot),
        targetid = my_id);

    *dHgt = yhtot;

    for (iLoop = 0; iLoop < nNumhtf; iLoop++)
    { /*   for every headerfield  */
      IGRdouble     dYhight;

      if (me->Lhtfrec[iLoop].htf_db.hdtr_type != nGrptyp) continue;

      strcpy (szLocfld, me->Lhtfrec[iLoop].htf_db.fieldid);

      status =
      om$send (msg = message VDdrwlo.VDdrwlo_grect
                              (&retmsg, nGrptyp, iLoop, szLocfld,
                                nExt, Exrec, &x1, &y1, &x2, &y2),
          targetid = my_id);

      dYhight = y2 - y1;

      /*   find datalines   */

      status =
      om$send (msg = message VDdrwlo.VDdrwlo_gfld
                                (&retmsg, nGrptyp, VD_DRWLO_EN_ALL, szLocfld,
                                  VD_DRWLO_EN_ALL, &jCnt, fBuff),
          targetid = my_id);

      /*   now calculate the text displacements     */

      status = VD_drwlo_getx (nGrptyp,NULL, &me->Lhtfrec[iLoop], xValues);

      status = VD_drwlo_gtty (me->Lhtfrec[iLoop].htf_db.fld_charhgt,
                              me->Lhtfrec[iLoop].htf_db.fld_linspc,
                              jCnt, dYhight, yValues);

      for (jfld = 0; jfld < jCnt; jfld++)
      {
        if (fBuff[jfld].fieldtype == VD_DRWLO_EN_TEXT) continue;

        /*     position text .....  */

        if (Fldrec)
        {
          IGRdouble     xtext, ytext;

          switch (fBuff[jfld].justification)
          {
            case GRIO_LEFT_JUSTIFY:
            default:
              xtext = xValues[0];
              Fldrec[*nCount].justif  = LEFT_BASE;
              break;
            case GRIO_CENTER_JUSTIFY:
              xtext = xValues[1];
              Fldrec[*nCount].justif  = CENTER_BASE;
              break;
            case GRIO_RIGHT_JUSTIFY:
              xtext = xValues[2];
              Fldrec[*nCount].justif  = RIGHT_BASE;
              break;
          }

          ytext = yValues[jfld] + y1;

          Fldrec[*nCount].grptyp   = nGrptyp;
          Fldrec[*nCount].xcor     = xtext + xLode;
          Fldrec[*nCount].ycor     = ytext + yLode;
          Fldrec[*nCount].colno    = VD_DRWLO_EN_ALL;
          Fldrec[*nCount].ch_wdt   = me->Lhtfrec[iLoop].htf_db.fld_charwdt;
          Fldrec[*nCount].ch_hgt   = me->Lhtfrec[iLoop].htf_db.fld_charhgt;
          Fldrec[*nCount].ch_spc   = me->Lhtfrec[iLoop].htf_db.fld_charspc;
          Fldrec[*nCount].numchr   = me->Lhtfrec[iLoop].htf_db.fld_chars;

          Fldrec[*nCount].datatyp  = fBuff[jfld].datatype;
          Fldrec[*nCount].lineno   = fBuff[jfld].lin_seqno;
          Fldrec[*nCount].decplace = fBuff[jfld].f_decimal;
	  Fldrec[*nCount].weight   = fBuff[jfld].id_weight;
          Fldrec[*nCount].rectyp   = fBuff[jfld].fieldtype;

	  strcpy (Fldrec[*nCount].font, fBuff[jfld].id_Font);
          strcpy (Fldrec[*nCount].fldid, szLocfld);

          strcpy (Fldrec[*nCount].Text,  fBuff[jfld].Ftext);
          strcpy (Fldrec[*nCount].ExAtt, fBuff[jfld].id_name);
        }

        (*nCount)++;
      }
    }
  }

  _FREE (yValues);
  _FREE (fBuff);

  return (status);
}

end implementation VDdrwlo;

