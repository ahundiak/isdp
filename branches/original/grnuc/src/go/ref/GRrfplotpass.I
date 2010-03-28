/*
Name
        GRreffile.GRplotpass

Description

History
        mrm     12/12/91    removed local struct definitions and use the ones
                            defined in translate.h
        dhm     07/07/92    ANSI conversion.
        Jack    10/04/92    Added support for tangent edge suppression.
*/

class implementation GRreffile;

#include "grimport.h"
#include "OMmacros.h"
#include "msdef.h"
#include "madef.h"
#include "OMindex.h"
#include "refdef.h"
#include "refpriv.h"
#include "gomacros.h"
#include "godef.h"
#include "gocmacros.h"
#include "dpdef.h"
#include "dpmacros.h"
#include "grsymdef.h"
#include "transdef.h"
#include "translate.h"
#include "grdpbdef.h"
#include "grdpbmacros.h"
#include "detaildef.h"
#include <alloca.h>

extern    IGRint    GUprocessplot();
extern    IGRboolean    GRexpansion_valid();
extern    IGRshort  GUsubcount();
extern 	  IGRint    GUsetsymb();
extern 	  IGRint    GUinitsymb();
extern    void      GRdv_tangent_edge_display();

from GRdvattach import GRget_put_orientation;

method GRplotpass(IGRlong *msg; OM_S_MESSAGE *plot_msg; IGRint *levels;
	struct IGRcv_prism *prism_array; IGRint *num_prisms; IGRint (*filter_function)(); IGRchar *filter_data)
{
    IGRchar	*ptr;			/* geometry pointer		*/

    IGRboolean  is_skew,		/* indicator for skew view	*/
		set_clear,
		malloced;

    IGRboolean  hidden_so_flag, hidden_so_off = 0;

    IGRshort	symb_props;

    IGRlong  	OMmsg,			/* local return codes		*/
		msg1;

    IGRint   	dimension,		/* dimension of filename	*/
		i,
		index,
		size;

    IGRdouble	tolerance,
		buffer[1000];

    struct GRmd_env pass_env;		/* environment info for pass	*/
    struct IGRcv_prism *prism,
		new_prism,
		local_prism_array[50],
		*prism_ptr;
    struct GRsymbology symb;
    struct GRfunction_info function_info;

    OM_S_MESSAGE  pass_msg, 		/* structs for make message	*/
		new_plot_msg;

    OM_S_CHANSELECT    chan,
                       owner_chan;    /* channel to drawing view attachment */
  OMuint               chan_count=0;
  OM_S_OBJECT_LINKAGE *list=NULL;
  IGRint               cntr;
  OMuword              classid;
  IGRint               get_flag,
                       orient,
                       inquire_only,
                       turn_on = 1,
                       result;

    struct GUplot_element_args *plot_args, local_plot_args;
    struct GUplot_user_info my_info;
    struct function_struct		/* arguments for GRfunction	*/
    {
	IGRlong	*msg;
	IGRint    (*usr_function)();
	IGRchar *info;
    } function_args;

    *msg = MSSUCC;
    OMmsg = OM_S_SUCCESS;

    result = 0;
    inquire_only=0;


    if (!  ( (me->properties & GRIS_DISPLAYABLE) &&
	      GRexpansion_valid() ) )
    {
     	goto wrapup;
    }

    /* If the object space is opened, set up to call function to 
     * plot the objects in the reference file object space 
     */

    dimension = om$dimension_of(varray= me->osname);
	
    if (dimension)
    {
    /*
     * first, if there is a dv attachment, see if it has tangent edge
     * display suppressed and notify the edge plot func accordingly.
     */
    owner_chan.type = OM_e_addr;
    owner_chan.u_sel.addr = &me->to_owners;

    /* check if there is a drawing view attachment connected to me */
    om$get_channel_count( object = me,
                          p_chanselect = &owner_chan,
                          count = &chan_count );
    if(chan_count > 0)
      {
       /* allocate memory for the list of objects */      
       list = (OM_S_OBJECT_LINKAGE *) alloca(sizeof(OM_S_OBJECT_LINKAGE) *
                                                    chan_count);

       /* get the drawing view attachment object */
       OMmsg = om$get_channel_objects( object = me,
                                       p_chanselect = &owner_chan,
                                       size = chan_count,
                                       list = list,
                                       count = &chan_count);
       if(! (1 & OMmsg )) goto wrapup;

       for(cntr=0;cntr<chan_count;cntr++)
        {
         OMmsg = om$get_classid(osnum = list[cntr].osnum,
                                objid = list[cntr].S_objid,
                                p_classid = &classid );
       if(! (1 & OMmsg )) goto wrapup; 

         if( classid == OPP_GRdvattach_class_id )
          {
           /* the tangent edge display flag (bit) is in the orientation
              int for the drawing view attachment.
            */  
           orient = 0;
           get_flag = 1;
           OMmsg = om$send(msg = message GRdvattach.GRget_put_orientation
                                         (msg, 
                                          get_flag,
                                         &orient),
                            senderid = my_id,
                            targetos = list[cntr].osnum,
                            targetid = list[cntr].S_objid );
           if(! (1 & OMmsg & *msg)) goto wrapup;
            
           /* toggle the tangent edge display flag */
           if(orient & GR_DV_TAN_ED_DIS_OFF_CURRENT)  /* if display is off */
            {
             turn_on=0;
             /* turn static variable off(edge display methods will
                access it.)
              */  
             GRdv_tangent_edge_display(inquire_only,
                                       turn_on,
                                      &result);
            } /* if the display for the drawing view is off */
            
          } /* if we found the GRdvattach object */
          
        } /* looping through the channel objects */
        
        
      } /* if( chan_count > 0 ) */





	is_skew = ((me->ref_properties & GRIS_SKEW) ? 1 : 0);

      	OMmsg = om$make_message(classname = "GRgraphics",
       	    methodname = "GRfunction",
            size = sizeof( struct function_struct),
            p_arglist = &function_args,
            p_msg = &pass_msg);

    	if (1 & OMmsg)
	{
 	    /* Set up the new message structures to pass to objects
	     * in the reference file.
	     * The environment information will be different.
	     */

    	    plot_args = (struct GUplot_element_args *)plot_msg->p_arglist;
    	    local_plot_args = *plot_args;
	    local_plot_args.internal_msg = msg;
	    local_plot_args.md_env = &pass_env;

    	    new_plot_msg = *plot_msg;
	    new_plot_msg.p_arglist = (char *)&local_plot_args;

	    GRcomputectx(&msg1,&plot_args->md_env->md_env.matrix_type,
		    plot_args->md_env->md_env.matrix,
		    me->ref_to_master_matrix,
		    &pass_env.md_env.matrix_type,
		    pass_env.md_env.matrix);
		    
	    /* Get the prism to add to the prism array
	     */

	    GRgetabsg(&msg1,&plot_args->md_env->md_env.matrix_type,
		plot_args->md_env->md_env.matrix, &ptr, i);
		
	    prism = (struct IGRcv_prism *) ptr;

					/* find size needed for buffer	*/
	    GRbc_size(prism->curve.order,prism->curve.num_poles,
		    prism->curve.rational,prism->curve.num_boundaries,
		    size);
					/* see if allocation necessary	*/
	    if (size > sizeof(buffer))
	    {
		ptr =  om$malloc(size = size);
		malloced = TRUE;
	    }
	    else
	    {
		malloced = FALSE;
		ptr = (IGRchar *)buffer;
	    }
	    new_prism.curve.poles = (IGRdouble *)ptr;
	    index = prism->curve.num_poles * 3;
	    new_prism.curve.knots = &new_prism.curve.poles[index];
	    index = prism->curve.num_knots;
	    if (prism->curve.rational)
	    {
		new_prism.curve.weights = &new_prism.curve.knots[index];
		index += prism->curve.num_poles;
	    }
	    else
	    {
		new_prism.curve.weights = 0;
	    }
	    if (prism->curve.num_boundaries)
	    {
		new_prism.curve.bdrys = &new_prism.curve.knots[index];
	    }

	    MAbccopy(&msg1,&prism->curve,&new_prism.curve);
	    for (i=0; i<16; ++i)
	    {
		new_prism.matrix[i] = prism->matrix[i];
	    }
	    new_prism.height = prism->height;

	    /* add the prism for this attachment to the prism array
	     */

	    if (*num_prisms > 0)
	    {
		if (*num_prisms > 49)
		{
		    prism_ptr = (struct IGRcv_prism *)om$malloc
                        (size = 
                         (sizeof(struct IGRcv_prism) * (*num_prisms+1)));
		}
		else
		{
		    prism_ptr = local_prism_array;
		}
		for (i=0; i<*num_prisms; ++i)
		{
		    prism_ptr[i] = prism_array[i];
		}
		prism_ptr[i] = new_prism;
	    }		
	    else
	    {
		prism_ptr = &new_prism;
	    }

				/* load arguments to GRfunction		*/
	    function_args.msg = msg;
	    function_args.usr_function = GUprocessplot; 
	    function_args.info = (IGRchar *)&function_info;

	    go$build_user_function_buffer(
			buffer = &function_info,
			md_env = NULL,
			pass_on = 0,
			your_info = &my_info);

				/* load information for user function	*/
	    my_info.plot_msg = &new_plot_msg;
	    my_info.prism_array = prism_ptr;
	    my_info.num_prisms = *num_prisms + 1;
	    my_info.levels = me->dp_levels;
            my_info.filter_function = filter_function;
            my_info.filter_data = filter_data;

				/* set channel indexes			*/
	    chan.type = OM_e_name;
	    chan.u_sel.name = "GRcmpowner.to_components";
	    om$get_channel_count(
		osnum = plot_args->id_info[1].osnum,
		objid = plot_args->id_info[1].objid,
		p_chanselect = &chan,
		count = (IGRuint *) &my_info.index1);

	    my_info.index2 = my_info.index1;

	    Get_module_info(&msg1,me->osname,&pass_env.md_id.osnum,
		    &pass_env.md_id.objid);

	    if ( 1 & msg1)
	    {
	    	tolerance = 0.0;

		if (me->ref_properties & GROVERRIDE_SYMBOLOGY)
		{
		    symb_props = 0;
		    set_clear = 1;
		    symb.display_attr = me->display_attr;
		    symb.level = me->level;

		    if (me->display_attr.color != ((unsigned short)-1))
		    {
			symb_props |= GR_SYM_COLOR;
		    }			    		    
		    if (me->display_attr.weight != ((unsigned char) -1))
		    {
			symb_props |= GR_SYM_WEIGHT;
		    }
		    if (me->display_attr.style != ((unsigned char) -1))
		    {
			symb_props |= GR_SYM_STYLE;
		    }

		    GUset_symb(&msg1,&symb,&symb_props,&set_clear);

		    GUaddcount();
		}

		if (me->ref_properties & GRHIDDEN_OFF)
                {
                    /* save the current setting and turn them off */
                    gr$get_hidden_so_on(buffer = &hidden_so_flag);
                    gr$put_hidden_so_on(buffer = &hidden_so_off);
                }

		OMmsg = GRrefpass(msg,
		    &plot_args->md_env->md_env.matrix_type,
		    plot_args->md_env->md_env.matrix,
		    &pass_env,&pass_msg,&is_skew,me->vw_origin,
		    me->vw_rotation,NULL,NULL,NULL,me->vw_volume,
		    me->master_to_ref_matrix,me->range,&tolerance,
		    &my_id,&OM_Gw_current_OS);

		if (me->ref_properties & GROVERRIDE_SYMBOLOGY)
		{
		    if (GUsubcount())
		    {
		        set_clear = 0;
		        GUset_symb(&msg1,&symb,&symb_props,&set_clear);
		    }
		    else
		    {
			GUinit_symb();
		    }
		}

		if (me->ref_properties & GRHIDDEN_OFF)
                    gr$put_hidden_so_on(buffer = &hidden_so_flag);
	    }

	    if ( *num_prisms > 49)
	    {
		om$dealloc(ptr = prism_ptr);
	    }
	    if (malloced)
	    {
		om$dealloc(ptr = ptr);
	    }
	}
    }

wrapup:
  if(chan_count > 0)
    if(turn_on == 0) 
     {
      /* reset the static tangent edge display variable */
      turn_on = 1;
      GRdv_tangent_edge_display(inquire_only,
                                turn_on,
                               &result);
     }

    return (OMmsg);

}
end implementation GRreffile;
