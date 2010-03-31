/*---------------------------------------------------------------------------+
 |									                                         |
 | Abstract:								                                 |
 |									                                         |
 |     This file containts the functions for creating and manipulating the   |
 |     global assembly tree  and utility functions. 			             |
 |									                                         |
 | Description:								                                 |
 |									                                         |
 |     The assembly tree structure is defined in assem.h                     |
 |									                                         |
 | History :								                                 |
 |									                                         |
 |     Gang   02/04/94   Creation.					                         |
 |     bbkr   04/12/96   Modified the input matrix and matrix type for       |
 |                       GRfindcontext to get the correct context_id         |
 |                       TR#119603821.                                       | 
 |              						                                     |
 +---------------------------------------------------------------------------*/

class implementation EMpart;

#include "grimport.h"
#include "OMindex.h"
#include "OMprimitives.h"
#include "OMminimum.h"
#include "OMmacros.h"
#include "OMlimits.h"
#include "DIprims.h"
#include "grownerdef.h"
#include "grerr.h"
#include "gocmacros.h"
#include "msmacros.h"
#include "grmessage.h"
#include "ex.h"
#include "igrdp.h"
#include "igr.h"
#include "dpdef.h"
#include "dp.h"
#include "dpmacros.h"
#include "go.h"
#include "griodef.h"
#include "grio.h"
#include "griomacros.h"
#include "grdpbdef.h"
#include "grdpbmacros.h"
#include "refdef.h"
#include "ref.h"
#include "exmacros.h"
#include "csdef.h"
#include "grcoordsys.h"
#include "nddef.h"
#include "ndmacros.h"
#include "grgsdef.h"
#include "grgsmacros.h"
#include "coparadef.h"
#include "coparamac.h"
#include "madef.h"
#include "msdef.h"

#include "assemdef.h"
#include "assem.h"
#include "assemmacros.h"

extern OMuword OPP_EMpart_class_id;
extern OMuword OPP_EMinstance_class_id;
extern OMuword OPP_GRreffile_class_id;

from GRvg  import GRgetsymb;
from GRcontext import GRgetmodule_env;
from GRreffile import GRinquireref, GRgetenvironment, GRgetosnum;
from EMlocalpart import EMget_layers;


typedef struct EMbom_pass_info
{
    struct GRmd_env mod_env;
    ASM_tree        *assembly_tree;
} EMbom_pass_info;


#define Null ((char *)NULL)

#ifdef TRACE
#define trace(x) x
#else
#define trace(x) 
#endif

%safe
ASM_tree      *assembly_tree = NULL;
IGRint      EMbom_display_depth = 1;
%endsafe


/*** start prototypes ***/

IGRlong EMbuild_tree (IGRlong         * msg,
                      struct GRmd_env * mod_env,
                      IGRint            depth,
                      IGRchar         * info,
                      struct GRid     * desc_id);

IGRlong EMadd_to_tree(IGRlong *msg,
                      struct GRid *part_id);

IGRlong EMadd_local_to_tree(IGRlong *msg,
                            struct GRid *local_part);

IGRlong EMdelete_from_tree(IGRlong *msg,
                           struct GRid *part_id);

IGRlong EMbuild_sub_tree(IGRlong *msg,
                         struct GRid *part_id,
                         ASM_tree **sub_tree);

IGRlong EMfree_tree(IGRlong *msg,
                    ASM_tree *tree);

IGRlong EMget_first_level_part(IGRlong *msg,
                               struct GRid *part_id,
                               struct GRid *cntxt_id,
                               struct GRid *top_part);

IGRlong EMget_part_mdenv(IGRlong *msg,
                         struct GRid *part_id,
                         struct GRmd_env *mod_env);

IGRlong EMbom_find_row_by_node(ASM_tree *node,
			       IGRint *row);

IGRlong EMbom_find_node_by_row(IGRint row,
			       ASM_tree **node);

IGRlong EMbom_find_node_by_id(struct GRid *id,
			      ASM_tree **node);

IGRlong EMbom_find_active_node(IGRint *row,
			       ASM_tree **node, short type);

IGRboolean EMbom_cyclic_node(IGRint depth,
			     struct GRid *part_id,
			     ASM_tree *asm_tree,
			     struct GRmd_env *part_env);

/*** end prototypes ***/



IGRboolean EMbom_cyclic_node(IGRint depth,
			     struct GRid *part_id,
			     ASM_tree *asm_tree,
			     struct GRmd_env *part_env)
{
  IGRlong om_msg, msg = ASM_S_SUCCESS;
  IGRint  type = 0;
  ASM_tree  *ptr_tree, *tree_end, *parent_node;
  EMmemb memb;
  IGRint which_error;
  IGRboolean pass = FALSE;
  struct GRinquire_list requestes[2];
  IGRchar filename[DI_PATH_MAX];

  tree_end = parent_node = NULL;

  if(!part_id)
   {
      return FALSE;
   }
  om_msg = om$send (msg = message EMdescribe.EMget_type (&msg, &type),
                    senderid = NULL_OBJID,
                    targetid = part_id->objid,
                    targetos = part_id->osnum);
  if(!(om_msg & msg & 1) || !(type & EM_REFERENCE_PART))   
   {
      return FALSE;
   }

  ptr_tree = asm_tree;
  while(ptr_tree)
   {
      tree_end = ptr_tree;
      ptr_tree = ptr_tree->next;
   }

  if(tree_end)
   { 
     if(tree_end->depth < depth)
      {
        parent_node = tree_end;
      }     
     else
      if(tree_end->depth == depth)
       {
         parent_node = tree_end->parent;
       }
      else
       if(tree_end->depth > depth)
        {
          while(tree_end->depth != depth)
	   {
	     tree_end = tree_end->parent;
	     if(!tree_end)
	      goto quit;
	   }

          parent_node = tree_end->parent;
        }
   }
   om_msg = om$send(msg = message EMdescribe.EMget_memb
                                             ( &msg,
                                               NULL,
                                               EM_GRAPHIC,
                                               0,
                                               &memb),
                    senderid = NULL_OBJID,
                    targetid = part_id->objid,
                    targetos = part_id->osnum);
   if(msg & om_msg & 1)
    {
        requestes[0].var = REFERENCE_FILE_NAME;
        requestes[0].var_ptr = filename;
        requestes[0].num_requested = DI_PATH_MAX;

        requestes[1].var = END_REPORT_REQUEST;
        requestes[1].var_ptr = NULL;
        requestes[1].num_requested = 0;

        om_msg = om$send(msg=message GRreffile.GRinquireref
                                               (&msg,
                                                part_env,
                                                requestes,
                                                &which_error,
                                                &pass, NULL),
                         senderid = NULL_OBJID,
                         targetid = memb.id.objid,
                         targetos = memb.id.osnum);

        if(filename[0] != '/') 
         {
           IGRchar tmp_name[DI_PATH_MAX], buf[DI_PATH_MAX];

           EXgetcwd(tmp_name,DI_PATH_MAX);
           sprintf(buf,"%s/%s",
                   tmp_name,filename);
           strcpy(filename, buf );
         }
     }

  while(parent_node)
   {
     if(!strcmp(parent_node->filename,filename))
      {
	  return TRUE;
      }

     parent_node = parent_node->parent;
   }

  if(asm_tree)
   {
     if(!(asm_tree->props & EM_FILE_PART))
      {
	if(assembly_tree)
	 {
	    if(!strcmp(assembly_tree->filename, filename))
	     return TRUE;
	 }
      }
   }

quit:
  return FALSE;
}

#argsused
IGRboolean EMbom_select (struct GRmd_env * mod_env,
                         IGRint            depth,
                         IGRchar         * info,
                         struct GRid     * desc_id)
{
    IGRlong      om_msg, msg = ASM_S_SUCCESS;
    IGRboolean   select = TRUE;
    IGRint       type = 0;

    trace(printf("in EMbom_select\n"));
    
    om_msg = om$send (msg = message EMdescribe.EMget_type (&msg, &type),
                      senderid = NULL_OBJID,
                      targetid = desc_id->objid,
                      targetos = desc_id->osnum);
    
    if (!(om_msg & msg & 1) ||
        !(type & (EM_LOCAL_PART | EM_FILE_PART | EM_CACHED_PART |
		  EM_REFERENCE_PART)))
    {
        select = FALSE;
    }

    return select;
}



IGRlong EMbuild_tree (IGRlong         * msg,
                      struct GRmd_env * mod_env,
                      IGRint            depth,
                      IGRchar         * info,
                      struct GRid     * desc_id)
{
    IGRlong             om_msg = OM_S_SUCCESS;
    EMbom_pass_info   * bom_info = (EMbom_pass_info *)info;
    IGRuint             props;
    struct GRmd_env     part_env;
    ASM_tree          * ptr_tree, *tree_end, *tree_ptr;
    
    *msg = ASM_S_SUCCESS;
    ptr_tree = NULL;
    tree_end = NULL;

    if(mod_env)
     {
       part_env = *mod_env;
     }
    else
     {
       gr$get_module_env(buffer = &part_env);
     }
    trace(printf(" in EMbuild_tree\n"));
    
    om_msg = om$send (msg = message EMdescribe.EMget_props (msg, &props),
                      senderid = NULL_OBJID,
                      targetid = desc_id->objid,
                      targetos = desc_id->osnum);
    
    if (!(om_msg & *msg & 1))
    {
        goto quit;
    }

    /*
     * If this is a file part which is not in the master file,
     * don't add it to the list since the instance which represents
     * it will be added to the list.
     */
    if (props & EM_FILE_PART)
    {
        if (desc_id->osnum != EX_active_OS_num)
          goto quit;

        if(bom_info->assembly_tree)
	 {
	    goto quit;
         }
    }
    
    /* skip the background parts */

    if((props & EM_BACKGROUND) &&
       (desc_id->osnum != EX_active_OS_num))
     {
	om_msg = OM_I_STOP_SENDING;
	*msg = ASM_E_ABORT;
	goto quit;
     }

    if(bom_info->assembly_tree)
     {
       ptr_tree = bom_info->assembly_tree;

       while(ptr_tree)
         {
            tree_end = ptr_tree;
            ptr_tree = ptr_tree->next;
         }

       ptr_tree = tree_end;
       ptr_tree->next = (ASM_tree *)calloc(1, sizeof(ASM_tree));
       ptr_tree = ptr_tree->next;
     }
    else
     {
       bom_info->assembly_tree = (ASM_tree *)calloc(1, sizeof(ASM_tree));
       ptr_tree = bom_info->assembly_tree;
     }

    
    ptr_tree->part_id.objid = desc_id->objid;
    ptr_tree->part_id.osnum = desc_id->osnum;
    ptr_tree->props = props;
    ptr_tree->depth = depth;
    ptr_tree->next = NULL;
    ptr_tree->child = NULL;
    ptr_tree->sibling = NULL;
    ptr_tree->old_state = ((EM_IS_DESCRIBE_ACTIVE(props) && 
                          (desc_id->osnum == bom_info->mod_env.md_id.osnum)) ?
                                             BOM_ACTIVE : 0) |
                          (EM_IS_GRAPHIC_DISPLAYED(props) ?
                                             BOM_DISPLAY : 0) |
                          (EM_IS_BACKGROUND(props) ?
                                             BOM_BACKGROUND : 0) |
                          (EM_IS_READONLY(props) ?
                                             0 : BOM_WRITE) ;

    if(ptr_tree->props & EM_REFERENCE_PART)
     {
       EMmemb memb;
       IGRint which_error;
       IGRboolean pass = FALSE;
       struct GRinquire_list requestes[2];

         om_msg = om$send(msg = message EMdescribe.EMget_memb
                                                   ( msg,
                                                     NULL,
                                                     EM_GRAPHIC,
                                                     0,
                                                     &memb),
                          senderid = NULL_OBJID,
                          targetid = desc_id->objid,
                          targetos = desc_id->osnum);
         if(*msg & om_msg & 1)
          {
             requestes[0].var = REFERENCE_FILE_NAME;
             requestes[0].var_ptr = ptr_tree->filename;
             requestes[0].num_requested = DI_PATH_MAX;

             requestes[1].var = END_REPORT_REQUEST;
             requestes[1].var_ptr = NULL;
             requestes[1].num_requested = 0;

             om_msg = om$send(msg=message GRreffile.GRinquireref
                                                    (msg,
                                                     &part_env,
                                                     requestes,
                                                     &which_error,
                                                     &pass, NULL),
                              senderid = NULL_OBJID,
                              targetid = memb.id.objid,
                              targetos = memb.id.osnum);

             if(ptr_tree->filename[0] != '/') 
              {
                IGRchar tmp_name[DI_PATH_MAX], buf[DI_PATH_MAX];

                EXgetcwd(tmp_name,DI_PATH_MAX);
                sprintf(buf,"%s/%s",
                        tmp_name,ptr_tree->filename);
                strcpy(ptr_tree->filename, buf);
              }
          }
         else
          {
            ptr_tree->filename[0] = NULL;
          }

     }
    else
     if(props & EM_FILE_PART)
      {
	ex$filename( name= ptr_tree->filename,       
	             len= DI_PATH_MAX);
      }
     else
      {
        ptr_tree->filename[0] = NULL;
	
      }

     if(ptr_tree->props & EM_LOCAL_PART)
      {
	ptr_tree->old_state &=  ~(BOM_EVENT | BOM_WRITE | BOM_BACKGROUND) ;
				  
      }

     ptr_tree->new_state = ptr_tree->old_state;

     /* connect the parent, child and siblings */

     if(tree_end)
      {
        if(tree_end->depth < ptr_tree->depth)
         {
            tree_end->child = ptr_tree;
            ptr_tree->parent = tree_end;
         }     
        else
         if(tree_end->depth == ptr_tree->depth)
          {
            tree_end->sibling = ptr_tree;
            ptr_tree->parent = tree_end->parent;
          }
         else
          if(tree_end->depth > ptr_tree->depth)
           {
              while(tree_end->depth != ptr_tree->depth)
                {
                  tree_end = tree_end->parent;
                }

              tree_end->sibling = ptr_tree;
              ptr_tree->parent = tree_end->parent;
           }
      }

    /* Added the following code for filling in the context id  10/08/94 */
    ptr_tree->cntxt_id.objid = NULL_OBJID;

    if(ptr_tree->props & EM_REFERENCE_PART)
    {
    EMmemb memb;
    struct GRmd_env tmp_mdenv, ref_mdenv;
    struct GRid refid;
    int finished = FALSE;
    OMuword ref_osnum;

        om_msg = om$send(msg = message EMdescribe.EMget_memb
                                            ( msg,
                                              NULL,
                                              EM_GRAPHIC,
                                              0,
                                              &memb),
                          senderid = NULL_OBJID,
                          targetid = desc_id->objid,
                          targetos = desc_id->osnum);

        if(*msg & om_msg & 1)
        {
            tmp_mdenv.md_id.objid = NULL_OBJID;
            tmp_mdenv.md_id.osnum = desc_id->osnum;
            tmp_mdenv.md_env.matrix_type = MAIDMX;
            MAidmx(msg,tmp_mdenv.md_env.matrix);
            refid = memb.id;

            om_msg = om$send(msg = message GRreffile.GRgetenvironment(msg,
								 &tmp_mdenv,
								 &ref_mdenv),
                        senderid = NULL_OBJID,
			targetid = memb.id.objid,
			targetos = memb.id.osnum);

            if(*msg & om_msg & 1)
                tmp_mdenv = ref_mdenv;
        }

        tree_ptr = ptr_tree->parent;
	if(tree_ptr)
	{
            if(tree_ptr->props & EM_LOCAL_PART)
                tree_ptr = tree_ptr->parent;
            if((tree_ptr) && (tree_ptr->props & EM_FILE_PART))
                tree_ptr = NULL;
        }

        if(tree_ptr)
        {
            while(!finished)
            {
                om_msg = om$send(msg = message EMdescribe.EMget_memb
                                                  ( msg,
                                                    NULL,
                                                    EM_GRAPHIC,
                                                    0,
                                                    &memb),
                         senderid = NULL_OBJID,
                         targetid = tree_ptr->part_id.objid,
                         targetos = tree_ptr->part_id.osnum);

                if(*msg & om_msg & 1)
                {
                  int i;
                 IGRshort four = 4;
                 IGRmatrix refmatrix,invmatrix,tmpmatrix;
                 IGRboolean Value;
 
                 for(i=0; i < 16 ; i++)
                  tmpmatrix[i] = tmp_mdenv.md_env.matrix[i];
 
                 Value = MAinvmx(msg,&four,tmpmatrix,invmatrix);
#ifdef DEBUG 
                 if( Value != TRUE )
                  printf("Matrix is singular, no inverse\n");
#endif

                 om_msg = om$send(msg = message GRreffile.GRgetenvironment(
                                                                msg,
				                                				&tmp_mdenv,
								                                &ref_mdenv),
                                  senderid = NULL_OBJID,
	            		          targetid = memb.id.objid,
			                      targetos = memb.id.osnum);

                 if(*msg & om_msg & 1)
                   tmp_mdenv = ref_mdenv;
              
                 /* Fix for TR#119603821 */

                 MAmulmx(msg,&four,&four,&four,invmatrix,
                         ref_mdenv.md_env.matrix, refmatrix);
 
                 MAmulmx(msg,&four,&four,&four,refmatrix,tmpmatrix,
                         tmp_mdenv.md_env.matrix);
 
                 MAtypemx(msg,tmp_mdenv.md_env.matrix,
                          &tmp_mdenv.md_env.matrix_type);

                }

                tree_ptr = tree_ptr->parent;
	        if(tree_ptr)
                {
	            if(tree_ptr->props & EM_LOCAL_PART)
	                tree_ptr = tree_ptr->parent;
    	            if(tree_ptr) 
                    {
                        if(tree_ptr->props & EM_FILE_PART)
	                    finished = TRUE;
                    }
                    else 
                        finished = TRUE;
                }
                else finished = TRUE;
            }
        }

        /* From the computed environment matrix, obtain the context id
           within the master file os */

        om_msg = om$send(msg = message GRreffile.GRgetosnum(msg, &ref_osnum),
		      senderid = NULL_OBJID,
		      targetid = refid.objid,
		      targetos = refid.osnum);

	if ( om_msg & *msg & 1 )
	{
            om_msg = GRfindcontext(msg,
                               &(tmp_mdenv.md_env.matrix_type),
                               tmp_mdenv.md_env.matrix,
                               &ref_osnum,
                               &ptr_tree->cntxt_id);

	    if( !(om_msg & *msg & 1))
	    {
	        om_msg = OM_S_SUCCESS;
                *msg = ASM_S_SUCCESS;
            }
        }
    }

    if(EMbom_cyclic_node(depth,desc_id,bom_info->assembly_tree,&part_env))
     {
       om_msg = OM_I_STOP_SENDING; 
       *msg = ASM_E_ABORT;
       goto quit;
     }

 quit:
    
    return om_msg;
}

IGRlong EMadd_to_tree(IGRlong *msg,
                      struct GRid *part_id)
{
  IGRlong          om_msg = OM_S_SUCCESS;
  IGRlong          msg1;
  IGRuint          props;
  IGRshort         part_found;
  struct GRmd_env  mod_env;
  struct GRid      lp_id;
  ASM_tree         *sub_tree, *tree_ptr, *tree_end;

    lp_id.objid = NULL_OBJID;
    /* get the active module environment */
    gr$get_module_env(buffer = &mod_env);

    /* don't add if the part is not in the master space */

    if(part_id->osnum != mod_env.md_id.osnum)
     {
        goto quit;
     }


    om_msg = om$send (msg = message EMdescribe.EMget_props (msg, &props),
                      senderid = NULL_OBJID,
                      targetid = part_id->objid,
                      targetos = part_id->osnum);

    if(om_msg & *msg & 1)
     {
        if(props & EM_REFERENCE_PART)
         {
            om_msg = EMbuild_sub_tree(msg, part_id, &sub_tree);

            if(!(*msg & om_msg & 1))
             {
               goto quit;
             }
            
            EMget_localpart_frm_grid(&msg1,part_id,&mod_env,&lp_id);

            if(lp_id.objid == NULL_OBJID)
             {
                tree_ptr = assembly_tree;
                tree_end = NULL;

                while(tree_ptr)
                 {
                    tree_end = tree_ptr;
                    tree_ptr = tree_ptr->next;
                 }


                if(tree_end)
	         {
                   tree_end->next = sub_tree;
		   if(tree_end->depth < sub_tree->depth)
		    {
		       tree_end->child = sub_tree;
		       sub_tree->parent = tree_end;
		    }     
		   else
		     if(tree_end->depth == sub_tree->depth)
		      {
		        tree_end->sibling = sub_tree;
		        sub_tree->parent = tree_end->parent;
		      }
		     else
		      if(tree_end->depth > sub_tree->depth)
		       {
		         while(tree_end->depth != sub_tree->depth)
			   {
			      tree_end = tree_end->parent;
			   }

		         tree_end->sibling = sub_tree;
		         sub_tree->parent = tree_end->parent;
		       }
	         }
             }
            else
             {
                part_found = FALSE;
                /* find the local part node in the tree */
                tree_ptr = assembly_tree->child; 
                while(tree_ptr)
                 {
                    if((tree_ptr->part_id.objid == lp_id.objid) &&
                       (tree_ptr->part_id.osnum == lp_id.osnum))
                     {
                         part_found = TRUE;
                         break;
                     }

                    tree_ptr = tree_ptr->sibling;
                 }
                
                if(!part_found)
                 {
                   EMfree_tree(msg, sub_tree);
                   goto quit;
                 }
                else
                 {
                   ASM_tree *tmp_tree1, *tmp_tree2;

                   if(!tree_ptr->child)
                    {
                       tmp_tree1 = tree_ptr->next;

                       tree_ptr->child = sub_tree;
                       sub_tree->parent = tree_ptr;
                       tree_ptr->next = sub_tree;

                       tmp_tree2 = sub_tree;
                       while(tmp_tree2)
                         {
                            sub_tree = tmp_tree2;
                            tmp_tree2 = tmp_tree2->next;
                             
                         }

                       sub_tree->next = tmp_tree1;
                    }
                   else
                    {
                       tmp_tree1 = tree_ptr->child; 
                       while(tmp_tree1)
                        {
                           tree_ptr = tmp_tree1;
                           tmp_tree1 = tmp_tree1->sibling;
                        }

                       tree_ptr->sibling = sub_tree;
                       sub_tree->parent = tree_ptr->parent; 

                       if(!tree_ptr->child )
                        {
                           tmp_tree1 = tree_ptr->next;
                           tree_ptr->next = sub_tree;

                           tmp_tree2 = sub_tree;
                           while(tmp_tree2)
                            {
                               sub_tree = tmp_tree2;
                               tmp_tree2 = tmp_tree2->next;
                            }
                           sub_tree->next = tmp_tree1;
                        }
                       else
                        {
                           tmp_tree2 = tree_ptr->next;
                           while(tmp_tree2->depth < sub_tree->depth)
                              {
                                 tree_ptr = tmp_tree2;
                                 tmp_tree2 = tmp_tree2->next; 
                              }
                           tmp_tree1 = tree_ptr->next;
                           tree_ptr->next = sub_tree;

                           tmp_tree2 = sub_tree;
                           while(tmp_tree2)
                            {
                               sub_tree = tmp_tree2;
                               tmp_tree2 = tmp_tree2->next;
                            }
                           sub_tree->next = tmp_tree1;
                        } 
                    }
                   
                 }
             }
         }
        else
         if(props & EM_LOCAL_PART)
          {
            om_msg = EMadd_local_to_tree(msg, part_id);
          }
         else
          {
            goto quit;
          }
     }

 quit:

   return om_msg;
}


IGRlong EMadd_local_to_tree(IGRlong *msg,
                            struct GRid *local_part)
{
  IGRlong  om_msg = OM_S_SUCCESS;
  IGRint   part_count, instance_count,i ,j;
  ASM_tree *sub_tree, *tree_ptr, *tree_end;
  struct GRmd_env   mod_env;
  struct GRsymbology    symb;
  struct GRid  part_id, instance_id;
  IGRlong      layers[32];

   /* get the active module environment */

   gr$get_module_env(buffer = &mod_env);

   if(local_part->osnum != mod_env.md_id.osnum)
    {
       goto quit;
    }

    om_msg = EMbuild_sub_tree(msg, local_part, &sub_tree);

    if(!(*msg & om_msg & 1))
     {
       goto quit;
     }

    tree_ptr =  assembly_tree;

     if(!tree_ptr->child)
      {
        tree_ptr->next = sub_tree;
        tree_ptr->child = sub_tree;
        sub_tree->parent = tree_ptr;

        goto quit;
      }
            
    /*
     * Get any instances that fall on my levels.
     */
    om_msg = asm$part_count (msg = msg,
                             mod_env = &mod_env,
                             type = EM_CACHED_PART,
                             count = &part_count);

    if (!(om_msg & *msg & 1))
    {
        goto quit;
    }

    /* get the layers of the local part */

    om_msg = om$send(msg = message EMlocalpart.EMget_layers(msg,
                                                            layers,
                                                            NULL,
                                                            NULL),
                     senderid = NULL_OBJID,
                     targetid = local_part->objid,
                     targetos = local_part->osnum); 
    if(!(om_msg & *msg & 1))
     {
        goto quit;
     }

    /*
     * For all the parts.
     */
    for (i=0; i<part_count; ++i)
    {
        /*
         * Get the part.
         */
        om_msg = asm$get_part (msg = msg,
                               mod_env = &mod_env,
                               type = EM_CACHED_PART,
                               index = i,
                               part_id = &part_id);

        if (!(om_msg & *msg & 1))
        {
            continue;
        }

        /*
         * Get the instances of this part.
         */
        om_msg = asm$instance_count (msg = msg,
                                     part_id = &part_id,
                                     count = &instance_count);

        if (!(om_msg & *msg & 1))
        {
            EMfree_tree(msg, sub_tree);
            goto quit;
        }

        for (j=0; j<instance_count; ++j)
        {
            om_msg = asm$get_instance (msg = msg,
                                       part_id = &part_id,
                                       index = j,
                                       instance_id = &instance_id);

            if (!(om_msg & *msg & 1))
            {
                continue;
            }

            om_msg = om$send (msg = message GRvg.GRgetsymb (msg, &symb),
                              senderid = NULL_OBJID,
                              targetid = instance_id.objid,
                              targetos = instance_id.osnum);

            if (!(om_msg & *msg & 1))
            {
                EMfree_tree(msg, sub_tree);
                goto quit;
            }

            /*
             * If this instance falls on this my layers ...
             */
            if (EMlayer_in_layers (symb.level, layers))
            {
                om_msg = EMdelete_from_tree(msg, &instance_id);
            }
        }  
     }

   tree_ptr = assembly_tree;
   tree_end = NULL;

   while(tree_ptr)
    {
      tree_end = tree_ptr;
      tree_ptr = tree_ptr->next;
    }


  if(tree_end)
   {
     tree_end->next = sub_tree;
     if(tree_end->depth < sub_tree->depth)
      {
         tree_end->child = sub_tree;
	 sub_tree->parent = tree_end;
      }     
     else
       if(tree_end->depth == sub_tree->depth)
        {
           tree_end->sibling = sub_tree;
	   sub_tree->parent = tree_end->parent;
	}
       else
        if(tree_end->depth > sub_tree->depth)
         {
           while(tree_end->depth != sub_tree->depth)
	     {
	       tree_end = tree_end->parent;
	     }

	   tree_end->sibling = sub_tree;
	   sub_tree->parent = tree_end->parent;
        }
  }

 quit:

   return om_msg;
}


IGRlong EMdelete_from_tree(IGRlong *msg,
                           struct GRid *part_id)
{
  IGRlong   om_msg  = OM_S_SUCCESS;
  ASM_tree  *ptr1, *ptr2, *ptr3;
  IGRshort  part_found = FALSE;
  IGRint    depth;

  *msg = ASM_S_SUCCESS;
  /* parts that are in the active assembly can only be deleted */

  if(part_id->osnum != EX_active_OS_num)
   {
      om_msg = OM_E_ABORT;
      goto quit;
   }

  ptr1 = assembly_tree->child;
  ptr2 = assembly_tree;
  ptr3 = NULL;

  while(ptr1)
    {
       if((ptr1->part_id.objid == part_id->objid) &&
          (ptr1->part_id.osnum == part_id->osnum))
        {
          part_found = TRUE;
          break;
        } 

       if(ptr1->props & EM_LOCAL_PART)
        {
          ptr2 = ptr1;
          ptr3 = ptr1->child;
          while(ptr3)
            {
                if((ptr3->part_id.objid == part_id->objid) &&
                   (ptr3->part_id.osnum == part_id->osnum))
                 {
                    ptr1 = ptr3;
                    part_found = TRUE;
                    break;
                 }        
                ptr2 = ptr3;
                ptr3 = ptr3->sibling;
            }
        }

       if(part_found)
        {
           break;
        }
       ptr2 = ptr1;
       ptr1 = ptr1->sibling;
    }

   if(part_found)
    {
      ASM_tree  *ptr4, *ptr5;

      ptr4 = ptr2;
      while(ptr4->next != ptr1)
        {
           ptr4 = ptr4->next;
        }
      if(ptr1->parent == ptr2)
       {
          ptr2->child = ptr1->sibling;
       }
      else
       {
          ptr2->sibling = ptr1->sibling;
       }

      depth = ptr1->depth;

      ptr5 = ptr1->next;
      free(ptr1);
   
      if(ptr5)
       {
          while(ptr5->depth > depth)
           {
             ptr1 = ptr5->next;
             free(ptr5);
             ptr5 = ptr1;
	     if(!ptr5)
	      break;
           }
       }

      ptr4->next = ptr5;
    }


 quit:

   return om_msg;
}


IGRlong EMfree_tree(IGRlong *msg,
                    ASM_tree *tree)
{
  IGRlong  om_msg = OM_S_SUCCESS;
  ASM_tree *tmp_tree1, *tmp_tree2;

  *msg = ASM_S_SUCCESS;
  tmp_tree1 = tree;

  while(tmp_tree1)
   {
      tmp_tree2 = tmp_tree1->next;
      free(tmp_tree1);
      tmp_tree1 = tmp_tree2;
     
   }

   return om_msg;
}

IGRlong EMbuild_sub_tree(IGRlong *msg,
                         struct GRid *part_id,
                         ASM_tree **sub_tree)
{
  IGRlong om_msg = OM_S_SUCCESS;
  EMbom_pass_info  bom_info;
  IGRuint          props;
  struct GRsymbology  symb;
  IGRint           depth;
  struct GRid      file_part;
  IGRlong          layers[32];

   /* get the active module environment */
   gr$get_module_env(buffer = &bom_info.mod_env);

   bom_info.assembly_tree = NULL;

   if(part_id->osnum != bom_info.mod_env.md_id.osnum)
    {
      goto quit;
    }

    /* get the file part */

    om_msg = asm$get_file_part(msg = msg,
                               mod_env = &bom_info.mod_env,
                               part_id = &file_part);
    if(!(om_msg & *msg & 1))
     {
        goto quit;
     } 

    om_msg = om$send (msg = message EMdescribe.EMget_props (msg, &props),
                      senderid = NULL_OBJID,
                      targetid = part_id->objid,
                      targetos = part_id->osnum);

    if(om_msg & *msg & 1)
     {
        if(props & EM_REFERENCE_PART)
         {
            /* get the symbology */
            om_msg = om$send (msg = message GRvg.GRgetsymb (msg, &symb),
                              senderid = NULL_OBJID,
                              targetid = part_id->objid,
                              targetos = part_id->osnum);
            if(!(om_msg & *msg & 1))
             {
                goto quit;
             }

            /* get the layers of the file part */

            om_msg = om$send(msg = message EMlocalpart.EMget_layers(msg,
                                                                    layers,
                                                                    NULL,
                                                                    NULL),
                             senderid = NULL_OBJID,
                             targetid = file_part.objid,
                             targetos = file_part.osnum); 
            if(!(om_msg & *msg & 1))
             {
                goto quit;
             }

            if(EMlayer_in_layers(symb.level,layers))
             {
               depth = 1;
             }
            else
             {
               depth = 2;
             }
          }
         else
           if(props & EM_LOCAL_PART)
            {
              depth = 1;
            }
           else
            {
               om_msg = OM_E_ABORT;
               goto quit;
            }

        om_msg = om$send(msg = message EMdescribe.EMpass(msg,
                                                    &bom_info.mod_env,
                                                    depth,
                                                    EMbuild_tree,
                                                    (IGRchar *)(&bom_info),
                                                    EMbom_select),
                         senderid = NULL_OBJID,
                         targetid = part_id->objid,
                         targetos = part_id->osnum);

        *sub_tree = bom_info.assembly_tree;

      }

 quit:

   return om_msg;
}

IGRlong EMasmtree_generate()
{
  IGRlong  om_msg = OM_S_SUCCESS, msg = ASM_S_SUCCESS;
  struct GRid file_part;
  EMbom_pass_info  bom_info;
  
    bom_info.assembly_tree = NULL;

    /* get the active module environment */
    gr$get_module_env(buffer = &bom_info.mod_env);

    om_msg = asm$get_file_part (msg = &msg,
                                mod_env = &bom_info.mod_env,
                                part_id = &file_part);
    
    if (om_msg & msg & 1)
    {
       om_msg = om$send(msg = message EMdescribe.EMpass(&msg,
                                                        &bom_info.mod_env,
                                                        0,
                                                        EMbuild_tree,
                                                        (IGRchar *)(&bom_info),
                                                        EMbom_select),
                          senderid = NULL_OBJID,
                          targetid = file_part.objid,
                          targetos = file_part.osnum);
    }

    if(assembly_tree)
     EMfree_tree(&msg,assembly_tree);

    assembly_tree = bom_info.assembly_tree;

    return om_msg;

}



IGRlong EMget_first_level_part(IGRlong *msg,
                               struct GRid *part_id,
                               struct GRid *cntxt_id,
                               struct GRid *top_part)
{
  IGRlong om_msg = OM_S_SUCCESS;
  ASM_tree  *tree_ptr;

  *msg = ASM_S_SUCCESS;
  /* validate the input */

  if((part_id == NULL) || (top_part == NULL))
   {
      om_msg = OM_E_ABORT;
      *msg = ASM_E_ABORT;
      return om_msg;
   }

  if(part_id->osnum == EX_active_OS_num)
   {
      top_part->objid = part_id->objid;
      top_part->osnum = part_id->osnum;

      return(om_msg);
   }

  if( assembly_tree )
     tree_ptr = assembly_tree->next;
  else
  {
     EMasmtree_generate();
     tree_ptr = assembly_tree->next;
  }

  while(tree_ptr)
    {
       if((tree_ptr->part_id.objid == part_id->objid) &&
	  (tree_ptr->part_id.osnum == part_id->osnum))
        
        {
            if((cntxt_id->objid != NULL_OBJID) && 
               (tree_ptr->cntxt_id.objid != NULL_OBJID))
            {
                if((tree_ptr->cntxt_id.objid == cntxt_id->objid) &&
                   (tree_ptr->cntxt_id.osnum == cntxt_id->osnum))
                    break;
            }
            else
	        break;
	}

	tree_ptr = tree_ptr->next;
    }

  if(tree_ptr)
   {
      tree_ptr = tree_ptr->parent;
      while(tree_ptr)
	{
	    if((tree_ptr->part_id.osnum == EX_active_OS_num) &&
	       (tree_ptr->props & EM_REFERENCE_PART))
             {
		 top_part->objid = tree_ptr->part_id.objid;
		 top_part->osnum = tree_ptr->part_id.osnum;
		 break;
             }

	     tree_ptr = tree_ptr->parent;
	}
   }

   return(om_msg);
}


IGRlong EMget_part_mdenv(IGRlong *msg,
                         struct GRid *part_id,
                         struct GRmd_env *mod_env)
{
  IGRlong  om_msg = OM_S_SUCCESS;
  IGRint i;
  ASM_tree *tree_ptr;
  IGRshort finished;
  struct GRmd_env tmp_mdenv, ref_mdenv;
  EMmemb memb;

  /* validate the input */
  if(part_id == NULL || mod_env == NULL)
   {
     *msg   = ASM_E_ABORT;
     om_msg = OM_E_ABORT;
     goto quit;
   }

  *msg = ASM_S_SUCCESS;
  if(part_id->osnum == EX_active_OS_num)
   {
      gr$get_module_env(buffer = mod_env);
      *msg = ASM_S_SUCCESS;
      goto quit;
   }
  tree_ptr = assembly_tree->next;

  while(tree_ptr)
    {
       if((tree_ptr->part_id.objid == part_id->objid) &&
	  (tree_ptr->part_id.osnum == part_id->osnum))
        {
	   break;
	}

       tree_ptr = tree_ptr->next;
    }
  
  tree_ptr = tree_ptr->parent;
  if(tree_ptr->props & EM_LOCAL_PART)
   {
      tree_ptr = tree_ptr->parent;
   }

  if(tree_ptr->props & EM_FILE_PART)
   {
      goto quit;
   }

  om_msg = om$send(msg = message EMdescribe.EMget_memb
                                            ( msg,
                                              NULL,
                                              EM_GRAPHIC,
                                              0,
                                              &memb),
                   senderid = NULL_OBJID,
                   targetid = part_id->objid,
                   targetos = part_id->osnum);
  if(*msg & om_msg & 1)
   {
       tmp_mdenv.md_id.objid = NULL_OBJID;
       tmp_mdenv.md_id.osnum = part_id->osnum;
       tmp_mdenv.md_env.matrix_type = MAIDMX;
       MAidmx(msg,tmp_mdenv.md_env.matrix);

       om_msg = om$send(msg = message GRreffile.GRgetenvironment(msg,
								 &tmp_mdenv,
								 &ref_mdenv),
                        senderid = NULL_OBJID,
			targetid = memb.id.objid,
			targetos = memb.id.osnum);
       if(*msg & om_msg & 1)
	{
	   mod_env->md_id.objid = ref_mdenv.md_id.objid;
	   mod_env->md_id.osnum = ref_mdenv.md_id.osnum;

	   mod_env->md_env.matrix_type = ref_mdenv.md_env.matrix_type;
	   for(i=0; i < 16; i++)
	     {
		mod_env->md_env.matrix[i] = ref_mdenv.md_env.matrix[i];
	     }
	}
       else
	{
	  goto quit;
	}

   }
  else
   {
      goto quit;
   }

  tree_ptr = tree_ptr->parent;
  if(!tree_ptr)
   {
     goto quit;
   }

  if(tree_ptr->props & EM_LOCAL_PART)
   {
      tree_ptr = tree_ptr->parent;
   }

  if(!tree_ptr)
   {
     goto quit;
   }

  finished = FALSE;

  while(!finished)
    {
        om_msg = om$send(msg = message EMdescribe.EMget_memb
                                                  ( msg,
                                                    NULL,
                                                    EM_GRAPHIC,
                                                    0,
                                                    &memb),
                         senderid = NULL_OBJID,
                         targetid = tree_ptr->part_id.objid,
                         targetos = tree_ptr->part_id.osnum);
        if(*msg & om_msg & 1)
         {

            om_msg = om$send(msg = message GRreffile.GRgetenvironment(msg,
								 mod_env,
								 &ref_mdenv),
                        senderid = NULL_OBJID,
			targetid = memb.id.objid,
			targetos = memb.id.osnum);
            if(*msg & om_msg & 1)
	     {
               mod_env->md_env.matrix_type = ref_mdenv.md_env.matrix_type;
	       for(i=0; i < 16; i++)
		{
                  mod_env->md_env.matrix[i] = ref_mdenv.md_env.matrix[i];
		}
	     }
            else
	     {
		goto quit;
	     }
         }
        else
	 {
	    goto quit;
	 }

        tree_ptr = tree_ptr->parent;
	if(tree_ptr->props & EM_LOCAL_PART)
	 {
	    tree_ptr = tree_ptr->parent;
         }

	if(tree_ptr->props & EM_FILE_PART)
	 {
	   finished = TRUE;
         }
       
    }
  
quit:

    return(om_msg);

}

IGRint EMbom_max_depth()
{
  IGRint max_depth;
  ASM_tree *tree_ptr;

  max_depth = 1;

  if(assembly_tree)
   {
      tree_ptr = assembly_tree;

      while(tree_ptr)
       {
	  if(tree_ptr->depth > max_depth)
	     max_depth = tree_ptr->depth;

	  tree_ptr = tree_ptr->next;
       }
   }

  return(max_depth);
}

IGRlong EMbom_find_row_by_node(ASM_tree *node,
			       IGRint *row)
{
  IGRint j;
  ASM_tree *tree_ptr;

  j = 0;
  tree_ptr = assembly_tree;

  while(tree_ptr)
   {
      if((tree_ptr->part_id.objid == node->part_id.objid) &&
	 (tree_ptr->part_id.osnum == node->part_id.osnum))
        {
	   break;
	}

      if(tree_ptr->depth <= EMbom_display_depth)
       {
	  j++;
       }
      tree_ptr = tree_ptr->next;
   }

  *row = j;

  return(OM_S_SUCCESS);
}

IGRlong EMbom_find_node_by_row(IGRint row,
			       ASM_tree **node)
{
  IGRint j;
  ASM_tree *tree_ptr;

  j=0;
  tree_ptr = assembly_tree;

  while(tree_ptr)
   {
      if(tree_ptr->depth <= EMbom_display_depth)
       {
	  if(j++ == row)
	   {
	     break;
	   }
       }

      tree_ptr =  tree_ptr->next;
   }

  if(tree_ptr)
   {
     *node = tree_ptr;
   }
  else
   {
     *node = NULL;
   }

  return(OM_S_SUCCESS);
}

IGRlong EMbom_find_node_by_id(struct GRid *id,
			      ASM_tree **node)
{
  ASM_tree *tree_ptr;

  tree_ptr = assembly_tree;

  while(tree_ptr)
   {
     if((tree_ptr->part_id.objid == id->objid) &&
	(tree_ptr->part_id.osnum == id->osnum))
      {
	break;
      }
     tree_ptr = tree_ptr->next;
   }

  if(tree_ptr)
   {
     *node = tree_ptr;
   }
  else
   {
     *node = NULL;
   }

  return(OM_S_SUCCESS);
}

IGRlong EMbom_find_active_node(IGRint *row,
			       ASM_tree **node, IGRshort type)
{
  IGRint i;
  ASM_tree *tree_ptr;
 
  *row = -1;
  *node = NULL;
  i = 0;

  tree_ptr = assembly_tree;

  while(tree_ptr)
    {
       if(tree_ptr->new_state & type)
	{
	  *node = tree_ptr;

	  if(tree_ptr->depth <= EMbom_display_depth)
	   {
	     *row = i;
	   }

          break;
	}

	if(tree_ptr->depth <= EMbom_display_depth)
	 {
	   i++;
	 }

       tree_ptr = tree_ptr->next;
    }

  return(OM_S_SUCCESS);
}

IGRlong EMbom_set_display(IGRint *types)
{
  ASM_tree *tree_ptr, *tree_ptr2;
  IGRint  entry_types;
  IGRlong om_msg ,msg;
  IGRuint new_props;
  struct GRmd_env mod_env, part_mdenv;

  gr$get_module_env(buffer = &mod_env);
  tree_ptr =  assembly_tree;

  while(tree_ptr)
   {
	
       if ((tree_ptr->new_state & BOM_SETDISPLAY) !=
	    (tree_ptr->old_state & BOM_SETDISPLAY))
	{

	    entry_types = *types;
	    entry_types |= EM_IS_GRAPHIC_DISPLAYED(tree_ptr->props) ?
			   EM_GRAPHIC_DISPLAYED : 0;
    
	    entry_types |= EM_IS_HANDLE_DISPLAYED(tree_ptr->props) ?
			   EM_HANDLE_DISPLAYED : 0;
    
	    if(tree_ptr->part_id.osnum == mod_env.md_id.osnum)
	       part_mdenv = mod_env;
	    else
	       EMget_part_mdenv(&msg,&tree_ptr->part_id,&part_mdenv);

	    om_msg = asm$set_display_props (msg = &msg,
					    mod_env = &part_mdenv,
					    id = &tree_ptr->part_id,
					    display = &entry_types,
					    layers = NULL,
					    update = TRUE);

            tree_ptr2 = assembly_tree;
	    while(tree_ptr2)
	      {
		 if(!strcmp(tree_ptr->filename, tree_ptr2->filename))
		  {
                    new_props = entry_types |
                                (tree_ptr2->props & ~EM_DISPLAY_PROPS);
		    om_msg = om$send(msg = message EMdescribe.EMset_props
							  (&msg,
							   new_props),
				     senderid = NULL_OBJID,
				     targetid = tree_ptr2->part_id.objid,
				     targetos = tree_ptr2->part_id.osnum);
		    tree_ptr2->props = new_props;
		    tree_ptr2->new_state &= ~(BOM_EDIT | BOM_EVENT  | 
					  BOM_HIGHLIGHT | BOM_DELETE | 
					  BOM_SETDISPLAY);

		    tree_ptr2->old_state = tree_ptr2->new_state;
		  }
                 tree_ptr2 = tree_ptr2->next;
	      }
	}

	tree_ptr->new_state &= ~(BOM_EDIT | BOM_EVENT  | 
				BOM_HIGHLIGHT | BOM_DELETE | 
				BOM_SETDISPLAY);

	tree_ptr->old_state = tree_ptr->new_state;
	tree_ptr = tree_ptr->next;
    }

    return(OM_S_SUCCESS);
}

IGRlong EMprint_tree()
{
  IGRlong  om_msg = OM_S_SUCCESS;
  ASM_tree *ptr_tree;
  IGRint   i;
  IGRchar  indent[120];

  ptr_tree = assembly_tree->next;

   while(ptr_tree)
     {
       for(i=0; i < ptr_tree->depth; i++)
          indent[i] = ' '; 
       indent[i] = '\0';
       ptr_tree = ptr_tree->next;
     }

  return om_msg;

}


end implementation EMpart;
