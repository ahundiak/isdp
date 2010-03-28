/*
Name
        COcvt_type5lv3

Description
        This method converts an IGDS saved view to an EMS saved view.

History
        A long, long time ago...

        mrm     03/14/92    delete IGEgragad when finished constructing
                            saved view
        dhm     09/16/92    added del_wrapup and GUswapint()'s.

*/

class implementation GRvg;

#include "exsysdep.h"
#include "coimport.h"
#include "transdef.h"
#include "translate.h"
#include "transerr.h"
#include "transmacros.h"
#include "igewindef.h"
#include "igewindow.h"
#include "igewinmacros.h"
#include "dpdef.h"
#include "dpmacros.h"
#include "OMmacros.h"
#include "grdpbdef.h"
#include "grdpbmacros.h"
#include "grerr.h"

/* --------Structure of saved view --------- */

struct IGDS_saved_view
{
   IGRuchar level;
   IGRuchar type;
   IGRshort    	    words_to_follow;
   IGRlong	    range[6];
   IGRshort	    graphic_group;
   IGRshort	    index_to_ae;
   short unsigned   properties;
   IGRshort         num_of_views;
   IGRshort         rad_view_descript[9];
   IGRshort         screens;
   IGRshort         view_descriptor[59];
};
   
from IGEgragad import gragad_cons;

extern OMuword OPP_IGEgragad_class_id;

#argsused
IGRint COcvt_type5lv3 (msg, view, db_type, scale_factor, object_info)

IGRlong                 *msg;
struct IGDS_saved_view  *view;
IGRint			*db_type;
IGRdouble		*scale_factor;
struct GRid             *object_info;
{
    IGRchar             view_descript[28];   
    IGRchar             view_name[7];
    IGRshort            subclass;         
    IGRshort            length = 0;
    IGRshort		*view_table_ptr;
    IGRshort            *rad_vwname_ptr;
    IGRshort		num_views;
    IGRshort            i,j;
    IGRshort		set0_inq1;
    IGRint		gadget_flags[2];
    IGRint		grid_flag;
    IGRint		levels[32];
    IGRlong             num_words;
    IGRlong		view_array[30];
    IGRlong             tempdummy;
    IGRlong		status = 0; 
    IGRlong		mess;
    IGRlong		ret_bytes1;
    IGRlong		ret_bytes2;
    IGRlong		ret_bytes3;
    IGRlong		ret_bytes4;
    IGRlong		ret_bytes5;
    IGRlong		ret_bytes6;
    IGRlong		ret_bytes7;
    IGRlong		ret_bytes8;
    IGRlong		ret_bytes9;
    IGRlong		which_error;
    IGRlong 		grid_per_ref;
    IGRdouble		uor_per_ref;
    IGRdouble 		rotation[4][4];
    IGRdouble 		vw_volume[6];
    IGRdouble 		origin[3];
    IGRdouble		scratch[9];
    IGRdouble		act_z;
    GRobjid		gad_ids[8];
    struct GRid         gadget;
    struct var_list	params[10];
    struct GRmd_env	ModuleInfo;


#ifdef BIG_ENDIAN
    GRswap_type5lv3_ele(view);
#endif

    /* ------ Checking for a saved view -------------------*/

#ifdef BIG_ENDIAN
    subclass = (view->properties & 0x0F00);
#else
    subclass = (view->properties & 0x000F);
#endif

    if (subclass != 1)
    {
        *msg = GRNOTIMPLEMENTED; /* don't understand this element */
        goto wrapup;
    }

    /* ------ Initialize gad_ids to NULL_OBJID ------------- */

    for (i = 0; i < 8; i++)
       gad_ids[i] = NULL_OBJID;

    /* ------ Setting up the grid values ------------------- */

    uor_per_ref = DEF_UOR_PER_REF;
    grid_per_ref = DEF_GRID_PER_REF;

    /* ------ Getting the view name from the attribute linkage -- */

    num_words = 2;
    rad_vwname_ptr = &(view->index_to_ae) + view->index_to_ae + 3;
    GUrad50_to_ascii(&num_words, rad_vwname_ptr, view_name);
    i = 0;
    while (view_name[i] != NULL)
    {
        view_name[i] = tolower(view_name[i]);
        i++;
    }

    /* ---- Getting the number of views ------------------ */

    num_views = (view->num_of_views & 0x000F);
    if (num_views != 0)
    {
        length = strlen(view_name);
    }  

    /* --------Getting the View_description ---------------*/
 
    num_words = 9;
    GUrad50_to_ascii(&num_words, view->rad_view_descript, view_descript);

    /* --------- Getting the module environment ----------- */

    gr$get_module_env(buffer = &ModuleInfo);

    /* -------- Processing the View_table into saved views ----*/

    num_views++;
    view_table_ptr = (view->view_descriptor);

    for (i = 0; i < num_views; i++)
    {
	/* -------- Putting in the View name -----------------*/

	if (num_views > 1)
	{
            sprintf(&view_name[length], "%d", i+1);
	}

	/* ----- Initialize and set gadget & grid flags --- */

	gadget_flags[0] = GRID_ON | GRID_LOCK;
	gadget_flags[1] = 0;

	if (*view_table_ptr & 0x0200)
	{
            grid_flag = 1;
            gadget_flags[1] |= GRID_ON | GRID_LOCK;
	}
	else
	{
            grid_flag = 0;
	}
	
	/* ------ Constructing the Graphic gadget ---------- */

	status = om$construct(osnum = ModuleInfo.md_id.osnum,
                              classid = OPP_IGEgragad_class_id,
                              p_objid = &(gad_ids[i]),
                              msg = message IGEgragad.gragad_cons
                                   (&mess, view_name,
                                    0.0, 0.0, 1.0, 1.0));
   	if (!(status & 1))
	{
            goto wrapup;
	}

   	/* --- Get the level info from the IGDS window --------*/
	    	
   	view_table_ptr ++;
   	OM_BLOCK_MOVE(view_table_ptr, levels, 8);

	levels[0] = ~levels[0];
	levels[1] = ~levels[1];

	status = dp$levels_on_off(msg = &mess,
                                  osnum = ModuleInfo.md_id.osnum,
                                  levels_mask = levels,
                                  update = FALSE, 
                                  on_off_flag = 0, 
                                  objid = gad_ids[i]);

	if (! (status & 1))
	{ 
            goto del_wrapup;
	}

	/* --- Get view parameters out of IGDS element ------*/

	view_table_ptr += 4;
	OM_BLOCK_MOVE(view_table_ptr, view_array, 108);

	for (j = 0; j < 6; j++)
	{
            GUswapint( &(view_array[j]), &tempdummy);
            vw_volume[j] = (IGRdouble) tempdummy;
/*	    vw_volume[j] = view_array[j]; */
	}   

	/* ----- Calculate the view origin --------- */

	for (j = 0; j < 3; j++)
	{
	    origin[j] = vw_volume[j];
	}

	/* -- Kludge to convert 2D VAX views to OSA 3D windows ----*/

	if (*db_type == GU_2I)
	{
            vw_volume[2] = GUMINVV_Z_2D;
            vw_volume[5] = GUMAXVV_Z_2D;
            origin[2] = GUMINVV_Z_2D; /* should = values given 2-d objects */
	}

	for (j = 0; j < 3; j++)
	{
    	    origin[j] /= *scale_factor;
	    vw_volume[j] = 0.0;
	}

	for (j = 3; j < 6; j++)
	{
	    vw_volume[j] /= *scale_factor;
	}      	

	/* ------ Set up view rotation -----------*/

        GUswapint( &(view_array[26]), &tempdummy);
        act_z = (IGRdouble) tempdummy;
/*	act_z = view_array[26]; */
	fltvax_to_flt32 (9, &(view_array[6]), scratch);
	act_z /= *scale_factor;

	if (*db_type == GU_2I)
	{
            act_z = GUACT_Z_2D;	/* should = values given 2-D objects */
            rotation[0][0] = scratch[0];
            rotation[0][1] = scratch[1];
            rotation[0][2] = 0.0;
            rotation[0][3] = 0.0;
            rotation[1][0] = scratch[2];
            rotation[1][1] = scratch[3];
            rotation[1][2] = 0.0;
            rotation[1][3] = 0.0;
            rotation[2][0] = 0.0;
            rotation[2][1] = 0.0;
            rotation[2][2] = 1.0;
            rotation[2][3] = 0.0;
            rotation[3][0] = 0.0;
            rotation[3][1] = 0.0;
            rotation[3][2] = 0.0;
            rotation[3][3] = 1.0;
	}
	else
	{
            rotation[0][0] = scratch[0];
            rotation[0][1] = scratch[1];
            rotation[0][2] = scratch[2];
            rotation[0][3] = 0.0;
            rotation[1][0] = scratch[3];
            rotation[1][1] = scratch[4];
            rotation[1][2] = scratch[5];
            rotation[1][3] = 0.0;
            rotation[2][0] = scratch[6];
            rotation[2][1]= scratch[7];
            rotation[2][2] = scratch[8];
            rotation[2][3] = 0.0;
            rotation[3][0] = 0.0;
            rotation[3][1] = 0.0;
            rotation[3][2] = 0.0;
            rotation[3][3] = 1.0;
	}

	/* -- Set the gadget parameters to resemble the saved view -- */
	/* --               as closely as possible                 -- */

	gadget.osnum = ModuleInfo.md_id.osnum;
	gadget.objid = gad_ids[i];
	set0_inq1 = 0;

	params[0].var			= GRAGAD_FLAGS;
	params[0].var_ptr		= (IGRchar *)gadget_flags;
	params[0].num_bytes		= sizeof(IGRint) * 2;
	params[0].bytes_returned	= &ret_bytes5;

	params[1].var			= GRID_PER_REF_X;
	params[1].var_ptr		= (IGRchar *)&grid_per_ref;
	params[1].num_bytes		= sizeof(IGRlong);
	params[1].bytes_returned	= &ret_bytes6;

	params[2].var			= GRID_PER_REF_Y;
	params[2].var_ptr		= (IGRchar *)&grid_per_ref;
	params[2].num_bytes		= sizeof(IGRlong);
	params[2].bytes_returned	= &ret_bytes7;

	params[3].var			= UOR_PER_REF_X;
	params[3].var_ptr		= (IGRchar *)&uor_per_ref;
	params[3].num_bytes		= sizeof(IGRdouble);
	params[3].bytes_returned	= &ret_bytes8;

	params[4].var			= UOR_PER_REF_Y;
	params[4].var_ptr		= (IGRchar *)&uor_per_ref;
	params[4].num_bytes		= sizeof(IGRdouble);
	params[4].bytes_returned	= &ret_bytes9;

	params[5].var			= VW_VOLUME;
	params[5].var_ptr		= (IGRchar *)vw_volume;
	params[5].num_bytes		= sizeof(IGRdouble) * 6;
	params[5].bytes_returned	= &ret_bytes1;

	params[6].var			= VIEW_ROTATION;
	params[6].var_ptr		= (IGRchar *)rotation;
	params[6].num_bytes		= sizeof(IGRmatrix);
	params[6].bytes_returned	= &ret_bytes3;

	params[7].var			= VIEW_ORIGIN;
	params[7].var_ptr		= (IGRchar *)origin;
	params[7].num_bytes		= sizeof(IGRdouble) * 3;
	params[7].bytes_returned	= &ret_bytes4;

	params[8].var			= ACT_Z;
	params[8].var_ptr		= (IGRchar *)&act_z;
	params[8].num_bytes		= sizeof(IGRdouble);
	params[8].bytes_returned	= &ret_bytes2;
	
	params[9].var			= END_PARAM;
	params[9].var_ptr		= NULL;
	params[9].num_bytes		= 0;
	params[9].bytes_returned	= NULL;

	/* ------ Setting the graphic gadget to resemble --------- */
	/* ------            the saved view              --------- */

 	status = dp$inq_set_gragad (msg = &mess,
                                    inq0_set1 = 1,
                                    calc_info = 1, 
                                    which_error = &which_error,
                                    var_list = params,
                                    gragad_objid = gad_ids[i],
                                    osnum = ModuleInfo.md_id.osnum);
		
	if (! (status & 1))
	{
            goto del_wrapup;
	}

	/* ------------- Construct the saved view ------------- */

	status  = dp$savvw_cons (msg = &mess,
                                 osnum = &ModuleInfo.md_id.osnum,
                                 vw_name = view_name,
                                 gg_id = &gadget,
                                 in_flags = GGI_STRUCT,
                                 descript = view_descript);
				 
	if (! (status &  1))
	{
            goto del_wrapup;
	}

	if (num_views != 1)
	{
            view_table_ptr += 54;
	}

	if ((num_views == 8) && (i == 3))
	{
            view_table_ptr += 36;
	}

        /* delete the gragad used to construct the saved view 

        om$send(msg = message IGEgragad.delete(NULL),
                senderid = NULL_OBJID,
                targetid = gad_ids[i],
                targetos = ModuleInfo.md_id.osnum);  */
    }


del_wrapup:
     for (i = 0; i < 8; i++)
     {
        if ( gad_ids[i] != NULL_OBJID )
        {
          om$send(msg = message IGEgragad.delete(NULL),
                  senderid = NULL_OBJID,
                  targetid = gad_ids[i],
                  targetos = ModuleInfo.md_id.osnum);
        }
     }

wrapup:

    return (status);
}

end implementation GRvg;
