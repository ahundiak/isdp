/* $Id: SMLtdVoli.I,v 1.1.1.1 2001/01/04 21:07:38 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/smspace/vol / SMLtdVoli.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: SMLtdVoli.I,v $
 *	Revision 1.1.1.1  2001/01/04 21:07:38  cvs
 *	Initial import to CVS
 *	
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
# Revision 1.1  1997/05/08  13:20:44  pinnacle
# New project VDS 250
#
# Revision 1.1  1996/07/19  20:33:52  pinnacle
# Create VDS 241 project
#
# Revision 1.4  1996/04/29  09:19:26  pinnacle
# Replaced: smspace/vol/SMLtdVoli.I for:  by ksundar for vds.240
#
# Revision 1.3  1996/01/24  20:05:48  pinnacle
# Replaced: ./smspace/vol/SMLtdVoli.I for:  by azuurhou for vds.240
#
# Revision 1.2  1995/12/14  12:13:06  pinnacle
# Replaced: smspace/vol/SMLtdVoli.I for:  by rgade for vds.240
#
# Revision 1.1  1994/11/14  22:42:32  pinnacle
# Create vds.240 from vds.232
#
# Revision 1.1  1994/11/08  16:07:00  pinnacle
# create vds.232
#
 *
 * History:
 *	MM/DD/YY	AUTHOR	DESCRIPTION
 *	11/02/92	alc	creation date
 *	01/24/96	adz	Control error message system.
 *
 * -------------------------------------------------------------------*/


class implementation SMLtdVol ;
   
#include <stdio.h>
#include "AS_status.h"
#include "msmacros.h"
#include "OMmacros.h"
#include "OMprimitives.h"
#include "grdpbdef.h"
#include "grdpbmacros.h"
#include "nddef.h"
#include "ndmacros.h"
#include "acrepdef.h"
#include "acrepmacros.h"
#include "asbox.h"

#include "grerr.h"
#include "vds.h"
#include "VDmsg.h"
#include "SMmsg.h"
#include "VDmem.h"



/*
	----------------------------------------------------------
 */


method ACmplace_from_def(int *rc, prop ;
		char rep ; char *macro_name ;
	       	int num_temp ;	struct GRid *temp_list ;
		struct GRid *def_occ ;
		struct GRmd_env *md_env)

{
	IGRlong		status;

	/*
	 * Put the properties to no protect:
	 *	- Does not create source,
	 *	- Does not verify the number (variable number of templates) 
	 *	- Does not verify the template types
	 */

	prop = prop | AChdr_noprotect | ACcant_place_sym ;
 
	return om$send(	msg = message ACncpx.ACmplace_from_def(
						rc, prop, rep, 
						macro_name,
						num_temp, temp_list,
						def_occ, md_env),
			mode     = OM_e_wrt_message,
			targetid = my_id ) ; 

} /* ACmplace_from_def() */

/*
	----------------------------------------------------------
 */

method GRgetobjinfo(IGRlong *rc ; struct GRobj_info *info)

{
	*rc = MSSUCC ; 
	strcpy(info->type,"Limited Volume") ;
	return	OM_S_SUCCESS ;

} /* GRgetobjinfo() */

/*
	----------------------------------------------------------
 */

method	ACconstruct_feet( IGRlong *rc; IGRint cn_type; 
				IGRint count; struct GRid list[];
				struct GRmd_env *md_env;
				IGRint *fcount; struct GRid *feet_list )
{
IGRlong			status, SMmsg ;
IGRlong			sizebuf, nret ;
struct ret_struct       str ;
IGRint			consume_exp ;
IGRboolean		consume_parents ;
IGRint			i_par ;
struct GRvg_construct	cst ;
struct IGRdisplay	display ;
IGRshort		level ;
struct GRmd_env		my_env   ;
GRobjid			*go_list ; 
struct GRobj_env	aux_go ;   /* auxiliary g.o. owned by a parent  */
struct GRid		volume ;
extern IGRlong		SMmakeLtdVolume() ;

 *fcount = 0 ;
 feet_list[0].objid = NULL_OBJID ;
 go_list = NULL ;
 *rc = MSFAIL ;


/*
	Initialize construction list
 */

 my_env = *md_env;
 my_env.md_id.objid = NULL_OBJID; /* Computation out of RTREE */

 cst.msg        = &SMmsg ;
 cst.newflag    = FALSE ;
 cst.geometry   = NULL ;
 cst.env_info   = &my_env ;
 cst.class_attr = NULL ;
 cst.name       = NULL ;
 cst.properties	= GRIS_LOCATABLE | GRIS_DISPLAYABLE ;

 sizebuf = sizeof(struct IGRdisplay) ;
 gr$get_active_display(msg     = &status,
                       sizbuf  = &sizebuf,
                       buffer  = &display,
                       nret    = &nret) ; 
 as$status(action = GOTO_VALUE, value = wrapup) ;

 sizebuf = sizeof(IGRshort) ;
 gr$get_active_level(msg     = &status,
                     sizbuf  = &sizebuf,
                     buffer  = &level,
                     nret    = &nret) ;
 as$status(action = GOTO_VALUE, value = wrapup) ;
 cst.display    = &display;
 cst.level      = level;


/*
	Make a limited volume
 */

/* Get the first parent which is an expression */

status = om$send(msg = message NDnode.NDgive_structure(&SMmsg, &str, NULL),
                        targetid= list[0].objid,
                        targetos= list[0].osnum);
as$status(action = GOTO_VALUE, value = wrapup) ;
if (!(SMmsg & 1)) {
	status = OM_E_ABORT ; 
	as$status(action = GOTO_VALUE, value = wrapup) ;
	}
consume_exp = (IGRint) str.var.root_pm_st.value ;
if (! consume_exp)	consume_parents = FALSE ;
else			consume_parents = TRUE  ;

/* Get graphic objects from the other parents, and copy them */

go_list = _MALLOC((count-1), GRobjid) ;
if (go_list == NULL) {
	status = OM_E_ABORT ; as$status(action = GOTO_VALUE, value = wrapup) ;
	}

for (i_par = 1 ; i_par < count ; i_par ++) {

 	status = om$send(msg = message NDnode.ASreturn_go(
			&aux_go.obj_id,
			&aux_go.mod_env.md_env.matrix_type,
			aux_go.mod_env.md_env.matrix),
		targetid = list[i_par].objid,
		targetos = list[i_par].osnum) ; 
	as$status(action = GOTO_VALUE, value = wrapup) ;
	aux_go.mod_env.md_id.objid = NULL_OBJID ;
	aux_go.mod_env.md_id.osnum = aux_go.obj_id.osnum ;

 	status = om$send(msg = message GRgraphics.GRcopy(
			&SMmsg,
			&aux_go.mod_env,	
			&my_env,		/* copy's environment */
			&go_list[i_par - 1]),   /* watch out !        */
		targetid = aux_go.obj_id.objid,
		targetos = aux_go.obj_id.osnum) ; 
	as$status(action = GOTO_VALUE, value = wrapup) ;
	if (!(SMmsg & 1)) {
		status = OM_E_ABORT ; 
		as$status(action = GOTO_VALUE, value = wrapup) ;
		}

	if (consume_parents) {
 	   status = om$send(msg = message NDmacro.ACconsume(&SMmsg, 
				"",
				0, 	/* no copy */
				NULL,
				&my_env),
		targetid = list[i_par].objid,
		targetos = list[i_par].osnum) ; as$status() ;
	} 
	/* They may be in consume state,unconsume it TR#179528414  -Ravi */

	else  {
 	      status = om$send(msg = message NDmacro.ACunconsume(&SMmsg, ""),
			targetid = list[i_par].objid,
			targetos = list[i_par].osnum) ; as$status() ;
	}
	

	} /* for each surface */

/* Create limited volume */

status = SMmakeLtdVolume(&SMmsg, go_list, count - 1, &cst, &volume) ;
if (!(status & SMmsg & 1)) {
	/*
		Unconsume surface parents if they have been consumed
	 */
	if (consume_parents) {
	   for (i_par = 1 ; i_par < count ; i_par ++) {
 	      status = om$send(msg = message NDmacro.ACunconsume(&SMmsg, ""),
			targetid = list[i_par].objid,
			targetos = list[i_par].osnum) ; as$status() ;
	   }
	}
	status = OM_E_ABORT ;
	status = OM_E_ABORT ; 
	goto wrapup ;
}

/*
	Set the macro foot
 */

 *fcount = 1 ;
 feet_list[0] = volume ;
 *rc = MSSUCC ; 
 status = OM_S_SUCCESS ; /* so far */

 wrapup:

	_FREE (go_list);
	return status ;

} /* ACconstruct_feet() */


/*
	----------------------------------------------------------
 */


method GRdelete(IGRlong *rc ; struct GRmd_env *md_env)

{
IGRlong			status, SMmsg ;
struct ret_struct       str ;
IGRint			i_par, num_par ;
IGRint			consume_exp  ;
IGRboolean		consume_parents ;
struct GRid		surf_parent  ;
struct GRobj_env	aux_go ;
struct GRid		display_info ;
enum GRdpmode 		mode ;
extern 			GRfindmod() ;

/* 
	Get consume_parents expression value
 */

status = om$send(msg = message NDnode.NDget_objects(
			ND_ROOT, NULL, 0, NULL, 0, OM_K_MAXINT, &num_par),
               targetid = my_id) ;
as$status(action = GOTO_VALUE, value = wrapup) ;

/* First parent is an expression */
status = om$send( msg = message  ACcpx.ACfind_exp_temp_struct(
			(int *)&SMmsg, 0, &str, md_env),
                  targetid = my_id) ;
as$status(action = GOTO_VALUE, value = wrapup) ;
if (!(SMmsg & 1)) {
	status = OM_E_ABORT ; as$status(action = GOTO_VALUE, value = wrapup) ;
	}

consume_exp = (IGRint) str.var.root_pm_st.value ;
if (! consume_exp)	consume_parents = FALSE ;
else			consume_parents = TRUE  ;

/*
	Unconsume surface parents if needed
 */

if (consume_parents) {
	#ifdef DEBUG
	printf("consume_parents is TRUE \n") ;
	#endif

	for (i_par = 1 ; i_par < num_par ; i_par ++) {
	   /* Get surface parent */
           status = om$send( msg = message  ACcpx.ACfind_exp_temp_obj(
                                       (int *)&SMmsg, i_par, &surf_parent),
               		     targetid = my_id) ;
	   as$status(action = GOTO_VALUE, value = wrapup) ;
	   if (!(SMmsg & 1)) {
	      status = OM_E_ABORT ; 
	      as$status(action = GOTO_VALUE, value = wrapup) ;
	      }
           status = om$send( msg = message  ACcpx.ACunconsume(&SMmsg, ""),
               		     targetid = surf_parent.objid,
			     targetos = surf_parent.osnum) ;
	   as$status(action = GOTO_VALUE, value = wrapup) ;
	   if (!(SMmsg & 1)) {
	      status = OM_E_ABORT ; 
	      as$status(action = GOTO_VALUE, value = wrapup) ;
	      }

	   /* Re-display owned graphic object */
 	   status = om$send(msg = message NDnode.ASreturn_go(
			&aux_go.obj_id,
			&aux_go.mod_env.md_env.matrix_type,
			aux_go.mod_env.md_env.matrix),
		targetid = surf_parent.objid,
		targetos = surf_parent.osnum) ; 
	   as$status(action = GOTO_VALUE, value = wrapup) ;
	   aux_go.mod_env.md_id.objid = NULL_OBJID ;
	   aux_go.mod_env.md_id.osnum = aux_go.obj_id.osnum ;

	   GRfindmod(&display_info) ;
	   mode = GRbd ;
           status = om$send(msg = message GRgraphics.GRdisplay(
                                    &SMmsg,
                                    &aux_go.mod_env.md_env.matrix_type,
                                    aux_go.mod_env.md_env.matrix,
                                    &mode,
                                    &display_info),
                       targetid = aux_go.obj_id.objid,
                       targetos = aux_go.obj_id.osnum) ;
	   as$status(action = GOTO_VALUE, value = wrapup) ;
	   if (!(SMmsg & 1)) {
	      status = OM_E_ABORT ; 
	      as$status(action = GOTO_VALUE, value = wrapup) ;
	      }
	   }
	} /* if */

wrapup :
status = om$send(msg  = message ASnode.GRdelete(rc, md_env),
                  mode = OM_e_wrt_message,
                  targetid= my_id) ; as$status() ;
return	status ;
} /* GRdelete() */


/*
	----------------------------------------------------------
 */

/*   Modif PL 06-29-93  
	Kluddge waiting that the feet management is correctly done !!!!. */


method ACgive_path(int *suc;struct GRid *go_obj;char *foot_name)
{
        int i,sts;
        struct GRid pied;
        OM_S_CHANSELECT chansel;

        chansel.type = OM_e_name;
        chansel.u_sel.name = "GRcmpowner.to_components";

        /**** must find pied see give_foot ****/
        pied.objid = NULL_OBJID;
        sts = om$get_objid_at_index
                             ( object =         me,
                               p_chanselect =   &chansel,
                               index =          0,
                               objidaddr =      &pied.objid,
                               osnumaddr =      &pied.osnum);

        if( (1&sts) && pied.objid != NULL_OBJID ){
            /*| get the index of the object go_obj*/
            get_index_of_surf(pied, &i, *go_obj );
            if( i != -1 ){
                sprintf(foot_name,"$%d", i );
                /*"ACgivepath, foot_name created: %s\n ",foot_name */
                return ( *suc =OM_S_SUCCESS );
            }
        }

        /*"ACgivepath failed, call normal message \n"*/
        return om$send(msg= message ACncpx.ACgive_path
                                                (suc,go_obj,foot_name),
                        targetid=my_id,
                        mode = OM_e_wrt_message);
}

method ACreturn_foot(long *suc;char *foot_name; struct GRid *foot_GRid;
                     IGRshort *mat_type; IGRdouble *matrix)
{
        int ix;         /* index */
        int sts,loc_msg;
        OM_S_CHANSELECT chansel;
        struct GRid pied;

        *suc = 0;

        if( foot_name[0] != '$' ){
                return om$send( msg = message ACncpx.ACreturn_foot
                                        ( suc, foot_name, foot_GRid,
                                          mat_type, matrix),
                         targetid = my_id,
                         mode = OM_e_wrt_message);
        }
        chansel.type = OM_e_name;
        chansel.u_sel.name = "GRcmpowner.to_components";

        /**** must find real feet
        /**** we assume this is the 1st one on the channel to_component
        /* */
        pied.objid = NULL_OBJID;
        sts = om$get_objid_at_index
                             ( object =         me,
                               p_chanselect =   &chansel,
                               index =          0,
                               objidaddr =      &pied.objid,
                               osnumaddr =      &pied.osnum);
        if(!(1&sts) )
                return sts;
        if( pied.objid == NULL_OBJID )
                return *suc = 0;

        ix = -1;
        sscanf(&foot_name[1],"%d", &ix );
        if( !get_surf_at_index(pied, ix, foot_GRid ) )
                return *suc = 0;
        /*"ci_mac_bib.ACgive_foot, foot:%d %d\n",foot_GRid->objid,
                                foot_GRid->osnum */

        if(mat_type) *mat_type = MAIDMX;
        if(matrix) MAidmx(&loc_msg,matrix);

        *suc = 1; /*return real graphic object */

        return(sts);
}


/*----------------------------------------------------------------------------*/
method VDgetObjDef( long *msg ; VDobjDef *myDef ) {

	long		sts ;	/* OM return code	*/

	/*
	 * name.
	 */
	myDef->info		= SM_I_ObjLtdVol ;
	myDef->type		= 0 ;

	sts	= OM_S_SUCCESS ;
	*msg	= MSSUCC ;

	return sts ;

} /* method VDgetObjdDef */
/*----------------------------------------------------------------------------*/

end implementation SMLtdVol ;
 

