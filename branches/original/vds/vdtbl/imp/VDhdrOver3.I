/* $Id: VDhdrOver3.I,v 1.1.1.1 2001/01/04 21:09:28 cvs Exp $  */
/*--------------------------------------------------------------------------
/* I/VDS
 *
 * File:        vdtbl/imp / VDhdrOver1.I
 *
 * Description:
 *	Implementation of the following overridden methods  for VDdrwTblHdr :
 *		NDupdate
 *		NDcompute_node
 *		NDmove_to_root
 *
 * Dependencies:
 *
 * History:
 *      
 *	04/14/95	R. Manem	Creation
 *	06/20/95	R. Manem	Confirmed transformation matrix
 *					computation : updated comments
 *	08/15/95	R. Manem	Added NDmove_to_root
 *	10/25/95	tlb		EMS 3.2: changed cs.h to grcoordsys.h
 *
 * -------------------------------------------------------------------------
 */

class implementation VDdrwTblHdr;

/*
#define vdsDEBUG
#define vdserrDEBUG
*/

#include <stdio.h>

#include "OMmacros.h"
#include "OMprimitives.h"

#include "godef.h"
#include "grdpbdef.h"
#include "grdpbmacros.h"

#include "v_miscmacros.h"
#include "v_dbgmacros.h"
#include "v_datamacros.h"

#include "vds.h"
#include "emsdef.h"
#include "EMSutlmacros.h"

#include "exmacros.h"
#include "nddef.h"
#include "asbox.h"

#include "csdef.h"
#include "grcoordsys.h"
#include "asmacros.h"

#include "VDdrwlo.h"
#include "VDdrwtbl.h"

extern 		MAtypemx(), 
		MAinvmx(),
		BSmult_mats();

from GRgencs		import	GRcvt_to_wld_coords;

/*+mo
 -------------------------------------------------------------------------

  Overridden Message
        NDupdate from ASnode

  Abstract
        Updates a node.  
	Overridden to avoid removing myself from range tree.

  Arguments
        IGRint          *msg            O       completion code
        IGRint          cn_type         I       compute type
        IGRint          count           I       number of parents
        struct GRid     *parents        I       list of parents
        IGRint          *parent_state   I       completion code of
                                                parents compute
        struct GRid     *context        I       context GRid
        struct GRid     *new_objid      O       new GRid of the associative
                                                element if it changes.
        struct GRmd_env *md_env         I       module env

  Status/Return Code
     OM_S_SUCCESS       if success;
 -------------------------------------------------------------------------
-mo*/

method	NDupdate(	IGRint		*msg, cn_type, count;
			struct GRid	*parents;
			IGRint		*parent_state;
			struct GRid	*context, *new_objid;
			struct GRmd_env	*md_env )
{
    enum GRdpmode	dpmode;
    IGRlong		loc_msg,
			status = OM_S_SUCCESS;
    IGRboolean		save_br;

    extern IGRboolean	ASbroadcast_in_progress;

    SetProc( VDdrwTblRow.NDupdate ) ; Begin

    *msg = MSSUCC;

    /* 
     * same code as in NDnode.NDupdate 
     */

    new_objid->objid = my_id;
    new_objid->osnum = OM_Gw_current_OS;

    /* Check parent state to know if I have to recompute and if I can */

    NDcontrol_parent_state(count,parent_state,msg);

    if( *msg != ND_COMP_SUCC ) 
	goto wrapup;

    /* In case of stop, don't update */

    if( (cn_type & ND_COMP_TYPE) == ND_COMP_STOPPED )
    {
    	*msg = ND_COMP_OUT_OF_DATE;
    	goto wrapup;
    }

    save_br = ASbroadcast_in_progress;
    ASbroadcast_in_progress = 1;

    /* erase myself */

    dpmode = GRbehe;
    status =
    _VD_SEND_MY( GRgraphics.GRdisplay(	&loc_msg,	
					&md_env->md_env.matrix_type,
					md_env->md_env.matrix,
					&dpmode,
					&md_env->md_id ) );
    CheckRC( status, loc_msg );
		
    /* I recompute */

    /* ?????? Do we need the following ??? */

/*
    sv_md = md_env->md_id.objid;
    md_env->md_id.objid = NULL_OBJID;
*/

    status =
    _VD_SEND_MY( NDnode.NDcompute_node(	&loc_msg, 
					cn_type, 
					count, parents, 
					md_env ) );
    CheckRC( status, *msg );

/*
    md_env->md_id.objid = sv_md;
*/

    /* If context compute, transfer symbology */

    if( context && context->objid != NULL_OBJID )
	ACtrans_symb( *context, *new_objid );

    /* display myself */

    dpmode = GRbd;
    status =
    _VD_SEND_MY( GRgraphics.GRdisplay(	&loc_msg,	
					&md_env->md_env.matrix_type,
					md_env->md_env.matrix,
					&dpmode,
					&md_env->md_id ) );
    CheckRC( status, loc_msg );
		
    ASbroadcast_in_progress = save_br;

wrapup :
    End
    return OM_S_SUCCESS;
}

/*+mo
 -------------------------------------------------------------------------

  Overridden Message
        NDcompute_node from NDnode

  Abstract
        Recomputes a node.  Since the header has only one graphical parent
        (the coordinate system), recompute of the header is nothing but a 
	GRxform. 

  Arguments
      IGRlong           *msg            O       completion code
      IGRint            cn_type         I       reserved
      IGRint            count           I       number of roots
      struct GRid       *list           I       list of roots
      struct GRmd_env   *md_env         I       module env

  Status/Return Code
     OM_S_SUCCESS       if success;
 -------------------------------------------------------------------------
-mo*/

method  NDcompute_node ( IGRlong         *msg;
                         IGRint          cn_type;
                         int             count;
                         struct GRid     *list;
                         struct GRmd_env *mod_env )
{
    IGRshort		four = 4;
    IGRint		i,
			endRowNo;
    IGRlong		status = OM_S_SUCCESS;
    IGRshort		matType;
    IGRmatrix		oldMatrix,
			newMatrix,
			tMatrix;
    struct GRid		hdrId;
    SetProc( VDdrwTblRow.NDcompute_node ) ; Begin

    *msg = MSSUCC;

    /*
     * NOTES : 	A point is a 4x1 matrix (column), and not a 1x4 matrix (row)
     *
     *		Old matrix 	= A (local to world)
     *		New matrix	= B (local to world)
     *		Old point	= Pa (w.r.t. A)
     *		New point	= Pb (w.r.t. B)
     *		Pa = Pb (coordinates only : both are with respect to local cs)
     *		Old point	= A x Pa (w.r.t world)
     *		New point	= B x Pb (w.r.t world)
     *		Transformation matrix to be applied	= T
     *
     *		    T x A x Pa	= B x Pb
     *		=>  T x A	= B 
     *		=>  T x A x A-1 = B x A-1
     *		=>  T		= B x A-1
     */

    __DBGpr_mat( "Old matrix (A)", me->tMatrix );

    /* invert the old matrix */

    MAinvmx( msg, &four, me->tMatrix, oldMatrix );
    CheckRC( 1, *msg );

    __DBGpr_mat( "Inverse of Old matrix (A-1)", oldMatrix );

    /* update the new matrix in the instance */

    status =
    _VD_SEND_MY( VDdrwTblHdr.VDsetMatrixFromCS( msg ) );
    CheckRC( status, 1 );

    for( i = 0 ; i < 16 ; i++)
	newMatrix[i] = me->tMatrix[i];

    __DBGpr_mat( "New matrix (B) ", newMatrix );

    /* multiply the two matrices to get the net transformation matrix */

    BSmult_mats( 4, 4, newMatrix, 0, 4, 4, oldMatrix, 0, tMatrix, msg );
    MAtypemx( msg, tMatrix, &matType );
    CheckRC( 1, *msg );

    __DBGpr_mat( "Net transformation matrix (T=BA-1)", tMatrix );

    hdrId.objid = my_id;
    hdrId.osnum = OM_Gw_current_OS;

    endRowNo = (om$dimension_of(varray = me->rowHeights)) - 3 + me->startRowNo;

    __DBGpr_int( "Start row number", me->startRowNo );
    __DBGpr_int( "End row number", endRowNo );

    status = VD_drwtb_moveRowsOfTbl( 	msg,
                                	me->startRowNo,
                                	endRowNo,
                                	0,
                                	1, 1, 1,
                                	hdrId,
                                	matType,
                                	tMatrix );
    CheckRC( status, *msg );

    End

    /* return a valid return code */

    if( status & *msg & 1 )
	*msg =  ND_COMP_SUCC;
    else
	*msg =  ND_COMP_FAIL;

    return status;
}

/*+mo
 ---------------------------------------------------------------------------
  Overridden Message
        NDmove_to_root from NDnode

  Abstract
        When the coordinate system is deleted, reconstruct one, based on
        the instance matrix.  Make it non-displayable.

  Arguments
        IGRlong         *msg            O       return code
        struct GRid     *src_grid       O       GRid of the created object
        struct GRmd_env *md_env         I       module env
 ---------------------------------------------------------------------------
-mo*/

method NDmove_to_root(  IGRlong         *msg;
                        struct GRid     *src_grid;
                        struct GRmd_env *md_env )
{
    IGRint			i,
				size;
    IGRlong			status = OM_S_SUCCESS;
    struct IGRdisplay		display;
    IGRshort			level;
    struct IGRlbsys		lbs_geom;
    struct GRcs_construct	cs_args;
    struct GRid			csId,
				oldRoot;
    struct GRvg_construct	cnst_lis;

    SetProc( VDdrwTblHdr.NDmove_to_root ); Begin

    *msg = MSSUCC;

    /* get active parameters */

    size = sizeof( struct IGRdisplay );
    gr$get_active_display(	msg = msg,
				sizbuf = &size,
				buffer = &display,
				nret = &size);

    size = sizeof( IGRshort );
    gr$get_active_level(	msg = msg,
				sizbuf = &size,
				buffer = &level,
				nret = &size );

    cs_args.desc = "";
    cs_args.flag = CS_CONNECT_TO_MGR;;
    cs_args.type = RECTANGULAR;

    for( i = 0 ; i < 16 ; i++ )
	lbs_geom.matrix[i] = me->tMatrix[i];

    for( i = 0 ; i < 3 ; i++ )
    {
	lbs_geom.diag_pt1[i] = 0;
	lbs_geom.diag_pt2[i] = 0;
    }

    /* set up construction parameters */

    cnst_lis.msg = msg;
    cnst_lis.newflag = FALSE;
    cnst_lis.class_attr = (IGRchar *) &cs_args;
    cnst_lis.name = "";
    cnst_lis.level = level;
    cnst_lis.display = &display;
    cnst_lis.env_info = md_env;
    cnst_lis.properties = GRIS_LOCATABLE;
    cnst_lis.geometry = (IGRchar *)&lbs_geom;

    /* construct the coordinate system */

    csId.osnum = OM_Gw_current_OS;

    status = 
    om$construct(	classname	= "GRgencs",
			msg		= message GRgraphics.GRconstruct(
								&cnst_lis ),
			p_objid		= &csId.objid );

    __CheckRC( status, 1, "om$construct", wrapup );

    __DBGpr_obj( "Constructed cs id", csId );

    /* make source on cs */

    as$make_source(	go_grid		= csId,
			as_grid		= &csId );
    __DBGpr_obj( "Source id of cs", csId );
			
    /* 
     * disconnect old parent (could be cs or a source object), if present, 
     * and connect new one 
     */

    status = om$get_objid_at_index(  	objid           = my_id,
					p_chanselect    = &ND_father,
					index           = 1,
					objidaddr       = &oldRoot.objid,
					osnumaddr       = &oldRoot.osnum );

    if( status & 1 )
    {
	__DBGpr_obj( "Disconnecting old root", oldRoot );

	om$send(msg = message Root.disconnect(	ND_father, 
						oldRoot.objid,
                                      		oldRoot.osnum,
						ND_children),
		targetid = my_id);
    }

    status = _VD_SEND_MY( Root.connect(	ND_father, OM_K_MAXINT,
					csId.objid, csId.osnum,
					ND_children, 1 ) );
    CheckRC( status, 1 );

wrapup :
    End
    return status;
}

end implementation VDdrwTblHdr;

