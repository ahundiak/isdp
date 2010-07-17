
/* $Id: VCCsection.I,v 1.2 2001/02/20 01:09:11 build Exp $  */

/*************************************************************************
 * I/CABLE
 *
 * File:        vccable/VCCsection.I
 *
 * Description:
 *
 *      Methods to access individual string sections
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VCCsection.I,v $
 *      Revision 1.2  2001/02/20 01:09:11  build
 *      Replaced v_dbgmacros.h with product specific dbgmacros.h
 *
 *      Revision 1.1.1.1  2001/01/04 21:12:26  cvs
 *      Initial import to CVS
 *
# Revision 1.2  1998/12/03  04:46:06  pinnacle
# Replaced: vccable/VCCsection.I for:  by sbilla for route
#
# Revision 1.1  1998/04/30  10:52:34  pinnacle
# ROUTE 2.5.1
#
# Revision 1.4  1998/04/02  20:13:24  pinnacle
# Replaced: vccable/VCCsection.I for:  by azuurhou for route
#
# Revision 1.3  1998/04/01  21:20:50  pinnacle
# Replaced: vccable/VCCsection.I for:  by kddinov for route
#
# Revision 1.2  1998/03/31  07:11:10  pinnacle
# Replaced: vccable/VCCsection.I for: TR 179800045 by aharihar for route
#
# Revision 1.1  1997/10/30  04:09:46  pinnacle
# Integration of Cable into 02.04.03.04
#
# Revision 1.9  1997/08/15  12:44:32  pinnacle
# Replaced: vccable/VCCsection.I for:  by hverstee for cabling
#
# Revision 1.8  1997/07/22  21:40:04  pinnacle
# Replaced: vccable/VCCsection.I for:  by hverstee for cabling
#
# Revision 1.7  1997/07/22  15:00:54  pinnacle
# Replaced: vccable/VCCsection.I for:  by hverstee for cabling
#
# Revision 1.6  1997/05/12  17:01:54  pinnacle
# Replaced: vccable/VCCsection.I for:  by hverstee for cabling
#
# Revision 1.5  1997/05/07  14:27:44  pinnacle
# Replaced: vccable/VCCsection.I for:  by hverstee for cabling
#
# Revision 1.4  1997/01/16  14:38:08  pinnacle
# Replaced: vccable/VCCsection.I for:  by hverstee for cabling
#
# Revision 1.3  1996/11/26  16:58:06  pinnacle
# Replaced: vccable/VCCsection.I for:  by hverstee for cabling
#
# Revision 1.2  1996/10/14  21:53:04  pinnacle
# Replaced: vccable/VCCsection.I for:  by hverstee for cabling
#
# Revision 1.1  1996/08/28  21:49:42  pinnacle
# Created: vccable/VCCsection.I by hverstee for cabling
#
 *
 * History:
 *      MM/DD/YY   AUTHOR       DESCRIPTION
 *      07/08/96    hv          Initial
 *	04/02/98    adz         Changes call for VCCSetOffset/VCCGetOffset
 *      12/03/98    Reddy       CR179800463 - if condition is  added in
 *				delete vertex case so that the vertex deletion
 *				is not possible in the case of cable with 
 *				two vertices
 *************************************************************************/

class implementation VCCable;

/*
#define vdsDEBUG      1
#define MY_DEBUG   1
*/

#include "nddef.h"
#include "ndmacros.h"

#include "VCsys.h"

#include "VDmem.h"
#include "vrdbgmacros.h"
#include "vdreporterr.h"

#include "bsdptseg2.h"
#include "bsdistptpt.h"

from    GRlinear   import    GRgetpolyline;
from    GRlinear   import    GRputpolyline;

from    VCP        import    VCP_addpt;
from    VCP        import    VCP_reorg;

/**********************************************************************

   Abstract: This file contains the methods to find and modify the
             string sections of a composite link

***********************************************************************/

/*      modify linestring section          */

method    VCCbModify (IGRlong        *msg;
                      IGRint          ModType;   /*  sendtype INS/MOV/DEL   */
                      IGRint          AdjType;   /*  adjustment type        */
                      IGRint          SecNum;    /*  section number         */
                      IGRint          VtxNum;    /*  vertex/segment number  */
                      IGRdouble      *dCoord;    /*  coordinates            */
              struct  GRmd_env       *md_env)
{
  IGRlong        retmsg;
  IGRint         status;
  IGRint         NumSect;
  IGRint         NumBend;
  IGRint         iVert;
  IGRint         iSect;
  IGRint         action;
  IGRint         cn_type;
  IGRint         iMstr;
  IGRint         i;
  IGRboolean     bEndVtx;
  IGRdouble     *dVertex = NULL ;
  GRobjid        New;
  IGRdouble      dB;
  IGRint	Numvert; /* stores the total no. of vertices on the cable */

  struct IGRpolyline     LineIn;
  struct GRpost_info     post_info;
  struct GRid            Test;
  struct GRid            mygrid;
  struct VCOffset	 *pOffset	= NULL;
  extern  NDwait_batch();

  SetProc( VCCable_VCCbModify ); Begin 
  __DBGpr_int(" Modtype", ModType);
  __DBGpr_int(" VCCB_MOV_VERTEX",VCCB_MOV_VERTEX);

  *msg     = MSFAIL;
  bEndVtx  = FALSE;

  mygrid.objid = my_id;
  mygrid.osnum = OM_Gw_current_OS;

  NumSect  = om$dimension_of (varray = me->Sect);
  __DBGpr_int(" Dimension of me->Sect",NumSect);
  __DBGpr_int(" section number",SecNum);

  if ((SecNum >= NumSect) || (SecNum < 0))
  {
    End
    return (OM_E_ABORT);
  }
  if (me->Sect[SecNum].type != VCC_STRING)
  {
    __DBGpr_com(" Section type is not VCC_STRING");
    End
    return (OM_E_ABORT);
  }

#ifdef vdsDEBUG
  printf ("\tModify Getpoly sect,vtx = %d %d\n",SecNum,VtxNum);
#endif

  iMstr  = me->Sect[SecNum].strno;

  action = 0;
  status =
  om$send(msg    = message GRlinear.GRgetpolyline
                              (&retmsg, &md_env->md_env.matrix_type,
                                md_env->md_env.matrix, &action, &LineIn),
    p_chanselect = &AS_to_comp,
    from         = iMstr,
    to           = iMstr);
  as$status();

  if (ModType == VCCB_INS_VERTEX)
  { /*  legal segment num   */
    if ((VtxNum > (LineIn.num_points -1)) || (VtxNum < 0)) return (OM_E_ABORT);
    if ((VtxNum > (me->Sect[SecNum].iTo - 1))  ||
        (VtxNum < me->Sect[SecNum].iFrom))                 return (OM_E_ABORT);
  }
  else
  { /*  legal vertex num (exclude end vertices!!!)  */
    /*  after introduction of "BREAK" end vertices may play along ...... */

    if ((VtxNum > (LineIn.num_points)) || (VtxNum < 0))
    {
	End
	return (OM_E_ABORT);
    }

    if ((VtxNum == (LineIn.num_points)) || (VtxNum == 0)) bEndVtx = TRUE;
  }

  action = 1;
  
  dVertex  = _MALLOC (((LineIn.num_points+2) * 3), IGRdouble);

  LineIn.points     = dVertex;
  LineIn.num_points = 0;

  status =
  om$send(msg    = message GRlinear.GRgetpolyline
                              (&retmsg, &md_env->md_env.matrix_type,
                                md_env->md_env.matrix, &action, &LineIn),
    p_chanselect = &AS_to_comp,
    from         = iMstr,
    to           = iMstr);
  as$status();

#ifdef vdsDEBUG
  printf ("\tmodify retrieved line %d vertices\n",LineIn.num_points);
#endif

/* Calculate the total no. of vertices on a section - CR179800463 */
  Numvert=0;
  for( i=0; i<NumSect ; i++ )
  {
      if (me->Sect[i].type == VCC_STRING)
	  Numvert += me->Sect[i].numvert;
  }
  __DBGpr_int( " number of vertices in cable by ",Numvert);

  switch (ModType)
  {
    case VCCB_MOV_VERTEX:
      LineIn.points[VtxNum*3]   = dCoord[0];
      LineIn.points[VtxNum*3+1] = dCoord[1];
      LineIn.points[VtxNum*3+2] = dCoord[2];
      __DBGpr_vec(" Coord of vertex",dCoord);

      /*    if end vertex, do we automatically adjust cpt or offset??  */

      if (AdjType == VCCB_ADJUST_OFFSET)
      {
        /*     @@@@@@@@@@@TBD@@@@@@@@@@@@   */
        /*     Get a matrix based on this adjoining segment and project
               the offset coordinates to get dY and dZ                  */
        /*     @@@@@@@@@@@TBD@@@@@@@@@@@@   */
	__DBGpr_int(" VCCB_ADJUST_OFFSET",VCCB_ADJUST_OFFSET);

        if (VtxNum == 0)
        {  /*  set offset at begin    */
          me->Sect[SecNum].dY0 = 0.0;
          me->Sect[SecNum].dZ0 = 0.0;
        }
        else
        {  /*  set offset at end      */
          me->Sect[SecNum].dY1 = 0.0;
          me->Sect[SecNum].dZ1 = 0.0;
        }
      }
      __DBGpr_int(" Adjtype",AdjType);
      __DBGpr_int(" VCCB_ADJUST_DYNCPT",VCCB_ADJUST_DYNCPT);

      if (AdjType == VCCB_ADJUST_DYNCPT)
      {
        struct GRid      Term;
        IGRshort         nEND;
        IGRshort         nCP = -1;
	IGRmatrix	 dRefMatrix;
	IGRvector	 NewOffset;
	IGRshort	 NoOffsets	= 0;

        if (VtxNum == 0) nEND = 0;
        else             nEND = 1;
	__DBGpr_int(" nEND vertex",nEND);

        status =
        om$send (msg = message VCCable.VCCbTerm (&retmsg, nEND, &Term),
            targetid = my_id);
	__DBGpr_obj(" Terminal ID",Term);
 
	/*
	 * Below lines of code added by Anand for resetting offset of cable
	 * vertex wrt its attached terminal, when it is moved
	 */
	status = om$send( msg = message VCRoot.VCGetMatrix( &retmsg , -1,
						    dRefMatrix, md_env),
		     targetid = Term.objid,
		     targetos = Term.osnum);
	as$status(msg = "VCRoot.VCGetMatrix",
		  action = GOTO_VALUE,
		  value = wrapup );
	__DBGpr_mat(" Matrix of terminal",dRefMatrix);

	NewOffset[0] = dCoord[0] - dRefMatrix[3];
	NewOffset[1] = dCoord[1] - dRefMatrix[7];
	NewOffset[2] = dCoord[2] - dRefMatrix[11];
	__DBGpr_vec(" New offset",NewOffset);

	status =
	om$send(msg = message VCCable.VCCGetOffset( (void *)&pOffset, &NoOffsets ),
	        targetid = my_id );
	as$status(msg = "VCCable.VCCGetOffset", action = GOTO_VALUE,
		  value = wrapup );

	__DBGpr_int(" NoOffsets",NoOffsets);
	if( NoOffsets )
	{
	  for( i=0 ; i < NoOffsets ; i=i+1 )
	  {
	      __DBGpr_int(" Offset Index ",(pOffset+i)->Index);
	      __DBGpr_vec(" Offset vector",(pOffset+i)->Offset);

	      if( (pOffset+i)->Index == nEND ){

		(pOffset+i)->Offset[0]=NewOffset[0];
		(pOffset+i)->Offset[1]=NewOffset[1];
		(pOffset+i)->Offset[2]=NewOffset[2];
	        __DBGpr_vec(" Offset vector",(pOffset+i)->Offset);
	        break;
	      }
	  }

          /*
	   * For release 2.5, pass the third argument as zero to signify that
	   * the type of OffsetStruct is struct VCOffset.
	   */
     
	  status =
	  om$send( msg = message VCCable.VCCSetOffset( (void *)pOffset, NoOffsets ),
		       targetid = my_id);
	  as$status(msg = "VCCable.VCCSetOffset", action = GOTO_VALUE,
		  value = wrapup );

	}

     /* Above lines of code added by Anand */

#ifdef UNCOMMENTED
    /* Not required, as now the offset is stored in the cable object */
        status =
        om$send (msg = message VCP.VCP_addpt
                          (&retmsg, dCoord, NULL, md_env, &nCP),
            targetid = Term.objid,
            targetos = Term.osnum);

        printf (" adjust dynamic cpt, new at %f %f %f - %d\n",
                      dCoord[0],dCoord[1],dCoord[2],nCP);
#endif

        if (nEND == 0)
          me->Sect[0].iFrom = me->Sect[0].iTo =nCP;
        else
          me->Sect[NumSect-1].iFrom = me->Sect[NumSect-1].iTo = nCP;

        /*  now reorganize......  */

#ifdef UNCOMMENTED
        status =
        om$send (msg = message VCP.VCP_reorg (&retmsg),
            targetid = Term.objid,
            targetos = Term.osnum);
#endif
      }
      break;

    case VCCB_ORT_VERTEX:
      LineIn.points[VtxNum*3]   = dCoord[0];
      LineIn.points[VtxNum*3+1] = dCoord[1];
      LineIn.points[VtxNum*3+2] = dCoord[2];
      break;

    case VCCB_INS_VERTEX:
      /*C   NOTE: VtxNum here denotes the SEGMENT number....... */
      for (iVert = LineIn.num_points; iVert > VtxNum; iVert--)
      {
        LineIn.points[(iVert+1)*3]   = LineIn.points[iVert*3];
        LineIn.points[(iVert+1)*3+1] = LineIn.points[iVert*3+1];
        LineIn.points[(iVert+1)*3+2] = LineIn.points[iVert*3+2];
#ifdef vdsDEBUG
  printf (" move vtx %d to %d\n",iVert,(iVert+1));
#endif
      }

      LineIn.points[VtxNum*3+3] = dCoord[0];
      LineIn.points[VtxNum*3+4] = dCoord[1];
      LineIn.points[VtxNum*3+5] = dCoord[2];

#ifdef vdsDEBUG
  printf (" insert new %d\n",VtxNum+1);
#endif

      LineIn.num_points++;
      me->Sect[SecNum].iTo +=1;

#ifdef vdsDEBUG
  printf (" vertices out %d\n",LineIn.num_points);
#endif

      /*    adapt following section records ....  */

      for (iSect=SecNum+1; iSect<NumSect; iSect++)
      {
        if (me->Sect[iSect].type != VCC_STRING) continue;
        if (me->Sect[iSect].strno != iMstr)     break;

        me->Sect[iSect].iFrom++;
        me->Sect[iSect].iTo++;
      }

      /*    adapt bend override table....  */

      NumBend = om$dimension_of( varray = me->Bend);

      for (iVert=0; iVert<NumBend; iVert++)
      {
        IGRint   iST;

        iST = me->Sect[me->Bend[iVert].secno].strno;

        if ((iST == iMstr) &&
            (me->Bend[iVert].vtxno > VtxNum))
        {
          me->Bend[iVert].vtxno++;
        }
      }
      break;

    case VCCB_DEL_VERTEX:

/* if loop is added to  see that  the delete vertex command eliminates
   vertex only for the cable with more than two vertices - Billa-CR179800463 */
      if (Numvert > 2)
      {
      if (AdjType == VCCB_DELETE_BREAK)
      { /*   when deleting a break, just adapt sections     */
        /*   change BREAK_ON/BREAK_OFF to free vertices     */
        if ((VtxNum == 0) && (SecNum > 1))
        {
          me->Sect[SecNum - 1].type = VCC_FREE_VERTEX;
          me->Sect[SecNum - 2].type = VCC_FREE_VERTEX;
          break;
        }

        if (SecNum < (NumSect - 2))
        {
          me->Sect[SecNum + 1].type = VCC_FREE_VERTEX;
          me->Sect[SecNum + 2].type = VCC_FREE_VERTEX;
          break;
        }
      }

      /*   remove bend override if it exists   */

      dB = 0.0;

      status =
      om$send (msg = message VCCable.VCCbBendrPut
                              (&retmsg, VtxNum, SecNum, dB),
          targetid = my_id);

      /*    adapt following section records ....  */

      for (iSect=SecNum+1; iSect<NumSect; iSect++)
      {
        if (me->Sect[iSect].type != VCC_STRING) continue;
        if (me->Sect[iSect].strno != iMstr)     break;

        me->Sect[iSect].iFrom--;
        me->Sect[iSect].iTo--;
      }

      /*    adapt bend override table....  */

      NumBend = om$dimension_of( varray = me->Bend);

      for (iVert=0; iVert<NumBend; iVert++)
      {
        IGRint   iST;

        iST = me->Sect[me->Bend[iVert].secno].strno;

        if ((iST == iMstr) &&
            (me->Bend[iVert].vtxno > VtxNum))
        {
          me->Bend[iVert].vtxno--;
        }
      }

      LineIn.num_points--;
      for (iVert = VtxNum; iVert < LineIn.num_points; iVert++)
      {
        LineIn.points[iVert*3]   = LineIn.points[(iVert+1)*3];
        LineIn.points[iVert*3+1] = LineIn.points[(iVert+1)*3+1];
        LineIn.points[iVert*3+2] = LineIn.points[(iVert+1)*3+2];
      }
      me->Sect[SecNum].iTo -=1;
      }
      else
      {
	UI_status("cannot delete vertex of a cable of two vertices");
	}
      break;

    case VCCB_MOV_SEGMENT:    /*   orthogonal move, assume given
                                   coordinates are in sync          */

      for (i=0; i<6; i++)
       LineIn.points[VtxNum*3+i]   = dCoord[i];

      break;

    default:
      break;
  }

  post_info.construct_flag = FALSE;
  New = NULL_OBJID;

  Test.objid = NULL_OBJID;

  status =
  om$get_objid_at_index( objid = my_id,
                  p_chanselect = &AS_to_comp,
                  index        = iMstr,
                  objidaddr    = &Test.objid,
                  osnumaddr    = &Test.osnum );
  as$status();

  status =
  om$send(msg    = message GRlinear.GRputpolyline
                           (&retmsg, md_env, &post_info, &LineIn, &New),
    p_chanselect = &AS_to_comp,
    from         = iMstr,
    to           = iMstr);
  as$status();

  /* @@@@ TBD  @@@@    see if reconnect is necessary ..................   */
  if ((Test.objid != New) && (New != NULL_OBJID))
    printf (" new objid after change %d\n",New);

  _FREE (dVertex);

  /* do the wait batch */
  cn_type = ND_COMP;
  nd$wait_batch (type   = GR_GEOM_POSTED,
             l_object   = &mygrid,
             l_obj_info = &cn_type,
             nb_obj     = 1);

  nd$exec_batch();
  status = OM_S_SUCCESS ;

wrapup:

  _FREE( pOffset );

  End
  return( status );
}


/*       find vertex/segment and section given coordinates    */

method    VCCbFind   (IGRlong        *msg;
                      IGRint          ModType;   /*  sendtype INS/MOV/DEL   */
                      IGRint         *AdjType;   /*  adjustment type        */
                      IGRint         *SecNum;    /*  section number         */
                      IGRint         *VtxNum;    /*  vertex/segment number  */
                      IGRdouble      *dCoord;    /*  coordinates            */
                      IGRint          IXloc;     /*  normal coord           */
                      IGRdouble      *dDyn;      /*  coords for dynamics    */
                      IGRint         *EndPos;    /*  end position           */
              struct  GRmd_env       *md_env)
{
  IGRlong        retmsg;
  IGRint         status;
  IGRint         NumSect;
  IGRint         ibeg, iend;
  IGRint         iSect;
  IGRint         iVert;
  IGRint         i;
  IGRint         iMstr;
  IGRint         action = 1;
  IGRint         nPrevType;
  IGRint         nNextType;
  IGRint         nPotBeg;
  IGRint         nPotEnd;

  IGRdouble     *dVertex = NULL;
  IGRdouble      dDist;
  IGRdouble      dSavDist;
  IGRdouble      minpar;
  IGRdouble      minpt[3];
  IGRdouble      dLocal[3];
  IGRboolean     bEndVtx;
  IGRboolean     bBegVtx;
  BSrc           rc;

  struct IGRpolyline     LineIn;

SetProc(VCCable_VCCbFind); Begin

  *msg     = MSSUCC;
  dSavDist = MAXDOUBLE;
  *AdjType = VCCB_NO_ADJUST;
  *EndPos  = VC_VSPOS_INT;

#ifdef MY_DEBUG
  printf ("vrml_find, modtype %d\n",ModType);
#endif

  NumSect  = om$dimension_of (varray = me->Sect);

  dVertex  = _MALLOC (3000 ,IGRdouble);
  LineIn.points     = dVertex;
  LineIn.num_points = 0;

  for (iSect = 0; iSect < NumSect; iSect++)
  {
    nPotBeg  = VCCB_NO_ADJUST;
    nPotEnd  = VCCB_NO_ADJUST;

    /*    set up next and previous types    */
    if (iSect == 0) nPrevType = VCC_FREE_VERTEX;
    else            nPrevType = me->Sect[iSect-1].type;

    if (iSect == (NumSect-1)) nNextType = VCC_FREE_VERTEX;
    else                      nNextType = me->Sect[iSect+1].type;

    if (me->Sect[iSect].type != VCC_STRING) continue;

    iMstr   = me->Sect[iSect].strno;
    bEndVtx = FALSE;
    bBegVtx = FALSE;

#ifdef MY_DEBUG
    printf (" get polyline, sect %d, string %d\n",iSect, me->Sect[iSect].strno);
#endif

    status =
    om$send(msg    = message GRlinear.GRgetpolyline
                                (&retmsg, &md_env->md_env.matrix_type,
                                  md_env->md_env.matrix, &action, &LineIn),
      p_chanselect = &AS_to_comp,
      from         = iMstr,
      to           = iMstr);

/* KDD 3-98. Check the memory allocated. 1000 (= 3000/3) see _MALLOC above */
    if ( 1000 < LineIn.num_points) {
       vd$report_error( error = "Memory allocation error",
                        mode = 1, filename = __FILE__);
       goto wrapup;
    }

    /*C  allow ALL segments but disallow end vertices   */
    /*C  except where a break adjoins                   */
    /*C   @@@@@@@@@@@@@TBD@@@@@@@@@@@@@@@@@  */
    /*C    automatically adjust dynamic cpt or cable offset  */

    switch (ModType)
    {
      case VCCB_INS_VERTEX:    /*    scan segments, ALL allowed   */
        ibeg = 0;
        iend = LineIn.num_points - 1;
        break;

      case VCCB_MOV_VERTEX:    /*    see which ones can move ..... */
                               /*    depending on the adjoining elements
                                     and the system settings              */
        switch (nPrevType)
        {
          case VCC_FREE_VERTEX:
          case VCC_FREE_GUIDE:
          case VCC_FREE_RWAY:
          case VCC_TERM_CHILD:
          case VCC_BREAK_ON:
          case VCC_BREAK_OFF:
          default:
            ibeg = 0;
            break;

          case VCC_TERM_PARENT:
            if (VCSYSGLB_dyncpt)
            {
              ibeg = 0;
              nPotBeg = VCCB_ADJUST_DYNCPT;
            }
            else
              ibeg = 1;
            break;

          case VCC_POINT_PARENT:
          case VCC_GUIDE_PARENT:
          case VCC_RWAY_PARENT:
          case VCC_TERM_PULL:
            if (VCSYSGLB_offset)
            {
              ibeg = 0;
              nPotBeg = VCCB_ADJUST_OFFSET;
            }
            else
              ibeg = 1;
            break;
        }

        switch (nNextType)
        {
          case VCC_FREE_VERTEX:
          case VCC_FREE_GUIDE:
          case VCC_FREE_RWAY:
          case VCC_TERM_CHILD:
          case VCC_BREAK_ON:
          case VCC_BREAK_OFF:
          default:
            iend = LineIn.num_points;
            break;

          case VCC_TERM_PARENT:
            if (VCSYSGLB_dyncpt)
            {
              iend = LineIn.num_points;
              nPotEnd = VCCB_ADJUST_DYNCPT;
            }
            else
              iend = LineIn.num_points - 1;
            break;

          case VCC_POINT_PARENT:
          case VCC_GUIDE_PARENT:
          case VCC_RWAY_PARENT:
          case VCC_TERM_PULL:
            if (VCSYSGLB_offset)
            {
              iend = LineIn.num_points;
              nPotEnd = VCCB_ADJUST_OFFSET;
            }
            else
              iend = LineIn.num_points - 1;
            break;
        }
        bBegVtx = (ibeg == 0);
        bEndVtx = (iend == LineIn.num_points);
        break;

      case VCCB_DEL_VERTEX:    /*    delete vertex          */
      case VCCB_ORT_VERTEX:    /*    orthogonalize vertex   */
      default:
        switch (nPrevType)
        {
          case VCC_FREE_VERTEX:
          case VCC_FREE_GUIDE:
          case VCC_FREE_RWAY:
          case VCC_TERM_CHILD:
            ibeg = 0;
            break;

          case VCC_BREAK_ON:
          case VCC_BREAK_OFF:
            nPotBeg = VCCB_DELETE_BREAK;
            ibeg = 0;
            break;

          case VCC_TERM_PARENT:
          case VCC_POINT_PARENT:
          case VCC_GUIDE_PARENT:
          case VCC_RWAY_PARENT:
          case VCC_TERM_PULL:
          default:
            ibeg = 1;
            break;
        }

        switch (nNextType)
        {
          case VCC_FREE_VERTEX:
          case VCC_FREE_GUIDE:
          case VCC_FREE_RWAY:
          case VCC_TERM_CHILD:
            iend = LineIn.num_points;
            break;

          case VCC_BREAK_ON:
          case VCC_BREAK_OFF:
            iend = LineIn.num_points;
            nPotEnd = VCCB_DELETE_BREAK;
            break;

          case VCC_TERM_PARENT:
          case VCC_POINT_PARENT:
          case VCC_GUIDE_PARENT:
          case VCC_RWAY_PARENT:
          case VCC_TERM_PULL:
          default:
            iend = LineIn.num_points - 1;
            break;
        }
        bBegVtx = (ibeg == 0);
        bEndVtx = (iend == LineIn.num_points);
        break;

      case VCCB_MOV_SEGMENT:    /*    move segment @@@@ TBD @@@@@   */
                                /*    command not yet implemented   */
        ibeg = 0;
        iend = LineIn.num_points - 1;
        break;
    }

#ifdef MY_DEBUG
    printf (" scan line ibeg, iend %d %d\n",ibeg, iend);
#endif

    for (iVert=ibeg; iVert < iend; iVert++)
    {

      for (i=0; i<3; i++)
        dLocal[i] = dCoord[i];

      if ((ModType == VCCB_INS_VERTEX) || (ModType == VCCB_MOV_SEGMENT))
      {   /*    locate segment    */
        if (IXloc >= 0)
          dLocal[IXloc] = (LineIn.points[3*iVert+IXloc] +
                           LineIn.points[3*(iVert+1)+IXloc]) / 2.0;

        BSdptseg2 (dLocal, &LineIn.points[3*iVert],
                    &LineIn.points[3*(iVert+1)],
                    minpt, &minpar, &dDist, &rc);
      }
      else
      {   /*     locate vertex   */
        if (IXloc >= 0)
          dLocal[IXloc] = LineIn.points[3*iVert+IXloc];

        dDist = BSdistptpt(&rc, dLocal, &LineIn.points[3*iVert]);
      }

#ifdef MY_DEBUG
    printf (" scan segment/vertex ivert, ddist = %d %f\n",iVert,dDist);
#endif

      if (dDist < dSavDist)
      {
        dSavDist = dDist;
        *SecNum  = iSect;
        *VtxNum  = iVert;

        if ((iVert == ibeg) && bBegVtx)
        {
          *EndPos  = VC_VSPOS_BEG;
          *AdjType = nPotBeg;
        }
        else
        if ((iVert == (iend-1)) && bEndVtx)
        {
           *EndPos  = VC_VSPOS_END;
           *AdjType = nPotEnd;
        }
        else
        {
           *EndPos  = VC_VSPOS_INT;
           *AdjType = VCCB_NO_ADJUST;
        }

#ifdef MY_DEBUG
    printf (" during scan, adjtype %d\n",*AdjType);
#endif

        if (dDyn)
        {   /*C   if requested set up dynamics buffer   */
          switch (ModType)
          {
            case VCCB_INS_VERTEX:

              dDyn[0] = LineIn.points[3*iVert];
              dDyn[1] = LineIn.points[3*iVert+1];
              dDyn[2] = LineIn.points[3*iVert+2];

              dDyn[6] = LineIn.points[3*iVert+3];
              dDyn[7] = LineIn.points[3*iVert+4];
              dDyn[8] = LineIn.points[3*iVert+5];

              dDyn[3] = (dDyn[0] + dDyn[6]) / 2.0;
              dDyn[4] = (dDyn[1] + dDyn[7]) / 2.0;
              dDyn[5] = (dDyn[2] + dDyn[8]) / 2.0;
              break;

            case VCCB_MOV_VERTEX:
              if ((iVert == ibeg) && bBegVtx)
              {
                dDyn[0] = LineIn.points[3*iVert+3];
                dDyn[1] = LineIn.points[3*iVert+4];
                dDyn[2] = LineIn.points[3*iVert+5];
              }
              else
              {
                dDyn[0] = LineIn.points[3*iVert-3];
                dDyn[1] = LineIn.points[3*iVert-2];
                dDyn[2] = LineIn.points[3*iVert-1];
              }

              dDyn[3] = LineIn.points[3*iVert];
              dDyn[4] = LineIn.points[3*iVert+1];
              dDyn[5] = LineIn.points[3*iVert+2];

              if ((iVert == (iend-1)) && bEndVtx)
              {
                dDyn[6] = LineIn.points[3*iVert-3];
                dDyn[7] = LineIn.points[3*iVert-2];
                dDyn[8] = LineIn.points[3*iVert-1];
              }
              else
              {
                dDyn[6] = LineIn.points[3*iVert+3];
                dDyn[7] = LineIn.points[3*iVert+4];
                dDyn[8] = LineIn.points[3*iVert+5];
              }
              break;

            default:
              break;
          }
        } /*    if dDyn   */
      }   /*    if dDist  */
    }     /*    for iVert   */
  }       /*    for iSect   */

#ifdef MY_DEBUG
  printf (" FOUND sect, vert %d %d\n",*SecNum, *VtxNum);
  printf (" adjtype  %d\n",*AdjType);
#endif

wrapup:
  _FREE (dVertex);
  End;
  return (OM_S_SUCCESS);
}


/*       find coordinates given vertex and section    */

method    VCCbVertex (IGRlong        *msg;
                      IGRint          SecNum;    /*  section number         */
                      IGRint          VtxNum;    /*  vertex/segment number  */
                      IGRdouble      *dCoord;    /*  coordinates            */
              struct  GRmd_env       *md_env)
{
  IGRlong        retmsg;
  IGRint         status;
  IGRint         NumSect;
  IGRint         iVert;
  IGRint         i;
  IGRint         action = 1;
  IGRdouble     *dVertex = NULL ;

  struct IGRpolyline     LineIn;

  *msg     = MSFAIL;

  NumSect  = om$dimension_of (varray = me->Sect);

  if ((SecNum < 0) || (SecNum >= NumSect)) return (OM_E_INVARG);
  if (me->Sect[SecNum].type != VCC_STRING) return (OM_E_INVARG);

  if ((VtxNum < 0) || (VtxNum >= me->Sect[SecNum].iTo)) return (OM_E_INVARG);

  iVert    = me->Sect[SecNum].iTo + 10;    /*   safety...   */

  dVertex  = _MALLOC ((iVert*3) ,IGRdouble);
  LineIn.points     = dVertex;
  LineIn.num_points = 0;

  status =
  om$send(msg    = message GRlinear.GRgetpolyline
                                (&retmsg, &md_env->md_env.matrix_type,
                                  md_env->md_env.matrix, &action, &LineIn),
    p_chanselect = &AS_to_comp,
    from         = me->Sect[SecNum].strno,
    to           = me->Sect[SecNum].strno);
  as$status();

/* KDD 3-98. Check the memory allocated */
  if ( iVert < LineIn.num_points) {
       vd$report_error( error = "Memory allocation error",
                        mode = 1, filename = __FILE__);
       goto wrapup;
  }

  /*   return the requested vertex    */

  for (i=0; i<3; i++)
    dCoord[i] =  LineIn.points[3*VtxNum+i];

wrapup:

  *msg     = MSSUCC;
  _FREE (dVertex);
  return (status);
}

end implementation VCCable;
