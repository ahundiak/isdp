/* $Id: VDitemOver.I,v 1.4 2001/09/14 16:57:08 ahundiak Exp $ */

/* I/VDS
 *
 * File:        vdannot/VDitemOver.I
 *
 * Description:
 *
 *      Implementation of methods
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VDitemOver.I,v $
 *	Revision 1.4  2001/09/14 16:57:08  ahundiak
 *	*** empty log message ***
 *	
 *	Revision 1.3  2001/07/28 20:03:25  ad
 *	*** empty log message ***
 *	
 *	Revision 1.2  2001/04/11 14:12:01  ylong
 *	*** empty log message ***
 *	
 *	Revision 1.1.1.1  2001/01/04 21:07:41  cvs
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
# Revision 1.7  1996/05/02  12:09:10  pinnacle
# Replaced: ./vdannot/imp/VDitemOver.I for:  by azuurhou for vds.240
#
# Revision 1.6  1995/08/29  21:28:32  pinnacle
# Replaced: vdannot/imp/VDitemOver.I for:  by jwfrosch for vds.240
#
# Revision 1.5  1995/08/18  22:54:12  pinnacle
# Replaced: vdannot/imp/VDitem*I for:  by jwfrosch for vds.240
#
# Revision 1.4  1995/07/26  13:47:28  pinnacle
# Replaced: vdannot/imp/VDitemOver.I for:  by jwfrosch for vds.240
#
# Revision 1.3  1995/07/13  14:37:20  pinnacle
# Replaced: vdannot/imp/VDitemOver.I for:  by jwfrosch for vds.240
#
 *
 * History:
 *
 *      12/07/94        R.Manem         Creation Date
 *	12/20/94	R. Manem	GRdelete : to free item number
 *	6/15/95		tlb		Adapted to VDitem instance data
 *	04/10/01	ylong		TR4997
 *	07/28/01	adz		TR5467
 */

class implementation VDitem;

#include "go.h"
#include "msdef.h"
#include "AS_status.h"
#include "asbox.h"
#include "dimdef.h"
#include "dpdef.h"
#include "dp.h"
#include "dpmacros.h"
#include "v_miscmacros.h"
#include "VDobj.h"

#define VD_DEBUG

#include "VDdebug.h"

from	dim_plan	import	give_info;
from	DMsrc		import	DMgive_structure;
from	expression	import	NDgive_value, NDset_value, modify;
from	ACcpx		import	find_macro;
from	ACcpx_defn	import	ACgive_name;
from	VDitemSet	import	VDgetSetInfo;
from	VDdrwTblRow	import	VDgetItemNumber;

extern	GRclassid	OPP_VDct1Base_class_id;
extern	GRclassid	OPP_VDitemSet_class_id;
extern	GRclassid	OPP_VDdrwTblRow_class_id;
extern	GRclassid	OPP_VDequipment_class_id;
extern	GRclassid	OPP_DMsrc_class_id;
extern	GRclassid	OPP_nci_macro_class_id;
extern	GRclassid	OPP_ACpretend_class_id;
extern	GRclassid	OPP_VDdrwSet_class_id;
extern	GRclassid	OPP_VDSroot_class_id;

/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~	*/

int	VDcheckAnnotStruct
(
  struct GRid		 MY_ID,		/* I	*/
  int			 option,	/* I (0/1) 1=Check Multiple VDitem's on 1 DMsrc	*/
  int			*NbDMsrc,	/* O Only of interest if option=1		*/
  struct GRid		*parId,		/* O GRid of 'src_obj' ci_macro			*/
  struct GRid		*macro		/* O GRid of 'ci_mac_def'			*/
)
{
  IGRint		 status = OM_S_SUCCESS,
			 j, k,
			 s_count, 
			 s_count1;
  IGRchar		*c;
  struct GRid		 parentId;
  OM_S_OBJECT_LINKAGE	 slist[10], slist1[10];

  __enterFunction ( name = "VDcheckAnnotStruct" );

  parId->objid = NULL_OBJID;
  macro->objid = NULL_OBJID;
  if ( NbDMsrc ) *NbDMsrc = 0;

  /*
   * Get the DMsrc root of VDitem at DIM_ROOT_LOC
   */
  status =
  om$send (	msg	 = message NDnode.NDget_objects (
						 ND_ROOT,
						&parentId,
						 1,
						 NULL,
						 DIM_ROOT_LOC,
						 DIM_ROOT_LOC,
						&s_count ),
		targetid = MY_ID.objid,
		targetos = MY_ID.osnum,
		senderid = NULL_OBJID );

  if( ( !(status&1) ) || ( parentId.objid == NULL_OBJID ))
  {
    __print_goto ( "wrapup" );
    goto wrapup ;
  }

  if( !( vd_$is_ancestry_valid (object  = &parentId,
				classid = OPP_DMsrc_class_id )))
  {
    __print_goto ( "wrapup" );
    goto wrapup;
  }

  if ( option )
  {
    /*
     * Check if more then one VDitem object is connected.
     * When this is the case, a "copy" process is activated
     * and the "src_obj" should NOT be deleted.
     */
    status =
    om$get_channel_count(osnum   = parentId.osnum,
                         objid   = parentId.objid,
                  p_chanselect   = &ND_children,
                         count   = (OMuint *)&s_count );

    if( ( status&1 ) && ( s_count > 1 ))
    {
      /*
       * More then 1 VDitem connected to the DMsrc.
       */
      if ( NbDMsrc ) *NbDMsrc = s_count;

      __print_goto ( "wrapup" );
      goto wrapup ;
    }
  }

  /*
   * get ACpretend
   */
  status =
  om$get_channel_count (	osnum	     = parentId.osnum,
				objid	     = parentId.objid,
				p_chanselect = &ND_father,
				count	     = (OMuint *)&s_count );

  if ( s_count > 10 )
  {
    __print_goto ( "wrapup" );
    goto wrapup;
  }

  status =
  om$get_channel_objects ( osnum	= parentId.osnum,
			   objid	= parentId.objid,
			   p_chanselect = &ND_father,
			   size		= 10,
			   list		= slist,
			   count	= (OMuint *) &s_count );
 /*
  * Get the nci_macro "src_obj"
  */
  for (j=0; j < s_count; j++ )
  {
    macro->objid     = NULL_OBJID;
    om$get_channel_count (	osnum   = slist[j].osnum,
				objid   = slist[j].S_objid,
				p_chanselect = &ND_father,
				count   = (OMuint *)&s_count1 );
    if ( s_count1 > 10 )
    {
      __print_goto ( "wrapup" );
      goto wrapup;
    }
    status =
    om$get_channel_objects (	osnum   = slist[j].osnum,
				objid   = slist[j].S_objid,
				p_chanselect = &ND_father,
				size    = 10,
				list    = slist1,
				count   = (OMuint *) &s_count1 );

    /*
     * test on objects for macro src_obj.
     */

    __printf ( "slist [%d] = [%d,%d], s_count1 = %d", `j, slist [j].osnum, slist [j].S_objid, s_count1` );

    for (k=0; k < s_count1; k++ )
    {
      macro->objid = NULL_OBJID;
      om$send (	msg	 = message ACcpx.find_macro(macro),
		senderid = NULL_OBJID,
		targetid = slist1[k].S_objid,
		targetos = slist1[k].osnum);

      __printf ( "slist1[%d] = [%d,%d], s_count1 = %d", `k, slist1[k].osnum, slist1[k].S_objid, s_count1` );

      if( macro->objid != NULL_OBJID )
      {
	status =
	om$send (	msg	 = message ACcpx_defn.ACgive_name( &c ),
			senderid = NULL_OBJID,
			targetid = macro->objid,
			targetos = macro->osnum);
	as$status();

	__printf ( "ACgive_name() status = %d, c = <%s>", `status, c` );

	if( strcmp( c, "src_obj" ) == 0 )
	{
	  parId->objid = slist1[k].S_objid,
	  parId->osnum = slist1[k].osnum ;
	  goto wrapup;
	}
      }
    }
  }

wrapup:

  __exitFunction ( name = "VDcheckAnnotStruct" );

  return( status );
}

/*-------------------------------------------------------------------*/

/*
 * output string format : "ItemNumber (<tblName>:<ItemNum>)"
 *          eg.   "ItemNumber (EqpBOM_00[mod.d]:P-2)"
 */

method GRgetobjinfo
(
  IGRlong		*msg;
  struct GRobj_info	*info
)
{
  IGRint		 status, count = 0, len = 0;
  IGRchar		*buffer  = NULL;
  IGRchar		*tblName = NULL;
  char			*prefix_nm = { "ItemNumber " };
  struct GRid		 ItmId,
			*ItmSet = NULL;
  OM_S_CHANSELECT	to_chan;

  __enterMethod ( name = "GRgetobjinfo" );

    *msg = MSSUCC;
    ItmId.objid = my_id;
    ItmId.osnum = OM_Gw_current_OS;

    /*
     * Get table name from VDitemSet
     */
    status = om$make_chanselect( channame	= "VDitem.to_bomset",
				 p_chanselect	= &to_chan );
    as$status( action = GOTO_VALUE, value = wrapup );

    __printf(" GetGrid[%d]: VDdrwTblRow ", `__LINE__`);
    status = VDGetGridsFromChan_of_Class ( msg, ItmId, &to_chan, OPP_VDitemSet_class_id, &count, &ItmSet );

    __printf("ItmId  = [%d,%d] count  = %d", `ItmId.osnum, ItmId.objid, count` );

    if ( ! count )
	goto wrapup;

    status = om$send( msg       = message VDitemSet.VDgetSetInfo( msg, &tblName),
                      targetid  = ItmSet[0].objid,
                      targetos  = ItmSet[0].osnum );
    as$status();

    /*
     * Calculate message length
     */
    len = strlen (prefix_nm) + strlen (tblName) + strlen (me->ItemNum) + 4;

    __printf("len    = %d", len );

    /*
     * Allocate space for temporary buffer
     */
    buffer = _CALLOC ( len, IGRchar );
    if( !buffer )
    {
      printf("\nERROR : Dynamic allocation\n");

      __exit_error_Method ( name = "GRgetobjinfo" );
      return OM_E_NODYNMEM ;
    }

    /*
     * Format output string
     */
    sprintf( buffer, "%s(%s:%s)", prefix_nm, tblName, me->ItemNum );

    __printf("buffer = <%s>", buffer );

    /*
     * Set up the output info
     */
    strncpy( info->type, buffer, MS_MAX_MSG_LENGTH );

wrapup:

  __exitMethod ( name = "GRgetobjinfo" );

    _FREE ( tblName );
    _FREE ( buffer );
    _FREE ( ItmSet );

    return OM_S_SUCCESS;
}

/*-------------------------------------------------------------------*/

method NDmove_to_root
(
  IGRlong		*msg;
  struct GRid		*src_grid;
  struct GRmd_env	*md_env
)
{
  IGRint status;
  struct GRid		oids_buf[1];
  extern IGRboolean ASbroadcast_in_progress;

  __enterMethod ( name = "NDmove_to_root" );

  /*
   * When a VDitem object looses one of its parents, it should delete itself
   */
  oids_buf[0].objid = my_id;
  oids_buf[0].osnum = OM_Gw_current_OS;
  dp$display (	msg		= msg,
		oids		= oids_buf,
		mode		= GRbehe );

  status =
  om$send (	msg	 = message GRgraphics.GRdelete( msg, md_env ),
		targetid = my_id);
  as$status();

/*
 * Do NOT perform the usual NDmove_to_root & successive operations
 *
  status =
  om$send (	msg	 = message NDnodein.NDmove_to_root(
					msg, src_grid, md_env),
		targetid = my_id,
		mode	 = OM_e_wrt_message);
  as$status(action = RET_STATUS);

  status =
  om$send(msg = message NDnode.NDchg_state(ND_DONT_MVRT, ND_DONT_MVRT),
		targetid = my_id);
  as$status(action = RET_STATUS);

  status =
  om$send(msg = message DMroot.set_dim_state(BIT_OR, DIM_DETACHED),
		p_chanselect = &ND_children,
		senderid = my_id);
  as$status(action = RET_STATUS);
*/

  __exitMethod ( name = "NDmove_to_root" );

  return(OM_S_SUCCESS);
}

/*---------------------------------------------------------------------------*/

method gather_data
(
  IGRint		*msg;
  IGRint		 count;
  struct GRid		list[];
  IGRpoint		 start_pt;
  IGRpoint		 end_pt;
  struct DMplan_info	*plan_info;
  struct DMsenv_param	*par_senv;
  struct GRmd_env	*md_env
)
{
  IGRint		 status, rc, index, type ;
  IGRshort		 first;
  IGRdouble		 text_offset;
  struct GRid		 prev;
  struct dim_ret_struct	 dim_str;

  __enterMethod ( name = "gather_data" );

  /*| - Get environment parameters */

  status =
  om$send (	msg	 = message DMannot.get_active_senv(par_senv),
		targetid = my_id);
  as$status();
  if ( ! ( status & 1 ) )
  {
    __print_goto ( "wrapup" );
    goto wrapup;
  }

  /*| - Get the dimension plane */

  /* alternative function : corr 2.0
  status =
  om$send (	msg	 = message DMroot.get_dimension_plane(
						&rc, md_env, plan_info),
		mode	 = OM_e_wrt_message,
		targetid = my_id);
  dm$status(action = RET_STATUS);
  */

  status =
  om$send (	msg	 = message dim_plan.give_info(&rc, plan_info, md_env),
		targetid = list[DIM_ROOT_PLAN].objid,
		targetos = list[DIM_ROOT_PLAN].osnum);
  as$status();
  if ( ! ( status & 1 ) )
  {
    __print_goto ( "wrapup" );
    goto wrapup;
  }

  first = TRUE;
  prev.objid = NULL_OBJID;
  if(me->dim_type == TEXT_WITH_BALLOON)
  {
    status =
    om$send (	msg	 = message DMroot.give_previous(&rc, &first, &prev),
		targetid = my_id);
    as$status();
    if ( ! ( status & 1 ) )
    {
      __print_goto ( "wrapup" );
      goto wrapup;
    }
  }
  __printf ( "first = %d, prev = [%d,%d]", `first, prev.osnum, prev.objid` );

  if( ! first )
  {
    /*| - get bln center from the previous balloon */

    text_offset = par_senv->txt_heig * 0.5;
    status=
    om$send (	msg	 = message DMtxbln.give_bln_center(
							&rc,
							&text_offset,
							start_pt,
							&prev,
							plan_info,
							md_env),
		targetid = my_id);
    as$status();
    if ( ! ( status & 1 ) )
    {
      __print_goto ( "wrapup" );
      goto wrapup;
    }
  }
  else
  {
    /* alternative function: corresponding with 2.0
    status =
    DMnode_give_structure(
                        &rc,
                        DIM_NO_INDEX,
                        ORIG_INFO,
                        (me->geom_type & DIM_IMPORTED),
                        list[AN_ROOT_ELEM1].objid,
                        my_id,
                        OM_Gw_current_OS,
                        md_env,
                        &ret_str);
    dm$status(action = RET_STATUS);
    */

    type = ORIG_INFO;
    status =
    om$send (	msg	 = message DMsrc.DMgive_structure(	&rc,
								type,
								FALSE,
								&dim_str,
								md_env ),
		targetid = list[AN_ROOT_ELEM1].objid,
		targetos = list[AN_ROOT_ELEM1].osnum);
    as$status();
    if ( ! ( status & 1 ) )
    {
      __print_goto ( "wrapup" );
      goto wrapup;
    }

    math_v_equal(start_pt, dim_str.var.dm_ptdist.point);
  }

  for (index=0; index<3; index++)
  {
    plan_info->win_plan.matrix[4*index + 3] =
    plan_info->act_plan.matrix[4*index + 3] = start_pt[index];
  }

wrapup:

  __exitMethod ( name = "gather_data" );

  return(OM_S_SUCCESS);
}

/*----------------------------------------------------------------------*/
/* METHOD  GRxform                                                      */
/* moves annotation                                                     */
/*----------------------------------------------------------------------*/

method GRxform
(
  IGRlong           *msg;
  struct GRmd_env   *md_env;
  IGRshort          *matrix_type;
  IGRmatrix         matrix;
  GRobjid           *newobjid
)
{
  IGRint		 status = OM_S_SUCCESS,
			 ii,
			 s_count;
  IGRshort		 rc;
  struct GRid		 temp, macro, parId, MY_ID;
  OM_S_OBJECT_LINKAGE	 slist[10];
  IGRdouble		 new_val[3];

  __enterMethod ( name = "GRxform" );

  MY_ID.objid = my_id;
  MY_ID.osnum = OM_Gw_current_OS;

  for( ii=0; ii<3; ii++ )
  {
    new_val[ii] = 0.0 ;
  }

  status = VDcheckAnnotStruct ( MY_ID, 0, NULL, &parId, &macro );

  __printf ("macro = [%d,%d], parId = [%d,%d]",
			`macro.osnum, macro.objid, parId.osnum, parId.objid` );

  if( macro.objid == NULL_OBJID || parId.objid == NULL_OBJID )
  {
    /*
     * Do we "return" from here or "goto wrapup" ???
     */
    __exitMethod ( name = "GRxform" );
    return OM_S_SUCCESS;
  }

  /*
   * get the parents of nci_macro "src_obj"
   */
  om$get_channel_count (	osnum   = parId.osnum,
				objid   = parId.objid,
				p_chanselect = &ND_father,
				count   = (OMuint *)&s_count );

  __printf ( "parId = [%d,%d], s_count = %d",
		`parId.osnum, parId.objid, s_count` );

  status =
  om$get_channel_objects (	osnum   = parId.osnum,
				objid   = parId.objid,
				p_chanselect = &ND_father,
				size    = 10,
				list    = slist,
				count   = (OMuint *) &s_count );

  for( ii = 1; ii<2; ii++ )
  {
    int			pos;
    struct ret_struct	expr;

    temp.objid  =  slist[ii].S_objid;
    temp.osnum  =  slist[ii].osnum;

    __printf ( "temp = [%d,%d]", ` temp.osnum, temp.objid` );

    status =
    om$send (	msg	 = message expression.NDgive_structure( msg, &expr, md_env ),
		targetid = temp.objid,
		targetos = temp.osnum  );
    as$status();

    __printf ( "<<< expr.var.text_st.text_string = <%s>", expr.var.text_st.text_string );;

    sscanf ( expr.var.text_st.text_string, "%d %lf %lf %lf", &pos, &new_val[0], &new_val[1], &new_val[2] );

    new_val[0] += matrix[ 3];
    new_val[1] += matrix[ 7];
    new_val[2] += matrix[11];

    sprintf ( expr.var.text_st.text_string, "%d %lf %lf %lf", pos, new_val[0], new_val[1], new_val[2] );

    __printf ( ">>> expr.var.text_st.text_string = <%s>", expr.var.text_st.text_string );;

    status =
    om$send( msg = message expression.modify( "",
                                              expr.var.text_st.text_string,
                                              &rc ),
             targetid = temp.objid,
             targetos = temp.osnum  );
    as$status();
  }

  {
    int     cn_type = ND_COMP, wait_batch ;

    nd$wait_batch(  type       = GR_GEOM_POSTED,
                    l_object   = &temp,
                    l_obj_info = &cn_type,
                    nb_obj     = 1);

    nd$mod_batch(   request    = ND_INQ,
                    p_ret_mode = &wait_batch);

    nd$exec_batch(  mode = ND_IMMEDIATE );
  }

  __exitMethod ( name = "GRxform" );

  return status;

wrapup:

  status =
  om$send (	msg	 = message DMroot.GRxform( msg, md_env, matrix_type,
                                          matrix, newobjid ),
		mode	 = OM_e_wrt_message,
		targetid = my_id );

  __exit_error_Method ( name = "GRxform" );

  return status ;
}

/*--------------------------------------------------------------------------*/

method GRdelete
(
  IGRlong		*msg;
  struct GRmd_env	*md_env
)
{
  IGRchar		*cnm;
  IGRint		 s_count, count = 0, i0;
  int			 NbDMsrc = 0;
  IGRlong		 status = OM_S_SUCCESS;
  struct GRid		 parId, macro, MY_ID, *cimac = NULL;
  OM_S_OBJECT_LINKAGE	 bomSetId;
  OM_S_CHANSELECT	 to_bom_chan;

  int			 cnt1 = 0, cnt2 = 0, cnt3 = 0, j0, j1, j2;
  struct GRid		*prtnd = NULL, *dmsrc = NULL, *vditm = NULL;

  __enterMethod ( name = "GRdelete" );

  MY_ID.objid = my_id;
  MY_ID.osnum = OM_Gw_current_OS;

  parId.objid	   = NULL_OBJID;
  macro.objid	   = NULL_OBJID;
  bomSetId.S_objid = NULL_OBJID;

  /*
   * Get nci_macro on children channel
   */

  __prints(" GetGrids: OPP_nci_macro_class_id ");
  status = VDGetGridsFromChan_of_Class ( msg, MY_ID, &ND_children, OPP_nci_macro_class_id, &count, &cimac );

  for ( i0=0; i0 < count; i0++ )
  {
    struct GRid macro;
    macro.objid = NULL_OBJID;

    status =
    om$send (	msg	 = message ACcpx.find_macro ( &macro ),
		targetid = cimac[i0].objid,
		targetos = cimac[i0].osnum );

    if ( macro.objid != NULL_OBJID )
    {
      status =
      om$send (	msg	= message ACcpx_defn.ACgive_name ( &cnm ),
		targetid	= macro.objid,
		targetos	= macro.osnum );
      as$status ();

      __printf ( "cimac[%d] = [%d,%d], macro = [%d,%d], cnm = <%s>",
		`i0, cimac[i0].osnum, cimac[i0].objid, macro.osnum, macro.objid, cnm` );

      if ( strcmp ( cnm, "src_obj" ) == 0 )
      {
	/*
	 * Here we are trying to force a delete of STACKED VDitem's. Stacked VDitem's
	 * are connected to the VDitem on the children channel thru the ci_macro 'src_obj'
	 */
  	__prints(" GetGrids: OPP_ACpretend_class_id ");
	status = VDGetGridsFromChan_of_Class ( msg, cimac[i0], &ND_children, OPP_ACpretend_class_id, &cnt1, &prtnd );

	for ( j0=0; j0 < cnt1; j0++ )
	{
  	  __prints(" GetGrids: OPP_DMsrc_class_id ");
	  status = VDGetGridsFromChan_of_Class ( msg, prtnd[j0], &ND_children, OPP_DMsrc_class_id, &cnt2, &dmsrc );

	  for ( j1=0; j1 < cnt2; j1++ )
	  {
  	    __prints(" GetGrids: OPP_VDitem_class_id ");
	    status = VDGetGridsFromChan_of_Class ( msg, dmsrc[j1], &ND_children, OPP_VDitem_class_id, &cnt3, &vditm );

	    for ( j2=0; j2 < cnt3; j2++ )
	    {
	      __printf ("vditm[%d] = [%d,%d]", `j2, vditm[j2].osnum, vditm[j2].objid` );

	      dp$display (	msg		= msg,
				oids		= &vditm[j2],
				mode		= GRbehe );

	      status =
	      om$send (	msg	 = message GRgraphics.GRdelete( msg, md_env ),
			targetid = vditm[j2].objid,
			targetos = vditm[j2].osnum );
	      as$status ();
	    }
	  }
	}
      }
    }
  }

  status = om$make_chanselect(	channame	= "VDitem.to_bomset",
				p_chanselect	= &to_bom_chan );
  as$status();

  status = om$get_channel_objects( objid	= my_id,
				   p_chanselect	= &to_bom_chan,
				   size		= 1,
				   list		= &bomSetId,
				   count	= (OMuint *)&s_count );
  as$status();

  __printf ("my_id = [%d,%d], status = %d, s_count = %d, bomSetId = [%d,%d]",
			`OM_Gw_current_OS, my_id, status, s_count, bomSetId.osnum, bomSetId.S_objid` );

  status = VDcheckAnnotStruct ( MY_ID, 1, &NbDMsrc, &parId, &macro );

  __printf ("NbDMsrc = %d, macro = [%d,%d], parId = [%d,%d]",
			`NbDMsrc, macro.osnum, macro.objid, parId.osnum, parId.objid` );

  if ( NbDMsrc > 1 ) goto wrapup;	// dynamics "copy" in progress

  if( macro.objid != NULL_OBJID && parId.objid != NULL_OBJID )
  {
    status =
    om$send (	msg	 = message GRgraphics.GRdelete( msg, md_env ),
		targetid = parId.objid,
		targetos = parId.osnum);
    as$status();
  }

wrapup:

  __printf ("BEFORE DMroot.GRdelete() my_id = [%d,%d]",	`OM_Gw_current_OS, my_id` );

  status =
  om$send (	msg	 = message DMroot.GRdelete( msg, md_env ),
		mode	 = OM_e_wrt_message,
		targetid = my_id);
  as$status();
  if ( ! ( status & 1 ) )
  {
    status =
    om$send (	msg	 = message GRgraphics.GRdelete( msg, md_env ),
		mode	 = OM_e_wrt_message,
		targetid = my_id);
    as$status();
  }

  _FREE ( cimac );
  _FREE ( prtnd );
  _FREE ( dmsrc );
  _FREE ( vditm );

  __exitMethod ( name = "GRdelete" );

  return(status);
}

/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ */

#define	AN_ROOT_TBLROW	4

method DMcompute_node
(
  IGRlong		*msg;
  IGRint		 cn_type;
  int			 count;
  struct GRid		 list[];
  struct GRmd_env	*md_env
)
{
  IGRint		 status, rc = 0, itemSz, cnt = 0, i, j;
  struct GRid		 RowId, myRowId, tblId, myTblId, ModelId, parentId;
  struct GRid		 *prtnd = NULL, *sets = NULL, *rows = NULL;
  IGRint		 setCnt = 0, rowCnt = 0;
  char			 ItemNum[40];

  __enterMethod ( name = "DMcompute_node" );

  RowId.objid	= NULL_OBJID;
  ModelId.objid	= NULL_OBJID;
  tblId.objid	= NULL_OBJID;

  if ( me->dim_state & GRDELETE_PENDING )
  {
    __printf ( "me->dim_state = %#o IS GRDELETE_PENDING", `me->dim_state` );
    __print_goto ( "wrapup" );
    goto wrapup;
  }

  status = om$is_objid_valid (	osnum = OM_Gw_current_OS,
				objid = my_id );

  if ( status != OM_S_SUCCESS )
  {
    __printf ( "my_id = [%d,%d] IS NOT VALID ANYMORE", `OM_Gw_current_OS, my_id` );
  }

  for( i = count-1; i >= 0; i-- ) 
  {
    parentId = list[i];

    if( parentId.objid == NULL_OBJID ) continue;

    if(  vd_$is_ancestry_valid (object  = &parentId,
				classid = OPP_ACpretend_class_id ) )
    {
      status =
      om$send (	msg	 = message NDmacro.ACreturn_foot(
                                       msg,
                                       "",
                                       &parentId,
                                       NULL, NULL ),
		targetid = parentId.objid,
		targetos = parentId.osnum );
      as$status();
    }

    if(  vd_$is_ancestry_valid (object  = &parentId,
				classid = OPP_VDdrwTblRow_class_id ) )
    {
	RowId = parentId;
    }
    else{
      if(  vd_$is_ancestry_valid (object  = &parentId,
				classid = OPP_VDSroot_class_id ) )
      {
	ModelId = parentId;
      }
    }

    if( ModelId.objid != NULL_OBJID && RowId.objid != NULL_OBJID ) break;
  }

  if( ModelId.objid == NULL_OBJID && RowId.objid == NULL_OBJID ) {
    __print_goto ( "quit" );
    goto quit;
  }

  status = VDtbl_get_hdrtbl( msg, &RowId, NULL, &tblId);
  
#if 0
  /* 
   * check table for testing
   */
  {
    IGRint		rowCnt=0;
    struct	GRid	tblHdr;
    OM_S_CHANSELECT	toRows;

    status = VDtbl_get_hdrtbl( msg, &RowId, &tblHdr, NULL);

    status = om$make_chanselect(channame	= "VDdrwTblHdr.to_tblRows",
				p_chanselect	= &toRows );

    __prints(" GetGrids: OPP_VDdrwTblRow_class_id ");
    status = VDGetGridsFromChan_of_Class( msg, tblHdr, &toRows, OPP_VDdrwTblRow_class_id, &rowCnt, &rows );
    printf("----- table header: "); vdobj$Print(objID=&tblHdr);
    for( i = 0; i < rowCnt; i++ ) {
  	printf("----- row[%d]: ", i); vdobj$Print(objID=&rows[i]);
    }
    _FREE(rows);
  }
#endif
  
  if( ModelId.osnum == OM_Gw_current_OS ) {
    __printf(" GetGrid[%d]: Get VDdrwSet in active file", `__LINE__`);
    __printf(" ModelId[%d,%d]:  ", `ModelId.osnum, ModelId.objid`);
    status = VDGetGridsFromChan_of_Class ( msg, ModelId, &ND_children, OPP_VDdrwSet_class_id, &setCnt, &sets );
    if( !(status&*msg&1) || setCnt < 1 || sets == NULL ){ __print_goto ( "check_tree" ); goto check_tree; }
  }
  else 
  {
    cnt = 0;
    __printf(" GetGrid[%d]: Get ACpretend of Object", `__LINE__`);
    __printf(" ModelId[%d,%d]:  ", `ModelId.osnum, ModelId.objid`);
    status = VDGetGridsFromChan_of_Class (	msg, ModelId, &AS_notification, OPP_ACpretend_class_id, &cnt, &prtnd );
    if( !(status&*msg&1) ) { goto check_tree; }

    for( i = 0; i < cnt; i++ ) {
	setCnt = 0;
        __printf(" GetGrid[%d]: OPP_VDdrwSet_class_id ", `__LINE__`);
        status = VDGetGridsFromChan_of_Class (	msg, prtnd[i], &ND_children, OPP_VDdrwSet_class_id, &setCnt, &sets );
	if( (status&*msg&1) && setCnt >= 1 && sets != NULL ) break;
	_FREE(sets);
    }
  }

check_tree:

  if( !setCnt ){

     IGRint		i0,
			NbDrwSet = 0,
			NbPrTree = 0,
			NbPrtnd  = 0,
			NbPrtnd1 = 0;

     struct GRid	*DrwSet = NULL,
			*PrTree = NULL,
			*Prtnd  = NULL,
			*Prtnd1 = NULL;

    /*
     * The Row may have been constructed with usage of Tree object.
     * Model -(to_notify)- VDct1Base -(to_notify)- ASsource -(child)- Set(s).
     */
    _FREE( sets );

    // __prints ( "GetGrids: OPP_VDatBase_class_id " );
    // status = VDGetGridsFromChan_of_Class ( msg, ModelId, &ND_children, OPP_VDatBase_class_id, &NbPrTree, &PrTree );

    if( !NbPrTree ){
      __prints ( "GetGrids: OPP_VDct1Base_class_id " );
      status = VDGetGridsFromChan_of_Class ( msg, ModelId, &AS_notification, OPP_VDct1Base_class_id, &NbPrTree, &PrTree );
    }

    if( NbPrTree ){

      /*
       * Check if there is a Make_source (ASsource | ACpretend connected) -> Always to notify channel !!
       */

      NbPrtnd = 0 ;
      _FREE( Prtnd );

      for ( i0 = 0; i0 < NbPrTree; i0++ ){

        __prints ( "GetGrids: -OPP_NDnodein_class_id " );
        status = VDGetGridsFromChan_of_Class ( msg, PrTree[i0], &AS_notification, -OPP_NDnodein_class_id, &NbPrtnd1, &Prtnd1 );

        if( NbPrtnd1 > 0 ){
          if ( Prtnd == 0 ) { Prtnd =  _MALLOC (        (NbPrtnd+NbPrtnd1), struct GRid ); }
          else { 	      Prtnd = _REALLOC ( Prtnd, (NbPrtnd+NbPrtnd1), struct GRid ); }
          if ( Prtnd == 0 ) { __print_goto ( "quit" ); goto quit; }

          memcpy ( &Prtnd[NbPrtnd], Prtnd1, sizeof (struct GRid) * NbPrtnd1 );

          NbPrtnd += NbPrtnd1;
          _FREE ( Prtnd1 );
        }
      }

      __printf ("%d Source (1) connected ", NbPrtnd );

      if( ! NbPrtnd ){

        /*
         * This can be the case where the tree and the table are in the same file.
         */
        Prtnd = _MALLOC ((NbPrTree), struct GRid );
        memcpy ( &Prtnd[NbPrtnd], PrTree, sizeof (struct GRid) * NbPrTree );
        NbPrtnd += NbPrTree ;

      }

      __printf ("%d Source (2) connected ", NbPrtnd );

      if( NbPrtnd ){

        _FREE( DrwSet );

        for ( i0 = 0; i0 < NbPrtnd; i0++)
        {
          __prints ( "GetGrids: OPP_VDdrwSet_class_id " );
          status = VDGetGridsFromChan_of_Class ( msg, Prtnd[i0], &ND_children, OPP_VDdrwSet_class_id, &NbDrwSet, &DrwSet );

          if ( NbDrwSet > 0 )
          {
            if ( sets == 0 ) { sets =  _MALLOC (       (setCnt+NbDrwSet), struct GRid ); }
            else { 	       sets = _REALLOC ( sets, (setCnt+NbDrwSet), struct GRid ); }
            if ( sets == 0 ) { __print_goto ( "quit" ); goto quit; }

            memcpy ( &sets[setCnt], DrwSet, sizeof (struct GRid) * NbDrwSet );

            setCnt += NbDrwSet;
            _FREE ( DrwSet );
          }
          __printf ("%d VDdrwSet connected to this ACpretendin [%d,%d]", `NbDrwSet, Prtnd[i0].osnum, Prtnd[i0].objid` );
        }
      }
    }

    _FREE( DrwSet );
    _FREE( PrTree );
    _FREE( Prtnd  );
    _FREE( Prtnd1 );
  } /* ( ! setCnt) */


  myRowId.objid = NULL_OBJID;

  for( i = 0; i < setCnt; i++ ) 
  {
    rowCnt = 0;
    _FREE(rows); 
    __printf(" GetGrid[%d]: OPP_VDdrwTblRow_class_id ", `__LINE__`);
    status = VDGetGridsFromChan_of_Class ( msg, sets[i], &ND_children, OPP_VDdrwTblRow_class_id, &rowCnt, &rows );
    if( !(status&*msg&1) || rowCnt < 1 ) {
	continue;
    }

    for( j = 0; j < rowCnt; j++ ) 
    {
	/* 
	 * get active table id from rows[j], but never succeed for new added 
         * row. It seems like the new row has not connected to table yet 
         * at the moment.
	 */

	status = VDtbl_get_hdrtbl(msg, &rows[j], NULL, &myTblId);
	if( (status&*msg&1) && myTblId.objid == tblId.objid ) 
	{
	   myRowId = rows[j];
	   goto process_row;
	}
	/* 
         * if a row has not connected to table, it must be the new added 
         * row we are trying to find, so get it.
 	 */

	else if( !(status&*msg&1) ) 
	{
	   myRowId = rows[j];
	   goto process_row;
	}
    }

  }

  if( myRowId.objid == NULL_OBJID) { __print_goto ( "quit" ); goto quit; }

process_row:

  if( myRowId.objid != RowId.objid || myRowId.osnum != RowId.osnum ) 
  {
    status = _VD_SEND_MY( NDnode.NDchange_connect( 1, &RowId, &myRowId ) );
  }

  status = om$send (	msg	 = message VDdrwTblRow.VDgetItemNumber 
						( msg, &itemSz, ItemNum ),
			senderid = my_id,
			targetid = myRowId.objid,
			targetos = myRowId.osnum );

  status = om$send (	msg	 = message DMroot.replace_text
					(
					&rc,
					DIM_TEXT,
					(struct GRid *) NULL,
					md_env,
					strlen(ItemNum),
					(IGRuchar *) ItemNum
					),
			targetid = my_id);
  as$status ();
  as$status ( sts = rc );
  if ( ! ( status & rc & 1 ) ) { __print_goto ( "wrapup" ); goto wrapup; }

  status = om$send (	msg	 = message VDitem.VDputItemInfo ( msg, ItemNum ),
			targetid = my_id);
  as$status();
  if (! (status & 1) ){__print_goto ( "wrapup" );goto wrapup;}

quit:

  status = om$send (	msg	 = message DMannot.DMcompute_node  (
						msg, cn_type,
						count, list, md_env),
			targetid = my_id,
			mode	 = OM_e_wrt_message);
  as$status ();
  as$status ( sts = *msg );
  if ( ! ( status & *msg & 1 ) ) { __print_goto ( "wrapup" ); goto wrapup; }

wrapup:

  _FREE(prtnd); 
  _FREE(sets);
  _FREE(rows);

  __exitMethod ( name = "DMcompute_node" );

  return( status );
}

/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ */

/*+me
  Public Message VDgetNbBreakPts

  Abstract
	This method gets the number of breakpoints of the leaderline

  Arguments
	IGRlong		*msg		O	Return code
	IGRint	 	*NbBreakPts	O
  Notes/Remarks

  Status/Return Code
      status == OM_S_SUCCESS    if success;
-me*/

method VDgetNbBreakPts
(
  IGRlong		*msg;
  IGRint	 	*NbBreakPts
)
{
  *msg = MSSUCC;
  *NbBreakPts = om$dimension_of ( varray = me->break_pt ) / 3;
  return OM_S_SUCCESS;
}

end implementation VDitem;
