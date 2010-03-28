/* #######################    APOGEE COMPILED   ######################## */
class           COpart
product_name    "$SOURCE"
super_class     COdpb
super_class     COtools
super_class     CEO_GSLOCATE
start_state     terminate
spec_path       "$GRNUC/co/spec"
path            "."
options         "SItc"

specification

#include <coimport.h>
#include <FI.h>
#include <grownerdef.h>
#include <growner.h>
#include <grsymdef.h>
#include <grsym.h>
#include <grsymmacros.h>
#include <DIdef.h>
#include <DItypedef.h>
#include <DIglob.h>
#include <DIprims.h>
#include <DImacros.h>
#include <msdef.h>
#include <msmacros.h>
#include "part.h"
#include "partdef.h"
#include "partmacros.h"
#include "partco.h"
#include "grmessage.h"

instance
{
    struct GRid                 part;
    IGRint                      num_attrs;
    variable IGRchar            attr[10][MAX_ATTR];
    variable IGRchar            value[10][MAX_VALUE];
    variable IGRint             type[10];
    IGRint                      num_objects;
    variable struct GRobj_env   object[25];
    variable struct format      format[5];
    IGRint                      num_processed;
    variable struct GRid        parts[10];
    IGRint                      num_parts;
    IGRint                      parts_processed;
}

implementation

#include <coimport.h>
#include <msdef.h>
#include <msmacros.h>
#include "grmessage.h"
#include "DIdef.h"

#define MAX_CATALOGS 10
#define MAX_GRIDS    50

from GRpart     import GRnum_attributes;
from GRgraphics import GRdisplay;
from GRlinear   import GRgetpolyline;

action arg_name_to_value
{
    *ret_type = _COB_UNKNOWN_ARG;
    *is_const = 0;

    if ( class_name[0] ) 
    {
        if ( !strcmp ( arg, "num_attrs" ) ) 
        {
            if ( addr_mode == _COB_address ) 
            {
                data->p = (char *) (&me->num_attrs);
                *ret_type = _COB_arg_p;
                *is_const = 1;
            }
            else if ( addr_mode == _COB_regular ) 
            {
                data->i = (int)me->num_attrs;
                *ret_type = _COB_arg_i;
            }
        }
        else if ( !strcmp ( arg, "num_parts" ) ) 
        {
            if ( addr_mode == _COB_address ) 
            {
                data->p = (char *) (&me->num_parts);
                *ret_type = _COB_arg_p;
                *is_const = 1;
            }
            else if ( addr_mode == _COB_regular ) 
            {
                data->i = (int)me->num_parts;
                *ret_type = _COB_arg_i;
            }
        }
        else if ( !strcmp ( arg, "parts_processed" ) ) 
        {
            if ( addr_mode == _COB_address ) 
            {
                data->p = (char *) (&me->parts_processed);
                *ret_type = _COB_arg_p;
                *is_const = 1;
            }
            else if ( addr_mode == _COB_regular ) 
            {
                data->i = (int)me->parts_processed;
                *ret_type = _COB_arg_i;
            }
        }
        else if ( !strcmp ( arg, "num_objects" ) ) 
        {
            if ( addr_mode == _COB_address ) 
            {
                data->p = (char *) (&me->num_objects);
                *ret_type = _COB_arg_p;
                *is_const = 1;
            }
            else if ( addr_mode == _COB_regular ) 
            {
                data->i = (int)me->num_objects;
                *ret_type = _COB_arg_i;
            }
        }
        else if ( !strcmp ( arg, "num_processed" ) ) 
        {
            if ( addr_mode == _COB_address ) 
            {
                data->p = (char *) (&me->num_processed);
                *ret_type = _COB_arg_p;
                *is_const = 1;
            }
            else if ( addr_mode == _COB_regular ) 
            {
                data->i = (int)me->num_processed;
                *ret_type = _COB_arg_i;
            }
        }
        else if ( !strcmp ( arg, "part" ) ) 
        {
            if ( addr_mode == _COB_address ) 
            {
                data->p = (char *) (&me->part);
                *ret_type = _COB_arg_p;
                *is_const = 1;
            }
        }
    }

    if ( *ret_type == _COB_UNKNOWN_ARG ) 
    {
        om$send ( targetid = my_id,
                  mode = OM_e_wrt_message,
                  msg = message CEO_LOCATE.arg_name_to_value ( addr_mode,
                                                               class_name,
                                                               arg,
                                                               data,
                                                               ret_type,
                                                               is_const ) );
    }

    return OM_S_SUCCESS;
}
/*
 * 'gather_objects' succedes by loading the me->object VLA with all
 * located parts (via me->located_chansel).  The number of parts 
 * 'gathered' is put in me->num_objects.
 */
action gather_objects (IGRint * msg )
{
    IGRint  om_msg = OM_S_SUCCESS, ok;
    IGRint  count, size;
    
    *msg = MSSUCC;

    /*
     * Remove the fence from the graphic set if it 
     * exists.
     */
    gr$gsremove_fence ( msg = &ok,
                        p_chanselect = &me->located_chansel );
                                            
    /*
     * Get the number of objects on the channel.
     */
    om_msg = gr$gsinqcount ( msg = msg, 
                             count = &count, 
                             p_chanselect = &me->located_chansel );

    if (om_msg & *msg & 1)
    {
        /*
         * Set the size of the object array.
         */
        size = count + me->num_objects;
        
        if (size > om$dimension_of (varray = me->object) )
        {
            om_msg = om$vla_set_dimension ( varray = me->object, 
                                            size = size + 25 );
        }

        if (om_msg & 1)
        {
            /*
             * Add the new objects to the object array.
             */
            om_msg = gr$gsget_objects ( msg = msg,
                                        array = &me->object[me->num_objects],
                                        size = count * sizeof (struct GRobj_env),
                                        count = &count,
                                        p_chanselect = &me->located_chansel );
               
            /*
             * If something failed set the array to it's old size.
             */                         
            if (!(om_msg & 1))
            {
                om$vla_set_dimension ( varray = me->object, 
                                       size = me->num_objects );
            }
            else
            {
                me->num_objects = size;
            }
        }
    }

    if (!(om_msg & *msg & 1) ) *msg = MSFAIL;
    
    return (OM_S_SUCCESS);
}

action true (IGRint * msg; IGRint query)
{
    IGRint      om_msg = OM_S_SUCCESS;
    IGRint      num;
    struct GRactive_symbol_def asdh;
    IGRchar     path[DI_PATH_MAX];
    GRobjid     objid;
    OMuword     osnum;
        
    *msg = MSFAIL;
        
    switch (query)
    {
        case CO_ARE_PARTS:
            num = 0;
            om_msg = co$part_get_parts ( msg = msg,
                                         mod_env = &me->ModuleInfo,
                                         num = &num );

            *msg = (!(om_msg & *msg & 1)) ? MSFAIL : (num) ? TRUE   : FALSE;

            break;
    
        case CO_ACTIVE_CELL:
            om_msg = gr$symget_active_symbol ( msg = msg, 
                                               act_symbol_def = &asdh );

            *msg = (!(om_msg & *msg & 1)) ? FALSE : TRUE;
            break;

        case CO_IS_PARTS_LIST:
            
            di$give_pathname (osnum = me->ModuleInfo.md_id.osnum, 
                              pathname = path );

            /* BLOCKS  */
            /* di$strcat (to = path, from = "partslist"); */
            di$strcat (to = path, from = "blocks:partslist");

            *msg = ( di$index ( dirname = path,
                                index = 0,
                                p_objid = &objid,
                                p_osnum = &osnum ) == DIR_S_SUCCESS );

            break;
            
    }
                
    return (OM_S_SUCCESS);
}


action dynamics
{
    IGRint              om_msg = OM_S_SUCCESS, action;
    struct GRactive_symbol_def asdh;
    struct GRevent    * events[2];
    IGRdouble           points[12];
    struct IGRpolyline  polyline;
    struct EX_button    vector_pt1, vector_pt2, from_point;
    struct GRid       * gr_id;
        
    *sts = MSSUCC;
    
    switch (dynamics)
    {
        case CO_part_cell:

            /*
             * Get the active symbol definition.
             */
            om_msg = gr$symget_active_symbol ( msg = sts,
                                               act_symbol_def = &asdh );

            if (om_msg & *sts & 1)
            {
                DYsdinit ( sts, 
                           &me->Attr[0].Scale, 
                           &me->Attr[0].Angle, 
                           &asdh );
            }
            
            break;
    
        case CO_parts_list_block:
    
            events[0] = &me->events[0];    
            events[1] = &me->events[1];

            DYrbblock (events, &me->Attr[0].dpb_Display);

            break;
            
        case CO_parts_list_divider:
        case CO_parts_list_title:

            action = 1;

            polyline.points = points;
            polyline.num_points = 4;

            om_msg = om$send ( msg = message GRlinear.GRgetpolyline(
			                (long *) sts,
                                       &me->ModuleInfo.md_env.matrix_type,
                                        me->ModuleInfo.md_env.matrix,
                                       &action,
                                       &polyline ),
                      targetid = me->object[0].obj_id.objid,
                      targetos = me->object[0].obj_id.osnum );
                      
            if (om_msg & *sts & 1)
            {
                me->events[2].event.button.x = points[0];
                me->events[2].event.button.y = points[1];
                me->events[2].event.button.z = points[2];

                /* construct me->object[me->num_objects - 1] */
                om_msg = om$send ( 
			  msg = message COpart.construct (sts, dynamics, 1),
                          targetid = my_id );

                
                if (om_msg & *sts & 1)
                {
                    vector_pt1 = me->events[0].event.button;
                    vector_pt2 = vector_pt1;
                    
                    vector_pt1.x = points[0];
                    vector_pt1.y = points[1];
                    vector_pt1.z = points[2];

                    vector_pt2.x = points[9];
                    vector_pt2.y = points[10];
                    vector_pt2.z = points[11];

                    from_point = vector_pt1;
                    
                    gr_id = &me->object[me->num_objects - 1].obj_id;
                    
                    me->event1.event.button = vector_pt1;
                    me->event1.located_object[0].located_obj = *gr_id;
                    me->event1.located_object[0].module_info = me->ModuleInfo;

                    DYmv_along_vec ( sts,
                                     my_id,
                                     OM_Gw_current_OS,
                                     &vector_pt1,
                                     &vector_pt2,
                                     &from_point,
                                     &me->ModuleInfo,
                                     NULL,
                                     &me->event1 );        

                    om$send ( msg = message COpart.stack_delete (sts, 1, 0),
                              targetid = my_id );
                }
            }
            break;
    }

    if (!(om_msg & *sts & 1)) *sts = MSFAIL;
    
    return (OM_S_SUCCESS);
}

action place_part (IGRint * msg; struct GRevent * origin)
{
    IGRint om_msg = OM_S_SUCCESS;
    
    me->num_parts = om$dimension_of ( varray = me->parts );
    
    om_msg = co$part_place ( 
		    msg     = msg,
                    mod_env = &me->ModuleInfo,
                    origin  = origin,
                    scale   = &me->Attr[0].Scale,
                    angle   = &me->Attr[0].Angle,
                    level   = &me->Attr[0].Level,
                    part    = me->parts,
                    num     = &me->num_parts );

    /*
     * If there wasn't enough space for all the parts in the cell, allocate
     * some more and recall the function.    
     */
    if (!(om_msg & *msg & 1) && 
         (me->num_parts > om$dimension_of (varray = me->parts )))
    {
        om_msg = om$vla_set_dimension ( varray = me->parts, 
                                        size = me->num_parts );

        if (om_msg & 1)
        {
            om_msg = co$part_place ( 
		        msg     = msg,
                        mod_env = &me->ModuleInfo,
                        origin  = origin,
                        scale   = &me->Attr[0].Scale,
                        angle   = &me->Attr[0].Angle,
                        level   = &me->Attr[0].Level,
                        part    = me->parts,
                        num     = &me->num_parts );
        }
    }
    /*
     * needed for set_attribute (Shelley H. 12/23/91)
     */
    if (me->num_parts > 0)  me->part = me->parts[me->num_parts-1];

    if (!(om_msg & 1)) *msg = MSFAIL;

    return (OM_S_SUCCESS);
}

action get_attribute_prompt (IGRlong * sts)
{
    IGRchar * number[MAX_ATTR];
    
    *sts = om$is_objid_valid (objid = me->parts[me->parts_processed].objid,
                             osnum = me->parts[me->parts_processed].osnum );
                                     
    if (*sts & 1)
    {
        if (me->num_parts > 1)
        {
            co$part_get_attr ( msg = sts,
                               part = &me->parts[me->parts_processed],
                               attr = NUMBER_NAME,
                               value = number );

            if (*sts & 1)
            {
                sprintf(me->prompt, 
                        "Enter %s for %s [%s]", 
                        &me->attr[me->num_processed][0], 
                        number,
                        &me->value[me->num_processed][0]);
            }
        }
        else
        {
            sprintf(me->prompt, 
                    "Enter %s [%s]", 
                    &me->attr[me->num_processed][0], 
                    &me->value[me->num_processed][0]);
        }
    }

    if (*sts & 1) *sts = MSSUCC;
}

action set_attribute (IGRchar * new_value)
{
    IGRint om_msg = OM_S_SUCCESS, msg = MSSUCC;
    
    if(new_value[0]=='\0')        
            om_msg = co$part_put_attr ( 
		       msg = &msg,
                       mod_env = &me->ModuleInfo,
                       part = &me->part,
                       attr = &me->attr[me->num_processed][0],
                       value = &me->value[me->num_processed][0],
                       type = me->type[me->num_processed] );

    else   
           om_msg = co$part_put_attr ( 
		       msg = &msg,
                       mod_env = &me->ModuleInfo,
                       part = &me->part,
                       attr = &me->attr[me->num_processed][0],
                       value = new_value,
                       type = me->type[me->num_processed] );
                       
    if (om_msg & msg & 1)
    {
        strcpy(&me->value[me->num_processed][0], new_value);
    }
    
    return (OM_S_SUCCESS);
}

action highlight_part ()
{
    long            msg;
    enum GRdpmode   mode = GRhd;
 
    om$send ( msg = message GRgraphics.GRdisplay( &msg,
                                                  &me->ModuleInfo.md_env.matrix_type,
                                                  me->ModuleInfo.md_env.matrix,
                                                  &mode,
                                                  &me->ModuleInfo.md_id ),
              targetid = me->parts[me->parts_processed].objid,
              targetos = me->parts[me->parts_processed].osnum );
}
    
action get_attributes (IGRint * msg; IGRint statics; IGRint dynamics)
{
    IGRint om_msg = OM_S_SUCCESS;
    IGRint i, num;
    struct GRid * part_p;

    part_p = (me->mytype == CO_place_part) ? 
             &me->parts[me->parts_processed] : &me->part;

    *msg = MSSUCC;

    om_msg = co$part_get_all_attr ( msg = msg,
                                    mod_env = &me->ModuleInfo,
                                    part = part_p,
                                    num = &num );

    if (om_msg & *msg & 1)
    {
        if (statics || dynamics)
        {
            if (num > om$dimension_of(varray = me->attr))
            {
                om$vla_set_dimension(varray = me->attr,  size = num + 5);
                om$vla_set_dimension(varray = me->value, size = num + 5);
                om$vla_set_dimension(varray = me->type,  size = num + 5);
            }
            
            me->num_attrs = 0;
            
            for (i=0; i<num; ++i)
            {
                me->attr[me->num_attrs][0] = '\0';
                om_msg = co$part_get_attr ( msg = msg,
                                            mod_env = &me->ModuleInfo,
                                            part = part_p,
                                            attr = &me->attr[me->num_attrs][0],
                                            index = &i,
                                            value = &me->value[me->num_attrs][0],
                                            type = &me->type[me->num_attrs] );

                if ((statics && (me->type[me->num_attrs] & GR_COMMON_ATTR)) ||
                    (dynamics && !(me->type[me->num_attrs] & GR_COMMON_ATTR)))
                {
                    me->num_attrs++;
                }
            }
        }
    }
    
    if (!(om_msg & *msg & 1)) *msg = MSFAIL;
    
    return (OM_S_SUCCESS);
}

action get_all_parts (IGRint * msg)
{
    int    om_msg = OM_S_SUCCESS,
           ii,
 	   jj,
           mflag1 = FALSE,  /* malloc flag */
           mflag2 = FALSE,  /* malloc flag */
           nbr_catalogs,
	   cat_count,
           start_object = 0;

    char   pwd[DI_PATH_MAX],
           part_dir[DI_PATH_MAX],
           cat_buffer[MAX_CATALOGS*DI_PATH_MAX],
	  *pm_cat_buffer,
	  *p_catalogs[MAX_CATALOGS],
         **p_p_catalogs;

    struct GRid  *grid_p,
		  grid[MAX_GRIDS];

    me->num_objects = 0;
    
    /* save pwd */
    di$pwd( dirname = pwd );

    /* get all catalogs */
    GRpart_get_default_parts_dir( &me->ModuleInfo,
				  part_dir );
    di$cd ( dirname = part_dir );
    di$ls( ptr = &nbr_catalogs );

    if ( nbr_catalogs > MAX_CATALOGS )
    {
      /* need to malloc here */
      mflag1 = TRUE;
      
      pm_cat_buffer = om$malloc (size = nbr_catalogs * DI_PATH_MAX); 
      p_p_catalogs  = (char **) om$malloc (size = nbr_catalogs * sizeof(char *) ); 

      for (ii=0; ii < nbr_catalogs; ii++) 
         p_p_catalogs[ii] = &pm_cat_buffer[ii * DI_PATH_MAX];
    }
    else
    {
       /* set up catalog adresses */
       for (ii=0; ii < nbr_catalogs; ii++) 
          p_catalogs[ii] = &cat_buffer[ii * DI_PATH_MAX];
       p_p_catalogs = p_catalogs;
    }

    di$ls( ptr = &nbr_catalogs,
           lines = &p_p_catalogs );

    /* split off the catalog names from full directory names */
    for (ii=0; ii<nbr_catalogs; ii++)
    {
      char basename[DI_PATH_MAX];
      di$split( pathname = p_p_catalogs[ii], 
		name = basename );
      strcpy( p_p_catalogs[ii], basename );
    }

    for (ii=0; ii<nbr_catalogs; ii++)
    {
       /* find number of parts in this catalog */
       om_msg = co$part_get_parts ( msg = msg,
                                    mod_env = &me->ModuleInfo,
                                    catalog = p_p_catalogs[ii],
                                    num =  &cat_count );
       me->num_objects += cat_count;

       if (me->num_objects > om$dimension_of (varray = me->object))
       {
          om$vla_set_dimension ( varray = me->object,
                                 size = me->num_objects + 5);
       }
 
       /* 
        * get the parts in this catalog 
        */
       if (cat_count > MAX_GRIDS)
       {
         mflag2 = TRUE;
         grid_p = (struct GRid *) om$malloc (size = cat_count * sizeof(struct GRid));
       }
       else
       {
         grid_p = grid;
       }
       om_msg = co$part_get_parts ( 
			    msg = msg,
                            mod_env = &me->ModuleInfo,
	                    catalog = p_p_catalogs[ii],
                            part = grid_p,
                            num = &cat_count );
       /*
        * load instance data 
        */
       if (om_msg & *msg & 1)
       {
          for (jj=0; jj<cat_count; jj++ )
          {
             me->object[jj+start_object].obj_id = grid_p[jj];
             me->object[jj+start_object].mod_env = me->ModuleInfo;
          }
       }
       start_object += cat_count;
       if ( mflag2 )
       {
          om$dealloc (ptr = grid_p );
          mflag2 = FALSE;
       }
    }

    if (!(om_msg & *msg & 1)) *msg = MSFAIL;

    /* restore pwd */
    di$cd ( dirname = pwd );
    
    return (OM_S_SUCCESS);
}

/* list_parts:
 *   for command == CO_add_to_parts_list 
 *      succedes by successfully adding all parts in the me->object
 *      to the partslist.
 */
action list_parts (IGRint * msg; IGRint command)
{
    IGRint om_msg = OM_S_SUCCESS;
    
    if (command == CO_list_parts)
    {
        if (me->num_objects > 0)
        {
            om_msg = co$part_list ( 
			   msg = msg,
                           mod_env = &me->ModuleInfo,
                           file = me->fp,
                           object = &me->object[0],
                           num_objects = me->num_objects );
        
            if (om_msg & *msg & 1)
            {
                fflush( (FILE *) me->fp );
            }
        }
    }
    else if (command == CO_add_to_parts_list)
    {
        om_msg = co$part_add_to_partslist ( 
				   msg = msg,
                                   mod_env = &me->ModuleInfo,
                                   object = &me->object[0],
                                   num_objects = me->num_objects );

        if (om_msg & *msg & 1) *msg = MSSUCC;
    }
    else *msg = MSFAIL;
    
    if (!(om_msg & 1)) *msg = MSFAIL;
    
    return (OM_S_SUCCESS);
}

action update_partslist (IGRint * msg)
{
    IGRint om_msg = OM_S_SUCCESS;
    
    om_msg = co$part_update_partslist ( msg = msg,
                                        mod_env = &me->ModuleInfo );

    if (om_msg & *msg & 1) *msg = MSSUCC;
    else *msg = MSFAIL;
    
    return (OM_S_SUCCESS);
}                               

action store_format (IGRint * msg; IGRchar * format)
{
    IGRchar * p, * q, * r;
    IGRchar * left, * center, * right, justs[80];

    *msg = MSSUCC;

    ex$message (msgnumb = GR_I_Justs, buff = justs);

    if ((left = strtok (justs," ")) && 
        (center = strtok (NULL," "))&&
        (right = strtok (NULL," ")))
    {
        while (*format == ' ') ++format;

        if (q = strchr (format, ','))
        {
            /* Make sure vla is large enough to hold this info */
            int size = om$dimension_of(varray = me->format);
            if (me->num_processed >= size)
                om$vla_set_dimension(varray = me->format, size = size + 5);
 
            p = q + 1;
            *q = '\0';
            strcpy (me->format[me->num_processed].attr, format);
    
            while (*p == ' ') ++p;   
            if (q = strchr (r = p, ','))
            {
		char *p_just;

                p = q + 1;
                *q = '\0';
                strcpy (me->format[me->num_processed].title, r);

                /* Stip leading spaces */
                while (*p == ' ') ++p;   

                /* 
		 * Convert the justification to lower case 
		 * 2/3/92: because we cannot control the message text in all
		 *         languages, we convert the message AND the user's
		 *         input to tower case.  SRH.
		 */
                r = p;
                while (*r != '\0') { *r = tolower(*r); r++; }

		p_just = left;
                while (*p_just != '\0') {*p_just = tolower(*p_just); p_just++;}

		p_just = center;
                while (*p_just!='\0'){*p_just=tolower(*p_just); p_just++;}

		p_just = right;
                while (*p_just!='\0'){*p_just=tolower(*p_just); p_just++;}

                if ( !strcmp (p, left ) )
                   strcpy (me->format[me->num_processed].justification,"left");
                else if ( !strcmp (p, center ) )
                  strcpy(me->format[me->num_processed].justification,"center");
                else if ( !strcmp (p, right ) )
                  strcpy (me->format[me->num_processed].justification,"right");
                else *msg = MSFAIL;
            }
            else 
            {
                strcpy (me->format[me->num_processed].title, r);
                strcpy (me->format[me->num_processed].justification,"left");
            }
        }
        else 
        {
            strcpy (me->format[me->num_processed].attr, format);
            strcpy (me->format[me->num_processed].title, format);
            strcpy (me->format[me->num_processed].justification, "left");
        }
    }   
    
    return (OM_S_SUCCESS);
}    


action do_Global_attr_message()
{
  IGRchar   buff1[10], buff2[10];

  strcpy(buff1, "%ITEM");
  strcpy(buff2, "%COUNT");

  ex$message(msgnumb = GR_I_GlobalAtt, type = "%s%s", var = `buff1,buff2`);

}

action update_form_attributes_by_label (IGRint          label;
                                        IGRint        * msg;
                                        IGRint          number_label;
                                        IGRint          name_label;
                                        IGRint          static_label;
                                        IGRint          dynamic_label )
                                                                    extern
action update_form_by_label (IGRint label; IGRint * msg)            extern 
action reset_form_by_label (IGRint label; IGRint * msg)             extern
action query_form_by_label (IGRint label; IGRint * msg)             extern
action form_notification                                            extern
action modify_part (IGRint label; IGRint * msg)                     extern
action modify_part_attributes (IGRint label; IGRint * msg)          extern
action update_active_row (IGRint label; IGRint * msg)               extern
action display_form_by_label                                        extern
action construct (IGRint * msg; IGRint object; IGRint dynamics)     extern
action stack_delete (IGRint * msg; IGRint number; IGRint erase)     extern
