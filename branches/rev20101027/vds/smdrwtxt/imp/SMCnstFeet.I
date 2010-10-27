/* $Id: SMCnstFeet.I,v 1.3 2001/04/06 15:08:38 ylong Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/smdrwtxt/imp / SMCnstFeet.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: SMCnstFeet.I,v $
 *	Revision 1.3  2001/04/06 15:08:38  ylong
 *	TR4984
 *	
 *	Revision 1.2  2001/01/19 23:06:27  jayadev
 *	*** empty log message ***
 *	
# Revision 1.1  2000/05/16  22:29:06  pinnacle
# Created: vds/smdrwtxt/imp/SMCnstFeet.I by rchennup for Service Pack
#
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
# Revision 1.1  1997/05/08  13:20:44  pinnacle
# New project VDS 250
#
# Revision 1.1  1996/07/19  20:33:52  pinnacle
# Create VDS 241 project
#
# Revision 1.1  1994/11/14  22:42:32  pinnacle
# Create vds.240 from vds.232
#
# Revision 1.1  1994/11/08  16:07:00  pinnacle
# create vds.232
#
 *
 * History:
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *	03/26/01	ylong		TR4984
 * -------------------------------------------------------------------*/

/*
/*  History :
/*	PL  : 19 fev 93	  creation date.
/*
/* */

class implementation SMCpTxt;

#include <math.h>
#include "grdpbdef.h"
#include "grdpbmacros.h"
#include "emsmass.h"

#include "exdef.h"
#include "exmacros.h"

#include "VDSutil_def.h" 
#include "vdsmacros.h"
#include "SMdef.h"
#include "SMcomp_def.h"

#include "AS_status.h"
#include "v_dbgmacros.h"

#define vdsDEBUG	1

from	GR3dtext	import	GRgenabsg;

/* ******************* MSG ACconstruct_feet () ************************	*/

method	ACconstruct_feet( IGRlong *rc; IGRint cn_type; 
				IGRint count; struct GRid list[];
				struct GRmd_env *md_env;
				IGRint *fcount; struct GRid *feet_list )
{
 /* Root list:
 /*
 /*	- Dynamic collection 
 /*	- text_id
 /*
 /* */

 IGRint			i, k;
 IGRlong 		status, loc_msg;
 IGRshort		matrix_type, level, is_consume, is_display;
 IGRdouble		vect[3], dx, dy, dz, aa;
 IGRlong                sizebuf, nret;
 struct IGRdisplay      display;
 struct GRobj_env	text;
 struct GRid		copy;
 struct	GRvg_construct  cst;
 IGRmatrix		matrix;
 struct GRsymbology	symb;


 *fcount = 0;
 *rc     = 0;


 /* Set the construction list 
 /* */

 cst.msg        = &loc_msg;
 cst.newflag    = FALSE;
 cst.geometry   = NULL;
 cst.env_info   = md_env;
 cst.class_attr = NULL;
 cst.name       = NULL;
 cst.properties	= GRIS_LOCATABLE | GRIS_DISPLAYABLE;

 feet_list[0].objid = NULL_OBJID;
 feet_list[0].osnum = md_env->md_id.osnum;

 sizebuf = sizeof(struct IGRdisplay);
 gr$get_active_display(msg     = &loc_msg,
                       sizbuf  = &sizebuf,
                       buffer  = &display,
                       nret    = &nret);

 /*| get the active level */

 sizebuf = sizeof(IGRshort);
 gr$get_active_level(msg     = &loc_msg,
                     sizbuf  = &sizebuf,
                     buffer  = &level,
                     nret    = &nret);
 cst.display    = &display;
 cst.level      = level;




 status = om$send(msg = message NDmacro.ACreturn_foot(&loc_msg, 
			".", &text.obj_id, &text.mod_env.md_env.matrix_type, 
			text.mod_env.md_env.matrix),
                  senderid = NULL_OBJID,
		  targetid = list[1].objid,
		  targetos = list[1].osnum );
 as$status();
 if(!(status & loc_msg & 1)) {
	printf("ERROR return_foot\n");
	goto wrapup;
 }

 status = om$send(msg = message GRvg.GRgetsymb(&loc_msg, 
			&symb),
                  senderid = NULL_OBJID,
		  targetid = text.obj_id.objid,
		  targetos = text.obj_id.osnum );
 as$status();
 if(!(status & loc_msg & 1)) {
	feet_list[0].objid = NULL_OBJID;
	goto wrapup;
 }

 text.mod_env.md_id.osnum = text.obj_id.osnum;
 ex$get_modid(	mod_osnum = text.mod_env.md_id.osnum,
		mod_id = &text.mod_env.md_id.objid);


 status = om$send(msg = message SMmgr.SMGetAttDbl(&loc_msg,"delta_x",
                        &dx, NULL),
                        targetid = my_id);
 if(!(status & loc_msg & 1))
  {
    printf("No delta_x defined for the surface\n");
    goto wrapup;
  }

 status = om$send(msg = message SMmgr.SMGetAttDbl(&loc_msg,"delta_y",
                        &dy, NULL),
                        targetid = my_id);
 if(!(status & loc_msg & 1))
  {
    printf("No delta_y defined for the surface\n");
    goto wrapup;
  }

 status = om$send(msg = message SMmgr.SMGetAttDbl(&loc_msg,"delta_z",
                        &dz, NULL),
                        targetid = my_id);
 if(!(status & loc_msg & 1))
  {
    printf("No delta_z defined for the surface\n");
    goto wrapup;
  }

 status = om$send(msg = message SMmgr.SMGetAttDbl(&loc_msg,"aa",
			&aa, NULL),
                        targetid = my_id);
 if(!(status & loc_msg & 1))	aa = 0.0;

 k = 0;
 for(i=0;i<3;i++) {
	vect[i] = 	dx * md_env->md_env.matrix[k] +
			dy * md_env->md_env.matrix[k+1] +
			dz * md_env->md_env.matrix[k+2] ;
	k = k+4;
 }

  /* GRxform */
 MAtrlmx(&loc_msg, vect, matrix);

 if( fabs(aa) > 0.00001 )
 {
    IGRpoint			origin;
    IGRmatrix			rot_mat, tmp_mat;
    IGRshort			four=4;
    IGRvector			x_vec;
    struct IGRlbsys         	*lbs = NULL;

    dblcpy( tmp_mat, matrix, 16 );
    status = om$send(msg = message GR3dtext.GRgenabsg( &loc_msg,
					&text.mod_env.md_env.matrix_type,
					text.mod_env.md_env.matrix,
					(IGRchar**)&lbs ),	
                  senderid = NULL_OBJID,
                  targetid = text.obj_id.objid,
                  targetos = text.obj_id.osnum );
    if(!(status & loc_msg & 1) || !lbs  )
    {
        printf("Problem getting Text location\n");
        goto wrapup;
    }
    __DBGpr_mat("Translation Matrix ", tmp_mat );

    for( i=0; i<3; ++i ) x_vec[i]  = lbs->matrix[4*i+2] ;
    for( i=0; i<3; ++i ) origin[i] = lbs->matrix[4*i+3] ;
    __DBGpr_vec("X vector ", x_vec );

    MAgrotmx( &loc_msg, x_vec, origin, &aa, rot_mat );
    __DBGpr_mat("Rotation Matrix ", rot_mat );

    MAmulmx( &loc_msg, &four, &four, &four, tmp_mat, rot_mat, matrix );
    __DBGpr_mat("Final Matrix ", matrix );

    if( lbs ) {  om$dealloc( ptr = lbs );  	lbs = NULL; }
 }

 MAtypemx(&loc_msg, matrix, &matrix_type);

 copy.osnum = md_env->md_id.osnum;

 status = om$send(msg = message GRgraphics.GRcopy(&loc_msg, 
			&text.mod_env, md_env,
			&copy.objid),
                  senderid = NULL_OBJID,
		  targetid = text.obj_id.objid,
		  targetos = text.obj_id.osnum );
 as$status();
 if(!(status & loc_msg & 1)) {
	feet_list[0].objid = NULL_OBJID;
	goto wrapup;
 }

 status = om$send(msg = message GRgraphics.GRxform(&loc_msg, 
			md_env, &matrix_type, matrix,
			&feet_list[0].objid),
                  senderid = NULL_OBJID,
		  targetid = copy.objid,
		  targetos = copy.osnum );
 as$status();
 if(!(status & loc_msg & 1)) {
	feet_list[0].objid = NULL_OBJID;
	goto wrapup;
 }

 status = om$send(msg = message GRvg.GRputsymb(&loc_msg,&symb),
                  senderid = NULL_OBJID,
		  targetid = feet_list[0].objid,
		  targetos = feet_list[0].osnum );
 as$status();
 if(!(status & loc_msg & 1)) {
	printf("Erreur putsymb object = %d, %d\n",feet_list[0].objid,feet_list[0].osnum ); 
	goto wrapup;
 }
 status = om$send(msg = message GRvg.GRputsymb(&loc_msg,&symb),
		  targetid = my_id);
 as$status();
 if(!(status & loc_msg & 1)) {
	printf("Erreur putsymb object = %d, %d\n",feet_list[0].objid,feet_list[0].osnum ); 
	goto wrapup;
 }



 /* consume the template and  undisplay it */
  is_display = 0;
  is_consume = 1;
  
  status = VDconsume_and_display( list[1], is_consume, is_display, md_env );
  as$status( );
 
 


 *fcount = 1;
 *rc = 1;
 return	OM_S_SUCCESS;

 
wrapup:

 /* Change the state to modified & error */
 status = om$send(msg = message SMmgr.SMChgState(SM_CAL_ERR, SM_CAL_ERR),
                  targetid = my_id );
 as$status();

 status = om$send(msg = message SMmgr.SMChgState(SM_STATE, SM_MOD),
                  targetid = my_id );
 as$status();

 *rc = 0;
 return OM_W_ABORT;
}

end implementation SMCpTxt;
