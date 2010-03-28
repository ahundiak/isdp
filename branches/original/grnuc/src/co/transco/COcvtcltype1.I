/* #######################    APOGEE COMPILED   ######################## */
/*
 *  This method will create and/or complete an IGE
 *  symbol definition object.  The IGDS cell header
 *  element (type 1) will provide some information
 *  for the object.
 */

class implementation COcvtclsl;

#include "exsysdep.h"
#include "coimport.h"
#include "OMindex.h"
#include "OMmacros.h"
#include "gr.h"
#include "grsymdef.h"
#include "grsym.h"

from GRvg import GRconstruct;
from GRvg import GRgetrang;
from GRconnector import GRrigidconn;

method cvt_type1 ( IGRlong *msg; struct GRid *object_info )

{

    struct IGDS_cell_header	*cellhdr;
    IGRint			i;
    IGRlong			status;
    IGRlong			const_msg;
    short unsigned		words_in_cell;
    IGRlong			rad_cell_name;
    IGRlong			index = OM_K_MAXINT;
    IGRshort			rad_cell_des[9];
    IGRshort			*internal_ptr;
    OM_S_CHANSELECT		chan_info;
    OM_S_OBJARRAY		objarray;
    GRspacenum			loc_OS;
    struct IGRdisplay		display;
    struct IGRsymboldef		symbol_geom;
    struct GRvg_construct	const_lis;
    struct GRnamdesc		symbol_desc;
    IGRboolean			newly_constructed = 0;
    GRobjid			sd_objid;
    struct GRid			comp_info;
    GRrange			accrange;
    IGRboolean			world = 1;    
    IGRchar			errmsg[240];
    IGRshort			bad_cell;
    extern IGRint		NumberofBadCells;
    

/*
 *  2D cell libraries are converted to
 *  the active type (3D) at this time.
 */

/*
 *  Extract data from the IGDS cell
 *	library header element.
 */

#ifdef BIG_ENDIAN
	GRswap_type1_ele(me->cvt_bufs.ele_buf);
#endif
    cellhdr = (struct IGDS_cell_header *) me->cvt_bufs.ele_buf;

/*
 *  extract the cell name
 */

    internal_ptr = (IGRshort *) &cellhdr->cell_name[0];
    OM_BLOCK_MOVE( internal_ptr, &rad_cell_name, 4);
    i = 2;
    GUrad50_to_ascii (&i, &rad_cell_name, symbol_desc.name_symbol);
    words_in_cell = cellhdr->wds_in_descrp - (cellhdr->words_to_follow - 17);

/*
 *  extract the cell description
 */

    internal_ptr = (IGRshort *) &cellhdr->cell_descrp[0];
    OM_BLOCK_MOVE( internal_ptr, rad_cell_des, 18 );
    i = 9;
    GUrad50_to_ascii ( &i, rad_cell_des, symbol_desc.desc_symbol );

/*
 *  search the b-tree containing incomplete symbol
 *  definition header objects
 *
 *  if the desired object is found, do not construct
 *  a new header object, instead fill in the object
 *  found
 */

    objarray.size = sizeof (OM_S_OBJARRAY);
    objarray.tree_type = KEY_STRING;

    status = GRbtreelocate ( msg, 1, &me->ModuleInfo.md_id.osnum,
			     me->btreename, symbol_desc.name_symbol,
			     &objarray, &loc_OS );

    if( !(status & *msg & 1) ){
	printf("Failed in GRbtreelocate\n");
	goto wrapup;
    }

/****************************************************************************/

    find_from_buf(&symbol_desc.name_symbol[0], &objarray.count, &objarray.array[0]);

/****************************************************************************/

    if ( objarray.count == 0 )
    {
	newly_constructed = 1;

	/*
	 *  Construct the symbol definition header object
	 */

	status = om$construct(classname = "GRsmdfhdr",
			      osnum = me->current_env.md_id.osnum,
	                      p_objid = &(sd_objid));

	if ( !(1 & status) ){
		printf("Failed in GRsmdfhdr construct\n");
	    	goto wrapup;
	}
    }
    else
    {
	sd_objid = objarray.array[0];
	newly_constructed = 0;
    }

    object_info->osnum = me->current_env.md_id.osnum;
    object_info->objid = sd_objid;
    
/*
 *  clear out accumulated range
 */

    accrange[0] = GRDGNLIMITS_MAX_D;
    accrange[1] = GRDGNLIMITS_MAX_D;
    accrange[2] = GRDGNLIMITS_MAX_D;
    accrange[3] = GRDGNLIMITS_MIN_D;
    accrange[4] = GRDGNLIMITS_MIN_D;
    accrange[5] = GRDGNLIMITS_MIN_D;
  
/*
 *  translate each component of the type 1
 *  and connect their object id's to the 
 *  symbol header object
 */

    bad_cell = 0;

    while ( words_in_cell > 0 ) 
    {
	comp_info.osnum = me->current_env.md_id.osnum;
	comp_info.objid = me->current_env.md_id.objid;
	
	status = om$send ( mode = OM_e_wrt_object,
			   msg = message COcvtclsl.cvt_next_ele
				 ( msg, &comp_info ),
			   senderid = my_id,
			   targetid = my_id );

	/******	if(!(status & 1 & *msg)) break; ******/

	words_in_cell -= (me->cvt_bufs.ele_size/2);

	if(!(status & 1 & *msg))
	{
		if(bad_cell == 0)
		{
			NumberofBadCells += 1;
		sprintf(errmsg, "echo Bad elements encountered in Cell %s >> igdsconv.log",symbol_desc.name_symbol);
			system(errmsg);
			bad_cell = 1;
		}
		continue;
	}
	if (( comp_info.objid != NULL_OBJID ) && (status & 1)){
	  	chan_info.type = OM_e_name;
     	  	chan_info.u_sel.name = "to_components";
	
		/*
	 	 *  connect component to symbol definition header
	 	 */

		status = om$send ( mode = OM_e_wrt_object,
		           	   msg = message GRconnector.GRrigidconn ( msg,
				 	object_info, &index ),
			   	   senderid = NULL,
			   	   targetid = comp_info.objid,
			   	   targetos = comp_info.osnum );

		if ( ! (1 & status) ){
			printf("Failed to connect component\n");
	    		goto wrapup;
		}

		/*
		 *  accumulate the range of the header as
		 *  each component object is constructed
		 */

		status = om$send ( mode = OM_e_wrt_object,
			   	   msg = message GRvg.GRgetrang ( msg, 
			   		&me->current_env.md_env.matrix_type,
			   		me->current_env.md_env.matrix, &world,
			   		me->range ),
			   	  senderid = NULL,
			   	  targetid = comp_info.objid,
			   	  targetos = comp_info.osnum );

		if ( ! (1 & status) ){
			printf("Failed to GRgetrange\n");
	    		goto wrapup;
		}

		GUaccumulate_range (me->range, accrange);
	}

    }

/*
 *  Build the construct list to
 *  initialize the instance data
 *  of the symbol definition header
 */

    const_lis.msg = &const_msg;    
    const_lis.env_info = &me->current_env;
    const_lis.newflag = FALSE;
    const_lis.level = 0;

/*
 *  Set up properties word.
 */

    const_lis.properties = 0;

    if ( cellhdr->properties & 0x2000 )
    {
	const_lis.properties |= GRIS_PLANAR;
    }
    if ( cellhdr->properties & 0x0200 )
    {
        const_lis.properties |= GRIS_NEW;
    }
    if ( cellhdr->properties & 0x0400 )
    {
        const_lis.properties |= GRIS_MODIFIED;
    }
    const_lis.properties |= GRIS_LOCATABLE;
    const_lis.properties |= GRIS_DISPLAYABLE;

    const_lis.geometry = (IGRchar *)&symbol_geom;
    const_lis.display = &display;
    const_lis.class_attr = (IGRchar *)&symbol_desc;
    const_lis.name = NULL;
 
/*
 *  Set up display structure.
 */

    display.color = ((unsigned short)(cellhdr->symbology & 0xFF00) >> 8);
    display.weight = ((IGRuchar)(cellhdr->symbology & 0x00F8) >> 3);
    display.style = cellhdr->symbology & 0x0007;

/*
 *  Set up cell geometry.
 */

    symbol_geom.diag_pt1[0] = accrange[0];
    symbol_geom.diag_pt1[1] = accrange[1];
    symbol_geom.diag_pt1[2] = accrange[2];
    symbol_geom.diag_pt2[0] = accrange[3];
    symbol_geom.diag_pt2[1] = accrange[4];
    symbol_geom.diag_pt2[2] = accrange[5];

/*
 *  initialize the instance data of the
 *  symbol definition header object
 */

    
	status = om$send ( mode = OM_e_wrt_object,
		               msg = message GRvg.GRconstruct ( &(const_lis) ),
		       	       senderid = NULL,
		       	       targetid = sd_objid,
		     	       targetos = me->current_env.md_id.osnum );

	if ( ! (1 & status) )
    	{
		printf("Failed in GRconstruct of symbol header\n");
		goto wrapup;
    	}

    /*
     *  if header was not newly constructed,
     *  then it needs to be removed from the
     *  b-tree containing incomplete headers
     *
     *  it is now complete !!
     */

    if ( ! newly_constructed )
    {

/****************************************************************************/

    rem_from_buf(symbol_desc.name_symbol);

/****************************************************************************/
/* 
	status = GRbtreeremove ( msg, 1, &me->ModuleInfo.md_id.osnum,
				 me->btreename, symbol_desc.name_symbol,
				 sd_objid );
*/
        GUrangeupdate ( &sd_objid, &me->current_env );

    }


wrapup:

	return ( status );

}

end implementation COcvtclsl;
