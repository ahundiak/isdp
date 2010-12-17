#include <stdio.h>
#include "PDUintdef.h"
#include "PDUerror.h"
#include "PDUfile_def.h"
#include "PDUforms.h"
#include "PDUstr.h"
#include "MEMstruct.h"
#include "MEMerrordef.h"
#include "PDMapi.h"
#include "PDMproto.h"
#include "PDUproto.h"

extern int PDMdebug_on;



void  PDMstrcpy 
  (
  char  *cpr_value,
  char  **cppw_variable
  )
  {
  if ( (cpr_value != NULL) && strcmp(cpr_value, "") )
     {
     *cppw_variable = (char *) malloc ( strlen(cpr_value) + 1);
     strcpy (*cppw_variable, cpr_value);
     }
  }

int PDMassy_linklist_to_buffer
  (
  PDMchildren     spr_head,
  MEMptr          *xpw_buffer
  )
{
  int		status = PDM_S_SUCCESS;
  char          *fname = "PDMassy_linklist_to_buffer";
  PDMchildren     spw_current = NULL;
  char           car_quant[33] = "", car_tagno[33] = "";
  char          *cpw_line;

  _PDMdebug(fname,"Enter\n");

  status = PDUformat_buffer(PDU_CHILD_BUFR, xpw_buffer);
  if (status != PDM_S_SUCCESS)
  {
   MEMclose(xpw_buffer);
   _PDMdebug(fname, "Formatting of buffer failes status %d\n", status);
   return(status);
  }

  cpw_line = (char *) malloc (1024);
  memset(cpw_line, NULL, 1024);

  spw_current = spr_head;

  while (spw_current)
     {
     if (spw_current->ir_p_level == 1)
       {
      strcpy(cpw_line, "");
      strcpy(car_quant, "");
 sprintf(car_quant, "%f", (float) spw_current->dr_p_quantity);
       sprintf(cpw_line, 
        "%d\1%s\1%s\1%s\1N\1%s\1%s\1%d\1%s\1%s\1%s\1%s\1%s\1%s\1\1\1%d\1",
                     spw_current->ir_p_childno,
                     spw_current->car_n_catalogname,
                     spw_current->cpr_n_itemname,
                     spw_current->cpr_n_itemrev,
                     car_quant,
                     spw_current->car_p_usageid,
                     spw_current->ir_p_tagno,
                     spw_current->car_p_alttagno,
                     spw_current->car_p_incbom,
                     spw_current->car_p_incstr,
                     spw_current->car_p_explode,
                     spw_current->car_n_cofilename,
                     spw_current->car_p_history,
                     spw_current->ir_p_level);

       _PDMdebug(fname, "cpw_line1 %s\n", cpw_line);

 sprintf(cpw_line, "%d", spw_current->ir_p_childno); strcat(cpw_line,"\1");
 strcat(cpw_line, spw_current->car_n_catalogname); strcat(cpw_line,"\1");
 strcat(cpw_line, spw_current->cpr_n_itemname); strcat(cpw_line,"\1");
 strcat(cpw_line, spw_current->cpr_n_itemrev); strcat(cpw_line,"\1");
 strcat(cpw_line, "N"); strcat(cpw_line, "\1");
 strcat(cpw_line, car_quant); strcat(cpw_line,"\1");
 strcat(cpw_line, spw_current->car_p_usageid); strcat(cpw_line,"\1");
 sprintf(car_tagno, "%d", spw_current->ir_p_tagno);
 strcat(cpw_line, car_tagno); strcat(cpw_line,"\1");
 strcat(cpw_line, spw_current->car_p_alttagno); strcat(cpw_line,"\1");
 strcat(cpw_line, spw_current->car_p_incbom); strcat(cpw_line,"\1");
 strcat(cpw_line, spw_current->car_p_incstr); strcat(cpw_line,"\1");
 strcat(cpw_line, spw_current->car_p_explode); strcat(cpw_line,"\1");
 strcat(cpw_line, spw_current->car_n_cofilename); strcat(cpw_line,"\1");
 strcat(cpw_line, spw_current->car_p_history); strcat(cpw_line,"\1");
 strcat(cpw_line,"\1\1");
 strcat(cpw_line,"1"); strcat(cpw_line,"\1");

       _PDMdebug(fname, "cpw_line %s\n", cpw_line);
       status = MEMwrite(*xpw_buffer, cpw_line);
       if (status != MEM_S_SUCCESS)
         {
          MEMclose(xpw_buffer);
         _PDMdebug(fname, "MEMwrite failed status %d\n", status);
         return(status);
         }
       }
     spw_current = spw_current->next;
     }

  if (PDMdebug_on)
    MEMprint_buffer("assembly buffer", *xpw_buffer, PDM_DEBUG_FILE);

  _PDMdebug(fname,"Exit\n");
    return(PDM_S_SUCCESS);
}  



int PDMassy_buffer_to_linklist
     (
  MEMptr    assy_bufr,
  PDMchildren *spr_PDMstructure
     )
{
  int                      status = PDM_S_SUCCESS;
  PDMchildren              spr_temp = NULL, spr_tail = NULL;
  char                     **data = NULL, **columns = NULL;
  char                     *fname = "PDMassy_buffer_to_linklist";
  short                    i =0, m1 = -1, m2 = -1, m3 = -1, m4 = -1;
  short                    m6 = -1, m7 = -1, m8 = -1;
  short                    m9 = -1, m10 = -1, m11 = -1, m12 = -1;
  short                    m13 = -1, m14 = -1, m15 = -1, m16 = -1;
  short                    m17 = -1, m18 = -1, row = 0;
  short                    nx = 0;
  double                   p_quantity = 1.0;

  _PDMdebug(fname, "Enter\n");
  if ((assy_bufr == NULL) || (assy_bufr->rows <= 1))
    {
    _PDMdebug(fname, "assembly buffer is empty!!\n");
    return(PDM_E_NULL_BUFFER);
    }
  else
    {
     MEMprint_buffer("assy_bufr", assy_bufr,PDM_DEBUG_FILE);
    status = MEMbuild_array(assy_bufr);
     if(status != MEM_S_SUCCESS)
     {
      _PDMdebug(fname,"MEMbuild_array status %d\n", status);
      return(status);
     }

        data = (char **) assy_bufr->data_ptr;
        columns = (char **) assy_bufr->column_ptr;
        for(i=0;i<assy_bufr->columns;i++)
        {
                if (!strcmp(columns[i], "n_catalogname")) m1 = i;
        else    if (!strcmp(columns[i], "n_itemname")) m2 = i;
        else    if (!strcmp(columns[i], "n_itemrev")) m3 = i;
        else    if (!strcmp(columns[i], "p_quantity")) m4 = i;
        else    if (!strcmp(columns[i], "p_childno")) m6 = i;
        else    if (!strcmp(columns[i], "p_usageid")) m7 = i;
        else    if (!strcmp(columns[i], "p_tagno")) m8 = i;
        else    if (!strcmp(columns[i], "p_alttagno")) m9 = i;
        else    if (!strcmp(columns[i], "p_incbom")) m10 = i;
        else    if (!strcmp(columns[i], "p_explode")) m11 = i;
        else    if (!strcmp(columns[i], "p_attached")) m12 = i;
        else    if (!strcmp(columns[i], "n_cofilename")) m13 = i;
        else    if (!strcmp(columns[i], "p_incstr")) m14 = i;
        else    if (!strcmp(columns[i], "p_parttype")) m15 = i;
        else    if (!strcmp(columns[i], "n_itemdesc")) m16 = i;
        else    if (!strcmp(columns[i], "p_level")) m17 = i;
        else    if (!strcmp(columns[i], "n_setindicator")) m18 = i;
        }
        if( m1 == -1 || m2 == -1 || m3 == -1 || m4 == -1 ||
           m6 == -1 || m9 == -1 ||
           m7 == -1 || m8 == -1 ||  m10 == -1 ||
           m11 == -1 || m12 == -1 || m13 == -1 || m14 == -1 ||
           m15 == -1 || m16 == -1  || m17 == -1)
        {
        MEMclose(&assy_bufr);
        _PDMdebug(fname,"Couldnot set offsets in bufr\n");
        status = PDM_E_BUFFER_FORMAT;
        return(status);
        } 

    for (row = 1; row < assy_bufr->rows; ++row)
       {
 
       nx = row * assy_bufr->columns;

       /* create the beginning node */
     spr_temp = (PDMchildren )malloc(sizeof( struct PDMassembly_member));
     spr_temp->next = NULL;
     spr_temp->im_n_citno = 0;
     spr_temp->im_n_pcatalogno = 0;
     spr_temp->im_n_pitemno = 0;
     spr_temp->im_n_ccatalogno = 0;
     spr_temp->im_n_citemno = 0;
     spr_temp->ir_p_level = 1;
     spr_temp->caw_n_setindicator[0] = '\0';
     spr_temp->caw_n_status[0] = '\0';
     spr_temp->im_p_pchildno = 0;
     spr_temp->ir_p_childno = 0;
     spr_temp->car_n_catalogname[0] = '\0';
     spr_temp->cpr_n_itemname = NULL;
     spr_temp->cpr_n_itemrev = NULL;
     spr_temp->cpr_n_itemdesc = NULL;
     spr_temp->car_p_attached[0] = '\0';
     spr_temp->dr_p_quantity = 1.0;
     spr_temp->car_p_usageid[0] = '\0';
     spr_temp->ir_p_tagno = 0;
     spr_temp->car_p_alttagno[0] = '\0';
     spr_temp->car_p_incbom[0] = '\0';
     spr_temp->car_p_explode[0] = '\0';
     spr_temp->car_p_incstr[0] = '\0';
     spr_temp->car_p_history[0] = '\0';


     spr_temp->ir_p_level = 1;
     strcpy(spr_temp->caw_n_setindicator, data[nx+m18]);
     strncpy(spr_temp->car_n_catalogname, data[nx+m1], 18);
     PDMstrcpy(data[nx+m2], &spr_temp->cpr_n_itemname );
     PDMstrcpy(data[nx+m3], &spr_temp->cpr_n_itemrev);
     PDMstrcpy(data[nx+m16], &spr_temp->cpr_n_itemdesc);
     strcpy(spr_temp->car_p_attached, data[nx+m12]);
     sscanf(data[nx+m4], "%lf", &p_quantity);
     spr_temp->dr_p_quantity = (double)p_quantity;
     strcpy(spr_temp->car_p_usageid, data[nx+m7]);
     spr_temp->ir_p_tagno = atoi(data[nx+m8]);
     strcpy(spr_temp->car_p_alttagno, data[nx+m9]);
     strcpy(spr_temp->car_p_incbom, data[nx+m10]);
     strcpy(spr_temp->car_p_explode, data[nx+m11]);
     strcpy(spr_temp->car_p_incstr, data[nx+m14]);
     strcpy(spr_temp->car_p_history, "");
      if (row != 1)  spr_tail->next = spr_temp;
      if (row == 1) *spr_PDMstructure = spr_temp;
       spr_tail = spr_temp;
       }
    }
  _PDMdebug(fname, "Exit\n");
  return(PDM_S_SUCCESS);
}  /* end PDMassy_buffer_to_linklist */



int PDMdrop_node_from_linklist
      (
      char *cpr_catalog, 
      char *cpr_partnum, 
      char *cpr_revision, 
      int   ir_childno, 
      char *cpr_usageid,
      PDMchildren *spm_PDMstructure
      )
{
  PDMchildren    spr_current_node, spr_prev_node;
  char           *fname = "PDMdrop_node_from_linklist";
  int            iw_childmatch = 0;

  _PDMdebug(fname, "Enter\n");

  if (*spm_PDMstructure == NULL)
    {
    _PDMdebug(fname, "linklist is empty\n");
    return(PDM_E_NULL_BUFFER);
    }

  spr_current_node = *spm_PDMstructure;
  spr_prev_node = *spm_PDMstructure;

  _PDMdebug(fname, "usage id to delete = <%s>\n",cpr_usageid);

 iw_childmatch = 0;

  while (spr_current_node)
    {
    if( (!strcmp(spr_current_node->car_n_catalogname, cpr_catalog)) &&
        (!strcmp(spr_current_node->cpr_n_itemname, cpr_partnum)) &&
        (!strcmp(spr_current_node->cpr_n_itemrev, cpr_revision) ) &&
        (!strcmp(spr_current_node->car_p_usageid, cpr_usageid)) &&
        (spr_current_node->ir_p_childno == ir_childno))
      {
      /* drop node from linklist */
      iw_childmatch = 1;
    if(((*spm_PDMstructure)->next == NULL) && ((*spm_PDMstructure)->ir_p_level == 1))
        {
        _PDMdebug(fname, "deleting last node in list: list is NULL\n");
        free(&spm_PDMstructure);
        *spm_PDMstructure = NULL;
        }
    else if( (!strcmp((*spm_PDMstructure)->car_n_catalogname, cpr_catalog)) &&
        (!strcmp((*spm_PDMstructure)->cpr_n_itemname, cpr_partnum)) &&
        (!strcmp((*spm_PDMstructure)->cpr_n_itemrev, cpr_revision) ) &&
        (!strcmp((*spm_PDMstructure)->car_p_usageid, cpr_usageid)) &&
        ((*spm_PDMstructure)->ir_p_childno == ir_childno) &&
        ((*spm_PDMstructure)->ir_p_level == 1))
        {
        _PDMdebug(fname, "deleting first node in list\n");
        *spm_PDMstructure = spr_current_node->next;
        free(&spr_current_node);
        }
      else
        {
        if (spr_current_node->ir_p_level == 1)
          {
          _PDMdebug(fname, "deleting node after first node in list\n");
          spr_prev_node->next = spr_current_node->next;
          free(spr_current_node);
          }
        else
          {
          _PDMdebug(fname, "match not found with p_childno && usage id\n");
          spr_prev_node = spr_current_node;
          spr_current_node = spr_current_node->next;
          continue;
          }
        }
      break;
      }
      else
       {
       spr_prev_node = spr_current_node;
       spr_current_node = spr_current_node->next;
       }
    }

    
   if(iw_childmatch == 0)
   {
  spr_current_node = *spm_PDMstructure;
  spr_prev_node = *spm_PDMstructure;
  while (spr_current_node)
    {
    if( (!strcmp(spr_current_node->car_n_catalogname, cpr_catalog)) &&
        (!strcmp(spr_current_node->cpr_n_itemname, cpr_partnum)) &&
        (!strcmp(spr_current_node->cpr_n_itemrev, cpr_revision) ) )
      {
      iw_childmatch = 1;
    /* drop node from linklist */
    if(((*spm_PDMstructure)->next == NULL) && ((*spm_PDMstructure)->ir_p_level == 1))
        {
        _PDMdebug(fname, "deleting last node in list: list is NULL\n");
        free(&spm_PDMstructure);
        *spm_PDMstructure = NULL;
        }
    else if( (!strcmp((*spm_PDMstructure)->car_n_catalogname, cpr_catalog)) &&
        (!strcmp((*spm_PDMstructure)->cpr_n_itemname, cpr_partnum)) &&
        (!strcmp((*spm_PDMstructure)->cpr_n_itemrev, cpr_revision) ) )
        {
        _PDMdebug(fname, "deleting first node in list\n");
        *spm_PDMstructure = spr_current_node->next;
        free(spr_current_node);
        }
      else
        {
        if (spr_current_node->ir_p_level == 1)
          {
          _PDMdebug(fname, "deleting node after first node in list\n");
          spr_prev_node->next = spr_current_node->next;
          free(spr_current_node);
          }
        else
          {
          _PDMdebug(fname, "match not found with cat-partnum-rev\n");
          spr_prev_node = spr_current_node;
          spr_current_node = spr_current_node->next;
          continue;
          }
        }
      break;
      }
      else
       {
       spr_prev_node = spr_current_node;
       spr_current_node = spr_current_node->next;
       }
      }
   }

   if(iw_childmatch == 0)
  _PDMdebug(fname, "No match found based on <%s> <%s> <%s>\n", cpr_catalog, cpr_partnum, cpr_revision);

  _PDMdebug(fname, "Exit\n");
  return(PDM_S_SUCCESS);
}  /* PDMdrop_node_from_linklist */


int pdmoLoadChildStructure
   (
   char                      *cpr_catalog,
   char                      *cpr_partnum,
   char                      *cpr_revision,
   char                      *cpr_description,
   int                        ir_childno,
   double                    dr_quantity,
   char                      *car_p_usageid,
   char                      *car_n_cofilename,
   int                       ir_p_tagno,
   char                      *car_p_alttagno,
   char                      *car_p_incbom,
   char                      *car_p_explode,
   char                      *car_p_incstr,
   struct PDMassembly_member  **spr_PDMstructure
    )
{
   struct  PDMassembly_member       *spr_current_node, *spr_temp;
   char   *fname = "pdmoLoadChildStructure";
   int     status = PDM_S_SUCCESS;

   _PDMdebug(fname, "Enter\n");

     /* create the  node */
    spr_temp = (struct PDMassembly_member * )malloc(sizeof(struct PDMassembly_member));

     spr_temp->next = NULL;
     spr_temp->im_n_citno = 0;
     spr_temp->im_n_pcatalogno = 0;
     spr_temp->im_n_pitemno = 0;
     spr_temp->im_n_ccatalogno = 0;
     spr_temp->im_n_citemno = 0;
     spr_temp->ir_p_level = 1;
     spr_temp->caw_n_setindicator[0] = '\0';
     spr_temp->caw_n_status[0] = '\0';
     spr_temp->im_p_pchildno = 0;
     spr_temp->ir_p_childno = ir_childno;
     spr_temp->car_n_catalogname[0] = '\0';
     spr_temp->cpr_n_itemname = NULL;
     spr_temp->cpr_n_itemrev = NULL;
     spr_temp->cpr_n_itemdesc = NULL;
     spr_temp->car_p_attached[0] = '\0';
     spr_temp->dr_p_quantity = dr_quantity;
     spr_temp->car_p_usageid[0] = '\0';
     spr_temp->ir_p_tagno = ir_p_tagno;
     spr_temp->car_p_alttagno[0] = '\0';
     spr_temp->car_p_incbom[0] = '\0';
     spr_temp->car_p_explode[0] = '\0';
     spr_temp->car_p_incstr[0] = '\0';
     strcpy(spr_temp->car_p_history, "");

    /* Check for the validity of the catalog */ 
    if (cpr_catalog == NULL) return(PDM_E_CAT_FIELD_BLANK);
    else if (strlen(cpr_catalog) == 0) return(PDM_E_CAT_FIELD_BLANK);
    else if ( strlen(cpr_catalog) > 18 ) return(PDM_E_CATALOG_FIELD_TOO_LONG);
    else if (isdigit (cpr_catalog[0])) return(PDM_E_INVALID_INPUT);
   strcpy(spr_temp->car_n_catalogname,cpr_catalog);

    /* Validate the partnum */ 
    if(status = PDUcheck_part_syntax(cpr_partnum) != PDM_S_SUCCESS)
        return(status);
     spr_temp->cpr_n_itemname = (char *) malloc( 100 + 1);
     strcpy(spr_temp->cpr_n_itemname, cpr_partnum);
    /* Validate the revision */ 
    if(status = PDUcheck_rev_syntax(cpr_revision) != PDM_S_SUCCESS)
        return(status);
     PDMstrcpy(cpr_revision, &(spr_temp->cpr_n_itemrev));
     PDMstrcpy(cpr_description, &(spr_temp->cpr_n_itemdesc));
     strncpy(spr_temp->car_p_usageid, car_p_usageid, 25);
     strncpy(spr_temp->car_n_cofilename, car_n_cofilename, 14);
     strncpy(spr_temp->car_p_alttagno, car_p_alttagno, 25);
 
     if ((car_p_incbom == NULL) || (!strcmp(car_p_incbom, "") ))
       strcpy(spr_temp->car_p_incbom, "Y");
     if ((car_p_incstr == NULL) || (!strcmp(car_p_incstr, "") ))
       strcpy(spr_temp->car_p_incstr, "Y");
     if ((car_p_explode == NULL) || (!strcmp(car_p_explode, "") ))
       strcpy(spr_temp->car_p_explode, "Y");

   if (*spr_PDMstructure == NULL) *spr_PDMstructure = spr_temp;
       else
       { 
       spr_current_node = *spr_PDMstructure;
      while(spr_current_node->next != NULL) spr_current_node = spr_current_node->next;
      spr_current_node->next = spr_temp;
        }

   _PDMdebug(fname, "Exit\n");
  return(PDM_S_SUCCESS);
}  



int pdmoFreeChildStructure
   (
   struct PDMassembly_member  **spr_PDMstructure
    )
{
   struct  PDMassembly_member       *spr_current_node, *spr_temp;
   char   *fname = "pdmoFreeChildStructure";

   _PDMdebug(fname, "Enter\n");

 if (*spr_PDMstructure != NULL) spr_temp = *spr_PDMstructure ;
  else 
     {
    _PDMdebug(fname, " NULL LIST PASSED - Exit\n");
     return(PDM_E_NULL_BUFFER);
      }
    while(spr_temp != NULL)
       { 
       spr_current_node = spr_temp->next;
        if(spr_temp) free(spr_temp);
       spr_temp = spr_current_node;
        }

     *spr_PDMstructure = NULL;

   _PDMdebug(fname, "Exit\n");
  return(PDM_S_SUCCESS);
}  

int PDMfind_instanceno_in_linklist(spm_head, usageid)
  PDMchildren    spm_head;
  char                   **usageid;
{
  int      iw_instanceno = 1;
  char     test_usage[100];
  char     instance_str[10];
  PDMchildren spw_head_save = NULL;
  short    cont;
  char     *fname = "PDMfind_instanceno_in_linkedlist";

  _PDMdebug(fname,"Enter\n");

  if (spm_head == NULL) return(PDM_E_NULL_LINKLIST);
  spw_head_save = spm_head;
  iw_instanceno = 1;
  cont = TRUE;
  while (cont)
  {
   cont = FALSE;
   /* reset the link list */
    spw_head_save = spm_head;

    strcpy(test_usage, *usageid);
    _PDMdebug("trying instance number = %d\n", iw_instanceno);
    instance_str[0] = '\0'; 
    sprintf(instance_str, "%d", iw_instanceno);
    sprintf(test_usage, "%s#%d", *usageid, iw_instanceno);
    _PDMdebug("","string to look for = <%s>\n", test_usage);

    while (spw_head_save)
      {
      _PDMdebug(fname,"existing usageid = <%s>\n", spw_head_save->car_p_usageid);
      if (spw_head_save->ir_p_level > 1)
        {
        spw_head_save = spw_head_save->next;
        continue;
        }
      if (strcmp(test_usage, spw_head_save->car_p_usageid) == 0)
        {
        _PDMdebug("","Occurence of part was found\n");
        ++iw_instanceno;
        cont = TRUE;
        break;
        }
      spw_head_save = spw_head_save->next;
      cont = FALSE;
      }
    }
  PDUfill_in_string(usageid, test_usage);
  return(PDM_S_SUCCESS);
}  /* PDUfind_instanceno_in_linklist */

int PDMfind_childno_in_linklist
  (
  PDMchildren spr_head
  )
{
  int      childno, tmp_childno;
  PDMchildren head = NULL;
  char     *fname = "PDMfind_childno_in_linklist";

  _PDMdebug(fname, "Enter\n");

  head = spr_head;

  if (head == NULL) return(PDM_E_NULL_LINKLIST);

  childno = 0;

  while (head)
    {
    tmp_childno = head->ir_p_childno;
    if (tmp_childno > childno)
    childno = tmp_childno;
    head = head->next;
    }

  ++childno;
  _PDMdebug(fname,"childno = %d", (char *)childno);

  _PDMdebug(fname, "Exit\n");
  return(childno);
}  /* PDUfind_childno_in_linklist */

int PDMcheck_usageid_for_uniqueness
  (
  PDMchildren   head,
  char          *usageid
  )
{
  int   found = FALSE;
  char  *fname  = "PDMcheck_usageid_for_uniqueness";

  _PDMdebug(fname, "Enter\n");

  found = FALSE;

  if (head == NULL) return(PDM_E_NULL_LINKLIST);
  /* get value of usageid for all parts */
  while (head)
    {
    if(head->car_p_usageid != NULL)
     {
    if (!strcmp(head->car_p_usageid, usageid)) found = TRUE;
    head = head->next;
      }
    }

  _PDMdebug(fname, "Exit\n");

  return(found);

}  /* end PDUcheck_usageid_for_uniqueness */

int PDMgenerate_tagno_from_linklist
 (
  char *cpr_catalog,
  char *cpr_partnum,
  char *cpr_revision,
  PDMchildren   cpr_head
 )
{
  int      iw_tagno = -1;
  PDMchildren cpr_head2 = NULL;
  char *fname = "PDMgenerate_tagno_from_linklist";

  _PDMdebug(fname, "Enter");
  if (cpr_head == NULL) return(PDM_E_NULL_LINKLIST);
  iw_tagno = 0;
  cpr_head2 = cpr_head;
  while (cpr_head)
  {
  /* check for matching value in linklist */
   if ((!strcmp(cpr_catalog, cpr_head->car_n_catalogname)) &&
        (!strcmp(cpr_partnum, cpr_head->cpr_n_itemname)) &&
        (!strcmp(cpr_revision, cpr_head->cpr_n_itemrev)))
   {
     _PDMdebug(fname, "Part already exists in structure");
       if(cpr_head->ir_p_tagno != -1)
      return(cpr_head->ir_p_tagno);
      }
    cpr_head = cpr_head->next;
   }

  _PDMdebug(fname, "Part does not already exist in structure -Generating new tagno\n");

  /* get value of tagno */
  while (cpr_head2)
    {
 if (cpr_head2->ir_p_tagno != -1 )
      {
      if(cpr_head2->ir_p_tagno > iw_tagno) iw_tagno = cpr_head2->ir_p_tagno;
      }
    cpr_head2 = cpr_head2->next;
    }
  ++iw_tagno;
  _PDMdebug(fname, "Exit\n");
  return(iw_tagno);
}

