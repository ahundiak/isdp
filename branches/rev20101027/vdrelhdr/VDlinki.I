/* $Id: VDlinki.I,v 1.1.1.1 2001/01/04 21:09:06 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/vdrelhdr / VDlinki.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VDlinki.I,v $
 *	Revision 1.1.1.1  2001/01/04 21:09:06  cvs
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
# Revision 1.2  1995/10/25  17:27:04  pinnacle
# Replaced: vdrelhdr/VDlinki.I for:  by tlbriggs for vds.240
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
 *	10/25/95	tlb		EMS 3.2: changed cs.h to grcoordsys.h
 *
 * -------------------------------------------------------------------*/

/*
/*  History :
/*	LLC :- march 92	 + creation date
/*
/* */

class implementation VDlink;

#include "OMmacros.h"
#include "godef.h"
#include "grerr.h"
#include "grdpbdef.h"
#include "grdpbmacros.h"
#include "AS_status.h"
#include "nddef.h"
#include "ndmacros.h"
#include "asdef.h"
#include "asmacros.h"
#include "asbox.h"
#include "madef.h"
#include "gr.h"
#include "igr.h"
#include "igrdp.h"
#include "go.h"
#include "batch.h"
#include "csdef.h"
#include "griodef.h"
#include "grcoordsys.h"
#include "nddef.h"


#define	AS_DEBUG

#define	AC_MAX_MASTER_COUNT	5


long ACSforwardMess( struct GRid id, OM_p_MESSAGE mess )

{
IGRlong		sts, msg;
struct	GRid	master[AC_MAX_MASTER_COUNT];
struct	GRid	*my_mast;
IGRint		mast_count;
IGRint		i;

	/*| initialization */
	my_mast	= master;

	sts = om$send(	msg	= message VDlink.ACget_model_list(
					&msg,
					AC_MAX_MASTER_COUNT,
					master,
					&mast_count ),
			senderid = NULL_OBJID,
			targetid = id.objid,
			targetos = id.osnum );
	as$status( sts = sts );

	if( mast_count > AC_MAX_MASTER_COUNT ){

		printf(" Warning : master list is too short, realloc space \n");
		mast_count	= AC_MAX_MASTER_COUNT;
	}

	for( i=0; i<mast_count; i++ ){

		sts = om$send(	msg	 = mess,
				senderid = NULL_OBJID,
				targetid = my_mast[i].objid,
				targetos = my_mast[i].osnum );
		as$status( sts = sts );
	}

return	sts;
}


method GRlocaldp(IGRlong *msg; IGRshort *type; IGRmatrix matrix;
        struct GRparms *parms; enum GRdpmode *mode;
        struct GRid *display_info; IGRshort *display_location;
        IGRshort *display_flag)

{
IGRlong		sts;
struct	GRid	master[AC_MAX_MASTER_COUNT];
struct	GRid	*my_mast;
IGRint		mast_count;
IGRint		i;

	/*| initialization */
	my_mast	= master;

	sts = om$send(	msg	= message VDlink.ACget_model_list(
					msg,
					AC_MAX_MASTER_COUNT,
					master,
					&mast_count ),
			targetid = my_id );
	as$status( sts = sts );

	if( mast_count > AC_MAX_MASTER_COUNT ){

		printf(" Warning : master list is too short, realloc space \n");
		mast_count	= AC_MAX_MASTER_COUNT;
	}

	for( i=0; i<mast_count; i++ ){

		sts = om$send(	msg	 = OPPmargs,
				targetid = my_mast[i].objid,
				targetos = my_mast[i].osnum );
		as$status( sts = sts );
	}

return	sts;
}

method GRclip(IGRlong *msg; struct GRmd_env *cur_env;
       struct GRmd_env *target_env; IGRchar  *prism;
       struct GRid *inside_id; struct GRid *outside_id;
       struct GRid *ovl_id; IGRlong *clip_flags)
{
IGRlong		sts;
struct	GRid	master[AC_MAX_MASTER_COUNT];
struct	GRid	*my_mast;
IGRint		mast_count;
IGRint		i;

	/*| initialization */
	my_mast	= master;

	sts = om$send(	msg	= message VDlink.ACget_model_list(
					msg,
					AC_MAX_MASTER_COUNT,
					master,
					&mast_count ),
			targetid = my_id );
	as$status( sts = sts );

	if( mast_count > AC_MAX_MASTER_COUNT ){

		printf(" Warning : master list is too short, realloc space \n");
		mast_count	= AC_MAX_MASTER_COUNT;
	}

	for( i=0; i<mast_count; i++ ){

		sts = om$send(	msg	 = OPPmargs,
				targetid = my_mast[i].objid,
				targetos = my_mast[i].osnum );
		as$status( sts = sts );
	}

return	sts;
}

method GRcopy(IGRlong *msg; struct GRmd_env *obj_dsenv;
       struct GRmd_env *new_dsenv; GRobjid *newobjid)
{
IGRlong		sts;
struct	GRid	master[AC_MAX_MASTER_COUNT];
struct	GRid	*my_mast;
IGRint		mast_count;
IGRint		i;

	/*| initialization */
	my_mast	= master;

	sts = om$send(	msg	= message VDlink.ACget_model_list(
					msg,
					AC_MAX_MASTER_COUNT,
					master,
					&mast_count ),
			targetid = my_id );
	as$status( sts = sts );

	if( mast_count > AC_MAX_MASTER_COUNT ){

		printf(" Warning : master list is too short, realloc space \n");
		mast_count	= AC_MAX_MASTER_COUNT;
	}

	for( i=0; i<mast_count; i++ ){

		sts = om$send(	msg	 = OPPmargs,
				targetid = my_mast[i].objid,
				targetos = my_mast[i].osnum );
		as$status( sts = sts );
	}

return	sts;
}

method GRrcopy(IGRlong *msg; struct GRmd_env *obj_dsenv;
       struct GRmd_env *new_dsenv; GRobjid *newobjid)
{
IGRlong		sts;
struct	GRid	master[AC_MAX_MASTER_COUNT];
struct	GRid	*my_mast;
IGRint		mast_count;
IGRint		i;

	/*| initialization */
	my_mast	= master;

	sts = om$send(	msg	= message VDlink.ACget_model_list(
					msg,
					AC_MAX_MASTER_COUNT,
					master,
					&mast_count ),
			targetid = my_id );
	as$status( sts = sts );

	if( mast_count > AC_MAX_MASTER_COUNT ){

		printf(" Warning : master list is too short, realloc space \n");
		mast_count	= AC_MAX_MASTER_COUNT;
	}

	for( i=0; i<mast_count; i++ ){

		sts = om$send(	msg	 = OPPmargs,
				targetid = my_mast[i].objid,
				targetos = my_mast[i].osnum );
		as$status( sts = sts );
	}

return	sts;
}

method GRgentform(IGRlong *msg; struct GRmd_env *md_env;
        IGRint (*tform_function)(); IGRchar *info; GRobjid *newobjid)
{
IGRlong		sts;
struct	GRid	master[AC_MAX_MASTER_COUNT];
struct	GRid	*my_mast;
IGRint		mast_count;
IGRint		i;

	/*| initialization */
	my_mast	= master;

	sts = om$send(	msg	= message VDlink.ACget_model_list(
					msg,
					AC_MAX_MASTER_COUNT,
					master,
					&mast_count ),
			targetid = my_id );
	as$status( sts = sts );

	if( mast_count > AC_MAX_MASTER_COUNT ){

		printf(" Warning : master list is too short, realloc space \n");
		mast_count	= AC_MAX_MASTER_COUNT;
	}

	for( i=0; i<mast_count; i++ ){

		sts = om$send(	msg	 = OPPmargs,
				targetid = my_mast[i].objid,
				targetos = my_mast[i].osnum );
		as$status( sts = sts );
	}

return	sts;
}

method GRcptform(IGRlong *msg; struct GRmd_env *md_env;
        IGRmatrix matrix; struct GRmd_env *new_env; GRobjid *newobjid)
{
IGRlong		sts;
struct	GRid	master[AC_MAX_MASTER_COUNT];
struct	GRid	*my_mast;
IGRint		mast_count;
IGRint		i;

	/*| initialization */
	my_mast	= master;

	sts = om$send(	msg	= message VDlink.ACget_model_list(
					msg,
					AC_MAX_MASTER_COUNT,
					master,
					&mast_count ),
			targetid = my_id );
	as$status( sts = sts );

	if( mast_count > AC_MAX_MASTER_COUNT ){

		printf(" Warning : master list is too short, realloc space \n");
		mast_count	= AC_MAX_MASTER_COUNT;
	}

	for( i=0; i<mast_count; i++ ){

		sts = om$send(	msg	 = OPPmargs,
				targetid = my_mast[i].objid,
				targetos = my_mast[i].osnum );
		as$status( sts = sts );
	}

return	sts;
}

method GRdisplay(IGRlong *msg;  IGRshort *type; IGRmatrix matrix;
        enum GRdpmode *mode; struct GRid *display_info)
{
IGRlong		sts;
struct	GRid	master[AC_MAX_MASTER_COUNT];
struct	GRid	*my_mast;
IGRint		mast_count;
IGRint		i;

	/*| initialization */
	my_mast	= master;

	sts = om$send(	msg	= message VDlink.ACget_model_list(
					msg,
					AC_MAX_MASTER_COUNT,
					master,
					&mast_count ),
			targetid = my_id );
	as$status( sts = sts );

	if( mast_count > AC_MAX_MASTER_COUNT ){

		printf(" Warning : master list is too short, realloc space \n");
		mast_count	= AC_MAX_MASTER_COUNT;
	}

	for( i=0; i<mast_count; i++ ){

		sts = om$send(	msg	 = OPPmargs,
				targetid = my_mast[i].objid,
				targetos = my_mast[i].osnum );
		as$status( sts = sts );
	}

return	sts;
}

method GRgetprops(IGRlong *msg; IGRshort *props)
{
IGRlong		sts;
struct	GRid	master[AC_MAX_MASTER_COUNT];
struct	GRid	*my_mast;
IGRint		mast_count;
IGRint		i;

	/*| initialization */
	my_mast	= master;

	sts = om$send(	msg	= message VDlink.ACget_model_list(
					msg,
					AC_MAX_MASTER_COUNT,
					master,
					&mast_count ),
			targetid = my_id );
	as$status( sts = sts );

	if( mast_count > AC_MAX_MASTER_COUNT ){

		printf(" Warning : master list is too short, realloc space \n");
		mast_count	= AC_MAX_MASTER_COUNT;
	}

	for( i=0; i<mast_count; i++ ){

		sts = om$send(	msg	 = OPPmargs,
				targetid = my_mast[i].objid,
				targetos = my_mast[i].osnum );
		as$status( sts = sts );
	}

return	sts;
}

method GRgethprops(IGRlong *msg; IGRuint *props)
{
IGRlong		sts;
struct	GRid	master[AC_MAX_MASTER_COUNT];
struct	GRid	*my_mast;
IGRint		mast_count;
IGRint		i;

	/*| initialization */
	my_mast	= master;

	sts = om$send(	msg	= message VDlink.ACget_model_list(
					msg,
					AC_MAX_MASTER_COUNT,
					master,
					&mast_count ),
			targetid = my_id );
	as$status( sts = sts );

	if( mast_count > AC_MAX_MASTER_COUNT ){

		printf(" Warning : master list is too short, realloc space \n");
		mast_count	= AC_MAX_MASTER_COUNT;
	}

	for( i=0; i<mast_count; i++ ){

		sts = om$send(	msg	 = OPPmargs,
				targetid = my_mast[i].objid,
				targetos = my_mast[i].osnum );
		as$status( sts = sts );
	}

return	sts;
}

/* not on 143

method GRchannel_pass(
        GR_S_PATH_LIST  *path;
        int             num_levels;
        OM_p_MESSAGE    msg)
{
IGRlong		sts, rc;
struct	GRid	master[AC_MAX_MASTER_COUNT];
struct	GRid	*my_mast;
IGRint		mast_count;
IGRint		i;

	my_mast	= master;

	sts = om$send(	msg	= message VDlink.ACget_model_list(
					&rc,
					AC_MAX_MASTER_COUNT,
					master,
					&mast_count ),
			targetid = my_id );
	as$status( sts = sts );

	if( mast_count > AC_MAX_MASTER_COUNT ){

		printf(" Warning : master list is too short, realloc space \n");
		mast_count	= AC_MAX_MASTER_COUNT;
	}

	for( i=0; i<mast_count; i++ ){

		sts = om$send(	msg	 = OPPmargs,
				targetid = my_mast[i].objid,
				targetos = my_mast[i].osnum );
		as$status( sts = sts );
	}

return	sts;
}

method GRgetname(IGRlong *msg; IGRchar *name)
{
IGRlong		sts;
struct	GRid	master[AC_MAX_MASTER_COUNT];
struct	GRid	*my_mast;
IGRint		mast_count;
IGRint		i;

	my_mast	= master;

	sts = om$send(	msg	= message VDlink.ACget_model_list(
					msg,
					AC_MAX_MASTER_COUNT,
					master,
					&mast_count ),
			targetid = my_id );
	as$status( sts = sts );

	if( mast_count > AC_MAX_MASTER_COUNT ){

		printf(" Warning : master list is too short, realloc space \n");
		mast_count	= AC_MAX_MASTER_COUNT;
	}

	for( i=0; i<mast_count; i++ ){

		sts = om$send(	msg	 = OPPmargs,
				targetid = my_mast[i].objid,
				targetos = my_mast[i].osnum );
		as$status( sts = sts );
	}

return	sts;
}

end not  in 143 */

method GRgetobjinfo(IGRlong *msg; struct GRobj_info *info)
{
IGRlong		sts;
struct	GRid	master[AC_MAX_MASTER_COUNT];
struct	GRid	*my_mast;
IGRint		mast_count;
IGRint		i;

	/*| initialization */
	my_mast	= master;

	sts = om$send(	msg	= message VDlink.ACget_model_list(
					msg,
					AC_MAX_MASTER_COUNT,
					master,
					&mast_count ),
			targetid = my_id );
	as$status( sts = sts );

	if( mast_count > AC_MAX_MASTER_COUNT ){

		printf(" Warning : master list is too short, realloc space \n");
		mast_count	= AC_MAX_MASTER_COUNT;
	}

	for( i=0; i<mast_count; i++ ){

		sts = om$send(	msg	 = OPPmargs,
				targetid = my_mast[i].objid,
				targetos = my_mast[i].osnum );
		as$status( sts = sts );
	}

return	sts;
}

method GRapprojpt(IGRlong *msg; IGRshort *matrix_type;
        IGRmatrix matrix; struct GRparms *locate_parms;
        struct IGRline *boreline; IGRpoint proj_pt;
        struct GRparms *proj_parms )
{
IGRlong		sts;
struct	GRid	master[AC_MAX_MASTER_COUNT];
struct	GRid	*my_mast;
IGRint		mast_count;
IGRint		i;

	/*| initialization */
	my_mast	= master;

	sts = om$send(	msg	= message VDlink.ACget_model_list(
					msg,
					AC_MAX_MASTER_COUNT,
					master,
					&mast_count ),
			targetid = my_id );
	as$status( sts = sts );

	if( mast_count > AC_MAX_MASTER_COUNT ){

		printf(" Warning : master list is too short, realloc space \n");
		mast_count	= AC_MAX_MASTER_COUNT;
	}

	for( i=0; i<mast_count; i++ ){

		sts = om$send(	msg	 = OPPmargs,
				targetid = my_mast[i].objid,
				targetos = my_mast[i].osnum );
		as$status( sts = sts );
	}

return	sts;
}

method ACgive_structure(int *suc,*direct_index;char *footname;
                struct ret_struct *ptr_rst;struct GRmd_env *md_env)
{
IGRlong		sts, msg;
struct	GRid	master[AC_MAX_MASTER_COUNT];
struct	GRid	*my_mast;
IGRint		mast_count;
IGRint		i;

	/*| initialization */
	my_mast	= master;
	*suc	= 0;

	sts = om$send(	msg	= message VDlink.ACget_model_list(
					&msg,
					AC_MAX_MASTER_COUNT,
					master,
					&mast_count ),
			targetid = my_id );
	as$status( sts = sts );

	if( mast_count > AC_MAX_MASTER_COUNT ){

		printf(" Warning : master list is too short, realloc space \n");
		mast_count	= AC_MAX_MASTER_COUNT;
	}

	for( i=0; i<mast_count; i++ ){

		sts = om$send(	msg	 = OPPmargs,
				targetid = my_mast[i].objid,
				targetos = my_mast[i].osnum );
		as$status( sts = sts );
	}

return	sts;
}

method ACreturn_foot(IGRlong *msg;char *footname;
                struct GRid *foot_obj;IGRshort *mat_type;IGRdouble *matrix)

{
IGRlong		sts;
struct	GRid	master[AC_MAX_MASTER_COUNT];
struct	GRid	*my_mast;
IGRint		mast_count;
IGRint		i;

	/*| initialization */
	my_mast	= master;

	sts = om$send(	msg	= message VDlink.ACget_model_list(
					msg,
					AC_MAX_MASTER_COUNT,
					master,
					&mast_count ),
			targetid = my_id );
	as$status( sts = sts );

	if( mast_count > AC_MAX_MASTER_COUNT ){

		printf(" Warning : master list is too short, realloc space \n");
		mast_count	= AC_MAX_MASTER_COUNT;
	}

	for( i=0; i<mast_count; i++ ){

		sts = om$send(	msg	 = OPPmargs,
				targetid = my_mast[i].objid,
				targetos = my_mast[i].osnum );
		as$status( sts = sts );
	}

return	sts;
}

method NDcompute_node ( IGRlong *msg; IGRint cn_type;
                           IGRint count; struct GRid list [];
                           struct GRmd_env *md_env)
{
//	*msg 	 = ND_COMP_SUCC;	not in 143
	*msg 	 = MSSUCC;

return	OM_S_SUCCESS;
}

method GRdisyourself(IGRlong *msg; IGRshort *mx_type; IGRmatrix
                        matrix;  enum GRdpmode *mode;
			struct IGRaltdisplay *alt_symb;
			struct DP_information *sp_info;
                        OM_p_KEY_DESC range_key)
{ 
IGRlong		sts;
struct	GRid	master[AC_MAX_MASTER_COUNT];
struct	GRid	*my_mast;
IGRint		mast_count;
IGRint		i;

	/*| initialization */
	my_mast	= master;

	sts = om$send(	msg	= message VDlink.ACget_model_list(
					msg,
					AC_MAX_MASTER_COUNT,
					master,
					&mast_count ),
			targetid = my_id );
	as$status( sts = sts );

	if( mast_count > AC_MAX_MASTER_COUNT ){

		printf(" Warning : master list is too short, realloc space \n");
		mast_count	= AC_MAX_MASTER_COUNT;
	}

	for( i=0; i<mast_count; i++ ){

		sts = om$send(	msg	 = OPPmargs,
				targetid = my_mast[i].objid,
				targetos = my_mast[i].osnum );
		as$status( sts = sts );
	}

return	sts;
}

method GRgetrang(IGRlong *msg;IGRshort *matrix_type; IGRmatrix matrix;
        IGRboolean *world; GRrange range)
{
IGRlong		sts;
struct	GRid	master[AC_MAX_MASTER_COUNT];
struct	GRid	*my_mast;
IGRint		mast_count;
IGRint		i;

	/*| initialization */
	my_mast	= master;

	sts = om$send(	msg	= message VDlink.ACget_model_list(
					msg,
					AC_MAX_MASTER_COUNT,
					master,
					&mast_count ),
			targetid = my_id );
	as$status( sts = sts );

	if( mast_count > AC_MAX_MASTER_COUNT ){

		printf(" Warning : master list is too short, realloc space \n");
		mast_count	= AC_MAX_MASTER_COUNT;
	}

	for( i=0; i<mast_count; i++ ){

		sts = om$send(	msg	 = OPPmargs,
				targetid = my_mast[i].objid,
				targetos = my_mast[i].osnum );
		as$status( sts = sts );
	}

return	sts;
}

method GRlnproject(IGRlong *msg; IGRshort *matrix_type;
        IGRmatrix matrix; struct IGRline *line;
        IGRpoint ln_pt,proj_pt; IGRdouble *t;
        struct GRparms *proj_parms)
{
IGRlong		sts;
struct	GRid	master[AC_MAX_MASTER_COUNT];
struct	GRid	*my_mast;
IGRint		mast_count;
IGRint		i;

	/*| initialization */
	my_mast	= master;

	sts = om$send(	msg	= message VDlink.ACget_model_list(
					msg,
					AC_MAX_MASTER_COUNT,
					master,
					&mast_count ),
			targetid = my_id );
	as$status( sts = sts );

	if( mast_count > AC_MAX_MASTER_COUNT ){

		printf(" Warning : master list is too short, realloc space \n");
		mast_count	= AC_MAX_MASTER_COUNT;
	}

	for( i=0; i<mast_count; i++ ){

		sts = om$send(	msg	 = OPPmargs,
				targetid = my_mast[i].objid,
				targetos = my_mast[i].osnum );
		as$status( sts = sts );
	}

return	sts;
}

method GRptproject(IGRlong *msg; IGRshort *matrix_type;
        IGRmatrix matrix; IGRpoint point,proj_pt;
        struct GRparms *proj_parms)
{
IGRlong		sts;
struct	GRid	master[AC_MAX_MASTER_COUNT];
struct	GRid	*my_mast;
IGRint		mast_count;
IGRint		i;

	/*| initialization */
	my_mast	= master;

	sts = om$send(	msg	= message VDlink.ACget_model_list(
					msg,
					AC_MAX_MASTER_COUNT,
					master,
					&mast_count ),
			targetid = my_id );
	as$status( sts = sts );

	if( mast_count > AC_MAX_MASTER_COUNT ){

		printf(" Warning : master list is too short, realloc space \n");
		mast_count	= AC_MAX_MASTER_COUNT;
	}

	for( i=0; i<mast_count; i++ ){

		sts = om$send(	msg	 = OPPmargs,
				targetid = my_mast[i].objid,
				targetos = my_mast[i].osnum );
		as$status( sts = sts );
	}

return	sts;
}

method GRprismrel(IGRlong *msg; IGRshort *mx_type; IGRmatrix matrix;
        IGRlong *prism_rel; IGRshort *type_prism; IGRchar *prism;
        IGRlong *relationship )
{
IGRlong		sts;
struct	GRid	master[AC_MAX_MASTER_COUNT];
struct	GRid	*my_mast;
IGRint		mast_count;
IGRint		i;

	/*| initialization */
	my_mast	= master;

	sts = om$send(	msg	= message VDlink.ACget_model_list(
					msg,
					AC_MAX_MASTER_COUNT,
					master,
					&mast_count ),
			targetid = my_id );
	as$status( sts = sts );

	if( mast_count > AC_MAX_MASTER_COUNT ){

		printf(" Warning : master list is too short, realloc space \n");
		mast_count	= AC_MAX_MASTER_COUNT;
	}

	for( i=0; i<mast_count; i++ ){

		sts = om$send(	msg	 = OPPmargs,
				targetid = my_mast[i].objid,
				targetos = my_mast[i].osnum );
		as$status( sts = sts );
	}

return	sts;
}

method GRlocate(struct GRlc_cvl *cvl; OM_p_KEY_DESC range_key)

{
IGRlong		sts, msg;
struct	GRid	master[AC_MAX_MASTER_COUNT];
struct	GRid	*my_mast;
IGRint		mast_count;
IGRint		i;

	/*| initialization */
	my_mast	= master;

	sts = om$send(	msg	= message VDlink.ACget_model_list(
					&msg,
					AC_MAX_MASTER_COUNT,
					master,
					&mast_count ),
			targetid = my_id );
	as$status( sts = sts );

	if( mast_count > AC_MAX_MASTER_COUNT ){

		printf(" Warning : master list is too short, realloc space \n");
		mast_count	= AC_MAX_MASTER_COUNT;
	}

	for( i=0; i<mast_count; i++ ){

		sts = om$send(	msg	 = OPPmargs,
				targetid = my_mast[i].objid,
				targetos = my_mast[i].osnum );
		as$status( sts = sts );
	}

return	sts;
}

method unknown(OM_S_MESSAGE *msg)
{
IGRlong		sts, rc;
struct	GRid	master[AC_MAX_MASTER_COUNT];
struct	GRid	*my_mast;
IGRint		mast_count;
IGRint		i;

	/*| initialization */
	my_mast	= master;

	sts = om$send(	msg	= message VDlink.ACget_model_list(
					&rc,
					AC_MAX_MASTER_COUNT,
					master,
					&mast_count ),
			targetid = my_id );
	as$status( sts = sts );

	if( mast_count > AC_MAX_MASTER_COUNT ){

		printf(" Warning : master list is too short, realloc space \n");
		mast_count	= AC_MAX_MASTER_COUNT;
	}

	for( i=0; i<mast_count; i++ ){

		sts = om$send(	msg	 = msg,
				targetid = my_mast[i].objid,
				targetos = my_mast[i].osnum );
		if( sts == OM_W_UNKNOWN_MSG )	sts = OM_S_SUCCESS;
		as$status( sts = sts );
	}

return	sts;
}

/* ************** MSG ACdisconnect_head () ****************************	*/

method ACdisconnect_head( IGRlong *rc; struct GRid *header; 
						struct GRmd_env *md_env )

{
IGRlong		sts;
struct	GRid	hdr;

	/*| disconnect model and header */
	sts = om$send(	msg	 = message Root.disconnect(
					AS_to_owner,
					header->objid,
					header->osnum,
					AS_to_comp ),
			targetid = my_id );
	as$status( sts = sts, msg = "Error in msg disconnect" );

	sts = om$get_objid_at_index(	object		= me,
					p_chanselect	= &AS_to_owner,
					index		= 0,
					objidaddr	= &hdr.objid,
					osnumaddr	= &hdr.osnum );
	if( ! (sts & 1))
		sts = om$send(	msg	 = message NDnode.NDdelete( md_env ),
				targetid = my_id );

return	sts;
}

/* ********************* NDmove_to_root () ****************************	*/

method NDmove_to_root (IGRlong *rc; struct GRid *src_grid;
						struct GRmd_env *md_env )
{
IGRlong		sts, msg;
enum GRdpmode	dpmode;

	/*| display off */
	dpmode	= GRbeheo;
	sts = om$send(	msg	 = message GRgraphics.GRdisplay(
					&msg,
					&md_env->md_env.matrix_type,
					md_env->md_env.matrix,
					&dpmode,
					&md_env->md_id ),
			p_chanselect = &AS_to_owner );

	sts = om$send(	msg	 = message NDnode.NDdelete( md_env ),
			p_chanselect = &AS_to_owner );
	as$status( sts = sts );

return	sts;
}


/* **************** MSG NDdrawing_copy_geom () ********************	*/

method NDdrawing_copy_geom
                (struct GRid *selected_elements;
                 int    nb_elements;
                 struct GRid **drawing_elements;
                 int    *nb_drawing_elem;
                 double *vector,*point;
                 int *level; struct IGRlbsys *lbsys;
                 struct GRmd_env *from_env,*to_env)

{
IGRlong		sts, msg;
struct	GRid	master[AC_MAX_MASTER_COUNT];
struct	GRid	*my_mast;
IGRint		mast_count;
IGRint		i;

	/*| initialization */
	my_mast	= master;

	sts = om$send(	msg	= message VDlink.ACget_model_list(
					&msg,
					AC_MAX_MASTER_COUNT,
					master,
					&mast_count ),
			targetid = my_id );
	as$status( sts = sts );

	if( mast_count > AC_MAX_MASTER_COUNT ){

		printf(" Warning : master list is too short, realloc space \n");
		mast_count	= AC_MAX_MASTER_COUNT;
	}

	for( i=0; i<mast_count; i++ ){

		sts = om$send(	msg	 = OPPmargs,
				targetid = my_mast[i].objid,
				targetos = my_mast[i].osnum );
		as$status( sts = sts );
	}

return	sts;
}

method NDdrawing_copy_attr
              (struct myfeet *attr_name; int nb_attr; struct GRid *drawing_attr;
                 struct GRmd_env *from_env,*to_env )

{
IGRlong		sts, msg;
struct	GRid	master[AC_MAX_MASTER_COUNT];
struct	GRid	*my_mast;
IGRint		mast_count;
IGRint		i;

	/*| initialization */
	my_mast	= master;

	sts = om$send(	msg	= message VDlink.ACget_model_list(
					&msg,
					AC_MAX_MASTER_COUNT,
					master,
					&mast_count ),
			targetid = my_id );
	as$status( sts = sts );

	if( mast_count > AC_MAX_MASTER_COUNT ){

		printf(" Warning : master list is too short, realloc space \n");
		mast_count	= AC_MAX_MASTER_COUNT;
	}

	for( i=0; i<mast_count; i++ ){

		sts = om$send(	msg	 = OPPmargs,
				targetid = my_mast[i].objid,
				targetos = my_mast[i].osnum );
		as$status( sts = sts );
	}

return	sts;
}


/* ******************* MSG ACget_model_list () ************************	*/

method ACget_model_list( IGRlong *rc; IGRint len_list; struct	GRid *mo_list;
				IGRint	*model_count )
{
IGRlong		msg, sts;
IGRint		i;
IGRint		nb_master;
struct	GRid	cur_master, master[AC_MAX_MASTER_COUNT];

	/*| initialization */
	*rc		= MSFAIL;
	*model_count	= 0;
	nb_master	= 0;
	if( mo_list == NULL )	len_list	= 0;

	sts = om$send(	msg	 = message NDnode.NDget_objects(
					ND_ROOT,
					master,
					AC_MAX_MASTER_COUNT,
					NULL,
					NULL,
					OM_K_MAXINT,
					&nb_master ),
			targetid = my_id );
	as$status( sts = sts, action = RET_STATUS );

	if( nb_master > AC_MAX_MASTER_COUNT )
			nb_master = AC_MAX_MASTER_COUNT;

	for( i=0; i<nb_master ; i++ ){

		sts = om$send(	msg	 = message NDmacro.ACreturn_foot(
						&msg,
						"",
						&cur_master, 
						NULL,
						NULL ),
				targetid = master[i].objid,
				targetos = master[i].osnum );
		if( sts&msg&1 ){

			if( *model_count < len_list )
				mo_list[*model_count] = cur_master;
			(*model_count) ++;

		}
	}

	if( ! *model_count )	return OM_W_ABORT;

	*rc	= MSSUCC;

return	OM_S_SUCCESS;
}

/* ************ override EMS 3 **************	*/

method GRplotyourself(IGRlong *msg; struct GRmd_env *md_env;
        IGRchar *dgn_buf; IGRchar *bs_buf; IGRchar *ele_buf; 
        IGRint *ele_size; IGRint *file_des; IGRdouble *max_overflow; 
        struct GRid *id_info; IGRdouble *scale_factor)
{
struct	GRid	id;

	id.objid	= my_id;
	id.osnum	= OM_Gw_current_OS;

return	ACSforwardMess( id, OPPmargs );
};

method GRformatele(IGRlong *msg; struct GRmd_env *md_env;
        IGRchar *dgn_buf; IGRchar *bs_buf; IGRchar *ele_buf; 
        IGRint *ele_size; IGRint *file_des; IGRdouble *max_overflow;
        IGRdouble *scale_factor)
{
struct	GRid	id;

	id.objid	= my_id;
	id.osnum	= OM_Gw_current_OS;

return	ACSforwardMess( id, OPPmargs );
};

method GRadd_to_display_list( IGRlong *msg; IGRboolean is_hidden_line )
{
struct	GRid	id;

	id.objid	= my_id;
	id.osnum	= OM_Gw_current_OS;

return	ACSforwardMess( id, OPPmargs );
};

method GRreport( IGRlong                        *msg;
                 struct GRmd_env                *md_env;
                 IGRint                         *list_size;
                 struct GRreport_item           *list;
                 struct GRreport_processor      *processor)
{
struct	GRid	id;

	id.objid	= my_id;
	id.osnum	= OM_Gw_current_OS;

return	ACSforwardMess( id, OPPmargs );
};

method GRreport_defaults( IGRlong *msg;
                          IGRchar *form;
                          IGRint *label;
                          IGRint *list_size;
                          struct GRreport_processor *processor)
{
struct	GRid	id;

	id.objid	= my_id;
	id.osnum	= OM_Gw_current_OS;

return	ACSforwardMess( id, OPPmargs );
};

method GRupdate_gadgets (IGRlong *msg; IGRchar *form_ptr)
{
struct	GRid	id;

	id.objid	= my_id;
	id.osnum	= OM_Gw_current_OS;

return	ACSforwardMess( id, OPPmargs );
};


end implementation VDlink;

