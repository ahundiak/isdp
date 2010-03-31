/*---------------------------------------------------------------------------+
 |									     |
 |  Abstract 								     |
 |                                                                           |
 |     This file contains functions for creating the revise assembly tree.   |
 |									     |
 |  Description								     |
 |									     |
 |     The revise assembly tree structure is defined in assem.h.             |
 | 									     |
 |  History				                                     |
 |    									     |
 |     Gang   06/02/94   Creation.                                           |
 |     dkk    06/27/94   Modified                                            |
 | 									     |
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
#include "nddef.h"
#include "ndmacros.h"
#include "grgsdef.h"
#include "grgsmacros.h"
#include "coparadef.h"
#include "coparamac.h"
#include "madef.h"

#include "assemdef.h"
#include "assem.h"
#include "assemmacros.h"

#include "asmrevdef.h"
#include "revasmipc.h"

#define Null ((char *)NULL)
#define LINE_LEN 255

#ifdef TRACE
#define trace(x) x
#else
#define trace(x) 
#endif

from GRreffile import GRgetosnum, GRgetenvironment;
from EMinstance import EMget_part; 

void EMprint_revasm_tree(REVASM_TREE *asm_tree)
{
IGRint  i;
IGRchar indent[120];
REVASM_TREE *tree_ptr;

    tree_ptr = asm_tree;

    while(tree_ptr)
    {
        for(i=0; i < tree_ptr->info.depth; i++)
            indent[i] = ' ';

        indent[i] = 0;

        tree_ptr = tree_ptr->next;
    }
}

#argsused
IGRint EMbuild_revasm_tree (IGRlong          * msg,
		             IGRint            num,
                             IGRint            depth,
                             struct GRinquire_list *requests,
		             REVASM_TREE      *asm_tree)
{
IGRint              i;
IGRint              om_msg = OM_S_SUCCESS;
IGRchar             filename[LINE_LEN];
IGRchar             intosname[OM_K_MAXINTOSNAME_LEN];
struct GRid         *ref_id, part_id, inst_id;
OMuword             ref_osnum;
IGRboolean          skip_node, file_found = FALSE;
REVASM_TREE         *ptr_tree,*tree_end,*parent;
EMattr              attribute;
OM_S_CHANSELECT     chandef;
OMuint              count;
OMuword             classid;
unsigned short      props = 0;
    
    *msg = ASM_S_SUCCESS;
    ptr_tree = NULL;
    tree_end = NULL;
    parent = NULL;
    ref_id = NULL;
    skip_node = FALSE;
    part_id.objid = NULL_OBJID;
    inst_id.objid = NULL_OBJID;
    depth++;

    if (requests)
    {
        for (i=0; requests[i].var != END_REPORT_REQUEST; ++i)
        {
            switch (requests[i].var)
            {
                case REFERENCE_FILE_NAME :
                    strncpy(filename,requests[i].var_ptr,LINE_LEN);
                    break;
           
                case REFERENCE_ID :
                    ref_id = (struct GRid *)requests[i].var_ptr;
                    break;

                case REFERENCE_FILE_FOUND:
    		    file_found = *((IGRboolean *)requests[i].var_ptr);
		    break;

                case FILE_PROPERTIES:
    		    props = *((unsigned short *)requests[i].var_ptr);
		    break;
            }
        }
    }
    else
        return(OM_S_SUCCESS);

    if (file_found)
    {
        /* get the internal osname of the reference file */
        om_msg = om$send(msg = message GRreffile.GRgetosnum(msg, &ref_osnum),
		      senderid = NULL_OBJID,
		      targetid = ref_id->objid,
		      targetos = ref_id->osnum);
        if(om_msg & *msg & 1) 
        {
	    om_msg = om$os_number_to_internal_name(osnum = ref_osnum,
				      osname = intosname);
            if(!(om_msg & 1))
	        return(OM_S_SUCCESS);
        }
        else
    	     return(OM_S_SUCCESS);

        if(asm_tree)
        {
            ptr_tree = asm_tree;

            while(ptr_tree)
    	    {
	        tree_end = ptr_tree;
	        ptr_tree = ptr_tree->next;
	    }
        }

        if(tree_end)
        {
            if(tree_end->info.depth < depth)
                parent = tree_end;
            else if(tree_end->info.depth == depth)
                parent = tree_end->parent;
            else if(tree_end->info.depth > depth)
            {
                while(tree_end->info.depth != depth)
                    tree_end = tree_end->parent;

                parent = tree_end->parent;
            }

            if(parent)
            {
	        ptr_tree = parent->child;

    	        while(ptr_tree)
    	        {
	            if(!(strcmp(intosname,ptr_tree->info.intosname)))
		    {
		        skip_node = TRUE;
		        break;
                    }
                    ptr_tree = ptr_tree->sibling;
                }
            }
        }

        if(skip_node)
            return(OM_I_STOP_SENDING);
    }

    /* get the part from the reference file */
    GRget_to_owner_info(&chandef,ref_id->osnum, ref_id->objid,&count);

    if(count > 0)
    {
        om_msg = om$get_objid_at_index(osnum = ref_id->osnum,
				      objid = ref_id->objid,
				      p_chanselect = &chandef,
				      index = 0,
				      objidaddr = &inst_id.objid,
				      osnumaddr = &inst_id.osnum);
        if(om_msg & 1)
	{
	    om_msg = om$get_classid(objid = inst_id.objid,
				  osnum = inst_id.osnum,
				  p_classid = &classid);
	    if(om_msg & 1)
	    {
	        if((om$is_ancestry_valid(subclassid = classid,
				      superclassname = "EMinstance")))
                {
		    om_msg = om$send(msg = message EMinstance.EMget_part(msg,
					     		     &part_id),
                         senderid = NULL_OBJID,
			 targetid = inst_id.objid,
			 targetos = inst_id.osnum);
	        }
	    }
	}
    }

    if(asm_tree)
    {
        ptr_tree = asm_tree;

        while(ptr_tree)
        {
            tree_end = ptr_tree;
            ptr_tree = ptr_tree->next;
        }

        ptr_tree = tree_end;
        ptr_tree->next = (REVASM_TREE *)calloc(1, sizeof(REVASM_TREE));
        ptr_tree = ptr_tree->next;
    }
    else
    {
        asm_tree = (REVASM_TREE *)calloc(1, sizeof(REVASM_TREE));
        ptr_tree = asm_tree;
    }

    ptr_tree->info.o_part.number[0]=NULL;
    ptr_tree->info.o_part.revision[0]=NULL;
    ptr_tree->info.o_part.description[0]=NULL;

    strcpy(ptr_tree->info.intosname,intosname);
    strcpy(ptr_tree->info.o_part.filename,filename);

    if(file_found && (part_id.objid == NULL_OBJID))
    {
    /* Try to get the default part definition from the file */
    struct GRmd_env env_path, env;

        part_id.objid = NULL_OBJID;
        om_msg = om$send(msg = message GRreffile.GRgetenvironment(msg,
                                                    &env_path, &env ),
                         senderid = NULL_OBJID,
			 targetid = ref_id->objid,
			 targetos = ref_id->osnum);

        if( om_msg & *msg & 1 )                
        {
            om_msg = asm$get_file_part( msg = msg,
                                        mod_env = &env,
                                        part_id = &part_id);
        }
    }
    if(part_id.objid != NULL_OBJID)
    {
        if(om_msg & *msg & 1)
	{
	    om_msg = asm$get_attribute(msg = msg,
				      id = &part_id,
				      name = "number",
				      attribute = &attribute);
            if(om_msg & *msg & 1)
                strcpy(ptr_tree->info.o_part.number,attribute.value.data.s);

	    om_msg = asm$get_attribute(msg = msg,
				     id = &part_id,
				     name = "revision",
				     attribute = &attribute);
            if(om_msg & *msg & 1)
                strcpy(ptr_tree->info.o_part.revision,attribute.value.data.s);

	    om_msg = asm$get_attribute(msg = msg,
				     id = &part_id,
				     name = "description",
				     attribute = &attribute);
            if(om_msg & *msg & 1)
                strcpy(ptr_tree->info.o_part.description,attribute.value.data.s);
        }
    }

    ptr_tree->info.depth = depth;
    ptr_tree->info.op_type = 0;

    if(part_id.objid == NULL_OBJID) 
        ptr_tree->info.op_type = UpdateOperation;

    if((!file_found) && (!(props & GRRF_BACKGROUND)))
        ptr_tree->info.op_type = Reference_file_not_found;

    ptr_tree->next = NULL;
    ptr_tree->child = NULL;
    ptr_tree->sibling = NULL;

    /* connect the parent, child and siblings */
    if(tree_end)
    {
        if(tree_end->info.depth < ptr_tree->info.depth)
        {
            tree_end->child = ptr_tree;
            ptr_tree->parent = tree_end;
        }     
        else if(tree_end->info.depth == ptr_tree->info.depth)
        {
            tree_end->sibling = ptr_tree;
            ptr_tree->parent = tree_end->parent;
        }
        else if(tree_end->info.depth > ptr_tree->info.depth)
        {
            while(tree_end->info.depth != ptr_tree->info.depth)
            {
                tree_end = tree_end->parent;
            }
            tree_end->sibling = ptr_tree;
            ptr_tree->parent = tree_end->parent;
        }
    }

    return OM_S_SUCCESS;
}


IGRlong EMrevasm_free_tree(REVASM_TREE *tree)
{
IGRlong  om_msg = OM_S_SUCCESS;
REVASM_TREE *tmp_tree1, *tmp_tree2;

  tmp_tree1 = tree;

  while(tmp_tree1)
  {
      tmp_tree2 = tmp_tree1->next;
      free(tmp_tree1);
      tmp_tree1 = tmp_tree2;
     
  }

   return om_msg;
}


IGRint EMgenerate_revasm_tree(IGRlong *msg,
			      struct GRmd_env *mod_env,
			      REVASM_TREE **tree_head)
{
IGRint	          	sts, found = 0;
struct GRmd_env         cur_mod;
struct GRreport_info    revasm_info;
struct GRid             part_id;
IGRchar                 intosname[OM_K_MAXINTOSNAME_LEN];
EMattr                  number,revision,description;
REVASM_TREE		*asm_tree = NULL;

    sts = OM_S_SUCCESS;
    *msg = MSSUCC;

    if(mod_env)
    {
	cur_mod = *mod_env;
    }
    else
    {
        sts = gr$get_module_env(msg = msg,
                                buffer = &cur_mod);
        if(!(*msg & sts & 1))
        {
            goto quit;
        }
    }

    if(!(asm_tree))
    {
        asm_tree = (REVASM_TREE *)calloc(1,sizeof(REVASM_TREE));
        if(!(asm_tree))
	{
	  goto quit;
        }
    }
    (asm_tree)->info.op_type = 0;
    (asm_tree)->next = NULL;
    (asm_tree)->child = NULL;
    (asm_tree)->parent = NULL;
    (asm_tree)->sibling = NULL;

    sts = om$os_number_to_name(osnum = cur_mod.md_id.osnum,
   		               osname = (asm_tree)->info.o_part.filename);

    sts = om$os_number_to_internal_name(osnum = cur_mod.md_id.osnum,
   		                        osname = intosname);
    if(!(sts & 1))
    {
	goto quit;
    }

    strcpy((asm_tree)->info.intosname,intosname);
    
    sts = asm$get_file_part(msg = msg,
			    mod_env = &cur_mod,
			    part_id = &part_id);
    if(sts & *msg & 1)
    {
        sts =  asm$get_part_identity(msg = msg,
				 part_id = &part_id,
				 number = &number,
				 revision = &revision,
				 description = &description);
        if(sts & *msg & 1)
        {
            found = 1;
            strcpy((asm_tree)->info.o_part.number,number.value.syntax);
            strcpy((asm_tree)->info.o_part.revision,revision.value.syntax);
            strcpy((asm_tree)->info.o_part.description,description.value.syntax);
        }
    }

    if( !found )
    {
       (asm_tree)->info.o_part.number[0] = NULL;
       (asm_tree)->info.o_part.revision[0] = NULL;
       (asm_tree)->info.o_part.description[0] = NULL;
    }

    revasm_info.output_func = EMbuild_revasm_tree;
    revasm_info.info = (IGRchar *)(asm_tree);

    sts = GRreffile_reports ( msg,
                              &cur_mod,
                              GR_reference_file_name |
			      GR_reference_id | 
			      GR_file_properties | 
			      GR_reference_file_found,
                              &revasm_info,
                              TRUE );

    /* A bug in GRrefile_reports, always returns MSFAIL */
    *msg = MSSUCC;
    sts = 1;

    *tree_head = asm_tree;

quit:
  return (sts);
}


end implementation EMpart;
