/* $Id: VSedcnstfeet.I,v 1.1.1.1 2001/01/04 21:10:35 cvs Exp $  */

/***************************************************************************
 * I/STRUCT
 *
 * File:        vsedge/VSedcnstfeet.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VSedcnstfeet.I,v $
 *      Revision 1.1.1.1  2001/01/04 21:10:35  cvs
 *      Initial import to CVS
 *
# Revision 1.1  1998/04/30  10:08:06  pinnacle
# STRUCT 2.5.1
#
# Revision 1.2  1997/09/26  18:22:26  pinnacle
# CR179700200
#
 *
 * History:
 *      MM/DD/YY        AUTHOR          DESCRIPTIO
 *      09/26/97        ah              added header
 *      09/26/97        ah		CR179700200 Variable bevel parents
 ***************************************************************************/

class implementation VSedge3Datt;

#include "igetypedef.h"
#include "igrtypedef.h"
#include "gr.h"
#include "igr.h"
#include "godef.h"
#include "go.h"
#include "bserr.h"
#include "bsdistptpt.h"
#include "growner.h"
#include "ACrg_collect.h"
#include "ACattrib.h"
#include "asmacros.h"
#include "vsmiscmacros.h"
#include "vsedgeattr.h"

from  ACrg_collect import       AClist_attribute, ACset_list_attribute;

extern OMuword OPP_GR3dlinestr_class_id;

#define RATIO 0.2
/*
#define DEBUG 1
#define vsDEBUG 1
#define vserrDEBUG 1
*/

#include "vsdbgmacros.h"

method ACconstruct_feet ( 		IGRlong		*msg;
			 		IGRint		cn_type;
			 		IGRint		count;
			 struct		GRid		list[];
			 struct		GRmd_env	*md_env;
					IGRint		*fcount;
			 struct		GRid		*feet_list )
{
  IGRint 		num, nb_att, i;
  IGRlong		bsrc, sts;
  IGRdouble		eval[12*3], tmp[2], midpt[3], tang[6];
  struct GRid		line, col_id, allow_line, bevel_line;
  struct GRobj_env      surf, edge, copy_edge;
  struct IGRbsp_curve	*cv=NULL;
  struct IGRbsp_surface	*sf=NULL;
  struct IGRpolyline    geom;
  struct GRsymbology    mySymb;
  struct GRvg_construct cst;
  struct ACrg_coll      list_att[ATT_NB_ATT],ACrg[ATT_NB_ATT];

  if ( !msg || !md_env || !list || !fcount || !feet_list ) {
        __DBGpr_com( " Problem with arguments" );
        goto wrapup;
  }

  __DBGpr_objlist( "Templates for VSedge3Datt", count, list )

  sts = om$send( msg      = message VScpx.VSget_graphic_input(
                                   msg, 1, &list[ATT_T_IDX_EDGE_3D], &edge ),
                     targetid = my_id );
  __CheckRC( sts, *msg, "VScpx.VSget_graphic_input", wrapup ) ;
  __DBGpr_obj("Original edge", edge.obj_id );

  copy_edge.mod_env = *md_env;
  copy_edge._osnum  = md_env->_MD_OS;

  sts = om$send( msg	   = message GRgraphics.GRcopy(  
						 msg,
						 &edge.mod_env,
                                             	 md_env,
						 &copy_edge._objid ),
                  	targetid = edge._objid,
	          	targetos = edge._osnum  );
  __CheckRC( sts, *msg, "GRgraphics.GRcopy", wrapup ) ;
  __DBGpr_obj("Graphic edge", copy_edge.obj_id );

   sts = om$send(msg = message GRvg.GRgenabsg(
				    msg,
                                    &edge._matrix_type,
                                    edge._matrix,
                                   (IGRchar **)&cv),
                  targetid = copy_edge._objid,
                  targetos = copy_edge._osnum);
  __CheckRC( sts, *msg, "GRvg.GRgenabsg", wrapup ) ;

  BScveval(cv,0.5,0,eval,&bsrc);
  if (bsrc != BSSUCC) goto wrapup;

  BScveval(cv,0.5,1,tang,&bsrc);
  if (bsrc != BSSUCC) goto wrapup;

  BSnorvec(&bsrc,&tang[3]);
  if (bsrc != BSSUCC) goto wrapup;

  sts = om$send( msg      = message VScpx.VSget_graphic_input(
                                   msg, 1, &list[ATT_T_IDX_SURF], &surf ),
                     targetid = my_id );
  __CheckRC( sts, *msg, "VScpx.VSget_graphic_input", wrapup ) ;
  __DBGpr_obj("Graphic Surf", surf.obj_id );

   sts = om$send(msg = message GRvg.GRgenabsg(
				    msg,
                                    &surf._matrix_type,
                                    surf._matrix,
                                   (IGRchar **)&sf),
                  targetid = surf._objid,
                  targetos = surf._osnum);
  __CheckRC( sts, *msg, "GRvg.GRgenabsg", wrapup ) ;
   
   BSsfeval(sf,0.5,0.5,0,&eval[3],&bsrc);
   if (bsrc != BSSUCC) goto wrapup;
   eval[3] = eval[3] - eval[0];
   eval[4] = eval[4] - eval[1];
   eval[5] = eval[5] - eval[2];
   if (bsrc != BSSUCC) goto wrapup;
   BSnorvec(&bsrc,&eval[3]);
   if (bsrc != BSSUCC) goto wrapup;

  tmp[0] = BSdistptpt(&bsrc,sf->poles,&(sf->poles[3*(sf->u_num_poles-1)]));
  if (bsrc != BSSUCC) goto wrapup;

  tmp[1] = BSdistptpt(&bsrc,&(sf->poles[3*(sf->u_num_poles-1)]),
                        &(sf->poles[3*(sf->u_num_poles*sf->v_num_poles-1)]));
  if (bsrc != BSSUCC) goto wrapup;

  if (tmp[0] > tmp[1]) tmp[0] = tmp[1];

   eval[3] = eval[0] + RATIO*tmp[0]*eval[3];
   eval[4] = eval[1] + RATIO*tmp[0]*eval[4];
   eval[5] = eval[2] + RATIO*tmp[0]*eval[5];

   sts = om$send(  msg     = message GRvg.GRgetsymb( msg, &mySymb),
				mode     = OM_e_wrt_message,
                            	targetid = my_id );
   __CheckRC( sts, *msg, "GRvg.GRgetsymb", wrapup ) ;

   vs$fill_cnst_list(      Env_info        = md_env,
                           Display         = &mySymb.display_attr,
                           Level           = mySymb.level,
                           Cnst_list       = cst ) ;

   geom.num_points = 2;

 // find process et specification number to put in the vljunction feet

  // find the box

  sts = om$send( msg = message ACrg_collect.AClist_attribute
                                     (msg, ATT_NB_ATT, list_att, &num),
                  targetid = list[ATT_T_IDX_BOX].objid,
                  targetos = list[ATT_T_IDX_BOX].osnum);
  __CheckRC( sts, *msg, "ACrg_collect.AClist_attribute", wrapup ) ;

  if (num < ATT_IDX_SPEC_NB) goto wrapup;

  allow_line.objid = NULL_OBJID;
  allow_line.osnum = cst.env_info->md_id.osnum;

#ifdef XXX
{
  IGRdouble allowValue;
  allowValue = list_att[ATT_IDX_ALLOWANCE].desc.value.att_exp;
  printf("Allow Value: %.2f\n",allowValue);
}
#endif

  if( list_att[ATT_IDX_ALLOWANCE].desc.value.att_exp > 0.0001 )
  {
    eval[6] = ( eval[0] + eval[3] ) * 0.5;
    eval[7] = ( eval[1] + eval[4] ) * 0.5;
    eval[8] = ( eval[2] + eval[5] ) * 0.5;

    eval[ 9] = eval[6] - 0.25*RATIO*tmp[0]*tang[3];
    eval[10] = eval[7] - 0.25*RATIO*tmp[0]*tang[4];
    eval[11] = eval[8] - 0.25*RATIO*tmp[0]*tang[5];

    eval[12] = eval[6] + 0.25*RATIO*tmp[0]*tang[3];
    eval[13] = eval[7] + 0.25*RATIO*tmp[0]*tang[4];
    eval[14] = eval[8] + 0.25*RATIO*tmp[0]*tang[5];

    geom.num_points += 3;
  }

  bevel_line.objid = NULL_OBJID;
  bevel_line.osnum = cst.env_info->md_id.osnum;

  if( count > 3 )
  {
    i = geom.num_points * 3;

    eval[i+0] = ((eval[0] + eval[3]) * 0.5) - ((eval[0] - eval[3]) * .25);
    eval[i+1] = ((eval[1] + eval[4]) * 0.5) - ((eval[1] - eval[4]) * .25);
    eval[i+2] = ((eval[2] + eval[5]) * 0.5) - ((eval[2] - eval[5]) * .25);

    midpt[0] = ( eval[0] + eval[3] ) * 0.5;
    midpt[1] = ( eval[1] + eval[4] ) * 0.5;
    midpt[2] = ( eval[2] + eval[5] ) * 0.5;

    eval[i+3] = midpt[0] - 0.25*RATIO*tmp[0]*tang[3];
    eval[i+4] = midpt[1] - 0.25*RATIO*tmp[0]*tang[4];
    eval[i+5] = midpt[2] - 0.25*RATIO*tmp[0]*tang[5];

    eval[i+6] = ( eval[0] + eval[3] ) * 0.5 + ((eval[0] - eval[3]) * .25);
    eval[i+7] = ( eval[1] + eval[4] ) * 0.5 + ((eval[1] - eval[4]) * .25);
    eval[i+8] = ( eval[2] + eval[5] ) * 0.5 + ((eval[2] - eval[5]) * .25);

    eval[i+ 9] = midpt[0] + 0.25*RATIO*tmp[0]*tang[3];
    eval[i+10] = midpt[1] + 0.25*RATIO*tmp[0]*tang[4];
    eval[i+11] = midpt[2] + 0.25*RATIO*tmp[0]*tang[5];

    if (geom.num_points == 2) {
      eval[i+12] = ((eval[0] + eval[3]) * 0.5) - ((eval[0] - eval[3]) * .25);
      eval[i+13] = ((eval[1] + eval[4]) * 0.5) - ((eval[1] - eval[4]) * .25);
      eval[i+14] = ((eval[2] + eval[5]) * 0.5) - ((eval[2] - eval[5]) * .25);
      geom.num_points++;
    }

    geom.num_points +=4;
  }

   geom.points = eval;
   cst.geometry = (IGRchar *) &geom;
   line.objid = NULL_OBJID;
   line.osnum = cst.env_info->md_id.osnum;
   sts = om$construct( 	classid = OPP_GR3dlinestr_class_id,
			p_objid = &line.objid,
			osnum   = line.osnum	);
   __CheckRC( sts, 1, "const GR3dlinestr", wrapup ) ;
   __DBGpr_obj("3D edge", line );

   sts = om$send( msg      = message GRgraphics.GRaltconstruct(&cst),
		  targetid = line.objid,
		  targetos = line.osnum    );
   __CheckRC( sts, 1, "GRgraphics.GRaltconstruct", wrapup ) ;


  nb_att=0;
  strcpy(ACrg[nb_att].name,ATT_PROCESS);
  ACrg[nb_att].desc.type = AC_ATTRIB_TEXT;
  strcpy(ACrg[nb_att].desc.value.att_txt,
                              list_att[ATT_IDX_PROCESS].desc.value.att_txt);
  nb_att = nb_att + 1;

  strcpy(ACrg[nb_att].name,ATT_SPEC_NB);
  ACrg[nb_att].desc.type = AC_ATTRIB_TEXT;
  strcpy(ACrg[nb_att].desc.value.att_txt,
                              list_att[ATT_IDX_SPEC_NB].desc.value.att_txt);
  nb_att = nb_att + 1;

  /* Construct collection object */
  col_id.objid = NULL_OBJID;
  col_id.osnum = md_env->md_id.osnum;
  om$construct ( classid = OPP_ACrg_collect_class_id,
                 osnum   = col_id.osnum,
                 p_objid = &col_id.objid );

  /* Set value in collection object */
  sts = om$send ( msg = message ACrg_collect.ACset_list_attribute
                                    ( msg, nb_att, ACrg ),
                       targetid = col_id.objid,
                       targetos = col_id.osnum );

  /* Set <collect> template in array */
  as$make_source ( go_grid = col_id,
                   mod_env = md_env,
                   as_grid = &feet_list[ATT_F_IDX_BOX] );

  *fcount = NB_FEET-1;
  feet_list[ATT_F_IDX_EDGE_3D] = copy_edge.obj_id;
  feet_list[ATT_F_IDX_SMALL_EDGE] = line;

  *fcount = 3;  /* Always have at least three */

  if( allow_line.objid != NULL_OBJID )
  {
     feet_list[*fcount] = allow_line;
     *fcount = *fcount + 1;
  }

  if( bevel_line.objid != NULL_OBJID )
  {
     feet_list[*fcount] = bevel_line;
     *fcount = *fcount + 1;
  }

wrapup:
  return OM_S_SUCCESS;

}


end implementation VSedge3Datt;
