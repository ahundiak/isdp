/****************************************************************************

Name
   pdmoModifyAssembly

Abstract
 Modifies the assembly stucture of the part


Description

To modify a non-graphic assembly, a add list of 1-level children  and
a delete list of 1-level children are given.
It validates the entries in add_list [It adds to the database,
if the parts doesn't exist in the case of VIEW catalogs].
It validates the entries in delete_list and deletes it from the cit/pdmcit.
[It it's the view part and it's the last occurence it deletes from the
 e_catalog table also].

Function protocol

long pdmoModifyAssembly (
                        char *cpr_catalog,
                        char *cpr_partnum, 
                        char *cpr_revsion,
                       struct PDMassembly_member *spr_PDMadd_to_structure, 
                       struct PDMassembly_member *spr_PDMdelete_from_structure
                         )

   Input:

     char *cpr_catalog - Catalog of the part to be defined.
     char *cpr_partnum - Partnum of the part to be defined.
     char *cpr_revision -Revision of the part to be defined.
   PDMchildren spr_PDMadd_to_structure - children info which needs to be
addedd
                                      to the assembly.

        {
        int     im_n_citno;      / System defined - Leave it  - N /
        int     im_n_pcatalogno; / System defined - Leave it  - N /
        int     im_n_pitemno;    / System defined - Leave it  - N/
        int     im_n_ccatalogno; / System defined - Leave it  - N/
        int     im_n_citemno;    / System defined - Leave it  - N/
        int     ir_p_level;/ Level no of the assembly-Default 1 - OPTIONAL /
        cha     caw_n_setindicator[2]; / System defined -Leave it -N/
        cha     caw_n_status[3];  / System defined - Leave it  - N/
        int     im_p_pchildno;    / System defined - Leave it  - N/
        int     ir_p_childno;    /  Child no of the like parts in the
                                    same level, if multiple parts
                                    are defined without this input
                                   system will assign it - OPTIONAL/
        char    car_n_catalogname[21]; /Catalogname of the child - INPUT /
        char    *cpr_n_itemname;      /Partnumber of the child   - INPUT /
        char    *cpr_n_itemrev;       /Revision   of the child   - INPUT /
        char    *cpr_n_itemdesc;      /Description of the child  - INPUT /
        char    car_p_attached[2];/Display flag of the child - Leave it -N /
        double  dr_p_quantity;   / Quantity of the child - Default 1
OPTIONAL/
        char    car_p_usgaeid[25]; / Usage ID - OPTIONAL /
        char    car_n_cofilename[14]; /Filename of the part - OPTIONAL /
        int     ir_p_tagno;  / Tagno - OPTIONAL - Default system generates /
        char    car_p_alttagno;/ ALttagno -OPTIONAL-Default system generates
/
        spr_children      *next;/ NEXT child pointer of linked list or NULL
/
        }* spr_PDMchildren;
pdmoLoadChildStructure can be used to load the structure.
       PDMchildren spr_PDMdelete_from_structure - children info which needs to
be deleted from the assembly.

        {
        int     im_n_citno;      / System defined - Leave it  - N /
        int     im_n_pcatalogno; / System defined - Leave it  - N /
        int     im_n_pitemno;    / System defined - Leave it  - N/
        int     im_n_ccatalogno; / System defined - Leave it  - N/
        int     im_n_citemno;    / System defined - Leave it  - N/
        int     ir_p_level;/ Level no of the assembly-Default 1 - OPTIONAL/
        cha     caw_n_setindicator[2]; / System defined -Leave it -N/
        cha     caw_n_status[3];  / System defined - Leave it  - N/
        int     im_p_pchildno;    / System defined - Leave it  - N/
        int     ir_p_childno;    / Child no of the like parts in the
                                    same level, if multiple parts
                                    are defined without this input
                                   system will assign it - OPTIONAL/
        char    car_n_catalogname[21]; /Catalogname of the child - INPUT /
        char    *cpr_n_itemname;      /Partnumber of the child   - INPUT /
        char    *cpr_n_itemrev;       /Revision   of the child   - INPUT /
        char    *cpr_n_itemdesc;      /Description of the child  - INPUT /
        char    car_p_attached[2];/Display flag of the child - Leave it -N /
        double  dr_p_quantity;   / Quantity of the child - Default 1
OPTIONAL/
        char    car_p_usgaeid[25]; / Usage ID - OPTIONAL /
        char    car_n_cofilename[14]; /Filename of the part - OPTIONAL /
        int     ir_p_tagno;  / Tagno - OPTIONAL - Default system generates /
        char    car_p_alttagno;/ ALttagno -OPTIONAL-Default system generates
/
        spr_children      *next;/NEXT child pointer of linked list or NULL
/
        }* spr_PDMchildren;

pdmoLoadChildStructure can be used to load the structure.

Input Constraints:
  cpr_n_catalogname:    required
                        16 characters or less
                        must already exist

  cpr_n_itemname:       required
                        ! * ? , : invalid characters
                        must not exceed the number of characters specified
                        at catalog creation time
  cpr_n_itemrev:        required
                        ! * ? , : invalid characters
                        must not exceed the number of characters specified
                        at catalog creation time
  ir_p_tagno            Cannot be zero or negative
  ir_p_quantity         Cannot be zero or negative



Output :
       None
Input/Output:
       None


Algorithm:
    Check whether the user is logged in?
     (Yes)
     (No) return PDM_E_USER_NOT_LOGGED_IN!
     ?
    Check whether the user has the access to modif?
     (Yes)
     (No) return PDM_E_VALIDATE_USER_ACCESS!
     ?
    Check for it's existence, Exists?
     (YES)
     (No) return PDM_E_ASSEMBLY_NOT_FOUND!
     ?end
     Check for the catalog type , Is it "P", "CID", "EID"?
       (Yes) return PDM_E_PARAMETRIC_STRUCTURE!
        (No)
      ?end
     Check the usage ID of the given child. Is it there?
      (YES)
      (No) Call the PDMget_usage_id, then return status.
      ?end
     Check for the input tagno, Is it there?
      (YES) Validate the tagno.
      (No)  Generate instance_no  which will be used for tag_no, Is it success?
           (Yes) Load it.
           (No)  instance_no = 1.
           ?end
      ?end
      Check for the Alt  tagno for the children. Does it exist?
       (Yes)  Validate it.
       (No)  Carry over the tagno to alttagno.
      ?end
     Check for the  child no for the children.
       (Yes) Validate it.
       (No)  Generate the child no- Success?
             (Yes)
             (No) childno = 1!
             ?end
        ?end
      get PDMget_assembly_structure, Is is successful?
       (Yes) Validate the structure.
       (No)
       ?end
      Delete the children as from the delete list.
      Add the children as from the add list.
      Call PDMdefine_assembly_structure()
       Get Catalog nos and Part nos SUCCESS?
      (Yes)
      (No) > return error!
      ?end
       Add p_citno,n_catalogno,n_itemno,pn_catalogno,pn_itemno,p_flag:
       Expand the assembly Bufr SUCCESS?
        (Yes)
        (No) > return error!
       ?end
       Get Assembly indicator SUCCESS?
        (Yes)
        (No) > return error!
       ?end
       Load children's catalognos and itemnos SUCCESS?
         (Yes)
         (No) > WRAPUP
       ?end
       Load parent's catalognos and itemnos SUCCESS?
         (Yes)
         (No) > WRAPUP
       ?end
       If PDMexec->operation is 1 ?
         (Yes)
          Check assembly structure for cyclic placement SUCCESS?
           (Yes)
           (No) > WRAPUP
            ?end
         (No)
       ?end
       SET AUTOCOMMIT OFF?
      (Yes)
      (No) > return error!
      ?end
      LOCK PDMCIT Loop for 2 minutes - SUCCESS?
      (Yes)
      (No) > return error!
      ?end
        If assembly indicator is set to "Y" ?
      (Yes)
          Drop all its first level children - SUCCESS?
           (Yes)
           (No) > WRAPUP
            ?end
        (No)
       ?end
       LOAD THE first level children into NFMSETCIT - SUCCESS?
         (Yes)
         (No) > WRAPUP
        ?end
       Change p_incbom based on p_incstr and p_incbom for background part.
       LOAD THE first level children into PDMCIT - SUCCESS?
         (Yes)
          (No) > WRAPUP
        ?end
       SET the n_setindicator to "Y".
       SET AUTOCOMMIT ON?
        (Yes)
        (No) > return error!
        ?end
        -WRAPUP
        ROLLBACK TRANSACTION.
        RETURN status!

DEPENDENCIES

Assumptions:
  1. The part is checked in/Never checked in.
  2. Parts are know to the database, except the view parts.
  3. Parts are yet to be positioned.
  4. Parts are not cyclic, except for the background attachement.
  5. The user has the access the change the defintion of the part.
  6. The part is not flagged for delete, restore, backup, archive.
  7. The part is backuped, or archived.
  8. You can't change parametric assemblies.
  9. You can't change nth level structure.
  10.The user must be logged into PDM database.

Globals used.
   ALL globals needed for Validate user access.
   All globals needed for login

Database schema impact:
   NFMSETCIT, PDMCIT gets changed
   p_incpartrpt,n_setindicator of catalog table gets changed

Functions called
1.PDMsdefine_assembly_structure
2.PDMquery_catalog_partnos
3.MEM functions
4.PDMexpand_copy_buffer
5.PDMquery_assembly_ind
6.PDMload_partnos
7.PDMload_parentnos
8.PDMcheck_cycles
9.PDMstop_transaction
10.SQLstmt
11.PDMdron_setindicator
12.PDMload_set_members
13.PDMset_n_setindicator
14.PDMstart_transaction

Feature Level Impact.

1. This will affect checkout and activate to update the current
   product structure.
2. This will affect the reports.


MODULARITY

Reused functions:

1.PDMquery_catalog_partnos  - used everywhere
2.MEM functions             - used everywhere
3.PDMexpand_copy_buffer     - Data defintion functionality
4.PDMquery_assembly_ind     - used everywhere
5.PDMload_partnos           - List local files
6.PDMstop_transaction       - used everywhere
7.SQLstmt                   - used everywhere
8.PDMdron_setindicator      - Checkin
9.PDMload_set_members       - Checkin
10.PDMset_n_setindicator    - Checkin
11.PDMstart_transaction     - used everywhere

Extensiblity:

1. Can be later in PDM2.4+ for taking care of EMS parts.
2. Can be used in the Update DB command.


Return Values

PDM_S_SUCCESS               -   Succesful Completion
PDM_E_CATALOG_NOT_FOUND     -   A given catalog is not there in the DB.
PDM_E_PART_NOT_FOUND        -   A given part/rev is not there in the DB.
PDM_E_CAT_FIELD_BLANK       -   Catalog field empty
PDM_E_PART_FIELD_BLANK      -   Partnum field empty
PDM_E_REV_FIELD_BLANK       -   Revison field empty
PDM_E_INVALID_PART_TYPE     -   Invalid part ype
PDM_I_TABLE_LOCKED          -   Concurrent access, the table is locked
PDM_E_LOCK_CIT              -   CIT is locked, Please try later.
PDM_E_SQL_STMT              -   Invalid data
PDM_E_VALIDATE_USER_ACCESS  -   User doesn't have the access to modify.



Notes

Index
STRUCTURE,ASSEMBLY,NON-GRAPHIC EDITING
Keywords
EDITING,STRUCTURE,ASSEMBLY,DEFINE ASSEMBLY

History
   Kumar Narayanan Sun Jul 11 16:50:39 CDT 1993: Initial Creation
****************************************************************************/


/****************************************************************************
Include Files
****************************************************************************/
#include                <stdio.h>
#include                "PDUerror.h"
#include                "MEMstruct.h"
#include                "MEMerrordef.h"
#include                "NFMerrordef.h"
#include                "SQLerrordef.h"
#include                "PDUpdmrpro.h"
#include                "UMS.h"
#include 		"PDMapi.h"
#include		"PDMproto.h"
#include		"PDUproto.h"

extern  int             PDMdebug_on;
extern  char            PDM_DEBUG_FILE[];
extern  PDMexec_ptr     PDMexec;
extern  PDMpart_ptr     PDMpart;



/****************************************************************************
Main Function
****************************************************************************/


int pdmoModifyAssembly (char *cpr_catalog, char *cpr_partnum, char *cpr_revision, struct PDMassembly_member *spr_PDMadd_to_structure,  struct PDMassembly_member *spr_PDMdelete_from_structure)

{
char *fname = "pdmoModifyAssembly";
PDMchildren spr_PDMstructure = NULL, spr_current_node = NULL;
PDMchildren  spr_temp = NULL, spr_delete = NULL;
PDMchildren  spr_add = NULL;
MEMptr       xpw_assy_bufr = NULL, xpw_structure = NULL;
int          cpw_catno = 0, iw_length = 0;
char         cpw_type[6] = "", *cpw_message = NULL, *cpr_usageid = NULL;
long         status = PDM_S_SUCCESS, status1 = NFM_S_SUCCESS;

   _PDMdebug(fname,"Enter\n");

   /* Check for login */
   if(!pdmcheck_log_in()) 
       {
       _PDMdebug(fname,"User has not logged into the database\n");
       return (PDM_E_USER_NOT_LOGGED_IN);
        }
      
   /* Validate the user access*/
     status = PDMvalidate_user_access("PDMUpdate Assembly Structure", "",
           cpr_catalog, "", cpr_partnum, cpr_revision );
     if (status != PDM_S_SUCCESS)
      {
      _PDMdebug(fname,"User does not access to Update the Assembly strcture\n");
       return(status);
      }

    /* This operation is not valid on parametric parts */
    status = PDMget_catno_type(cpr_catalog,&cpw_catno, cpw_type);
                if(status != SQL_S_SUCCESS)
                {
                       if(status == SQL_I_NO_ROWS_FOUND) ;
                       else
                       {
  _PDMdebug(fname,"Parametric Parts can't be Updated  for the Assembly strcture\n");
                       return(status);
                       }
                 }
    if(!strcmp(cpw_type,"P") || !strcmp(cpw_type,"CID") || !strcmp(cpw_type,"EID"))
      {
  _PDMdebug(fname,"Assembly Structure of Parametric Parts can't be Updated\n");
       return(PDM_E_PARAMETRIC_STRUCTURE);
      }
       

    /* Validate the part for this command based upon the
       current status of the part */

       status = PDMload_part_info(cpr_catalog, cpr_partnum, cpr_revision);
        if (status != PDM_S_SUCCESS) 
        {
     _PDMdebug (fname, "PDMload_part_info failed status <0x%x.8>\n", status);
        return (status);
        }
     _PDMdebug(fname, "parttype = %s, n_status = %s\n",  PDMpart.p_parttype,
                       PDMpart.n_status);

    /* Check whether the part is not checked out */ 
      if(!strcmp(PDMpart.n_status,"O") || !strcmp(PDMpart.n_status,"S"))
      {
  _PDMdebug(fname,"Assembly Structure of Checked Out Part can't be Updated\n");
      return(PDM_E_PART_CHECKED_OUT);
     }

  /* Check the part for flagging */
      if ((!strncmp(PDMpart.n_pendingflag, "IA", 2))
         || (!strncmp(PDMpart.n_pendingflag, "SA", 2))) {
                _PDMdebug (fname,  "Part is flagged for achive\n");
                return (PDM_E_PART_FLAGGED_FOR_ARCHIVE);
           }
        else if ((!strncmp(PDMpart.n_pendingflag, "IB", 2))
         || (!strncmp(PDMpart.n_pendingflag, "SB", 2)))
           {
           _PDMdebug (fname,  "Part is flagged for backup\n");
                return (PDM_E_PART_FLAGGED_FOR_BACKUP);
           }
        else if ((!strncmp(PDMpart.n_pendingflag, "ID", 2))
         || (!strncmp(PDMpart.n_pendingflag, "SD", 2)))
           {
           _PDMdebug (fname,  "Part is flagged for delete\n");
                return (PDM_E_PART_FLAGGED_FOR_DELETE);
           }
        else if ((!strncmp(PDMpart.n_pendingflag, "IR", 2))
         || (!strncmp(PDMpart.n_pendingflag, "SR", 2)))
           {
            _PDMdebug (fname,  "Part is flagged for delete\n");
                return (PDM_E_PART_FLAGGED_FOR_RESTORE);
           }

    /* Get the current product structure from the database */
   
      status = PDMquery_ass_struc (cpr_catalog, 
                                   cpr_partnum, 
                                   cpr_revision, 
                                   1, 
                                   "Y", 
                                   0,
                                   &xpw_assy_bufr);
     if(status != PDM_S_SUCCESS)
     {
     _PDMdebug(fname, "Query assembly structure failed status %d\n", status);
      return(status);
     }

    /* Convert this assembly structure to a linklist */

     status = PDMassy_buffer_to_linklist(xpw_assy_bufr, &spr_PDMstructure);
       if(status != PDM_S_SUCCESS)
         {
     _PDMdebug(fname, "PDMassy_buffer_to_linklist failed status %d\n", status);
      return(status);
          }

/*Scan the linked list to drop the nodes in the spr_PDMdelete_from_structure */

     spr_delete = spr_PDMdelete_from_structure;

    while(spr_delete != NULL)
        {
      status =  PDMdrop_node_from_linklist(spr_delete->car_n_catalogname, spr_delete->cpr_n_itemname, spr_delete->cpr_n_itemrev, spr_delete->ir_p_childno, spr_delete->car_p_usageid, &spr_PDMstructure);
       if(status != PDM_S_SUCCESS)
       {
        _PDMdebug(fname, "Couldn't delete <%s> <%s> <%s> from the existing \
                          structure \n", spr_delete->car_n_catalogname, \
                       spr_delete->cpr_n_itemname, spr_delete->cpr_n_itemrev);
         return(status);
       }
        spr_delete = spr_delete->next;
      }
   /* Scan the list to add the nodes from spr_PDMadd_to_structure to spr_PDMstructure */

     spr_add = spr_PDMadd_to_structure ;

    if(spr_add)
     {
       if(spr_PDMstructure)
       {
        spr_temp = spr_PDMstructure;
      while(spr_temp->next != NULL) spr_temp = spr_temp->next;
      spr_temp->next = spr_add;
         }
    }

      
 spr_current_node = spr_PDMstructure;

   while(spr_current_node->next != NULL)
   {

   /* Set the level always to 1 */
     spr_current_node->ir_p_level = 1;

   /* Generate the usage id for the part, if it doesn't exist */
    if(!strcmp(spr_current_node->car_p_usageid,""))
    {
   status = PDMget_usageid_cat(spr_current_node->car_n_catalogname, &cpr_usageid);
   if((status != PDM_S_SUCCESS) || (cpr_usageid == NULL) || (!strcmp(cpr_usageid,"")))
       {
      /* Generate the default usage id */
          iw_length = strlen(spr_current_node->cpr_n_itemname) + strlen(spr_current_node->cpr_n_itemrev) + 10;

         cpr_usageid = (char *) malloc (sizeof (char) * iw_length);
         strcpy(cpr_usageid, spr_current_node->cpr_n_itemname);
         strcpy(cpr_usageid, " ");
         strcat(cpr_usageid, spr_current_node->cpr_n_itemrev);
     
      status = PDMfind_instanceno_in_linklist(spr_PDMstructure, &cpr_usageid);
      if(status != PDM_S_SUCCESS) strcat(cpr_usageid," # 1");
      }
      strncpy(spr_current_node->car_p_usageid, cpr_usageid,25);
     }

  /* Assign the quantity, if it is not assigned */
     if(spr_current_node->dr_p_quantity <= 0) 
         spr_current_node->dr_p_quantity = 1.000;
 
 /* Generate the p_childno for the first level kids */
spr_current_node->ir_p_childno = PDMfind_childno_in_linklist(spr_PDMstructure);
     if(spr_current_node->ir_p_childno <= 0) 
         spr_current_node->ir_p_childno = 1;

  /* Set the p_attached to always to "N"  - OVERRIDE the attached flag*/
   strcpy(spr_current_node->car_p_attached,"N");

 /* Generate the Tag number, if it's not assigned */
  if(spr_current_node->ir_p_tagno <=0 ) 
      {
       spr_current_node->ir_p_tagno = PDMgenerate_tagno_from_linklist(spr_PDMstructure);
       if(spr_current_node->ir_p_tagno <=0 ) spr_current_node->ir_p_tagno = 1;
       }

  /* Carry over the tagno to alt_tagno if it's not assigned */
  if(!strcmp(spr_current_node->car_p_alttagno,"") ) 
 sprintf(spr_current_node->car_p_alttagno, "%d", spr_current_node->ir_p_tagno);

  /* Set the defaults, if it's not set */

  if(!strcmp(spr_current_node->car_p_incbom,"") ) 
   strcpy(spr_current_node->car_p_incbom,"Y");
  if(!strcmp(spr_current_node->car_p_explode,"") ) 
   strcpy(spr_current_node->car_p_explode,"Y");
  if(!strcmp(spr_current_node->car_p_incstr,"") ) 
   strcpy(spr_current_node->car_p_incstr,"Y");

       spr_current_node = spr_current_node->next;
   } 

   /* Convert the linked list to a MEM buffer so as to use the
      existing function for defining assembly structure */

     if(spr_PDMstructure != NULL)
     {
      status = PDMassy_linklist_to_buffer(spr_PDMstructure, &xpw_structure);
      if(status != PDM_S_SUCCESS)
      {
       _PDMdebug(fname, "PDMassy_linklist_buffer failed status %d\n", status);
       return(status);
      }
     }

    PDMstrcpy(cpr_catalog, &PDMexec->catalog);
    PDMstrcpy(cpr_partnum, &PDMexec->part_num);
    PDMstrcpy(cpr_revision, &PDMexec->revision);

   /* call the PDM function to define the assembly structure. This function
      is both used in the GUI and the API */

    if(xpw_structure != NULL)
     {
       status = PDMsdefine_assembly_structure(xpw_structure);
       if(status != PDM_S_SUCCESS)
        {
         _PDMdebug(fname, "PDMsdefine_assembly_structure failed status %d\n", status);
         return(status);
       }
    }

   /* Convert the status to a message string */
      if ((status1 = UMSGetByNum (cpw_message, status, NULL)) != UMS_S_SUCCESS)
          {
           _PDMdebug(fname, "UNKNOWN: %d\n", status );
          }

    /* Make a log of this command and corresponding transition */
    /* If set_to_state fails, don't return a error, ignore it */
      if ((status1 = PDMset_to_state (status, "PDM", cpw_message)) != PDM_S_SUCCESS)
       _PDMdebug(fname, "PDMset_to_state failed status %d\n", status1);
       
     _PDMdebug(fname,"Exit - SUCCESSFUL COMPLETION\n");
     return(PDM_S_SUCCESS);
}
