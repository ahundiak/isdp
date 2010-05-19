
/* $Id: VDdrwlo_gfix.I,v 1.1.1.1 2001/01/04 21:09:28 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:        vds/vdtbl/mgr/VDdrwlo_gfix.I
 *
 * Description:
 *
 * Implementation file for table manager get fix method
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDdrwlo_gfix.I,v $
 *      Revision 1.1.1.1  2001/01/04 21:09:28  cvs
 *      Initial import to CVS
 *
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
# Revision 1.3  1998/04/02  02:54:52  pinnacle
# Replaced: vdtbl/mgr/VDdrwlo_gfix.I for:  by mdong for vds
#
# Revision 1.2  1998/01/07  11:38:54  pinnacle
# Replaced: vdtbl/mgr/VDdrwlo_gfix.I for:  by vgnair for vds
#
# Revision 1.1  1997/05/08  13:20:44  pinnacle
# New project VDS 250
#
# Revision 1.1  1996/07/19  20:33:52  pinnacle
# Create VDS 241 project
#
# Revision 1.6  1995/09/25  23:44:38  pinnacle
# Replaced: vdtbl/mgr/VDdrwlo_gfix.I for:  by sundar for vds.240
#
# Revision 1.5  1995/09/13  16:05:20  pinnacle
# Replaced: vdtbl/mgr/VDdrwlo_gfix.I for:  by hverstee for vds.240
#
# Revision 1.4  1995/08/25  15:17:36  pinnacle
# Replaced: vdtbl/mgr/VDdrwlo_gfix.I for:  by hverstee for vds.240
#
# Revision 1.3  1995/07/06  14:40:36  pinnacle
# Replaced: vdtbl/mgr/VDdrwlo_gfix.I for:  by hverstee for vds.240
#
# Revision 1.2  1995/06/19  19:29:12  pinnacle
# Replaced: vdtbl/mgr/VDdrwlo_gfix.I for:  by hverstee for vds.240
#
# Revision 1.6  1995/05/15  13:28:46  pinnacle
# Replaced: vdtbl/mgr/VDdrwlo_gfix.I by hverstee r#
#
# Revision 1.4  1995/05/10  22:08:56  pinnacle
# Replaced: vdtbl/mgr/VDdrwlo_gfix.I by hverstee r#
#
# Revision 1.3  1995/04/28  03:46:10  pinnacle
# Replaced: vdtbl/mgr/VDdrwlo_gfix.I by hverstee r#
#
# Revision 1.2  1995/04/25  22:31:32  pinnacle
# Replaced: vdtbl/mgr/VDdrwlo_gfix.I by hverstee r#
#
# Revision 1.1  1995/04/13  14:34:38  pinnacle
# Created: vdtbl/mgr/* by tdumbach r#
# rno
#
# Revision 1.5  1995/04/12  15:29:02  pinnacle
# Replaced: vdtbl/mgr/VDdrwlo_gfix.I by hverstee r#
#
# Revision 1.4  1995/03/25  15:40:48  pinnacle
# Replaced: vdtbl/mgr/VDdrwlo_gfix.I by hverstee r#
#
# Revision 1.3  1995/03/20  17:25:20  pinnacle
# Replaced: vdtbl/mgr/VDdrwlo_gfix.I by hverstee r#
#
# Revision 1.1  1995/03/06  16:41:44  pinnacle
# Created: vdtbl/mgr/VDdrwlo_gfix.I by hverstee r#
# rno
#
 *
 * History:
 *      MM/DD/YY        AUTHOR          DESCRIPTION
 *
 *      03/03/95          HV            New
 *      04/01/98          Ming          TR179800877
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
#define  MY_DEBUG
*/


method   VDdrwlo_gfix  (IGRlong         *msg;
                        IGRshort         nGrptyp;
                        IGRdouble        xLode;
                        IGRdouble        yLode;
                        IGRshort         nExt;
                 struct VDdrwlo_extrec  *Exrec;
                        IGRdouble       *dHgt;
                        IGRshort        *nCount;
                 struct VDdrwlo_apifix  *Fldrec)
{
  IGRlong         status;
  IGRlong         retmsg;
  IGRshort        iLoop;
  IGRshort        jLoop;
  IGRshort        jCnt, jfld;
  IGRshort        jTot, jExt;
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
  if (nMAXfld == 0) nMAXfld = 5;

  yValues = _MALLOC (nMAXfld ,IGRdouble);
  fBuff   = _MALLOC (nMAXfld ,struct VDdrwlo_db_fld);

  /*    _Checkmem ???   */
  if ((yValues == NULL) || (fBuff == NULL)) return (OM_E_NODYNMEM);

  if (nGrptyp == VD_DRWLO_EN_DATA)
  { /*  collect fixed data for column/row part    */
    IGRdouble       xltot, yltot, xhtot, yhtot;
    IGRdouble       x1, y1, x2, y2;

    *msg    = MSSUCC;

    status =
    om$send (msg = message VDdrwlo.VDdrwlo_grect
                            (&retmsg, nGrptyp, VD_DRWLO_EN_ALL, NULL,
                              nExt, Exrec, &xltot, &yltot, &xhtot, &yhtot),
        targetid = my_id);

    *dHgt = yhtot;
#ifdef MY_DEBUG
    printf (" column height set %f\n",*dHgt);
#endif

    for (iLoop = 0; iLoop < nNumcol; iLoop++)
    { /*   for every column   */
      IGRshort     iColseq;
      IGRdouble    dYalign;
      IGRdouble    dYhight;

      iColseq = me->Lcolrec[iLoop].col_db.col_seqno;

      status =
      om$send (msg = message VDdrwlo.VDdrwlo_grect
                              (&retmsg, nGrptyp, iColseq, NULL,
                                nExt, Exrec, &x1, &y1, &x2, &y2),
          targetid = my_id);

      dYhight = y2 - y1;
      dYalign = *dHgt - dYhight;

      /* safeguard against null lines  */

      if (x1 == x2) x2 += 0.001;
      if (y1 == y2) y2 += 0.001;

      /*  output border and crossing lines    */
      if (me->Lcolrec[iLoop].col_db.ltop_style >= 0)
      { /*  top border */
        if (Fldrec)
        {
          if (x1 == x2) x2 += 0.001;
          Fldrec[*nCount].rectyp = VD_DRWLO_EN_LINE;
          Fldrec[*nCount].VD.ln.x1 = x1 + xLode;
          Fldrec[*nCount].VD.ln.x2 = x2 + xLode;
          Fldrec[*nCount].VD.ln.y1 =
          Fldrec[*nCount].VD.ln.y2 = yhtot + yLode;
          Fldrec[*nCount].symb.level               = nLlevel;
          Fldrec[*nCount].symb.display_attr.color  = nLcolor;
          Fldrec[*nCount].symb.display_attr.style  =
                              me->Lcolrec[iLoop].col_db.ltop_style;
          Fldrec[*nCount].symb.display_attr.weight =
                              me->Lcolrec[iLoop].col_db.ltop_wgt;
#ifdef MY_DEBUG
          printf ("tlin %f %f to %f %f\n",
                                 Fldrec[*nCount].VD.ln.x1,
                                 Fldrec[*nCount].VD.ln.y1,
                                 Fldrec[*nCount].VD.ln.x2,
                                 Fldrec[*nCount].VD.ln.y2);
#endif
        }
        (*nCount)++;
      }

      if (me->Lcolrec[iLoop].col_db.lbot_style >= 0)
      { /*  bottom border  */
        if (Fldrec)
        {
          Fldrec[*nCount].rectyp = VD_DRWLO_EN_LINE;
          Fldrec[*nCount].VD.ln.x1 = x1 + xLode;
          Fldrec[*nCount].VD.ln.x2 = x2 + xLode;
          Fldrec[*nCount].VD.ln.y1 =
          Fldrec[*nCount].VD.ln.y2 = y1 + yLode;
          Fldrec[*nCount].symb.level               = nLlevel;
          Fldrec[*nCount].symb.display_attr.color  = nLcolor;
          Fldrec[*nCount].symb.display_attr.style  =
                              me->Lcolrec[iLoop].col_db.lbot_style;
          Fldrec[*nCount].symb.display_attr.weight =
                              me->Lcolrec[iLoop].col_db.lbot_wgt;
#ifdef MY_DEBUG
          printf ("blin %f %f to %f %f\n",
                                 Fldrec[*nCount].VD.ln.x1,
                                 Fldrec[*nCount].VD.ln.y1,
                                 Fldrec[*nCount].VD.ln.x2,
                                 Fldrec[*nCount].VD.ln.y2);
#endif
        }
        (*nCount)++;
      }

      if (me->Lcolrec[iLoop].col_db.llft_style >= 0)
      { /*  left border  */
        if (Fldrec)
        {
          Fldrec[*nCount].rectyp = VD_DRWLO_EN_LINE;
          Fldrec[*nCount].VD.ln.y1 = y1 + yLode;
          Fldrec[*nCount].VD.ln.y2 = yhtot + yLode;
          Fldrec[*nCount].VD.ln.x1 =
          Fldrec[*nCount].VD.ln.x2 = x1 + xLode;
          Fldrec[*nCount].symb.level               = nLlevel;
          Fldrec[*nCount].symb.display_attr.color  = nLcolor;
          Fldrec[*nCount].symb.display_attr.style  =
                              me->Lcolrec[iLoop].col_db.llft_style;
          Fldrec[*nCount].symb.display_attr.weight =
                              me->Lcolrec[iLoop].col_db.llft_wgt;
#ifdef MY_DEBUG
          printf ("llin %f %f to %f %f\n",
                                 Fldrec[*nCount].VD.ln.x1,
                                 Fldrec[*nCount].VD.ln.y1,
                                 Fldrec[*nCount].VD.ln.x2,
                                 Fldrec[*nCount].VD.ln.y2);
#endif
        }
        (*nCount)++;
      }

      if (me->Lcolrec[iLoop].col_db.lrgt_style >= 0)
      { /*  right border  */
        if (Fldrec)
        {
          Fldrec[*nCount].rectyp = VD_DRWLO_EN_LINE;
          Fldrec[*nCount].VD.ln.y1 = y1 + yLode;
          Fldrec[*nCount].VD.ln.y2 = yhtot + yLode;
          Fldrec[*nCount].VD.ln.x1 =
          Fldrec[*nCount].VD.ln.x2 = x2 + xLode;
          Fldrec[*nCount].symb.level               = nLlevel;
          Fldrec[*nCount].symb.display_attr.color  = nLcolor;
          Fldrec[*nCount].symb.display_attr.style  =
                              me->Lcolrec[iLoop].col_db.lrgt_style;
          Fldrec[*nCount].symb.display_attr.weight =
                              me->Lcolrec[iLoop].col_db.lrgt_wgt;
#ifdef MY_DEBUG
          printf ("rlin %f %f to %f %f\n",
                                 Fldrec[*nCount].VD.ln.x1,
                                 Fldrec[*nCount].VD.ln.y1,
                                 Fldrec[*nCount].VD.ln.x2,
                                 Fldrec[*nCount].VD.ln.y2);
#endif
        }
        (*nCount)++;
      }

      if (me->Lcolrec[iLoop].col_db.tl_br != 0)
      { /*  topleft to bottom right cross */
        if (Fldrec)
        {
          Fldrec[*nCount].rectyp = VD_DRWLO_EN_LINE;
          Fldrec[*nCount].VD.ln.x1 = x1 + xLode;
          Fldrec[*nCount].VD.ln.y1 = yhtot + yLode;
          Fldrec[*nCount].VD.ln.x2 = x2 + xLode;
          Fldrec[*nCount].VD.ln.y2 = y1 + yLode;
          Fldrec[*nCount].symb.level               = nLlevel;
          Fldrec[*nCount].symb.display_attr.color  = nLcolor;
          Fldrec[*nCount].symb.display_attr.style  = 0;
          Fldrec[*nCount].symb.display_attr.weight = 0;
#ifdef MY_DEBUG
          printf ("tl_br %f %f to %f %f\n",
                                 Fldrec[*nCount].VD.ln.x1,
                                 Fldrec[*nCount].VD.ln.y1,
                                 Fldrec[*nCount].VD.ln.x2,
                                 Fldrec[*nCount].VD.ln.y2);
#endif
        }
        (*nCount)++;
      }

      if (me->Lcolrec[iLoop].col_db.bl_tr != 0)
      { /*  bottomleft to topright cross  */
        if (Fldrec)
        {
          Fldrec[*nCount].rectyp = VD_DRWLO_EN_LINE;
          Fldrec[*nCount].VD.ln.x1 = x1 + xLode;
          Fldrec[*nCount].VD.ln.y1 = y1 + yLode;
          Fldrec[*nCount].VD.ln.x2 = x2 + xLode;
          Fldrec[*nCount].VD.ln.y2 = yhtot + yLode;
          Fldrec[*nCount].symb.level               = nLlevel;
          Fldrec[*nCount].symb.display_attr.color  = nLcolor;
          Fldrec[*nCount].symb.display_attr.style  = 0;
          Fldrec[*nCount].symb.display_attr.weight = 0;
#ifdef MY_DEBUG
          printf ("bl_tr %f %f to %f %f\n",
                                 Fldrec[*nCount].VD.ln.x1,
                                 Fldrec[*nCount].VD.ln.y1,
                                 Fldrec[*nCount].VD.ln.x2,
                                 Fldrec[*nCount].VD.ln.y2);
#endif
        }
        (*nCount)++;
      }

      /*   fixed text   */

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

#ifdef MY_DEBUG
      printf (" to getx,gety - jcnt = %d\n",jCnt);
#endif


      /*   now calculate the text displacements     */

      status = VD_drwlo_getx (nGrptyp,&me->Lcolrec[iLoop],NULL, xValues);

      status = VD_drwlo_gtty (me->Lcolrec[iLoop].col_db.col_charhgt,
                              me->Lcolrec[iLoop].col_db.col_linspc,
                              jTot, dYhight, yValues);

      for (jfld = 0; jfld < jCnt; jfld++)
      {
        if (fBuff[jfld].fieldtype != VD_DRWLO_EN_TEXT) continue;

        /*     position text .....  */

        if (Fldrec)
        {
          IGRdouble     xtext, ytext;

          switch (fBuff[jfld].justification)
          {
            case GRIO_LEFT_JUSTIFY:
            default:
              xtext = xValues[0];
              Fldrec[*nCount].VD.tx.justif  = LEFT_BASE;
              break;
            case GRIO_CENTER_JUSTIFY:
              xtext = xValues[1];
              Fldrec[*nCount].VD.tx.justif  = CENTER_BASE;
              break;
            case GRIO_RIGHT_JUSTIFY:
              xtext = xValues[2];
              Fldrec[*nCount].VD.tx.justif  = RIGHT_BASE;
              break;
          }

          ytext = yValues[jfld] + dYalign;

          Fldrec[*nCount].rectyp = VD_DRWLO_EN_TEXT;
          Fldrec[*nCount].symb.level               = nLlevel;
          Fldrec[*nCount].symb.display_attr.color  = nLcolor;
          Fldrec[*nCount].symb.display_attr.style  = 0;
          Fldrec[*nCount].symb.display_attr.weight = fBuff[jfld].id_weight;
          Fldrec[*nCount].VD.tx.xcor   = xtext + xLode;
          Fldrec[*nCount].VD.tx.ycor   = ytext + yLode;
          Fldrec[*nCount].VD.tx.colno  = me->Lcolrec[iLoop].col_db.col_seqno;
          Fldrec[*nCount].VD.tx.ch_wdt = me->Lcolrec[iLoop].col_db.col_charwdt;
          Fldrec[*nCount].VD.tx.ch_hgt = me->Lcolrec[iLoop].col_db.col_charhgt;
          Fldrec[*nCount].VD.tx.ch_spc = me->Lcolrec[iLoop].col_db.col_charspc;
          Fldrec[*nCount].VD.tx.numchr = me->Lcolrec[iLoop].col_db.col_chars;

          Fldrec[*nCount].VD.tx.lineno = fBuff[jfld].lin_seqno;

          strcpy (Fldrec[*nCount].VD.tx.font, fBuff[jfld].id_Font);
          strcpy (Fldrec[*nCount].VD.tx.Text, fBuff[jfld].Ftext);

#ifdef MY_DEBUG
          printf ("textout %f %f %s\n",
                      Fldrec[*nCount].VD.tx.xcor,
                      Fldrec[*nCount].VD.tx.ycor,
                      Fldrec[*nCount].VD.tx.Text);
#endif
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

    *dHgt = yhtot - yltot;

    for (iLoop = 0; iLoop < nNumhtf; iLoop++)
    { /*   for every htf field  */
      IGRdouble     dYhight;

      if (me->Lhtfrec[iLoop].htf_db.hdtr_type != nGrptyp) continue;

      *msg    = MSSUCC;

      strcpy (szLocfld, me->Lhtfrec[iLoop].htf_db.fieldid);

#ifdef MY_DEBUG
      printf ("fix process iloop %d types %d %d field %s\n",iLoop,
                  me->Lhtfrec[iLoop].htf_db.hdtr_type, nGrptyp,
                  szLocfld);
#endif

      status =
      om$send (msg = message VDdrwlo.VDdrwlo_grect
                              (&retmsg, nGrptyp, iLoop, szLocfld,
                                nExt, Exrec, &x1, &y1, &x2, &y2),
          targetid = my_id);

      dYhight = y2 - y1;

      /*  output border and crossing lines    */
      if (me->Lhtfrec[iLoop].htf_db.ltop_style >= 0)
      { /*  top border */
        if (Fldrec)
        {
          Fldrec[*nCount].rectyp = VD_DRWLO_EN_LINE;
          Fldrec[*nCount].VD.ln.x1 = x1 + xLode;
          Fldrec[*nCount].VD.ln.x2 = x2 + xLode;
          Fldrec[*nCount].VD.ln.y1 =
          Fldrec[*nCount].VD.ln.y2 = y2 + yLode;
          Fldrec[*nCount].symb.level               = nLlevel;
          Fldrec[*nCount].symb.display_attr.color  = nLcolor;
          Fldrec[*nCount].symb.display_attr.style  =
                              me->Lhtfrec[iLoop].htf_db.ltop_style;
          Fldrec[*nCount].symb.display_attr.weight =
                              me->Lhtfrec[iLoop].htf_db.ltop_wgt;
#ifdef MY_DEBUG
          printf ("tbord %f %f to %f %f\n",
                                 Fldrec[*nCount].VD.ln.x1,
                                 Fldrec[*nCount].VD.ln.y1,
                                 Fldrec[*nCount].VD.ln.x2,
                                 Fldrec[*nCount].VD.ln.y2);
#endif
        }
        (*nCount)++;
      }

      if (me->Lhtfrec[iLoop].htf_db.lbot_style >= 0)
      { /*  bottom border  */
        if (Fldrec)
        {
          Fldrec[*nCount].rectyp = VD_DRWLO_EN_LINE;
          Fldrec[*nCount].VD.ln.x1 = x1 + xLode;
          Fldrec[*nCount].VD.ln.x2 = x2 + xLode;
          Fldrec[*nCount].VD.ln.y1 = 
          Fldrec[*nCount].VD.ln.y2 = y1 + yLode;
          Fldrec[*nCount].symb.level               = nLlevel;
          Fldrec[*nCount].symb.display_attr.color  = nLcolor;
          Fldrec[*nCount].symb.display_attr.style  =
                              me->Lhtfrec[iLoop].htf_db.lbot_style;
          Fldrec[*nCount].symb.display_attr.weight =
                              me->Lhtfrec[iLoop].htf_db.lbot_wgt;
#ifdef MY_DEBUG
          printf ("bbord %f %f to %f %f\n",
                                 Fldrec[*nCount].VD.ln.x1,
                                 Fldrec[*nCount].VD.ln.y1,
                                 Fldrec[*nCount].VD.ln.x2,
                                 Fldrec[*nCount].VD.ln.y2);
#endif
        }
        (*nCount)++;
      }

      if (me->Lhtfrec[iLoop].htf_db.llft_style >= 0)
      { /*  left border  */
        if (Fldrec)
        {
          Fldrec[*nCount].rectyp = VD_DRWLO_EN_LINE;
          Fldrec[*nCount].VD.ln.y1 = y1 + yLode;
          Fldrec[*nCount].VD.ln.y2 = y2 + yLode;
          Fldrec[*nCount].VD.ln.x1 =
          Fldrec[*nCount].VD.ln.x2 = x1 + xLode;
          Fldrec[*nCount].symb.level               = nLlevel;
          Fldrec[*nCount].symb.display_attr.color  = nLcolor;
          Fldrec[*nCount].symb.display_attr.style  =
                              me->Lhtfrec[iLoop].htf_db.llft_style;
          Fldrec[*nCount].symb.display_attr.weight =
                              me->Lhtfrec[iLoop].htf_db.llft_wgt;
#ifdef MY_DEBUG
          printf ("lbord %f %f to %f %f\n",
                                 Fldrec[*nCount].VD.ln.x1,
                                 Fldrec[*nCount].VD.ln.y1,
                                 Fldrec[*nCount].VD.ln.x2,
                                 Fldrec[*nCount].VD.ln.y2);
#endif
        }
        (*nCount)++;
      }

      if (me->Lhtfrec[iLoop].htf_db.lrgt_style >= 0)
      { /*  right border  */
        if (Fldrec)
        {
          Fldrec[*nCount].rectyp = VD_DRWLO_EN_LINE;
          Fldrec[*nCount].VD.ln.y1 = y1 + yLode;
          Fldrec[*nCount].VD.ln.y2 = y2 + yLode;
          Fldrec[*nCount].VD.ln.x1 =
          Fldrec[*nCount].VD.ln.x2 = x2 + xLode;
          Fldrec[*nCount].symb.level               = nLlevel;
          Fldrec[*nCount].symb.display_attr.color  = nLcolor;
          Fldrec[*nCount].symb.display_attr.style  =
                              me->Lhtfrec[iLoop].htf_db.lrgt_style;
          Fldrec[*nCount].symb.display_attr.weight =
                              me->Lhtfrec[iLoop].htf_db.lrgt_wgt;
#ifdef MY_DEBUG
          printf ("rbord %f %f to %f %f\n",
                                 Fldrec[*nCount].VD.ln.x1,
                                 Fldrec[*nCount].VD.ln.y1,
                                 Fldrec[*nCount].VD.ln.x2,
                                 Fldrec[*nCount].VD.ln.y2);
#endif
        }
        (*nCount)++;
      }

      if (me->Lhtfrec[iLoop].htf_db.tl_br != 0)
      { /*  topleft to bottom right cross */
        if (Fldrec)
        {
          Fldrec[*nCount].rectyp = VD_DRWLO_EN_LINE;
          Fldrec[*nCount].VD.ln.x1 = x1 + xLode;
          Fldrec[*nCount].VD.ln.y1 = y2 + yLode;
          Fldrec[*nCount].VD.ln.x2 = x2 + xLode;
          Fldrec[*nCount].VD.ln.y2 = y1 + yLode;
          Fldrec[*nCount].symb.level               = nLlevel;
          Fldrec[*nCount].symb.display_attr.color  = nLcolor;
          Fldrec[*nCount].symb.display_attr.style  = 0;
          Fldrec[*nCount].symb.display_attr.weight = 0;
#ifdef MY_DEBUG
          printf ("tl_br %f %f to %f %f\n",
                                 Fldrec[*nCount].VD.ln.x1,
                                 Fldrec[*nCount].VD.ln.y1,
                                 Fldrec[*nCount].VD.ln.x2,
                                 Fldrec[*nCount].VD.ln.y2);
#endif
        }
        (*nCount)++;
      }

      if (me->Lhtfrec[iLoop].htf_db.bl_tr != 0)
      { /*  bottomleft to topright cross  */
        if (Fldrec)
        {
          Fldrec[*nCount].rectyp = VD_DRWLO_EN_LINE;
          Fldrec[*nCount].VD.ln.x1 = x1 + xLode;
          Fldrec[*nCount].VD.ln.y1 = y1 + yLode;
          Fldrec[*nCount].VD.ln.x2 = x2 + xLode;
          Fldrec[*nCount].VD.ln.y2 = y2 + yLode;
          Fldrec[*nCount].symb.level               = nLlevel;
          Fldrec[*nCount].symb.display_attr.color  = nLcolor;
          Fldrec[*nCount].symb.display_attr.style  = 0;
          Fldrec[*nCount].symb.display_attr.weight = 0;
#ifdef MY_DEBUG
          printf ("bl_tr %f %f to %f %f\n",
                                 Fldrec[*nCount].VD.ln.x1,
                                 Fldrec[*nCount].VD.ln.y1,
                                 Fldrec[*nCount].VD.ln.x2,
                                 Fldrec[*nCount].VD.ln.y2);
#endif
        }
        (*nCount)++;
      }

      /*   fixed text   */

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
        if( (fBuff[jfld].fieldtype != VD_DRWLO_EN_TEXT) &&
            (fBuff[jfld].fieldtype != VD_DRWLO_EN_CELL) )
          continue;

        /*
        **     position cell .....
        */
        if( (fBuff[jfld].fieldtype == VD_DRWLO_EN_CELL) )
        {
          xValues[0] = me->Lhtfrec[iLoop].htf_x1;
          xValues[1] = (me->Lhtfrec[iLoop].htf_x1 + 
	               me->Lhtfrec[iLoop].htf_x2) / 2.0;
          xValues[2] = me->Lhtfrec[iLoop].htf_x2;
        }

        /*     position text .....  */

        if (Fldrec)
        {
          IGRdouble     xtext, ytext;

          switch (fBuff[jfld].justification)
          {
            case GRIO_LEFT_JUSTIFY:
            default:
              xtext = xValues[0];
              Fldrec[*nCount].VD.tx.justif  = LEFT_BASE;
              break;
            case GRIO_CENTER_JUSTIFY:
              xtext = xValues[1];
              Fldrec[*nCount].VD.tx.justif  = CENTER_BASE;
              break;
            case GRIO_RIGHT_JUSTIFY:
              xtext = xValues[2];
              Fldrec[*nCount].VD.tx.justif  = RIGHT_BASE;
              break;
          }

          ytext = yValues[jfld] + y1;

          if( (fBuff[jfld].fieldtype == VD_DRWLO_EN_CELL) )
          {
            ytext = ( y1 + y2 ) / 2.0;
          }

          Fldrec[*nCount].rectyp       = fBuff[jfld].fieldtype;

//if ( fBuff[jfld].fieldtype == 0 ) Fldrec[*nCount].rectyp  = VD_DRWLO_EN_TEXT;

          Fldrec[*nCount].symb.level               = nLlevel;
          Fldrec[*nCount].symb.display_attr.color  = nLcolor;
          Fldrec[*nCount].symb.display_attr.style  = 0;
          Fldrec[*nCount].symb.display_attr.weight = fBuff[jfld].id_weight;
          Fldrec[*nCount].VD.tx.xcor   = xtext + xLode;
          Fldrec[*nCount].VD.tx.ycor   = ytext + yLode;
          Fldrec[*nCount].VD.tx.colno  = VD_DRWLO_EN_ALL;
          Fldrec[*nCount].VD.tx.ch_wdt = me->Lhtfrec[iLoop].htf_db.fld_charwdt;
          Fldrec[*nCount].VD.tx.ch_hgt = me->Lhtfrec[iLoop].htf_db.fld_charhgt;
          Fldrec[*nCount].VD.tx.ch_spc = me->Lhtfrec[iLoop].htf_db.fld_charspc;
          Fldrec[*nCount].VD.tx.numchr = me->Lhtfrec[iLoop].htf_db.fld_chars;

          Fldrec[*nCount].VD.tx.lineno = fBuff[jfld].lin_seqno;

          strcpy (Fldrec[*nCount].VD.tx.font, fBuff[jfld].id_Font);
          strcpy (Fldrec[*nCount].VD.tx.Text, fBuff[jfld].Ftext);

#ifdef MY_DEBUG
          printf ("textout %d %f %f %s\n",Fldrec[*nCount].VD.tx.justif,
                      Fldrec[*nCount].VD.tx.xcor,
                      Fldrec[*nCount].VD.tx.ycor,
                      Fldrec[*nCount].VD.tx.Text);
#endif
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

