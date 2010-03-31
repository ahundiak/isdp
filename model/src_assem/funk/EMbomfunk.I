class implementation EMpart;

#include <grimport.h>
#include <OMindex.h>
#include "OMprimitives.h"
#include "OMminimum.h"
#include "OMmacros.h"
#include "OMlimits.h"
#include <DIprims.h>
#include <grownerdef.h>
#include <grerr.h>
#include <gocmacros.h>
#include <msmacros.h>
#include <grmessage.h>
#include <ex.h>
#include <igrdp.h>
#include <igr.h>
#include <dpdef.h>
#include <dp.h>
#include <dpmacros.h>
#include <go.h>
#include <godef.h>
#include <griodef.h>
#include <grio.h>
#include "griomacros.h"
#include <grdpbdef.h>
#include <grdpbmacros.h>
#include <refdef.h>
#include <ref.h>
#include "refmacros.h"
#include <exmacros.h>
#include <FI.h>
#include <FIdyn.h>
#include <nddef.h>
#include <ndmacros.h>
#include "grgsdef.h"
#include "grgsmacros.h"
#include "lcdef.h"
#include "lc.h"
#include "lcmacros.h"
#include "coparadef.h"
#include "coparamac.h"

#include "assemdef.h"
#include "assem.h"
#include "assemconstr.h"
#include "assemmacros.h"

#include "madef.h"

#define BOM_FORM                1
#define BOM_EDIT_FORM           2
#define BOM_SET_DISPLAY_FORM    3
#define BOM_CONSTRAINTS_FORM    4

#define ACCEPT      1
#define RUN         2
#define RESTORE     3
#define EXIT        4
#define CONVERT     5

#define LOCATE      31

#define BOM         12

#define DEPTH       29
#define DEPTH_LABEL 30

#define ACTIVE      19
#define DISPLAY     20  
#define EDIT        21
#define EVENT       22
#define BACKGROUND  23
#define WRITE       24
#define CONSTR	    25
#define HIGHLIGHT   26
#define DELETE      27
#define SETDISPLAY  28

#define MESSAGE     10

#define TEXT        29
#define DIMENSIONS  30
#define CONSTRAINTS 31
#define REFPLANES   32
#define WIREFRAME   33
#define SOLIDSURFS  34

#define PART_ATTR   12
#define INST_ATTR   15
#define ON_LAYERS   25
#define FROM_LAYERS 26
#define TO_LAYERS   27

#define ELEM_ON_TEXT 18
#define ON_LAYER_TEXT 19
#define FROM_LAYER_TEXT 20
#define TO_LAYER_TEXT 24

/* Gadgets on EMMngCnstr form */
#define CONSTR_LIST 12
#define CONSTR_VAL  11
#define DOF_BUTTON  14
#define DEL_BUTTON  17
#define STAR_TXT    21

/* Gadgets for the new form */

#define NEST_LEVEL            12 /* Slider bugger */
#define PART_DISPLAY          13 /* File Part Display Field */
#define GROUP1                14
#define ACTIVATE              15 /* Activate Btn */
#define SAVE                  17 /* Save */
#define DISPLAY_CONSTRAINTS   18 /* Constraints */
#define HILITE                22 /* Highlight Btn */
#define HIDE_SHOW             23 /* Display on/off Btn */
#define PART_LOCATE           24 /* Locate Btn */

/* Externs  for the new form*/

extern int FImcf_get_active_col();
extern int FIg_get_text_length();
extern int FIfld_get_text();
static int Get_text();


extern OMuword OPP_EMpart_class_id;
extern OMuword OPP_EMinstance_class_id;
extern OMuword OPP_GRreffile_class_id;
extern char      *EXgetcwd( char *, int );

from EMinstance import EMget_part;
from EMlocalpart import EMget_layers, EMset_layers;
from GRgraphics import GRdelete, GRdisplay, GRgetprops, GRchgprops;
from GRcontext import GRgetmodule_env;
from GRgrset import GSobject_add;
from GRreffile import GRinquireref, GRrfgetfilename, GRgetosnum;


typedef struct EMbom_pass_info
{
    struct GRmd_env mod_env;
    IGRint          row;
} EMbom_pass_info;

#define Null ((char *)NULL)

#ifdef TRACE
#define trace(x) x
#else
#define trace(x) 
#endif

%safe
static Form          EMbom_form = NULL;
static Form          EMconstr_form = NULL;
static IGRshort      EMbom_mode = BOM_DISPLAY;
static IGRint        EMbom_num_part_attrs = 0;
static EMattr      * EMbom_part_attrs = 0;
static IGRint        EMbom_num_inst_attrs = 0;
static EMattr      * EMbom_inst_attrs = 0;
static ASM_tree    * EMbom_selected_node = NULL;
static IGRshort      EMbom_locate = FALSE;
static EMattr        itemno;
static ASM_tree      *s_node; /* Added by RFA to handle its forms */
%endsafe

extern IGRint        EMbom_display_depth;
extern ASM_tree      *assembly_tree;

extern IGRlong EMbom_display();
extern int     EMbom_notify();
extern void    EMbom_update (IGRint op, 
                             OM_S_OBJID objid, 
                             OMuword osnum,
                             struct GRmd_env * mod_env);


/* Stub function for PDM hook */
#argsused
IGRlong EMGetDbPermissions(EMPartInfo *in_part,
			   IGRlong *in_operation,
			   IGRlong *out_perm)
{
  return(0);
}

void EMbom_reset_tree_state()
{
  ASM_tree *tree_ptr;

  tree_ptr = assembly_tree;

  while(tree_ptr)
   {
     tree_ptr->new_state = tree_ptr->old_state;
     tree_ptr = tree_ptr->next;
   }

  return;
}

IGRlong EMbom_display_entry (ASM_tree        *node, 
                             IGRint            row, 
                             struct GRmd_env * mod_env)
{
    IGRlong     om_msg, msg = ASM_S_SUCCESS;
    struct GRid part_id, * p_id;
    IGRchar     buffer[256], ref_name[DI_PATH_MAX],name[DI_PATH_MAX];
    EMattr      attr;
    
    struct GRinquire_list request[2];
    IGRboolean pass_to_other_spaces = FALSE;
    IGRint ok;
    struct GRid ref_id;
    EMmemb memb;
    
    trace(printf("in EMbom_display_entry\n"));

    if((EMbom_display_depth > 1) && (!(EMbom_mode & BOM_FIRSTLEVEL)))
     {
       if ((node->depth > EMbom_display_depth) ||
           ((EMbom_mode & BOM_FIRSTLEVEL) && 
           (node->part_id.osnum != mod_env->md_id.osnum)))
       {
          om_msg = OM_E_ABORT;
          goto quit;
       }
     }
    else
     {
	if(EMbom_mode & BOM_FIRSTLEVEL) 
         {
	   if(node->part_id.osnum != EX_active_OS_num)
	    {
	      om_msg = OM_E_ABORT;
	      goto quit;
            }
            
            if( node->depth > EMbom_display_depth )
            {
                EMbom_display_depth = node->depth;
            }
	 }
        else
	 {
	    if(node->depth > EMbom_display_depth)
	     {
	       om_msg = OM_E_ABORT;
	       goto quit;
	     }
	 }
     }

    if (node->props & EM_CACHED_PART)
     {
        om_msg = om$send (msg = message EMinstance.EMget_part (&msg, 
                                                               &part_id),
                              senderid = NULL_OBJID,
                              targetid = node->part_id.objid,
                              targetos = node->part_id.osnum);
        
        if (!(om_msg & msg & 1))
        {
            om_msg = OM_E_ABORT;
            goto quit;
        }
        
        p_id = &part_id;
     }
    else
     {
        p_id = &node->part_id;
     }
    
    sprintf (buffer, "%d", node->depth);
    FIfld_set_text (EMbom_form, PART_DISPLAY, row, 0, buffer, FALSE);

    if (node->depth == 0)
    {
      om_msg = asm$get_attribute (msg = &msg,
                                  id = p_id,
                                  name = "number",
                                  attribute = &attr);
        
      sprintf (buffer, 
               "%*s%s", 
               node->depth, 
               "", 
               (om_msg & msg & 1) ? attr.value.data.s : "no number");
    }
    else
    {
      om$send (msg = message EMdescribe.EMget_memb(&msg,
                                                   "reffile",
                                                   EM_GRAPHIC,
                                                   0,
                                                   &memb),
               senderid = NULL_OBJID,
               targetid = node->part_id.objid,
               targetos = node->part_id.osnum);

      if(msg & 1 )
      {
        request[0].var = REFERENCE_NAME;
        request[0].var_ptr = ref_name;
        request[0].num_requested = DI_PATH_MAX;
  
        request[1].var = END_REPORT_REQUEST;
        request[1].var_ptr = NULL;
        request[1].num_requested = 0;
    
        om$send ( msg = message GRreffile.GRinquireref(&msg,
                                                     mod_env,
                                                     request,
                                                     &ok,
                                                     &pass_to_other_spaces,
                                                     NULL ),
                  senderid = NULL_OBJID,
                  targetid = memb.id.objid,
                  targetos = memb.id.osnum );

        di$split ( pathname = request[0].var_ptr,
                  name = name );

        sprintf (buffer, 
                "%*s%s", 
                node->depth, 
                "", 
                name);
      }
    }

    FIfld_set_text (EMbom_form, PART_DISPLAY, row, 1, buffer, FALSE);

    /********** Not necessary now for RFA+Assembly modifications
            
    om_msg = asm$get_attribute (msg = &msg,
                                id = p_id,
                                name = "revision",
                                attribute = &attr);

    FIfld_set_text (EMbom_form, 
                    BOM, 
                    row, 
                    2, 
                    (om_msg & msg & 1) ? 
                    attr.value.data.s : "", 
                    FALSE);

    om_msg = asm$get_attribute (msg = &msg,
                                id = p_id,
                                name = "description",
                                attribute = &attr);
        
    FIfld_set_text (EMbom_form, 
                    BOM, 
                    row, 
                    3, 
                    (om_msg & msg & 1) ? 
                    attr.value.data.s : "", 
                    FALSE);

    if (EMbom_mode)
    {
      if(node->props & EM_LOCAL_PART)
       {
         if((EMbom_mode == BOM_EVENT) || (EMbom_mode == BOM_WRITE) ||
            (EMbom_mode == BOM_BACKGROUND) ||
            ((EMbom_mode == BOM_ACTIVE) && (node->depth > 1)))
           FIfld_set_text (EMbom_form,
                           BOM,
                           row, 4,
                           " ",
                           FALSE);
         else
           FIfld_set_text (EMbom_form,
                           BOM,
                           row, 4,
                           (EMbom_mode & node->new_state) ?
                           "yes" : "no",
                           FALSE);
       }
      else
       if((node->props & EM_FILE_PART) && 
	  ((EMbom_mode == BOM_BACKGROUND) || (EMbom_mode == BOM_DELETE) ||
	    (EMbom_mode == BOM_EVENT)))
	{
           FIfld_set_text (EMbom_form,
                           BOM,
                           row, 4,
                           " ",
                           FALSE);
	}
      else
        FIfld_set_text (EMbom_form,
                        BOM,
                        row, 4,
                        (EMbom_mode & node->new_state) ?
                        "yes" : "no",
                        FALSE);
    }
    **************/

 quit:
    
    return om_msg;
}
        
IGRlong EMbom_display ()
{
    IGRlong         om_msg = OM_S_SUCCESS;
    IGRint           row, count;
    IGRdouble       value;
    struct GRmd_env mod_env;
    ASM_tree        *tree_ptr;
    
    trace(printf("in EMbom_display\n"));
    FIg_get_value (EMbom_form, NEST_LEVEL, &value);
    EMbom_display_depth = (IGRint)value;

    gr$get_module_env(buffer = &mod_env);

    FIfld_get_num_rows (EMbom_form, PART_DISPLAY, &count);

    tree_ptr = assembly_tree;
    row = 0;

    while(tree_ptr)
     {
        om_msg = EMbom_display_entry (tree_ptr, row, &mod_env);
        
        if (om_msg & 1)
        {
            row++;
        }
	tree_ptr = tree_ptr->next;
     }
    
    if (count > row)
    {
        FIfld_delete_rows (EMbom_form, PART_DISPLAY, row, count - row);
    }

    return OM_S_SUCCESS;
}

IGRlong EMbom_display_properties ()
{
    IGRint          row;
    struct GRmd_env mod_env;
    ASM_tree        *tree_ptr;
    
    trace(printf("in EMbom_display_properties\n"));
    gr$get_module_env(buffer = &mod_env);
    tree_ptr = assembly_tree;
    row = 0;

    if (EMbom_mode)
    {
      while(tree_ptr) 
        {
            if ((tree_ptr->depth <= EMbom_display_depth) &&
                !((EMbom_mode & BOM_FIRSTLEVEL) &&
                  (tree_ptr->part_id.osnum != mod_env.md_id.osnum)))
            {
                if(tree_ptr->props & EM_LOCAL_PART)
                 {
                   if((EMbom_mode == BOM_EVENT) || (EMbom_mode == BOM_WRITE)||
                     (EMbom_mode == BOM_BACKGROUND))
                    {
                      FIfld_set_text (EMbom_form, 
                                      BOM, 
                                      row++, 4, 
                                      " ",
                                      FALSE);
                    }
                   else
                    FIfld_set_text (EMbom_form, 
                                    BOM, 
                                    row++, 4, 
                                    (EMbom_mode & tree_ptr->old_state) ?
                                    "yes" : "no",
                                    FALSE);
                  
                 }
                else
		 if((tree_ptr->props & EM_FILE_PART) &&
		    ((EMbom_mode == BOM_BACKGROUND)||(EMbom_mode==BOM_DELETE)||
		      (EMbom_mode == BOM_EVENT)))
                  {
                     FIfld_set_text (EMbom_form, 
                                      BOM, 
                                      row++, 4, 
                                      " ",
                                      FALSE);
                  }
                 else
                  {
                    FIfld_set_text (EMbom_form, 
                                    BOM, 
                                    row++, 4, 
                                    (EMbom_mode & tree_ptr->old_state) ?
                                    "yes" : "no",
                                    FALSE);
                  }
            }
            tree_ptr = tree_ptr->next;
        }
    }

    return OM_S_SUCCESS;
}


int EMshow_mode()
{
  if(EMbom_form != NULL)
   switch(EMbom_mode)
      {
	 case BOM_ACTIVE :
	      FIg_set_state_on(EMbom_form,ACTIVE);
	      break;

	 case BOM_DISPLAY :
	      FIg_set_state_on(EMbom_form,DISPLAY);
	      break;

	 case BOM_EDIT :
	      FIg_set_state_on(EMbom_form,EDIT);
	      break;

	 case BOM_EVENT :
	      FIg_set_state_on(EMbom_form,EVENT);
	      break;

	 case BOM_WRITE :
	      FIg_set_state_on(EMbom_form,WRITE);
	      break;

	 case BOM_CONSTRAINT :
	      FIg_set_state_on(EMbom_form,CONSTR);
	      break;

	 case BOM_HIGHLIGHT :
	      FIg_set_state_on(EMbom_form,HIGHLIGHT);
	      break;

	 case BOM_BACKGROUND :
	      FIg_set_state_on(EMbom_form,BACKGROUND);
	      break;

	 case BOM_DELETE :
	      FIg_set_state_on(EMbom_form,DELETE);
	      break;

	 case BOM_SETDISPLAY :
	      FIg_set_state_on(EMbom_form,SETDISPLAY);
	      break;
     }

   return(1);
}

void EMbom_update (IGRint op, 
                   OM_S_OBJID objid, 
                   OMuword osnum, 
                   struct GRmd_env * mod_env)
{
    IGRlong     om_msg, msg;
    IGRuint     props;
    IGRint      row;
    IGRdouble   value;
    ASM_tree    *p_node;
    struct GRid part_id;
    struct GRmd_env md_env;

    trace(printf("object: %d--%d\n",objid, osnum));
    if(!assembly_tree)
     {
	return;
     }
    gr$get_module_env (buffer = &md_env);
    
    mod_env = NULL; /* Quiet compiler */

    trace(printf("in EMbom_update\n"));
    p_node = NULL;
    part_id.objid = objid;
    part_id.osnum = osnum;
    
    switch (op)
    {
    case BOM_ADD_ENTRY:
	 trace(printf("add: %d--%d\n",part_id.objid, part_id.osnum));
	 om_msg = EMadd_to_tree(&msg, &part_id);
	 if(om_msg & msg & 1)
	  {
	    if(EMbom_form)
	     {
	       EMbom_display();
	     
               value = (IGRdouble)EMbom_max_depth();
               FIg_set_high_value (EMbom_form, NEST_LEVEL, value);
             }
          }
         break;
    case BOM_REM_ENTRY:
	 trace(printf("delete: %d--%d\n",part_id.objid, part_id.osnum));
	 om_msg = EMdelete_from_tree(&msg, &part_id);
	 if(om_msg & msg & 1)
	  {
	    if(EMbom_form)
	     {
	        EMbom_display();
                value = (IGRdouble)EMbom_max_depth();
                FIg_set_high_value (EMbom_form, NEST_LEVEL, value);
             }
	  }
         break;
    case BOM_MOD_LAYERS:
	 break;

    case BOM_MOD_ENTRY:
	 EMbom_find_node_by_id(&part_id, &p_node); 
	 if(p_node && EMbom_form)
	  {
	    EMbom_find_row_by_node(p_node, &row);

	    EMbom_display_entry(p_node,row,&md_env);
	  }
         break;

    case BOM_MOD_PROPS:
         om_msg = om$send (msg = message EMdescribe.EMget_props (&msg,
                                                                &props),
                          senderid = NULL_OBJID,
                          targetid = part_id.objid,
                          targetos = part_id.osnum);
        
         if (!(om_msg & msg & 1))
          {
            goto quit;
          }

        
         EMbom_find_node_by_id (&part_id, &p_node);
        
	 if(!p_node)
	  goto quit;

         if (props != p_node->props)
         {
            p_node->props = props;
            p_node->old_state =
              ((EM_IS_DESCRIBE_ACTIVE(props) && 
                (osnum == md_env.md_id.osnum)) ?
               BOM_ACTIVE : 0) |
                 (EM_IS_GRAPHIC_DISPLAYED(props) ?
                  BOM_DISPLAY : 0) |
                    (EM_IS_BACKGROUND(props) ?
                     BOM_BACKGROUND : 0) |
                       (EM_IS_READONLY(props) ?
                        0 : BOM_WRITE);
        }
        break;

    case BOM_MOD_ATTRS:
        break;
    }

 quit:
    
    return;
}

IGRint EMbom_update_constraints()
{
    if( EMbom_form == NULL )
        return 0;

    if( EMbom_selected_node && EMbom_mode == BOM_CONSTRAINT)
    {
        EMbom_show_constraints( EMbom_selected_node );
    }
    return 1;
}

IGRint EMbom_show_constraints ( ASM_tree *p_node )
{
IGRint           om_msg, count, inc, i, type, flag;
IGRlong          msg;
IGRchar          tmpstr[128], inst_name[128];
IGRdouble        offset;
struct  GRid     att_prt, cnstrid;
Form             sub_fp;
void             EMCnstr_notify();
    
    if( EMconstr_form == NULL )
    {
        if (FIf_new (BOM_CONSTRAINTS_FORM,
    	          "EMMngCnstr", 
    	          EMCnstr_notify,
    	          &EMconstr_form) != FI_SUCCESS)
        {
            FIg_set_text( EMbom_form, MESSAGE, "Error setting form EMMngCnstr");
            return 0;
    	}
	flag = 1;
    }
    else
    {
        FIg_reset( EMconstr_form, CONSTR_LIST );
        flag = 0;
    }

    sub_fp = EMconstr_form;

    /* Check the type of part */
    if( p_node->props & EM_FILE_PART )
    {
        FIg_set_text(EMbom_form, MESSAGE, "Select Part Occurance/Local Part");
	FIf_delete(EMconstr_form);
	EMconstr_form = NULL;
        return 0;
    } 

    count = 0;
    om_msg = asm$get_constraints_count( msg = &msg,
                                        part_id = &p_node->part_id,
                                        in_out = 2,
                                        count = &count );
    if( (om_msg & msg & 1) && count )
    {
        for( i = 0; i < count; i++ )
        {
            om_msg = asm$get_constraint( msg = &msg,
                                         part_id = &p_node->part_id,
                                         index = i,
                                         in_out = &inc,
                                         type = &type,
                                         cnstrid = &cnstrid );
            if( om_msg & msg & 1 )
            {
       	        if( type == GROUND )
                {
                    FIfld_set_text( sub_fp, CONSTR_LIST, i, 0, "GROUND", 0);
                    continue;
                }
    	        else if( type == ALIGN )
                    FIfld_set_text( sub_fp, CONSTR_LIST, i, 0, "ALIGN",0);
        	else if( type == MATE )
	        {
                IGRuint attr;

	            /*
                     * Check if the mate is special align
                     */
                    attr = 0;
                    asm$get_constraint_attrs( msg = &msg,
                                            id = &cnstrid,
                                            attrs = &attr );

                    if( attr & EM_MATE_ALIGNED )
                        FIfld_set_text(sub_fp, CONSTR_LIST, i, 0,"ALIGN",0);
                    else
                        FIfld_set_text(sub_fp, CONSTR_LIST, i, 0, "MATE",0);
	        }
                
                if( inc == 0 ) /* cnstrid is ROOT */
                {
                    om_msg = asm$get_paired_parts( msg = &msg,
                                                   cnstrid = &cnstrid,
                                                   p1_id = &att_prt );
		    inst_name[0] =  '\0';
                }
                else if( inc == 1 )/* cnstrid is CHILD  */
                {
                    om_msg = asm$get_paired_parts( msg = &msg,
                                                   cnstrid = &cnstrid,
                                                   p2_id = &att_prt );
                    strcpy( inst_name, "*");
		    FIg_display( sub_fp, STAR_TXT ); 
                }
		if( om_msg & msg & 1 )
		{
                    om_msg = EMget_instance_name( &msg, &att_prt, tmpstr );
                    strcat( inst_name, tmpstr );
                }
                else
                FIfld_set_text( sub_fp, MESSAGE, 0, 0, "getpart failed", 0);
                FIfld_set_text( sub_fp, CONSTR_LIST, i, 1, inst_name, 0 );
            }
	    else
                FIfld_set_text( sub_fp, MESSAGE, 0, 0, "getconstr failed", 0);
        }
	FIfld_set_select( sub_fp, CONSTR_LIST, i-1, 0, TRUE );
	if( type == MATE )
	{
	    FIg_enable( sub_fp, CONSTR_VAL );
	    /*
    	     * Offset for the last constraint is displayed
	     */
            om_msg = asm$get_cnstr_exp_info( msg = &msg,
                                         cnstrid = &cnstrid,
                                         exp_value = &offset);
            if( om_msg & msg & 1 )
            {
                sprintf( tmpstr, "%.2f", offset );
                FIfld_set_text( sub_fp, CONSTR_VAL, 0, 0, tmpstr, 0 );
            }
        }
        else
        {
            FIg_set_text( sub_fp, CONSTR_VAL, "" );
    	    FIg_disable( sub_fp, CONSTR_VAL );
	}
    }
    else if( !count )
    {
	if( flag )
        FIg_set_text( EMbom_form, MESSAGE,"No Constraints");
	else
        FIg_set_text( EMbom_form, MESSAGE,"All Constraints deleted");
	FIf_delete( sub_fp );
	EMconstr_form = NULL;
        return 0;
    }
    else
    {
        FIg_set_text( EMbom_form, MESSAGE, "Failed to get constraints");
	FIf_delete( sub_fp );
	EMconstr_form = NULL;
        return 0;
    }

    FIf_display( sub_fp );

    return (om_msg);
}

IGRint EMbom_sleep()
{
  IGRint displayed = FALSE;

  if(EMbom_form != NULL)
   {
     FIf_is_displayed(EMbom_form,&displayed);
     if(displayed)
      FIf_erase(EMbom_form);
   }
   return(OM_S_SUCCESS);
}

IGRint EMbom_wakeup()
{
  IGRint displayed = FALSE;

  if(EMbom_form != NULL)
   {
     FIf_is_displayed(EMbom_form, &displayed);
     if(!displayed)
      FIf_display(EMbom_form);

     FIg_reset(EMbom_form,PART_DISPLAY);
     EMbom_display();
   }

  return(OM_S_SUCCESS);
}

IGRint EMbom_nested_select(row,
                           property)
IGRint *row;
char   *property;
{
 IGRint i,count;
 IGRint node_depth;
 ASM_tree *p_node ;

 trace(printf("in EMbom_nested_select\n"));

 EMbom_find_node_by_row(*row,&p_node);
 if(!p_node)
  return(1);

 node_depth = p_node->depth; 

 FIfld_get_num_rows (EMbom_form, PART_DISPLAY, &count);

 for(i= *row + 1; i < count;i++)
  {
     EMbom_find_node_by_row(i,&p_node);
     if(!p_node)
      break;

      if(p_node->depth > node_depth)
       {
         if(p_node->props & EM_LOCAL_PART)
          {
            if((EMbom_mode != BOM_BACKGROUND) &&
	       (EMbom_mode != BOM_WRITE) &&
	       (EMbom_mode != BOM_EVENT))
             {
               if (!strcmp(property, "yes"))
                {
                  FIfld_set_text(EMbom_form, BOM, i, 4, "yes", FALSE);
                  p_node->new_state |= EMbom_mode;
                }
               else
                {
                  FIfld_set_text(EMbom_form, BOM, i, 4, "no", FALSE);
                  p_node->new_state &= ~EMbom_mode;
                }
             }
          }
        else
         {
           if (!strcmp(property, "yes"))
            {
               FIfld_set_text(EMbom_form, BOM, i, 4, "yes", FALSE);
               p_node->new_state |= EMbom_mode;
            }
           else
            {
               FIfld_set_text(EMbom_form, BOM, i, 4, "no", FALSE);
               p_node->new_state &= ~EMbom_mode;
            }
          }

       }
      else
       {
	 break;
       }

  }

  return(1);

}

void EMsetbom_locate()
{
  EMbom_locate = TRUE;
}

void EMresetbom_locate()
{
  EMbom_locate = FALSE;
}

IGRshort EMisbom_locate()
{
  return(EMbom_locate);
}

IGRlong EMshow_bom_edit(IGRlong *msg,
			ASM_tree *p_node)
{
    IGRlong       om_msg = OM_S_SUCCESS;
    IGRint        i,j;
    IGRchar       buffer[256];
    Form          sub_form_ptr;
    struct GRid   part_id;
    struct GRmd_env mod_env;
    IGRlong       layers[32], on_layers[32];
    IGRlong       low_layer, hi_layer;
    IGRchar       layer_string[256];
    
       trace(printf("in EMshow_bom_edit\n"));
       gr$get_module_env (buffer = &mod_env);



       if (FIf_new (BOM_EDIT_FORM,
                    "EMEdOcc", 
                    EMbom_notify,
                    &sub_form_ptr) == FI_SUCCESS)
	 {
	   if ((p_node->props & EM_FILE_PART) ||
		(p_node->props & EM_LOCAL_PART))
	    {
		part_id = p_node->part_id;
	    }
	   else
	    {
		asm$get_instance_part (msg = msg,
				       instance_id = &p_node->part_id,
				       part_id = &part_id);
	    }
				       
	    om_msg = asm$attribute_count (msg = msg,
					  type = EM_PART_ATTR,
					  id = &part_id,
					  count = &EMbom_num_part_attrs);
		
	    EMbom_part_attrs = (EMattr*)om$malloc(size = EMbom_num_part_attrs *
							 sizeof(EMattr));
	    
	    for (i=0; i<EMbom_num_part_attrs; ++i)
	    {
		om_msg = asm$get_attribute (msg = msg,
					    type = EM_PART_ATTR,
					    id = &part_id,
					    index = i,
					    attribute = &EMbom_part_attrs[i]);

		FIfld_set_text (sub_form_ptr, 
				PART_ATTR,
				i, 0,
				EMbom_part_attrs[i].info.name,
				FALSE);
		
		FIfld_set_text (sub_form_ptr, 
				PART_ATTR,
				i, 1,
				EMbom_part_attrs[i].info.desc,
				FALSE);
		if(EMbom_part_attrs[i].value.type == EM_STRING)
		 {
		   sprintf(buffer,"\"%s\"",EMbom_part_attrs[i].value.syntax);
		 }
		else
		 {
		   EMrem_syntax_lhs(EMbom_part_attrs[i].value.syntax,buffer);
		 }
		FIfld_set_text (sub_form_ptr, 
				PART_ATTR,
				i, 2,
				buffer,
				FALSE);
	    }


	    om_msg = asm$get_attribute (msg = msg,
				        type = EM_COMMON_ATTR,
					id = &part_id,
					name = "itemno",
					attribute = &itemno);
	    FIfld_set_text (sub_form_ptr, 
			    INST_ATTR,
			    0, 0,
			    itemno.info.name,
			    FALSE);
		
	    FIfld_set_text (sub_form_ptr, 
			    INST_ATTR,
			    0, 1,
			    itemno.info.desc,
			    FALSE);
	    if(itemno.value.type == EM_STRING)
	     {
		sprintf(buffer,"\"%s\"",itemno.value.syntax);
	     }
	    else
	     {
	        EMrem_syntax_lhs(itemno.value.syntax,buffer);
	     }
		    
	    FIfld_set_text (sub_form_ptr, 
			    INST_ATTR,
			    0, 2,
			    buffer, 
			    FALSE);

	    om_msg = asm$attribute_count (msg = msg,
					  type = EM_INSTANCE_ATTR,
					  id = &p_node->part_id,
					  count = &EMbom_num_inst_attrs);

	    EMbom_inst_attrs = (EMattr*)om$malloc(size = EMbom_num_inst_attrs *
							 sizeof(EMattr));
	    for (j=0,i=1; j<EMbom_num_inst_attrs; ++i,++j)
	    {
		om_msg = asm$get_attribute (msg = msg,
					    type = EM_INSTANCE_ATTR,
					    id = &p_node->part_id,
					    index = j,
					    attribute = &EMbom_inst_attrs[j]);

		FIfld_set_text (sub_form_ptr, 
				INST_ATTR,
				i, 0,
				EMbom_inst_attrs[j].info.name,
				FALSE);
		
		FIfld_set_text (sub_form_ptr, 
				INST_ATTR,
				i, 1,
				EMbom_inst_attrs[j].info.desc,
				FALSE);
		if(EMbom_inst_attrs[j].value.type == EM_STRING)
		 {
		   sprintf(buffer,"\"%s\"",EMbom_inst_attrs[j].value.syntax);
		 }
		else
		 {
		   EMrem_syntax_lhs(EMbom_inst_attrs[j].value.syntax,buffer);
		 }
		    
		FIfld_set_text (sub_form_ptr, 
				INST_ATTR,
				i, 2,
				buffer, 
				FALSE);
	    }


	    if ((p_node->props & EM_FILE_PART) ||
		(p_node->props & EM_LOCAL_PART))
	     {
	       om_msg = om$send(msg = message EMlocalpart.EMget_layers(
							  msg,
							  layers,
							  NULL,
							  on_layers),
				senderid = NULL_OBJID,
				targetid = p_node->part_id.objid,
				targetos = p_node->part_id.osnum);

	       om_msg = EMconvert_layer_mask_to_string(msg, 
						      &mod_env,
						      on_layers,
						      layer_string);
	       if(om_msg & *msg & 1)
		{
		  FIfld_set_text(sub_form_ptr,
				 ON_LAYERS,
				 0,0,
				 layer_string,
				 NULL);
		}

	       if(p_node->props & EM_LOCAL_PART)
		{
		   low_layer = EMget_first_layer(layers);
		   hi_layer = EMget_last_layer(layers);
		   sprintf(layer_string,"%d",low_layer);

		   FIfld_set_text(sub_form_ptr,
				  FROM_LAYERS,
				  0,0,
				  layer_string,
				  NULL);
		   sprintf(layer_string,"%d",hi_layer);

		   FIfld_set_text(sub_form_ptr,
				  TO_LAYERS,
				  0,0,
				  layer_string,
				  NULL);
		}
	       else
		{
		  FIg_erase(sub_form_ptr,FROM_LAYER_TEXT);
		  FIg_erase(sub_form_ptr, FROM_LAYERS);
		  FIg_erase(sub_form_ptr,TO_LAYER_TEXT);
		  FIg_erase(sub_form_ptr, TO_LAYERS);
		}

	     }
	    else
	     {
	       FIg_erase(sub_form_ptr,ELEM_ON_TEXT);
	       FIg_erase(sub_form_ptr,ON_LAYER_TEXT);
	       FIg_erase(sub_form_ptr, ON_LAYERS);
	       FIg_erase(sub_form_ptr,FROM_LAYER_TEXT);
	       FIg_erase(sub_form_ptr, FROM_LAYERS);
	       FIg_erase(sub_form_ptr,TO_LAYER_TEXT);
	       FIg_erase(sub_form_ptr, TO_LAYERS);
	     }
	    
	    FIg_set_state (sub_form_ptr, 
			   TEXT,
			   EM_IS_TEXT_DISPLAYED(p_node->props));
	    
	    FIg_set_state (sub_form_ptr, 
			   DIMENSIONS,
			   EM_IS_DIMENSION_DISPLAYED(p_node->props));
	    
	    FIg_set_state (sub_form_ptr, 
			   CONSTRAINTS,
			   EM_IS_CONSTRAINT_DISPLAYED(p_node->props));
	    
	    FIg_set_state (sub_form_ptr, 
			   REFPLANES,
			   EM_IS_REFPLANE_DISPLAYED(p_node->props));
	    
	    FIg_set_state (sub_form_ptr, 
			   WIREFRAME,
			   EM_IS_WIREFRAME_DISPLAYED(p_node->props));
	    
	    FIg_set_state (sub_form_ptr, 
			   SOLIDSURFS,
			   EM_IS_SOLIDSURF_DISPLAYED(p_node->props));
			   
	    FIf_display (sub_form_ptr);
	 }

   return(om_msg);
}

int EMbom_notify (int    form_label,
                  int    label,
                  double value,
                  Form   form_ptr)
{
    IGRlong       om_msg, msg;
    IGRint        type, old_bom_mode, state;
    IGRint        act_row, act_col, pos, sel, i,j, active_row, count;
    IGRint        row,col,old_sys_mode;
    IGRint        num_rows;
    IGRint        display, behavior;
    IGRchar       buffer[256], buff[256], name[256];
    ASM_tree      * p_node;
    ASM_tree      * p_node2;
    ASM_tree      *tmp_tree;
    ASM_tree      *tmp_tree2;
    IGRboolean    regenerate = FALSE, update = FALSE;
    Form          sub_form_ptr;
    EMattr        attr;
    IGRint        types;
    IGRuint       new_props;
    struct GRmd_env mod_env;
    struct GRmd_env part_mdenv;
    IGRchar       cmd_str[20];
    IGRint        response_type;
    IGRlong       nbytes;
    IGRshort      done = FALSE;
    IGRchar       active_file[OM_K_MAXOSNAME_LEN];
    IGRchar       save_prompt[256];
    IGRint        is_on;
    IGRlong       on_layers[32];
    IGRchar       layer_string[256];
    struct  GRid  att_prt, cnstrid;
    struct  GRid  part_id;
    enum GRdpmode mode;
    IGRdouble     offset;
    
    trace(printf("in EMbom_notify\n"));
    gr$get_module_env (buffer = &mod_env);

    if ((EMconstr_form != NULL) && (form_label != BOM_CONSTRAINTS_FORM))
	if (label != BOM)
    {
	FIg_set_text(EMbom_form,MESSAGE,"Check out constraints form");
        EMbom_mode = BOM_CONSTRAINT;
        FIg_set_state_off(EMbom_form,label);
        FIg_set_state_on(EMbom_form,CONSTR);
	return 0;
    }

    FIg_set_text( form_ptr, MESSAGE, "" );
    if (form_label == BOM_EDIT_FORM)
    {
        IGRint     batch_mode;

        p_node = EMbom_selected_node;
        
        switch (label)
        {
        case INST_ATTR:

	       FIfld_get_active_row (form_ptr, label, &act_row, &pos );
	       FImcf_get_active_col (form_ptr, label, &act_col, &pos );
		/*
		 * If an attribute name is removed, delete the row
	         */
               	buffer[0] = 0;
	       	FIfld_get_text (form_ptr, label, act_row, act_col, 
               		                 256, buffer, &sel, &pos);
		if( act_col == 0 )
		{
		    if( act_row == 0 )
               	    {
                        if(strcmp( buffer,"itemno"))
                       	FIfld_set_text( form_ptr, label, 0, 0,"itemno",0);
                           break;
                    }
                    else if( act_row == 1)
                    {
                       	if(strcmp( buffer,"quantity") )
                       	FIfld_set_text( form_ptr, label, 1, 0,
                                                       "quantity", 0 );
                        break;
                    }

		    if( buffer[0] == 0 )
		    {
	                FIfld_get_num_rows(form_ptr,label,&num_rows);
               	        for (i=act_row; i<num_rows-1; i=i+1)
               	         {
                       	    for (j=0; j<3; j=j+1)
                       	     {
                      	        FIfld_get_text (form_ptr, label, 
                               		i+1, j, 256, buffer, &sel,&pos);
                        
		                FIfld_set_text (form_ptr, label,
                                       		i, j, buffer, FALSE);
                       	     }       
               	         }
                
    	                 for (i=0; i<3; i=i+1)
               		  {
	                     FIfld_set_text (form_ptr,label,
               		                 num_rows-1, i, "", FALSE);
               	          }   
               	   }
                }
 		else if(act_col == 2)
		{
	           if(act_row == 0)
	            {
	              /* Validate the itemno keyed in */
                      if (!EMitem_string_unique (buffer))
                       {
                         FIg_set_text (form_ptr, MESSAGE, "Itemno not unique");
                         om_msg = EMnext_itemno_attribute (&msg, NULL, &attr);
                         if((om_msg & msg & 1))
                           sprintf( buffer, "\"%s\"", attr.value.syntax);
                         FIfld_set_text (form_ptr, INST_ATTR, 0, 2, buffer,
								      FALSE);
                         om_msg = OM_S_SUCCESS;
                       }
                    }
                  else
		    {
                      name[0] = 0;
                      om_msg = EMget_syntax_from_input( buffer, buff, name );

                      if( om_msg )
                       {
                          FIfld_set_text( form_ptr, label, act_row, 2,
                                                              buff, FALSE );
                          if(strlen(name))
                       	      FIfld_set_text( form_ptr, label, act_row,
                                                             0, name, FALSE );
                       }
                      else 
		        om_msg = OM_S_SUCCESS;
                    }
                }
            break;
            
        case ACCEPT:

            /*
             * See if any attributes have been deleted or modified...
             */

            FIfld_get_text (form_ptr,
                            INST_ATTR,
                            0,2,MAX_NAME,
                            buffer,
                            &sel,&pos );

            remove_quotes(buffer);

            if(strcmp(itemno.value.syntax,buffer))
	     {
	       if((p_node->props & EM_FILE_PART) ||
		   (p_node->props & EM_LOCAL_PART))
	         {
		    part_id = p_node->part_id;
	         }
	        else
	         {
		    asm$get_instance_part (msg = &msg,
				           instance_id = &p_node->part_id,
				           part_id = &part_id);
	         }

	       attr.value.type = EM_STRING;
	       strcpy(attr.value.syntax,buffer); 
	       strcpy(attr.info.name,itemno.info.name);

               FIfld_get_text (form_ptr,
                                INST_ATTR,
                                0,1,MAX_NAME,
                                buffer,
                                &sel,&pos );
               strcpy(attr.info.desc,buffer);

	       old_sys_mode = EMdesc_set_system_mode(TRUE);

               om_msg = asm$mod_attribute (msg = &msg,
                                           id = &part_id,
                                           name = attr.info.name,
                                           attribute = &attr);

               EMdesc_set_system_mode(old_sys_mode);
	    }

            for (i=0; i<EMbom_num_inst_attrs; ++i)
            {
                FIfld_get_text (form_ptr,
                                INST_ATTR,
                                i+1,0,MAX_NAME,
                                buffer,
                                &sel,&pos );
                    
                if (buffer[0] == '\0')
                {
                    om_msg = asm$rem_attribute (msg = &msg,
                                                id = &p_node->part_id,
                                                name = EMbom_inst_attrs[i].info.name);

                    if (!(om_msg & msg & 1))
                    {
                        FIfld_set_text (form_ptr,
                                        INST_ATTR,
                                        i+1,0,
                                        EMbom_inst_attrs[i].info.name,
                                        FALSE);
                        
                        FIfld_set_text (form_ptr,
                                        INST_ATTR,
                                        i+1,1,
                                        EMbom_inst_attrs[i].info.desc,
                                        FALSE);
                        
			EMrem_syntax_lhs(EMbom_inst_attrs[i].value.syntax,
					 buffer);
                        FIfld_set_text (form_ptr,
                                        INST_ATTR,
                                        i+1,2,
                                        buffer,
                                        FALSE);
                        sprintf (buffer, 
                                 "Couldn't remove attribute %s",
                                 EMbom_inst_attrs[i].info.name);
                    
                        FIfld_set_text (form_ptr,
                                        MESSAGE,
                                        0, 0,
                                        buffer,
                                        FALSE);
                    
                        FIg_set_state (form_ptr, ACCEPT, FALSE);
                        
                        return FI_SUCCESS;
                    }
                }
                else 
                {
                    attr = EMbom_inst_attrs[i];
                    strcpy (attr.info.name, buffer);

                    FIfld_get_text (form_ptr,
                                    INST_ATTR,
                                    i+1,1,MAX_DESC,
                                    buffer,
                                    &sel,&pos );
                    strcpy (attr.info.desc, buffer);
                    
                    FIfld_get_text (form_ptr,
                                    INST_ATTR,
                                    i+1,2,MAX_VALUE,
                                    buffer,
                                    &sel,&pos );
                    strcpy (attr.value.syntax, buffer);
		    if(remove_quotes(attr.value.syntax))
		      attr.value.type = EM_STRING;
                    
                    if (strcmp(attr.info.name, EMbom_inst_attrs[i].info.name) ||
                        strcmp(attr.info.desc, EMbom_inst_attrs[i].info.desc) ||
                        strcmp(attr.value.syntax, EMbom_inst_attrs[i].value.syntax))
                    {
	                old_sys_mode = EMdesc_set_system_mode(TRUE);
                        om_msg = asm$mod_attribute (msg = &msg,
                                                    id = &p_node->part_id,
                                                    name = EMbom_inst_attrs[i].info.name,
                                                    attribute = &attr);
                        EMdesc_set_system_mode(old_sys_mode);

                        if (!(om_msg & msg & 1))
                        {
                            FIfld_set_text (form_ptr,
                                            INST_ATTR,
                                            i+1,0,    
                                            EMbom_inst_attrs[i].info.name,
                                            FALSE);
                        
                            FIfld_set_text (form_ptr,
                                            INST_ATTR,
                                            i,1,
                                            EMbom_inst_attrs[i].info.desc,
                                            FALSE);
                        
                            FIfld_set_text (form_ptr,
                                            INST_ATTR,
                                            i,2,
                                            EMbom_inst_attrs[i].value.syntax,
                                            FALSE);
                        
                            sprintf (buffer, 
                                     "Couldn't update attribute %s",
                                     EMbom_inst_attrs[i].info.name);
                        
                            FIfld_set_text (form_ptr,
                                            MESSAGE,
                                            0, 0,
                                            buffer,
                                            FALSE);

                            FIg_set_state (form_ptr, ACCEPT, FALSE);
                                           
                            return FI_SUCCESS;
                        }            
                    }
                }
            }

            
            FIfld_get_num_rows (form_ptr, INST_ATTR, &count);

            if (count > EMbom_num_inst_attrs+1)
            {
                for (i=EMbom_num_inst_attrs+1; i<count; ++i)
                {
                    attr.info.type = EM_INSTANCE_ATTR;
                    attr.value.type = EM_CALCULATED;
                    
                    FIfld_get_text (form_ptr,
                                    INST_ATTR,
                                    i,0,MAX_NAME,
                                    attr.info.name,
                                    &sel,&pos );
                    
                    FIfld_get_text (form_ptr,
                                    INST_ATTR,
                                    i,1,MAX_DESC,
                                    attr.info.desc,
                                    &sel,&pos );
                    
                    FIfld_get_text (form_ptr,
                                    INST_ATTR,
                                    i,2,MAX_VALUE,
                                    attr.value.syntax,
                                    &sel,&pos );
                    if(remove_quotes(attr.value.syntax))
		      attr.value.type = EM_STRING;

                    asm$add_attribute (msg = &msg,
                                       id = &p_node->part_id,
                                       attribute = &attr);
                }
            }

            types = 0;
            
            FIg_get_state (form_ptr, SOLIDSURFS, &is_on);
            if (is_on) types |= EM_SOLIDSURF_DISPLAYED;
            
            FIg_get_state (form_ptr, WIREFRAME, &is_on);
            if (is_on) types |= EM_WIREFRAME_DISPLAYED;
            
            FIg_get_state (form_ptr, TEXT, &is_on);
            if (is_on) types |= EM_TEXT_DISPLAYED;
            
            FIg_get_state (form_ptr, DIMENSIONS, &is_on);
            if (is_on) types |= EM_DIMENSION_DISPLAYED;
            
            FIg_get_state (form_ptr, REFPLANES, &is_on);
            if (is_on) types |= EM_REFPLANE_DISPLAYED;
            
            FIg_get_state (form_ptr, CONSTRAINTS, &is_on);
            if (is_on) types |= EM_CONSTRAINT_DISPLAYED;

            if((p_node->props & EM_FILE_PART) ||
	       (p_node->props & EM_LOCAL_PART))
             {
               FIfld_get_text(form_ptr,ON_LAYERS,0,0,256,layer_string,
			      &sel,&pos);

	       om_msg = EMconvert_layer_string_to_mask(&msg, 
					               &mod_env,
					               layer_string,
					               on_layers);
	     }				   
            types |= EM_IS_GRAPHIC_DISPLAYED(p_node->props) ?
                     EM_GRAPHIC_DISPLAYED : 0;
            
            types |= EM_IS_HANDLE_DISPLAYED(p_node->props) ?
                     EM_HANDLE_DISPLAYED : 0;
            
            FIf_erase (form_ptr);
            FIf_delete (form_ptr);

            dp$erase_hilite (msg = &msg,
                             osnum = mod_env.md_id.osnum);
                
            if(p_node->part_id.osnum == mod_env.md_id.osnum)
               part_mdenv = mod_env;
            else
               EMget_part_mdenv(&msg,&p_node->part_id,&part_mdenv);
                            
            if((p_node->props & EM_FILE_PART) ||
	       (p_node->props & EM_LOCAL_PART))
             {
               om_msg = asm$set_display_props (msg = &msg,
                                               mod_env = &part_mdenv,
                                               id = &p_node->part_id,
                                               display = &types,
                                               layers = on_layers,
                                               update = TRUE);
               p_node->props = types | (p_node->props & ~EM_DISPLAY_PROPS);
             }
            else
	     {
                om_msg = asm$set_display_props (msg = &msg,
                                                mod_env = &part_mdenv,
                                                id = &p_node->part_id,
                                                display = &types,
                                                layers = NULL,
                                                update = TRUE);

                new_props = types | (p_node->props & ~EM_DISPLAY_PROPS);
                tmp_tree = assembly_tree->next;
		while(tmp_tree)
		 {
		    if(!(strcmp(p_node->filename, tmp_tree->filename)))
		     {
		       om_msg = om$send(msg = message EMdescribe.EMset_props(
								    &msg,
								    new_props),
                                        senderid = NULL_OBJID,
					targetid = tmp_tree->part_id.objid,
					targetos = tmp_tree->part_id.osnum);
                       tmp_tree->props = new_props;
		     }
                    tmp_tree = tmp_tree->next;
		 }

	     }
            /*
             * Update the modify batch if requested.
             */
            nd$mod_batch (request = ND_INQ, p_ret_mode = &batch_mode);
        
            if (batch_mode == ND_IMMEDIATE)
            {
                nd$exec_batch ();
            }

            EMbom_num_part_attrs = 0;
            om$dealloc (ptr = EMbom_part_attrs);
            EMbom_part_attrs = NULL;
            
            EMbom_num_inst_attrs = 0;
            om$dealloc (ptr = EMbom_inst_attrs);
            EMbom_inst_attrs = NULL;

            EMbom_selected_node = NULL;
            
            break;
            
        case EXIT:
            FIf_erase (form_ptr);
            FIf_delete (form_ptr);
            break;
        }
        
        return FI_SUCCESS;
    }

    if (form_label == BOM_SET_DISPLAY_FORM)
    {
        switch (label)
        {
        case ACCEPT:
            types = 0;
            
            FIg_get_state (form_ptr, SOLIDSURFS, &is_on);
            if (is_on) types |= EM_SOLIDSURF_DISPLAYED;
            
            FIg_get_state (form_ptr, WIREFRAME, &is_on);
            if (is_on) types |= EM_WIREFRAME_DISPLAYED;
            
            FIg_get_state (form_ptr, TEXT, &is_on);
            if (is_on) types |= EM_TEXT_DISPLAYED;
            
            FIg_get_state (form_ptr, DIMENSIONS, &is_on);
            if (is_on) types |= EM_DIMENSION_DISPLAYED;
            
            FIg_get_state (form_ptr, REFPLANES, &is_on);
            if (is_on) types |= EM_REFPLANE_DISPLAYED;
            
            FIg_get_state (form_ptr, CONSTRAINTS, &is_on);
            if (is_on) types |= EM_CONSTRAINT_DISPLAYED;

            FIf_erase (form_ptr);
            FIf_delete (form_ptr);

	    EMbom_set_display(&types);

            EMbom_display_properties ();
            break;
            
        case EXIT:
	    tmp_tree = assembly_tree;
	    while(tmp_tree)
	     {
	       tmp_tree->new_state &= ~(BOM_EDIT |BOM_EVENT | BOM_HIGHLIGHT |
					BOM_DELETE | BOM_SETDISPLAY);
               tmp_tree->old_state = tmp_tree->new_state;

	       tmp_tree = tmp_tree->next;
	     }
            FIf_erase (form_ptr);
            FIf_delete (form_ptr);
            EMbom_display_properties ();
            break;
        }
        return FI_SUCCESS;
    }


    if (form_label == BOM_CONSTRAINTS_FORM)
    {
        p_node = EMbom_selected_node;
        switch (label)
        {
            case CONSTR_LIST:	
                FIfld_get_active_row( form_ptr, CONSTR_LIST, &row, &state );
                FImcf_get_active_col( form_ptr, CONSTR_LIST, &col, &state );

       	        dp$erase_hilite( msg = &msg );

                asm$get_constraint( msg = &msg,
                                part_id = &p_node->part_id,
                                index = row,
                                in_out = &state,
				type = &type,
                                cnstrid = &cnstrid );
                /* 
                 * If col = 0, highlight the picked constraint's features
                 * if col = 1, highlight the part, constraint is applied to.
                 */
		is_on = -1;
                if( col == 0 )
                {
                    FIfld_get_select( form_ptr, CONSTR_LIST, row, 0, &is_on );
		    if( is_on == 1 )
                    	mode = GRhd;            
		    else
                    	mode = GRhe;            

                    if( type != GROUND )
                    {
                        EMHighlight_Cnstr( &msg, &cnstrid, mode );
			if( type == MATE )
		            FIg_enable( form_ptr, CONSTR_VAL );
                        else
                        {
        	            FIg_set_text( form_ptr, CONSTR_VAL, "" );
    			    FIg_disable( form_ptr, CONSTR_VAL );
                            break;
                        }
		    }
                    else
                    {
                        EMget_part_mdenv (&msg, &p_node->part_id, &mod_env);
                        EMhighlight_obj( &p_node->part_id, &mod_env, mode );
			FIg_disable( form_ptr, CONSTR_VAL );
        	        FIfld_set_text( form_ptr, CONSTR_VAL, 0, 0, "", 0 );
                        break;
                    }
    		    /*
		     *  Update the constraint offset gadget
		     */
		    om_msg = asm$get_cnstr_exp_info( msg = &msg,
					cnstrid = &cnstrid,
					exp_value = &offset );
	            if( om_msg & msg & 1 )
        	    {
	                sprintf( buffer, "%.2f", offset );
        	        FIfld_set_text( form_ptr, CONSTR_VAL, 0, 0, buffer, 0 );
	            }
                }
                else if( col == 1 )
                {
                    FIfld_get_select( form_ptr, CONSTR_LIST, row, 1, &is_on );
		    if( is_on == 1 )
                    	mode = GRhd;            
		    else
                    	mode = GRhe;            

                    if(type == GROUND)
                    {
                        EMget_part_mdenv (&msg, &p_node->part_id, &mod_env);
                        EMhighlight_obj( &p_node->part_id, &mod_env, mode );
                        break;
                    }

                    if( state == 1 ) 
                    {
                        om_msg = asm$get_paired_parts( msg = &msg,
                                                   cnstrid = &cnstrid,
                                                   p2_id = &att_prt );
                    }
                    else if( state == 0 )
                    {
                        om_msg = asm$get_paired_parts( msg = &msg,
                                                   cnstrid = &cnstrid,
                                                   p1_id = &att_prt );
                    }
                    EMget_part_mdenv (&msg, &att_prt, &mod_env);
                    EMhighlight_obj( &att_prt, &mod_env, mode );
                }

                break;

            case CONSTR_VAL:
                /*
                 * Update the constraint value of the active constraint selected.
                 */
                FIfld_get_num_rows( form_ptr, CONSTR_LIST, &row );
                for( i = 0; i < row; i++ )
                {
                    state = -1;
                    FIfld_get_select( form_ptr, CONSTR_LIST, i, 0, &state );
                    if( state == 1 )
                        break;
                }
                if( i != row ) /* Got a selected constraint */
                {
                    asm$get_constraint( msg = &msg,
                                    part_id = &p_node->part_id,
                                    index = i,
                                    in_out = &state,
                                    cnstrid = &cnstrid );

	            asm$get_cnstr_exp_info( msg = &msg,
		            		cnstrid = &cnstrid,
			        	exp_value = &offset );

	            FIfld_get_text( form_ptr, CONSTR_VAL, 0, 0, 256,
						 buffer, &col, &state );

                    om_msg = asm$set_constraint_value( msg = &msg,
                                               cnstrid = &cnstrid,
			        	       exp_syntax = buffer );
                    if( !(om_msg & msg & 1) )
                    {
                        sprintf( buff, "Failed to set offset=%s", buffer );
                        FIfld_set_text( form_ptr, MESSAGE, 0, 0, buff, 0 );
	                sprintf( buffer, "%.2f", offset );
        	        FIfld_set_text( form_ptr, CONSTR_VAL, 0, 0, buffer, 0 );
                    }
                    else
                    {
			dp$erase_hilite( msg = &msg );
                        /*
                         * Update the batch queue if necessary.
                         */
                        nd$mod_batch (request = ND_INQ, p_ret_mode = &state);
        
                        if (state == ND_IMMEDIATE)
                        {
                            nd$exec_batch ();
                        }
                    }
                }
                else
                {
                    FIfld_set_text( form_ptr, MESSAGE, 0, 0, "Select a Constraint", 0 );
                }
                break;        

            case DEL_BUTTON:
                /* Remove the selected constraint and update list */
                FIfld_get_num_rows( form_ptr, CONSTR_LIST, &row );
                for( i = 0; i < row; i++ )
                {
                    state = -1;
                    FImcf_get_select( form_ptr, CONSTR_LIST, i, &state );
                    if(state == 1)
                        break;
                }
                if( i == row )
                {
                    FIfld_set_text( form_ptr, MESSAGE, 0, 0, "Select a Constraint", 0 );
                    break;
                }
      	        /* Unhilight the plane */
        	{
		    dp$erase_hilite( msg = &msg );
                }
		
                /* get the constraint to be removed */
                om_msg = asm$get_constraint( msg = &msg,
                                        part_id = &p_node->part_id,
                                        index = i,
                                        in_out = &col,
                                        cnstrid = &cnstrid );

                om_msg = asm$rem_constraint( msg = &msg,
                                             constraint_id = &cnstrid );

       	        nd$mod_batch (request = ND_INQ, p_ret_mode = &state);
                /*
                 * Update the batch queue if necessary.
                 */
                if (state == ND_IMMEDIATE)
                {
                    nd$exec_batch ();
                }
                om_msg = EMbom_show_constraints( p_node );
		break;

	    case DOF_BUTTON:
                /* 
                 * Show the Degrees of Freedom on the selected part.
                 */
	        init_dof_display();

    	        om_msg = show_dof_part( &msg, &p_node->part_id, GRhd );

                if( !(om_msg & msg & 1 ))
                    printf("showdofpart failed\n");

                break;

            case ACCEPT:
            case EXIT:
                FIf_erase (form_ptr);
                FIf_delete (form_ptr);
				EMconstr_form = NULL;
            	EMbom_selected_node = NULL;
                break;
	}
        return FI_SUCCESS;
    }
    
    switch (label)
    {
    case ACCEPT:
    case RUN:

        if(EMbom_mode == BOM_EVENT)
         {
           IGRboolean set_flag = FALSE;
           IGRint     set_count = 0; 

	   tmp_tree = assembly_tree;
           while(tmp_tree)
             {
               if((tmp_tree->new_state != tmp_tree->old_state) &&
                   (tmp_tree->new_state & BOM_EVENT))
                 {
                    set_count+= 1;
                    p_node = tmp_tree;
                    if(set_count > 1)
                     {
                       set_flag = TRUE;
                       break;
                     }
                 }
	       tmp_tree = tmp_tree->next;
             }

           if(set_flag)
            {
              struct GRid grset;
              IGRint set_props = GRIS_DISPLAY_ALL;

              om_msg = gr$gsinit(msg = &msg,
                                 senderid = NULL_OBJID,
                                 senderos = mod_env.md_id.osnum,
                                 osnum = mod_env.md_id.osnum,
                                 flag = 3,
                                 p_objid = &grset.objid);
             if(om_msg & msg & 1)
              {
                grset.osnum = mod_env.md_id.osnum;
                tmp_tree = assembly_tree; 
		while(tmp_tree)
                 {
                   if((tmp_tree->new_state != tmp_tree->old_state) &&
                      (tmp_tree->new_state & BOM_EVENT))
                    {
                       if(tmp_tree->part_id.osnum == mod_env.md_id.osnum)
                         part_mdenv = mod_env;
                       else
                         EMget_part_mdenv(&msg,&tmp_tree->part_id,&part_mdenv);

                       om_msg = om$send(msg = message GRgrset.GSobject_add
                                              (&msg,&tmp_tree->part_id,
					       &part_mdenv, &set_props,
					       &grset, NULL),
                                        senderid = NULL_OBJID,
                                        targetid = grset.objid,
                                        targetos = grset.osnum);
                       if(!(om_msg & msg & 1))
                        {
                           om$report_error(sts = om_msg);
                           printf("failed to add part to select set\n");
                        }
                       tmp_tree->new_state &= ~(BOM_EDIT | BOM_EVENT  | 
                                               BOM_HIGHLIGHT | BOM_DELETE | 
                                               BOM_SETDISPLAY);

                       tmp_tree->old_state = tmp_tree->new_state; 

                    }
                   tmp_tree = tmp_tree->next;
                 }

                ASputobj(&msg, grset.objid, grset.osnum, &mod_env);
                 
              }
            } 
           else
            {
              if(set_count == 1)
               {
                if(p_node->part_id.osnum == mod_env.md_id.osnum)
                   part_mdenv = mod_env;
                else
                   EMget_part_mdenv(&msg,&p_node->part_id,&part_mdenv);

                ASputobj(&msg,p_node->part_id.objid,p_node->part_id.osnum,
                        &part_mdenv);


                p_node->new_state &= ~(BOM_EDIT | BOM_EVENT  | 
                                       BOM_HIGHLIGHT | BOM_DELETE | 
                                       BOM_SETDISPLAY);

                p_node->old_state = p_node->new_state; 
              }
            }
         }
        else
         {
           tmp_tree = assembly_tree; 
	   while(tmp_tree)
           {
            
             if (tmp_tree->new_state != tmp_tree->old_state)
              {
                switch (EMbom_mode)
                {
                case BOM_BACKGROUND:
                    if ((tmp_tree->new_state & BOM_BACKGROUND) !=
                        (tmp_tree->old_state & BOM_BACKGROUND))
                    {
                        update = FALSE;
                        
                        om_msg = asm$get_behavior_props(msg = &msg,
                                                        id = &tmp_tree->part_id,
                                                        behavior = &behavior);
                    
                        if (om_msg & msg & 1)
                        {
                            if (tmp_tree->new_state & BOM_BACKGROUND)
                            {
                                if (!(behavior & EM_BACKGROUND))
                                {
                                    behavior |= EM_BACKGROUND;
                                    update = TRUE;
                                }
                            }
                            else
                            {
                                if (behavior & EM_BACKGROUND)
                                {
                                    behavior &= ~EM_BACKGROUND;
                                    update = TRUE;
                                }                            
                            }
                        
                            if (update)
                            {
                                om_msg = asm$set_behavior_props (msg = &msg, 
                                                                 id = &tmp_tree->part_id,
                                                                 behavior = behavior);
                            }
                        }
                    }

                    tmp_tree->old_state &= ~(BOM_EDIT | BOM_EVENT  | 
                                            BOM_HIGHLIGHT | BOM_DELETE | 
                                            BOM_SETDISPLAY);
            
                    tmp_tree->new_state = tmp_tree->old_state;
                    break;
                    
                case BOM_ACTIVE:

                    if (((tmp_tree->new_state & BOM_ACTIVE) !=
                         (tmp_tree->old_state & BOM_ACTIVE)) &&
                        (tmp_tree->new_state & BOM_ACTIVE))
                    {
                        om_msg = asm$get_part_type(msg = &msg,
                                                   part_id = &tmp_tree->part_id,
                                                   type = &type);

                        if (type & (EM_LOCAL_PART | EM_FILE_PART))
                         {
                            om_msg = asm$set_active_part(msg = &msg,
                                                  part_id = &tmp_tree->part_id);
                            tmp_tree->new_state &= ~(BOM_EDIT | BOM_EVENT  | 
                                                  BOM_HIGHLIGHT | BOM_DELETE | 
                                                  BOM_SETDISPLAY);

                            tmp_tree->old_state = tmp_tree->new_state;
                         }
                        else
                         {
			   EMPartInfo dbpart_info;
			   IGRlong  in_opr, out_opr;

			   in_opr = BOM_ACTIVE;
			   out_opr = 0;

                            om_msg = asm$get_attribute (msg = &msg,
				                        id = &tmp_tree->part_id,
						        name = "number",
						        attribute = &attr);
                            if(om_msg & msg & 1)
			     {
			       strcpy(dbpart_info.number,attr.value.data.s);
			     }
                            om_msg = asm$get_attribute (msg = &msg,
				                        id = &tmp_tree->part_id,
						        name = "revision",
						        attribute = &attr);
                            if(om_msg & msg & 1)
			     {
			       strcpy(dbpart_info.revision,attr.value.data.s);	
			     }
                            strcpy(dbpart_info.filename,tmp_tree->filename);

			    om_msg = EMGetDbPermissions(&dbpart_info,
							&in_opr,
							&out_opr);

                            if((om_msg & 1) && (!(out_opr & BOM_ACTIVE)))
			     {
			       sprintf(buffer,
				       "Selected part can't be made active");
                               FIg_set_text(form_ptr,FI_MSG_FIELD,buffer);
			       return FI_SUCCESS;
			     }

                            if(tmp_tree->filename[0] != NULL)
                             {
                                IGRint response;
                                IGRchar resp_data[256];
                                struct GRevent event;

                                /* get the active file name */
                                ex$filename(name = active_file, 
					    len = OM_K_MAXOSNAME_LEN);
                                sprintf(save_prompt,"Save %s, y/n",active_file);
                                /* retrieve the file as active module */
                                while(!done)
                                 {
                                   co$getevent(msg = &msg,
                                               event_mask = GRm_TEXT_VALUE,
                                               prompt = save_prompt,
                                               response = &response,
                                               response_data = resp_data,
                                               event = &event);
				   if((response == TERMINATE) ||
				      (response == CLEAR_STACK ))
				    {
                                	ex$putque(msg = &msg,
                                       	response = &response);
					return FI_SUCCESS;
				    }

                                   if(event.response == STRING)
                                    {
                                      if(!(strcmp(event.event.keyin, "y")) ||
                                         !(strcmp(event.event.keyin, "Y")))
                                       {
                                         strcpy(cmd_str,"ret=y");
                                         response_type = CMD_STRING;
                                         nbytes = strlen(cmd_str) + 1;
                                         done = TRUE;
                                       }
                                      else
                                       if(!(strcmp(event.event.keyin, "n")) ||
                                         !(strcmp(event.event.keyin, "N")))
                                        {
                                          strcpy(cmd_str,"ret=n");
                                          response_type = CMD_STRING;
                                          nbytes = strlen(cmd_str) + 1;
                                          done = TRUE;
                                        }
                                    }

                                 }
                                FIf_erase(form_ptr);
                                ex$putque(msg = &msg,
                                          response = &response_type,
                                          byte = &nbytes,
                                          buffer = cmd_str);

                                response_type = EX_STRING;
                                nbytes = strlen(tmp_tree->filename) +1;

                                ex$putque(msg = &msg,
                                          pos = BACK,
                                          response = &response_type,
                                          byte = &nbytes,
                                          buffer = tmp_tree->filename);
                              }
                         }
                    } 

                    break;
                    
                case BOM_DISPLAY:

                    if ((tmp_tree->new_state & BOM_DISPLAY) !=
                        (tmp_tree->old_state & BOM_DISPLAY))
                    {
                        update = FALSE;
                        
                        om_msg = asm$get_display_props (msg = &msg,
                                                        id = &tmp_tree->part_id,
                                                        display = &display);
                    
                        if (om_msg & msg & 1)
                        {
                            if (tmp_tree->new_state & BOM_DISPLAY)
                            {
                                if (!(display & EM_GRAPHIC_DISPLAYED))
                                {
                                    display |= EM_GRAPHIC_DISPLAYED;
                                    update = TRUE;
                                }
                            }
                            else
                            {
                                if (display & EM_GRAPHIC_DISPLAYED)
                                {
                                    display &= ~EM_GRAPHIC_DISPLAYED;
                                    update = TRUE;
                                }                            
                            }
                        
                            if (update)
                            {
                              if(tmp_tree->part_id.osnum == mod_env.md_id.osnum)
                                   part_mdenv = mod_env;
                              else
                                EMget_part_mdenv(&msg,&tmp_tree->part_id,&part_mdenv);

                                om_msg = asm$set_display_props (msg = &msg, 
                                                                mod_env = &part_mdenv,
                                                                id = &tmp_tree->part_id,
                                                                display = &display);
                            }
                        }
                    }

                    tmp_tree->old_state &= ~(BOM_EDIT | BOM_EVENT  | 
                                            BOM_HIGHLIGHT | BOM_DELETE | 
                                            BOM_SETDISPLAY);
            
                    tmp_tree->new_state = tmp_tree->old_state;

                    break;
                    
                case BOM_WRITE:

                    if ((tmp_tree->new_state & BOM_WRITE) !=
                        (tmp_tree->old_state & BOM_WRITE))
                    {
                        behavior = tmp_tree->props & EM_BEHAVIOR_PROPS;

                        if(tmp_tree->new_state & BOM_WRITE)
                        {
                            if(tmp_tree->props & EM_READONLY)
                            {
			      EMPartInfo dbpart_info;
			      IGRlong  in_opr, out_opr;

			      in_opr = BOM_WRITE;
			      out_opr = 0;

                              om_msg = asm$get_attribute (msg = &msg,
				                        id = &tmp_tree->part_id,
						        name = "number",
						        attribute = &attr);
                              if(om_msg & msg & 1)
			       {
			         strcpy(dbpart_info.number,attr.value.data.s);	
			       }
                              om_msg = asm$get_attribute (msg = &msg,
				                        id = &tmp_tree->part_id,
						        name = "revision",
						        attribute = &attr);
                              if(om_msg & msg & 1)
			      {
			        strcpy(dbpart_info.revision,attr.value.data.s);	
			      }
                              strcpy(dbpart_info.filename,tmp_tree->filename);

			      om_msg = EMGetDbPermissions(&dbpart_info,
			  				&in_opr,
							&out_opr);

                              if((om_msg & 1) && (!(out_opr & BOM_WRITE)))
			       {
			         sprintf(buffer,
			  	       "Selected part can't be made active");
                                 FIg_set_text(form_ptr,FI_MSG_FIELD,buffer);
			         break;
			       }

                                update = TRUE;
                                tmp_tree2 = tmp_tree->parent;
                                while(tmp_tree2)
                                {
                                    if((tmp_tree2->props & EM_REFERENCE_PART) &&
                                       (tmp_tree2->props & EM_READONLY))
                                    {
                                        update = FALSE;
                                    }
                                    tmp_tree2 = tmp_tree2->parent;
                                }
                                if(update)
                                {
                                    GRmake_writable(&msg, tmp_tree->filename,
                                                &tmp_tree->part_id.osnum);

                                    behavior &= ~EM_READONLY;

                                    om_msg = asm$set_behavior_props(msg = &msg,
                                                        id = &tmp_tree->part_id,
                                                        behavior = behavior);
                                }
                            }
                        }
                        else
                        {
                            if(!(tmp_tree->props & EM_READONLY))
                            {
                                GRmake_read_only(&msg, tmp_tree->filename,
                                               &tmp_tree->part_id.osnum);

                                behavior |= EM_READONLY;

                                om_msg = asm$set_behavior_props(msg = &msg,
                                                       id = &tmp_tree->part_id,
                                                       behavior = behavior);
                            }
                        }
                    }
                    tmp_tree->old_state &= ~(BOM_EDIT | BOM_EVENT  | 
                                            BOM_HIGHLIGHT | BOM_DELETE | 
                                            BOM_SETDISPLAY);
            
                    tmp_tree->new_state = tmp_tree->old_state;

                    break;
                    
                case BOM_CONSTRAINT:
                    break;
                    
                case BOM_HIGHLIGHT:
                    if ((tmp_tree->new_state & BOM_HIGHLIGHT) !=
                        (tmp_tree->old_state & BOM_HIGHLIGHT))
                    {
                        struct GRmd_env mod_env;
                        IGRlong         layers[32];
                        enum GRdpmode   mode;

                        gr$get_module_env (buffer = &mod_env);
                        mod_env.md_id.osnum = tmp_tree->part_id.osnum;
                    
                        mode = (tmp_tree->new_state & BOM_HIGHLIGHT) ? GRhd : GRbd;

                        if ((tmp_tree->props & EM_LOCAL_PART) ||
                            (tmp_tree->props & EM_FILE_PART))
                        {
                            om_msg = om$send (msg = message EMlocalpart.EMget_layers
                                                                 (&msg,
                                                                  layers,
                                                                  NULL,
                                                                  NULL),
                                              senderid = NULL_OBJID,    
                                              targetid = tmp_tree->part_id.objid,
                                              targetos = tmp_tree->part_id.osnum);
                            
                            LClayer (layers, 
                                     mod_env.md_id.objid, 
                                     mod_env.md_id.osnum);
                        
                            EMdisplay_graphic_by_layer (&msg,
                                                        &mod_env,
                                                        layers,
                                                        mode);
                        }
                        else
                        {
                            dp$display (msg = &msg,
                                        osnum = tmp_tree->part_id.osnum,
                                        mode = mode,
                                        oids = &tmp_tree->part_id);
                        }
                    }
                    tmp_tree->new_state &= ~(BOM_EDIT | BOM_EVENT  | 
                                            BOM_HIGHLIGHT | BOM_DELETE | 
                                            BOM_SETDISPLAY);
            
                    tmp_tree->old_state = tmp_tree->new_state;
                    break;
                    
                case BOM_DELETE:
                    if ((tmp_tree->new_state & BOM_DELETE) !=
                        (tmp_tree->old_state & BOM_DELETE))
                    {
                        if (tmp_tree->new_state & BOM_DELETE)
                        {
                            om_msg = asm$get_part_type (msg = &msg,
                                                        part_id = &tmp_tree->part_id,
                                                        type = &type);
                            if (type & (EM_LOCAL_PART | EM_FILE_PART))
                            {
                                om_msg = om$send (msg = message EMdescribe.EMdelete
                                                  (&msg),
                                                  senderid = NULL_OBJID,
                                                  targetid = tmp_tree->part_id.objid,
                                                  targetos = tmp_tree->part_id.osnum);
			       tmp_tree = assembly_tree;
                               regenerate = TRUE;
			       continue;
                            }
                            else
                            {
                                struct GRmd_env mod_env;
                                
                                gr$get_module_env(buffer = &mod_env);
                                
				part_id = tmp_tree->part_id;
                                om_msg = dp$display (msg = &msg,
                                                     osnum = tmp_tree->part_id.osnum,
                                                     mode = GRbehe,
                                                     oids = &part_id);
                                
                                om_msg = om$send (msg = message GRgraphics.GRdelete
                                                  (&msg,
                                                   &mod_env),
                                                   senderid = NULL_OBJID,
                                                   targetid = tmp_tree->part_id.objid,
                                                   targetos = tmp_tree->part_id.osnum);
			       tmp_tree = assembly_tree;
                               regenerate = TRUE;
			       continue;
                            }
                        }
                    }
                    break;
                    
                case BOM_SETDISPLAY:
                    if ((tmp_tree->new_state & BOM_SETDISPLAY) !=
                        (tmp_tree->old_state & BOM_SETDISPLAY))
                    {
                        if (label == ACCEPT)
                        {
                            FIg_set_state (EMbom_form, ACCEPT, FALSE);
                        }

                        if (FIf_new (BOM_SET_DISPLAY_FORM,
                                     "EMSetDisp", 
                                     EMbom_notify,
                                     &sub_form_ptr) == FI_SUCCESS)
                        {
                           count = 0;
                           tmp_tree2 = assembly_tree;
			   while(tmp_tree2)
                            {
                
                               if ((tmp_tree2->new_state & BOM_SETDISPLAY) !=
                                   (tmp_tree2->old_state & BOM_SETDISPLAY))
                                {
                                    count++;
                                    if(count > 1)
                                     break;
                                }
                               tmp_tree2 = tmp_tree2->next;
                             }

                          if(count < 2)
                           { 
                            FIg_set_state (sub_form_ptr, 
                                           TEXT,
                                           EM_IS_TEXT_DISPLAYED(tmp_tree->props));
                    
                            FIg_set_state (sub_form_ptr, 
                                           DIMENSIONS,
                                           EM_IS_DIMENSION_DISPLAYED(tmp_tree->props));
                            
                            FIg_set_state (sub_form_ptr, 
                                           CONSTRAINTS,
                                           EM_IS_CONSTRAINT_DISPLAYED(tmp_tree->props));
                            
                            FIg_set_state (sub_form_ptr, 
                                           REFPLANES,
                                           EM_IS_REFPLANE_DISPLAYED(tmp_tree->props));
                    
                            FIg_set_state (sub_form_ptr, 
                                           WIREFRAME,
                                           EM_IS_WIREFRAME_DISPLAYED(tmp_tree->props));
                            
                            FIg_set_state (sub_form_ptr, 
                                           SOLIDSURFS,
                                           EM_IS_SOLIDSURF_DISPLAYED(tmp_tree->props));
                           }        
                          else
                           {
                            FIg_set_state (sub_form_ptr, 
                                           TEXT,
                                           FALSE);
                    
                            FIg_set_state (sub_form_ptr, 
                                           DIMENSIONS,
                                           FALSE);
                            
                            FIg_set_state (sub_form_ptr, 
                                           CONSTRAINTS,
                                           FALSE);
                            
                            FIg_set_state (sub_form_ptr, 
                                           REFPLANES,
                                           FALSE);
                    
                            FIg_set_state (sub_form_ptr, 
                                           WIREFRAME,
                                           FALSE);
                            
                            FIg_set_state (sub_form_ptr, 
                                           SOLIDSURFS,
                                           FALSE);
                           }        
                            FIf_display (sub_form_ptr);
                        }

                        return FI_SUCCESS;
                    }
                    break;
                }
            }
	    tmp_tree = tmp_tree->next;
          }
        }
        
        if (label == RUN)
        {
            if (regenerate)
            {
                EMbom_display();
            }
            else
            {
                EMbom_display_properties ();
            }
            break;
        }
        
        /* No break intentional */

    case EXIT:
         FIf_erase (form_ptr);
         FIf_delete (form_ptr);
         EMbom_form = NULL;
         break;

    case RESTORE:
	 EMbom_reset_tree_state();
	 if(EMbom_mode & BOM_FIRSTLEVEL)
	  {
	    //FIg_disable(form_ptr,NEST_LEVEL);
	    FIg_disable(form_ptr,DEPTH);
	    FIg_disable(form_ptr,DEPTH_LABEL);
	  }
         else
	  {
	    value = (IGRdouble)EMbom_display_depth;
	    //FIg_set_value(form_ptr,NEST_LEVEL,value);
	    FIg_set_value(form_ptr,DEPTH,value);
          }
         EMbom_display();
	 EMshow_mode();
         break;
        
    case CONVERT:
         break;

    case LOCATE:
         EMsetbom_locate();
         strcpy(cmd_str,"manage assembly");
         response_type = CMD_STRING;
         nbytes = strlen(cmd_str) + 1;

         ex$putque(msg = &msg,
                   response = &response_type,
                   byte = &nbytes,
                   buffer = cmd_str);

         break;

    case BOM:
        row = value;
        FImcf_get_active_col (EMbom_form, BOM, &col, &pos);
        EMbom_find_node_by_row (row, &p_node);

        switch (col)
        {
        case 0:
        case 1:
        case 2:
        case 3:
        case 4:
            
            FIfld_get_select (EMbom_form, BOM, row, col, &sel);
            
            for (i=0; i<5; ++i)
            {
                if (i != col)
                {
                    FIfld_set_select (EMbom_form, BOM, row, i, sel);
                }
            }

            FIfld_get_text(EMbom_form, BOM, row, 4, 256, buffer, &sel, &pos);

            switch (EMbom_mode)
            {
            case BOM_ACTIVE:
                if(buffer[0] == '\0')  /*** Fix to avoid crash ***/
                  break;
                if (!strcmp(buffer, "yes"))
                {
                    FIfld_set_text(EMbom_form, BOM, row, 4, "yes", FALSE);
                }
                else
                {
                    om_msg = om$send (msg = message EMdescribe.EMget_type 
                                                                      (&msg,
                                                                       &type),
                                      senderid = NULL_OBJID,
                                      targetid = p_node->part_id.objid,
                                      targetos = p_node->part_id.osnum);

                    if ((om_msg & msg & 1) && 
                        (type & 
                         (EM_LOCAL_PART | EM_FILE_PART | EM_REFERENCE_PART)))
                    {
			/* Cannot make nested localparts active 09/16/94*/
			if ((type & EM_LOCAL_PART) && (p_node->depth > 1))
				break;
	
                        EMbom_find_active_node(&active_row, &p_node2,BOM_ACTIVE);
                        
                        if (p_node2)
                        {
                            p_node2->new_state &= ~BOM_ACTIVE;

                            if (active_row != -1)
                            {
                                FIfld_set_text(EMbom_form, 
                                               BOM, 
                                               active_row, 
                                               4, 
                                               "no", 
                                               FALSE);
                            }
                        }

                        p_node->new_state |= BOM_ACTIVE;
                        FIfld_set_text(EMbom_form, BOM, row, 4, "yes", FALSE);
                    }
                    else
                    {
                        FIfld_set_text (EMbom_form, 
                                        MESSAGE, 
                                        0, 0, 
                                        "Only local parts can be made active.",
                                        FALSE);

                    }
                }
                break;

            case BOM_EDIT:
                if(!p_node) /*** Fix to avoid Crash***/
                  break;
                if(p_node->new_state & BOM_ACTIVE) 
		{
                   strcpy(cmd_str,"edit part");
                   response_type = CMD_STRING;
                   nbytes = strlen(cmd_str) + 1;

                   ex$putque(msg = &msg,
                             response = &response_type,
                             byte = &nbytes,
                             buffer = cmd_str);
		 }
                else
		 {
                   om_msg = EMshow_bom_edit(&msg, p_node);
		 }
                EMbom_selected_node = p_node;
                break;

            case BOM_CONSTRAINT:
                if(buffer[0] == '\0') /** Fix to avoid Crash ***/
                  break;
                if (!strcmp(buffer, "yes"))
                {
                    FIfld_set_text(EMbom_form, BOM, row, 4, "yes", FALSE);
                }
                else
                {
                    om_msg = om$send (msg = message EMdescribe.EMget_type 
                                                                      (&msg,
                                                                       &type),
                                      senderid = NULL_OBJID,
                                      targetid = p_node->part_id.objid,
                                      targetos = p_node->part_id.osnum);

                    if ((om_msg & msg & 1) && 
                        (type & 
                         (EM_LOCAL_PART | EM_REFERENCE_PART)))
                    {
                        EMbom_find_active_node(&active_row, &p_node2, BOM_CONSTRAINT);
                        
                        if (p_node2)
                        {
                            p_node2->new_state &= ~BOM_CONSTRAINT;

                            if (active_row != -1)
                            {
                                FIfld_set_text(EMbom_form, 
                                               BOM, 
                                               active_row, 
                                               4, 
                                               "no", 
                                               FALSE);
                            }
                        }

                        p_node->new_state |= BOM_CONSTRAINT;
                        FIfld_set_text(EMbom_form, BOM, row, 4, "yes", FALSE);
                    }
		}

                om_msg = EMbom_show_constraints(p_node);
                EMbom_selected_node = p_node;
                break;
                
            case BOM_DISPLAY:
            case BOM_BACKGROUND:
            case BOM_WRITE:
            case BOM_HIGHLIGHT:
            case BOM_DELETE:
            case BOM_SETDISPLAY:
            case BOM_EVENT:
                
                if (!strcmp(buffer, "yes"))
                {
                    FIfld_set_text(EMbom_form, BOM, row, 4, "no", FALSE);
                    p_node->new_state &= ~EMbom_mode;
                    strcpy(buffer,"no");
                    if(col != 4)
                      EMbom_nested_select(&row,buffer);
                }
                else
                  if(!strcmp(buffer, "no"))
                   {
                      FIfld_set_text(EMbom_form, BOM, row, 4, "yes", FALSE);
                      p_node->new_state |= EMbom_mode;
                      strcpy(buffer,"yes");
                      if(col != 4)
                        EMbom_nested_select(&row,buffer);
                   }

                break;
            }
            
            for (i=0; i<5; ++i)
            {
                FIfld_set_select (EMbom_form, BOM, row, i, FALSE);
            }

            break;
        }
        break;
        
    case DEPTH:
        EMbom_display ();
        break;

    case ACTIVE:
    case DISPLAY:
    case EDIT:
    case EVENT:
    case BACKGROUND:
    case WRITE:
    case CONSTR:
    case HIGHLIGHT:
    case DELETE:
    case SETDISPLAY:
	EMbom_reset_tree_state();
        old_bom_mode = EMbom_mode;
        EMbom_mode = BOM_ACTIVE << (label%ACTIVE);
        
        if ((EMbom_mode & BOM_FIRSTLEVEL) != (old_bom_mode & BOM_FIRSTLEVEL))
        {
            if (EMbom_mode & BOM_FIRSTLEVEL)
            {
		EMbom_display_depth = 1;
                FIg_disable (EMbom_form, DEPTH);
                FIg_disable (EMbom_form, DEPTH_LABEL);
            }
            else
            {
                FIg_enable (EMbom_form, DEPTH);
                FIg_enable (EMbom_form, DEPTH_LABEL);
            }

            EMbom_display ();
        }
        else
        {
            EMbom_display_properties ();
        }
        break;
    }
    
    return FI_SUCCESS;
}


IGRint EMbom_locate_update(msg, 
                           partids,
                           num_parts)
IGRlong *msg;
struct GRid *partids;
IGRint num_parts;
{
  IGRint i,j;
  IGRint row,col;
  IGRint sel = 1, pos, active_row;
  IGRint type;
  IGRlong om_msg;
  IGRchar buffer[256];
  ASM_tree *p_node;
  ASM_tree *p_node2;
  IGRdouble value;

  *msg = MSSUCC;
  trace(printf("in EMbom_locate_update\n"));

  if(!EMbom_form)
   {
     return(OM_S_SUCCESS);
   }

  if((num_parts > 1) && ((EMbom_mode == BOM_ACTIVE) ||
     (EMbom_mode == BOM_EDIT)))
   {
     FIg_set_text(EMbom_form, FI_MSG_FIELD, "Select single part");
     return(OM_S_SUCCESS);
   }

  for(i =0; i < num_parts; i++)
   {
      p_node = NULL;
      EMbom_find_node_by_id(&partids[i],&p_node);
      if(!p_node)
       continue;

      if(p_node->depth > EMbom_display_depth)
       {
         if(EMbom_mode & BOM_FIRSTLEVEL)
          {
            FIg_set_text(EMbom_form, FI_MSG_FIELD, 
			   "Nested part cannot be selected");
            return(OM_S_SUCCESS);
          }
        else
          {
            value = (IGRdouble)p_node->depth;
            FIg_set_value(EMbom_form, NEST_LEVEL,value);
            EMbom_display(); 
          }
       }

      EMbom_find_row_by_node(p_node, &row);
      col = 4;

      FIfld_set_select (EMbom_form, PART_DISPLAY, row, 1, sel);

#ifdef ET_TU_ASSEMBLY

            FIfld_get_text(EMbom_form, BOM, row, 4, 256, buffer, &sel, &pos);

            switch (EMbom_mode)
            {
            case BOM_ACTIVE:
                if (!strcmp(buffer, "yes"))
                {
                    FIfld_set_text(EMbom_form, BOM, row, 4, "yes", FALSE);
                }
                else
                {
                    om_msg = om$send (msg = message EMdescribe.EMget_type 
                                                                      (msg,
                                                                       &type),
                                      senderid = NULL_OBJID,
                                      targetid = p_node->part_id.objid,
                                      targetos = p_node->part_id.osnum);

                    if ((om_msg & *msg & 1) && 
                        (type & 
                         (EM_LOCAL_PART | EM_FILE_PART | EM_REFERENCE_PART)))
                    {
                        EMbom_find_active_node(&active_row, &p_node2,BOM_ACTIVE);
                        
                        if (p_node2)
                        {
                           p_node2->new_state &= ~BOM_ACTIVE;

                            if (active_row != -1)
                            {
                                FIfld_set_text(EMbom_form, 
                                               BOM, 
                                               active_row, 
                                               4, 
                                               "no", 
                                               FALSE);
                            }
                        }

                        p_node->new_state |= BOM_ACTIVE;
                        FIfld_set_text(EMbom_form, BOM, row, 4, "yes", FALSE);
                    }
                    else
                    {
                        FIfld_set_text (EMbom_form, 
                                        MESSAGE, 
                                        0, 0, 
                                        "Only local parts can be made active.",
                                        FALSE);

                    }
                }
                break;

            case BOM_EDIT:
                om_msg = EMshow_bom_edit(msg,p_node);
                EMbom_selected_node = p_node;
                break;

            case BOM_CONSTRAINT:
                if (!strcmp(buffer, "yes"))
                {
                    FIfld_set_text(EMbom_form, BOM, row, 4, "yes", FALSE);
                }
                else
                {
                    om_msg = om$send (msg = message EMdescribe.EMget_type 
                                                                      (msg,
                                                                       &type),
                                      senderid = NULL_OBJID,
                                      targetid = p_node->part_id.objid,
                                      targetos = p_node->part_id.osnum);

                    if ((om_msg & *msg & 1) && 
                        (type & 
                         (EM_LOCAL_PART | EM_REFERENCE_PART)))
                    {
                        EMbom_find_active_node(&active_row, &p_node2, BOM_CONSTRAINT);
                        
                        if (p_node2)
                        {
                            p_node2->new_state &= ~BOM_CONSTRAINT;

                            if (active_row != -1)
                            {
                                FIfld_set_text(EMbom_form, 
                                               BOM, 
                                               active_row, 
                                               4, 
                                               "no", 
                                               FALSE);
                            }
                        }

                        p_node->new_state |= BOM_CONSTRAINT;
                        FIfld_set_text(EMbom_form, BOM, row, 4, "yes", FALSE);
                    }
		}

                om_msg = EMbom_show_constraints(p_node);
                EMbom_selected_node = p_node;
                break;

            case BOM_DISPLAY:
            case BOM_BACKGROUND:
            case BOM_WRITE:
            case BOM_HIGHLIGHT:
            case BOM_DELETE:
            case BOM_SETDISPLAY:
            case BOM_EVENT:
                
                if (!strcmp(buffer, "yes"))
                {
                    FIfld_set_text(EMbom_form, BOM, row, 4, "no", FALSE);
                    p_node->new_state &= ~EMbom_mode;
                    strcpy(buffer,"no");
                    if(col != 4)
                      EMbom_nested_select(&row,buffer);
                }
                else
                  if(!strcmp(buffer, "no"))
                   {
                      FIfld_set_text(EMbom_form, BOM, row, 4, "yes", FALSE);
                      p_node->new_state |= EMbom_mode;
                      strcpy(buffer,"yes");
                      if(col != 4)
                        EMbom_nested_select(&row,buffer);
                   }

                break;
            }
            
            for (j=0; j<5; ++j)
            {
                FIfld_set_select (EMbom_form, BOM, row, j, FALSE);
            }
#endif

    }

  return(OM_S_SUCCESS);

}

IGRlong EMmanage_assembly (IGRlong * msg)
{
    IGRlong om_msg = OM_S_SUCCESS, FImsg = FI_SUCCESS;
    IGRint  displayed = FALSE;
    IGRdouble value;
    extern void EMPrt_notify();
    
    *msg = ASM_S_SUCCESS;
    
    if (EMbom_form == NULL)
    {
        FImsg = FIf_new (BOM_FORM,
                         "EMMngFlPrts", 
                         EMPrt_notify,
                         &EMbom_form);
        
        if ((FImsg != FI_SUCCESS) || (EMbom_form == NULL))
        {
            *msg = ASM_E_ABORT;
            goto quit;
        }
    }

    FIf_is_displayed(EMbom_form, &displayed);
    
    if (!displayed)
    {
        FIf_display (EMbom_form);
        FIg_erase (EMbom_form, NEST_LEVEL);
        value = (IGRdouble)EMbom_max_depth();
        FIg_set_high_value (EMbom_form, NEST_LEVEL, value);
//        value = (IGRdouble)EMbom_display_depth;
        FIg_set_value (EMbom_form, NEST_LEVEL, value);
        FIg_activate (EMbom_form, NEST_LEVEL);
        FIg_display (EMbom_form, NEST_LEVEL);
        EMbom_display();
        EMshow_mode();  
    }


 quit:
    
    return om_msg;
}

IGRlong EMupdate_asm_display(IGRlong *msg)
{
  IGRlong om_msg = OM_S_SUCCESS;
  ASM_tree *tree_ptr;
  struct GRmd_env part_env;

  *msg = ASM_S_SUCCESS;
  tree_ptr = assembly_tree;

  while(tree_ptr)
   {
      if(tree_ptr->props & EM_REFERENCE_PART)
       {
	 om_msg = EMget_part_mdenv(msg, &tree_ptr->part_id, &part_env);
	 if(om_msg & *msg & 1)
	  {
	    om_msg = asm$update_part_display(msg = msg,
					     part_id = &tree_ptr->part_id,
					     mod_env = &part_env);
            if(!(om_msg & *msg & 1))
	      goto quit;
	  }
       }
      tree_ptr = tree_ptr->next;
   }

quit:
   return om_msg;
}

void EMCnstr_notify(form_label, label, value, form_ptr )
  int     form_label;       /* The label of the form   */
  int     label;       /* The label of the gadget */
  double  value;         /* The value of the gadget */
  Form    form_ptr;            /* Pointer to the form     */ 
{
   ASM_tree *p_node;
   IGRlong om_msg,msg;
   IGRint row,col,state,type,is_on,i;
   struct GRid cnstrid, att_prt;
   struct GRmd_env mod_env;
   enum GRdpmode mode;
   IGRdouble offset;
   IGRchar buffer[256], buff[256], name[256];

   p_node = s_node;

   switch (label)
   {
     case CONSTR_LIST:	
        FIfld_get_active_row( form_ptr, CONSTR_LIST, &row, &state );
        FImcf_get_active_col( form_ptr, CONSTR_LIST, &col, &state );

       	dp$erase_hilite( msg = &msg );

        asm$get_constraint( msg = &msg,
                                part_id = &p_node->part_id,
                                index = row,
                                in_out = &state,
				type = &type,
                                cnstrid = &cnstrid );
        /* 
        * If col = 0, highlight the picked constraint's features
        * if col = 1, highlight the part, constraint is applied to.
        */
	is_on = -1;
        if( col == 0 )
        {
           FIfld_get_select( form_ptr, CONSTR_LIST, row, 0, &is_on );
           if( is_on == 1 )
             mode = GRhd;            
           else
             mode = GRhe;            

           if( type != GROUND )
           {
              EMHighlight_Cnstr( &msg, &cnstrid, mode );
              if( type == MATE )
		 FIg_enable( form_ptr, CONSTR_VAL );
              else
              {
        	 FIg_set_text( form_ptr, CONSTR_VAL, "" );
                 FIg_disable( form_ptr, CONSTR_VAL );
                 break;
              }
           }
           else
           {
              EMget_part_mdenv (&msg, &p_node->part_id, &mod_env);
              EMhighlight_obj( &p_node->part_id, &mod_env, mode );
              FIg_disable( form_ptr, CONSTR_VAL );
              FIfld_set_text( form_ptr, CONSTR_VAL, 0, 0, "", 0 );
              break;
           }
           /*
            *  Update the constraint offset gadget
            */
           om_msg = asm$get_cnstr_exp_info( msg = &msg,
					cnstrid = &cnstrid,
					exp_value = &offset );
           if( om_msg & msg & 1 )
           {
              sprintf( buffer, "%.2f", offset );
              FIfld_set_text( form_ptr, CONSTR_VAL, 0, 0, buffer, 0 );
           }
        }
        else if( col == 1 )
        {
           FIfld_get_select( form_ptr, CONSTR_LIST, row, 1, &is_on );
           if( is_on == 1 )
              mode = GRhd;            
           else
              mode = GRhe;            

           if(type == GROUND)
           {
              EMget_part_mdenv (&msg, &p_node->part_id, &mod_env);
              EMhighlight_obj( &p_node->part_id, &mod_env, mode );
              break;
           }

           if( state == 1 ) 
           {
               om_msg = asm$get_paired_parts( msg = &msg,
                                              cnstrid = &cnstrid,
                                              p2_id = &att_prt );
           }
           else if( state == 0 )
           {
               om_msg = asm$get_paired_parts( msg = &msg,
                                              cnstrid = &cnstrid,
                                              p1_id = &att_prt );
           }
           EMget_part_mdenv (&msg, &att_prt, &mod_env);
           EMhighlight_obj( &att_prt, &mod_env, mode );
        }

        break;

        case CONSTR_VAL:
               /*
                * Update the constraint value of the active constraint selected.
                */
                FIfld_get_num_rows( form_ptr, CONSTR_LIST, &row );
                for( i = 0; i < row; i++ )
                {
                    state = -1;
                    FIfld_get_select( form_ptr, CONSTR_LIST, i, 0, &state );
                    if( state == 1 )
                        break;
                }
                if( i != row ) /* Got a selected constraint */
                {
                    asm$get_constraint( msg = &msg,
                                    part_id = &p_node->part_id,
                                    index = i,
                                    in_out = &state,
                                    cnstrid = &cnstrid );

	            asm$get_cnstr_exp_info( msg = &msg,
		            		cnstrid = &cnstrid,
			        	exp_value = &offset );

	            FIfld_get_text( form_ptr, CONSTR_VAL, 0, 0, 256,
						 buffer, &col, &state );

                    om_msg = asm$set_constraint_value( msg = &msg,
                                               cnstrid = &cnstrid,
			        	       exp_syntax = buffer );
                    if( !(om_msg & msg & 1) )
                    {
                        sprintf( buff, "Failed to set offset=%s", buffer );
                        FIfld_set_text( form_ptr, MESSAGE, 0, 0, buff, 0 );
	                sprintf( buffer, "%.2f", offset );
        	        FIfld_set_text( form_ptr, CONSTR_VAL, 0, 0, buffer, 0 );
                    }
                    else
                    {
			dp$erase_hilite( msg = &msg );
                        /*
                         * Update the batch queue if necessary.
                         */
                        nd$mod_batch (request = ND_INQ, p_ret_mode = &state);
        
                        if (state == ND_IMMEDIATE)
                        {
                            nd$exec_batch ();
                        }
                    }
                }
                else
                {
                    FIfld_set_text( form_ptr, MESSAGE, 0, 0, "Select a Constraint", 0 );
                }
                break;        

            case DEL_BUTTON:
                /* Remove the selected constraint and update list */
                FIfld_get_num_rows( form_ptr, CONSTR_LIST, &row );
                for( i = 0; i < row; i++ )
                {
                    state = -1;
                    FImcf_get_select( form_ptr, CONSTR_LIST, i, &state );
                    if(state == 1)
                        break;
                }
                if( i == row )
                {
                    FIfld_set_text( form_ptr, MESSAGE, 0, 0, "Select a Constraint", 0 );
                    break;
                }
      	        /* Unhilight the plane */
        	{
		    dp$erase_hilite( msg = &msg );
                }
		
                /* get the constraint to be removed */
                om_msg = asm$get_constraint( msg = &msg,
                                        part_id = &p_node->part_id,
                                        index = i,
                                        in_out = &col,
                                        cnstrid = &cnstrid );

                om_msg = asm$rem_constraint( msg = &msg,
                                             constraint_id = &cnstrid );

       	        nd$mod_batch (request = ND_INQ, p_ret_mode = &state);
                /*
                 * Update the batch queue if necessary.
                 */
                if (state == ND_IMMEDIATE)
                {
                    nd$exec_batch ();
                }
                om_msg = EMbom_show_constraints( p_node );
		break;

	    case DOF_BUTTON:
                /* 
                 * Show the Degrees of Freedom on the selected part.
                 */
	        init_dof_display();

    	        om_msg = show_dof_part( &msg, &p_node->part_id, GRhd );

                if( !(om_msg & msg & 1 ))
                    printf("showdofpart failed\n");

                break;

            case ACCEPT:
            case EXIT:
                FIf_erase (form_ptr);
                FIf_delete (form_ptr);
                EMconstr_form = NULL;
                EMbom_selected_node = NULL;
                break;
	}
}

void EMPrt_notify ( f_label, g_label, value, fp )
  int     f_label;       /* The label of the form   */
  int     g_label;       /* The label of the gadget */
  double  value;         /* The value of the gadget */
  Form    fp;            /* Pointer to the form     */
{
  int  status;
  static char *text;
  static int text_size = 0;
  IGRlong msg;
  struct IGRdisplay rfdisp;
  IGRshort flag;
  IGRmatrix matrix;
  short mtx_type;
  struct GRid cur_mod;
  enum GRdpmode mode;

  char *strptr;
  static node_selected = FALSE;
  static struct GRid rfhead;
  char rfname[1024];
  int depth = 0;
  IGRboolean aflag;
  IGRchar       cmd_str[20];
  IGRint        response_type;
  IGRlong       nbytes;
  IGRshort rfprops;

  EMmemb memb;

  status = ex$get_cur_mod(id = &cur_mod.objid,
                          osnum = &cur_mod.osnum );
  mtx_type = MAIDMX;
  MAidmx ( &msg, matrix );

  aflag = pwIsActivationOn();

  switch ( g_label )
  {
    case NEST_LEVEL:  
        EMbom_display ();
        break;

    case PART_DISPLAY:  

         status = dp$erase_hilite(msg = &msg);

         /* Get the text string */
         status = Get_text ( fp, g_label, & text, & text_size );

         EMbom_find_node_by_row ((int)value, &s_node);

         node_selected = TRUE;

         strptr = text;
         while(*strptr++ == ' ')
         {
           depth++;
         }
         strptr--;
         strcpy(rfname,strptr);

         if (depth > 1)
         {
            FIg_disable(EMbom_form, ACTIVATE);
            FIg_disable(EMbom_form, SAVE);
            FIg_disable(EMbom_form, PART_LOCATE);
            FIg_disable(EMbom_form, HIDE_SHOW);
            FIg_disable(EMbom_form, HILITE);
            rfhead.objid = NULL_OBJID;
         }
         else
           if (depth == 0)
           {
              FIg_disable(EMbom_form, ACTIVATE);
              FIg_disable(EMbom_form, HILITE);
              FIg_disable(EMbom_form, PART_LOCATE);
              FIg_disable(EMbom_form, HIDE_SHOW);
              rfhead.objid = NULL_OBJID;
           }
           else
           {
             om$send (msg = message EMdescribe.EMget_memb
                                                 (&msg,
                                                  "reffile",
                                                  EM_GRAPHIC,
                                                  0,
                                                  &memb),
                      senderid = NULL_OBJID,
                      targetid = s_node->part_id.objid,
                      targetos = s_node->part_id.osnum);

             if(msg & 1 )
	         {
                rfhead.objid = memb.id.objid;
                rfhead.osnum = memb.id.osnum;
                om$send(msg = message GRgraphics.GRgetprops(&msg, &rfprops),
                        senderid = NULL_OBJID,
                        targetid = rfhead.objid,
                        targetos = rfhead.osnum);

                if (rfprops & GRIS_DISPLAYABLE)
                {
                  FIg_enable(EMbom_form, HILITE);
	              FIg_enable(EMbom_form, SAVE);
                  if (aflag)
	                FIg_disable(EMbom_form, ACTIVATE);
                  else
	                FIg_enable(EMbom_form, ACTIVATE);
	              FIg_enable(EMbom_form, DISPLAY_CONSTRAINTS);
                  FIg_enable(EMbom_form, PART_LOCATE);
                }
                else
                {
                  FIg_disable(EMbom_form, HILITE);
	              FIg_disable(EMbom_form, SAVE);
	              FIg_disable(EMbom_form, ACTIVATE);
	              FIg_disable(EMbom_form, DISPLAY_CONSTRAINTS);
                  FIg_disable(EMbom_form, PART_LOCATE);
                }
                FIg_enable(EMbom_form, HIDE_SHOW);
             }
           }

           break;

    case HILITE:

         if (rfhead.objid != NULL_OBJID)
	     {
            status = dp$erase_hilite(msg = &msg);

		    mode = GRhd;
		    om$send(msg = message GRgraphics.GRdisplay(&msg,&mtx_type,
						     matrix , &mode,
						     &cur_mod ),
		            senderid = NULL_OBJID,
			        targetid = rfhead.objid,
			        targetos = rfhead.osnum);
	     }
         break;

    case HIDE_SHOW:
         
         if (rfhead.objid != NULL_OBJID)
         {
            om$send(msg = message GRgraphics.GRgetprops(&msg, &rfprops),
                    senderid = NULL_OBJID,
                    targetid = rfhead.objid,
                    targetos = rfhead.osnum); 

            if (rfprops & GRIS_DISPLAYABLE)
            {
		      mode = GRbe;
		      om$send(msg = message GRgraphics.GRdisplay(&msg,&mtx_type,
						     matrix , &mode,
						     &cur_mod ),
		              senderid = NULL_OBJID,
			          targetid = rfhead.objid,
			          targetos = rfhead.osnum);

              flag = 0;
              rfprops = GRIS_DISPLAYABLE;

		      om$send(msg = message GRgraphics.GRchgprops(&msg,&flag,
                                                             &rfprops),
		              senderid = NULL_OBJID,
			          targetid = rfhead.objid,
			          targetos = rfhead.osnum);

              FIg_disable(EMbom_form, HILITE);
	          FIg_disable(EMbom_form, SAVE);
	          FIg_disable(EMbom_form, ACTIVATE);
	          FIg_disable(EMbom_form, DISPLAY_CONSTRAINTS);
	          FIg_disable(EMbom_form, PART_LOCATE);
            }
            else
            {
              flag = 1;
              rfprops = GRIS_DISPLAYABLE;

		      om$send(msg = message GRgraphics.GRchgprops(&msg,&flag,
                                                             &rfprops),
		              senderid = NULL_OBJID,
			          targetid = rfhead.objid,
			          targetos = rfhead.osnum);

		      mode = GRbd;
		      om$send(msg = message GRgraphics.GRdisplay(&msg,&mtx_type,
						     matrix , &mode,
						     &cur_mod ),
		              senderid = NULL_OBJID,
			          targetid = rfhead.objid,
			          targetos = rfhead.osnum);

              FIg_enable(EMbom_form, HILITE);
	          FIg_enable(EMbom_form, SAVE);
              if (aflag)
	            FIg_disable(EMbom_form, ACTIVATE);
              else
	            FIg_enable(EMbom_form, ACTIVATE);
	          FIg_enable(EMbom_form, DISPLAY_CONSTRAINTS);
	          FIg_enable(EMbom_form, PART_LOCATE);
            }
         }
         break;

    case PART_LOCATE:
 
         EMsetbom_locate();
         strcpy(cmd_str,"manage assembly");
         response_type = CMD_STRING;
         nbytes = strlen(cmd_str) + 1;

         ex$putque(msg = &msg,
                   response = &response_type,
                   byte = &nbytes,
                   buffer = cmd_str);
         break;

    case FI_CANCEL:

         /* Intentional fall thru' */

    case FI_ACCEPT:

         /* Erase the displayed form */
         status = dp$erase_hilite(msg = &msg);
         FIf_erase ( fp );
         FIf_delete (fp);
         EMbom_form = NULL;
         break;

    case ACTIVATE:     

         if (node_selected && rfhead.objid != NULL_OBJID)
         {
	       FIg_disable(EMbom_form, ACTIVATE);

           status = dp$erase_hilite(msg = &msg);
           UpdateActParams(rfhead);

           /** get the ref. files symbology and the update the form **/
           gr$get_active_display(buffer = &rfdisp);
           gr$put_active_display(buffer = &rfdisp);
           gr$get_active_layer(buffer = &rfdisp);
           gr$put_active_layer(buffer = &rfdisp);
         }

         break;

    case SAVE:     

         if (rfhead.objid != NULL_OBJID)
         {
            IGRint entry_num;
            GRspacenum osn;
            om$send(msg = message GRreffile.GRgetosnum(&msg, &osn),
                    senderid = NULL_OBJID,
                    targetid = rfhead.objid,
                    targetos = rfhead.osnum);
            status = ex$is_invis ( mod_osnum = osn,index = &entry_num);
            if (status)
            {
              ex$save_module(index = entry_num);
            }
         }
         break;

    case DISPLAY_CONSTRAINTS:     
         if (node_selected)
         {
            EMbom_show_constraints(s_node);
         }
         break;
  }

  if (text)
  {
     free(text);
     text=NULL;
     text_size =0;
  }
} 

static int Get_text ( fp, g_label, text, text_size )
       Form    fp;            /* Pointer to the form     */
       int     g_label;       /* The label of the gadget */
       char ** text;          /* The text contained in the field */
       int   * text_size;     /* The space allocated for the text */
{
    int status;
    int text_len;
    int field_type;
    int select_flag;
    int row = 0;
    int col = 0;
    int pos = 0;

    FIg_get_type ( fp, g_label, &field_type );

    if ( field_type == FI_MULTI_COL )
    {
        /* Get the col for the MCF */

        FImcf_get_active_col ( fp, g_label, &col, &pos );

    }

    /* Get the row for the field or MCF */

    FIfld_get_active_row ( fp, g_label, &row, &pos );
    FIfld_get_text_length ( fp, g_label, row, col, &text_len );

    /* Increment text_len because of NULL */

    text_len++;

    if ( * text_size < text_len )
    {
        if ( * text_size > 0 )
        {
           /* Realloc space for larger string */
           * text = realloc ( * text, text_len );
        }
        else
        {
           /* Calloc space for string */
           * text = calloc ( 1, text_len );
        }
        * text_size = text_len;
    }

    if ( ! * text )
    {
      * text_size = 0;
      return ( FI_NO_MEMORY );
    }

    status = FIfld_get_text ( fp, g_label, row, col, * text_size,
                            * text, &select_flag, &pos );
    return ( status );
}

end implementation EMpart;
