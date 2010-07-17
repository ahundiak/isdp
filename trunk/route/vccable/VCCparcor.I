
/* $Id: VCCparcor.I,v 1.3 2002/05/08 15:48:22 anand Exp $  */

/*************************************************************************
 * I/CABLE
 *
 * File:        vccable/VCCparcor.I
 *
 * Description:
 *      method to define cable coordinates at Attachments
 *
 * Dependencies:
 *
 * Revision History:
 *        $Log: VCCparcor.I,v $
 *        Revision 1.3  2002/05/08 15:48:22  anand
 *        Files added/modified for sub-cable functionality.
 *
 *        Revision 1.2  2001/02/20 01:08:58  build
 *        Replaced v_dbgmacros.h with product specific dbgmacros.h
 *
 *        Revision 1.1.1.1  2001/01/04 21:12:26  cvs
 *        Initial import to CVS
 *
# Revision 1.2  1998/06/05  13:06:48  pinnacle
# TR179801108
#
# Revision 1.1  1998/04/30  10:52:34  pinnacle
# ROUTE 2.5.1
#
# Revision 1.5  1998/04/03  22:00:58  pinnacle
# Replaced: vccable/VCCparcor.I for:  by kddinov for route
#
# Revision 1.4  1998/04/01  19:48:30  pinnacle
# Replaced: vccable/VCCparcor.I for:  by kddinov for route
#
# Revision 1.3  1998/03/31  07:10:18  pinnacle
# Replaced: vccable/VCCparcor.I for: TR 179800045 by aharihar for route
#
# Revision 1.2  1998/03/12  10:15:58  pinnacle
# Replaced: vccable/VCCparcor.I for: TR179800045 by aharihar for route
#
# Revision 1.1  1997/10/30  04:09:46  pinnacle
# Integration of Cable into 02.04.03.04
#
# Revision 1.4  1997/04/28  22:14:10  pinnacle
# Replaced: vccable/VCCparcor.I for:  by hverstee for cabling
#
# Revision 1.3  1997/01/31  18:01:52  pinnacle
# Replaced: vccable/VCCparcor.I for:  by hverstee for cabling
#
# Revision 1.2  1997/01/20  20:49:02  pinnacle
# Replaced: vccable/VCCparcor.I for:  by hverstee for cabling
#
# Revision 1.1  1997/01/16  14:37:20  pinnacle
# Created: vccable/VCCparcor.I by hverstee for cabling
#
 *
 * History:
 * 06/29/96  hv      Initial
 * 03/12/98  Anand   For the case of terminal as parent, the
 *		     connect point was obtained from the cable
 *		     itself (thru the new method VCCGetOffset)
 * 04/xx/98  KDD     VCCGetOffset return to 2 arguments
 * 06/01/98  ah      TR179801108 Coredumping when terminals recompute
 *************************************************************************/

class implementation VCCable;

#include "VDmem.h"
#include "vrdbgmacros.h"
#include "VCstructs2.h"

/*
#define vdsDEBUG        1
#define MY_DEBUG      1
*/

from   VRGeneric  import   VRGetCptGeom;



/*C recompute the cable */

method VCCbparcor (IGRlong    *msg; 
                   IGRshort    secno;
            struct GRid       *ParId;
                   IGRdouble  *Cin;
                   IGRdouble  *Vin;
                   IGRboolean *bIFree;
                   IGRdouble  *Cout;
                   IGRdouble  *Vout;
                   IGRboolean *bOFree;
            struct GRmd_env   *md_env)
{
  IGRlong            retmsg;
  IGRint             status;
  IGRint             Isectype;
  IGRint             NumSect;
  IGRshort           iendnum;
  IGRshort           nPar;
  IGRboolean         bIF;
  IGRboolean         bOF;

  IGRdouble          dCIN[3];
  IGRdouble          dVIN[3];
  IGRdouble          dCOT[3];
  IGRdouble          dVOT[3];

  IGRint             i;

  struct GRid        RealId;
  struct ret_struct  VertexSt;
  struct GRmd_env    alt_env;
 
  IGRshort           nConPt;
  IGRshort           NoOffsets=0;
  IGRdouble          *dOffSetVec = NULL;  // TR179801108, Init added
  IGRdouble          dRefMatrix[16];
 
  SetProc( VCCable_VCCbParCor ); Begin 

  /*A initialization */
  *msg    = MSFAIL;
  iendnum = 0;

  NumSect  = om$dimension_of (varray = me->Sect);

  if ((secno < 0) || (secno >= NumSect))
  {
    __DBGpr_com(" invalid no of sections");
    End
    return OM_S_SUCCESS;
  }

  Isectype = me->Sect[secno].type;
  nPar     = me->Sect[secno].parno;

  if ((Isectype == VCC_FREE_VERTEX) ||
      (Isectype == VCC_FREE_GUIDE)  ||
      (Isectype == VCC_FREE_RWAY)   ||
      (Isectype == VCC_TERM_CHILD)  ||
      (Isectype == VCC_STRING))           return OM_S_SUCCESS;

  *msg    = MSSUCC;

  bIF     = bOF = TRUE;

  alt_env = *md_env;

  status =
  om$send (msg = message VCRoot.VCParent (&retmsg, nPar, &RealId, &alt_env),
      targetid = my_id);
  __DBGpr_obj(" Real id as returned by vcparent",RealId);

  if (ParId != NULL) *ParId = RealId;

  switch (Isectype)
  {
    case VCC_TERM_PARENT:
      iendnum = me->Sect[secno].iFrom;

/* Following lines added by Anand for TR179800045 */

      {
	  void *Temp = NULL ;
	  IGRshort OffsetType=0;

	  status =
	  om$send( msg      = message VCCable.VCCGetOffset( &Temp, &NoOffsets),
	           targetid = my_id );

	  __DBGpr_int(" NoOffsets",NoOffsets);
	  __DBGpr_int(" OffsetType",OffsetType);

	  /* ----------------------------------------------------------
	   * TR179801108 In the test cases, NoOffsets being returned as zero
	   * don't know why at this point however this prevents dOffSetVec from
	   * being allocated resulting in later core dump
	   */
	  if( NoOffsets )
	  {
	      switch(OffsetType)
	      {
		  case 0:
		  {
		    struct VCOffset *TEMP;
		    TEMP = (struct VCOffset *) Temp;

		    for( i=0 ; i < NoOffsets ; i=i+1 )
		    {
			__DBGpr_int(" Offset Index ",(TEMP+i)->Index);
			__DBGpr_vec(" Offset vector",(TEMP+i)->Offset);
		    }

		    dOffSetVec = _CALLOC( 3*NoOffsets , IGRdouble );
		    __DBGpr_com(" Going to retrieve offsets");

		    for( i=0 ; i < NoOffsets ; i=i+1 )
		    {
			  *(dOffSetVec+3*i+0) = (TEMP+i)->Offset[0];
			  *(dOffSetVec+3*i+1) = (TEMP+i)->Offset[1];
			  *(dOffSetVec+3*i+2) = (TEMP+i)->Offset[2];
			  __DBGpr_vec(" Offset vector",(dOffSetVec+3*i));
			  __DBGpr_int(" Offset Index",(TEMP+i)->Index);
		    }

		    _FREE( TEMP );
		    break;
		  }

	    /* For modification beyond release 2.5 */
    /*
		  case 1:
		  {
		    struct VCOffsetXXX *TEMP;

		    TEMP = (struct VCOffsetXXX *) *Temp;
		    for( i=0 ; i < NoOffsets ; i=i+1 )
			(dOffSetVec+3*i) = TEMP[i].Offset;

		    break;
		  }	
    */
		  default:
		    return( OM_E_ABORT );

	      } /* End of switch statement */
	  } /* End of if condition */
      }

      /* Allow case statement to fall through (no break). - Anand */

    case VCC_TERM_PULL:

      status = om$send( msg = message VCRoot.VCGetMatrix( &retmsg , -1,
                                                          dRefMatrix, &alt_env),
                   targetid = RealId.objid,
                   targetos = RealId.osnum);
      __DBGpr_mat(" Matrix of terminal",dRefMatrix);
 
      status = om$send ( msg = message VCCable.VCGetCptOnTerm( &retmsg,
                                                            &RealId,
                                                            &nConPt ),
                    targetid = my_id);
      __DBGpr_int(" cable index at terminal", nConPt);
 
      /* Note: The following if-else loop may need to be extended when number
               of terminal parents can become more than two */
 
      /* -------------------------------------------------------
       * TR179801108 As noted above, dOffSetVec was not always being
       * allocated resulting in a core dump, for the fix just use 0
       * for the offset vector
       */
      if( dOffSetVec==NULL || Isectype==VCC_TERM_PULL ) {
        dCIN[0] = dRefMatrix[3];
        dCIN[1] = dRefMatrix[7];
        dCIN[2] = dRefMatrix[11];
      }
      else {
	
	if( nConPt == 0 )
	{
	  dCIN[0] = dRefMatrix[3]  + *(dOffSetVec+0);
	  dCIN[1] = dRefMatrix[7]  + *(dOffSetVec+1);
	  dCIN[2] = dRefMatrix[11] + *(dOffSetVec+2);
	}
	else if( nConPt == 1 ) /* The coordinate of the "other end" vertex */
	{
	  IGRshort LastVertexIndex = (NoOffsets-1)*3;
	  
	  dCIN[0] = dRefMatrix[3]  + *(dOffSetVec+LastVertexIndex+0);
	  dCIN[1] = dRefMatrix[7]  + *(dOffSetVec+LastVertexIndex+1);
	  dCIN[2] = dRefMatrix[11] + *(dOffSetVec+LastVertexIndex+2);
	}
      }
      
      __DBGpr_vec(" coordinates of end point of cable (FINAL)",dCIN );
 
      _FREE( dOffSetVec );
 
/* Above lines added by Anand for TR179800045 */

#ifdef UNCOMMENTED

/* Commented by Anand for TR179800045. The connect point geometry can now be
   obtained from the cable itself, based on the offset information (that is
   stored in its instance) and the terminal's location */

      status =
      om$send (msg = message VCRoot.VCGetCptGeom
                   (&retmsg, iendnum, dCIN, dVIN,NULL, &bIF, &alt_env ),
          targetid = RealId.objid,
          targetos = RealId.osnum);
      as$status();

      bOF = bIF;
#endif

      for (i=0; i<3; i++)
      {
        dCOT[i] = dCIN[i];
/*        dVOT[i] = dVIN[i]; -> Commented by Anand for TR179800045 */
      }
      break;

    case VCC_POINT_PARENT:
      /*C Get parent's description */
      status =
      om$send (msg = message NDnode.NDgive_structure
                                        (&retmsg, &VertexSt, &alt_env),
          targetid = RealId.objid,
          targetos = RealId.osnum);
      as$status();

      if (VertexSt.type & point_generic)
      {   /*C point's coordinates */
        for (i=0; i<3; i++)
        {
          dCOT[i] = dCIN[i] = VertexSt.var.point_st.pt[i];
          dVOT[i] = dVIN[i] = 0.0;
        }
      }
      else
      if (VertexSt.type & ref_generic)
      {   /*C origin of the cs */
        for (i=0; i<3; i++)
        {
          dCOT[i] = dCIN[i] = VertexSt.var.ref_st.t[i*4 + 3];
          dVOT[i] = dVIN[i] = VertexSt.var.ref_st.t[i*4];;
        }

        bIF = bOF = FALSE;
      }
      else
      if (VertexSt.type & macro_generic)
      {   /*C Get from a complex object its foot "ref" */
        IGRint             Index = -1;

        status =
        om$send (msg = message NDmacro.ACgive_structure
                ((IGRint *) &retmsg, &Index, VC_N_REF_CS, &VertexSt, &alt_env ),
            targetid = RealId.objid,
            targetos = RealId.osnum);
        as$status();

        for (i=0; i<3; i++)
        {
          dCOT[i] = dCIN[i] = VertexSt.var.ref_st.t[i*4 + 3];
          dVOT[i] = dVIN[i] = VertexSt.var.ref_st.t[i*4];;
        }

        bIF = bOF = FALSE;
      }
      else
      {   /*C What kind of point source ???? */
        printf ("Unknown type of pointparent, Index %d\n",nPar);
        *msg = MSFAIL;
        return OM_E_ABORT;
      }
      break;

    case VCC_GUIDE_PARENT:

      iendnum = (me->Sect[secno].iFrom < me->Sect[secno].iTo) ? 0 : 1;

      status =
      om$send (msg = message VCRoot.VCGetCptGeom
                  (&retmsg, iendnum, dCIN, dVIN, NULL, &bIF, &alt_env ),
          targetid = RealId.objid,
          targetos = RealId.osnum);
      as$status();

#ifdef vdsDEBUG
      printf (" enter conduit at %d end %f %f %f\n",iendnum,dCIN[0],
                            dCIN[1], dCIN[2]);
#endif

      /*A   set the exit coordinates   */
      iendnum = 1 - iendnum;

      status =
      om$send (msg = message VCRoot.VCGetCptGeom
                  (&retmsg, iendnum, dCOT, dVOT, NULL, &bOF, &alt_env ),
          targetid = RealId.objid,
          targetos = RealId.osnum);
      as$status();

#ifdef vdsDEBUG
      printf (" exit conduit at %d end %f %f %f\n",iendnum,dCOT[0],
                            dCOT[1], dCOT[2]);
#endif
      break;

    case VCC_RWAY_PARENT:

      iendnum = me->Sect[secno].iFrom;

      status = 
      om$send (msg = message VRGeneric.VRGetCptGeom
                  (&retmsg, iendnum, dCIN, dVIN, NULL, &alt_env ),
          targetid = RealId.objid,
          targetos = RealId.osnum);
      as$status();

#ifdef vdsDEBUG
      printf (" raceway comp in at %d end %f %f %f\n",iendnum,dCIN[0],
                            dCIN[1], dCIN[2]);
#endif

      iendnum = me->Sect[secno].iTo;

      status = 
      om$send (msg = message VRGeneric.VRGetCptGeom
                  (&retmsg, iendnum, dCOT, dVOT, NULL, &alt_env ),
          targetid = RealId.objid,
          targetos = RealId.osnum);
      as$status();

      bIF = bOF = FALSE;

#ifdef vdsDEBUG
      printf (" exit raceway at %d end %f %f %f\n",iendnum,dCOT[0],
                            dCOT[1], dCOT[2]);
#endif
      break;
    case VCC_SPLIT_END:
    case VCC_SPLIT_BEGIN:
      status = om$send( msg = message VCRoot.VCGetCptGeom( &retmsg,
					       (Isectype==VCC_SPLIT_END)?1:0,
							    dCIN, dVIN, NULL,
							    &bIF, &alt_env ),
			targetid = RealId.objid,
			targetos = RealId.osnum );
      for (i=0; i<3; i++)
      {
	  dCOT[i] = dCIN[i];
	  dVOT[i] = dVIN[i];
      }
      bOF = bIF;
      __DBGpr_str("Which End of Parent Cable",
				  (Isectype==VCC_SPLIT_END)?"END":"BEGINNING");
      __DBGpr_vec("Coordinates of vertex",dCOT);
      break;

  }

  for (i=0; i<3; i++)
  {
    if (Cin) Cin[i] = dCIN[i];
    if (Vin) Vin[i] = dVIN[i];
    if (Cout) Cout[i] = dCOT[i];
    if (Vout) Vout[i] = dVOT[i];
  }

  if (bIFree) *bIFree = bIF;
  if (bOFree) *bOFree = bOF;

quit:
  End
  return OM_S_SUCCESS;
}

end implementation VCCable;

