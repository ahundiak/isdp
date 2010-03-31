
/******************************************************************************
 * Name:     EMplistfunk.I                                                    *
 *                                                                            *
 * Description: Create/Modify parts list functions                            *
 *                                                                            *
 * Remarks:                                                                   *
 *                                                                            *
 * History:                                                                   *
 *           creation     Krishnakumar     12/12/93                           *
 *           modified for                                                     *
 *           drawing views     dkk         05/24/94                           *
 *****************************************************************************/

class implementation ECprtlist;
#include <math.h>
#include <string.h>
#include "igetypedef.h"
#include "igrtypedef.h"
#include "tools.h"
#include "FI.h"
#include <exdef.h>
#include <ex.h>
#include <exmacros.h>
#include <igr.h>
#include <gr.h>
#include <igrdp.h>
#include <grdpbdef.h>
#include <grdpbmacros.h>
#include "godef.h"
#include <go.h>
#include "griodef.h"
#include "grio.h"
#include "emserr.h"
#include "bserr.h"
#include "msdef.h"
#include "EMSerrordef.h"
#include "EMStypedef.h"
#include "grmacros.h"
#include "grwireframe.h"

#include "DIdef.h"
#include "DItypedef.h"
#include "DIglob.h"
#include "DIprims.h"
#include "DImacros.h"
#include "dpdef.h"
#include "dp.h"
#include "dpmacros.h"
#include "nddef.h"
#include "AS_status.h"
#include "expression.h"
#include "expmacros.h"
#include "ACattrib.h"
#include "ACrg_collect.h"
#include <cotxmacros.h>

#include "assemdef.h"
#include "assem.h"
#include "assemmacros.h"

#ifdef DEBUG
#define verbose(x) x
#else
#define verbose(x)
#endif

from EMdescribe import EMget_notify, EMset_active, EMget_behavior, EMget_memb ;
from GRgraphics import GRdisplay, GRdelete;
from ACrg_collect import ACcreate, AClist_attribute, ACadd_list_attribute;
from ACdiowner  import ACadd_attribute_by_type;
from Super_rfmgr import GRget_channel_objects;
from Super_rfmgr import GRget_channel_count;
from GRreffile  import GRgetenvironment;

extern OMuword OPP_ACrg_collect_class_id;
extern OMuword OPP_GRdvattach_class_id;

extern char    *ecvt();


IGRint EMpart_create_partslist ( msg, 
                                 mod_env,
                                 partslist,
                                 cols,
                                 attrname,
                                 title,
                                 numcolchars,
                                 justification,
                                 paramvals,
                                 crnr_flg,
                                 windowgrid,
                                 plcmnt_pt,
                                 viewname,
                                 asci_flg,
                                 filename )

    IGRlong         * msg;
    struct GRmd_env * mod_env;
    struct GRid     * partslist;
    IGRint            cols;
    IGRchar        ** attrname;
    IGRchar        ** title;	
    IGRint          * numcolchars;
    IGRint          * justification;	
    IGRint            crnr_flg;
    LISTPARAMS      * paramvals;
    struct     GRid * windowgrid;
    IGRdouble       * plcmnt_pt;
    IGRchar         * viewname;
    IGRint            asci_flg;
    IGRchar         * filename;
    {
        IGRint  om_msg = OM_S_SUCCESS, mode;
        struct GRid *prts_list = NULL, gg_id, description_id, oldgrp_id ;
        struct GRid blkid;
        struct GRmd_env env_info;
        IGRdouble *colwidths = NULL, rowhght, totwidth;
        IGRchar pathname[DI_PATH_MAX];
        struct var_list     var_list[2];
        IGRint              which_error;

        IGRint    i, k, num = 0;
        EMattr    *attr = NULL;
        IGRchar **val_strs = NULL;
        IGRint  * quantity = NULL;
        OM_S_CHANSELECT to_comps;
        IGRmatrix       vmat, view_mat;
                
        /*
         * If the module info was not supplied get the current module.
         */
        if (!mod_env)
        {
            gr$get_module_env (buffer = &env_info);
            mod_env = &env_info;
        }

        /*
         * Check if the partslist is existing. If yes, obtain the block grid from the gr_grp,
         * and put the gr_group in background color.
         */
        if( partslist->objid != NULL_OBJID )
        {
            om_msg = om$send ( msg = message EMdescribe.EMget_notify ( msg,
                                                            &oldgrp_id),
                                senderid = NULL_OBJID,
                                targetid = partslist->objid,
                                targetos = partslist->osnum );
            if( !( om_msg & *msg & 1 ))
            {
                verbose(printf("failed to get the described objects' grid\n"));
                goto quit;
            }
            mode = GRbe;
            om_msg = om$send(msg = message GRgraphics.GRdisplay(msg, 
					                        &mod_env->md_env.matrix_type, 
                        					mod_env->md_env.matrix, 
			        		                (enum GRdpmode * )(&mode),
			        		                &mod_env->md_id), 
                                senderid = NULL_OBJID,
                                targetid = oldgrp_id.objid,
                                targetos = oldgrp_id.osnum );
            /*
             * Get the blockid from the 0th index of the graphic group.
             */
            om$make_chanselect( p_chanselect = &to_comps,
                                channame = "GRcmpowner.to_components");

	    om$get_objid_at_index(objid = oldgrp_id.objid,
				    osnum = oldgrp_id.osnum,
				    p_chanselect = &to_comps,
				    index = 0,
				    objidaddr = &blkid.objid,
				    osnumaddr = &blkid.osnum);
            /*
             * Obtain the viewmatrix from the view name 
             */
            var_list[0].var             = VIEW_ROTATION;
            var_list[0].var_ptr         = (IGRchar *)vmat;
            var_list[0].num_bytes       = sizeof(IGRdouble) * 16;
            var_list[0].bytes_returned  = (long *)&which_error;
                        
            var_list[1].var             = END_PARAM;
                        
            om_msg = dp$inq_set_gragad ( msg = msg,
                                         osnum = mod_env->md_id.osnum,
                                         gragad_name = viewname,
                                         which_error = &which_error,
                                         var_list = var_list );
        }
        else
        {
            blkid.objid = NULL_OBJID;

            /*
             * Obtain the view matrix for the given window
             */           
            var_list[0].var             = VIEW_ROTATION;
            var_list[0].var_ptr         = (IGRchar *)vmat;
            var_list[0].num_bytes       = sizeof(IGRdouble) * 16;
            var_list[0].bytes_returned  = (long *)&which_error;
                        
            var_list[1].var             = END_PARAM;
                        
            om_msg = dp$inq_set_gragad ( msg = msg,
                                         osnum = windowgrid->osnum,
                                         gragad_objid = windowgrid->objid,
                                         which_error = &which_error,
                                         var_list = var_list );
         }
	BStrans_mat( 4, 4, vmat, view_mat, &om_msg );
        /*
         * Call the function which calculates the grid dimensions 
         */
        colwidths = ( IGRdouble * ) malloc( cols * sizeof( IGRdouble ));
        EMget_colm_row_size( paramvals, cols, numcolchars, colwidths, &rowhght );
        totwidth = 0.0;
        for( i = 0; i < cols; i++ )
            totwidth += colwidths[i];
        /*
         * Get the list of parts to be include in partslist and their attr vals.
         */
        EMget_parts_for_prtlist( msg, mod_env, &prts_list, &quantity, &num );

        /*
         * Get the attributes' values from each part.
         */
        val_strs = ( IGRchar ** )malloc( cols * num * sizeof( IGRchar *));

	EMget_attrs_for_prtlist(paramvals, attrname, cols, prts_list, quantity,
                                                         num, val_strs);
        /*
         * Generate the graphics for the partslist.
         * Note: titles are always "center" justified.
         */
        om_msg = EMplace_graphic_grid( msg,
			               totwidth,
			               rowhght,
			               cols,
			               colwidths,
                                       title,
                                       val_strs,
                                       justification,
                                       numcolchars,
			               num,
			               plcmnt_pt,
			               view_mat,
       			               crnr_flg,
			               &blkid, 
			               paramvals,
			               &gg_id);
          
        if( om_msg & 1 )
        {
            /*
             * Delete the old group, if present, which deletes the old partslist directory as well.
             */
            if( oldgrp_id.objid != NULL_OBJID )
            {
                om_msg = om$send ( msg = message GRgraphics.GRdelete( msg, 
                                   			            mod_env ),
                                    senderid = NULL_OBJID,
                                    targetid = oldgrp_id.objid,
                                    targetos = oldgrp_id.osnum );
            }
        }
        /*
         * Create the "EMdescribe" class of partslist in :<file>:PartsList: directory. Add the
         * number of columns(cols), and then for each column add attrname, title, colwidth,
         * justification. Then add the 11 list parameters like text font, text height etc...
         * to a parameters box in the partslist directory.
         * Add the graphic group to the describe object.
         */

        di$give_pathname (  osnum = mod_env->md_id.osnum,
                            pathname = pathname );

	om_msg = asm$add_feature_description (msg = msg,
                                    directory = pathname,
                                    name = "PartsList",
                                    active = TRUE,
                                    feature_name = "partslist_gr",
                                    feature_id = &gg_id,
                                    num_attributes = 0,
                                    attributes = NULL,
                                    description_id = &description_id );

        if( !(om_msg & *msg & 1 ))
        {
            verbose(printf("Add_describe failed\n"));
            goto quit;
        }

        attr = ( EMattr * ) malloc( (cols * 4 + 2) * sizeof( EMattr ));

        attr[0].info.type = EM_ATTRIBUTE;
        strcpy(attr[0].info.name, "NoCols");
	strcpy(attr[0].info.desc,"NumberofColumns");
	attr[0].value.type = EM_INTEGER;
	sprintf(attr[0].value.syntax, "%d", cols);

        attr[1].info.type = EM_ATTRIBUTE;
        strcpy(attr[1].info.name, "viewname");
	strcpy(attr[1].info.desc,"ViewName");
	attr[1].value.type = EM_STRING;
	strcpy(attr[1].value.syntax, viewname);

        for( k = 2, i = 0; i < cols; k+=4, i ++ )
        {
	    attr[k].info.type = EM_ATTRIBUTE;	
	    sprintf(attr[k].info.name, "attr%d", i);
	    strcpy(attr[k].info.desc,"AttrName");
	    attr[k].value.type = EM_STRING;
	    strcpy(attr[k].value.syntax, attrname[i]);

	    attr[k+1].info.type = EM_ATTRIBUTE;	
	    sprintf(attr[k+1].info.name, "title%d", i);
	    strcpy(attr[k+1].info.desc,"AttrTitle");
	    attr[k+1].value.type = EM_STRING;
	    strcpy(attr[k+1].value.syntax, title[i]);

	    attr[k+2].info.type = EM_ATTRIBUTE;	
	    sprintf(attr[k+2].info.name, "nchar%d", i);
	    strcpy(attr[k+2].info.desc,"NumChars");
	    attr[k+2].value.type = EM_INTEGER;
	    sprintf(attr[k+2].value.syntax,"%d",numcolchars[i]);

	    attr[k+3].info.type = EM_ATTRIBUTE;	
	    sprintf(attr[k+3].info.name, "just%d", i);
	    strcpy(attr[k+3].info.desc,"Justify");
	    attr[k+3].value.type = EM_INTEGER;
	    sprintf(attr[k+3].value.syntax,"%d",justification[i]);
        }

        for( i = 0; i <= 4*cols+1; i++ )
        {
            om_msg = asm$add_attribute( msg = msg,
                               id = &description_id,
                               attribute = &attr[i] );
            if( !(om_msg & *msg & 1 ))
                verbose(printf("add attr %d failed\n", i ));
        }
        								    
        /*
         * create a static collection of all parameter values in the partslist directory.
         */
        EMcreate_params_box( msg, mod_env, paramvals );

        om_msg = om$send (msg = message EMdescribe.EMset_active (msg, FALSE),
                                    senderid = NULL_OBJID,
                                    targetid = description_id.objid,
                                    targetos = description_id.osnum);
        if( !(om_msg & *msg & 1 ))
        {
            verbose(printf(" set_active failed 2\n"));
            goto quit;
        }

        if( asci_flg )
            EMcreate_plist_file( msg, 
				 filename, 
                                 title,
				 val_strs,
                                 numcolchars,
                                 justification,
				 cols,
				 num );
    quit:        
        if( attr )
            free( attr );
	if( colwidths )
	    free( colwidths );
        for( i = 0; i < num; i++ )
            if( val_strs[i] )
                free( val_strs[i] );
        if( val_strs )
            free( val_strs );            
        if( prts_list )
            free(prts_list);
        if( quantity )
            free(quantity);

        return( om_msg );
    }

/* Currently this function is not being used  - 21/12/93 */
IGRint EMpart_update_partslist ( msg, 
                                 mod_env,
                                 partslist )  
    IGRlong         * msg;
    struct GRmd_env * mod_env;
    struct GRid     * partslist;
    {
	struct GRmd_env env_info;

        *msg = MSSUCC;
	if( !mod_env )
	{
	    gr$get_module_env( buffer = &env_info );
            mod_env = &env_info;
        }
        if( partslist->objid == NULL_OBJID )
            goto quit;

    quit:
        return( OM_S_SUCCESS ); 
    }      


IGRint EMget_colm_row_size( params, numcols, numcolchars, colwidth, rowht )
    LISTPARAMS * params;
    IGRint     * numcolchars;
    IGRint       numcols;
    IGRdouble  * colwidth;
    IGRdouble  * rowht;
    {
        IGRint  i;
        IGRdouble width_per_char, txt_wdth;
        
        /*
         * From the num chars/col, the charwidth and chargap calculate each colwidth.
         */
	txt_wdth = params->txt_hght * params->txt_aspect ;
        width_per_char = txt_wdth + params->char_gap * txt_wdth / 2.;
        for( i = 0; i < numcols; i++ )
            colwidth[i] = numcolchars[i] * width_per_char;          

        /*
         * From the line spacing and text height calculate the total height
         */
        *rowht = (params->txt_hght + params->line_gap * params->txt_hght);
        
        return( 1 );
    }   

IGRint EMget_parts_for_prtlist( msg, mod_env, prts_list, quantity, num )
    IGRlong *msg;
    struct GRmd_env * mod_env;
    struct GRid    ** prts_list;
    IGRint         ** quantity;
    IGRint          * num;
    {
        IGRint om_msg = OM_S_SUCCESS;
        IGRint cprt_count = 0, lprt_count = 0, i, j, inst_count;
        EMattr attr;
	struct GRid iid, *list = NULL;
	IGRint props;
	IGRchar **itnums = NULL;
        struct GRmd_env *env, loc_env;
                
        *msg = MSSUCC;

        /*
         * Get the drawing view environment, if a drawing view is present
         */
        om_msg = EMGetDviewenvironment( msg, &loc_env );

        if( om_msg & *msg & 1 )
            env = &loc_env;  /* Drawing view environment */
        else
            env = mod_env;   /* Incoming environment */

	*num = 0;
	om_msg = asm$part_count (msg = msg,
                             	mod_env = env,
                             	type = EM_CACHED_PART,
                             	count = &cprt_count);
        
	if (!(om_msg & *msg & 1))
    	{
            goto quit;
        }

        /* Now, get the local parts count */
	om_msg = asm$part_count (msg = msg,
                             	mod_env = env,
                             	type = EM_LOCAL_PART,
                             	count = &lprt_count);
        
	if (!(om_msg & *msg & 1))
    	{
            goto quit;
        }

        if( cprt_count + lprt_count == 0 ) /* No parts in the current environment */
        {
            *prts_list = NULL;
            *num = 0;
            goto quit;
        }
        list = (struct GRid *)malloc((cprt_count+lprt_count) * sizeof( struct GRid ));
        *quantity = ( IGRint * )malloc((cprt_count+lprt_count) * sizeof ( int ));
        
        for ( i = 0; i < cprt_count; ++i )
        {
            (*quantity)[i] = 0;
            om_msg = asm$get_part (msg = msg,
                                   mod_env = env,
                                   type = EM_CACHED_PART,
                                   index = i,
                                   part_id = &list[i]);
            /*
             * Get the instance count and instances of each part and eliminate those that are
             * background. Get the itemno and quantity attributes.
             */                                   
            if( om_msg & 1 )
            {
              	om_msg = asm$instance_count( msg = msg,
              				     part_id = &list[i],
					     count = &inst_count );
		for( j = 0; j < inst_count; j ++ )
		{
		    om_msg = asm$get_instance( msg = msg,
		                                part_id = &list[i],
		                                index = j,
		                                instance_id = &iid );

                    om_msg = om$send( msg = message EMdescribe.EMget_behavior ( msg, &props ),
                                            targetid = iid.objid,
                                            targetos = iid.osnum,
                                            senderid = NULL_OBJID );

                    if( !(props & EM_BACKGROUND) )      
                    {
                        (*quantity)[i]++;
                    }
                }
            }
        }
        
        for ( ; i < (cprt_count+lprt_count); ++i )
        {
            (*quantity)[i] = 1;

/*            om_msg = asm$get_part (msg = msg,
                                   mod_env = env,
                                   type = EM_LOCAL_PART,
                                   index = (i-cprt_count),
                                   part_id = &list[i]);

            if(!( om_msg & *msg & 1))
            {
                verbose(printf("failed to get local part at index %d\n",i-cprt_count));
                continue;
            }

            om_msg = asm$get_attribute( msg = msg,
                                        name = "quantity",
                                        id = &list[i],
                                        attribute = &attr );
            if( om_msg & *msg & 1 )
                EMrem_syntax_lhs(attr.value.syntax,(*quantity)[i]);
*/
        }
        /*
         * Get the itemno attribute for each part and then sort the parts list according to the
         * itemno.
         */
        itnums = (IGRchar **)malloc( (cprt_count+lprt_count) * sizeof (IGRchar *));
        for( i = 0; i < (cprt_count+lprt_count); i++ )
        {
            om_msg = asm$get_attribute( msg = msg,
                                        name = "itemno",
                                        id = &list[i],
                                        attribute = &attr );
            if( om_msg & *msg & 1 )
            {
                itnums[i] = (IGRchar *)malloc( strlen(attr.value.syntax) + 1 );
                strcpy( itnums[i], attr.value.syntax );
            }                                          
            else
            {
                itnums[i] = (IGRchar *)malloc(2);
                itnums[i][0] = '\0';                
                verbose(printf("Failed to get itemno for part %d(%d) at %d\n",list[i].objid,
                                                                list[i].osnum,i ));
            }          
        }
        *prts_list = list;
        *num = cprt_count + lprt_count;
        
        /* KLUDGE:
         * Sort the itemno list alphanumerically, simultaneously reordering the prts_list and
         * quantity arrays.
         */
quit:              
        for( i = 0; i < *num; i++ )
            if( itnums[i] )
                free( itnums[i] );
        if( itnums )
            free( itnums );
        return( om_msg );              
    }


IGRint EMget_attrs_for_prtlist( paramvals, attrname, nattr, prts, qty, nprts, values )
LISTPARAMS   * paramvals;
struct GRid * prts;
IGRint nattr, nprts, * qty;
IGRchar ** attrname, ** values;
{
IGRint i, j, k, om_msg = OM_S_SUCCESS;
EMattr tmpattr;
IGRlong msg;

    for( i = 0, k = 0; i < nprts; i++ )
    {
        for( j = 0; j < nattr; j++ )
        {
	    if( !strcmp( attrname[j], "quantity" ))
	    {
                values[k] = (IGRchar *)malloc(25);
	        sprintf( values[k++], "%d", qty[i]);
                continue;
	    }			
            om_msg = asm$get_attribute( msg = &msg,
                                        id = &prts[i],
                                        name = attrname[j],
                                        attribute = &tmpattr );
            if( om_msg & msg & 1 )
            {
                /*
                 * Found the attribute, copy its value into the val_strs
                 * Take the number format into account 
                 */
	        if( tmpattr.value.type == EM_STRING )
                {
                    values[k] = (IGRchar *)malloc( strlen( tmpattr.value.syntax ) + 1);
                    strcpy( values[k++], tmpattr.value.syntax );
                }
                else
                {
                    /* consider the leading and trailing zeros flags and
                     * the delimiter type, if it is a decimal number.
                     */
                    values[k] = (IGRchar *)malloc( 80 );
		    EMformat_number( tmpattr.value.data.d, paramvals, values[k++] );
                }
            }
            else
            {
                /*
                 * Attribute not found on this part.
                 */
	        verbose(printf("Attrib <%s> Not found in <%d> part\n",attrname[j],i));
                values[k] = (IGRchar *)malloc(5);
                values[k++][0] = '\0';
            }
        }
    }

    return( om_msg );
}


IGRint EMcreate_params_box( msg, env, params )
    IGRlong *msg;
    struct GRmd_env *env;
    LISTPARAMS *params;
    {
        int sts = OM_S_SUCCESS;
        struct GRid rg_collect_grid;
        struct ACrg_coll list_att[15];
    
        *msg = MSSUCC;
	rg_collect_grid.osnum = env->md_id.osnum;
        sts = om$construct ( classid   = OPP_ACrg_collect_class_id,
        		        p_objid   = &rg_collect_grid.objid,
	    			osnum = rg_collect_grid.osnum );

        if( !( sts & 1 ))
        {
            verbose(printf("failed to construct parameters collection\n"));
            goto quit;
        }

        sts = om$send( msg	 = message ACrg_collect.ACcreate
					( msg, "params_box"),
			senderid = NULL_OBJID,
			targetid = rg_collect_grid.objid,
			targetos = rg_collect_grid.osnum );

        if( !( sts & *msg & 1 ))
        {
            verbose(printf("failed to create parameters collection\n"));
            goto quit;
        }			
        strcpy( list_att[0].name, "text_font" );
        list_att[0].desc.type = AC_ATTRIB_TEXT;
        strcpy( list_att[0].desc.value.att_txt, params->txt_font);

        strcpy( list_att[1].name, "text_height" );
        list_att[1].desc.type = AC_ATTRIB_DOUBLE;
        list_att[1].desc.value.att_exp = params->txt_hght;

        strcpy( list_att[2].name, "text_aspect" );
        list_att[2].desc.type = AC_ATTRIB_DOUBLE;
        list_att[2].desc.value.att_exp = params->txt_aspect;

        strcpy( list_att[3].name, "text_weight" );
        list_att[3].desc.type = AC_ATTRIB_DOUBLE;
        list_att[3].desc.value.att_exp = params->txt_wght;

        strcpy( list_att[4].name, "char_spacing" );
        list_att[4].desc.type = AC_ATTRIB_DOUBLE;
        list_att[4].desc.value.att_exp = params->char_gap;

        strcpy( list_att[5].name, "line_spacing" );
        list_att[5].desc.type = AC_ATTRIB_DOUBLE;
        list_att[5].desc.value.att_exp = params->line_gap;

        strcpy( list_att[6].name, "bline_weight" );
        list_att[6].desc.type = AC_ATTRIB_DOUBLE;
        list_att[6].desc.value.att_exp = params->blin_wght;

        strcpy( list_att[7].name, "bline_style" );
        list_att[7].desc.type = AC_ATTRIB_DOUBLE;
        list_att[7].desc.value.att_exp = params->blin_styl;

        strcpy( list_att[8].name, "border_color" );
        list_att[8].desc.type = AC_ATTRIB_DOUBLE;
        list_att[8].desc.value.att_exp = params->border_col;

        strcpy( list_att[9].name, "dline_weight" );
        list_att[9].desc.type = AC_ATTRIB_DOUBLE;
        list_att[9].desc.value.att_exp = params->dlin_wght;

        strcpy( list_att[10].name, "dline_style" );
        list_att[10].desc.type = AC_ATTRIB_DOUBLE;
        list_att[10].desc.value.att_exp = params->dlin_styl;

        strcpy( list_att[11].name, "divider_color" );
        list_att[11].desc.type = AC_ATTRIB_DOUBLE;
        list_att[11].desc.value.att_exp = params->divider_col;

        strcpy( list_att[12].name, "leading_zeros" );
        list_att[12].desc.type = AC_ATTRIB_DOUBLE;
        list_att[12].desc.value.att_exp = params->leading_z;

        strcpy( list_att[13].name, "trailing_zeros" );
        list_att[13].desc.type = AC_ATTRIB_DOUBLE;
        list_att[13].desc.value.att_exp = params->triling_z;

        strcpy( list_att[14].name, "delimiter" );
        list_att[14].desc.type = AC_ATTRIB_TEXT;
        sprintf( list_att[14].desc.value.att_txt,"%c", params->delimiter);

        sts = om$send( msg = message ACrg_collect.ACadd_list_attribute( 
                                                                    msg, 15, 
						                    list_att ),
                        senderid = NULL_OBJID,
                        targetid = rg_collect_grid.objid,
                        targetos = rg_collect_grid.osnum );

	if( !( sts & *msg & 1 ))
	    verbose(printf("add_list failed\n"));
            
    quit:			
        return( sts );			
    }

IGRint EMget_plist_colm_info( msg, desc_id, numcols, colfrmt, params, view )
    IGRlong *msg;
    IGRint  *numcols;
    struct GRid *desc_id;
    IGRchar     *view;
    COLMFORMAT **colfrmt;
    LISTPARAMS *params;
    {
        int om_msg = OM_S_SUCCESS, nbattr, i;
        EMattr  attr;
        EMmemb  memb;
        struct ACrg_coll list_attr[15];
        IGRchar attrname[50];

        
        *msg = MSSUCC;
        /*
         * In the describe directory, the first attribute gives the number of columns,
         * followed by the column definition and then the collection containing the parameters.
         */
        om_msg = asm$get_attribute ( msg = msg,
				    name = "NoCols",
                                    id   = desc_id,
                                    attribute = &attr );

        if( !strcmp( attr.info.name, "NoCols" ))   /* Verify it IS no of cols */
            *numcols = (IGRint) attr.value.data.d;
	else
	{
	    verbose(printf("Error in partslist storage NoCols\n"));
            goto quit;
        }

        om_msg = asm$get_attribute ( msg = msg,
				    name = "viewname",
                                    id   = desc_id,
                                    attribute = &attr );

        strcpy( view, attr.value.syntax );
        
        *colfrmt = ( COLMFORMAT * )malloc( *numcols * sizeof ( COLMFORMAT ));
        for( i = 0; i < *numcols; i++ )
        {
            sprintf( attrname, "attr%d", i );
            om_msg = asm$get_attribute ( msg = msg,
                                        name = attrname,
                                        id   = desc_id,
                                        attribute = &attr );
            strcpy( (*colfrmt)[i].attr, attr.value.data.s );     /* Attribute Name */

            sprintf( attrname, "title%d", i );
            om_msg = asm$get_attribute ( msg = msg,
                                        name = attrname,
                                        id   = desc_id,
                                        attribute = &attr );
            strcpy( (*colfrmt)[i].title, attr.value.data.s );    /* Title */

            sprintf( attrname, "nchar%d", i );
            om_msg = asm$get_attribute ( msg = msg,
                                        name = attrname,
                                        id   = desc_id,
                                        attribute = &attr );
	    (*colfrmt)[i].numchar = (IGRint)attr.value.data.d;

            sprintf( attrname, "just%d", i );
            om_msg = asm$get_attribute ( msg = msg,
                                        name = attrname,
                                        id   = desc_id,
                                        attribute = &attr );
	    (*colfrmt)[i].justify = (IGRint)attr.value.data.d;
        }            
        /*
         * Now get the parameters from the box by name.
         */
        om_msg = om$send ( msg = message EMdescribe.EMget_memb( msg,
                                                                "params_box",
								0, 0,
                                                                &memb ),
                                    senderid = NULL_OBJID,
                                    targetid = desc_id->objid,
                                    targetos = desc_id->osnum );
        if( !(om_msg & *msg & 1 ))
        {
            verbose(printf("EMget_memb failed\n"));
            goto quit;
        }

	om_msg  = om$send (msg	= message ACrg_collect.AClist_attribute( 
						msg, 15, 
						list_attr, &nbattr),
			targetid = memb.id.objid,
			targetos = memb.id.osnum,
			senderid = NULL_OBJID);

        if( !(om_msg & *msg & 1 ))
        {
            verbose(printf("get params_box failed\n"));
            goto quit;
        }			

        strcpy( params->txt_font, list_attr[0].desc.value.att_txt );
        params->txt_hght = list_attr[1].desc.value.att_exp;
        params->txt_aspect = list_attr[2].desc.value.att_exp;
        params->txt_wght = list_attr[3].desc.value.att_exp;   
        params->char_gap = list_attr[4].desc.value.att_exp;
        params->line_gap = list_attr[5].desc.value.att_exp;
        params->blin_wght = list_attr[6].desc.value.att_exp;
        params->blin_styl = (int)list_attr[7].desc.value.att_exp;
        params->border_col = (int)list_attr[8].desc.value.att_exp;
        params->dlin_wght = list_attr[9].desc.value.att_exp;
        params->dlin_styl = (int)list_attr[10].desc.value.att_exp;
        params->divider_col = (int)list_attr[11].desc.value.att_exp;
        params->leading_z = (int)list_attr[12].desc.value.att_exp;
        params->triling_z = (int)list_attr[13].desc.value.att_exp;
        sscanf( list_attr[14].desc.value.att_txt, "%c", &params->delimiter );

    quit:
        return( om_msg );
    }

IGRint EMplace_graphic_grid( IGRlong       *msg,
			       IGRdouble    width,
			       IGRdouble    rheight,
			       IGRlong      num_cols,
			       IGRdouble   *col_arr,
                               IGRchar    **titles,        /* size = num_cols */
                               IGRchar    **txt_str,       /* size = num_cols * num_rows */
                               IGRint      *justify,       /* justification type */
                               IGRint	   *numcolmchars,  /* number of chars/column */
			       IGRint       num_rows,      /* without the title row */
			       IGRpoint     origin,
			       IGRmatrix    view_matrix,   /* if NULL, axes xtracted from curve_grid */
       			       IGRint       flag,	   /* origin at top or bottom right */		
			       struct GRid *curve_grid,    /* outer curve in the gr_grp */
			       LISTPARAMS  *params,
			       struct GRid *graphic_grid)
    {
        IGRint i,k,j;
	IGRshort len;
        IGRlong stat_om,msg_loc;
        IGRvector x_axis,y_axis;
        IGRdouble lst_pts[15], txt_origin[3];
        struct GRid  outer_grid,*grid_arr = NULL;
        struct GRmd_env env;
        struct IGRdisplay     act_disp, new_disp;
	struct GRdpb_text_symb text_symb;
        IGRdouble width_per_char, act_wid;

        stat_om = OM_S_SUCCESS;
        msg_loc = *msg = MSSUCC;

        /* Kludge for RFA + Assembly - Always have Center Justification for
         * all text.
         */
        for (i = 0; i < num_cols; i++)
        {
           justify[i] = CENT_JUSTIFY;
        }

        gr$get_module_env( buffer = &env );

        if( curve_grid->objid == NULL_OBJID )
        {   
            x_axis[0]=-1.0;
            x_axis[1]=0.0;
            x_axis[2]=0.0;   

            y_axis[0]=0.0;
            y_axis[1]=1.0;
            y_axis[2]=0.0;   
    
            if(!flag)      /* Top Right corner */
                y_axis[1] = -1.0;

            ASMtran(x_axis,view_matrix);
            ASMtran(y_axis,view_matrix);
        } 
        else 
        { /* xtract from the curv_grid ( outer grid of existing gr. grp ) */

            IGRboolean bs_stat;
            IGRlong rc=BSSUCC;
            struct IGRbsp_curve *curv_geom=NULL;
       
            gr$get_curve_geometry(msg=&msg_loc,
                             md_env = &env,
                             object_id = curve_grid,
                             curve_struct = &curv_geom);
            if( !( msg_loc & 1 ) )
            {
                *msg = MSFAIL;
                goto wrapup;
            }                             
       
            if(curv_geom->num_poles < 5 ) 
            {
                *msg = MSFAIL;
                gr$free_curve(curve_struct=curv_geom);          
                goto wrapup;
            }
       
            for( k = 0; k < 3; k++)
            {
                origin[k] = curv_geom->poles[k];
                x_axis[k] = curv_geom ->poles[k+3] - origin[k];
                y_axis[k] = curv_geom->poles[k+6] - curv_geom->poles[k+3];
            }
       
            bs_stat = BSnorvec(&rc,x_axis);
            bs_stat = BSnorvec(&rc,y_axis);

            gr$free_curve(curve_struct=curv_geom);
        } /* if view_mat */
   
        for( k = 0; k < 3; k++)
        {
            lst_pts[k]     = origin[k];
            lst_pts[k+3]   = origin[k] + width*x_axis[k];
            lst_pts[k+6]   = lst_pts[k+3] + rheight*(num_rows+1)*y_axis[k];
            lst_pts[k+9]   = origin[k] + rheight*(num_rows+1)*y_axis[k];
            lst_pts[k+12]  = origin[k];
        }

        /*
         * Save the active line_weight and line_styl
         */
        gr$get_active_display( buffer = &act_disp );
        
        /*
         * Set the active line_wt and line_st to blin_wt and blin_styl.
         */   
        new_disp = act_disp;
        new_disp.style = params->blin_styl;
        new_disp.weight = params->blin_wght;        
        new_disp.color = (unsigned short)params->border_col;
	gr$put_active_display( buffer = &new_disp );
        
        outer_grid.objid = NULL_OBJID;
        outer_grid.osnum = env.md_id.osnum;

        gr$place_linear_object(msg=&msg_loc,
   			  md_env = &env,
   			  num_points=5,
   			  points = lst_pts,
                          object_id = &outer_grid);
/*                          display_flag = 0);*/
                          
        if( !( msg_loc & 1 ) )
        {
            *msg = MSFAIL;
            goto wrapup;
        }                             

        grid_arr = (struct GRid *) malloc( num_cols * sizeof(struct GRid ));
   
        grid_arr[0].objid = outer_grid.objid;   /* outer line is first in the gra. group */
        grid_arr[0].osnum = outer_grid.osnum;

        /*
         * Set the active line_wt and line_st to dlin_wt and dlin_styl.
         */   
        new_disp.style = params->dlin_styl;
        new_disp.weight = params->dlin_wght;        
        new_disp.color = (unsigned short)params->divider_col;
	gr$put_active_display( buffer = &new_disp );

        /*
         * * Place column lines from left to right
         */   
        for( i = 0; i < num_cols-1; i++)
        {
            IGRdouble loc_wid = 0.;

            loc_wid = col_arr[i];
       
            for(k = 0 ; k < i; k++)
                loc_wid = loc_wid + col_arr[k];
       
            for( k = 0 ; k < 3; k++)
            {
                lst_pts[k] = origin[k] + (width - loc_wid)*x_axis[k];
                lst_pts[k+3] = lst_pts[k] + rheight*(num_rows+1)*y_axis[k];
            }
   
            grid_arr[i+1].osnum = env.md_id.osnum;

            gr$place_linear_object(msg=&msg_loc,
   			      md_env = &env,
   			      num_points=2,
   			      points = lst_pts,
                              object_id = &grid_arr[i+1]);
/*                              display_flag = 0);*/
                              
            if( !( msg_loc & 1 ) )
            {
                *msg = MSFAIL;
                goto wrapup;
            }                             
        } /* for each col i */
   
        /*
         * * place row lines 
         */
        /*
         * Reset the active line_wt and line_styl.
         */
        gr$put_active_display( buffer = &act_disp );    

        grid_arr = (struct GRid *)realloc(grid_arr,
 				(num_cols + num_rows)*sizeof( struct GRid));

        for( i = 0 ; i < num_rows; i++ )
        {
            for( k = 0 ; k < 3 ; k++)
            {
                lst_pts[k] = origin[k] + y_axis[k]*(i+1)*rheight;
                lst_pts[k+3] = lst_pts[k] + x_axis[k]*width;
            }
        
           grid_arr[i+num_cols].osnum = env.md_id.osnum;
        
           gr$place_linear_object(msg=&msg_loc,
   			      md_env = &env,
   			      num_points=2,
   			      points = lst_pts,
                              object_id = &grid_arr[i+num_cols]);
/*                             display_flag = 0);*/
            if( !( msg_loc & 1 ) )
            {
                *msg = MSFAIL;
                goto wrapup;
            }                             
        }
        BStrans_mat( 4, 4, view_matrix, view_matrix, &j);
        
        /*
         * Set the active text font, height, aspect, spacing and weight 
	 * KLUDGE: should these values be converted into the design units??
         */
        gr$get_text_symb(msg = msg,
                       buffer = &text_symb );


	if( strcmp( params->txt_font, "default") )
            sscanf( params->txt_font, "%d", &text_symb.Active_font );

        text_symb.Active_width = (params->txt_hght * params->txt_aspect);
        text_symb.Active_height = params->txt_hght;
        text_symb.Active_charspac = params->char_gap;
        text_symb.Active_linespac = params->line_gap;

        /*
         * Create the text for titles and attributes taking the justification into account.
         */
        width_per_char = ( params->txt_hght * params->txt_aspect ) + params->char_gap/2.;    

        grid_arr = (struct GRid *)realloc(grid_arr,
  		   (2*num_cols+num_rows+1+num_cols*num_rows)*sizeof( struct GRid ));

        for( i = 0; i < num_cols; i++ )
        {
            text_symb.Active_just = 7;    	/* CENTER_CENT */

            act_wid = 0.0;
	    for( k = 0; k < i; k ++ )
                act_wid = act_wid + col_arr[k];
	    
            act_wid += col_arr[i]/2.0;

            for( j = 0; j < 3; j++ )
                txt_origin[j] = origin[j] + y_axis[j] * params->txt_hght
                                + x_axis[j] * ( width - act_wid );

	    len = strlen( titles[i] );
            co$place_text ( msg = &msg_loc,
                        text_string = titles[i],
                        text_length = &len,
                        origin = txt_origin,
                        rot_matrix = view_matrix,
                        TextSymb = &text_symb,
                        buffer = &grid_arr[num_cols+num_rows+i]);
        }            

        for( j = 0; j < num_rows; j++ )
        {
            for( i = 0; i < num_cols; i++ )
            {
	        for( k = 0; k < 3; k++ )
    	            txt_origin[k] = origin[k] 
                                    + y_axis[k] * params->txt_hght
			            + x_axis[k] * width
                                    + (j + 1) * rheight * y_axis[k];
                act_wid = 0.0;
		for( k = 0; k < i; k++ )
                    act_wid = act_wid + col_arr[k];

                  /* 2 - LEFT_CENT, 7 - CENTER_CENT, 12 - RIGHT_CENT - (gotxtdef.h)*/
                if( justify[i] == LEFT_JUSTIFY )
                {
    	            text_symb.Active_just = 2;
                    for( k = 0; k < 3; k++ )
                    txt_origin[k] = txt_origin[k]
                                    - x_axis[k] * (act_wid + params->char_gap);
                }
                else if( justify[i] == CENT_JUSTIFY )
                {
                    text_symb.Active_just = 7;    	

                    act_wid += col_arr[i]/2.0;

                    for( k = 0; k < 3; k++ )
                    txt_origin[k] = txt_origin[k]
                                    - x_axis[k] * act_wid;
                }
                else if( justify[i] == RIGHT_JUSTIFY )
                {
    	            text_symb.Active_just = 12;    	

                    for( k = 0; k < 3; k++ )
                    txt_origin[k] = txt_origin[k]
                                    - x_axis[k] * (act_wid+col_arr[i]-params->char_gap);

                }

    	    	len = strlen( txt_str[j*num_cols+i] );
		if( len )
		{
    	            co$place_text ( msg = &msg_loc,
                            text_string = (IGRuchar *)txt_str[j*num_cols+i],
                            text_length = &len,
                            origin = txt_origin,
                            rot_matrix = view_matrix,
                            TextSymb = &text_symb,
                            buffer = &grid_arr[ 2*num_cols+num_rows+j*num_cols+i]);
                }
            }
        }	
    
        gr$create_graphic_group(msg=&msg_loc,
                                object_ids = grid_arr,
                                num_objects = ( 2*num_cols + num_rows + num_cols*num_rows),
                                gg_id = graphic_grid);
        if( !( msg_loc & 1 ) )
        {
            *msg = MSFAIL;
            goto wrapup;
        }                             
   
    wrapup:
      if(grid_arr) free(grid_arr);
  
      return(stat_om);
    }

IGRint ASMtran ( IGRvector  vec,  IGRmatrix  mat )
    {
    IGRvector temp;

       temp[0] = mat[0] * vec[0] + mat[1] * vec[1] + mat[2] * vec[2] + mat[3];
       temp[1] = mat[4] * vec[0] + mat[5] * vec[1] + mat[6] * vec[2] + mat[7];
       temp[2] = mat[8] * vec[0] + mat[9] * vec[1] + mat[10] * vec[2] + mat[11];

       vec[0] = temp[0];
       vec[1] = temp[1];
       vec[2] = temp[2];

       return(1);
    }

IGRint  EMcreate_plist_file(IGRlong *  msg, 
			    IGRchar *  filename, 
                            IGRchar ** title,
			    IGRchar ** val_strs,
                            IGRint  *  numcolchars,
                            IGRint  *  justification,
			    IGRint     cols,
			    IGRint     rows )
    {
    IGRint om_msg = OM_S_SUCCESS, i, j;
    FILE  *fp;

    *msg = MSSUCC;

	if(( fp = fopen( filename, "w" )) == NULL)
        {
            *msg = MSFAIL;
            verbose(printf("Could not open file %s\n", filename ));  
            goto quit;
        }

        for( i = 0; i < cols; i++ )
            fprintf( fp, "%s\t", title[i] );
        fprintf(fp, "\n");

        for( i = 0; i < rows; i++ )
        {
            for( j = 0; j < cols; j++ )
                fprintf( fp, "%s\t", val_strs[i*cols + j] );
            fprintf(fp, "\n");        
        }

        fclose( fp );

    quit:
        return( om_msg );
    }

EMformat_number( IGRdouble number, LISTPARAMS *params, IGRchar *val_str )
{
char *tmpstr, *ptr;
int decpt, sign, len;
    
    sprintf(val_str, "%lf", number );
    len = strlen( val_str );
    tmpstr = ecvt( number, len, &decpt, &sign );

/*printf("s = %s, decpt = %d, sign= %d\n",tmpstr, decpt, sign);*/

    if( sign )
        strcpy( val_str, "-");
    else
        val_str[0] = 0;

    if( !decpt )
    {
        if( params->leading_z )
            strcat( val_str, "0");
    }
    else
        strncat( val_str, tmpstr, decpt );                        

    if( params->delimiter == '.' )
        strcat( val_str, "." );
    else
        strcat( val_str, "," );

    if( params->triling_z )                            
        strcat( val_str, tmpstr+decpt );
    else
    {
        ptr = tmpstr + len - 1;
        while( *ptr == '0' ) ptr--;
	if( ptr == (tmpstr + decpt - 1) )
	    val_str[strlen(val_str)-1] = 0;
	else
            strncat( val_str, tmpstr+decpt, ptr - ( tmpstr+decpt ) + 1);
    }
/*printf( "valstr = :%s:\n", val_str );*/

    return( 1 );
}

IGRint EMGetDviewenvironment( IGRlong *msg, struct GRmd_env *view_env)
{
IGRint sts, i, j;
IGRlong count, out_count;
struct GRmd_env mod_env;
struct GRid     refmgr;
OM_S_OBJID      *objids = NULL;
OMuword         *osnums = NULL;
IGRshort nest;
unsigned long props;
unsigned int  cnt;
OM_S_CHANSELECT         chansel;
OMuword                 classid;
OM_S_OBJECT_LINKAGE   * objects = NULL;
    
    *msg = ASM_S_SUCCESS;
	
    /*
     * Get the current module env
     */
    gr$get_module_env( buffer = &mod_env );

    /*
     * First check if there is a drawing view attached in the master file, 
     * for this, get all the reference file objects in the master file and
     * check if it is a drawing view attachment.
     */
    sts = ex$get_super(mod_id = mod_env.md_id.objid,
                       mod_osnum = mod_env.md_id.osnum,
                       super_name = "Ref Mgr",
                       create = 0,
                       super_id = &refmgr.objid,
                       super_osnum = &refmgr.osnum);
    if (!(sts & 1))
    {
        verbose(printf("Failed to get reference file manager in master space\n"));
        goto quit;
    }
    nest = FALSE;
    props = 0;
    sts = om$send(msg = message Super_rfmgr.GRget_channel_count(msg, &props,
                                                                &nest, &count),
		  senderid = NULL_OBJID,
                  targetid = refmgr.objid,
                  targetos = refmgr.osnum);

    if (!(sts & *msg & 1))
    {
        verbose(printf("Failed to get attachment count in master space\n"));
        goto quit;
    }
    osnums = (OMuword *)malloc(count * sizeof(OMuword));
    objids = (OM_S_OBJID *)malloc(count * sizeof(OM_S_OBJID));

    sts = om$send(msg = message Super_rfmgr.GRget_channel_objects
                  (msg, &props, &nest, &count, 
                   objids, osnums, &out_count),
		  senderid = NULL_OBJID,
                  targetid = refmgr.objid,
                  targetos = refmgr.osnum);

    if (!(sts & *msg & 1) || count != out_count)
    {
        verbose(printf("Failed to get attachment list in master space\n"));
        verbose(printf("count = %d, out_count = %d\n", count, out_count));
        goto quit;
    }
    sts = om$make_chanselect (p_chanselect = &chansel,
                                 channame = "GRconnector.to_owners");
    
    if (!(sts & 1))
    {
       	*msg =  ASM_E_ABORT;
        goto quit;
    }

    for (i = 0; i < count; i++ )
    {
        /*
         * Get the objects on the to_owner's channel
         */
        cnt = 0;
    	sts = om$get_channel_count (objid = objids[i],
                                   osnum = osnums[i],
                                   p_chanselect = &chansel,
                                   count = &cnt);

    	if (!(sts & 1) || (cnt == 0))
    	{
		continue;
    	}

    	objects = (OM_S_OBJECT_LINKAGE *)malloc(cnt * 
						sizeof(OM_S_OBJECT_LINKAGE));
    
	sts = om$get_channel_objects (objid = objids[i],
                                     osnum = osnums[i],
                                     p_chanselect = &chansel,
                                     list = objects,
                                     size = cnt,
                                     count = &cnt);
    	if (!(sts & 1))
    	{
        	*msg = ASM_E_ABORT;
        	goto quit;
    	}
    
    	for (j=0; j<cnt; ++j)
    	{
            sts = om$get_classid (objid = objects[j].S_objid,
                                 osnum = objects[j].osnum,
                                 p_classid = &classid);
        
            if (!(sts & 1))
            {
		verbose(printf("failed to get classid\n"));
                *msg = ASM_E_ABORT;
                goto quit;
            }
            /*
             * Check if it is GRdvattach class object
             */
            if (om$is_ancestry_valid (superclassid = OPP_GRdvattach_class_id,
                                  subclassid = classid) == OM_S_SUCCESS)
            {
                break;
            }
        }
        free( objects );
        if ( j < cnt )
            break;
    }
    if (i < count)   
    {
        /* 
         * Found a drawing view attachment, get the ref file env 
         */
        sts = om$send(msg = message GRreffile.GRgetenvironment(msg,
							&mod_env,
							view_env),
                        senderid = NULL_OBJID,
			targetid = objids[i],
			targetos = osnums[i]);
        if(! (*msg & sts & 1))
	{
            verbose(printf("failed to get dvattach reffile env\n"));
	    goto quit;
        }
        return( 1 );
    }

quit:
    if( objids )
        free( objids );
    if( osnums )
        free( osnums );

    return( 0 );
}
end implementation ECprtlist;
