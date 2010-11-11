/* $Id: VDSmainchkin.C,v 1.1.1.1 2001/01/04 21:07:57 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/vdcheckin/func / VDSmainchkin.C
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VDSmainchkin.C,v $
 *	Revision 1.1.1.1  2001/01/04 21:07:57  cvs
 *	Initial import to CVS
 *	
 * Revision 1.1  1998/04/29  16:27:20  pinnacle
 * VDS 2.5.1
 *
 * Revision 1.1  1997/05/08  13:20:44  pinnacle
 * New project VDS 250
 *
 * Revision 1.2  1996/10/18  14:34:06  pinnacle
 * Replaced: vdcheckin/func/VDSmainchkin.C for:  by msmanem for vds.241
 *
 * Revision 1.1  1996/07/19  20:33:52  pinnacle
 * Create VDS 241 project
 *
 * Revision 1.7  1996/05/30  20:46:06  pinnacle
 * Replaced: vdcheckin/func/VDSmainchkin.C for:  by tlbriggs for vds.240
 *
 * Revision 1.6  1996/05/09  13:59:02  pinnacle
 * Replaced: vdcheckin/func/VDSmainchkin.C for:  by sljenks for vds.240
 *
 * Revision 1.5  1996/05/03  15:44:30  pinnacle
 * Replaced: vdcheckin/func/VDSmainchkin.C for:  by sljenks for vds.240
 *
 * Revision 1.4  1995/11/29  13:53:08  pinnacle
 * Replaced: ./vdcheckin/func/VDSmainchkin.C for:  by ksundar for vds.240
 *
 * Revision 1.3  1995/11/06  13:23:14  pinnacle
 * Replaced: vdcheckin/func/VDSmainchkin.C for:  by msbraju for vds.240
 *
 * Revision 1.2  1995/09/25  23:09:30  pinnacle
 * Replaced: vdcheckin/func/VDSmainchkin.C for:  by sundar for vds.240
 *
 * Revision 1.1  1994/11/14  22:42:32  pinnacle
 * Create vds.240 from vds.232
 *
 * Revision 1.1  1994/11/08  16:07:00  pinnacle
 * create vds.232
 *
 *
 * History:
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *	05/01/96	slj		changed malloc, free to _MALLOC, _FREE
 *	05/30/96	tlb		Replace VDS_CHECKIN_MODEL by REP_MODEL
 *	10/17/96	msm		replaced VDPostToDb with VDPostToDb.O
 * -------------------------------------------------------------------*/

/**************************************************************************/
/*                                                                        */
/*      File:           VDSmainchkin.C                                    */
/*      Created by:     Roger Malmgren                                    */
/*      Date:           16 Nov, 1992                                      */
/*                                                                        */
/*      This function displays a form to the user to identify the part id */
/*      of current part for post to database.                             */
/**************************************************************************/
/*      History:        25, Feb 1993.  Mallik				  */
/*			Changes made to remove the Project		  */
/**************************************************************************/

#include        <stdio.h>
#include        "FI.h"


#include        "VX_FIproto.h"


#include        "OMlimits.h"
#include 	"OMprimitives.h"
#include        "exmacros.h"
#include 	"VDmem.h"
#include        "VDScheckin.h"
#include        "PDUerror.h"
#include        "PDUstr.h"
#include        "PDUuser.h"
#include	"igrtypedef.h"
#include	"igetypedef.h"
#include	"godef.h"
#include	"gr.h"
#include	"igr.h"
#include	"igrdp.h"
#include	"go.h"
#include 	"vdbmacros.h"

#define MAX_TEXT_LEN    15
#define MAX_PROJ_LEN    40
#define PART_ID_FORM    10

extern struct PDUrefresh *refresh;
extern struct PDUuser *user;
extern int VD_PDU_present;
char    *in_key;
int     in_to_sql;
static  char cur_filedescr[OM_K_MAXOSNAME_LEN];
static  char cur_filename[OM_K_MAXOSNAME_LEN];
static  char    catalog[81], partid[81], revision[81], filename[81];
static  char    project[81], username[81], passwd[81], environ[81];
static  char	designRep[15];
char    **catalogs, **part_names, **revisions, **buf;
int     n_cat, n_part, n_revision, num;
Form            form_id;

/* Gadgets */
/*
#define PROJECT         23
*/
#define CATALOG         14
#define PART_NAME       15
#define REVISION        16
#define LOCAL_FNAME     17
#define FILE_NAME       22

#define SUCCESS		1
#define FAILURE		0


int VDchk_Get_text (
       Form    fp,            /* Pointer to the form     */
       int     g_label,       /* The label of the gadget */
       char ** text,          /* The text contained in the field */
       int   * text_size)     /* The space allocated for the text */
{
    int status;
    int text_len;
    int field_type;
    int select_flag;
    int row = 0;
    int col = 0;
    int pos = 0;

    status = TRUE;

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

    if ( *text_size < text_len )
    {
        if ( *text_size > 0 )
        {
           /* Realloc space for larger string */
	   *text = _REALLOC (text, text_len, char);
	   _CheckAlloc(text, "realloc:text", status, FALSE, quit);
        }
        else
        {
           /* Calloc space for string */
           *text = _CALLOC(text_len, char);
	   _CheckAlloc(text, "calloc:text", status, FALSE, quit);
        }
        *text_size = text_len;
    }

    if ( ! * text )
    {
      *text_size = 0;
      return ( FI_NO_MEMORY );
    }

    status = FIfld_get_text ( fp, g_label, row, col, *text_size,
                            (unsigned char *)(*text), &select_flag, &pos );
quit:

    return ( status );
}

int     VDSCheckinNotif(f_label, g_label, value, fp)
int     f_label;
int     g_label;
IGRdouble  value;
Form    fp;
{
        int     row,sts;
        static  char    *text;
        static  int     text_size=0;
        char    string[81];
        char    err_msg[256];
        char    io_status[3];
        char    checkin_user[15];
        char    checkout_user[15];
        char    checkout_node[31];
        char    checkout_dir[81];

        FIg_set_text(fp, FI_PROMPT_FIELD, "");
        FIg_set_text(fp, FI_MSG_FIELD, "");

        switch ( g_label )
        {
        case FI_CANCEL:
/* Remove Project
                strcpy(VDSproject_name,"");
*/
                if (!VD_PDU_present)
                {
                   VdsPtrStrcpy(&refresh->rev_catalog,"");
                   VdsPtrStrcpy(&refresh->rev_partid,"");
                   VdsPtrStrcpy(&refresh->rev_revision,"");
                   VdsPtrStrcpy(&refresh->rev_filename,"");
                }
                FIf_delete(fp);
                FIf_erase(fp);

	        _FREE(in_key);

                break;

        case FI_RESET:
/* Remove Project
                project[0] = 0;
                FIg_set_text (fp, PROJECT, "");
*/
                if (!VD_PDU_present)
                {
                   VdsPtrStrcpy(&refresh->rev_catalog,"");
                   VdsPtrStrcpy(&refresh->rev_partid,"");
                   VdsPtrStrcpy(&refresh->rev_revision,"");
                   VdsPtrStrcpy(&refresh->rev_filename,"");
                   FIg_set_text (fp, CATALOG, "");
                   FIg_set_text (fp, PART_NAME, "");
                   FIg_set_text (fp, REVISION, "");
                   FIg_set_text (fp, LOCAL_FNAME, "");
                   FIg_disable (fp, PART_NAME);
                   FIg_disable (fp, REVISION);
                   FIg_disable (fp, LOCAL_FNAME);
                   FIfld_pos_cursor(fp, CATALOG, 0, 0, 0, 0, 1, 1);
                }
                break;

        case FI_ACCEPT:

                if (!VDSverify_catalog(catalog))
                {
                   sprintf(string,"Catalog %s does not exist",catalog);
                   FIg_set_text(fp, FI_MSG_FIELD, string);
                   FIg_set_state_off( fp, FI_ACCEPT);
                   break;
                }
                if (!VDSverify_part(catalog,partid,revision))
                {
                   sprintf(string,"Part %s rev %s does not exist in catalog %s",
                                  partid,revision,catalog);
                   FIg_set_text(fp, FI_MSG_FIELD, string);
                   FIg_set_state_off( fp, FI_ACCEPT);
                   break;
                }
                if (!get_local_fname(catalog,partid,revision,filename))
                {
                   FIg_set_text(fp, FI_MSG_FIELD,
                                "Unable to get local file name from RDB");
                   FIg_set_state_off( fp, FI_ACCEPT);
                   break;
                }
                if (strcmp(cur_filename,filename))
                {
                   FIg_set_text(fp, FI_MSG_FIELD,
                                "Part local file name not same as current file name");
                   FIg_set_state_off( fp, FI_ACCEPT);
                   break;
                }

                if ( VdsRetrievePartAttributes ( catalog,
                                                 partid,
                                                 revision,
                                                 io_status,
                                                 checkin_user,
                                                 checkout_user,
                                                 checkout_node,
                                                 checkout_dir,
                                                 err_msg) != SUCCESS )
                {
                   FIg_set_text(fp, FI_MSG_FIELD,err_msg);
                   FIg_set_state_off( fp, FI_ACCEPT);
                   break;
                }

                if ( io_status[0] != NULL )
                {
                   if ( strcmp(io_status,"O") && strcmp(io_status,"S"))
                   {
                      sprintf(err_msg,"Part %s rev %s is not checked out",
                                    partid, revision);
                      FIg_set_text(fp, FI_MSG_FIELD,err_msg);
                      FIg_set_state_off( fp, FI_ACCEPT);
                      break;
                   }
                   else if (   strcmp(checkout_node,user->wrkst_node)
                            || strcmp(checkout_dir,user->wrkst_cwd)
                            || strcmp(checkout_user,user->username))
                   {
                      sprintf(err_msg,"Part %s rev %s is checked out by %s",
                         partid, revision, checkout_user);
                      FIg_set_text(fp, FI_PROMPT_FIELD,err_msg);
                      sprintf(err_msg,"to %s on node %s",
                                       checkout_dir, checkout_node);
                      FIg_set_text(fp, FI_MSG_FIELD,err_msg);
                      FIg_set_state_off( fp, FI_ACCEPT);
                      break;
                   }
                }

                VDSset_login_defaults(username,environ,project);
                if (!VD_PDU_present)
                {
                   VdsPtrStrcpy(&refresh->rev_catalog,catalog);
                   VdsPtrStrcpy(&refresh->rev_partid,partid);
                   VdsPtrStrcpy(&refresh->rev_revision,revision);
                   VdsPtrStrcpy(&refresh->rev_filename,filename);
                }
                FIf_erase( fp);
                FIf_delete( fp);
                if (!strcmp(in_key,REG_CHECKIN))
                      UI_status ("Regular checkin in progress");
                else  UI_status ("Drawing checkin in progress");

                if (VDScheckin(in_key,in_to_sql,designRep) == SUCCESS)
                {
                   UI_status("Successful completion");
                }

	        _FREE(in_key);

                break;

        case CATALOG:
		/* Button disabled for PDU version */
                sts = VDchk_Get_text ( fp, g_label, &text, &text_size);
                if (!VDSverify_catalog(text))
                {
                   sprintf(string,"Catalog %s does not exist",text);
                   FIg_set_text(fp, FI_MSG_FIELD, string);
                   break;
                }
                strcpy (catalog,text);
                if (!get_part_candidates(cur_filename, catalog, &part_names,
                                         &n_part ))
                {
                   FIg_set_text(fp, FI_MSG_FIELD,"Failed to get valid parts");
                   break;
                }
                if (n_part <= 0 )
                {
                   sprintf(string,"Catalog %s does not contain parts with filename = %s",
                           catalog,cur_filename);
                   FIg_set_text(fp, FI_MSG_FIELD,string);
                   break;
                }
                else
                {
                   if (FIfld_set_list_num_rows(fp,PART_NAME,0,n_part)
                       != FI_SUCCESS)
                   {
                      FIg_set_text(fp, FI_MSG_FIELD,
                              "Failed to set number of rows in part name list");
                      break;
                   }

                   for (row = 0; row < n_part; ++row)
                   {
                      if (VDfld_set_list_text( fp,
                                               PART_NAME,
                                               row,
                                               0,
                                               part_names[row],
                                               1) != FI_SUCCESS)
                      {
                         FIg_set_text(fp, FI_MSG_FIELD,
                                          "Failed to set text in part name list");
                         break;
                      }
                   }
                   vdb$RisFreeBuffer ( buffer = part_names, size = n_part);
                }

                if (! get_first_part_candidate(cur_filename, catalog, partid,
                                               revision, filename))
                {
                   FIg_set_text(fp, FI_MSG_FIELD,
                                        "Failed to get part name and revision");
                   break;
                }

                FIfld_set_text( fp, PART_NAME, 0, 0, partid, 0);
                FIfld_set_text( fp, REVISION, 0, 0, revision, 0);
                FIfld_set_text( fp, LOCAL_FNAME, 0, 0, filename, 0);

                FIg_disable (fp,REVISION);
                break;

        case PART_NAME:
	         /* Button disabled for PDU version */
                sts = VDchk_Get_text ( fp, g_label, &text, &text_size);

                if (!get_revision_candidates(cur_filename,catalog,
                                            text, &revisions,&n_revision ))
                {
                   FIg_set_text(fp, FI_MSG_FIELD,"Failed to get valid revisions");
                   break;
                }
                if (n_revision <= 0 )
                {
                   sprintf(string,"Part %s does not contain revisions with filename = %s",
                           text,cur_filename);
                   FIg_set_text(fp, FI_MSG_FIELD,string);
                   break;
                }
                else
                {
                   if (FIfld_set_list_num_rows(fp,REVISION,0,n_revision)
                       != FI_SUCCESS)
                   {
                      FIg_set_text(fp, FI_MSG_FIELD,
                              "Failed to set number of rows in revision list");
                      break;
                   }

                   for (row = 0; row < n_revision; ++row)
                   {
                      if (VDfld_set_list_text( fp,
                                               REVISION,
                                               row,
                                               0,
                                               revisions[row],
                                               1) != FI_SUCCESS)
                      {
                         FIg_set_text(fp, FI_MSG_FIELD,
                                          "Failed to set text in revision list");
                         break;
                      }
                   }
                   vdb$RisFreeBuffer ( buffer = revisions, size = n_revision);
                }
                strcpy(partid,text);

                strcpy(revision,revisions[0]);
                FIfld_set_text( fp, REVISION, 0, 0, revision, 0);
                FIfld_set_text( fp, LOCAL_FNAME, 0, 0, filename, 0);

                FIg_enable (fp,REVISION);
                break;

        case REVISION:
	          /* Button disabled for PDU version */
                sts = VDchk_Get_text ( fp, g_label, &text, &text_size);
                strcpy(revision,text);
                if (!VDSverify_part(catalog,partid,revision))
                {
                   sprintf(string,"Part %s rev %s does not exist in catalog %s",
                                  partid,revision,catalog);
                   FIg_set_text(fp, FI_MSG_FIELD, string);
                   break;
                }
                if (!get_local_fname(catalog,partid,revision,filename))
                {
                   FIg_set_text(fp, FI_MSG_FIELD,
                                "Unable to get local file name from RDB");
                   break;
                }

                FIg_set_text(fp, LOCAL_FNAME,filename);
                if (strcmp(cur_filename,filename))
                {
                   FIg_set_text(fp, FI_MSG_FIELD,
                                "Part local file name not same as current file name");
                   break;
                }
                break;
        }


        return SUCCESS;
}

int get_local_fname ( catalog, partid, revision, filename)

    char  catalog[];       /* Catalog name   (I) */
    char  partid[];        /* Part name      (I) */
    char  revision[];      /* Revision       (I) */
    char  filename[];      /* File name      (O) */

{
  int   sts;
  char  search[256];
  char  table[81];
  char  n_itemno[81];
  int   n_attr;

  /* ---- Get n_itemno from table <catalog> */

  sprintf ( search, "n_itemname = '%s' and n_itemrev = '%s'", partid,revision);
  n_attr = 1;
  sts = vdb$RisSelect ( select = "n_itemno", table_name = catalog, 
			where = search, 
                numselect = n_attr,p_numrows = &num, p_buffer = &buf);
  if(sts != 1 || num == 0) {sts = 0; goto wrapup;}
  vdb$RisExtractValue ( nbrows = num, nbcolumns = n_attr,  buffer = buf, 
			row =0, column = 0, value = n_itemno);
  vdb$RisFreeBuffer ( buffer = buf, size = n_attr*num);

  /* ---- Get n_cofilename from table f_<catalog> */

  sprintf ( search, "n_itemnum = %s", n_itemno);
  sprintf ( table, "f_%s",catalog);
  n_attr = 1;
  sts = vdb$RisSelect ( select = "n_cofilename", table_name = table, 
			where = search, 
                 numselect =n_attr,p_numrows = &num, p_buffer = &buf);
  if(sts != 1 || num == 0) {sts = 0; goto wrapup;}
  vdb$RisExtractValue ( nbrows = num, nbcolumns = n_attr,  buffer = buf, 
			row = 0,column =  0, value =filename);
wrapup:
  if (num)  vdb$RisFreeBuffer ( buffer = buf, size = n_attr*num);
  return (sts);
}

int get_local_fname2 ( catalog, partid, revision, nRows, fName)

    char  catalog[];       /* Catalog name   (I) */
    char  partid[];        /* Part name      (I) */
    char  revision[];      /* Revision       (I) */
    int   *nRows;	   /* Number of rows (O) */
    char  ***fName;        /* File name      (O) - Memory is allocated
			    * in this function. It should be freed by
			    * calling routine.
			    */
{
  int   sts;
  char  search[256];
  char  table[81];
  char  n_itemno[81];
  int   n_attr;
  int	i;
  int	status;

  status = TRUE;

  /* ---- Get n_itemno from table <catalog> */

  sprintf ( search, "n_itemname = '%s' and n_itemrev = '%s'", partid,revision);
  n_attr = 1;
  sts = vdb$RisSelect ( select = "n_itemno", table_name = catalog, 
			where = search, 
                numselect = n_attr,p_numrows = &num, p_buffer = &buf);
  if(sts != 1 || num == 0) return 0;
  vdb$RisExtractValue ( nbrows = num, nbcolumns = n_attr,  buffer = buf, 
			row =0, column = 0, value = n_itemno);
  vdb$RisFreeBuffer ( buffer = buf, size = n_attr*num);

  /* ---- Get n_cofilename from table f_<catalog> */

  sprintf ( search, "n_itemnum = %s", n_itemno);
  sprintf ( table, "f_%s",catalog);
  n_attr = 1;

  sts = vdb$RisSelect ( select = "n_cofilename", table_name = table, 
			where = search, 
                 numselect =n_attr,p_numrows = &num, p_buffer = &buf);
  if(sts != 1 || num == 0) return 0;
  
  *fName = _MALLOC (num, char* );
  _CheckAlloc(*fName, "*fname", status, FALSE, quit);
  for(i=0; i<num; i++ ) 
      {
	(*fName)[i] = _MALLOC (80, char);
	_CheckAlloc ((*fName)[i], "malloc:fName[i]", status, FALSE, quit);
      }

  for(i=0;i<num;i++) {
	vdb$RisExtractValue ( nbrows = num, nbcolumns = n_attr,  buffer = buf, 
			      row = i,column =  0, value = (*fName)[i]);
  }
  *nRows = num ;
  vdb$RisFreeBuffer ( buffer = buf, size = n_attr*num);

quit:

  return (status);
}

/*************************************************************************/
/*get_catalog_candidates searches for catalogs containing parts with local file
  name same as cur_filename.

  Returns a catalog buffer and number of catalogs found.
*/
int get_catalog_candidates(cur_filename, catalogs, n_cat )

char cur_filename[];    /* Filename to be matched                     (I) */
char **catalogs[];      /* List of catalogs containing matching parts (O) */
int  *n_cat;            /* Number of matching catalogs found          (O) */

/* Returns 1 if OK
           0 if error
*/
{
  int   i,sts;
  char  search[256];
  char  table[81];
  char  n_catalogname[25];
  int   num_cat;
  char  **cat_buf;
  int   n_attr,first;

  sts = 0;

  *catalogs = NULL;
  *n_cat = 0;
  first = 1;

  /* ---- Get n_catalogname from table nfmcatalogs */

  sprintf(search,"n_type != 'P' or n_type is NULL");
  n_attr = 1;
  sts = vdb$RisSelect ( select = "n_catalogname", table_name = "nfmcatalogs", 
			where = search, 
                 numselect =n_attr,p_numrows = &num_cat,p_buffer =  &cat_buf);
  if(sts != 1) return 0;
  if( num_cat <= 0) return 1;

  for (i=0;i<num_cat;i=i+1)
  {
     vdb$RisExtractValue ( nbrows = num_cat,nbcolumns =  n_attr,  
			   buffer = cat_buf, row = i, column = 0, 
			   value = n_catalogname);
     sprintf(table,"f_%s",n_catalogname);
     sprintf(search,"n_cofilename = '%s'",cur_filename);
     n_attr = 1;
     sts = vdb$RisSelect ( select = "n_itemnum",
                          table_name = table, where = search, 
                          numselect =n_attr,p_numrows = &num, p_buffer = &buf);
     if (sts != 1) goto wrapup;
     if (num <= 0) continue;
     if (first)
     {
        first = 0;
	*catalogs = _MALLOC (1, char* );
	_CheckAlloc(*catalogs, "malloc:*catalogs", sts, FALSE, wrapup);
     }
     else
     {
	*catalogs = _REALLOC (*catalogs, *n_cat+1, char* );
	_CheckAlloc(*catalogs, "malloc:*catalogs", sts, FALSE, wrapup);
     }
     (*catalogs)[*n_cat] = _MALLOC (strlen(n_catalogname)+1, char);
      _CheckAlloc((*catalogs)[*n_cat], "malloc:(*catalogs)[*ncat]",
                   sts, FALSE, wrapup);

     strcpy ((*catalogs)[*n_cat],n_catalogname);
     vdb$RisFreeBuffer (buffer =  buf, size = n_attr * num);
     *n_cat = *n_cat + 1;
  }

wrapup:

  if (num_cat) vdb$RisFreeBuffer ( buffer = cat_buf, size = num_cat);

  return sts;
}

/*get_part_candidates searches for part names in a catalog where local file
  name is same as cur_filename.

  Outputs a part name buffer and number of parts found

*/
int get_part_candidates(cur_filename, catalog, part_names, n_part )

char cur_filename[];    /* Filename to be matched                     (I) */
char catalog[];         /* Catalog to be matched                      (I) */
char **part_names[];    /* List of part names having matching filename(O) */
int  *n_part;           /* Number of matching part names found        (O) */

/* Returns 1 if OK
           0 if error
*/
{
  int   i,sts;
  char  search[256];
  char  table[81];
  char  n_itemname[25];
  int   n_attr,first;

  *part_names = NULL;
  *n_part = 0;
  first = 1;

  sprintf(table,"%s,f_%s",catalog,catalog);
  sprintf(search,"n_itemno = n_itemnum and n_cofilename = '%s'",cur_filename);
  n_attr = 1;
  sts = vdb$RisSelect ( select = "distinct n_itemname",
                       table_name = table, where = search, 
                       numselect =n_attr,p_numrows = &num, p_buffer = &buf);
  if (sts != 1) return 0;
  if ( num <= 0) return 1;

  for (i=0;i<num;i=i+1)
  {
     if (first)
     {
        first = 0;
        *part_names = (char **) malloc ( sizeof (char*) );
        if (*part_names == NULL)
        {
           printf ("get_part_candidates : Cannot allocate memory for part buffer\n");
           sts = 0;
           goto wrapup;
        }
     }
     else
     {
        *part_names = (char **) realloc ( *part_names,
					(*n_part + 1) * sizeof (char*) );
        if (*part_names == NULL)
        {
           printf ("get_part_candidates : Cannot re-allocate memory for part buffer\n");
           sts = 0;
           goto wrapup;
        }
     }

     vdb$RisExtractValue ( nbrows = num, nbcolumns = n_attr,  buffer = buf, 
				row = i, column = 0, value = n_itemname);

     (*part_names)[*n_part] = (char *) malloc( (strlen(n_itemname) +1) * sizeof(char) ) ;

     if ((*part_names)[*n_part] == NULL)
     {
        printf ("get_part_candidates : Cannot allocate memory for part buffer\n");
        sts = 0;
        goto wrapup;
     }

     strcpy ((*part_names)[*n_part],n_itemname);
     *n_part = *n_part + 1;
  }

wrapup:
  vdb$RisFreeBuffer ( buffer = buf, size = n_attr * num);
  return sts;
}

/*get_revision_candidates searches for revisions of parts in a catalog where
  local file name is same as cur_filename.

  Outputs a revision buffer and number of revisions found

*/
int get_revision_candidates(cur_filename, catalog, partid, revisions,
    n_revision )

char cur_filename[];    /* Filename to be matched                     (I) */
char catalog[];         /* Catalog to be matched                      (I) */
char partid[];  /* Part name to be matched                    (I) */
char **revisions[];     /* List of part names having matching filename(O) */
int  *n_revision;       /* Number of matching part names found        (O) */

/* Returns 1 if OK
           0 if error
*/
{
  int   i,sts;
  char  search[256];
  char  table[81];
  char  n_itemrev[25];
  int   n_attr,first;

  *revisions = NULL;
  *n_revision = 0;
  first = 1;

  sprintf(table,"%s,f_%s",catalog,catalog);
  sprintf(search,"n_itemno = n_itemnum and n_cofilename = '%s' and n_itemname = '%s'",
                 cur_filename,partid);
  n_attr = 1;
  sts = vdb$RisSelect ( select = "n_itemrev",
                       table_name = table, where = search, 
                       numselect =n_attr,p_numrows = &num, p_buffer = &buf);
  if (sts != 1 || num <= 0) return 0;

  for (i=0;i<num;i=i+1)
  {
     if (first)
     {
        first = 0;
        *revisions = (char **) malloc ( sizeof (char*) );
        if (*revisions == NULL)
        {
           printf ("get_revision_candidates : Cannot allocate memory for part buffer\n");
           sts = 0;
           goto wrapup;
        }
     }
     else
     {
        *revisions = (char **) realloc  ( *revisions,
					(*n_revision + 1) * sizeof (char*) );
        if (*revisions == NULL)
        {
           printf ("get_revision_candidates : Cannot re-allocate memory for part buffer\n");
           sts = 0;
           goto wrapup;
        }
     }

     vdb$RisExtractValue ( nbrows = num, nbcolumns = n_attr,  buffer = buf, 
				row = i, column = 0, value = n_itemrev);

     (*revisions)[*n_revision] = (char *) malloc( (strlen(n_itemrev) +1) * sizeof(char) ) ;

     if ((*revisions)[*n_revision] == NULL)
     {
        printf ("get_revision_candidates : Cannot allocate memory for part buffer\n");
        sts = 0;
        goto wrapup;
     }

     strcpy ((*revisions)[*n_revision],n_itemrev);
     *n_revision = *n_revision + 1;
  }

wrapup:
  vdb$RisFreeBuffer ( buffer = buf, size = n_attr * num);
  return sts;
}

/*get_first_part_candidate searches for parts in a catalog with local file
  name same as cur_filename.

 Outputs first found combination of partid,revision and local filename
*/
int get_first_part_candidate(cur_filename, catalog, partid,
                             revision, filename)

char cur_filename[];    /* Filename to be matched                     (I) */
char catalog[];         /* Catalog to be matched                      (I) */
char partid[];  /* First found matching part name             (O) */
char revision[];        /* First found matching revision              (O) */
char filename[];        /* Filename of matching part                  (O) */

/* Returns 1 if OK
           0 if error
*/
{
  int   sts;
  char  search[256];
  char  table[81];
  int   n_attr;

  sprintf(table,"%s,f_%s",catalog,catalog);
  sprintf(search,"n_itemno = n_itemnum and n_cofilename = '%s'",cur_filename);

  n_attr = 3;
  sts = vdb$RisSelect ( select = "n_itemname,n_itemrev,n_cofilename",
                       table_name = table, where = search, 
                      numselect = n_attr,p_numrows = &num, p_buffer = &buf);
  if (sts != 1 || num <= 0) return 0;

  vdb$RisExtractValue ( nbrows 		= num, 
			nbcolumns 	= n_attr,  
			buffer 		= buf, 
			row 		= 0, 
			column 		= 0, 
			value 		= partid);

  vdb$RisExtractValue ( nbrows 		= num, 
			nbcolumns 	= n_attr,  
			buffer 		= buf,
			row 		= 0, 
			column 		= 1, 
			value 		= revision);

  vdb$RisExtractValue ( nbrows 		= num, 
			nbcolumns 	= n_attr,  
			buffer 		= buf, 
			row 		= 0, 
			column 		= 2, 
			value 		= filename);
  vdb$RisFreeBuffer ( buffer = buf, size = n_attr * num);

  return 1;
}

int     VDSmaincheckin(key, to_sql)

        char *key;
        int  to_sql;

{
   int  row,sts,rev_flag;
   char string[81];
   unsigned char	cRep;
   struct GRsymbology	Symb;

   sts = SUCCESS;
   if (VDSverify_login() != PDM_S_SUCCESS)
   {
      UI_status("User not logged in to Database");
      sts = FAILURE;
      goto wrapup;
   }
   in_key = NULL;
   in_key = _MALLOC (strlen(key) +1, char );
   _CheckAlloc(in_key, "malloc:in_key", sts, FALSE, wrapup);

   strcpy(in_key,key);
   in_to_sql = to_sql;
   strcpy(designRep,REP_MODEL);
   strcpy(catalog,"");
   strcpy(partid,"");
   strcpy(revision,"");
   strcpy(filename,"");

   /* Get current filename */
   ex$filename(name=cur_filedescr, len=OM_K_MAXOSNAME_LEN);
   strcpy(cur_filename,(char *)(strrchr(cur_filedescr,'/') +sizeof(char)));

   if (!VD_PDU_present)
   {
      UI_status("Searching for part...");
      if (!get_catalog_candidates(cur_filename,
                                  &catalogs,
                                  &n_cat))
      {
         UI_status("Failed to get catalog candidates");
         sts = FAILURE;
         goto wrapup;
      }

      if ( n_cat > 0 )
      {
         if (! get_first_part_candidate(cur_filename, catalogs[0], partid,
                                        revision, filename))
         {
            UI_status("Failed to get part name and revision");
            sts = FAILURE;
            goto wrapup;
         }
      strcpy(catalog,catalogs[0]);
      }
   }
   else
   {
      if (VdsDatabaseAccess(username,passwd, project, catalog, partid, revision,
                            filename, &rev_flag ) != SUCCESS)
      {
         sts = FAILURE;
         goto wrapup;
      }
   }
   UI_status("");

   if ( FIf_new(PART_ID_FORM,"VDPostToDb.O",VDSCheckinNotif,&form_id) != FI_SUCCESS)
   {
      UI_status("Failed to create post to data base form");
      sts = FAILURE;
      goto wrapup;
   }

   if (!VD_PDU_present)
   {
      if (n_cat <= 0 )
      {
         /* No catalogs contains parts with local filename = cur_filename */
         /* Disable gadgets */
         FIg_disable (form_id,CATALOG);
         FIg_disable (form_id,PART_NAME);
         FIg_disable (form_id,FI_ACCEPT);
         FIg_disable (form_id,FI_RESET);
         sprintf(string,"No catalog contains a part with filename = %s",cur_filename);
         FIg_set_text(form_id, FI_MSG_FIELD,string);

      }
      else
      {
         /* Update catalogs associated list */
         if (FIfld_set_list_num_rows(form_id,CATALOG,0,n_cat)
             != FI_SUCCESS)
         {
            UI_status("Failed to set number of rows in catalog list");
            sts = FAILURE;
            goto wrapup;
         }

         for (row = 0; row < n_cat; ++row)
         {
            if (VDfld_set_list_text( form_id,
                                     CATALOG,
                                     row,
                                     0,
                                     catalogs[row],
                                     1) != FI_SUCCESS)
            {
               UI_status("Failed to set text in catalog list");
               sts = FAILURE;
               goto wrapup;
            }
         }
         vdb$RisFreeBuffer ( buffer = catalogs, size = n_cat);

         /* Update part names associated list */
         if (!get_part_candidates(cur_filename, catalog, &part_names,
                                  &n_part ))
         {
            UI_status("Failed to get valid parts");
            sts = FAILURE;
            goto wrapup;
         }
         if (n_part <= 0 )
         {
            sprintf(string,"Catalog %s does not contain parts with filename = %s",
                            catalog,cur_filename);
            FIg_set_text(form_id, FI_MSG_FIELD,string);
         }
         else
         {
            if (FIfld_set_list_num_rows(form_id,PART_NAME,0,n_part) != FI_SUCCESS)
            {
               FIg_set_text(form_id, FI_MSG_FIELD,
                           "Failed to set number of rows in part name list");
            }
            for (row = 0; row < n_part; ++row)
            {
               if (VDfld_set_list_text( form_id,
                                        PART_NAME,
                                        row,
                                        0,
                                        part_names[row],
                                        1) != FI_SUCCESS)
               {
                  FIg_set_text(form_id, FI_MSG_FIELD,
                                     "Failed to set text in part name list");
               }
            }
            vdb$RisFreeBuffer ( buffer = part_names, size = n_part);
         }
      }
   }
   else
   {
      /* Disable gadgets for PDU version */
      FIg_disable (form_id,CATALOG);
      FIg_disable (form_id,PART_NAME);
      FIg_disable (form_id,REVISION);
   }

   VDSget_login_defaults(username,environ,project);
   ACget_def_NVrep( &cRep, &Symb );

/* Remove Project   2-25-1993
   if ( vdb$RisSelect ( select = "prj_name", table_name = "vds_project", 
			 numselect =1,p_numrows = &num, p_buffer = &buf) != 1)
   {
      UI_status("Failed to get list of projects");
      sts = 0;
      goto wrapup;
   }
   for (row = 0; row < num; ++row)
   {
      if (VDfld_set_list_text( form_id,
                               PROJECT,
                               row,
                               0,
                               buf[row],
                               1) != FI_SUCCESS)
      {
         UI_status("Failed to set text in project list");
         vdb$RisFreeBuffer ( buffer = buf, size = num);
         sts = 0;
         goto wrapup;
      }
   }

   FIfld_set_text( form_id, PROJECT, 0, 0, project, 0);
2-25-1993  */

   FIfld_set_text( form_id, CATALOG, 0, 0, catalog, 0);
   FIfld_set_text( form_id, PART_NAME, 0, 0, partid, 0);
   FIfld_set_text( form_id, REVISION, 0, 0, revision, 0);
   FIfld_set_text( form_id, LOCAL_FNAME, 0, 0, filename, 0);
   FIg_set_text(form_id, FILE_NAME, cur_filedescr);
   FIg_disable (form_id,REVISION);

   if ( FIf_display( form_id ) != FI_SUCCESS)
   {
         UI_status("Failed to display post to data base form");
         sts = FAILURE;
         goto wrapup;
   }

wrapup:

   return sts;
}
