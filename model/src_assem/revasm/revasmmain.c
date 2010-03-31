/*
Name
        revasmmain.c

Description
        This file contains the main function for the Revise Assembly command.
        and also the form interface functions.

History
        dkk     06/21/94        creation
*/
#include <stdlib.h>
#include <stdio.h>
#include <alloca.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <sys/ipc.h>
#include <sys/shm.h>
#include <unistd.h>
#include <string.h>
#include <sys/param.h>
#ifdef X11
#include <X11/Intrinsic.h>
#endif
#ifdef ENV5
#include <tools.h>
#endif
#include <FI.h>
#include <UMS.h>
#include "grmsg.h"

#include "revasmipc.h"
#include "asmrevdef.h"

#define Success         0
#define NoGrnuc         1
#define NoForm          2
#define InitError       3
#define IPCError        4

#define TRUE		1
#define FALSE		0
#define Null        	(char *)NULL

#define DefaultSuffix   "1"
#define DefaultPath     ""
#define DefaultDepth    1     

#define MAX_REFFILE_DEPTH   256

/*
        Global and static data.
*/
static char *RevAssemblyForm = "EMRevAsm";

static int      shmid, emssem, extsem;
static Form     form;
static NodeInfo *nodeptr;

static REVASM_TREE     *ext_asmtree;
static int              EMdisplay_full_tree;
static char		old_suff[10];

void   EMrevasm_button_intercept();

void usage(progname)
char *progname;
{
    fprintf(stderr, "Usage: %s <assyfilename>\n", progname);
    exit(1);
}

void EMsetop_type( REVASM_TREE *p, int op )
{
int spl_bits;

    spl_bits = (p->info.op_type & SPECIAL_BITS);

    p->info.op_type = op | spl_bits;
}

/* Form notification routine for Revise Assembly */
int EMrevasm_callback(f_label, g_label, value, form)
int f_label, g_label;
double value;
Form form;
{   
REVASM_TREE *p, *tr_p;
NodeInfo end_of_tree;
char suff[10], buf[256], *c, *s, new_name[128];
char new_path[128];
int  i, row, col, st, rp, numrows, j, op;
double dpt;

    FIf_get_user_pointer( form, (char **)&tr_p );
    FIg_set_text(form, FI_MSG_FIELD, "");
    switch( g_label )
    {
        case FI_ACCEPT:
            /* Format the copyOS command for all nodes that need to be
               copied and after copy, change the internal osname in their
               respective masters' using dros. Do the same operation for
               replaced files also.
            */
            if (!(tr_p->info.op_type & UpdateOperation))
                if(!EMrevasm_preprocess_tree(form, tr_p))
		    break;

	    /* Send the tree to the EMS process and wait for the updating
	       process to complete.
            */
            send_tree_thru_shm(tr_p, nodeptr, extsem, emssem);
            FIg_set_text(form, FI_MSG_FIELD, "Changing attachments ...");
            sem_wait(extsem);
	    FIf_erase(form);
            FIf_delete(form);
            break;

        case FI_CANCEL:
            /* Terminate the command */
            end_of_tree.op_type = END_OF_TREE;
            *nodeptr = end_of_tree;
	    sem_signal(emssem);
	    sem_wait(extsem);

	    FIf_erase(form);
            FIf_delete(form);
            break;

        case FI_RESET:
            /* Reset the form to the Initial state */
	    FIg_set_text(form, SuffixField, DefaultSuffix);
	    EMsetup_default_info(form, tr_p);
            row = 0;
            tr_p->info.op_type |= SUBASSY_EXPLODED;
            EMdisplay_full_tree = FALSE;
            EMdisplay_subassy(form, tr_p, &row);
            break;

	case RevAssyMCF:
            /* Do the processing for Operation and PartInfo columns */
	    FIfld_get_active_row(form, g_label, &row, &rp);
            FImcf_get_active_col(form, g_label, &col, &st);
            i = 0;
            if(!EMrevasm_find_node_by_row(row, &i, tr_p, &p))
            {
                /*"couldnot find node by row"*/
                break;
            }
	    if (p->info.op_type & Reference_file_not_found)
                break;
            op = (p->info.op_type & OPERATION_TYPES);
            switch(col)
            {
		case NestLevelColumn:
                    /* Do level expansion/compression, as the case maybe */
		    if (!(p->info.op_type & ReplaceOperation))
                    {
                        if (p->info.op_type & SUBASSY_EXPLODED)
                        {
                            p->info.op_type &= ~SUBASSY_EXPLODED;
                            EMcollapse_subassy(form, p, row);
                        }
                        else
                        {
                            p->info.op_type |= SUBASSY_EXPLODED;
                            EMexpand_subassy(form, p, row);
                        }
                    }
		    break;

                case CurrentNameColumn:
                    /* Display the old part info in a messagefield */
		    sprintf(buf,"Part Attributes: %s | %s | %s", p->info.o_part.number,
			    p->info.o_part.revision,p->info.o_part.description);
		    FIg_set_text(form, FI_MSG_FIELD, buf);
                    break;

                case OperationColumn:
                    if((p->parent) && (p->parent->info.op_type & NoOperation))
                        break;
                    new_path[0] = 0;
                    suff[0] = 0;
                    FIg_get_text(form, PathField, new_path);

                    if(new_path[0]) /* remove final '/' if present */
                        if(new_path[strlen(new_path)-1] == '/' )
                            new_path[strlen(new_path)-1] = 0;
                    FIg_get_text(form, SuffixField, suff);
                    FIfld_get_text(form, g_label, row, CurrentNameColumn, 256,
                                    buf, &st, &rp);
                    c = buf;
                    while(isspace(*c)) c++;
                    if(new_path[0])
                    {
                        /* strip oldpath and append new_path */
                        s = strrchr(p->info.o_part.filename, '/');
                        if(!s) 
                            s = p->info.o_part.filename;
                        else 
                            s++;
                        sprintf(c, "%s/%s", new_path, s);
                    }

                    switch(p->info.op_type & OPERATION_TYPES)
                    {
                        case NoOperation:
                        case EditOperation:
                            /* Toggle the operation to Copy */
                            EMsetop_type(p, CopyOperation);
                            strcat(c, suff);
                            EMrevasm_check_dest_name(form, row, c);
                            break;

                        case CopyOperation:
                            EMsetop_type(p, EditOperation);
			    strcpy(p->info.n_part.filename, c);
                            EMdisplay_node(form, p, row);
                            break;

                        case ReplaceOperation:
                            EMsetop_type(p, OverwriteOperation);
                            FIfld_set_text(form, RevAssyMCF, row, col, 
                                                          "overwrite", FALSE);
                            break;                            

                        case OverwriteOperation:
                            EMsetop_type(p, ReplaceOperation);
                            FIfld_set_text(form, RevAssyMCF, row, col, 
                                                          "replace", FALSE);
                            break;                            
                    }
                    EMrevasm_set_same_nodes(form, tr_p, p);
                    break;

                case NewNameColumn:
                    FIfld_get_text(form, g_label, row, NewNameColumn, 256,
                                    buf, &st, &rp);
                    for(c = buf; isspace(*c); c++);
                    if(!(*c)) /* Blank entry */
                    {
                        EMdisplay_node(form, p, row);
                        break;
                    }
                    /* scan over the name looking for blanks */
                    s = c;
                    while (*s && !isspace(*s)) s++;
                    if(*s) /* Blank in the middle of filename */
                    {
                        EMdisplay_node(form, p, row);
                        FIg_set_text(form, FI_MSG_FIELD, "Illegal filename");
                        break;
                    }
    
		    /* Append the newpath */
		    new_path[0] = 0;
                    FIg_get_text(form, PathField, new_path);
		    if (new_path[0])
		    {
		        /* rip the directory spec off the input name */
		        s = strrchr(c, '/');
		        if ( s == NULL )
		            strcpy( new_name, c);
		        else
		            strcpy( new_name, s+1);

		        /* format the new path */
		        if(new_path[strlen(new_path) - 1] == '/')
		            s = "";
		        else
			    s = "/";
		        sprintf(c, "%s%s%s", new_path, s, new_name);
    		    }

                    EMrevasm_check_dest_name(form, row, c);           
		    if (op != (p->info.op_type & OPERATION_TYPES))
                        EMrevasm_set_same_nodes(form, tr_p, p);
                    break;

                case PartNumberColumn: 
                    buf[0] = 0;
                    FIfld_get_text(form, RevAssyMCF, row, col, 256, buf, &st, &rp);
                    if( buf[0] && strcmp(buf, p->info.n_part.number))
		    {
                        strcpy(p->info.n_part.number, buf);
                        if(!(p->info.op_type & UpdateOperation))
                        {
                            if(p->info.op_type & NoOperation)
                                EMset_edit_op(form, tr_p, p, row);
                            EMrevasm_set_same_nodes(form, tr_p, p);
                        }
                    }
                    else if( !buf[0] )
                        EMdisplay_node(form, p, row);

                    break;

                case RevisionColumn: 
                    buf[0] = 0;
                    FIfld_get_text(form, RevAssyMCF, row, col, 256, buf, &st, &rp);
                    if( buf[0] && strcmp(buf, p->info.n_part.revision))
                    {
                        strcpy(p->info.n_part.revision, buf);
                        if(!(p->info.op_type & UpdateOperation))
                        {
                            if(p->info.op_type & NoOperation)
                                EMset_edit_op(form, tr_p, p, row);
                            EMrevasm_set_same_nodes(form, tr_p, p);
                        }
                    }
                    else if( !buf[0] )
                        EMdisplay_node(form, p, row);
                    break;

                case DescriptionColumn: 
                    buf[0] = 0;
                    FIfld_get_text(form, RevAssyMCF, row, col, 256, buf, &st, &rp);
                    if( buf[0] && strcmp(buf, p->info.n_part.description))
                    {
                        strcpy(p->info.n_part.description, buf);

                        if(!(p->info.op_type & UpdateOperation))
                        {
                            if(p->info.op_type & NoOperation)
                                EMset_edit_op(form, tr_p, p, row);
                            EMrevasm_set_same_nodes(form, tr_p, p);
                        }
                    }
                    break;
            }
            break;

        case CopyAllButton:
            /* Set all the parts' optype to Copy and use the autonaming
               suffix to get the newfilename from the old one.
            */
            new_path[0] = 0;
            suff[0] = 0;
            FIg_get_text(form, PathField, new_path);
            if(new_path[0]) /* remove final '/' if present */
                if(new_path[strlen(new_path)-1] == '/' )
                    new_path[strlen(new_path)-1] = 0;
            FIg_get_text(form, SuffixField, suff);

            p = tr_p;
            while(p)
            {
                if (p->info.op_type & Reference_file_not_found)
                {
                    p = p->next;
                    continue;
                }
                EMsetop_type(p, CopyOperation);
                p->info.n_part = p->info.o_part;
                c = p->info.n_part.filename;
                if(new_path[0])
                {
                    /* strip oldpath and append new_path */
                    s = strrchr(p->info.o_part.filename, '/');
                    if(!s) 
                        s = p->info.o_part.filename;
                    else 
                        s++;
                    sprintf(c, "%s/%s", new_path, s);
                }
                strcat(p->info.n_part.filename, suff);

                p = p->next;
            }
            FIg_reset(form, RevAssyMCF);
            EMdisplay_full_tree = TRUE;
            row = 0;
            EMdisplay_subassy(form, tr_p, &row );
            EMdisplay_full_tree = FALSE;
            p = tr_p;
            row = 0;
            while(p)
            {
                if (!(p->info.op_type & Reference_file_not_found))
	            EMrevasm_check_dest_name(form, row, p->info.n_part.filename);
		row++;		
                p = p->next;
            }
	    FIg_get_high_value(form, DepthSlider, &dpt);
            FIg_set_value(form, DepthSlider, dpt);
            break;

        case DepthSlider:
            FIg_get_value(form, DepthSlider, &dpt);
            EMchange_display_depth(form, tr_p, (int) dpt);
            break;

        case PreservePathToggle:
            /* If yes, the new files path is same as that of old, else
               use the path given in path field */
	    FIg_get_state(form, g_label, &st);

            if (st) /* toggle set to "No" */
            {
		FIg_start_seq(form, PathField);
            }
            else /* toggle set to "Yes" */
            {
                FIg_set_text(form, PathField, "");
                /* loop through all files changing the pathnames to match the
                   old filename, if its op_type is other than nochange */
                FIfld_get_num_rows(form, RevAssyMCF, &numrows);
                for( i = 0; i < numrows; i++ )
                {
                    st = 0;
                    if (EMrevasm_find_node_by_row(i, &st, tr_p, &p))
                    {
		        if(p->info.op_type & NoOperation)
                            continue;

                        /* strip new_path and append oldpath */
                        strcpy(buf, p->info.o_part.filename);
                        c = strrchr(buf, '/');
                        if(c)
			    *c = '\0';

                        s = strrchr(p->info.n_part.filename, '/');
                        if(!s) 
                            s = p->info.n_part.filename;
                        else 
                            s++;
                        sprintf(p->info.n_part.filename, "%s/%s", buf, s);
    		        EMrevasm_check_dest_name(form, i, p->info.n_part.filename);
                    }
                }
            }
            break;     

        case PathField:
            /* This is the path to be used for all new files, when the
             * preserve path toggle is OFF.
             * Make sure the Preserve Path toggle is set to "No" 
             */
            FIg_set_state(form, PreservePathToggle, 1);

            /* get the new path */
            FIfld_get_text(form, PathField, 0, 0, 128, new_path, &st, &rp);
            if (strlen(new_path) == 0)
            {
                UMSGetByNum(buf, GR_P_Cd, 0);
                FIfld_set_text(form, FI_MSG_FIELD, 0, 0, buf, FALSE);
                FIg_set_state(form, PreservePathToggle, 0);
            }
            else
            {
                /* make sure the path is accessible */
                if (access(new_path, W_OK) != 0)
                {
                    UMSGetByNum(buf, GR_E_CantWriteDir, 0);
                    FIfld_set_text(form, FI_MSG_FIELD, 0, 0, buf, FALSE);
		    FIg_set_text(form, PathField, "");
                    FIg_set_state(form, PreservePathToggle, 0);
                }
                else
                {
                    /* change tree nodes (!no_change) to the new_path */
                    FIfld_get_num_rows(form, RevAssyMCF, &numrows);
                    for(i = 0; i < numrows; i++)
                    {
                        j = 0;
                        EMrevasm_find_node_by_row(i, &j, tr_p, &p);
                        if(!(p->info.op_type & NoOperation))
                        {
                            /* Strip the Path Info in the new name */
                            FIfld_get_text(form, RevAssyMCF, i, NewNameColumn,
                                                    256, buf, &st, &rp);
                            for(c = buf; isspace(*c); c++);
                            s = strrchr(buf, '/');
                            if(!s)
                                strcpy(new_name, c);
                            else
                                strcpy(new_name, s+1);
                            if(new_path[strlen(new_path)-1] == '/' )
                                new_path[strlen(new_path)-1] = 0;
                            sprintf(c, "%s/%s", new_path, new_name);
		            EMrevasm_check_dest_name(form, i, c);
                        }
                    }
                }
            }
            break;

        case SuffixField:
            /* Strip off the suffix from all parts with optype Copy and
               append the new suffix.
            */
            FIg_get_text(form, g_label, suff);

            if (strcmp(old_suff, suff)) /* suffix is changed */
            {
                p = tr_p;
                while (p)
                {
                    if (p->info.op_type & CopyOperation)
                    {
                        /* if the newfilename is just an addition of a
                           suffix to the old file name, change the old suffix
                           to the new suffix.
                        */
                        i = strlen(p->info.o_part.filename);
                        if (!strncmp(p->info.o_part.filename,
                                     p->info.n_part.filename,
                                     i))
                        {
                            p->info.n_part.filename[i] = 0;
                            strcat(p->info.n_part.filename, suff);
                            row = 0;
                            if (EMrevasm_find_row_by_node(&row, tr_p, p))
                                EMrevasm_check_dest_name(form, row, 
                                                    p->info.n_part.filename);
                        }
                    }
                    p = p->next;
                }
            }
	    strcpy(old_suff, suff);
            break;
    }
    return 1;
}

EMrevasm_set_same_nodes( form, tr_top, node )
Form form;
REVASM_TREE *tr_top, *node;
{
REVASM_TREE *p, *ptr[MAX_REFFILE_DEPTH];
int ptrcnt = 0, j, row, old_op;

    p = tr_top;
    while (p)
    {
        if ((p != node) && !strcmp(p->info.o_part.filename, 
					node->info.o_part.filename))
        {
            /* Explode the parent nodes in the path, if not already exploded.
            */
            if (!(p->parent->info.op_type & SUBASSY_EXPLODED))
            {
                /* copy the new part info and optype */
                p->info.n_part = node->info.n_part;
                p->info.op_type = node->info.op_type;

                /* If the parent node is a nochange, set to copy operation */
                if((p->parent) && (p->parent->info.op_type & NoOperation))
                {
                    EMsetop_type(p->parent, CopyOperation);
                    /* build the new filename for the parent */
                    EMbuild_new_filename(form, p->parent);
                }

                /* Store the parents in the path */
                ptr[ptrcnt] = p->parent;
                while(!(ptr[ptrcnt++]->parent->info.op_type & SUBASSY_EXPLODED))
                    ptr[ptrcnt] = ptr[ptrcnt-1]->parent;

                /* Explode each of the parents, starting from topmost */
                for (j = ptrcnt; j > 0; j-- )
                {
                    /* Get the last unexploded parents' row number on form
                    */
                    row = 0;
                    if (EMrevasm_find_row_by_node(&row, tr_top, ptr[j-1]))
                    {
                        ptr[j-1]->info.op_type |= SUBASSY_EXPLODED;
                        EMexpand_subassy(form, ptr[j-1], row);
                    }
                    else
		    {
                        ptr[j-1]->info.op_type |= SUBASSY_EXPLODED;
                    }
                }
            }
            else
            {
                old_op = p->info.op_type;

                /* Copy the new part info and optype */
                p->info.n_part = node->info.n_part;
                p->info.op_type = node->info.op_type;

                /* Find out the row corresponding to the node on the form */
		row = 0;
                if (EMrevasm_find_row_by_node(&row, tr_top, p))
                {
                    /* check if new operation is Replace 
		       and if this subassly is in exploded state, collapse it.
                    */
                    EMdisplay_node(form, p, row);
                    if (old_op & SUBASSY_EXPLODED)
                    {
                        if (p->info.op_type & ReplaceOperation)
                            EMcollapse_subassy(form, p, row);
                    }
                }
                else
                    printf("find row failed 2\n");

                /* If the parent node is a nochange, set to copy operation */
                if((p->parent) && (p->parent->info.op_type & NoOperation))
                {
                    EMsetop_type(p->parent, CopyOperation);
                    /* build the new filename for the parent */
                    EMbuild_new_filename(form, p->parent);

                    /* Find the parent nodes' row number and change it */
                    row = 0;
                    if (EMrevasm_find_row_by_node(&row, tr_top, p->parent))
                        EMdisplay_node(form, p->parent, row);
                    else
                        printf("find row failed 3\n");
                }
            }
        }
        p = p->next;
    }
    return 1;
}

EMbuild_new_filename(Form form, REVASM_TREE *node)
{
char new_path[128], suff[10];
char *s;

    new_path[0] = 0;
    suff[0] = 0;
    FIg_get_text(form, PathField, new_path);
    FIg_get_text(form, SuffixField, suff);

    if(new_path[0])
    {
        /* strip oldpath and append new_path */
        s = strrchr(node->info.o_part.filename, '/');
        if(!s) 
            s = node->info.o_part.filename;
        else
            s++;
        if (new_path[strlen(new_path)-1] != '/')
            strcat(new_path, "/");
    }
    else
        s = node->info.o_part.filename;

    sprintf(node->info.n_part.filename, "%s%s%s", new_path, s, suff);

    return 1;
}

EMcollapse_subassy(form, p, row)
Form form;
REVASM_TREE *p;
int  row;
{
    /* First set the op_type of the nodes in the subassy to
       nochange and then change the display on the form.
    */
    if(p->child)
        EMset_nochange_op(p->child);

    /* Now, display the current and other subassemblies */
    EMdisplay_subassy(form, p, &row);
    EMdisplay_next_subassy(form, p, row);

    return 1;
}

EMset_nochange_op(node)
REVASM_TREE *node;
{
REVASM_TREE *p;
int op;

    p = node;
    op = p->info.op_type;
    if (op & Reference_file_not_found)
        p->info.op_type = NoOperation | Reference_file_not_found;
    else
        p->info.op_type = NoOperation;
    /* copy the old part info into new part info */
    p->info.n_part = p->info.o_part;

    if (op & SUBASSY_EXPLODED)
    {
        if (p->child)
            EMset_nochange_op(p->child);
    }
    p = p->sibling;
    if (p)
        EMset_nochange_op(p);

    return 1;
}

EMexpand_subassy(form, p, row)
Form form;
REVASM_TREE *p;
int  row;
{
    EMdisplay_subassy(form, p, &row);
    EMdisplay_next_subassy(form, p, row);

    return 1;
}

EMdisplay_next_subassy(form, p, row)
Form form;
REVASM_TREE *p;
int  row;
{
REVASM_TREE *ptr;
int numrows;

    ptr = p->parent;
    while(ptr)
    {
        if( ptr->sibling )
            EMdisplay_subassy(form, ptr->sibling, &row);
        ptr = ptr->parent;
    }
    FIfld_get_num_rows(form, RevAssyMCF, &numrows);
    FIfld_delete_rows(form, RevAssyMCF, row, numrows - row);

    return 1;
}

EMset_edit_op(form, tree_p, p, row)
Form form;
REVASM_TREE *tree_p, *p;
int row;
{
REVASM_TREE *ptr;
int j, i;

    EMsetop_type(p, EditOperation);
    FIfld_set_text(form, RevAssyMCF, row, OperationColumn, "edit", 0);
    if(!(p->parent)) 
        return 1;

    if(p->parent->info.op_type & NoOperation)
    {
        /* Find parents' row number and change its optype */
        ptr = NULL;
        for(j = row-1; (ptr != p->parent); j-- )
        {
            i = 0;
            EMrevasm_find_node_by_row(j, &i, tree_p, &ptr);
      	    if(ptr == NULL)
		 break;
        }
        if((j == -1) || (ptr == NULL)) /* Should not happen at all !!! */
            printf("Error in finding parent node\n");
        else
        {
            EMsetop_type(p->parent, EditOperation);
            FIfld_set_text(form, RevAssyMCF, j+1, OperationColumn, "edit", 0);
        }
    }

    return 1;
}

main(argc, argv)
int argc;
char *argv[];
{
char  mess[256];
char  dummy_name[128];
char  buf[512], *emsarg[9], *c;
int   sts;

    	/* make sure filename was specified */
    	if (argc == 1) usage(argv[0]);

    	/* make sure that the file can be read */
    	if (access(argv[1], R_OK) != 0)
    	{
        	fprintf(stderr,"Cannot read %s\n", argv[1]);
        	perror(argv[1]);
        	exit(InitError);
    	}

	if( check_prod_paths() != Success )
		exit(NoGrnuc);

    	/* Setup the Form interface */
	if( RevAssy_setup_form(argc, argv) != Success )
                exit(NoForm);

    	/*
	Setup the shared memory and semaphores, with 1 for EMS
	semaphore and 0 for the external process semaphore. 
	*/
	if( setup_ipc() < 0 )
		exit(IPCError);

	/* Copy the assembly filename into the nodeptr */
	strcpy( nodeptr->o_part.filename, argv[1] );

	/*
	Fork the EMS process in batch mode and run the ppl
	*/
	if(get_model_path( buf ) != Success)
		exit(NoGrnuc);

        /* invent a non-existent file name */
        c = (c = getenv("TMPDIR")) ? c : "/usr/tmp";
        sprintf(dummy_name, "%s/revasm1XXXXXX", c);
        mktemp(dummy_name);

        /* 
         format the ems command line arguments
        */
	emsarg[0] = buf;
	emsarg[1] = "-p";
	emsarg[2] = "Emspp";
	emsarg[3] = "-cf";
	emsarg[4] = dummy_name;
	emsarg[5] = "-b";
	emsarg[6] = "-C";
	emsarg[7] = "ci=RevAssly";
	emsarg[8] = 0;

        FIg_set_text(form, FI_MSG_FIELD, "Reading assembly structure...");

        /* fork the ems command line */
        if( !fork() )
        {
            /* Child */
            execvp(emsarg[0], emsarg);
            exit(0);
        }

	/*
	Wait until the external process semaphore is set to 1.
	Build the tree by reading the node info in the shared memory
	and pass the control back to EMS process, until the read
	node info's "optype" is END_OF_TREE (indicating end-of-tree).
	*/
  	build_tree_from_shm(&ext_asmtree, nodeptr, emssem, extsem);

	if (ext_asmtree == NULL)
	{
 	    printf("Assembly does not contain ref files OR\n");
	    printf("Could not read assembly; use 'killipcs' before revasm\n");
            exit(0);
        }	

        /* fill in the data on the form */
        sts = EMinit_revasm_form(form, ext_asmtree);

        if (!(sts & 1))
        {
            UMSGetByNum(buf, GR_E_NoRefFl, 0);
            UMSGetByNum(mess, GR_I_Notice, 0);
            FI_msg_box2(mess, FI_BLUE, buf, FI_BLACK);
            exit(InitError);
        }

	/*
        ... and wait for the form processing.
	*/
	FI_process_forms();

        close_ipc(nodeptr, emssem, extsem);
}

setup_ipc()
{
   	if((shmid = shmget(SHMKEY, sizeof(NodeInfo), PERMS | IPC_CREAT)) < 0 )
   	{
		perror("server: cant get shared memory");
		return(-1);
   	}

   	if((nodeptr = (NodeInfo *)shmat(shmid, (char *)0, 0)) == (NodeInfo *)-1)
   	{
		perror("server: cant attach shared memory");
		return(-1);
   	}

   	if((emssem = sem_create(SEMKEY1, 1)) < 0)
   	{
		perror("server:cant create client semaphore");
		return(-1);
   	}

   	if((extsem = sem_create(SEMKEY2, 0)) < 0)
   	{
		perror("server:cant create server semaphore");
		return(-1);
   	}
	return 1;
}

close_ipc(nodeptr, sem1, sem2)
int sem1, sem2 ;
NodeInfo *nodeptr;
{
    /* Detach the shared memory segment */
    if( shmdt(nodeptr) < 0 )
        printf("server: cant detach shared memory\n");

    /* Close the semaphores */
    sem_close(sem1);
    sem_close(sem2);

    return 1;
}

RevAssy_setup_form(argc, argv)
int  argc;
char *argv[];
{
    int sts;
    char buf[256];
#ifdef X11
    Display  *display;
    Widget top_level;
    XtAppContext app_context;
#endif

#ifdef ENV5
    Enter_tools();
    FI_enter();
    Enable_events(FI_EVENT_MASK);
#endif

#ifdef X11
    /* initialize the toolkit */
    top_level = XtVaAppInitialize(&app_context, RevAssemblyForm, NULL, NULL,
#ifdef SUNOS
                                  (Cardinal *)&argc,
#else
                                  (int *)&argc,
#endif
                                  (String *)argv, (String *)NULL, NULL);

    /* initialize the forms system */
    display = XtDisplay(top_level);
    FSEnter(display, 0);

    FI_enter(display, DefaultColormap(display, DefaultScreen(display)), 32);
#endif

    /* set up the FORMS search paths */
    GRget_product_data("Model", Null, Null, Null, Null, buf);
    strcat(buf, "config/english/forms");
    FI_set_form_path(buf);

    /* create the Revise Assembly form */
    form = (Form)NULL;
    sts = FIf_new(RevAssemblyFormLabel, RevAssemblyForm, 
                  EMrevasm_callback, &form);

    if ((sts != FI_SUCCESS) || (form == NULL))
    {
        fprintf(stderr, "Failed to create form %s\n", RevAssemblyForm);
        return(NoForm);
    }

    /* display the form */
    FIf_display(form);

    /* set up a button intercept routine to handle files not found */
    sts = FIf_set_button_intercept_routine(form, EMrevasm_button_intercept);

    /* let the user know something is going on */
    UMSGetByNum(buf, GR_I_Working, 0);
    FIfld_set_text(form, FI_MSG_FIELD, 0, 0, buf, 0);

    return(Success);
}

check_prod_paths()
{
char buf[256], grnuc[256];
int  i;

    /* make sure the path to EXNUC is there, and utilities are executable */
    buf[0] = NULL;
    GRget_product_data("Exnuc", Null, Null, Null, Null, buf);
    if (buf[0] == NULL)
    {
        fprintf(stderr, "Failed to find Exnuc in $INGRHOME/product_data\n");
        return(NoGrnuc);
    }
    i = strlen(buf);
    strcat(buf, "bin/dros");
    if (access(buf, X_OK) != 0)
    {
        fprintf(stderr,"Cannot execute %s\n", buf);
        perror(buf);
        return(NoGrnuc);
    }
    buf[i] = NULL;
    strcat(buf, "bin/copyOS");
    if (access(buf, X_OK) != 0)
    {
        fprintf(stderr,"Cannot execute %s\n", buf);
        perror(buf);
        return(NoGrnuc);
    }

    /* find the path to GRNUC */
    grnuc[0] = NULL;
    GRget_product_data("Grnuc", Null, Null, Null, Null, grnuc);
    if (grnuc[0] == NULL)
    {
        fprintf(stderr, "Failed to find Grnuc in $INGRHOME/product_data\n");
        return(NoGrnuc);
    }
    /* make sure the path to MODEL is there */
    buf[0] = NULL;
    GRget_product_data("Model", Null, Null, Null, Null, buf);
    if (buf[0] == NULL)
    {
        fprintf(stderr, "Failed to find Model in $INGRHOME/product_data\n");
        return(NoGrnuc);
    }

    /* initialize the message system */
    sprintf(buf, "%s/config/english/messages/grmsg.msg", grnuc);
    UMSInitMsg(buf, UMS_INDEX);

    return(Success);
}

get_model_path( char *buf)
{
char title[128], buffer[256];

    /* get the path to MODEL (already validated in main) */
    buf[0] = NULL;
    GRget_product_data("Model", Null, Null, Null, Null, buf);
    if (buf[0] == NULL)
	return(NoGrnuc);

    strcat(buf,"bin/Model");

    if (access(buf, X_OK) != 0)
    {
        UMSGetByNum(buffer, GR_E_CannotExecuteFile, "%s", buf);
        UMSGetByNum(title, GR_I_Error, 0);
        FIfld_set_text(form, FI_MSG_FIELD, 0, 0, buffer, 0);
        FI_msg_box2(title, FI_RED, buffer, FI_BLACK);
        return(NoGrnuc);
    }
    return(Success);
}

int EMinit_revasm_form(form, asm_tree)
Form form;
REVASM_TREE *asm_tree;
{
    int sts;
    int max_depth, row;
    REVASM_TREE *p;
    char buf[1024];

    /* adjust the path gadgets */
    FIg_set_text (form, PathField, DefaultPath);

    /* setup the suffix gadget */
    FIg_set_text (form, SuffixField, DefaultSuffix);
    strcpy(old_suff, DefaultSuffix);

    /* Get the max depth for the tree and set the slider */
    max_depth = 1;
    p = asm_tree;
    while( p )
    {
        if(p->info.depth > max_depth)
	    max_depth = p->info.depth;

        p = p->next;
    }
    FIg_set_high_value (form, DepthSlider, (double)max_depth);

    /* set the depth gadget to default depth */
    FIg_set_value(form, DepthSlider, (double)DefaultDepth);

    /* Check if any reference file is in Update mode */
    EMdisplay_full_tree = FALSE;
    p = asm_tree;
    while (p)
    {
        if( p->info.op_type & UpdateOperation )
        {
            FIg_disable(form, CopyAllButton);
            FIg_disable(form, PreservePathToggle);
            FIg_disable(form, PathField);
            FIg_disable(form, SuffixField);
            FIg_disable(form, DepthSlider);
            FIfld_set_mode(form, RevAssyMCF, OperationColumn, FI_REVIEW);
            FIfld_set_mode(form, RevAssyMCF, NewNameColumn, FI_REVIEW);
            EMdisplay_full_tree = TRUE;
            break;
        }
        p = p->next;
    }
    if (EMdisplay_full_tree)
    {
        sprintf(buf, "Update files to EMS4 before making assembly revisions");
        FIg_set_text(form, FI_MSG_FIELD, buf); 
    }
    else
    {
        /* tell the user to start banging on gadgets */
        UMSGetByNum(buf, GR_P_SelFrForm, 0);
        FIg_set_text(form, FI_MSG_FIELD, buf);
    }

    /* Setup the tree pointer so that it can be accessed in the form callback */
    FIf_set_user_pointer( form, (char *)asm_tree );

    /* Setup the default op_type and new part info in the tree */
    EMsetup_default_info(form, asm_tree);

    /* If any reference file other than master is set to UpdateOperation,
       master file will be set to NoOperation
    */
    if ((p) && (p != asm_tree))
        asm_tree->info.op_type = NoOperation;

    /* fill in the file names along with first level attachments */
    row = 0;
    sts = EMdisplay_subassy(form, asm_tree, &row);
                                
    return(sts);
}

int EMsetup_default_info(form, asm_tree)
Form form;
REVASM_TREE *asm_tree;
{
REVASM_TREE *p;
char suff[10], *ptr;

    p = asm_tree;
    if( !(p->info.op_type & UpdateOperation ))
    {
        /* Master file will be set to Copy, by Default */
	p->info.op_type = CopyOperation;
        p->info.n_part  = p->info.o_part;

        /* Add the suffix to the new filename */
        suff[0] = 0;
        FIg_get_text(form, SuffixField, suff);
        strcat(p->info.n_part.filename, suff);

        /* Set up the default part info, if old part info not available */
        if(!strlen(p->info.o_part.number))
	{
	    ptr = strrchr(p->info.o_part.filename, '/');
            if(!ptr)
                ptr = p->info.o_part.filename;
            strcpy(p->info.n_part.number,ptr);
        }

        if(!strlen(p->info.o_part.revision))
            strcpy(p->info.n_part.revision, "1");

	p->info.op_type |= SUBASSY_EXPLODED;

        /* Check if the new master file is present on disk */
        EMrevasm_check_dest_name(form, 0, p->info.n_part.filename);

        /* Check if the master file is attached elsewhere in the assembly */
        EMrevasm_set_same_nodes(form, asm_tree, p);

        p = p->next;
    }
    while( p )
    {
        /* By default, copy old part filename and attributes to the new part */
        p->info.n_part = p->info.o_part;

	/* Setup the Optype */
        if(!(p->info.op_type & UpdateOperation))
	    if (p->info.op_type & Reference_file_not_found)
                p->info.op_type = (NoOperation | Reference_file_not_found);
            else
                p->info.op_type = NoOperation;

        /* Set up the default part info, if old part info not available */
        if(!strlen(p->info.o_part.number))
        {
	    ptr = strrchr(p->info.o_part.filename, '/');
            if(!ptr)
                ptr = p->info.o_part.filename;
            strcpy(p->info.n_part.number, ptr);
        }

        if(!strlen(p->info.o_part.revision))
            strcpy(p->info.n_part.revision, "1");

        p = p->next;
    }

    return 1;
}

void EMrevasm_set_row_state(form, row, state)
Form form;
int row, state;
{
    FIfld_set_select(form, RevAssyMCF, row, NestLevelColumn, state);
    FIfld_set_select(form, RevAssyMCF, row, CurrentNameColumn, state);
    FIfld_set_select(form, RevAssyMCF, row, OperationColumn, state);
    FIfld_set_select(form, RevAssyMCF, row, NewNameColumn, state);
}

EMdisplay_node(form, p, row)
Form form;
REVASM_TREE *p;
int row;
{
char buf[MAXPATHLEN], leader[128], nest[32], warning;

    /* format a leader to use indentation to represent nesting */
    memset(leader, (int)' ', p->info.depth * IndentWidth);
    leader[p->info.depth * IndentWidth] = NULL;

    /* format the current file name */
    sprintf(buf, "%s%s", leader, p->info.o_part.filename);

    /* format the nesting level */
    warning = ((p->info.op_type & Reference_file_not_found) ? '*' : ' ');
    sprintf(nest, "%-3d%c", p->info.depth, warning);

    /* add them to the form */
    FIfld_set_text(form, RevAssyMCF, row, NestLevelColumn, nest, FALSE);
    FIfld_set_text(form, RevAssyMCF, row, CurrentNameColumn, buf, FALSE);

    /* Enter the new filename */
    sprintf(buf, "%s%s", leader, p->info.n_part.filename );
    FIfld_set_text(form, RevAssyMCF, row, NewNameColumn, buf, FALSE);

    /* Enter the op type */
    if(p->info.op_type & CopyOperation)
        strcpy( buf, "copy" );
    else if(p->info.op_type & EditOperation)
        strcpy( buf, "edit" );
    else if(p->info.op_type & OverwriteOperation)
        strcpy( buf, "overwrite" );
    else if(p->info.op_type & NoOperation)
        strcpy( buf, "nochange" );
    else if(p->info.op_type & ReplaceOperation)
        strcpy( buf, "replace" );
    else if(p->info.op_type & UpdateOperation)
        strcpy( buf, "update" );
    else
        buf[0] = 0;

    FIfld_set_text(form, RevAssyMCF, row, OperationColumn,
                                             buf, FALSE);
    /* Enter the part info */
    FIfld_set_text(form, RevAssyMCF, row, PartNumberColumn,
                                         p->info.n_part.number, FALSE);
    FIfld_set_text(form, RevAssyMCF, row, RevisionColumn,
                                            p->info.n_part.revision, FALSE);
    FIfld_set_text(form, RevAssyMCF, row, DescriptionColumn,
                                            p->info.n_part.description, FALSE);
    return 1;
}

EMdisplay_subassy(form, node, row)
Form form;
REVASM_TREE *node;
int  *row;
{
REVASM_TREE *p;
    
    p = node;
    EMdisplay_node(form, p, (*row)++);
    if (EMdisplay_full_tree || (p->info.op_type & SUBASSY_EXPLODED))
    {
	if (EMdisplay_full_tree)
	    p->info.op_type |= SUBASSY_EXPLODED;
        if (p->child)
            EMdisplay_subassy(form, p->child, row);
    }
    p = p->sibling;
    if (p)
    	EMdisplay_subassy(form, p, row);
    return 1;
}

EMchange_display_depth(Form form, REVASM_TREE *tree_head, 
                       int depth)
{
REVASM_TREE *p;
int row = 0;

    p = tree_head;
    while (p)
    {
        if (p->info.depth >= depth)
        {
	    /* if the node is exploded, collapse it */
            if (p->info.op_type & SUBASSY_EXPLODED)
            {
		row = 0;
                if (EMrevasm_find_row_by_node(&row, tree_head, p))
                {
                    p->info.op_type &= ~SUBASSY_EXPLODED;
                    EMcollapse_subassy(form, p, row);
                }
            }
        }
        else if (!(p->info.op_type & ReplaceOperation))
        {
            if ((p->child) && !(p->info.op_type & SUBASSY_EXPLODED))
            {
		row = 0;
                if (EMrevasm_find_row_by_node(&row, tree_head, p))
                {
                    p->info.op_type |= SUBASSY_EXPLODED;
                    EMexpand_subassy(form, p, row);
                }
            }                
        }
        p = p->next;
    }
    return 1;
}

int EMrevasm_find_node_by_row(int row, int *index,
			    REVASM_TREE *tree_head,
			    REVASM_TREE **node)
{
REVASM_TREE *tree_ptr;

    tree_ptr = tree_head;

    while(tree_ptr)
    {
        if((*index)++ == row)
        {
            *node = tree_ptr;
            return 1;
        }
        if(tree_ptr->info.op_type & SUBASSY_EXPLODED)
            if( EMrevasm_find_node_by_row( row, index, tree_ptr->child, node))
		return 1;
        tree_ptr = tree_ptr->sibling;
    }

    return 0;
}

/* This routine returns the row number relative to the tree_head, for the
   given node. If the node is not on the form, the routine returns 0.
*/
int EMrevasm_find_row_by_node(int *row,
                              REVASM_TREE *tree_head,
                              REVASM_TREE *node)
{
REVASM_TREE *p;

    p = tree_head;
    while(p)
    {
        if(node == p)
            return 1;
        else
            (*row)++;

        if(p->info.op_type & SUBASSY_EXPLODED)
            if( EMrevasm_find_row_by_node( row, p->child, node))
		return 1;
        p = p->sibling;
    }
    return 0;
}

int EMrevasm_check_dest_name(form, row, name)
Form form;
int  row;
char *name;
{
int  st, found, sts = 0;
int  i, j;
char buf[256];
char *c, *s;
char old_name[128];
REVASM_TREE *p, *tr_top, *ptr, *l;

    FIf_get_user_pointer(form, (char **)&tr_top);
    st = 0;
    sts = EMrevasm_find_node_by_row( row, &st, tr_top, &p );

    if(!sts)
    {
        printf("failed to find node for row %d\n", row);
        return 0;
    }

    strcpy(old_name, p->info.o_part.filename);

    /* strip off any whitespace */
    for (c = name; isspace(*c); c++);         
    /* Check if the new file already exists */
    if (access(c, F_OK) == 0)
    {
        struct stat old, new;

        /* File is already out there; is it the same as the current file? */
        stat(c, &new);
        stat(old_name, &old);
        if (new.st_ino == old.st_ino) /* same */
        {
            /* if there are children to be changed, then this is an edit */
            found = FALSE;
            if ((l = p->child) && (p->info.op_type & SUBASSY_EXPLODED))
            {
                do
                {
                    if (l->info.op_type & (CopyOperation | ReplaceOperation |
                                    OverwriteOperation | EditOperation))
                    {
                        found = TRUE;
                        EMsetop_type(p, EditOperation);
			strcpy(p->info.n_part.filename, c);
			EMdisplay_node(form, p, row);
                    }
                }
                while (!found && (l = l->sibling));
            }
            if (!found)
            {
		/* Check if the old and new part info is same */
		if((strcmp(p->info.o_part.number, p->info.n_part.number)) ||
		   (strcmp(p->info.o_part.revision, p->info.n_part.revision)) ||
	           (strcmp(p->info.o_part.description,p->info.n_part.description)))
                    EMsetop_type(p, EditOperation);
                else  /* this is a no change */
                    EMsetop_type(p, NoOperation);
		strcpy(p->info.n_part.filename, c);
		EMdisplay_node(form, p, row);
            }
        }
        else
        {
            /* different file */
	    strcpy(p->info.n_part.filename, c);
            if(p->info.op_type & SUBASSY_EXPLODED)
            {
	        p->info.op_type = ReplaceOperation;
                EMcollapse_subassy(form, p, row);
            }
            else
	    {
                p->info.op_type = ReplaceOperation;
                EMdisplay_node(form, p, row);
	    }
        }
    }
    else 
    {
        /* make sure the directory specified is writable */
        if (s = strrchr(strcpy(buf, c), '/'))
            *s = NULL;
        else
            strcpy(buf, "./");
            
        if (access(buf, W_OK) != 0)
        {
            UMSGetByNum(buf, GR_E_NotWritable, 0);
            FIg_set_text(form, FI_MSG_FIELD, buf);
	    goto quit;
        }
        else
        {
            /* filename must be ok; set the operation to copy */
            EMsetop_type(p, CopyOperation);
	    strcpy(p->info.n_part.filename, c);
	    EMdisplay_node(form, p, row);
        }
    }

    if(!(p->info.op_type & NoOperation))
    {
        if((p->parent) && (p->parent->info.op_type & NoOperation))
        {
            /* Find parents' row number and change its optype */
            ptr = NULL;
            for(j = row-1; (ptr != p->parent); j-- )
	    {
                i = 0;
                EMrevasm_find_node_by_row(j, &i, tr_top, &ptr);
                if(ptr == NULL)
                    break;
            }

            if((j == -1) || (ptr == NULL)) /* Should not happen at all !!! */
                printf("Error in finding parent node 2\n");
            else
            {
                EMsetop_type(p->parent, EditOperation);
                FIfld_set_text(form, RevAssyMCF, j+1, OperationColumn, "edit", 0);
            }
        }
    }

quit:
    return 1;
}

void EMrevasm_button_intercept(form, xpos, ypos, button, trans, t_tag)
Form form;
int xpos, ypos;
int button;
int trans;
int t_tag;
{
    int invocation_button = -1;
    int row, col, i;
    REVASM_TREE *tr_p, *p;

    /* clear any lingering prompts */
    FIfld_set_text(form, FI_MSG_FIELD, 0, 0, "", FALSE);

#ifdef X11
    invocation_button = Button2;
#endif
#ifdef ENV5
    invocation_button = MIDDLE_BUTTON;
#endif

    if ((button == invocation_button) &&
        (FIfld_find_row_and_column(form, RevAssyMCF, xpos, ypos,
                                   &row, &col) == FI_SUCCESS))
    {
        /* get pointer to data stored in form */
        FIf_get_user_pointer(form, (char **)&tr_p);

	/* Do not allow locate of a row in the following cases:
	 *  - If the ref file is not found
         *  - If the parent is a nochange and selected col=optype
         *  - If the part is in Update and col is NestLevel or CurrentName
	 */
        i = 0;
        if (EMrevasm_find_node_by_row(row, &i, tr_p, &p))
            if (p->info.op_type & Reference_file_not_found)
                return;
	    else if ((col == OperationColumn) && (p->parent) &&
		     (p->parent->info.op_type & NoOperation))
                return;
	    else if (((col == NestLevelColumn) || (col == CurrentNameColumn)) &&
                        (p->info.op_type & UpdateOperation))
                return;

        /* let FORMS handle the input from here */
        FIf_process_point(form, xpos, ypos, button, trans, t_tag);
    }
    else
    {
        /* let FORMS handle the input */
        FIf_process_point(form, xpos, ypos, button, trans, t_tag);
    }
}

int EMrevasm_preprocess_tree(Form form, REVASM_TREE *asm_tree)
{
REVASM_TREE *p;
char copyos[256], buf[MAXPATHLEN], *c;
char intosname[2][MAXPATHLEN], dros[256];
char file[2][MAXPATHLEN];
int  i, j, numrows, ind, *copied_ind, *index;
int st, rp, sts;
FILE *fp;

    /* print a working message */
    UMSGetByNum(buf, GR_I_Working, 0);
    FIfld_set_text(form, FI_MSG_FIELD, 0, 0, buf, FALSE);

    copyos[0] = NULL;
    GRget_product_data("Exnuc", Null, Null, Null, Null, copyos);
    strcat(copyos, "bin/copyOS");
    if (access(copyos, X_OK) != 0)
    {
        UMSGetByNum(buf, GR_E_CannotExecuteFile, "%s", "copyOS");
        FIfld_set_text(form, FI_MSG_FIELD, 0, 0, buf, FALSE);
        FIg_set_state(form, FI_ACCEPT, 0);
        return 0;
    }
    /* redirect stderr to the stdout stream */
    strcat(copyos, " 2>&1 ");

    GRget_product_data("Exnuc", Null, Null, Null, Null, dros);
    strcat(dros, "bin/dros");
    if (access(dros, X_OK) != 0)
    {
        UMSGetByNum(buf, GR_E_CannotExecuteFile, "%s", "dros");
        FIfld_set_text(form, FI_MSG_FIELD, 0, 0, buf, FALSE);
        FIg_set_state(form, FI_ACCEPT, 0);
        return 0;
    }

    EMget_num_rows(form, RevAssyMCF, 0, &numrows);
    copied_ind = (int *)malloc(numrows * sizeof(int));
    for (i = 0; i < numrows; i++)
        copied_ind[i] = -1;

    for (i = 0; i < numrows; i++)
    {
        ind = 0;
        if (!EMrevasm_find_node_by_row(i, &ind, asm_tree, &p))
            continue;

        if (p->info.op_type & CopyOperation)
        {
            /* Avoid copy if this file is already copied */
            index = copied_ind;
            while((*index) != -1 )
            {
                FIfld_get_text(form, RevAssyMCF, *index, NewNameColumn,
                                            MAXPATHLEN, buf, &st, &rp);
                for(c = buf; isspace(*c); c++);
                if (!strcmp(c, p->info.n_part.filename))
                    break;
                index++;
            }
            if ((*index) != -1)    /* File already copied */
                continue;
            else
                *index = i;      /* Store the file index being copied */
            /* add old/new pair to the copyos line */
            strcpy(file[0], p->info.o_part.filename);
            strcpy(file[1], p->info.n_part.filename);
            sprintf(buf, "%s %s %s ", copyos, file[0], file[1]);

            /* Fork the copyOS copyos */
            sts = system(buf);

            /* If copyOS failed, continue with next node */
            if (sts) 
	    {
                printf("copyOS failed for %s\n",file[0]);
                continue;
            }
        }
        else if ((p->info.op_type & ReplaceOperation) ||
                 (p->info.op_type & OverwriteOperation))
        {
            strcpy(file[0], p->info.o_part.filename);
            strcpy(file[1], p->info.n_part.filename);
            sts = 0;
        }            
	else sts = 1;
            
        /* If operation type is copy, replace/overwrite, update the intosname
	   in parent.
	*/
        if (!sts)
        {
            if (p->parent)
	    {
	        /* Get the INT_OSNAME of the copied and the
	           original files, through dros -N */
                for (j = 0; j < 2; j++)
                {
                    sprintf(buf, "%s -f %s -N", dros, file[j]);
                    if ((fp = (FILE *)popen(buf, "r")) != NULL)
                    {
                        while (fgets(intosname[j], MAXPATHLEN, fp))
                            if (c = strrchr(intosname[j], (int)'\n'))
                                *c = NULL;

                        pclose(fp);
                    }
                }
                /* Replace the INT_OSNAME in the parent file
		   from the original's to that of copied, using
		   dros -R */
                sprintf(buf, "%s -f %s -R %s %s", dros, 
                                            p->parent->info.n_part.filename,
                                            intosname[0], intosname[1]);
                system(buf);
            }
        }
    }
    free(copied_ind);

    return 1;
}

EMprint_full_tree_info( REVASM_TREE *tree)
{
REVASM_TREE *tree_ptr;

    tree_ptr = tree;

    while(tree_ptr)
    {
        printf("Intosname = %s\n",tree_ptr->info.intosname);
	printf("Depth     = %d\n",tree_ptr->info.depth);
        printf("Operation = ");
	switch(tree_ptr->info.op_type & OPERATION_TYPES)
	{
    	    case NoOperation:
                printf("NoOperation\n");
                break;
    	    case UpdateOperation:
                printf("UpdateOperation\n");
                break;
    	    case EditOperation:
                printf("EditOperation\n");
                break;
    	    case ReplaceOperation:
                printf("ReplaceOperation\n");
                break;
    	    case CopyOperation:
                printf("CopyOperation\n");
                break;
    	    case OverwriteOperation:
                printf("OverwriteOperation\n");
                break;
            default:
                printf("Unknown\n");
                break;
        }
        printf("OldPartInfo:\n");
        printf(" Number      = <%s>\n",tree_ptr->info.o_part.number);
	printf(" Revision    = <%s>\n",tree_ptr->info.o_part.revision);
	printf(" Description = <%s>\n",tree_ptr->info.o_part.description);
	printf(" Filename    = <%s>\n",tree_ptr->info.o_part.filename);

        printf("NewPartInfo:\n");
        printf(" Number      = <%s>\n",tree_ptr->info.n_part.number);
	printf(" Revision    = <%s>\n",tree_ptr->info.n_part.revision);
	printf(" Description = <%s>\n",tree_ptr->info.n_part.description);
	printf(" Filename    = <%s>\n",tree_ptr->info.n_part.filename);

        printf("\n");
        tree_ptr = tree_ptr->next;
    }
    printf("\n");
}

int EMget_num_rows( fp, gadget, column, nrows )
Form fp;
int gadget, column;
int *nrows;
{
char txt_buff[128];
int  row = 0, sf, rp ;

    while( 1 )
    {
        txt_buff[0] = 0;
        FIfld_get_text( fp, gadget, row, column, 128, txt_buff, &sf, &rp );
        if( !strlen( txt_buff ) )
            break;
        row++ ;
    }

    *nrows = row;

    return( 1 );
}

