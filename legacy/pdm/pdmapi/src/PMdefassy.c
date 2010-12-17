/****************************************************************************

Name
   pdmoDefineAssembly

Abstract

Synopsis
  int pdmoDefineAssembly ( )

Description

 Defines the assembly stucture of the part 
 To define a non-graphic assembly, a list of 1-level children are given.

Algorithm:

   Input:
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

 

   Input/Output:

   Output:

   Algorithm:
   1)

Return Values

Notes

Index

Keywords

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
#include                "PDMproto.h"
#include                "PDUpdmrpro.h"
#include                "PDMapi.h"
#include                "UMS.h"

extern  int             PDMdebug_on;
extern  char            PDM_DEBUG_FILE[];
extern  PDMexec_ptr     PDMexec;
extern  PDMpart_ptr     PDMpart;




/****************************************************************************
Main Function
****************************************************************************/


int pdmoDefineAssembly
                (
               char *cpr_catalog, 
               char *cpr_partnum, 
               char *cpr_revision, 
               struct PDMassembly_member *spr_PDMstructure
                )

{

char *fname = "pdmoDefineAssembly";
PDMchildren  spr_current_node = NULL;
MEMptr       xpw_structure = NULL;
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
     status = PDMvalidate_user_access("PDMDefine Modify Assembly Structure", "",
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
           _PDMdebug(fname, "UNKNOWN: %d\n", status );

    /* Make a log of this command and corresponding transition */
    /* If set_to_state fails, don't return a error, ignore it */
      if ((status1 = PDMset_to_state (status, "PDM", cpw_message)) != PDM_S_SUCCESS)
       _PDMdebug(fname, "PDMset_to_state failed status %d\n", status1);
       
     _PDMdebug(fname,"Exit - SUCCESSFUL COMPLETION\n");
     return(PDM_S_SUCCESS);
}
