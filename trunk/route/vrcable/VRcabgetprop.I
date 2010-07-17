/* $Id: VRcabgetprop.I,v 1.1.1.1 2001/01/04 21:12:40 cvs Exp $  */

/*************************************************************************
 * I/ROUTE
 *
 * File:	vrcable / VRcabgetprop.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VRcabgetprop.I,v $
 *	Revision 1.1.1.1  2001/01/04 21:12:40  cvs
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
# Revision 1.3  1996/01/16  20:05:08  pinnacle
# Replaced: vrcable/VRcabgetprop.I for:  by r240_int for route240
#
 *
 * History:
 *	MM/DD/YY   AUTHOR	DESCRIPTION
 *
 *************************************************************************/
class implementation VRcable;

#include <math.h>
#include "OMmacros.h"
#include "OMprimitives.h"
#include "ASmatrix.h"
#include "asdef.h"
#include "asmacros.h"
#include "asbox.h"
#include "AS_status.h"
#include "macro.h"
#include "bsparameters.h"
#include "parametric.h"
#include "bsvalues.h"
#include "bserr.h"
#include "bstypes.h"
#include "msdef.h"
#include "bslenvec.h"
#include "bsdotp.h"
#include "bsdistptpt.h"
#include "bscrossp.h"
#include "bsmkvec.h"
#include "bsnorvec.h"

#define AS_DEBUG 	1
#define EPSILON		1.0E-12

extern IGRdouble  modulo();

/*--------------------------------------------------------------------------*/
/* method VRget_cab_props  get tube_radius, bend_radius, length of VRcable  */
/*--------------------------------------------------------------------------*/
method VRCbGetProps( 	IGRlong 	*msg; 
			struct GRmd_env *md_env;
			IGRdouble	*sect_radius;
			IGRdouble	*bend_radius;
			IGRdouble	*cab_length )
{
IGRint 		status;
struct  GRid	str_id;

  if( sect_radius ){
    *sect_radius = me->sect_radius;
    /*^ printf("tub_radius  = %f\n", *sect_radius); */
  }

  if( bend_radius ){
    *bend_radius = me->bend_radius;
    /*^ printf("bend_radius = %f\n", *bend_radius); */
  }

  if( cab_length ){
    status = om$get_objid_at_index( objid        = my_id,
				    p_chanselect = &AS_to_comp,
				    index        = 0,
				    objidaddr    = &str_id.objid,
				    osnumaddr    = &str_id.osnum );
    as$status(action = GOTO_VALUE, value = wrapup);

    status = eval_length( msg, &(me->bend_table[0]), str_id, 
			  md_env, cab_length );
    as$status(action = GOTO_VALUE, value = wrapup);
    
    /*^ printf("length      = %f\n", *cab_length); */
  }

  *msg = MSSUCC;
  return(OM_S_SUCCESS);

wrapup:
  *msg = MSFAIL;
  return(OM_W_ABORT);
}

/*=========================================================================*/
/*   function to evaluate the lentgh of the linestring			   */
/*									   */
int eval_length( msg, btable, GO_STR, md_env, tot_length )
/*		 O  , I       , I        , I     , O		   	   */
/*=========================================================================*/

IGRlong 		*msg;
IGRdouble		*btable; 
struct 	GRid 		GO_STR;
struct  GRmd_env 	*md_env;
IGRdouble 		*tot_length;
/*.eval_length*/
{
IGRint			i, status;
BSrc			rc;
IGRdouble               va[3];		/* va = poles[i+3] - poles[i]     */
IGRdouble		vb[3];		/* vb = poles[i+6] - poles[i+3]   */
IGRdouble		vn[3];		/* vn = va /\ vb		  */
IGRdouble		teta;		/* angle between (va,vb)	  */
IGRdouble		tan_teta;	/* tangente of teta		  */
IGRint			num_segment;	/* number of segments of curve    */
IGRint			num_bangles;	/* number of bend angles in curve */
struct IGRbsp_curve	*bspcurve;	/* struct to retrive the spine    */

  /*| Retrieve the geometry */
  status = om$send( msg	    = message GRvg.GRgenabsg(	
						msg,
						&md_env->md_env.matrix_type,
						md_env->md_env.matrix,
						(IGRchar **)&bspcurve  ) ,
		   senderid = NULL_OBJID,
	           targetid  = GO_STR.objid,
                   targetos  = GO_STR.osnum  );

  /*| evaluate the length and  create expression length */
  *tot_length = 0.0;
  num_segment = bspcurve->num_poles - 1;
  num_bangles = bspcurve->num_poles - 2;

  /*^
    printf(" num_segmt : %d\n", num_segment );
    printf(" num_b_ang : %d\n", num_bangles );
    for(i=0; i<num_bangles; i++)
	printf(" btable[%d] = %f\n",i, btable[i] );
   */

  for(i=0;i<num_segment; i++)
   	*tot_length = *tot_length + BSdistptpt(&rc,&(bspcurve->poles[3*i]),
				                 &(bspcurve->poles[3*i+3]));

  for(i=0;i<num_bangles; i++){
	/* vector of first line */
    	BSmkvec( &rc, va, &(bspcurve->poles[3*i+3]), &(bspcurve->poles[3*i]) );
    	BSnorvec( &rc, va);
	/* vector of second line */
    	BSmkvec( &rc, vb, &(bspcurve->poles[3*i+3]), &(bspcurve->poles[3*i+6]) );
    	BSnorvec( &rc, vb);

        BScrossp( &rc, va, vb, vn);
    	BSnorvec( &rc, vn);

	ang_v1v2( va, vb, vn, &teta);

	if( fabs(teta) > EPSILON ){
		teta = M_PI - fabs( teta);
        	*tot_length = *tot_length + btable[i] * teta;
		teta = teta / 2.0;
		tan_teta = fabs( tan( teta));
		*tot_length = *tot_length - 2.0 * btable[i] * tan_teta;
		/*" len: %f;teta: %f;tan: %f\n", *tot_length,teta,tan_teta */
	}
		
  }/* --- loop on i --- */
  /*^ printf("tot_length = %f\n",*tot_length); */  

  /* remove geometry */
  GRabsg_del(bspcurve);
  *msg = MSSUCC;
  return(OM_S_SUCCESS);

}

/*=========================================================================*/
/*            compute the angle between two vectors                        */
/*=========================================================================*/

ang_v1v2(v1, v2, vz, angle)

IGRdouble	*v1;
IGRdouble	*v2;
IGRdouble 	*vz;
IGRdouble 	*angle;

{
BSrc		rc; 
IGRdouble 	cosinus,sinus,kz; 
IGRdouble 	normal[3];


  /* -- compute angle's ( cosinus * length ) -- */
  cosinus = BSdotp ( &rc, v1, v2 );

  /* -- compute angle's ( sinus * length ) -- */
  BScrossp ( &rc, v1, v2, normal);

  sinus = BSlenvec ( &rc, normal );

  /* -- compute angle -- */
  *angle = atan2(sinus,cosinus);

  /* angle or PI - angle depending upon vz value */

  kz = BSdotp ( &rc, normal, vz );

  /* -- if kz < 0 => take the complementary angle -- */
  if (kz < 0) *angle = 2*M_PI - *angle;
		modulo( angle, 2*M_PI ); 

return OM_S_SUCCESS;
}

/*--------------------------------------------------------------------------*/
/* end of file								    */
/*--------------------------------------------------------------------------*/
end implementation VRcable;
