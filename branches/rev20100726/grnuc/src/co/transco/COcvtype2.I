/* #######################    APOGEE COMPILED   ######################## */
/*
 *  This function will translate IGDS 2D and 3D cells into
 *  IGE 3D cells.
 */

class implementation COcvigdsige;

#include "coimport.h"
#include "godef.h"
#include "OMmacros.h"
#include "grdpbmacros.h"
#include "transdef.h"
#include "grsymdef.h"
#include "vardef.h"
#include "var.h"

from GRconnector import GRrigidconn;
from GRclhdr import GRconstruct;
from GRsymbol import GRset_inq_symbol;
from GRgraphics import GRchgprops;

method cvt_type2 (IGRlong *msg; struct GRid *object_info)
{

    struct IGDS_cell	*igdscell;
    static IGRint	nest_depth = -1;
    static IGRint	level_total = 0;
    IGRint		i;
    IGRlong		status = FALSE;
    IGRlong		const_msg;
    short unsigned	wds_in_descript;
    IGRlong		rad_cell_name;
    IGRlong		diag_pt1[3];
    IGRlong		diag_pt2[3];
    IGRlong		transformation[9];
    IGRdouble		dtransformation[9];
    IGRlong		origin[3];
    IGRshort		*internal_ptr;
    IGRlong		tempdummy;
    IGRlong		index = OM_K_MAXINT;
    struct GRid		module_info;
    struct GRmd_env	mod_environ;
    struct GRid		header;
    IGRint		save_wds;
    IGRlong		nbytes_in_buffer;
    IGRlong		nbytes_transferred;
    struct IGRdisplay	display;
    struct IGRlbsys	symbol_geom;
    struct GRvg_construct	const_lis;
    struct GUcommon_header_info element;	/* GUgetname info	*/
    IGRint		has_link;		/* TRUE if named element*/
    IGRchar		name[257];		/* element's name	*/
    IGRchar		*typeface = NULL;
    IGRchar		*charmap = NULL;
    IGRmatrix		scale_matrix;
    struct GRmd_env	new_env;
    IGRshort		num_rc = 4;
    IGRchar		cell_name[7];
    IGRlong		num_words = 2;
    IGRlong		bytes_returned;
    struct GRvar_list	var_list[2];
    IGRint		set_inq = 1;
    IGRint		sav_ele_size;
    
    nest_depth += 1;

    /*
     *  Extract data from the IGDS cell
     *	element header.
     */

    igdscell = (struct IGDS_cell *) me->cvt_bufs.ele_buf;
    sav_ele_size = me->cvt_bufs.ele_size;
    internal_ptr = (IGRshort *) &igdscell->cell_data;
    wds_in_descript = *internal_ptr;

    /*
     *  Calculate the number of words in the component
     *  elements of the cell.
     */

    wds_in_descript -= (igdscell->header.words_to_follow - 17);
    save_wds = wds_in_descript;

    /*
     * When wds_in_descript is 0, and the complex_bit is set in the cell
     * header, the cell is from a cell library and is a valid cell. When
     * only the wds_in_descript is 0, the cell header was probably generated
     * during a conversion from EMS into IGDS. These cell header's
     * words in description are insufficient to contain all the elements 
     * in the cell. The cell was therefore flattened. The cell header is
     * left in the IGDS file because, the Electronics group required the 
     * cell header information in the cell. The else clause is to take
     * care of these IGDS files that may be translated back into EMS again.
     */

    if ((wds_in_descript == 0) && (igdscell->header.level & 0x80))
    {
	status = COcvtcltype2 ( msg, igdscell, &me->scale_factor, 
				&me->IGDS_file_type, &me->current_env,
				object_info, me->ModuleInfo );
	nest_depth -= 1;
	goto wrapup;
    }
    else 
    {
	if ( wds_in_descript == 0)
	{
	   goto wrapup;
	}
    }

    internal_ptr++;

    OM_BLOCK_MOVE( internal_ptr, &rad_cell_name, 4);
    GUrad50_to_ascii(&num_words, &rad_cell_name, cell_name);

    internal_ptr += 7;

   /*
    *  Get data from 2D cell.
    */

   if ( me->IGDS_file_type == GU_2I )
   {
    OM_BLOCK_MOVE( internal_ptr, diag_pt1, 8 );
    for ( i = 0; i < 2; i++ )
    {
	GUswapint( &diag_pt1[i], &tempdummy );
    }
    diag_pt1[2] = GUACT_Z_2D;

    internal_ptr += 4;
    OM_BLOCK_MOVE( internal_ptr, diag_pt2, 8 );
    for ( i = 0; i < 2; i++ )
    {
    	GUswapint( &diag_pt2[i], &tempdummy );
    }
    diag_pt2[2] = GUACT_Z_2D;

    internal_ptr += 4;

    OM_BLOCK_MOVE( internal_ptr, transformation, 16 );

    GUswapint( &transformation[0], &tempdummy );
    GUswapint( &transformation[1], &tempdummy );
    GUswapint( &transformation[2], &tempdummy );
    GUswapint( &transformation[3], &tempdummy );

    dtransformation[0] = transformation[0]/214748.3647*me->scale_factor;
    dtransformation[1] = transformation[1]/214748.3647*me->scale_factor;
    dtransformation[3] = transformation[2]/214748.3647*me->scale_factor;
    dtransformation[4] = transformation[3]/214748.3647*me->scale_factor;

    dtransformation[2] = 0;
    dtransformation[5] = 0;
    dtransformation[6] = 0;
    dtransformation[7] = 0;
    dtransformation[8] = 1;
    
    internal_ptr += 8;

    OM_BLOCK_MOVE( internal_ptr, origin, 8 );

    for ( i = 0; i < 2; i ++ )
    {
	GUswapint ( &origin[i], &tempdummy );
    }
    origin[2] = GUACT_Z_2D;

   }

   else
   {
	
   /*
    *  Get data from 3D cell.
    */

    OM_BLOCK_MOVE( internal_ptr, diag_pt1, 12 );
    for ( i = 0; i < 3; i++ )
    {
	GUswapint( &diag_pt1[i], &tempdummy );
    }

    internal_ptr += 6;
    OM_BLOCK_MOVE( internal_ptr, diag_pt2, 12 );
    for ( i = 0; i < 3; i++ )
    {
    	GUswapint( &diag_pt2[i], &tempdummy );
    }

    internal_ptr += 6;

    OM_BLOCK_MOVE( internal_ptr, transformation, 36 );

    for ( i = 0; i < 9; i++ )
    {
	GUswapint( &transformation[i], &tempdummy );
	dtransformation[i] = transformation[i]/214748.3647*me->scale_factor;
    }
    
    internal_ptr += 18;

    OM_BLOCK_MOVE( internal_ptr, origin, 12 );

    for ( i = 0; i < 3; i ++ )
    {
	GUswapint ( &origin[i], &tempdummy );
    }

   }
 
    /*
     *  KLUDGE.  At this time, nested IGDS cells are
     *  flattened into one cell object with components.
     */

    if ( nest_depth > 0 )
    {
	status = FALSE;
 	goto leave;
    }

    nbytes_in_buffer = sizeof(mod_environ);
    gr$get_module_env ( msg = msg,
			sizbuf = &nbytes_in_buffer,
			buffer = &mod_environ,
		        nret = &nbytes_transferred );

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
        ((unsigned short)(igdscell->header.symbology & 0xFF00 ) >> 8);
    display.weight = ((IGRuchar)(igdscell->header.symbology & 0x00F8) >> 3);
    display.style = igdscell->header.symbology & 0x0007;

    /*
     *  Set up range.
     */

   symbol_geom.diag_pt1[0] = diag_pt1[0] / me->scale_factor;
   symbol_geom.diag_pt1[1] = diag_pt1[1] / me->scale_factor;
   symbol_geom.diag_pt1[2] = diag_pt1[2] / me->scale_factor;

   symbol_geom.diag_pt2[0] = diag_pt2[0] / me->scale_factor;
   symbol_geom.diag_pt2[1] = diag_pt2[1] / me->scale_factor;
   symbol_geom.diag_pt2[2] = diag_pt2[2] / me->scale_factor;


    /*
     *  Set up cell geometry.
     */

    symbol_geom.matrix[0] = dtransformation[0];
    symbol_geom.matrix[1] = dtransformation[1];
    symbol_geom.matrix[2] = dtransformation[2];
    symbol_geom.matrix[3] = origin[0];
    symbol_geom.matrix[4] = dtransformation[3];
    symbol_geom.matrix[5] = dtransformation[4];
    symbol_geom.matrix[6] = dtransformation[5];
    symbol_geom.matrix[7] = origin[1];
    symbol_geom.matrix[8] = dtransformation[6];
    symbol_geom.matrix[9] = dtransformation[7];
    symbol_geom.matrix[10] =dtransformation[8];
    symbol_geom.matrix[11] = origin[2];
    symbol_geom.matrix[12] = 0.0;
    symbol_geom.matrix[13] = 0.0;
    symbol_geom.matrix[14] = 0.0;
    symbol_geom.matrix[15] = 1.0;

	/*
         *  set-up scale matrix for IGDS to IGE working units
         */

	scale_matrix[0] = me->scale_factor;
	scale_matrix[1] = 0.0;
	scale_matrix[2] = 0.0;
	scale_matrix[3] = 0.0;
	scale_matrix[4] = 0.0;
	scale_matrix[5] = me->scale_factor;
	scale_matrix[6] = 0.0;
	scale_matrix[7] = 0.0;
	scale_matrix[8] = 0.0;
	scale_matrix[9] = 0.0;
	scale_matrix[10] = me->scale_factor;
	scale_matrix[11] = 0.0;
	scale_matrix[12] = 0.0;
	scale_matrix[13] = 0.0;
	scale_matrix[14] = 0.0;
	scale_matrix[15] = 1.0;

        new_env = mod_environ;
   
        MAmulmx ( msg, &num_rc, &num_rc, &num_rc, mod_environ.md_env.matrix,
		  scale_matrix, new_env.md_env.matrix );

        MAtypemx ( msg, new_env.md_env.matrix,
		   &new_env.md_env.matrix_type );


    /*
     *	Check the user data linkage for an element name.
     */

	element = igdscell->header;
	has_link = GUattr_link (msg, &igdscell->header, name,
			&igdscell->header.symbology, typeface, charmap);


    /*
     *  Construct the symbol header object and store
     *	its id and osnum.
     */

    status = om$construct(osnum = object_info->osnum,
                          classname = "GRclhdr",
                          p_objid = &(object_info->objid),
                          msg = message GRclhdr.GRconstruct ( &const_lis ) );
    var_list[0].var = GR_SYMBOL_NAME;
    var_list[0].var_ptr = cell_name;
    var_list[0].num_bytes = 7;
    var_list[0].bytes_returned = &bytes_returned;
    var_list[1].var = END_PARAM;
    var_list[1].var_ptr = NULL;
    var_list[1].num_bytes = NULL;
    var_list[1].bytes_returned = &bytes_returned;

    status = om$send( msg = message GRsymbol.GRset_inq_symbol (
		      msg, set_inq,var_list),
	     senderid = my_id,
	     targetid = object_info->objid,
	     targetos = object_info->osnum);


   /* 
    *  Enter the IGDS element's name into the translated element's
    *  data structure.
    */

	if (has_link & HAS_NAME_TYPE)
	{
	  GUputname(msg, name, object_info, &me->current_env);
 	}


    /*
     *  Save the object space number and object id
     *	of the current active module for use in 
     * 	nested cells.
     */

    module_info.osnum = object_info->osnum;
    module_info.objid = object_info->objid;

    header.osnum = object_info->osnum;
    header.objid = object_info->objid;

    /*
     *  Process the cell elements at this level of nesting.
     */

    while ( wds_in_descript > 0 )
    {
	object_info->osnum = module_info.osnum;
	object_info->objid = module_info.objid;
	
	status = om$send (mode = OM_e_wrt_object, 
			  msg = message COcvigdsige.cvt_next_ele ( msg, 
						object_info ), 
			  senderid = my_id, 
			  targetid = my_id );

	sav_ele_size += me->cvt_bufs.ele_size;
	if ( me->cvt_bufs.ele_type == GU_CELL )
	{
	    wds_in_descript -= level_total;
	}
	else
	{
	    wds_in_descript -= (me->cvt_bufs.ele_size/2);

	    if ( object_info->objid != module_info.objid )
	    {

  	        /*
 	         *  Connect object to symbol header.
	         */

	    	status = om$send(mode = OM_e_wrt_object,
                                 msg = message GRconnector.GRrigidconn
				( msg, &header, &index ),
                                 senderid = NULL,
                                 targetid = object_info->objid,
				 targetos = object_info->osnum );

	    }

	}

    }


leave:

    if ( !(1 & status) )
    {
	/*
    	 *  Failure to complete the symbol object, skip
 	 *  IGDS cell header and continue processing the
	 *  individual components as separate objects.
	 */

	level_total = igdscell->header.words_to_follow + 2;
    }
    else
    {
    	level_total = save_wds;
    }

    nest_depth -= 1;

    object_info->osnum = header.osnum;
    object_info->objid = header.objid;
    me->cvt_bufs.ele_size = sav_ele_size;

wrapup:

return (status);
}

end implementation COcvigdsige;
