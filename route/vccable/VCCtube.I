
/* $Id: VCCtube.I,v 1.2 2001/02/20 01:09:17 build Exp $  */

/*************************************************************************
 * I/CABLE
 *
 * File:        vccable/VCCtube.I
 *
 * Description:
 *
 *      Method to create tube around cable string
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VCCtube.I,v $
 *      Revision 1.2  2001/02/20 01:09:17  build
 *      Replaced v_dbgmacros.h with product specific dbgmacros.h
 *
 *      Revision 1.1.1.1  2001/01/04 21:12:26  cvs
 *      Initial import to CVS
 *
# Revision 1.1  1998/04/30  10:52:34  pinnacle
# ROUTE 2.5.1
#
# Revision 1.3  1998/04/10  15:53:04  pinnacle
# Replaced: vccable/VCCtube.I for:  by apazhani for route
#
# Revision 1.2  1998/04/01  20:28:24  pinnacle
# Replaced: vccable/VCCtube.I for:  by kddinov for route
#
# Revision 1.1  1997/10/30  04:09:46  pinnacle
# Integration of Cable into 02.04.03.04
#
# Revision 1.5  1997/07/14  22:33:04  pinnacle
# Replaced: vccable/VCCtube.I for:  by hverstee for cabling
#
# Revision 1.4  1997/05/06  23:10:58  pinnacle
# Replaced: vccable/VCCtube.I for:  by hverstee for cabling
#
# Revision 1.3  1997/03/06  22:56:24  pinnacle
# Replaced: vccable/VCCtube.I for:  by hverstee for cabling
#
# Revision 1.2  1996/11/26  16:57:52  pinnacle
# Replaced: vccable/VCCtube.I for:  by hverstee for cabling
#
# Revision 1.1  1996/08/28  21:50:30  pinnacle
# Created: vccable/VCCtube.I by hverstee for cabling
#
 *
 * History:
 *      MM/DD/YY   AUTHOR       DESCRIPTION
 *
 *      05/29/96    hv          Initial
 *	3-98	  KDD		don't use VCGetModel rather call methods on me.
 *				VCRoot.VCGetModel takes care of the model.
 *	04/10/98  Alwin		Set the 'dSectRad' correctly. TR179800703
 *
 *************************************************************************/

class implementation VCCable;

/*
#define vdsDEBUG      1
#define MY_DEBUG      1
*/

#include "VDmem.h"
#include "vrdbgmacros.h"

extern     GRclassid     OPP_EMSgenbs_class_id;

from    EMSgenbs        import  EMplctbesrf;

method VCCbTube (  IGRlong         *msg; 
                   IGRint           NumLines;
            struct GRid            *LineGRid;
                   IGRint          *NumTube;
            struct GRid            *TubeGRid;
            struct GRvg_construct  *cnst_lis;
            struct GRmd_env        *md_env)
{
  IGRint             status;
  IGRlong            retmsg;
  IGRint             Vertex;
  IGRchar           *geomsave;
  IGRdouble         *dLocBend;
  IGRint             NumVert;
  IGRint             NumSect;
  IGRint             NumBover;
  IGRint             NValloc;
  IGRshort           nIndex;
  IGRshort           nMAP;
  IGRint             nSTR;
  IGRint             i;
  IGRint             iSE, iSB;
  IGRdouble          dBendRad;
  IGRdouble          dSectRad;
  IGRchar            szTag[VC_MAX_TAGNO];

  struct ret_struct  Attr;
  struct GRid        LocTube;
  struct GRid        ModelId;

SetProc(VCCable_VCCbTube); Begin

__DBGpr_me(); 

  /*A initialization */
  *msg     = MSFAIL;
  nIndex   = -1;
  nMAP     = -1;
  *NumTube = 0;
  NValloc  = 0;
  dLocBend = NULL;

  for (i=0; i<NumLines; i++)
  {
    TubeGRid[i].objid = NULL_OBJID;
    TubeGRid[i].osnum = OM_Gw_current_OS;
  }

  /*C Get Database attributes' cache */

  status = om$send( msg      = message VCRoot.VCGetTagNo (szTag),
                    targetid = my_id);

__DBGpr_str("My tag ", szTag); 

  /*C get the Bend radius from the Db collection */
  /* 3-98 KDD Use VCRoot.VCGpAnum, overwritten in VCCable */

  status = om$send( msg  = message VCRoot.VCGpAnum (&retmsg, 
					nIndex, nMAP, VC_X_BEND_RAD_DB, &Attr),
                    targetid = my_id);

  if ( (!(status & OM_S_SUCCESS)) || (retmsg != MSSUCC)) {
    printf (" %s : Error, cannot find bend radius\n",szTag);
    as$status(); 
    goto NO_TUBE;
  }

  dBendRad = Attr.var.root_pm_st.value;

  /*C get the Sect radius from the sys collection */
  /* 3-98 KDD Use VCRoot.VCGpAnum, overwritten in VCCable */

  status = om$send( msg      = message VCRoot.VCGpAnum (&retmsg, 
					nIndex, nMAP, VC_X_DIAMETER_DB, &Attr),
                    targetid = my_id);

  if ( (!(status & OM_S_SUCCESS)) || (retmsg != MSSUCC)) {
    printf (" %s : Error, cannot find cable radius\n",szTag);
    as$status(); 
    goto NO_TUBE;
  }

  __DBGpr_dbl( " Diameter of Cable ", Attr.var.root_pm_st.value );

  /* radius = Diameter / 2.0 ). TR179800703 */
  dSectRad = ( Attr.var.root_pm_st.value / 2.0 );

  __DBGpr_dbl( " Radius of Cable ", dSectRad );

#ifdef MY_DEBUG
  printf ("Create tube, bendrad, sectrad %f %f\n",dBendRad, dSectRad);
#endif

  NumSect = om$dimension_of (varray = me->Sect);
  NumVert = 0;

  for (nSTR = 0; nSTR< NumLines; nSTR++)
  {
    iSB = iSE = -1;

    LocTube.objid = NULL_OBJID;
    LocTube.osnum = OM_Gw_current_OS;

    for (i=0;i<NumSect; i++)
    {
      if (me->Sect[i].strno == nSTR)
      {
        iSE = i;

        NumVert += me->Sect[i].numvert;

        if (iSB < 0) iSB = i;
      }
    }

    /*C Allocate a bend table and update with overrides   */

    if (NumVert > NValloc)
    {
      _FREE (dLocBend);
      dLocBend = _MALLOC (NumVert ,IGRdouble);
      NValloc = NumVert;
    }

    for ( Vertex = 0; Vertex < NumVert; Vertex++ )
      dLocBend[Vertex] = dBendRad;

    NumBover = om$dimension_of(varray = me->Bend);

    /*   EMS numbers it's vertices starting at 0, but NOT INCLUDING
         the begin ............ */

    for (Vertex = 0; Vertex < NumBover; Vertex++ )
      if ((me->Bend[Vertex].secno >= iSB) &&
          (me->Bend[Vertex].secno <= iSE))
    {
      IGRint     iEMS;

      iEMS = me->Bend[Vertex].vtxno - 1;

      if (iEMS >= 0)
        dLocBend[iEMS] = me->Bend[Vertex].rad;
    }

#ifdef MY_DEBUG
    printf ("bendrad override %d\n",NumBover);
    for ( Vertex = 0; Vertex < NumVert; Vertex++ )
      printf (" bendtab %d %f\n",Vertex,dLocBend[Vertex]);
    printf ("Linegrid %d %d\n",LineGRid->objid, LineGRid->osnum);
#endif

    /*A construct the tube object */
    geomsave = cnst_lis->geometry;

    status =
    om$construct(classid = OPP_EMSgenbs_class_id,
                 p_objid = &LocTube.objid,
                 msg     = message EMSgenbs.EMplctbesrf
                                         (&retmsg, md_env, LineGRid[nSTR],
                                         dSectRad, dLocBend, cnst_lis));
    as$status();

    cnst_lis->geometry = geomsave;

    *msg = retmsg;

    /*A status check for the tube construction */
    if ( !(status & OM_S_SUCCESS) || retmsg != MSSUCC )
    {
      printf (" %s : Error, cannot generate tube\n", szTag );

      if (retmsg == MSINARG)
      {
        printf ("bend radius too big\n");

        for ( Vertex = 0; Vertex < NumVert; Vertex++ )
          printf (" bendtab %d %f\n",Vertex,dLocBend[Vertex]);
      }
      else
        printf ("retmsg = %d\n",retmsg);

      if( LocTube.objid != NULL_OBJID )
      {
        om$send(msg   = message Root.delete(1),
             targetid = LocTube.objid,
             senderid = NULL_OBJID );

        LocTube.objid = NULL_OBJID;
      }
    }
    else
    {
      TubeGRid[*NumTube].objid = LocTube.objid;
      TubeGRid[*NumTube].osnum = LocTube.osnum;
      (*NumTube)++;
    }
  }

  NO_TUBE:
   _FREE (dLocBend);
End;
  return OM_S_SUCCESS ;
}

end implementation VCCable;
