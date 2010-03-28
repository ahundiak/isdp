/* #######################    APOGEE COMPILED   ######################## */
class implementation COcvigdsige;

 /*
 *  This method will translate IGDS cell library
 *  type 2 elements into DRAFT symbols.
 */

#include "coimport.h"
#include "OMindex.h"
#include "OMmacros.h"
#include "gr.h"
#include "grsymdef.h"
#include "grsymmacros.h"
#include "transdef.h"

from GRconnector import GRflexconn;
from GRsmhdr import GRconstruct;

IGRint COcvtcltype2 ( rc, igdscell, scalefactor, IGDSfiletype, current_env,
		      object_info, ModuleInfo)

IGRlong		 *rc;
struct IGDS_cell *igdscell;
IGRdouble	 *scalefactor;
IGRlong		 *IGDSfiletype;
struct GRmd_env  *current_env;
struct GRid	 *object_info;
struct GRmd_env  ModuleInfo;

{
    IGRint		i;
    IGRlong		status;
    IGRlong		const_msg;
    IGRlong		msg;
    IGRlong		rad_cell_name;
    IGRchar		symbol_ref_name[10];
    IGRchar		btreename[40];
    IGRlong		diagpts[6];
    IGRlong		transformation[9];
    IGRlong		origin[3];
    IGRlong		index = OM_K_MAXINT;
    IGRshort		*internal_ptr;
    IGRshort		wds_in_descript;
    IGRshort		flag = 1;
    IGRshort		num_rc = 4;
    IGRmatrix		scale_matrix;
    struct GRmd_env	new_env;
    struct IGRdisplay	display;
    struct IGRlbsys	symbol_geom;
    struct GRvg_construct	const_lis;
    GRobjid		sd_objid;
    OM_S_OBJARRAY	objarray;
    GRspacenum		loc_OS;
    OM_S_CHANSELECT	chan_info;
    struct GRid		sd_info;

    /*
     *  Extract data from the IGDS cell
     *	element header.
     */

    internal_ptr = (IGRshort *) &igdscell->cell_data;
    wds_in_descript = *internal_ptr;
    internal_ptr++;
    OM_BLOCK_MOVE( internal_ptr, &rad_cell_name, 4);
    i = 2;
    GUrad50_to_ascii ( &i, &rad_cell_name, symbol_ref_name );
    internal_ptr += 7;

   /*
    *  2D cell data
    */

    if ( IGDSfiletype == GU_2I )
    {
     OM_BLOCK_MOVE ( internal_ptr, diagpts, 16 );
     for ( i = 0; i < 4; ++i )
     {
        GUswapint ( &diagpts[i], &diagpts[i] );
     }

     internal_ptr += 8;
     OM_BLOCK_MOVE( internal_ptr, transformation, 16 );

     for ( i = 0; i < 4; i++ )
     {
	 GUswapint ( &transformation[i], &transformation[i] );
         transformation[i] = transformation[i]/214748.3647*(*scalefactor);
     }
    
     internal_ptr += 8;
     OM_BLOCK_MOVE( internal_ptr, origin, 8 );
     for ( i = 0; i < 2; i ++ )
     {
	 GUswapint ( &origin[i], &origin[i] );
     }
     diagpts[2] = GUACT_Z_2D;
     diagpts[5] = GUACT_Z_2D;
     transformation[4] = transformation[3];
     transformation[3] = transformation[2];
     transformation[2] = 0;
     transformation[5] = 0;
     transformation[6] = 0;
     transformation[7] = 0;
     transformation[8] = 1;
     origin[2] = GUACT_Z_2D;
    }
 
   /*
    *  3D cell data
    */

    else
    {
     OM_BLOCK_MOVE ( internal_ptr, diagpts, 24 );
     for ( i = 0; i < 6; ++i )
     {
	 GUswapint ( &diagpts[i], &diagpts[i] );
     }

     internal_ptr += 12;
     OM_BLOCK_MOVE( internal_ptr, transformation, 36 );
     for ( i = 0; i < 9; i++ )
     {
	 GUswapint ( &transformation[i], &transformation[i] );
	 transformation[i] = transformation[i]/214748.3647*(*scalefactor);
     }
    
     internal_ptr += 18;
     OM_BLOCK_MOVE( internal_ptr, origin, 12 );
     for ( i = 0; i < 3; i ++ )
     {
	 GUswapint ( &origin[i], &origin[i] );
     }
    }

    /*
     *  set-up scale matrix for IGDS to IGE working units
     */

    scale_matrix[0] = *scalefactor;
    scale_matrix[1] = 0.0;
    scale_matrix[2] = 0.0;
    scale_matrix[3] = 0.0;
    scale_matrix[4] = 0.0;
    scale_matrix[5] = *scalefactor;
    scale_matrix[6] = 0.0;
    scale_matrix[7] = 0.0;
    scale_matrix[8] = 0.0;
    scale_matrix[9] = 0.0;
    scale_matrix[10] = *scalefactor;
    scale_matrix[11] = 0.0;
    scale_matrix[12] = 0.0;
    scale_matrix[13] = 0.0;
    scale_matrix[14] = 0.0;
    scale_matrix[15] = 1.0;

    new_env = *current_env;
   
    MAmulmx ( &msg, &num_rc, &num_rc, &num_rc, current_env->md_env.matrix,
	      scale_matrix, new_env.md_env.matrix );

    MAtypemx ( &msg, new_env.md_env.matrix,
    	       &new_env.md_env.matrix_type );

    const_lis.msg = &const_msg;    
    const_lis.env_info = &new_env;
    const_lis.newflag = FALSE;
    const_lis.level = igdscell->header.level & 0x3f;

    /*
     *  Set up properties word.
     */

    const_lis.properties = 0;

    if ( igdscell->header.properties & 0x2000 )
    {
	const_lis.properties |= GRIS_PLANAR;
    }
    if ( igdscell->header.properties & 0x0200 )
    {
	const_lis.properties |= GRIS_NEW;
    }
    if ( igdscell->header.properties & 0x0400 )
    {
	const_lis.properties |= GRIS_MODIFIED;
    }
    const_lis.properties |= GRIS_LOCATABLE;
    const_lis.properties |= GRIS_DISPLAYABLE;

    const_lis.geometry = (IGRchar *) &symbol_geom;
    const_lis.display = &display;
    const_lis.class_attr = NULL;
    const_lis.name = NULL;
 
    /*
     *  Set up display structure.
     */

    display.color = 
        ((unsigned short)(igdscell->header.symbology & 0xFF00) >> 8);
    display.weight = ((IGRuchar)(igdscell->header.symbology & 0x00F8) >> 3);
    display.style = igdscell->header.symbology & 0x0007;

    if (( display.color == 0 ) & (display.weight == 0) & (display.style == 0 ))
    {
	const_lis.display = NULL;
    }

    /*
     *  Set up cell geometry.
     */

    symbol_geom.matrix[0] = transformation[0];
    symbol_geom.matrix[1] = transformation[1];
    symbol_geom.matrix[2] = transformation[2];
    symbol_geom.matrix[3] = origin[0] / *scalefactor;
    symbol_geom.matrix[4] = transformation[3];
    symbol_geom.matrix[5] = transformation[4];
    symbol_geom.matrix[6] = transformation[5];
    symbol_geom.matrix[7] = origin[1] /  *scalefactor;
    symbol_geom.matrix[8] = transformation[6];
    symbol_geom.matrix[9] = transformation[7];
    symbol_geom.matrix[10] = transformation[8];
    symbol_geom.matrix[11] = origin[2] / *scalefactor;
    symbol_geom.matrix[12] = 0.0;
    symbol_geom.matrix[13] = 0.0;
    symbol_geom.matrix[14] = 0.0;
    symbol_geom.matrix[15] = 1.0;

    symbol_geom.diag_pt1[0] = diagpts[0]/ *scalefactor;
    symbol_geom.diag_pt1[1] = diagpts[1]/ *scalefactor;
    symbol_geom.diag_pt1[2] = diagpts[2]/ *scalefactor;
    symbol_geom.diag_pt2[0] = diagpts[3]/ *scalefactor;
    symbol_geom.diag_pt2[1] = diagpts[4]/ *scalefactor;
    symbol_geom.diag_pt2[2] = diagpts[5]/ *scalefactor;

    /*
     *  Construct the symbol header object and store
     *	its id and osnum.
     */

    status = om$construct(classname = "GRsmhdr",
			  osnum = current_env->md_id.osnum,
                          neighbor = OM_GS_NULL_NEIGHBOR,
                          p_objid = &(object_info->objid),
			  msg = message GRsmhdr.GRconstruct (&const_lis) );

    if ( !(1 & status) )
    {
	goto wrapup;
    }

/*
 *  Search the symbol library b-tree for the
 *  symbol definition matching the cell name
 * 
 *  if found, connect the header object to the reference object
 *  if not found, create the header object
 *	          connect the header object to the reference object
 *		  add the header object to the b-tree containing
 *					incomplete headers
 */

    objarray.size = sizeof (OM_S_OBJARRAY);
    objarray.tree_type = KEY_STRING;

    /*
     *  search btree with incomplete symbol definition
     *  headers
     */

    strcpy (btreename, "sd_btree");

    status = GRbtreelocate ( &msg, 1, &ModuleInfo.md_id.osnum,
			     btreename, symbol_ref_name,
			     &objarray, &loc_OS );

/****************************************************************************/

    find_from_buf(symbol_ref_name, &objarray.count, objarray.array);

/****************************************************************************/


    if ( objarray.count == 0 )
    {

	/*
	 *  search active symbol library
	 */

	gr$symsd_locate ( msg = &msg,
			  num_OS = 1,
			  p_OS = &(current_env->md_id.osnum),
			  sd_name = symbol_ref_name,
			  p_OBJARRAY = &objarray,
			  p_loc_OS = &loc_OS );

	if ( objarray.count == 0 )
	{
	   
	    /*
	     *  create the header object
  	     */

	    status = om$construct ( classname = "GRsmdfhdr",
				    osnum = current_env->md_id.osnum,
				    p_objid = &(sd_objid) );
	    if ( ! (1 & status) )
	    {
		printf("Failed in GRsmdfhdr construct\n");
	        goto wrapup;
	    }

	    /*
	     *  add the header object to the b-tree
	     */

	    status = GRbtreeadd ( &msg, 1, &ModuleInfo.md_id.osnum,
				  btreename, symbol_ref_name,
				  &sd_objid );

	    if ( ! (1 & status) )
	    {
		printf("Failed in GRbtreeadd for %s construct\n", 
							symbol_ref_name);
	        goto wrapup;
	    }

/****************************************************************************/

	add_to_buf(symbol_ref_name, sd_objid);

/****************************************************************************/


        }
	else
	{
	    sd_objid = objarray.array[0];
	}
    }
    else
    {
	sd_objid = objarray.array[0];
    }


/*
 *  connect the header to the reference
 */

    chan_info.type = OM_e_name;
    chan_info.u_sel.name = "to_components";

    sd_info.osnum = current_env->md_id.osnum;
    sd_info.objid = sd_objid;

    status = om$send ( mode = OM_e_wrt_object,
		       msg = message GRconnector.GRflexconn ( &msg, (IGRlong *)&flag,
			     object_info, &index, &index ),
		       senderid = NULL,
		       targetid = sd_objid,
		       targetos = current_env->md_id.osnum );

wrapup:

	*rc = msg;
    	return (status) ;
}

end implementation COcvigdsige;
