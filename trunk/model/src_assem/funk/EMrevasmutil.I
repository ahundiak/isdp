/*
Name
        EMrevasmutil.I

Description
        This file contains functions used with the Revise Assembly command.
Notes

History
        dkk     07/21/94    creation
*/
class implementation EMpart;

#include <stdlib.h>
#include <stdio.h>

#include "grimport.h"
#include "OMindex.h"
#include "OMprimitives.h"
#include "OMminimum.h"
#include "OMmacros.h"
#include "OMlimits.h"
#include "DIprims.h"
#include "grmsg.h"
#ifndef NT
#include <unistd.h>
#include <dirent.h>
#include <sys/param.h>
#else
#define MAXPATHLEN _MAX_PATH
#include <direct.h>
#endif

#include <exdef.h>
#include <ex.h>
#include <expriv.h>
#include <exmacros.h>
#include "igrdp.h"
#include "igr.h"
#include "dpdef.h"
#include "dp.h"
#include "go.h"
#include "griodef.h"
#include "grio.h"
#include "grdpbdef.h"
#include "igetypedef.h"
#include "igrtypedef.h"
#include <gr.h>
#include <grdpbmacros.h>

#include "refdef.h"
#include "ref.h"
#include "asmrevdef.h"
#include "assemdef.h"
#include "assem.h"
#include "assemmacros.h"

#include "revasmipc.h"

#ifdef DEBUG
#define verbose(x) x
#else
#define verbose(x)
#endif

/*
        External data
*/

extern OMuword OPP_GRreffile_class_id;
extern struct EX_invisible_module *invisible_table;

from Super_rfmgr import GRget_channel_count, GRget_channel_objects;
from GRreffile   import GRinquireref, GRchgfilename;

/* 
 * Visit each node in the tree and update
 */
IGRint EMrevise_assembly ( IGRlong *rc,
                            REVASM_TREE *tree_ptr )
{
REVASM_TREE *p, *pnext;
int sts, fno, exmsg, count;
struct GRmd_env env;
char path[DI_PATH_MAX], *c, *osname;
char newfilename[DI_PATH_MAX], tmp_name[DI_PATH_MAX];
char empty_name[4];
struct GRid mod_id, id;
EMattr attrs[3];
IGRlong msg;
OM_S_CHANSELECT chandef;

    *rc = MSSUCC;
/*    ASMset_reading_partdata();*/

    p = tree_ptr;
    while(p)
    {
        if (!(p->info.op_type & NoOperation))
        {
            /*
             * Retrieve this node with EX_read_write  **without loading the
             * first level attachments**
             */
            ex$get_cur_mod(id = &mod_id.objid, osnum = &mod_id.osnum);
            DIstmocpy(path, "ref", p->info.n_part.filename, 0, mod_id.osnum);

	    fno = -1;       

	    verbose(printf("retrieving file %s\n", p->info.n_part.filename));

    	    sts = ex$retrieve_module( msg = &exmsg, ftype = EX_invisible,
                           filename = p->info.n_part.filename,
                           flag = EX_read_write, file_no = &fno,  
			   mount_name = path, mod_type = 2,
                           type = EX_ref,
                           fstat = EX_old_module );

            if (exmsg == EX_flag)
	    {
		/* File already open with different permission */
                verbose(printf("Cannot Update %s, attached read_only\n"));
                p = p->next;
                continue;
            }
    	    else if( exmsg == EX_succ )
	    {
                /*
                 * Get the module env of the attached node and get the
                 * part definition, and modify the part attributes. If no
                 * definition found, create one.
                 */

		sts = ex$get_invis_info_by_index ( index = fno,
					  mod_osnum = &env.md_id.osnum,	
					  mod_id = &env.md_id.objid );
		if( sts & 1 )
		{
		    sts = asm$get_file_part (msg = &msg,
		                          mod_env = &env,
                		          part_id = &id);
		    if( msg & 1 ) /* Found the filepart */
                    {
			verbose(printf("Modifying filepart definition\n"));

                        /* Modify the number, revision, description */
                        EMdesc_set_system_mode(TRUE);
                        sts = asm$get_attribute(msg = &msg,
                                                id = &id,
                                                name = "number",
                                                attribute = &attrs[0]);

                        strcpy(attrs[0].value.syntax, p->info.n_part.number);
                        sts = asm$mod_attribute(msg = &msg,
                                                id = &id,
                                                name = "number",
                                                attribute = &attrs[0]);

                        sts = asm$get_attribute(msg = &msg,
                                                id = &id,
                                                name = "revision",
                                                attribute = &attrs[1]);

                        strcpy(attrs[1].value.syntax, p->info.n_part.revision);
                        sts = asm$mod_attribute(msg = &msg,
                                                id = &id,
                                                name = "revision",
                                                attribute = &attrs[1]);

                        sts = asm$get_attribute(msg = &msg,
                                                id = &id,
                                                name = "description",
                                                attribute = &attrs[2]);

                        strcpy(attrs[2].value.syntax, p->info.n_part.description);
                        sts = asm$mod_attribute(msg = &msg,
                                                id = &id,
                                                name = "description",
                                                attribute = &attrs[2]);
                        EMdesc_set_system_mode(FALSE);
                    }
                    else  /* No filepart definition, create one */
                    {
			char   *tmpstr;

			verbose(printf("creating filepart definition\n"));

                        /* First, check if the file is writeable */
                        if( access(p->info.n_part.filename, W_OK) != 0 )
                        {
                            /* No write */
                            verbose(printf("No write access to %s, not updated\n",
                                                      p->info.n_part.filename));
                            p = p->next;
                            continue;
                        }

                        /* Create a file part definition in it */
                        attrs[0].info.type = EM_PART_ATTR;
                        attrs[0].value.type = EM_STRING;
                        strcpy(attrs[0].info.name, "description");
                        strcpy(attrs[0].info.desc, "Part Description");
                        strcpy(attrs[0].value.syntax, p->info.n_part.description);

                        attrs[1].info.type = EM_COMMON_ATTR;
                        attrs[1].value.type = EM_STRING;
                        strcpy(attrs[1].info.name, "itemno");
                        strcpy(attrs[1].info.desc, "Item Number");
                        strcpy(attrs[1].value.syntax, "1");

                        attrs[2].info.type = EM_INSTANCE_ATTR;
                        attrs[2].value.type = EM_INTEGER;
                        strcpy(attrs[2].info.name, "quantity");
                        strcpy(attrs[2].info.desc, "Quantity");
                        strcpy(attrs[2].value.syntax, "1");

                        if (p->info.n_part.number[0] == 0)
                        {
	                    tmpstr = strrchr(p->info.o_part.filename, '/' );
			    strcpy(p->info.n_part.number, tmpstr);
                        }
                        if (p->info.n_part.revision[0] == 0)
                            strcpy(p->info.n_part.revision, "1");

                        sts = asm$create_file_part( msg = &msg,
				 number = p->info.n_part.number,
				 revision = p->info.n_part.revision,
                                 mod_env = &env,
                                 num_attributes = 3,
				 part_id = &id,
                                 attributes = attrs );

                        if(!(sts & msg & 1))
	                {
                            verbose(printf("create filepart failed for %s\n",
                                                p->info.n_part.filename));
                            p = p->next;
                            continue;
                        }
                    }
		}
            }
            else
            {
                verbose(printf("Failed to attach %s\n", p->info.n_part.filename));
                p = p->next;
                continue;
            }

	    if (p->child)
            {
            int num_att, j;
            char *filenames, *file;
            OM_S_OBJID *att_ids;
            OMuword *att_oss;

                /* Get first level attachment info */
                EMget_attachment_info(&env, &num_att, &filenames,
                                                        &att_ids, &att_oss);
                pnext = p->child;
                while(pnext)
                {
                    /*
                     * Get the matching attachment for this tree node
                     */
	            for (j = 0; j < num_att; j++)
                    {   
	                /*
                	KLUDGE!!
			    Instead of comparing the filenames,
                            we should compare the internal_osnames of
                            the files, for uniquness.
		        */
                        if (c = strrchr(pnext->info.o_part.filename,'/'))
                            osname = c + 1;
                        else
                            osname = pnext->info.o_part.filename;

                        if (c = strrchr(&filenames[j * MAXPATHLEN],'/'))
                            file = c + 1;
                        else
                            file = &filenames[j * MAXPATHLEN];

                        /* check whether the old/new filenames match */
                        verbose(printf("Checking %s against %s\n",
                                    				file, osname));

                        if (!strcmp(file, osname))
                        {
                            /* Found the corresponding attachment */
                            if (!(pnext->info.op_type & NoOperation) && 
                                !(pnext->info.op_type & EditOperation) &&
                                !(pnext->info.op_type & UpdateOperation))
                            {
                                /* Change the attachment name */
                                verbose(printf("changing attachment %d, %d to %s\n",
                                        att_oss[j], att_ids[j],
                                        pnext->info.n_part.filename));
                                strcpy(newfilename,pnext->info.n_part.filename);
                                if(newfilename[0] != '/') 
                                {
                                    if(strchr(newfilename,'/'))
                                    {
                                        /* If it is a relative path, make it
                                           absolute w.ref.t the pwd 
                                        */
                                        EXgetcwd(tmp_name,DI_PATH_MAX);
                                        strcat(tmp_name,"/");
                                        strcat(tmp_name,newfilename);
                                        strcpy(newfilename,tmp_name);
                                    }
                                }
				empty_name[0] = 0;
                                /* change the reference file attachment name */
                                sts = om$send(msg = message GRreffile.GRchgfilename
                                             (&msg, newfilename, empty_name),
                                                senderid = NULL_OBJID,
                                                targetid = att_ids[j],
                                                targetos = att_oss[j]);
                                verbose(printf("GRchgfilename: %#x, %#x\n", sts, msg));
                                if (!(sts & msg & 1))
                                {
                                    verbose(printf("Failed to change attachment name from %s to %s\n",
                                       pnext->info.o_part.filename, 
                                       pnext->info.n_part.filename));
                                }
                            }
                            /*
                             * If this attachment has no owner connected,
                             * create a part instance for it.
                             */
    		            GRget_to_owner_info(&chandef, att_oss[j],
                                                      att_ids[j], &count);
        	            if(count == 0)
                            {
                            struct GRid instance_id, ref_id;

                                attrs[0].info.type = EM_PART_ATTR;
                                attrs[0].value.type = EM_STRING;
                                strcpy(attrs[0].info.name, "description");
                                strcpy(attrs[0].info.desc, "Part Description");
                                strcpy(attrs[0].value.syntax, pnext->info.n_part.description);

                                attrs[1].info.type = EM_COMMON_ATTR;
                                attrs[1].value.type = EM_STRING;
                                strcpy(attrs[1].info.name, "itemno");
                                strcpy(attrs[1].info.desc, "Item Number");
                                strcpy(attrs[1].value.syntax, "1");

                                attrs[2].info.type = EM_INSTANCE_ATTR;
                                attrs[2].value.type = EM_INTEGER;
                                strcpy(attrs[2].info.name, "quantity");
                                strcpy(attrs[2].info.desc, "Quantity");
                                strcpy(attrs[2].value.syntax, "1");

				verbose(printf("creating filepart occurance\n"));

				ref_id.objid = att_ids[j];
				ref_id.osnum = att_oss[j];
                                sts = asm$create_instance (msg = &msg,
                                              mod_env = &env,
                                              type = EM_REFERENCE_PART,
                                              display = EM_DEFAULT_DISPLAY & ~EM_HANDLE_DISPLAYED,
                                              filename = &filenames[j * MAXPATHLEN],
                                              number = pnext->info.n_part.number,
                                              revision = pnext->info.n_part.revision,
                                              num_attributes = 3,
                                              attributes = attrs,
                                              num_graphics = 1,
                                              graphic_ids = &ref_id,
                                              instance_id = &instance_id);

                                if (!(sts & msg & 1))
                                {
                                    verbose(printf("failed to create instance for %s\n",
                                            &filenames[j*MAXPATHLEN]));
                                }
				else
				verbose(printf("successful creation\n"));
                            }
			    else 
                            {
                            OMuword instance_classid, classid;
                            int     i;
                            struct GRid owner_id, cp_id;

                                /* if the owner is an EMinstance, 
                                   modify the "filename" attribute in its
                                   cached part. The part number, revision and
                                   description in the cached part will be 
                                   updated when the assembly file is actually
                                   brought up on-line.
                                */
                                /*
                                 * Get the classid for EMinstance.
                                 */
                                om$get_classid (osnum = att_oss[j],
                                                classname = "EMinstance",
                                                p_classid = &instance_classid);
                                for (i=0; i<count; ++i)
                                {
                                    om$get_objid_at_index (
                                                objid = att_ids[j],
                                                osnum = att_oss[j],
                                                index = i,
                                                p_chanselect = &chandef,
                                                objidaddr = &owner_id.objid,
                                                osnumaddr = &owner_id.osnum);

                                    om$get_classid (objid = owner_id.objid,
                                                    osnum = owner_id.osnum,
                                                    p_classid = &classid);
        
                                    if (om$is_ancestry_valid (
                                        superclassid = instance_classid,
                                        subclassid = classid) == OM_S_SUCCESS)
                                    {
                                        /* Get the cachepart for this instance */
                                        sts = asm$get_instance_part(msg = &msg,
                                                    instance_id = &owner_id,
                                                    part_id = &cp_id);
                                        if (sts & msg & 1)
                                        {
                                        EMattr attr;

                                            sts = asm$get_attribute (msg = &msg,
                                                        name = "filename",
                                                        id = &cp_id,
                                                        attribute = &attr);

                                            if (sts & msg & 1)
                                            {
                                                if (strcmp(attr.value.data.s,
                                                           newfilename))
                                                {
                                                    strcpy(attr.value.syntax,
                                                            newfilename);
                                                    sts = om$send (msg = 
                                                            message EMdescribe.EMmod_attr(
                                                                  &msg,
                                                                  "filename",
                                                                  EM_ATTRIBUTE,
                                                                  -1,
                                                                  &attr),
                                                        mode = OM_e_wrt_message,
                                                        targetid = cp_id.objid,
                                                        targetos = cp_id.osnum,
                                                        senderid = NULL_OBJID);
                                                }/* if "filename" is changed */
                                            }/* if "filename" found */
                                        }/* if cp found */
                                    }/* if EMinstance */
                                }/* for (count) */
                            }/* if (count) */
                            break; /* break for loop */
                        }/* if (!strcmp(file, osname)) */
                    }/* for ( num_att ) */
                    pnext = pnext->sibling;
                }/* while (pnext) */
            }/* if p->child */
            /*
             * Close the retrieved node with flag = 1, for saving it
	     * KLUDGE: explicitly saving the module, because it is found that
	     * just putting flag = 1 in ex$close_m... is not saving the file.
             * Also, tried to replace the ex$ stuff with attach ref_file and
             * GRrfclose and this way also it did not work.
             */
	    ex$save_module(ftype = EX_invisible, index = fno);
            ex$close_module(ftype = EX_invisible, index = fno, flag = 0);
        }/* if !NoOperation */
        
        p = p->next;
    }/* while (p) */
/*    ASMreset_reading_partdata();*/
    return 1;
}
                            
int EMget_attachment_info(mod, nattachments, filenames, objids, osnums)
struct GRmd_env *mod;   /* in  */
int *nattachments;      /* out */
char **filenames;       /* out */
OM_S_OBJID **objids;    /* out */
OMuword **osnums;       /* out */
{
    char *f;
    short nest;
    IGRboolean pass;
    int sts, i, len, which_error;
    long count, out_count;
    unsigned long props;
    struct GRid refmgr;
    struct GRinquire_list requests[3];
    IGRlong msg;

    /* get the reference file manager for this space */
    verbose(printf("getting super from mod [%d, %d]\n",
                   mod->md_id.osnum, mod->md_id.objid));
    sts = ex$get_super(mod_id = mod->md_id.objid,
                       mod_osnum = mod->md_id.osnum,
                       super_name = "Ref Mgr",
                       create = 0,
                       super_id = &refmgr.objid,
                       super_osnum = &refmgr.osnum);
    if (!(sts & 1))
    {
        verbose(printf("Failed to get reference file manager in space %d\n",
               mod->md_id.osnum));
        return(FALSE);
    }
    verbose(printf("refmgr = %d, %d\n", refmgr.osnum, refmgr.objid));

    /* get a list of the reference file attachments in the current space */
    verbose(printf("getting attachment list size\n"));
    nest = FALSE;
    props = 0;
    sts = om$send(msg = message Super_rfmgr.GRget_channel_count(&msg, &props,
                                                                &nest, &count),
                  senderid = NULL_OBJID,
                  targetid = refmgr.objid,
                  targetos = refmgr.osnum);

    if (!(sts & msg & 1))
    {
        verbose(printf("Failed to get attachment count in space %d: ", refmgr.osnum));
        return(FALSE);
    }

    verbose(printf("attachment count = %d\n", count));

    *osnums = (OMuword *)om$malloc(size = count * sizeof(OMuword));
    *objids = (OM_S_OBJID *)om$malloc(size = count * sizeof(OM_S_OBJID));

    verbose(printf("getting attachment list \n"));
    sts = om$send(msg = message Super_rfmgr.GRget_channel_objects
                  (&msg, &props, &nest, &count, 
                   *objids, *osnums, &out_count),
                  senderid = NULL_OBJID,
                  targetid = refmgr.objid,
                  targetos = refmgr.osnum);

    if (!(sts & msg & 1) || count != out_count)
    {
        verbose(printf("Failed to get attachment list in space %d\n", refmgr.osnum));
        return(FALSE);
    }
    *nattachments = out_count;

    /* retrieve info about the files attached to master file */
    verbose(printf("getting filenames\n"));
    len = (count + 1) * sizeof(char) * MAXPATHLEN;
    *filenames = (char *)om$malloc(size = len);
    f = *filenames;
    i = 0;
    requests[i].var = REFERENCE_FILE_NAME;
    requests[i].num_requested = MAXPATHLEN - 1;
    i = i + 1;
    requests[i].var = END_REPORT_REQUEST;
    requests[i].var_ptr = NULL;
    requests[i].num_requested = 0;
    pass = FALSE;
    for (i = 0; i < count; i = i + 1)
    {
        requests[0].var_ptr = &f[i * MAXPATHLEN];
        sts = om$send(msg = message GRreffile.GRinquireref(&msg,
                                                           mod,
                                                           requests,
                                                           &which_error,
                                                           &pass,
                                                           NULL),
                      senderid = NULL_OBJID,
                      targetid = objids[0][i],
                      targetos = osnums[0][i]);
        if (!(sts & msg & 1))
        {
            verbose(printf("Failed to get ref name: %#x, %#x\n", sts, msg));
            return(FALSE);
        }
        verbose(printf("f[%d] = %s\n", i, &f[i * MAXPATHLEN]));
    }
    return(TRUE);
}

end implementation EMpart;
