/* $Id: VCMover.I,v 1.4 2002/04/10 14:56:22 louis Exp $  */

/*************************************************************************
 * I/CABLE
 *
 * File:        vcroot / VCMover.I
 *
 * Description:
 *   This file contains the overrides for the VCMac class.
 *
 * Dependencies:
 *
 * Revision History:
 *        $Log: VCMover.I,v $
 *        Revision 1.4  2002/04/10 14:56:22  louis
 *        TR5649-standardize tolerances
 *
 *        Revision 1.3  2001/02/20 01:11:07  build
 *        Replaced v_dbgmacros.h with product specific dbgmacros.h
 *
 *        Revision 1.2  2001/01/11 22:10:45  anand
 *        SP merge
 *
 *        Revision 1.1.1.1  2001/01/04 21:12:36  cvs
 *        Initial import to CVS
 *
# Revision 1.1  2000/09/08  19:13:44  pinnacle
# Created: route/vcroot/VCMover.I by aharihar for Service Pack
#
# Revision 1.4  1999/09/17  13:39:22  pinnacle
# Replaced: vcroot/VCMover.I for:  by lawaddel for route
#
# Revision 1.3  1999/03/04  05:24:28  pinnacle
# Replaced: vcroot/VCMover.I for: TR 179801249 by aharihar for route
#
# Revision 1.2  1998/12/22  17:04:26  pinnacle
# Replaced: vcroot/VCMover.I for:  by lawaddel for route
#
# Revision 1.1  1998/04/30  10:52:34  pinnacle
# ROUTE 2.5.1
#
# Revision 1.5  1998/04/20  04:22:56  pinnacle
# Replaced: vcroot/VCMover.I for:  by kddinov for route
#
# Revision 1.4  1998/04/13  00:12:46  pinnacle
# Replaced: vcroot/VCMover.I for:  by kddinov for route
#
# Revision 1.3  1998/04/12  21:24:08  pinnacle
# Replaced: vcroot/VCMover.I for:  by kddinov for route
#
# Revision 1.2  1997/11/30  16:09:26  pinnacle
# Replaced: vcroot/VCMover.I for:  by r250_int for route
#
# Revision 1.4  1997/11/26  18:58:52  pinnacle
# Replaced: vcroot/VCMover.I for:  by apazhani for cabling
#
# Revision 1.3  1997/08/28  15:42:20  pinnacle
# Replaced: vcroot/VCMover.I for:  by apazhani for cabling
#
# Revision 1.2  1997/08/13  14:04:30  pinnacle
# Replaced: vcroot/VCMover.I for:  by hverstee for cabling
#
# Revision 1.1  1997/07/14  22:01:10  pinnacle
# Created: vcroot/VCMover.I by hverstee for cabling
#
 *
 * History:
 *        05/29/96        hv         Initial
 *        08/28/97        Alwin      Preventing the Terminal being moved twice
 *                                   when both the Parent and the Terminal
 *                                   were inside the fence, during the fence
 *                                   move operation. CR179701612
 *        11/26/97        Alwin      Arrested the movement of Embedded Terminals
 *	  4/98		  KDD	     allow embeded terminals to be moved with
 *				     MOVE/ROTATE EMS commands.
 *	  11/08/98	  law	     TR179801229-rotate terminal fix.
 *        12/02/98        law        TR179801645-Change Parent repair.
 *      4 Mar 1999	  Anand	     TR179801249-Backshell does not displace as
 *      			     much as its terminal-parent, when the
 *      			     latter has a scale != 1.
 *     16 Sep 1999       Ad Zuurhout TR179900558 terminal offsets bad when
 *				      scale != 1.
 *      8 Sep 2000	  Anand	     TR 179901914
 *      04/05/02          law        TR5649-standardize tolerance with VRGetTol
 *************************************************************************/

class implementation VCMac;

/*
#define MY_DEBUG	1
#define vdsDEBUG	1
*/

#include "bsparameters.h"
#include "OMmacros.h"
#include "nddef.h"
#include "asbox.h"
#include "VRMath.h"
#include "AS_status.h"

#include "VCchansel.h"
#include "VCproto.h"

#include "coparamac.h"
#include "grgsmacros.h"
#include "VDmem.h"
#include "vrdbgmacros.h"

#include "mainvmx.h"
#include "mamulmx.h"
#include "DPvd.h"
#include "vc_param.h"
#include "parametric.h"

from	IGEgragad	import	DPinrot;

/*****************************************************************************/
extern GRclassid OPP_GRgencs_class_id;

method NDcopy (IGRlong       *msg;
               IGRint         cp_type;
        struct GRmd_env      *fr_env;
        struct GRmd_env      *to_env;
        struct GRid          *newobjid)

{
  IGRint          status;
  IGRlong         retmsg;

  /*   for copy to macro template adapt upscan again    */

  if( to_env->md_id.osnum != fr_env->md_id.osnum )
  {
    IGRboolean     bEmbed;

    bEmbed = TRUE;

    status =
    om$send (msg = message VCMac.VCMchgup
                           (&retmsg, bEmbed, NULL, NULL, NULL),
        targetid = my_id );
  }

  /*| Generic copy */

  status =
  om$send (msg = message VCRoot.NDcopy
                      (msg,cp_type,fr_env,to_env,newobjid),
          mode = OM_e_wrt_message,
      targetid = my_id );

  /*  change back upscan    */

  if( to_env->md_id.osnum != fr_env->md_id.osnum )
  {
    status =
    om$send (msg = message VCMac.VCMchgdn (&retmsg, NULL, NULL),
        targetid = my_id );

    if ( cp_type == ND_TO_MACRO )
    { /*   part of a macro ->   OWNED     */
      status =
      om$send (msg = message VCRoot.VCSetType (VC_GEN_OWNED, VC_GEN_OWNED),
          targetid = newobjid->objid,
          targetos = newobjid->osnum );
    }
  }
  else
  { /*   in same OS  ->   CLONE     */
    /*   This generally happens when the NDcopy was issued by the
         EMS move command, which makes a copy for dynamics, another
         copy to destination after which it deletes the original.     */
    status =
    om$send (msg = message VCRoot.VCSetStatus (VC_CLONE, VC_CLONE),
        targetid = newobjid->objid,
        targetos = newobjid->osnum );
  }

#ifdef MY_DEBUG
  printf ("NDcopy end, newobject = %d, old = %d\n",newobjid->objid, my_id);
#endif

  return ( status);
}/* end NDcopy */


method NDupdate (int      *msg;
                 int       cn_type, count;
          struct GRid     *parents;
                 int      *parent_state;
          struct GRid     *context,*new_objid;
          struct GRmd_env *md_env)

{
  /* Once moved to root during place macro, this objects receives
     another compute ??????? */
  /* So, if no templates are given => return success */
  if ( count <= 0 )
  {
    *msg = MSSUCC;
    return ND_COMP_SAME;
  }

  /*A    then send to general NDupdate method   */
  return
  (om$send (msg = message VCRoot.NDupdate
                (msg, cn_type, count, parents, parent_state,
                 context, new_objid, md_env),
        mode     = OM_e_wrt_message,
        targetid = my_id)                                       );
}


/*    These methods implement the flex move, in which the terminal
      or backshell move with regards to their parents. Therefore
      the offset values in the instance need to be adapted.

      NOTE: the full 3d transformation may force the instance to
            change to a full matrix representation, which may make
            for instance the change parent functionality difficult
            to implement.                                              */

method GRxform (IGRlong     *msg;
         struct GRmd_env    *md_env;
                IGRshort    *matrix_type;
                IGRmatrix    matrix;
                GRobjid     *new_objid)
{
  IGRint       status;
  IGRlong      retmsg;
  IGRshort     iArr;
  IGRshort     nCP, CompMatType;
  IGRint       i;
  IGRdouble    dRef[16];
  IGRdouble    dOut[16];
  IGRdouble    dOff[3];
  IGRdouble    dOf1[3];
  IGRmatrix	CompMat;
  struct ret_struct  ParamAttr;
  IGRint             FootIndex = -1;
  IGRdouble		One={1.0}; 

SetProc( VCMac_GRxform); Begin

  nCP = 0;

#ifdef MY_DEBUG
{
    IGRint   CL, CW;

    CL = me->nVCStat & VC_CLONE;
    CW = me->nVCType & VC_GEN_OWNED;

    printf ("CL_CW %d %d offset   %f %f %f\n",
                        CL, CW, matrix[3],matrix[7],matrix[11]);
}
#endif

  /* Check for the Embedded Terminal, if it's embedded terminal don't
  allow him to move it */
 
/* 4-98 KDD Allow move of embedded terminals, with MOVE/ROTATE EMS commnads  
*  if( me->nVCType & VC_GEN_EXTERN ) goto no_changein_offset;
*/

/* added by alwin, for preventing the terminal moving twice when its
parent is moved with a fence ( i.e If the fence contains both Terminal and its 
Parent, and if the we move the contents of the Fence then this problem occurs). This invloves preventing the "offset" between the terminal and the equipment 
being transformed. ---for CR179701612 */

   if ( ( me->nVCType & VC_GEN_VIRTUAL) ||
        ( me->nVCType & VC_GEN_BITERM ) ||
        ( me->nVCType & VC_GEN_OWNED  ) ||
        ( me->nVCType & VC_GEN_EXTERN ) )
   {
     IGRuint count=0;
     IGRlong retmsg;
     struct GRid  fence_id, ParentId;
     OM_S_OBJECT_LINKAGE *child;
     OM_S_CHANSELECT to_object;
     GRclassid ClassId;

     status = om$send ( msg = message VCRoot.VCParent( &retmsg, 0, &ParentId,
                                             md_env ),
                                      targetid = my_id );

     /*  Checking whether the terminal has Parent or not */
     if( status & retmsg & 1 )
     {
        status = gr$gsget_fence( msg = &retmsg, fence_id = &fence_id );
   
        /* It means that it's not a FENCE move, then proceed as usual */
        if( !(status & retmsg & 1 ) ) goto wrapup;
   
        status = om$make_chanselect ( channame     = VC_CHAN_OWNER,
                                      p_chanselect = &to_object );
   
        status = om$get_channel_count ( objid        = fence_id.objid,
                                        osnum        = fence_id.osnum,
                                        p_chanselect = &to_object,
                                        count        = &count );
   
        status = om$get_classid ( classname = "GRsvset", p_classid = &ClassId );
   
        /*"\n No of Owners count = %d \n", count );*/
   
        if( count > 0 )
        {
             IGRint i;
   
             child = _MALLOC (count, OM_S_OBJECT_LINKAGE);
             if(!child) return OM_E_NODYNMEM;
   
             status = om$get_channel_objects(
                                      objid        = fence_id.objid,
                                      osnum        = fence_id.osnum,
                                      p_chanselect = &to_object,
                                      list         = child,
                                      size         = count,
                                      count        = &count );
   
             for( i=0; i<count; i++ )
             {
               struct GRid MyId;
               GRclassid MyClassId;
   
               MyId.objid = child[i].S_objid;
               MyId.osnum = child[i].osnum;
   
               status = om$get_classid (objid = MyId.objid,
                                   p_classid = &MyClassId );
   
               if (    om$is_ancestry_valid ( subclassid   = MyClassId,
                               superclassid = ClassId )
                               == OM_S_SUCCESS )
               {
                  fence_id.objid = MyId.objid;
                  fence_id.osnum = MyId.osnum;
                  break;
               }
   
             }
   
             _FREE( child );
        }
   
        status = om$make_chanselect ( channame  = VC_CHAN_COMPS,
                                   p_chanselect = &to_object );
   
        status = om$get_channel_count(  objid = fence_id.objid,
                                        osnum = fence_id.osnum,
                                        p_chanselect = &to_object,
                                        count = &count );
        as$status( action = RET_STATUS );

        if( count > 0 )
        {
          IGRint i;
          IGRboolean bParent= FALSE, bTerminal=FALSE;
          GRclassid Parent_Classid, Terminal_Classid;

          /* Get the Classid of the Parent  */
          status = om$get_classid( objid = ParentId.objid,
                                   osnum = ParentId.osnum,
                               p_classid = &Parent_Classid );
   
          /* Get the Classid of the Terminal  */
          status = om$get_classid( objid = my_id,
                                   osnum = OM_Gw_current_OS,
                               p_classid = &Terminal_Classid );
   
          child = _MALLOC (count, OM_S_OBJECT_LINKAGE);
          if(!child) return OM_E_NODYNMEM;
   
          status = om$get_channel_objects(
                                   objid        = fence_id.objid,
                                   osnum        = fence_id.osnum,
                                   p_chanselect = &to_object,
                                   list         = child,
                                   size         = count,
                                   count        = &count );
   
          for( i=0; i<count; i++ )
          {
             GRclassid ClassId;
   
             /*printf("\n Objects in the Fence are [%d] (%d,%d) \n",
                                    i, child[i].S_objid, child[i].osnum );*/
   
             status = om$get_classid( objid = child[i].S_objid,
                                      osnum = child[i].osnum,
                                   p_classid = &ClassId );
   
            /*Check whether both Terminal and its Parent is there inside the
              Fence, If so don't allow the GRxform to work on Terminal object.
              So, quit this method. OPP_GRfencs_classid is for the Co-oridinate
              System Parent  */
            if ( Parent_Classid == ClassId || (ClassId == OPP_GRgencs_class_id) )
            {
                bParent = TRUE;
            }
   
            if ( Terminal_Classid == ClassId )
            {
                bTerminal = TRUE;
            }

          }

          if( bParent && bTerminal )
          {
             /* It means both the Terminal and the Parent lies within the
                Fence Range, so quit */
   
                /* Both the Terminal and Equipment are within the Fence \n */
                _FREE( child );
__DBGpr_com("Both the Terminal and Equipment are within the Fence");

		goto no_changein_offset;

                // return OM_S_SUCCESS;
          }
   
          _FREE( child );
        }
     }/* Terminal Parent check loop */
   }
/* ========= ADDED BY ALWIN ===========*/


wrapup :
/*-------------------
*  4-98 KDD  allow terminals embedded in Route equipment (VC_TERM_RE) 
*  to adjust to parent as per 179800301. 
*------------------*/

  if ((!(me->nVCStat & VC_CLONE))     && 
      (!(me->nVCType & VC_GEN_OWNED)) &&
      (!(me->nVCType & VC_GEN_VIRTUAL)) || 
      (me->nVCType & VC_TERM_RE) )
  { /*  I am free to adjust wrt my parent     */

__DBGpr_com("Terminal is free to adjust to parent");

#ifdef MY_DEBUG
    if ((!(me->nVCStat & VC_CLONE)))
    {
    printf (" GRxform mattyp %d\n",*matrix_type);
    for (i=0; i<4; i++)
      printf (" -MATRIX-  %f %f %f %f\n",matrix[i*4],matrix[i*4+1],
                     matrix[i*4+2],matrix[i*4+3]);
    }
#endif

    iArr = om$dimension_of (varray = me->dVCOffVal);
__DBGpr_int("iArr is ",iArr);
    if (iArr == 0)
    {
      me->nVCType |= VC_TOFF_COORDS;
	/* Below modified for tr179801229 for terminal rotate */
      status =
      om$vla_set_dimension (varray = me->dVCOffVal,
                            size   = 16);
      MAidmx (&retmsg, me->dVCOffVal); /* TR179801645 */
      me->dVCOffVal[3] =
      me->dVCOffVal[7] =
      me->dVCOffVal[11] = 0.0;

      iArr = 16;
    }

    dOff[0] = matrix[3] ;
    dOff[1] = matrix[7] ;
    dOff[2] = matrix[11];

#ifdef MY_DEBUG
    if ((!(me->nVCStat & VC_CLONE)))
    {
    printf ("Old offset %f %f %f\n",me->dVCOffVal[3], me->dVCOffVal[7],
                                    me->dVCOffVal[11]);
    printf ("trn offset %f %f %f\n",matrix[3], matrix[7], matrix[11]);
    }
#endif


    if ((me->nVCType & VC_TOFF_COORDS) ||
        (me->nVCType & VC_TOFF_C_ANG))
    {
__DBGpr_com("VC_TOFF_COORDS || VC_TOFF_C_ANG"); 

      status =
      om$send (msg = message VCRoot.VCBaseMat
                                  (&retmsg, nCP, dRef, md_env),
          targetid = my_id);

      dRef[3] = dRef[7] = dRef[11] = 0.0;
    iArr = om$dimension_of (varray = me->dVCOffVal); /* tr179801229 */
      VC_to_offset (dRef, me->nVCType, iArr, dOff, dOf1);
__DBGpr_mat("matrix before offset",me->dVCOffVal);
/**** TR179801229-rotate terminal broken - law *********/
      if(iArr == 16)
      {
      me->dVCOffVal[3]  += dOf1[0] ;
      me->dVCOffVal[7]  += dOf1[1] ;
      me->dVCOffVal[11] += dOf1[2] ;
#ifdef MY_DEBUG
    printf ("New offset %f %f %f\n",me->dVCOffVal[3], me->dVCOffVal[7],
                                    me->dVCOffVal[11]);
#endif

      }
      else
      {
      me->dVCOffVal[0] += dOf1[0];
      me->dVCOffVal[1] += dOf1[1];
      me->dVCOffVal[2] += dOf1[2];
#ifdef MY_DEBUG
    printf ("New offset %f %f %f\n",me->dVCOffVal[0], me->dVCOffVal[1],
                                    me->dVCOffVal[2]);
#endif

      }
    }
    else
    if (me->nVCType & VC_TOFF_C_FULL)
    {
__DBGpr_com("VC_TOFF_C_FULL"); 

/*---------------------------
* 4-98 KDD TR179800301.   
# ---KLUDGY--- 
* For some reason the input matrix is either Rotational or Translational.
* Thus when it is rotational DISREGARD the translational part, and vice versa.
*
*---------------------------
* Test if the matrix has rotational part.
* if not then it is a translation matrix use it to modify the offset.
* if rotational part is present, use the rotation ONLY.
*
* Assuming that the 3x3 part of matrix is normalized column wise, I am testing
* the diagonal elements to determine if the matrix is Identity (no rotation).
*--------------------------*/

__DBGpr_mat("input  full      matrix", matrix); 
__DBGpr_mat("me->dVCOffVal     ", me->dVCOffVal);

    if ((fabs(matrix[ 0 ] - One) > VRGetTol(VR_DEFAULT_TOL)) ||
	(fabs(matrix[ 5 ] - One) > VRGetTol(VR_DEFAULT_TOL)) ||
	(fabs(matrix[ 10] - One) > VRGetTol(VR_DEFAULT_TOL)) ) {

/* 4-98 KDD use only the rotational part */
      for ( i = 0; i < 16; i++ ) dRef[i]  = matrix[i] ;      

      dRef[ 3 ] = dRef [ 7 ] = dRef [ 11 ] = 0.0 ; 
      dRef[ 15] = 1.0; 

      VC_mat_multiply (dRef, me->dVCOffVal, dOut);

      for (i=0; i < 3 ; i++) {
        me->dVCOffVal[i*4    ] = dOut[i*4    ];
        me->dVCOffVal[i*4 + 1] = dOut[i*4 + 1];
        me->dVCOffVal[i*4 + 2] = dOut[i*4 + 2];
      }
    }
    else
    { 
	IGRdouble 	Trans[4], V_Offset[4];
	IGRshort	i_four = 4, i_one = 1; 

/* 4-98 KDD. Translation part may be taken only if there is no rotation */
/* Translation is with respect to the inverse rotation of the parent */

        status = om$send( msg      = message VCRoot.VCBaseMat
                                            (&retmsg, nCP, dRef, md_env),
                          targetid = my_id);

	__DBGpr_mat("Base matrix ", dRef); 

/* Add translation to the existing one. */

	ParamAttr.var.root_pm_st.value = One;

	if( me->nVCType & VC_GEN_EXTERN )
	{
	    /* The following ACgive_structure call was put inside an if
	     * condition (use the PID scale only for embedded terminals)
	     * by Anand for TR 179901914. */

	    status = om$send( msg = message ACncpx.ACgive_structure (
							    (int *) &retmsg,
							    (int *) &FootIndex,
							    VC_N_PID_SCALE_DB, 
							    &ParamAttr, md_env),
			 targetid = my_id);
	}

	dRef[3] = dRef[7] = dRef[11] = 0.0;
	dRef[15] = One; 

        __DBGpr_dbl(" scale ", ParamAttr.var.root_pm_st.value );
        /* scale added for TR179900558 */
	Trans[0] = matrix[ 3 ] / ParamAttr.var.root_pm_st.value ;
	Trans[1] = matrix[ 7 ] / ParamAttr.var.root_pm_st.value ;
	Trans[2] = matrix[ 11] / ParamAttr.var.root_pm_st.value ;
	Trans[3] = One;
	__DBGpr_vec("Transformation ", Trans ); 

	VC_mat_invert (dRef, dRef);

        MAmulmx( msg, &i_four, &i_four, &i_one, dRef, Trans, V_Offset); 

	__DBGpr_vec("New rotated offset   ", V_Offset); 

	    /* Modified the following 3 lines for TR 179801249 by Anand */
        me->dVCOffVal[ 3 ] += V_Offset[ 0 ]; // ParamAttr.var.root_pm_st.value;
        me->dVCOffVal[ 7 ] += V_Offset[ 1 ]; // ParamAttr.var.root_pm_st.value;
        me->dVCOffVal[ 11] += V_Offset[ 2 ]; // ParamAttr.var.root_pm_st.value;
	    /* Wonder why the offset values were scaled in the first place? */

    }
/* 4-98 KDD end update of instance data */

    }
  }

no_changein_offset :

  status =
  om$send (msg = message VCRoot.GRxform
                       (msg, md_env, matrix_type, matrix, new_objid),
      targetid = my_id,
          mode = OM_e_wrt_message);

/*  Causes crash - law 11/08/98
__DBGpr_mat("me->dVCOffVal  exit     ", me->dVCOffVal);
*/
End;
  return (status);
}


method  GRmodify (IGRlong    *msg;
           struct GRmd_env   *md_env;
           struct GRparms    *parms;
                  IGRpoint    point;
           struct IGRline    *boreline;
                  GRobjid    *new_objid)
{
  IGRint        status;

#ifdef MY_DEBUG
  printf (" GRmodify point %f %f %f\n",point[0],point[1],point[2]);

  printf (" GRmodify boreline %f %f %f to %f %f %f\n",
              boreline->point1[0],boreline->point1[1],boreline->point1[2],
              boreline->point2[0],boreline->point2[1],boreline->point2[2]);
#endif

  status =
  om$send (msg = message VCRoot.GRmodify
                       (msg, md_env, parms, point, boreline, new_objid),
      targetid = my_id,
          mode = OM_e_wrt_message);

  return (status);
}

end implementation VCMac;

