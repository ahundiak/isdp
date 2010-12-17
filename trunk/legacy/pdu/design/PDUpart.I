class implementation COpdu;

#include  <PDUint.h>
#include  <PDUintdef.h>
#include  <PDUcommand.h>
#include  <PDUnode.h>
#include  <PDUgrpart.h>
#include  <OMlimits.h>
#include  <grsymdef.h>
#include  <grsym.h>
#include  <msdef.h>
#include  <godef.h>
#include  <go.h>
#include  <gr.h>
#include  <msdef.h>
#include  <fontmacros.h>
#include  <lcmacros.h>
#include  <dpmacros.h>
#include  <grdpbmacros.h>
#include  <grownerdef.h>
#include  <ex.h>
#include  <exmacros.h>
#include  <macro.h>
#include  <exdef.h>
#include  <string.h>
#include  <dpdef.h>
#include  <madef.h>
#include  <grio.h>
#include  <ciexecmacros.h>

#define PARTID_COL 	0
#define REVISION_COL	1
#define CATALOG_COL	2
#define USAGEID_COL	3
#define QUANTITY_COL	4
#define VIEWID_COL	5
#define HISTORY_COL	6
#define ORIENT_COL	7
#define CREGRA_COLS	8
#define PART_WIDTH 	32

extern struct PDUrefresh	*refresh;
extern IGRmatrix                PDUrot_mat;
extern IGRshort                 PDU_list_parts;
extern IGRshort                 PDU_list_origins;
extern IGRint                   PDU_command;
extern struct PDUpart_node      *PDU_parts_id_list;
extern struct PDUpart_node      *PDU_origins_id_list;
extern struct GRid               *PDU_part_id;
extern struct GRid               *PDU_origin_id;
struct stemp              *PDU_macro_temp;
struct myfeet             *PDU_macro_feet;

from	GRgraphics  import	GRxform;
from    GRgraphics  import	GRconstruct;
from    IGEgragad   import	DPinrot;

IGRint	PDUget_objects (target, target_channel, objects_found, obj_count)
  struct PDUid    *target;
  OM_S_CHANSELECT *target_channel;
  struct PDUid    *objects_found;
  IGRint	  *obj_count;
  {
  IGRint		status;
  IGRint		list_size = 0, i;
  OM_S_OBJECT_LINKAGE	*obj_list = NULL;
  OMuint                tmp_objcnt = 0;

  _pdm_debug("In the function PDUget_objects: %d", target->objid);

  if ( *obj_count > 0 )
     list_size = *obj_count;

  obj_list = (OM_S_OBJECT_LINKAGE *) malloc( sizeof(OM_S_OBJECT_LINKAGE) *
					     list_size );

  if ( target->osnum != OM_Gw_TransOSnum_0 )
     {
     status = om$get_channel_objects ( objid = target->objid,
				       osnum = target->osnum,
				       p_chanselect = target_channel,
				       list = obj_list,
				       size = list_size,
				       count = &tmp_objcnt );
     *obj_count = tmp_objcnt;
     _pdm_rstatus ("om$get_channel_objects", status);
     }

  else
     {
     /* get objects connected to command object */
     status = lc$get_channel_objects ( objid = target->objid,
				       osnum = target->osnum,
				       p_chanselect = target_channel,
				       list = obj_list,
				       size = list_size,
				       count = &tmp_objcnt );
     *obj_count = tmp_objcnt;
     _pdm_rstatus ("lc$get_channel_objects", status);
     }

  if ( 1&status )
     {
     for ( i = 0; i < *obj_count; ++i )
	 {
	 objects_found[i].objid = obj_list[i].S_objid;
	 objects_found[i].osnum = obj_list[i].osnum;

	 _pdm_debug ("extracted objid = %d", objects_found[i].objid);
	 }

     _pdm_debug ("extracted %d objects", i);
     }

  if ( obj_list )  free(obj_list);

  return (status);
  }

IGRint PDUprocess_selected_parts_in_os()
  {
  int status;
  int resp;
  int pos;
  GRobjid obj;
  char *command_string = NULL;
  struct PDUpart_node *head = NULL;
  struct GRmd_env  mod_env;
  IGRlong NumberOfBytes, BytesReceived, msg;


  _pdm_debug("In PDUprocess_selected_parts_in_os", 0);

  /* Get current module environment information */
  NumberOfBytes = sizeof(mod_env);
  status = gr$get_module_env(
                             msg = &msg,
                             sizbuf = &NumberOfBytes,
                             buffer = &mod_env,
                             nret = &BytesReceived
                            );

  if (PDU_command == PDC_M_ATTACH_PART)
    PDUfill_in_string(&command_string, "PDAtPr");
  else if (PDU_command == PDC_M_DETACH_PART)
    PDUfill_in_string(&command_string, "PDDtPr");
  else if (PDU_command == PDC_M_LOCATE_REV_PRTS)
    PDUfill_in_string(&command_string, "PDLcRvPr");
  else if (PDU_command == PDC_M_DELETE_PART_PTR)
    PDUfill_in_string(&command_string, "PDDlPrPt");
  else if (PDU_command == PDC_M_DELETE_PPART)
    PDUfill_in_string(&command_string, "PDDlPrPt");
  else if (PDU_command == PDC_M_POSITION_PARTS)
    PDUfill_in_string(&command_string, "PDPoPr");
  else if (PDU_command == PDC_M_COPY_PART_PTR)
    PDUfill_in_string(&command_string, "PDCpPrPt");
  else if (PDU_command == PDC_M_COPY_PPART)
    PDUfill_in_string(&command_string, "PDCpPrPt");
  else if (PDU_command == PDC_M_REPLACE_PART)
          _pdm_debug("calling Sarma's Modify part", 0);
  else if (PDU_command == PDC_M_REPLACE_PPART)
          _pdm_debug("calling Sarma's Modify part", 0);
  else
  {
      _pdm_debug( "Not a valid command",0);
      return (PDM_S_SUCCESS);
  }
    
  if (PDU_list_parts)
    {
    _pdm_debug("process linklist", 0);
    head = PDU_parts_id_list;

    if (!head)
      {
      _pdm_debug("linklist is empty", 0);
      return(PDM_S_SUCCESS);
      }

  /* Deal with delete part specially */
  if ((PDU_command == PDC_M_DELETE_PART_PTR) || 
      (PDU_command == PDC_M_DELETE_PPART) || (PDU_command == PDC_M_ATTACH_PART))
     {
      resp = EX_CMD_KEY;
      pos = FRONT;

      status = PDUput_queue(
                            1,
                            NULL,
                            command_string,
                            NULL,
                            NULL,
                            &resp,
                            NULL,
                            NULL,
                            NULL,
                            &pos
                           );

      return(PDM_S_SUCCESS);
     }
 
  while (head)
      {
      resp = EX_OBJID;
      obj = (head->part_id).objid;
      pos = FRONT;

      status = PDUis_parametric_part(&(head->part_id));
      _pdm_status("PDUis_parametric_part", status);
      
      if ( ((PDU_command == PDC_M_COPY_PART_PTR) && (status)) || 
           ((PDU_command == PDC_M_COPY_PPART) && (status)))
         {
          /*_pdm_debug("copying a parametric part", 0);
          status = copy_prpart(&(head->part_id), &mod_env);*/

          PDUfill_in_string(&command_string, "PDCpPPr");
          /*head = head->next;
          continue;*/
         }

      if ( ((PDU_command == PDC_M_REPLACE_PART) && (status)) ||
           ((PDU_command == PDC_M_REPLACE_PPART) && (status)))
         {
          /*_pdm_debug("modifying a parametric part", 0);
          PALmodprt(&(head->part_id), FALSE);*/

          PDUfill_in_string(&command_string, "PDRpPPr");
          /*head = head->next;
          continue;*/
         }

      if ( (!status) && ((PDU_command == PDC_M_REPLACE_PART) ||
           (PDU_command == PDC_M_REPLACE_PPART )))
         {
          /*_pdm_debug("modifying a GRpart", 0);
          PALmodprt(&(head->part_id), TRUE);*/
          PDUfill_in_string(&command_string, "PDRpPPr");
         
          /*head = head->next;
          continue;*/
         }

      status = PDUput_queue(
                            2,
                            NULL, 
                            NULL, 
                            NULL,
                            NULL,
                            &resp,
                            &obj, 
                            NULL,
                            NULL, 
                            &pos
                           );
      _pdm_status("PDUput_queue", status);

      resp = EX_CMD_KEY;
      pos = FRONT;

      status = PDUput_queue(
                            1,
                            NULL,
                            command_string,
                            NULL,
                            NULL,
                            &resp,
                            NULL, 
                            NULL, 
                            NULL, 
                            &pos
                           );
       head = head->next;

      } /* end while loop */

      /* Free PDU_parts_id_list */
      if (PDU_parts_id_list)
         {
          head = PDU_parts_id_list;

          while (PDU_parts_id_list)
                {
                 PDU_parts_id_list = PDU_parts_id_list->next;
                 free(head);
                 head = PDU_parts_id_list;
                }
         
          PDU_parts_id_list = NULL;
         }
    }
  else
    {
      resp = EX_OBJID;
      obj = PDU_part_id->objid;
      pos = FRONT;

      status = PDUput_queue(2, NULL, NULL, NULL, NULL, &resp, &obj, NULL, NULL, 
                            &pos);
      _pdm_status("PDUput_queue", status);

      resp = EX_CMD_KEY;
      pos = FRONT;

      status = PDUput_queue(1, NULL, command_string, NULL, NULL, &resp, NULL, 
                            NULL, NULL, 
                            &pos);
      if (PDU_part_id)
        {
        free(PDU_part_id);
        PDU_part_id = NULL;
        }
    }

  return(PDM_S_SUCCESS);
  }

IGRint PDUprocess_selected_origins_in_os()
  {
  int status;
  int resp;
  int pos;
  GRobjid obj;
  char *command_string = NULL;
  struct PDUpart_node *head = NULL;

  _pdm_debug("In PDUprocess_selected_origins_in_os", 0);

  PDUfill_in_string(&command_string, "PDDlOr");

  if (PDU_list_origins)
    {
    _pdm_debug("process linklist", 0);
    head = PDU_origins_id_list;

    if (!head)
      {
      _pdm_debug("linklist is empty", 0);
      return(PDM_S_SUCCESS);
      }

      resp = EX_CMD_KEY;
      pos = FRONT;

      status = PDUput_queue(1, NULL, command_string, NULL, NULL, &resp, NULL, 
                            NULL, NULL, 
                            &pos);
      }

  else if (PDU_origin_id)
    {
      resp = EX_OBJID;
      obj = PDU_origin_id->objid;
      pos = FRONT;

      status = PDUput_queue(2, NULL, NULL, NULL, NULL, &resp, &obj, NULL, NULL, 
                            &pos);
      _pdm_status("PDUput_queue", status);

      resp = EX_CMD_KEY;
      pos = FRONT;

      status = PDUput_queue(1, NULL, command_string, NULL, NULL, &resp, NULL, 
                            NULL, NULL, 
                            &pos);
      if (PDU_origin_id)
         {
          free(PDU_origin_id);
          PDU_origin_id = NULL;
         }
    }

  return(PDM_S_SUCCESS);
  }

IGRint PDUget_exnuc_path(path_name)

IGRchar *path_name;
/*****************************************************************************/
/*                                                                           */
/*  Documentation: PDUget_exnuc_path                                         */
/*                 This function finds the path of exnuc using the macro     */
/*                 ex$get_path.                                              */
/*  Output:                                                                  */
/*                 IGRchar *path                                             */
/*                                                                           */
/*  Returns:       PDM_S_SUCCESS if path found                               */ 
/*                 PDM_E_PATH    otherwise                                   */
/*****************************************************************************/

{
  int sts, status = PDM_S_SUCCESS;
  int i;
  char *temp_path = NULL;
  char *s;

  _pdm_debug("In PDUget_exnuc_path function", 0);
  sts = TRUE;
  for (i = 0; sts == TRUE; i++)
  {
  sts = ex$get_path(index = i, path = path_name, len = 80, 
                    type = EX_PRODUCT_PATH);
  _pdm_debug("Path is <%s>", path_name);
  if (sts)
    {
    PDUfill_in_string(&temp_path, path_name);
    s = strtok(temp_path, "/");
    while (s)
      {
      _pdm_debug("Token is <%s>", s);
      if ((strcmp(s, "exnucdp") == 0) || (strcmp(s, "exnuc") == 0))
        {   
        sts = FALSE;
        status = PDM_S_SUCCESS;
        break;
        }
      else
        {
        s = strtok(0, "/");
        }
      }
   }
   else
     status = PDM_E_FAILURE;
    
  }

  return(status);
}

IGRint PDUget_ems_path(path_name)
IGRchar *path_name;
/*****************************************************************************/
/*                                                                           */
/*  Documentation: PDUget_ems_path                                           */
/*                 This function finds the path of ems   using the macro     */
/*                 ex$get_path.                                              */
/*  Output:                                                                  */
/*                 IGRchar *path                                             */
/*                                                                           */
/*  Returns:       PDM_S_SUCCESS if path found                               */ 
/*                 PDM_E_PATH    otherwise                                   */
/*****************************************************************************/
{
  int sts, status = PDM_S_SUCCESS;
  int i;
  char *temp_path = NULL;
  char *s;

  _pdm_debug("In PDUget_ems_path function", 0);
  sts = TRUE;
  for (i = 0; sts == TRUE; i++)
  {
  sts = ex$get_path(index = i, path = path_name, len = 80, 
                    type = EX_PRODUCT_PATH);
  _pdm_debug("Path is <%s>", path_name);
  if (sts)
    {
    PDUfill_in_string(&temp_path, path_name);
    s = strtok(temp_path, "/");
    while (s)
      {
      _pdm_debug("Token is <%s>", s);
      if ((strcmp(s, "ems") == 0) || (strcmp(s, "emsdp") == 0) ||
          (strcmp(s, "emssrc") == 0))
        {   
        sts = FALSE;
        status = PDM_S_SUCCESS;
        break;
        }
      else
        {
        s = strtok(0, "/");
        }
      }
   }
   else
     status = PDM_E_FAILURE;
  }
  return(status);
}
IGRint PDUget_model_path(path_name)
IGRchar *path_name;
/*****************************************************************************/
/*                                                                           */
/*  Documentation: PDUget_model_path                                         */
/*                 This function finds the path of model using the macro     */
/*                 ex$get_path.                                              */
/*  Output:                                                                  */
/*                 IGRchar *path                                             */
/*                                                                           */
/*  Returns:       PDM_S_SUCCESS if path found                               */
/*                 PDM_E_PATH    otherwise                                   */
/*****************************************************************************/
{
  int sts, status = PDM_S_SUCCESS;
  int i;
  char *temp_path = NULL;
  char *s;

  _pdm_debug("In PDUget_model_path function", 0);
  sts = TRUE;
  for (i = 0; sts == TRUE; i++)
  {
  sts = ex$get_path(index = i, path = path_name, len = 80,
                    type = EX_PRODUCT_PATH);
  _pdm_debug("Path is <%s>", path_name);
  if (sts)
    {
    PDUfill_in_string(&temp_path, path_name);
    s = strtok(temp_path, "/");
    while (s)
      {
      _pdm_debug("Token is <%s>", s);
      if ((strcmp(s, "model") == 0) || (strcmp(s, "modeldp") == 0) ||
          (strcmp(s, "modelsrc") == 0))
        {
        sts = FALSE;
        status = PDM_S_SUCCESS;
        break;
        }
      else
        {
        s = strtok(0, "/");
        }
      }
   }
   else
     status = PDM_E_FAILURE;
  }
  return(status);
}

IGRint PDUget_pdu_path(path_name)

IGRchar *path_name;
/*****************************************************************************/
/*                                                                           */
/*  Documentation: PDUget_pdu_path                                          */
/*                 This function finds the path of pdu using the macro     */
/*                 ex$get_path.                                              */
/*  Output:                                                                  */
/*                 IGRchar *path                                             */
/*                                                                           */
/*  Returns:       PDM_S_SUCCESS if path found                               */ 
/*                 PDM_E_PATH    otherwise                                   */
/*****************************************************************************/

{
  int sts, status = PDM_S_SUCCESS;
  int i;
  char *temp_path = NULL;
  char *s;

  _pdm_debug("In PDUget_pdu_path function", 0);
  sts = TRUE;
  for (i = 0; sts == TRUE; i++)
  {
  sts = ex$get_path(index = i, path = path_name, len = 80, 
                    type = EX_PRODUCT_PATH);
  _pdm_debug("Path is <%s>", path_name);
  if (sts)
    {
    PDUfill_in_string(&temp_path, path_name);
    s = strtok(temp_path, "/");
    while (s)
      {
      _pdm_debug("Token is <%s>", s);
      if (strcmp(s, "pdu") == 0)
        {   
        sts = FALSE;
        status = PDM_S_SUCCESS;
        break;
        }
      else
        {
        s = strtok(0, "/");
        }
      }
   }
   else
     status = PDM_E_FAILURE;
    
  }

  return(status);
}

IGRint PDUget_grnuc_path(path_name)

IGRchar *path_name;
/*****************************************************************************/
/*                                                                           */
/*  Documentation: PDUget_grnuc_path                                         */
/*                 This function finds the path of grnuc using the macro     */
/*                 ex$get_path.                                              */
/*  Output:                                                                  */
/*                 IGRchar *path                                             */
/*                                                                           */
/*  Returns:       PDM_S_SUCCESS if path found                               */ 
/*                 PDM_E_PATH    otherwise                                   */
/*****************************************************************************/

{
  int sts, status = PDM_S_SUCCESS;
  int i;
  char *temp_path = NULL;
  char *s;

  _pdm_debug("In PDUget_grnuc_path function", 0);
  sts = TRUE;
  for (i = 0; sts == TRUE; i++)
  {
  sts = ex$get_path(index = i, path = path_name, len = 80, 
                    type = EX_PRODUCT_PATH);
  _pdm_debug("Path is <%s>", path_name);
  if (sts)
    {
    PDUfill_in_string(&temp_path, path_name);
    s = strtok(temp_path, "/");
    while (s)
      {
      _pdm_debug("Token is <%s>", s);
      if ((strcmp(s, "grnuc") == 0) || (strcmp(s, "grnucdp") == 0) ||
          (strcmp(s,"grnucsrc") == 0))
        {   
        sts = FALSE;
        status = PDM_S_SUCCESS;
        break;
        }
      else
        {
        s = strtok(0, "/");
        }
      }
   }
   else
     status = PDM_E_FAILURE;
    
  }

  return(status);
}

void PDUdeactivate_stop_sign()

  {

  IGEdeactivate_stop_sign();

  }
 
void PDUactivate_stop_sign()

  {
  _pdm_debug("In PDUdeactivate_stop_sign", 0);
  IGEactivate_stop_sign();
  }
end implementation COpdu;

