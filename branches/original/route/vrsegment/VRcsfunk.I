/* $Id: VRcsfunk.I,v 1.3 2002/04/10 20:30:14 louis Exp $  */

/*************************************************************************
 * I/ROUTE
 *
 * File:	vrsegment / VRcsfunk.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VRcsfunk.I,v $
 *	Revision 1.3  2002/04/10 20:30:14  louis
 *	tr5649-standardize tolerance
 *	
 *	Revision 1.2  2001/03/08 23:34:06  louis
 *	tr4725-dbg prints only
 *	
 *	Revision 1.1.1.1  2001/01/04 21:13:09  cvs
 *	Initial import to CVS
 *	
# Revision 1.1  1998/04/30  10:52:34  pinnacle
# ROUTE 2.5.1
#
# Revision 1.1  1997/07/17  18:30:54  pinnacle
# route 2.5
#
# Revision 1.1  1996/07/25  18:25:44  pinnacle
# Creation of Route 241 project
#
# Revision 1.2  1996/01/17  23:26:28  pinnacle
# Replaced: vrsegment/VRcsfunk.I for:  by r240_int for route240
#
 *
 * History:
 *	01/17/96   tlb	Add prototypes
 *      03/08/01   law          dbg prints
 *      04/08/02   law          TR5649-standardize tolerance with VRGetTol
 *
 *************************************************************************/
/* external functions */

class implementation VRCnrlSeg;


#include <math.h>
#include "OMerrordef.h"
#include "igetypedef.h"
#include "igrtypedef.h"
#include "godef.h"
#include "grdpbdef.h"
#include "msdef.h"
#include "gr.h"
#include "igr.h"
#include "igrdp.h"
#include "go.h"
#include "grdpbmacros.h"
#include "bserr.h"
#include "bsparameters.h"
#include "VRpriv_attr.h"
#include "VRMath.h"
#include "ACattrib.h"
#include "ACrg_collect.h"
#include "VRprivmacros.h"
#include "AS_status.h"
#include "bspl_pl_pl.h"
#include "bsmkvec.h"
#include "bsdotp.h"
#include "bslenvec.h"
#include "vrdbgmacros.h"

#define AS_DEBUG 	1

from	VRGeneric	import	VRGetCorrections,
				VRSelectCptByGeom;

/*--------------------------------------------------------------------- */

VRget_segment_geom( retcode, plane, pt1, pt2 )

IGRint		*retcode;    /* return code 				*/
struct IGRplane plane[];     /* plane[0] = left boundary		*/
			     /* plane[1] = fisrt intersection plan      */
			     /* plane[2] = second intersection plan     */
			     /* plane[3] = right  intersection plan     */
IGRdouble       *pt1;        /* right point defining the segment        */
IGRdouble       *pt2;        /* left point defining  the segment        */
{
  BSrc	 	bsretcode;
  IGRint 	flag;
  IGRpoint 	q, r;
  IGRvector 	u, v;

  SetProc(VRCnrlSeg-VRget_segment_geom); Begin

  *retcode = MSSUCC;

  /* find the start point of the segment */

#ifdef vdsDEBUG
  {
  	IGRint	i;

  	for( i = 0; i<4; i++ )      
  	{
      		printf(" plane %d point: %lf , %lf , %lf \n", i, plane[i].point[0],
				            			 plane[i].point[1],
					    			 plane[i].point[2]);

      		printf("plane %d normal: %lf , %lf , %lf \n", i, plane[i].normal[0],
				            			 plane[i].normal[1],
					    			 plane[i].normal[2]);
	}
  }
#endif

  BSpl_pl_pl
  ( &(plane[0].point[0]), &(plane[0].normal[0]), &(plane[1].point[0]),
    &(plane[1].normal[0]),&(plane[2].point[0]), &(plane[2].normal[0]),
    &flag, pt1, q, r, u, v, &bsretcode
  );

  __DBGpr_vec("pt1 ", pt1);

  if( bsretcode != BSSUCC )
  {
    as$status( sts = OM_E_ABORT, msg = "Compute segment geometry failed" );
    return OM_E_ABORT;
  }

  /* find the end point of the segment */

  BSpl_pl_pl
  ( &(plane[1].point[0]), &(plane[1].normal[0]), &(plane[2].point[0]),
    &(plane[2].normal[0]), &(plane[3].point[0]), &(plane[3].normal[0]),
    &flag, pt2, q, r, u, v, &bsretcode
  );

  __DBGpr_vec("pt2 ", pt2);

  if( bsretcode != BSSUCC )
  {
    as$status( sts = OM_E_ABORT, msg = "Compute segment geometry failed" );
    End
    return OM_E_ABORT;
  }

  End
  return OM_S_SUCCESS;
}

/******************************************************************************/

VRget_segment_to_notify( p_retmsg, nb_sup, list_sup, seg_id, not_seg, md_env, Merge )

IGRlong				*p_retmsg;
IGRint				nb_sup;
struct		GRid		*list_sup;
struct 		GRid		*seg_id;
struct 		GRid		*not_seg;
struct		GRmd_env	*md_env;
IGRboolean			*Merge;
{
  IGRint			i;
  BSrc				bsretcode;
  IGRlong			status=OM_S_SUCCESS, retcode=MSSUCC;
  IGRdouble			scalar;
  IGRdouble			VectLength;
  IGRdouble			TmpVect[3];
  IGRdouble			VectLength1;
  IGRdouble			TmpVect1[3];
  struct	ret_struct	seg_str;
  struct	ret_struct	notseg_str;

  *p_retmsg = MSSUCC;
  
  status = om$send( msg     = message NDnode.NDgive_structure( &retcode, &seg_str, md_env ),
                    senderid = NULL_OBJID,
                    targetid = seg_id->objid,
                    targetos = seg_id->osnum );
  as$status( action = RET_STATUS );
  as$status( sts = retcode, action = RET_STATUS );

  *Merge = FALSE;

  /*"nb_sup = %d\n", nb_sup */

  for( i=0; i<nb_sup; i++ )
  {
	GRclassid	ClassId;
extern	GRclassid	OPP_VRCnrlSeg_class_id;

	/* Act only upon the segment objects */
	status =
	om$get_classid( objid     = list_sup[i].objid,
			osnum     = list_sup[i].osnum,
			p_classid = &ClassId ) ;
	if( 	!(status&1) ||
		ClassId != OPP_VRCnrlSeg_class_id )
	continue;


    if( seg_id->objid != list_sup[i].objid )
    {
      /*"if seg = %d will be notified\n", list_sup[i].objid */

      status = om$send( msg     = message NDnode.NDgive_structure
      							( &retcode, &notseg_str, md_env ),
                    	senderid = NULL_OBJID,
                    	targetid = list_sup[i].objid,
                    	targetos = list_sup[i].osnum );
      as$status( action = RET_STATUS );
      as$status( sts = retcode, action = RET_STATUS );

      scalar = BSdotp( &bsretcode, seg_str.var.line_st.v0, 
                                                   notseg_str.var.line_st.v0 );

      /*"scalar = %f\n", scalar */

      if( (1 - fabs(scalar)) < VRGetTol(VR_DOTPROD_TOL) )
      {
	/* If here, scalar is close to +1 or -1. Establish which one. */
/*      if( 1 - scalar < BSBASISVAL ) modified 4/5/02-law *****/
        if( scalar > 0.0 )
        {
          /*| same direction */
        
          BSmkvec( &bsretcode, TmpVect, seg_str.var.line_st.p1, 
                   notseg_str.var.line_st.p0
                 );

          BSmkvec( &bsretcode, TmpVect1, seg_str.var.line_st.p0, 
                   notseg_str.var.line_st.p1
                 );

          /*"TmpVect  = %f %f %f\n", TmpVect[0],  TmpVect[1],  TmpVect[2] */
          /*"TmpVect1 = %f %f %f\n", TmpVect1[0], TmpVect1[1], TmpVect1[2] */

          VectLength  = BSlenvec( &bsretcode, TmpVect );
          VectLength1 = BSlenvec( &bsretcode, TmpVect1 );

          /*"VectLength  = %f\n", VectLength  */
          /*"VectLength1 = %f\n", VectLength1 */

          if( (VectLength < VRGetTol(VR_LENGTH_TOL)) ||
              (VectLength1 < VRGetTol(VR_LENGTH_TOL)) )
          {
            *Merge = TRUE;

            *not_seg = list_sup[i];
     
            return(OM_S_SUCCESS);
          }
        }
        else
        {
          /*| opposed direction */
        
          BSmkvec( &bsretcode, TmpVect, seg_str.var.line_st.p1, 
                   notseg_str.var.line_st.p1
                 );

          BSmkvec( &bsretcode, TmpVect1, seg_str.var.line_st.p0, 
                   notseg_str.var.line_st.p0
                 );

          /*"TmpVect  = %f %f %f\n", TmpVect[0],  TmpVect[1],  TmpVect[2] */
          /*"TmpVect1 = %f %f %f\n", TmpVect1[0], TmpVect1[1], TmpVect1[2] */

          VectLength  = BSlenvec( &bsretcode, TmpVect );
          VectLength1 = BSlenvec( &bsretcode, TmpVect1 );

          /*"VectLength  = %f\n", VectLength  */
          /*"VectLength1 = %f\n", VectLength1 */

          if( (VectLength < VRGetTol(VR_LENGTH_TOL)) ||
              (VectLength1 < VRGetTol(VR_LENGTH_TOL)) )
          {
            *Merge = TRUE;

            *not_seg = list_sup[i];
     
            return(OM_S_SUCCESS);
          }
        }
      }
    }
  }
 
  return(OM_S_SUCCESS);

}

/*****************************************************************************/
VRGetAttrFromCpt( product, cmp_index, section_matrix, cmp_param_id, user_param_id, cmp_id,
                  seg_id, md_env )
                 

IGRshort			product;
IGRshort			cmp_index;
IGRdouble			*section_matrix;	
struct		GRid		*cmp_param_id;
struct		GRid		*user_param_id;
struct		GRid		*cmp_id;
struct		GRid		*seg_id;
struct		GRmd_env	*md_env;

/*.VRGetAttrFromCpt */
{
  IGRshort			CptNum;
  IGRlong			status, retcode;
  IGRdouble			SegVector[3], SegEndPt[6];


  status  = OM_S_SUCCESS;
  retcode = MSSUCC;

  status = om$send( msg      = message VRCnrlSeg.VRGetTopo
                               ( &retcode, SegVector, NULL, NULL, NULL, NULL, md_env ),
                    senderid = NULL_OBJID,
                    targetid = seg_id->objid,
                    targetos = seg_id->osnum );
  as$status( action = RET_STATUS );
  as$status( sts = retcode, action = RET_STATUS );

  status = om$send( msg      = message VRCnrlSeg.VRget_terminators
                               			( &retcode, NULL, md_env, SegEndPt, NULL ),
                    senderid = NULL_OBJID,
                    targetid = seg_id->objid,
                    targetos = seg_id->osnum );
  as$status( action = RET_STATUS );
  as$status( sts = retcode, action = RET_STATUS );

  if( cmp_index )
  {
    SegVector[0] *= -1; SegVector[1] *= -1; SegVector[2] *= -1;
  }

  /*"CmpVector = %f %f %f\n", SegVector[0], SegVector[1], SegVector[2] */
  /*"CmpPt     = %f %f %f\n", SegEndPt[3*cmp_index], SegEndPt[3*cmp_index+1], SegEndPt[3*cmp_index+2] */
	
  status = om$send( msg      = message VRGeneric.VRSelectCptByGeom
                              ( &retcode, &SegEndPt[3*cmp_index], SegVector, &CptNum, md_env ),
                    senderid = NULL_OBJID,
                    targetid = cmp_id->objid,
                    targetos = cmp_id->osnum );
  as$status( action = RET_STATUS );
  as$status( sts = retcode, action = RET_STATUS );
   
  /*"CptNum = %d\n", CptNum */

  if( section_matrix )
  {
  	/*| Get Section on Cpt */
  	status = VR$ModifyHvacSection(	p_retmsg	= &retcode,
					p_ComponentId	= cmp_id,
					CmpCptNum	= CptNum,
					p_OutPutSection	= section_matrix,
					p_MdEnv		= md_env );
  	as$status( action = RET_STATUS );
  	as$status( sts = retcode, action = RET_STATUS );
  }

  /*| Get collection overridden by cpt values. */
  status = VR$GetCmpAttributes(	p_retmsg        = &retcode,
           	             Product         = product,
           	             p_ComponentId	= cmp_id,
           	             CmpCptNum	= CptNum,
           	             p_SysParamId    = cmp_param_id,
           	             p_UserParamId   = user_param_id,
                	     p_MdEnv      	= md_env );
  as$status( action = RET_STATUS );
  as$status( sts = retcode, action = RET_STATUS );

  /*^ VRprint_user_attr( cmp_param_id ); */

  return OM_S_SUCCESS;

}

end implementation VRCnrlSeg;
