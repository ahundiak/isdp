
/* $Id: VCCconsft.I,v 1.3 2002/05/08 15:48:22 anand Exp $  */

/*************************************************************************
 * I/CABLE
 *
 * File:        vccable/VCCconsft.I
 *
 * Description:
 *      ACconstruct_feet method for cables
 *
 * Dependencies:
 *
 * Revision History:
 *        $Log: VCCconsft.I,v $
 *        Revision 1.3  2002/05/08 15:48:22  anand
 *        Files added/modified for sub-cable functionality.
 *
 *        Revision 1.2  2001/02/20 01:08:47  build
 *        Replaced v_dbgmacros.h with product specific dbgmacros.h
 *
 *        Revision 1.1.1.1  2001/01/04 21:12:26  cvs
 *        Initial import to CVS
 *
# Revision 1.1  1998/04/30  10:52:34  pinnacle
# ROUTE 2.5.1
#
# Revision 1.5  1998/04/01  19:56:42  pinnacle
# Replaced: vccable/VCCconsft.I for:  by kddinov for route
#
# Revision 1.4  1998/03/14  19:49:10  pinnacle
# Replaced: vccable/VCCconsft.I for:  by kddinov for route
#
# Revision 1.3  1998/02/24  04:51:06  pinnacle
# Replaced: vccable/VCCconsft.I for:  by apazhani for route
#
# Revision 1.2  1998/02/21  18:48:06  pinnacle
# Replaced: vccable/VCCconsft.I for:  by kddinov for route
#
# Revision 1.1  1997/10/30  04:09:46  pinnacle
# Integration of Cable into 02.04.03.04
#
# Revision 1.17  1997/08/15  12:44:44  pinnacle
# Replaced: vccable/VCCconsft.I for:  by hverstee for cabling
#
# Revision 1.16  1997/07/29  14:54:38  pinnacle
# Replaced: vccable/VCCconsft.I for:  by hverstee for cabling
#
# Revision 1.15  1997/07/26  13:37:38  pinnacle
# Replaced: vccable/VCCconsft.I for:  by hverstee for cabling
#
# Revision 1.14  1997/07/22  21:39:38  pinnacle
# Replaced: vccable/VCCconsft.I for:  by hverstee for cabling
#
# Revision 1.13  1997/05/12  17:01:42  pinnacle
# Replaced: vccable/VCCconsft.I for:  by hverstee for cabling
#
# Revision 1.12  1997/05/10  14:49:20  pinnacle
# Replaced: vccable/VCCconsft.I for:  by hverstee for cabling
#
# Revision 1.11  1997/05/07  19:53:58  pinnacle
# Replaced: vccable/VCCconsft.I for:  by hverstee for cabling
#
# Revision 1.10  1997/05/06  23:10:46  pinnacle
# Replaced: vccable/VCCconsft.I for:  by hverstee for cabling
#
# Revision 1.9  1997/04/28  22:12:58  pinnacle
# Replaced: vccable/VCCconsft.I for:  by hverstee for cabling
#
# Revision 1.8  1997/03/06  22:54:14  pinnacle
# Replaced: vccable/VCCconsft.I for:  by hverstee for cabling
#
# Revision 1.7  1997/01/31  18:03:00  pinnacle
# Replaced: vccable/VCCconsft.I for:  by hverstee for cabling
#
# Revision 1.6  1997/01/16  14:37:42  pinnacle
# Replaced: vccable/VCCconsft.I for:  by hverstee for cabling
#
# Revision 1.5  1996/11/21  21:28:22  pinnacle
# Replaced: vccable/VCCconsft.I for:  by hverstee for cabling
#
# Revision 1.4  1996/11/15  19:17:16  pinnacle
# Replaced: vccable/VCCconsft.I for:  by hverstee for cabling
#
# Revision 1.3  1996/11/12  15:39:22  pinnacle
# Replaced: vccable/VCCconsft.I for:  by hverstee for cabling
#
# Revision 1.2  1996/10/09  21:50:56  pinnacle
# Replaced: vccable/VCCconsft.I for:  by hverstee for cabling
#
# Revision 1.1  1996/08/28  21:47:32  pinnacle
# Created: vccable/VCCconsft.I by hverstee for cabling
#
 *
 * History:
 *        06/29/96        hv        Initial
 *        02/24/98        Alwin     Set the Section type properly when dealing
 *				    about the VCC_STRING type section. This's
 *				    leading to unpredictable results.
 *
 *************************************************************************/

class implementation VCCable;

/*
#define vdsDEBUG        1
#define MY_DEBUG      1
*/

#include "VDmem.h"
#include "vrdbgmacros.h"


extern     GRclassid     OPP_GR3dlinestr_class_id;


/*C recompute the cable */

method ACconstruct_feet(  IGRlong    *msg; 
                          IGRint      cn_type;
                          IGRint      count;
                   struct GRid        list []; 
                   struct GRmd_env   *md_env;
                          int        *fcount; 
                   struct GRid       *FeetList )
{
  IGRint             action,status;
  IGRshort           IsectIn;
  IGRint             IsectOt;
  IGRint             NumFeet;
  IGRint             OldFeet;
  IGRint             NumTube;
  IGRint             NumSect;
  IGRint             NumBrk;
  IGRint             TotVtx;
  IGRint             TotBrk;
  IGRint             i;
  IGRint             iExOff;
  IGRint             iB, iE;
  IGRlong            retmsg;
  IGRint             ParentI;
  IGRint             nBend;
  IGRint             iBend;
  IGRint             lSTR;
  IGRboolean         bCSet;

  IGRshort           nTP, nPT, nNT;

  IGRdouble         *dOldVertex;
  IGRdouble         *dNewVertex;

  IGRdouble          dCIN[3];
  IGRdouble          dVIN[3];
  IGRdouble          dCOT[3];
  IGRdouble          dVOT[3];

  IGRboolean         bFbeg, bFend;

  struct GRvg_construct  cnst_lis;
  struct IGRpolyline     LineIn;
  struct IGRpolyline     LineOt;
  struct GRsymbology     Symb;
  struct VCCL_sectmap   *pNewSect;
  struct GRid           *TubeList;
  struct GRid           *BrkList;

  /*A  the list[] has to contain the following objects:
    [0] : SYstem Attributes Collection
    [1] : User Attributes Collection
    [2] : start connector (if present)
    [3->(N-1)] : intermediate parents (points and guides)
    [N] : end connector  (if present)      */

  SetProc( VCCable_ACconstruct_feet ); Begin 

  /*A total number of parents should tally */
  if ( ( count < ( me->nVCTopo+me->nVCAttr ) )  ) 
  {
    struct GRid          *PrBuf;
    IGRint                NbBuf;

#ifdef MY_DEBUG
    printf ("Internal inconsistency in cable, count, topo, attr  %d %d %d\n",
                    count, me->nVCTopo, me->nVCAttr);

#endif
    /*      see what the real current number of links is   */

    status =
    om$send( msg = message NDnode.NDget_objects
                        ((ND_ROOT | ND_IN_BUF), NULL, 0, &PrBuf, 0,
                           OM_K_MAXINT, &NbBuf ),
        targetid = my_id);

    if (NbBuf != count)
    {
      /*      @@@@@@TBD@@@@@ rectify with real parents list           */
      /*   Obviously something went seriously wrong in the assoc
           system, force more recomputes to see if it clears itself   */

      printf (" Cable object internally corrupted\n");

      *msg = MSFAIL;
      return OM_E_ABORT;
    }
    else
    {
      me->nVCTopo = count - me->nVCAttr;
    }
  }

  /*A initialization */
  *msg    = MSSUCC;
  *fcount = 0;
  action  = 1;

  dOldVertex = NULL;
  dNewVertex = NULL;

  pNewSect = NULL;
  TubeList = NULL;
  BrkList  = NULL;
  nBend    = om$dimension_of (varray = me->Bend);

#ifdef MY_DEBUG
  printf ("count, topo, attr  %d %d %d\n",count, me->nVCTopo, me->nVCAttr);
  for (i=0; i<count; i++)
    printf (" Input List %d <%d %d>\n",i,list[i].objid,list[i].osnum);
#endif

  status =
  om$send( msg = message GRvg.GRgetsymb (&retmsg,&Symb),
      targetid = my_id);
  as$status ( action = RET_STATUS );

  /*A Set up constructionlist   */
  cnst_lis.msg          = &retmsg;
  cnst_lis.env_info     = md_env;
  cnst_lis.newflag      = FALSE;
  cnst_lis.properties   = GRIS_NEW | GRIS_LOCATABLE | GRIS_DISPLAYABLE;
  cnst_lis.level        = Symb.level;
  cnst_lis.display      = &(Symb.display_attr);

  cnst_lis.class_attr   = NULL;
  cnst_lis.name         = NULL;
  cnst_lis.geometry     = (IGRchar *)&LineOt;

  /*A Allocate temp memory  */
  NumSect  = om$dimension_of (varray = me->Sect);
  __DBGpr_int( " Nb of Sections ", NumSect );

  TotVtx  = 0;
  TotBrk  = 0;

  ParentI = 0;

  for (i=0; i<NumSect; i++)
  {
    
    if (me->Sect[i].type == VCC_STRING)
      TotVtx += me->Sect[i].iTo - me->Sect[i].iFrom;

    if ((me->Sect[i].type == VCC_BREAK_ON) ||
        (me->Sect[i].type == VCC_BREAK_OFF))      TotBrk++;

#ifdef vdsDEBUG
    printf (" sectmap in %d %d %d %d %d %d\n",me->Sect[i].type,
                                           me->Sect[i].iFrom,
                                           me->Sect[i].iTo,
                                           me->Sect[i].parno,
                                           me->Sect[i].strno,
                                           me->Sect[i].numvert);
#endif

    if (me->Sect[i].parno >= 0)
    {
      if (me->Sect[i].parno != ParentI)
      {
        /* Putting this printf statement in the ifdef, b'cas almost for
        every recompute say if one of the parent is deleted/detached these
        we end up in parent count mismatch. This parent count mismatch is
        b'cas in the instance data mayn't have correct some times, though
        there in no harm. Commenting this, since this disturbs the user
        saying something is wrong. Alwin */
#ifdef vdsDEBUG
        printf ("Internal Error: corrected parent pointer\n");
#endif 
      }

      me->Sect[i].parno = ParentI;
      ParentI++;
    }
  }

  TotVtx += 2;    /*    for safety   */

  dOldVertex = _MALLOC ((3 * TotVtx), IGRdouble);
  dNewVertex = _MALLOC ((3 * TotVtx), IGRdouble);
  TubeList   = _MALLOC (NumSect, struct GRid);
  pNewSect   = _MALLOC (NumSect, struct VCCL_sectmap);

  if (TotBrk > 0) BrkList = _MALLOC (TotBrk, struct GRid);

  IsectIn = 0;
  IsectOt = 0;
  NumFeet = 0;
  NumTube = 0;
  NumBrk  = 0;
  OldFeet = 0;
  bCSet   = FALSE;

  LineOt.num_points = 0;
  LineIn.num_points = 0;
  LineIn.points     = dOldVertex;
  LineOt.points     = dNewVertex;

  /*A Recompute the string sections */
  /*C Get the number of string sections first  */

  nPT    = -1;
  iExOff = 0;
  lSTR   = -1;

  while (IsectIn < NumSect)
  {

    nTP = me->Sect[IsectIn].type;

    if (IsectIn < (NumSect-1)) nNT = me->Sect[IsectIn+1].type;
    else                       nNT = -1;

    ParentI = me->Sect[IsectIn].parno + me->nVCAttr;

#ifdef MY_DEBUG
    printf (" section %d type %d\n",IsectIn,me->Sect[IsectIn].type);
    printf (" -- %d %d %d %d --\n",me->Sect[IsectIn].iFrom,
                                   me->Sect[IsectIn].iTo,
                                   me->Sect[IsectIn].strno,
                                   me->Sect[IsectIn].parno);
#endif


    /* @@@@@@@@@@@@@@@@@@@@@@@@   TBD   @@@@@@@@@@@@@@@@@@@@@@@@@@@@ */

    /* The current recompute has one serious flaw, because each
       attachment triggers a new string section and thus a new string
       the 3d display WILL NOT use a rounded bend at the attachment
       of a placed point. It will be necessary to at one point
       rewrite the logic such that an attached point will merely be
       a controlled vertex inside a string.                            */

    switch (nTP)
    {

      /**********************************************************************/
      /*    FREE entities, bypass and thus remove from sectmap              */

      default:               /* possible garbage entry, bypass              */
      case VCC_FREE_VERTEX:  /* continue in adjoining dispstring            */
        IsectIn++;
        nPT = VCC_STRING;
        iExOff = 0;
        break;

      case VCC_FREE_GUIDE:  /* freed entities, has to be between displayed  */
      case VCC_FREE_RWAY:   /* freed entities, has to be between displayed  */
        IsectIn++;
        nPT = VCC_STRING;
        iExOff = 0;
        break;

      /**********************************************************************/
      /*    DEPENDANT entities, copy without affecting others               */

      case VCC_TERM_CHILD:
        pNewSect[IsectOt] = me->Sect[IsectIn];
        IsectIn++;
        IsectOt++;
        nPT = nTP;
        iExOff = 0;
        break;

      /**********************************************************************/

      case VCC_BREAK_ON:
        /*  close off current string and section record   */
        if (nPT == VCC_STRING)
        {
          IGRdouble    *pO, *pV;
          IGRdouble    dRES[3];
          IGRint       nBR;

            /*A construct the polyline */

          FeetList[NumFeet].objid = NULL_OBJID;
          FeetList[NumFeet].osnum = md_env->md_id.osnum;

#ifdef MY_DEBUG
          for (i=0; i<LineOt.num_points; i++)
            printf (" vertices out (before break) %d %f %f %f\n",i,
                         dNewVertex[i*3],
                         dNewVertex[i*3+1],
                         dNewVertex[i*3+2]);
#endif
          status =
          om$construct (classid = OPP_GR3dlinestr_class_id,
                        p_objid = &FeetList[NumFeet].objid,
                        msg     = message GRgraphics.GRaltconstruct(&cnst_lis));
          as$status(action = GOTO_VALUE, value = NO_GRAPHIC );

#ifdef MY_DEBUG
          printf (" closed string foot %d\n",NumFeet);
#endif
          nBR = LineOt.num_points - 1;

          LineOt.num_points = 0;
          NumFeet++;
          IsectOt++;

          /*   at end of string, place break     */

          pO = &dNewVertex[nBR*3];

          if (nBR > 0)
            pV = &dNewVertex[(nBR-1)*3];
          else
          {
            dRES[0] = dNewVertex[(LineOt.num_points-1)*3] + 1.0;
            dRES[1] = dNewVertex[(LineOt.num_points-1)*3 + 1];
            dRES[2] = dNewVertex[(LineOt.num_points-1)*3 + 2];

            pV = dRES;
          }

          status = 
          om$send (msg = message VCCable.VCCbPlaceBreak
                                 (&retmsg, pO, pV, &NumBrk,&BrkList[NumBrk],
                                  &cnst_lis, md_env),
              targetid = my_id);
        }

        pNewSect[IsectOt] = me->Sect[IsectIn];
        IsectIn++;
        IsectOt++;
        nPT = VCC_BREAK_ON;
        iExOff = 0;
        break;

      case VCC_BREAK_OFF:
        pNewSect[IsectOt] = me->Sect[IsectIn];
        IsectIn++;
        IsectOt++;
        nPT = VCC_BREAK_OFF;
        iExOff = 0;
        break;

      /**********************************************************************/
      /*    LINESTRING,  add to output buffer                               */

      case VCC_STRING:
        /*C Get geometry */

        lSTR = IsectOt;
        /* added by alwin, for TR179802183 & TR179701648. Set the Section type
        correctly otherwise, these kind of TRs may arise. */
 
        pNewSect[IsectOt].type = VCC_STRING;
        pNewSect[IsectOt].iFrom = 0;
        /* Intialize the from index, which is most of the time is zero */

        status =
        om$send(msg = message VCCable.VCCbLdLine
                                (&retmsg, me->Sect[IsectIn].strno,
                                 &LineIn, md_env),
           targetid = my_id);

        if (!(retmsg & MSSUCC)) goto NO_GRAPHIC;

        /* place break at begin .......    */
        if (nPT == VCC_BREAK_OFF)
        {
          IGRint         iX;
          IGRdouble     *pO, *pV;

          iX = me->Sect[IsectIn].iFrom;

          pO = &LineIn.points[iX*3];
          pV = &LineIn.points[(iX+1)*3];

#ifdef MY_DEBUG
          printf (" Opening break before new string\n");
#endif
          status =
          om$send (msg = message VCCable.VCCbPlaceBreak
                                 (&retmsg, pO, pV, &NumBrk, &BrkList[NumBrk],
                                  &cnst_lis, md_env),
              targetid = my_id);

          pNewSect[IsectOt]           = me->Sect[IsectIn];
          pNewSect[IsectOt].iFrom     = LineOt.num_points;
        }

        if (nPT == -1) /*   starting in space     */
        {
          pNewSect[IsectOt]           = me->Sect[IsectIn];
          pNewSect[IsectOt].iFrom     = LineOt.num_points;
        }

        iB = me->Sect[IsectIn].iFrom + iExOff;

        if ((nNT == VCC_TERM_PARENT)  ||
            (nNT == VCC_POINT_PARENT) ||
            (nNT == VCC_GUIDE_PARENT) ||
            (nNT == VCC_RWAY_PARENT)  ||
            (nNT == VCC_TERM_PULL)    ||
 /* Added below two OR conditions for split functionality - Anand */
	    (nNT == VCC_SPLIT_BEGIN)  ||
	    (nNT == VCC_SPLIT_END))            iE = me->Sect[IsectIn].iTo - 1;
        else                                   iE = me->Sect[IsectIn].iTo;

        for (i=iB; i<=iE; i++)
        {
#ifdef MY_DEBUG
          printf (" vertex %d to string %d\n",i,LineOt.num_points);
          printf (" vertexpt %f %f %f\n",LineIn.points[i*3],
                     LineIn.points[i*3+1],LineIn.points[i*3+2]);
#endif
          VCC_addcoord (dNewVertex, &LineOt.num_points, &LineIn.points[i*3]);

          /*   update the bend table.......   */

          for (iBend = 0; iBend < nBend; iBend++)
          {
            if ((me->Bend[iBend].secno == IsectIn) &&
                (me->Bend[iBend].vtxno == i))
            {
              me->Bend[iBend].secno = IsectOt;
              me->Bend[iBend].vtxno = LineOt.num_points -1;
              break;
            }
          }
        }

        pNewSect[IsectOt].iTo       = LineOt.num_points - 1;
        pNewSect[IsectOt].numvert   = pNewSect[IsectOt].iTo -
                                        pNewSect[IsectOt].iFrom + 1;
        pNewSect[IsectOt].strno     = NumFeet;
        pNewSect[IsectOt].parno     = -1;
        IsectIn++;
        nPT = nTP;
        break;

      /**********************************************************************/
      /*    POINTPARENT, add as fixed point in linestring                   */
      /*    Separate points, when string continues (add later)              */

      /*    See also TBD note above                                         */

      case 9999:                  /*   dummy for now   */
        status =
        om$send (msg = message VCCable.VCCbparcor
                     (&retmsg, IsectIn, &list[ParentI],
                      dCIN, NULL, &bFbeg, NULL, NULL, &bFend, md_env ),
            targetid = my_id);
        as$status();

#ifdef MY_DEBUG
        printf (" coords set %f %f %f\n",dCIN[0],
                            dCIN[1], dCIN[2]);
#endif
        /*  Add to current string and continue    */

        VCC_addcoord (dNewVertex, &LineOt.num_points, dCIN);
        pNewSect[IsectOt].iTo       = LineOt.num_points - 1;
        pNewSect[IsectOt].numvert   = pNewSect[IsectOt].iTo -
                                        pNewSect[IsectOt].iFrom + 1;
        IsectOt++;

        pNewSect[IsectOt]           = me->Sect[IsectIn];

        pNewSect[IsectOt].parno     = ParentI - me->nVCAttr;
        IsectIn++;
        IsectOt++;

        /*  Continue in next string   */

        if (nNT == VCC_STRING)
        {
          pNewSect[IsectOt].type      = VCC_STRING;
          pNewSect[IsectOt].iFrom     = LineOt.num_points -1;
          pNewSect[IsectOt].strno     = NumFeet;
          pNewSect[IsectOt].parno     = -1;
        }


        nPT = VCC_STRING;
        iExOff = 1;
        break;

      /**********************************************************************/
      /*    CONTROLLING PARENT, close linestring first if present           */

      case VCC_POINT_PARENT:

      case VCC_TERM_PULL:
      case VCC_TERM_PARENT:
      case VCC_GUIDE_PARENT:
      case VCC_RWAY_PARENT:
	/* Below two case statements added for split functionality - Anand */
      case VCC_SPLIT_BEGIN:
      case VCC_SPLIT_END:

        /* add begin/endvertex to dispstring if present and store it */
        /* if necessary (end)                                        */

	__DBGpr_com( " Get the Parent Co-ordinates " );
        status =
        om$send (msg = message VCCable.VCCbparcor
                     (&retmsg, IsectIn, &list[ParentI],
                      dCIN, dVIN, &bFbeg, dCOT, dVOT, &bFend, md_env ),
            targetid = my_id);
        as$status();

#ifdef MY_DEBUG
        printf (" CONTROL %d set %f %f %f\n",LineOt.num_points,
                              dCIN[0], dCIN[1], dCIN[2]);
#endif
        /*  close off current string and section record   */
        if (nPT == VCC_STRING)
        {
          VCC_addcoord (dNewVertex, &LineOt.num_points, dCIN);

          pNewSect[IsectOt].iTo       = LineOt.num_points - 1;
          pNewSect[IsectOt].numvert   = pNewSect[IsectOt].iTo -
                                          pNewSect[IsectOt].iFrom + 1;
            /*A construct the polyline */

          FeetList[NumFeet].objid = NULL_OBJID;
          FeetList[NumFeet].osnum = md_env->md_id.osnum;

#ifdef MY_DEBUG
          for (i=0; i<LineOt.num_points; i++)
            printf (" vertices out (before parent) %f %f %f\n",
                         dNewVertex[i*3],
                         dNewVertex[i*3+1],
                         dNewVertex[i*3+2]);
#endif
          status =
          om$construct (classid = OPP_GR3dlinestr_class_id,
                        p_objid = &FeetList[NumFeet].objid,
                        msg     = message GRgraphics.GRaltconstruct(&cnst_lis));
          as$status(action = GOTO_VALUE, value = NO_GRAPHIC );

#ifdef MY_DEBUG
          printf (" closed string foot %d\n",NumFeet);
#endif
          LineOt.num_points = 0;
          NumFeet++;
          IsectOt++;
        }

        pNewSect[IsectOt]           = me->Sect[IsectIn];

        pNewSect[IsectOt].parno     = ParentI - me->nVCAttr;
        IsectIn++;
        IsectOt++;

        /*  if this controller is followed by another entry , force a
            connecting linestring,
            EXCEPT when one raceway part follows another      */

        if ((nNT != -1) && ((nNT != nTP) || (nTP != VCC_RWAY_PARENT)))
        {
          pNewSect[IsectOt].type      = VCC_STRING;
          pNewSect[IsectOt].iFrom     = LineOt.num_points;

          VCC_addcoord (dNewVertex, &LineOt.num_points, dCOT);

          pNewSect[IsectOt].iTo       = LineOt.num_points;
          pNewSect[IsectOt].numvert   = pNewSect[IsectOt].iTo -
                                        pNewSect[IsectOt].iFrom + 1;
          pNewSect[IsectOt].strno     = NumFeet;
          pNewSect[IsectOt].parno     = -1;
          iExOff = 1;

#ifdef MY_DEBUG
          printf (" Forced next string %d\n",IsectOt);
#endif
        }

        nPT = nTP;
        break;
    }
  }

  /*  close off last pending string and section record   */
  if (LineOt.num_points > 1)
  {
      /*A construct the polyline */

    FeetList[NumFeet].objid = NULL_OBJID;
    FeetList[NumFeet].osnum = md_env->md_id.osnum;

#ifdef MY_DEBUG
    for (i=0; i<LineOt.num_points; i++)
      printf (" vertices out (before line end) %f %f %f\n",
                   dNewVertex[i*3],
                   dNewVertex[i*3+1],
                   dNewVertex[i*3+2]);
#endif
    status =
    om$construct (classid = OPP_GR3dlinestr_class_id,
                  p_objid = &FeetList[NumFeet].objid,
                  msg     = message GRgraphics.GRaltconstruct(&cnst_lis));
    as$status(action = GOTO_VALUE, value = NO_GRAPHIC );

    __DBGpr_int( " Nb of Feet ", NumFeet );

    LineOt.num_points = 0;
    NumFeet++;
    IsectOt++;
  }

  /*C   resize variable arrays    */

  __DBGpr_com( " Re-Setting the Instance info " );
  status =
  om$vla_set_dimension(   varray  = me->Sect,
                          size    = IsectOt);
  as$status();

  for (i=0; i<IsectOt; i++)
    me->Sect[i] = pNewSect[i];

#ifdef vdsDEBUG
  for (i=0; i<IsectOt; i++)
    printf (" sectmap out %d %d %d %d %d %d\n",me->Sect[i].type,
                                           me->Sect[i].iFrom,
                                           me->Sect[i].iTo,
                                           me->Sect[i].parno,
                                           me->Sect[i].strno,
                                           me->Sect[i].numvert);
#endif

  /*A In 3D, Build the tubes */

  NumTube = 0;

  if (!(bVC_IS_2D(me->xform_chan)))
  {
    status =
    om$send (msg = message VCCable.VCCbTube
                               (&retmsg, NumFeet, FeetList,
                                &NumTube, TubeList,
                                &cnst_lis, md_env),
        targetid = my_id);
    as$status();
  }

#ifdef MY_DEBUG
  printf (" strings %d tubes %d breaks %d\n", NumFeet, NumTube, NumBrk);
#endif
  /*   add breakpoints to feet array   */

  for (i=0;i<NumBrk; i++)
  {
    FeetList[NumFeet] = BrkList[i];
    NumFeet++;
  }

  /*  add tubes to feet array   */

  for (i=0;i<NumTube; i++)
  {
    FeetList[NumFeet] = TubeList[i];
    NumFeet++;
  }

  *fcount = NumFeet;

  _FREE (dOldVertex);
  _FREE (dNewVertex);
  _FREE (TubeList);
  _FREE (pNewSect);
  _FREE (BrkList);

#ifdef MY_DEBUG
  printf (" number of feet %d\n", *fcount);
#endif

  End
  return OM_S_SUCCESS ;

NO_GRAPHIC :    /*A        CONSTRUCTION FAILED          */
                /*A delete all created graphics objects */

  for (i=0;i<NumFeet; i++)
  {
    status =
    om$send(  msg   = message Root.delete(1),
           targetid = FeetList[i].objid,
           senderid = NULL_OBJID );
  }

  for (i=0;i<NumBrk; i++)
  {
    status =
    om$send(  msg   = message Root.delete(1),
           targetid = BrkList[i].objid,
           senderid = NULL_OBJID );
  }

  for (i=0;i<NumTube; i++)
  {
    status =
    om$send(  msg   = message Root.delete(1),
           targetid = TubeList[i].objid,
           senderid = NULL_OBJID );
  }

  *fcount = 0;

  _FREE (dOldVertex);
  _FREE (dNewVertex);
  _FREE (TubeList);
  _FREE (pNewSect);
  _FREE (BrkList);

  __DBGpr_com( " Something failed " );
  End
  return OM_E_ABORT;
}/* end ACconstruct_feet */

end implementation VCCable;

