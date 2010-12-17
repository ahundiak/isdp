class implementation COpdu;
/*
  PMplprto.I contains the function pdmoPlacePart for the API

  Author: Jenny Parris
*/

/* Include file section */
#include        "ctype.h"
#include        "DItypedef.h"
#include	"DIprims.h"
#include        "DIdef.h"
#include        "DIglob.h"
#include 	"GRpart.h"
#include 	"PDUerror.h"
#include 	"PDUstr.h"
#include        "PDUintdef.h"
#include        "PDUpart.h"
#include        "PDUgrpart.h"
#include 	"msdef.h"
#include 	"godef.h"
#include        "igrdp.h"
#include 	"partmacros.h"
#include 	"part.h"
#include 	"partdef.h"
#include        "string.h"
#include        "dpmacros.h"
#include        "grdpbmacros.h"
#include        "OMindex.h"
#include        "OMtypes.h"
#include        "refdef.h" 
#include        "referr.h"
#include        "ref.h"
#include        "csmacros.h"
#include        "MEMstruct.h"
#include        "MEMerrordef.h"
#include        "comnmacros.h"
#include        "exmacros.h"
#include        "expriv.h"
#include        "PDUuser.h"
#include        "PDUfile_def.h"
#include        "PDUconvert.h"
#include        "PDUqueue.h"
#include        "PDUassy.h"
#include        "PDUnode.h"
#include        "PDUstorage.h"
#include        "PDUforms.h"
#include        "PDUrev_str.h"
#include        "PDMmessage.h"
#include        "FI.h"
#include        <sys/stat.h>
#include  <ex.h>
#include  <exdef.h>
#include  <ciexecmacros.h>
#include <sys/types.h>
#include <errno.h>


/* Imported messages */
from  GRowner     import       GRadd_components;
from  GRowner     import       GRget_components;
from  GRowner     import       GRremove_components;
from  GRowner     import       GRget_number_components;
from  GRreffile   import       GRchglevels;
from  GRgraphics  import       GRconstruct;
from  GRgraphics  import       GRxform;
from  GRgraphics  import       GRdelete;
from  GRgencs     import       GRgetmatrix;
from  GRreffile   import       GRgetenvironment;
from  GRreffile   import       GRgetdescription;
from  GRreffile   import       GRinquireref;
from  GRcsmgr     import       GRcstoggle_display;

extern IGRchar   *PDU_usage_id;
extern IGRchar   *PDU_quantity;
extern IGRchar   *PDU_explode_BOM;
extern IGRchar   *PDU_alt_tagno;
extern IGRchar   *PDU_tagno;
extern IGRchar   *PDU_incl_BOM;
extern IGRchar   *PDU_incl_ASM;
extern IGRchar   *PDU_filename;
extern IGRchar   *PDU_checkin_file;
extern IGRshort   PDU_edit_display;
extern IGRchar    PDU_status_string[54];
extern MEMptr     PDU_dyn_attr_bufr;
extern MEMptr     PDU_dyn_data_bufr;
extern MEMptr     PDU_dyn_value_bufr;
extern MEMptr     PDU_ret_bufr;
extern struct     PDUrev_assy *current_rev_assy;
extern struct     PDUrefresh *refresh;
extern Form       PDU_calling_form;
extern Form       PDU_form_id;
extern struct     PDUforms forms;
extern IGRshort   PDU_display_dyn_attr;
extern struct     PDUparts_list *PDU_checked_out_parts;
extern IGRshort   PDU_apiflag;
extern IGRint     PDU_instance_no;


int PDUget_description_for_part(catalog, partid, revision, description)

char *catalog;
char *partid;
char *revision;
char **description;

  {
  extern MEMptr PDU_ret_bufr;
  int desc_col;
  int status;
  char **data_row = NULL;

  _pdm_debug("In PDUget_description_for_part", 0);
  if (PDU_ret_bufr)
    {
    MEMclose(&PDU_ret_bufr);
    PDU_ret_bufr = NULL;
    }
  status = PDMget_pt_desc(catalog,partid,revision);
  _pdm_status("PDMget_pt_desc", status);
  if ((PDU_ret_bufr) && (PDU_ret_bufr->rows > 0))
    {
    MEMbuild_array(PDU_ret_bufr);
    status = PDUget_buffer_col(PDU_ret_bufr, "n_itemdesc", &desc_col);
    if (status != PDM_S_SUCCESS)
      return(status);

    PDUsetup_buffer(PDU_ret_bufr, ROW, &data_row);

   PDUfill_in_string(description, data_row[(PDU_ret_bufr->columns*0)+desc_col]);
   MEMclose(&PDU_ret_bufr);
   PDU_ret_bufr = NULL;
    }
  else
    PDUfill_in_string(description, "");

  _pdm_debug("description = <%s>", *description);
  return(PDM_S_SUCCESS);
  }

IGRint  PDUvalidate_usageid(spr_mod_env,cpr_usage_id)

 struct GRmd_env *spr_mod_env;  /* INPUT */
 IGRchar *cpr_usage_id;		/* INPUT */
 {
  IGRlong    status = PDM_S_SUCCESS;
  IGRlong    NumberOfBytes, BytesReceived;
  IGRlong    msg;
  IGRint     count = 0;
  IGRint     type;
  IGRshort   free_mod = FALSE;
  IGRchar    attr_value[MAX_VALUE];
  IGRchar    cs_full_name[MAX_VALUE];
  GRobjid    csid;
  IGRchar    **params = NULL;
  IGRchar    **param_vals = NULL;
  struct     PDUpart_node      *part_ids = NULL;
  struct     PDUpart_node      *parametric_ids = NULL;
  struct     PDUpart_node      *head = NULL;

 
  _pdm_debug("In the PDUvalidate_usageid function", 0);

  if (cpr_usage_id == NULL)
    return(PDM_E_NULL_USAGEID);
  else if (strcmp(cpr_usage_id, "") == 0)
    return(PDM_E_NULL_USAGEID);
  else if (strlen(cpr_usage_id) > 25)
    return(PDM_E_LENGTH_USAGEID);

  /* Get current module environment information */
  if (spr_mod_env == NULL)
    {
    spr_mod_env = (struct GRmd_env *)malloc(sizeof(struct GRmd_env));
    NumberOfBytes = sizeof(struct GRmd_env);
    status = gr$get_module_env(
                              msg = &msg,
                              sizbuf = &NumberOfBytes,
                              buffer = spr_mod_env,
                              nret = &BytesReceived);
    free_mod = TRUE;
    }

  _pdm_debug("cpr_usage_id = <%s>", cpr_usage_id);

  /* Get path to "<filename>:usr" */
  di$give_pathname(
                   osnum = spr_mod_env->md_id.osnum,
                   pathname = cs_full_name 
                  );

  strcat(cs_full_name, ":usr:");
  strcat(cs_full_name, cpr_usage_id);

  /* Check to see if usage id is unique across coord sys */
  status = PDUget_coord_sys_id(
                               *spr_mod_env,
                               cs_full_name,
                               &csid 
                              );
  _pdm_status("PDUget_coord_sys_id", status);

  if (status == PDM_S_SUCCESS)
     {
      _pdm_debug("usage id <%s> is not unique", cpr_usage_id);
      if (free_mod)
        {
        free(spr_mod_env);
        spr_mod_env = NULL;
        }
     return(PDM_E_DUPLICATE_USAGEID);
     } 

  /* Check to see if usage id is unique across GRparts */
  status = PDUget_all_GRpart_ids(
                                  spr_mod_env->md_id.osnum,
                                  &part_ids,
                                  &count
                                 );
  _pdm_status("PDUget_all_GRpart_ids", status);

  head = part_ids;

  while (head)
    {
    /* Extract GRpart usage id */
    co$part_get_attr(msg = &msg, mod_env = spr_mod_env, part = &(head->part_id),
                     attr = "usage_id", value = attr_value, type = &type);

    /* Unqoute usage id */
    PDUunquote(attr_value);

    if (strcmp(attr_value, cpr_usage_id) == 0)
      {
      _pdm_debug("usage id <%s> is not unique", cpr_usage_id);
      /* Free part_ids */
      if (part_ids)
        {
        head = part_ids;
        while (part_ids)
          {
          part_ids = part_ids->next;
          free(head);
          head = part_ids;
          }
        }

      if (free_mod)
        {
        free(spr_mod_env);
        spr_mod_env = NULL;
        }
      return (PDM_E_DUPLICATE_USAGEID);
      }
    head = head->next;
    } /* end while loop */

  /* Check to see if usage id is unique across parametric parts */
  status = PDUget_all_parametric_ids(
                                     spr_mod_env->md_id.osnum,
                                     &parametric_ids,
                                     &count
                                    );
  _pdm_status("PDUget_all_parametric_ids", status);

  head = parametric_ids;

  while (head)
    {
    /* Extract parametric part usage id */
    params = (IGRchar **) malloc(sizeof(IGRchar *));
    memset((IGRchar *)params, NULL, sizeof(IGRchar *));
    PDUfill_in_string(&params[0], "p_usageid");

    status = get_parameter_values(&(head->part_id), params, 1, &param_vals);
    if (!status)
      {
      _pdm_debug("get_parameter_values failed", 0);
      if (free_mod)
        {
        free(spr_mod_env);
        spr_mod_env = NULL;
        }
      return(PDM_E_INVALID_PART_POINTER);
      }
     _pdm_debug("param_vals[0] = %s", param_vals[0]);
     if (strcmp(param_vals[0], cpr_usage_id) == 0)
       {
        _pdm_debug("usage id <%s> is not unique", cpr_usage_id);
             
       /* Free parametric_ids */
       if (parametric_ids)
         {
         head = parametric_ids;
         while (parametric_ids)
           {
           parametric_ids = parametric_ids->next;
           free(head);
           head = parametric_ids;
           }
         } 

       if (free_mod)
         {
         free(spr_mod_env);
         spr_mod_env = NULL;
         }
       return (PDM_E_DUPLICATE_USAGEID);
       }
     head = head->next; 
     } /* end while loop */

  /* Free variables */
  if (part_ids)
    {
    head = part_ids;
    while (part_ids)
      {
      part_ids = part_ids->next;
      free(head);
      head = part_ids;
      }
    }

  if (parametric_ids)
    {
    head = parametric_ids;
    while (parametric_ids)
      {
      parametric_ids = parametric_ids->next;
      free(head);
      head = parametric_ids;
      }
    }

  if (params)
    {
    if (params[0])
      free(params[0]);
    free(params);
    }

  if (param_vals)
    {
     if (param_vals[0])
       free(param_vals[0]);
     free(param_vals);
    }
     
  if (free_mod)
    {
    free(spr_mod_env);
    spr_mod_env = NULL;
    }
  return(PDM_S_SUCCESS);
 }

 IGRint  PDUapi_default_usageid(spr_mod_env, catalog, number, 
                                 revision, cpw_usage_id)
 struct GRmd_env *spr_mod_env;
 IGRchar *catalog;
 IGRchar *number;
 IGRchar *revision;
 IGRchar *cpw_usage_id;
 {
  IGRint     i = 0;
  IGRchar    *catalog_no = NULL;
  IGRchar    *item_no = NULL;
  IGRchar    *usage_id_seed = NULL;
  IGRchar    str[MAX_VALUE];
  IGRint     status = PDM_S_SUCCESS;


  _pdm_debug("In the PDUapi_default_usage_id function", 0);

  /* Check to see if part catalog has a usage id seed */
  status = PDMget_usageid_cat(catalog, &usage_id_seed);
  _pdm_status("PDMget_usageid_cat", status);

  if (status != PDM_S_SUCCESS)
    {
    _pdm_debug("SEVERE error: PDMget_usageid_cat failed", 0);
    return(status);
    }

  if ( (usage_id_seed) && (strcmp(usage_id_seed, "") != 0) )
    {
    strcpy(str, usage_id_seed);
    }
  else
    {
    if ( (!number) && (!revision) )
      {
      strcpy(cpw_usage_id, "");
      return(PDM_S_SUCCESS);
      }
     sprintf(str, "%s %s", number, revision);
     }
  status = PDM_E_INVALID_VALUE;
  while (status != PDM_S_SUCCESS)
    {
    ++i;
    sprintf(cpw_usage_id, "%s #%d", str, i);
    status = PDUvalidate_usageid(spr_mod_env, cpw_usage_id);
    _pdm_status("PDUvalidate_usageid", status);
    if (status == PDM_E_LENGTH_USAGEID)
      status = PDM_S_SUCCESS;
    }

  /* Check to see if usage id exceeds 25 characters */
  if ((cpw_usage_id) && (strlen(cpw_usage_id) > 25))
    {
    /* Use catalog no/part no pairs in the default usage id */
    status = PDMget_catno_partno(catalog, number, revision, &catalog_no,
                                 &item_no);
    _pdm_status("PDMget_catno_partno", status);
 
   if (status != PDM_S_SUCCESS)
     {
     _pdm_debug("SEVERE error: PDMget_catno_partno failed", 0);
     return(status);
     }

   /* Default usage id */
   sprintf(cpw_usage_id, "%s %s #%d", catalog_no, item_no, i);
   }

 _pdm_debug("default usage id = <%s>", cpw_usage_id);

 /* Free variables */
 if (usage_id_seed)
   free(usage_id_seed);

 if (catalog_no)
   free(catalog_no);

 if (item_no)
   free(item_no);

 return(status);
 }

IGRlong  PDUvalidate_alttagno(spr_mod_env,catalog, itemname, revision, 
                              cpr_alt_tag)

 struct GRmd_env *spr_mod_env;
 IGRchar *catalog;		/* INPUT */
 IGRchar *itemname;		/* INPUT */
 IGRchar *revision;		/* INPUT */
 IGRchar *cpr_alt_tag;		/* INPUT */
 {
  IGRlong    status = PDM_S_SUCCESS;
  IGRlong    NumberOfBytes, BytesReceived;
  IGRchar    parts_dir[DI_PATH_MAX];
  IGRchar    value[MAX_VALUE];
  IGRlong    msg, i, j;
  IGRshort   free_mod = FALSE;
  IGRint     count = 0;
  IGRint     entry_count = 0;
  IGRint     instance_no = 0;
  IGRchar    **entries;
  IGRint     type;
  IGRchar    *part_alt_tag = NULL;
  IGRchar    *part_tag = NULL;
  IGRchar    *tag_no = NULL;
  struct GRid      *part_ids = NULL;
 
  _pdm_debug("In the PDUvalidate_alttagno function", 0);

  /* Get current module environment information */
  if (spr_mod_env == NULL)
    {
    spr_mod_env = (struct GRmd_env *)malloc(sizeof(struct GRmd_env));
    NumberOfBytes = sizeof(struct GRmd_env);
    status = gr$get_module_env(
                              msg = &msg,
                              sizbuf = &NumberOfBytes,
                              buffer = spr_mod_env,
                              nret = &BytesReceived);
    free_mod = TRUE;
    }

  /* Find all part entries of the form <filename:parts:*:*!*:> */
  di$give_pathname(osnum = spr_mod_env->md_id.osnum, pathname = parts_dir);

  strcat(parts_dir, ":parts"); 
  
  status = di$find(
                   start_dir = parts_dir,
                   regexp = "*!*",
                   lines = &entries,
                   ptr = &entry_count,
                   max_level = -1
                  );

  if (status != DIR_S_SUCCESS)
    {
    _pdm_debug("di$find failed", 0);
    _pdm_debug("must be first part placement", 0);
    if (free_mod)
      {
      free(spr_mod_env);
      spr_mod_env = NULL;
      }
    return(PDM_S_SUCCESS);
    }

  if (entry_count == 0)
    {
    /* alt is unique */
    _pdm_debug("alt is unique", 0);
    if (free_mod)
      {
      free(spr_mod_env);
      spr_mod_env = NULL;
      }
     return(PDM_S_SUCCESS);
    }

  /* Get GRparts ids for each entry */
  for (i = 0; i < entry_count; ++i)
    {
    status = PDUget_GRparts_ids( entries[i], &part_ids, &count);
    _pdm_status("PDUget_GRparts_ids", status);

    if (status != PDM_S_SUCCESS)
      {
      _pdm_debug("PDUget_GRparts_ids failed", 0);
      di$free(lines = entries, count = entry_count);
      if (free_mod)
        {
        free(spr_mod_env);
        spr_mod_env = NULL;
        }
      return(status);
      }

    /* Check to see if alt tag number is unique */
    if (count > 0)
      {
      status = PDUgenerate_tag_no(&tag_no, spr_mod_env->md_id.osnum);
      _pdm_status("PDUgenerate_tag_no", status);
      status = PDUgenerate_instance_number(catalog, itemname, revision, 
                                           &instance_no, spr_mod_env);
      _pdm_status("PDUgenerate_instance_number", status);
      if (instance_no > 1)
        {
        status = co$part_get_attr(msg = &msg, mod_env = spr_mod_env, 
                                  catalog = catalog, number = itemname, 
                                  revision = revision, attr = "tag", 
                                  value = value);
         PDUunquote(value);
         PDUfill_in_string(&tag_no, value);
         }
      /* Loop thru extracting alt tag number for each GRpart */
      for (j = 0; j < count; ++j)
        {
        /* Extract alt tag number */
        status = co$part_get_attr (
                                   msg = &msg,
                                   mod_env = spr_mod_env,
                                   part = &(part_ids[j]),
                                   attr = "alt_tag",
                                   value = value,
                                   type = &type
                                   );
         _pdm_debug("alt tag = <%s>", value);

         /* Unquote alt tag no */
         PDUunquote(value);
         PDUfill_in_string(&part_alt_tag, value);

         _pdm_debug("extracted alt tag = <%s>", part_alt_tag);

         /* Extract tag no */
         status = co$part_get_attr (
                                    msg = &msg,
                                    mod_env = spr_mod_env,
                                    part = &(part_ids[j]),
                                    attr = "tag",
                                    value = value,
                                    type = &type
                                    );
         /* Unquote tag no */
         PDUunquote(value);
         PDUfill_in_string(&part_tag, value);
         _pdm_debug("extracted tag = <%s>", part_tag);

         if ((strcmp(part_alt_tag, cpr_alt_tag) == 0) &&
              (strcmp(part_tag, tag_no) != 0))
           {
           _pdm_debug("alt tag is not unigue", 0);
           di$free(lines = entries, count = entry_count);
           free(part_tag);
           free(part_alt_tag);

           /* Free up part_ids */
           if (part_ids)
             free(part_ids);

           if (free_mod)
             {
             free(spr_mod_env);
             spr_mod_env = NULL;
             }
           return(PDM_E_DUP_ALTTAGNO);
           }
         }

       /* Free up part_ids */
       if (part_ids)
         free(part_ids);
       }
     }

     /* Alt tag is unique */
     _pdm_debug("alt tag is unique", 0);
     di$free(lines = entries, count = entry_count);

     if (part_alt_tag)
        free(part_alt_tag);

     if (part_tag)
        free(part_tag);

     if (free_mod)
       {
       free(spr_mod_env);
       spr_mod_env = NULL;
       }
     return(PDM_S_SUCCESS);
 }

IGRlong PDUvalidate_viewname(cpr_viewname, view_buffer)

  IGRchar *cpr_viewname;
  MEMptr  view_buffer;
  {
  IGRlong status;
  IGRint  viewname_col;
  IGRint  i;
  IGRchar **view_data = NULL;

  _pdm_debug("PDUvalidate_viewname", 0);

  if (cpr_viewname == NULL)
    return(PDM_E_MULTIPLE_VIEWS); 
  else if (strcmp(cpr_viewname, "") == 0)
    return(PDM_E_MULTIPLE_VIEWS); 

  if (view_buffer == NULL)
    return(PDM_E_NO_VIEWS_DEFINED);
  else if (view_buffer->rows == 0)
    return(PDM_E_NO_VIEWS_DEFINED);

  status = MEMbuild_array(view_buffer);
  _pdm_status("MEMbuild_array", status);
  if (status != MEM_S_SUCCESS)
    return(PDM_E_BUILD_ARRAY);

  view_data = (char **)view_buffer->data_ptr;
  PDUget_buffer_col(view_buffer, "p_viewname", &viewname_col);
  for (i = 0; i < view_buffer->rows; i ++)
    {
    if (strcmp(view_data[(view_buffer->columns * i) + viewname_col], 
        cpr_viewname) == 0)
      {
      _pdm_debug("viewname %s found", cpr_viewname);
      status = PDM_S_SUCCESS;
      break;
      }
    else
      {
      _pdm_debug("viewname %s not found", cpr_viewname);
      status = PDM_E_VIEWNAME_NOT_EXIST;
      }
    }
  return(status);
  }
  
IGRlong pdmoAttachPart(spr_mod_env, spr_part, cpr_ccatalogname, cpr_citemname, 
                       cpr_citemrev, cpr_cofilename, cpr_viewname,
                       cpr_incstr, cpr_catno, cpr_itemno, cpr_childno, 
                       parent_parttype, display)

  struct GRmd_env *spr_mod_env;
  struct GRid     *spr_part;
  IGRchar *cpr_ccatalogname;
  IGRchar *cpr_citemname;
  IGRchar *cpr_citemrev;
  IGRchar *cpr_cofilename;
  IGRchar *cpr_viewname;
  IGRchar *cpr_incstr;
  IGRchar *cpr_catno;
  IGRchar *cpr_itemno;
  IGRchar *cpr_childno;
  IGRchar *parent_parttype;
  IGRchar *display;
  {
  IGRlong status;
  IGRlong sts;
  IGRlong msg;
  IGRint  viewname_col;
  IGRshort  four = 4;
  IGRint  type;
  IGRint  itemno;
  IGRint  num_objects = 1;
  IGRint  own_index[1];
  IGRshort background = FALSE;
  IGRshort display_flag = FALSE;
  IGRpoint origin;
  IGRpoint x_point;
  IGRpoint y_point;
  IGRchar attr_value[MAX_VALUE];
  IGRchar tmp_viewname[MAX_VALUE];
  IGRchar assy_path[DI_PATH_MAX];
  IGRchar refid_string[20];
  IGRchar *viewname = NULL;
  IGRchar **view_data = NULL;
  IGRmatrix src_matrix;
  IGRmatrix rot_matrix;
  MEMptr view_buffer = NULL;
  MEMptr file_buffer = NULL;
  struct PDUpoint origin_pt;
  struct PDUpoint x_axis_pt;
  struct PDUpoint y_axis_pt;
  struct GRid     coord;
  struct GRid     cs_id;
  struct GRid     refobjid;
  struct GRid     contextid;
  struct GRobj_env objects[1];
  extern IGRchar *PDU_filename;
  extern IGRchar *PDU_viewname;

  _pdm_debug("In pdmoAttachPart", 0);

  if (cpr_itemno == NULL)
    return(PDM_E_PART_NULL);
  else if (strcmp(cpr_itemno, "") == 0)
    return(PDM_E_PART_NULL);
  else 
    sscanf(cpr_itemno, "%d", &itemno);
    
  /* update the part's attached flag in assembly structure */
  di$give_pathname(osnum = spr_mod_env->md_id.osnum, pathname = assy_path);
  strcat(assy_path, ":ASSEMBLY:P");
  strcat(assy_path, cpr_childno);
  PDUmodify_exp(0, assy_path, "attached", display, spr_mod_env->md_id.osnum);
  
  status = PDMget_part_attach_info(cpr_ccatalogname, cpr_citemname,cpr_citemrev,
                                   itemno, &view_buffer, &file_buffer);
  if (status != PDM_S_SUCCESS)
    return(status);
  else if (view_buffer == NULL)
    return(PDM_E_NO_VIEWS_DEFINED);
  else if (view_buffer->rows == 0)
    return(PDM_E_NO_VIEWS_DEFINED);
  else if ((view_buffer->rows > 1) && (cpr_viewname == NULL))
    return(PDM_E_MULTIPLE_VIEWS);
  else if ((view_buffer->rows > 1) && (strcmp(cpr_viewname, "") == 0))
    return(PDM_E_MULTIPLE_VIEWS);
  else if ((cpr_viewname) && (strcmp(cpr_viewname, "") != 0))
    {
    status = PDUvalidate_viewname(cpr_viewname, view_buffer);
    _pdm_status("PDUvalidate_viewname", status);
    if (status != PDM_S_SUCCESS)
      return(status);
    PDUfill_in_string(&viewname, cpr_viewname);
    }
  else 
    {
    status = MEMbuild_array(view_buffer);
    _pdm_status("MEMbuild_array", status);
    if (status != MEM_S_SUCCESS) 
      return(PDM_E_BUILD_ARRAY);
    view_data = (char **)view_buffer->data_ptr;
    PDUget_buffer_col(view_buffer, "p_viewname", &viewname_col);
    PDUfill_in_string(&viewname, view_data[viewname_col]);
    }
  
  PDUfill_in_string(&PDU_viewname,viewname);
  /* extract serial number from part */
  status = co$part_get_attr(msg = &msg, mod_env = spr_mod_env, part = spr_part,
                            attr = "serial", value = attr_value, type = &type);
  if (!(status & msg & 1))
    return(PDM_E_INVALID_PART_POINTER);

  sscanf(attr_value, "%d", &coord.objid);
  coord.osnum = spr_mod_env->md_id.osnum;
  status = om$send(msg = message GRgencs.GRgetmatrix(&msg, src_matrix), 
                   senderid = NULL_OBJID,
                   targetid = coord.objid, 
                   targetos = coord.osnum);
  _pdm_status("GRgetmatrix", status);

  if (strcmp(cpr_incstr, "N") == 0)
    background = TRUE;
  PDUfill_in_string(&PDU_filename, cpr_cofilename);
  if ((strcmp(parent_parttype, "D") == 0) || 
      (strcmp(parent_parttype, "d") == 0))
    {
    _pdm_debug("attaching part to a drawing part", 0);
    status = PDUmatrix_to_point(src_matrix, &origin_pt);
    _pdm_status("PDUmatrix_to_point", status);
    MAinvmx(&status, &four, src_matrix, src_matrix);
    _pdm_debug("MAinvmx = %d", status);
    status = PDUadd_points(src_matrix, origin_pt, &x_axis_pt,0,1,2);
    _pdm_status("PDUadd_points", status);
    status = PDUadd_points(src_matrix, origin_pt, &y_axis_pt,4,5,6);
    _pdm_status("PDUadd_points", status);
    origin[0] = origin_pt.x;
    origin[1] = origin_pt.y;
    origin[2] = origin_pt.z;
    x_point[0] = x_axis_pt.x;
    x_point[1] = x_axis_pt.y;
    x_point[2] = x_axis_pt.z;
    y_point[0] = y_axis_pt.x;
    y_point[1] = y_axis_pt.y;
    y_point[2] = y_axis_pt.z;

    /* Get coord sys rotation matrix */
    status = MA3protmx(&sts, origin, x_point, y_point, rot_matrix);
    _pdm_status("MA3protmx", status);

    PDUdump_matrix(rot_matrix);
    if ((display) && (strcmp(display, "Y") == 0))
      display_flag = TRUE;
    else
      display_flag = FALSE;
    /* attach drawing graphically */
    status = PDUattach_ref_to_GRpart(spr_mod_env,*spr_part, src_matrix, 
                                     cpr_viewname, cpr_cofilename, 
                                     cpr_catno, cpr_itemno, display_flag, 
                                      TRUE, background,
                                     rot_matrix, origin, &cs_id, &refobjid);
    }
  else
    {
    _pdm_debug("attaching regular part", 0);
    if ((display) && (strcmp(display, "") != 0))
      display_flag = TRUE;
    else if (strcmp(display, "Y") == 0)
      display_flag = TRUE;
    else
      display_flag = FALSE;
    status = PDUattach_ref_to_GRpart(spr_mod_env, *spr_part, src_matrix, 
                                     cpr_viewname, cpr_cofilename, 
                                     cpr_catno, cpr_itemno, display_flag,FALSE, 
                                     background,
                                     rot_matrix, origin, NULL, &refobjid);
    }
  _pdm_status("PDUattach_ref_to_GRpart", status);
  if (status != PDM_S_SUCCESS)
    return(PDM_E_ATTACH_PART);

  if ((strcmp(parent_parttype, "D") == 0) || 
      (strcmp(parent_parttype, "d") == 0))
    {
    /* add coordinate system to GRpart */
    objects[0].obj_id.objid = coord.objid;
    objects[0].obj_id.osnum = coord.osnum;
    objects[0].mod_env = *spr_mod_env;
    own_index[0] = PDU_K_MAXINT;
    status = om$send (msg = message GRowner.GRadd_components(&msg, spr_mod_env,
                                                             &num_objects, 
                                                             objects,
                                                             own_index, NULL),
                      senderid = spr_part->objid, 
                      targetid = spr_part->objid, 
                      targetos = spr_part->osnum);
    }
  
  /* update the attach flag for this GRpart */
  sprintf(attr_value, "%d", refobjid.objid);
  _pdm_debug("refobjid.objid %d", refobjid.objid);
  status = co$part_put_attr(msg = &msg, mod_env = spr_mod_env, part = spr_part,
                            attr = "attach_flag", value = attr_value, 
                            type = GR_DYNAMIC_ATTR);

  /* need to update viewname for this part */
  if ((viewname) && (strcmp(viewname, "") != 0))
     sprintf(tmp_viewname,"\"%s\"", viewname);
  else
    strcpy(tmp_viewname, "");

  status = co$part_put_attr(msg = &msg, mod_env = spr_mod_env, part = spr_part,
                            attr = "view_name", value = tmp_viewname, 
                            type = GR_DYNAMIC_ATTR);
  if (!(status & msg & 1))
    return(PDM_E_INVALID_PART_POINTER);
  
  if ((strcmp(parent_parttype, "D") != 0) &&
      (strcmp(parent_parttype, "d") != 0))
    {
    status = PDUget_context_from_refid(&refobjid, &contextid);
    _pdm_status("PDUget_context_from_refid", status);
    if (!status)
      return(PDM_E_ATTACH_PART);
    status = PDUconstruct_refid_string(&refobjid, &contextid, refid_string);
    _pdm_status("PDUconstruct_refid_string", status);
  
   PDUmodify_exp(0, assy_path, "refid", refid_string, spr_mod_env->md_id.osnum);
    }
  if (view_buffer)
    MEMclose(&view_buffer);
  if (file_buffer)
    MEMclose(&file_buffer);
   if ((viewname) && (strcmp(viewname, "") != 0))
     free(viewname);
  return(PDM_S_SUCCESS);
  }

IGRint PDUfind_dynloc_name(cpr_dynloc_name, cpr_prompts, ir_numloc)

  IGRchar *cpr_dynloc_name;
  IGRchar **cpr_prompts;
  IGRint  ir_numloc;

  {
  int row = -1;
  int i;

  _pdm_debug("PDUfind_dynloc_name", 0);
  for (i = 0; i < ir_numloc; i++)
    {
    if (strcmp(cpr_dynloc_name, cpr_prompts[i]) == 0)
      {
      _pdm_debug("match for <%s> found", cpr_dynloc_name);
      row = i;
      break;
      }
    }
  
  return(row);
  }

IGRlong pdmoPlacePart(lw_status,spr_mod_env, spw_part, cpr_ccatalogname, 
                      cpr_citemname, cpr_citemrev, cpr_cofilename, cpr_usageid, 
                      cpr_viewname, cpr_quantity, cpr_explode, cpr_attach, 
                      cpr_alttagno, cpr_incstr, cpr_incbom, ir_dyn_count, 
                      cpr_dyn_names, cpr_dyn_values, ir_dynloc_count, 
                      cpr_dynloc_names, spr_dynloc_id, dar_origin, dar_x_point,
                      dar_y_point, spr_position_cs, edit_display)

  IGRlong *lw_status;            /* Output: Status of function for PPL API */
  struct GRmd_env *spr_mod_env;  /* Input: Module information */
  struct GRid     *spw_part;     /* Output: Object ID of part placed */
  IGRchar *cpr_ccatalogname;     /* Input: Catalog name of part to be placed*/
  IGRchar *cpr_citemname;        /* Input: Part number of part to be placed*/
  IGRchar *cpr_citemrev;         /* Input: Part revision of part to be placed */
  IGRchar *cpr_cofilename;       /* Input: Filename */
  IGRchar *cpr_usageid;          /* Input: Part usageid */
  IGRchar *cpr_viewname;         /* Input: Graphic view name */
  IGRdouble cpr_quantity;        /* Input: Part quantity */
  IGRchar *cpr_explode;          /* Input: Explode in BOM (Y or N) */
  IGRchar *cpr_attach;           /* Input: Attach file (Y or N) */
  IGRchar *cpr_alttagno;         /* Input: Alternate tag number */
  IGRchar *cpr_incstr;           /* Input: Background part (Y or N) */
  IGRchar *cpr_incbom;           /* Input: Include in BOM (Y or N) */
  IGRint  ir_dyn_count;          /* Input: Dynamic attribute count */
  IGRchar **cpr_dyn_names;       /* Input: Dynamic attribute name array */
  IGRchar **cpr_dyn_values;      /* Input: Dynamic attribute value array */
  IGRint  ir_dynloc_count;       /* Input: Dynamic locate input count */
  IGRchar **cpr_dynloc_names;    /* Input: Dynamic locate input names */
  struct GRid *spr_dynloc_id;    /* Input: Dynamic locate input object ID */
  IGRdouble *dar_origin;         /* Input: Position by 3 point origin point */
  IGRdouble *dar_x_point;        /* Input: Position by 3 point x-axis point */
  IGRdouble *dar_y_point;        /* Input: Position by 3 point y-axis point */
  struct GRid *spr_position_cs;  /* Input: position by coordinate system */
  IGRchar *edit_display;         /* Input: Edit assembly display (Y/N) */
  {
  IGRlong msg;
  IGRlong status;
  IGRlong NumberOfBytes;
  IGRlong BytesReceived;
  IGRshort free_mod = FALSE;
  IGRshort position = TRUE;
  IGRint  type;
  IGRint  filename_col;
  IGRint  i;
  IGRint  catno_col;
  IGRint  itemno_col;
  IGRint  num_objects = 1;
  IGRint  numcoll;
  IGRint  numloc;
  IGRint  numtemp;
  IGRint  length;
  IGRint  instance_no;
  IGRint  row = -1;
  IGRint  own_index[1];
  IGRint  *locatables;
  IGRint  count = 0;
  IGRint  displayed = 0;
  IGRmatrix src_matrix;
  IGRchar quantity[MAX_VALUE];
  IGRchar attr_value[MAX_VALUE];
  IGRchar part_label[MAX_VALUE];
  IGRchar origin_str[MAX_VALUE];
  IGRchar x_point_str[MAX_VALUE];
  IGRchar y_point_str[MAX_VALUE];
  IGRchar usageid[DI_PATH_MAX];
  IGRchar assy_path[DI_PATH_MAX];
  IGRchar child_dir[DI_PATH_MAX];
  IGRchar serial_no[10];
  IGRchar *child_no = NULL;
  IGRchar *explode = NULL;
  IGRchar *attach = NULL;
  IGRchar *save_attach = NULL;
  IGRchar *incstr = NULL;
  IGRchar *incbom = NULL;
  IGRchar *tmpstr = NULL;
  IGRchar *tmpbom = NULL;
  IGRchar *tmpexp = NULL;
  IGRchar *p_parttype = NULL;
  IGRchar *active_parttype = NULL;
  IGRchar *cofilename = NULL;
  IGRchar *catalog_no = NULL;
  IGRchar *item_no = NULL;
  IGRchar *description = NULL;
  IGRchar *viewname = NULL;
  IGRchar *tmp_explode = NULL;
  IGRchar *alttag = NULL;
  IGRchar **filename_data = NULL;
  IGRchar **asm_data = NULL;
  IGRchar **prompts = NULL;
  MEMptr  asm_bufr = NULL;
  MEMptr  filename_bufr = NULL;
  struct  GRid part_id;
  struct  GRid cs_id;
  struct  GRid hdr;
  struct  GRid *rg_grid = NULL;
  struct GRobj_env objects[1];
  extern IGRchar *PDU_explode_BOM;
  extern IGRchar *PDU_incl_ASM;
  extern IGRchar *PDU_incl_BOM;
  extern IGRchar *PDU_usage_id;
  extern IGRchar *PDU_tagno;
  extern IGRshort PDU_attach;
  extern struct PDUrefresh *refresh;
  extern struct PDUuser *user;
  extern struct  GRid *grid_list;
  extern MEMptr  PDU_dyn_attr_bufr;
  extern MEMptr  PDU_dyn_data_bufr;
  extern MEMptr  PDU_dyn_value_bufr;
  extern MEMptr  PALdyn_bufr;
  extern MEMptr  filterbuf;

  _pdm_debug("In pdmoPlacePart", 0);

  _pdm_debug("cpr_usageid = <%s>", cpr_usageid);
  _pdm_debug("cpr_quantity = <%lf>", cpr_quantity);
  _pdm_debug("cpr_alttagno = <%s>", cpr_alttagno);
  _pdm_debug("cpr_incstr = <%s>", cpr_incstr);
  _pdm_debug("cpr_incbom = <%s>", cpr_incbom);
  _pdm_debug("PDU_tagno = <%s>", PDU_tagno);

  _pdm_debug("PDU_apiflag = <%d>", (char *)PDU_apiflag);

  if (PDUnullstr(user->username))
    {
    *lw_status = PDM_E_USER_NOT_LOGGED_IN;
    return(PDM_E_USER_NOT_LOGGED_IN);
    }

  if (cpr_ccatalogname == NULL)
    {
    *lw_status = PDM_E_CAT_FIELD_BLANK;
    return(PDM_E_CAT_FIELD_BLANK);
    }
  else if (strcmp(cpr_ccatalogname, "") == 0)
    {
    *lw_status = PDM_E_CAT_FIELD_BLANK;
    return(PDM_E_CAT_FIELD_BLANK);
    }

  if (cpr_citemname == NULL)
    {
    *lw_status = PDM_E_PART_FIELD_BLANK;
    return(PDM_E_PART_FIELD_BLANK);
    }
  else if (strcmp(cpr_citemname, "") == 0)
    {
    *lw_status = PDM_E_PART_FIELD_BLANK;
    return(PDM_E_PART_FIELD_BLANK);
    }

  if (cpr_citemrev == NULL)
    {
    *lw_status = PDM_E_REV_FIELD_BLANK;
    return(PDM_E_REV_FIELD_BLANK);
    }
  else if (strcmp(cpr_citemrev, "") == 0)
    {
    *lw_status = PDM_E_REV_FIELD_BLANK;
    return(PDM_E_REV_FIELD_BLANK);
    }

  if (spr_mod_env == NULL)
    {
    _pdm_debug("getting mod_env", 0);
    spr_mod_env = (struct GRmd_env *)malloc(sizeof(struct GRmd_env));
    NumberOfBytes = sizeof(struct GRmd_env);
    status = gr$get_module_env(
                              msg = &msg,
                              sizbuf = &NumberOfBytes,
                              buffer = spr_mod_env,
                              nret = &BytesReceived);
    free_mod = TRUE;
    }

  /* MJG - 10/3/95 - The refresh data needs to be verified IFF pdmoPlacePart
     is being called from the API */

  if (PDU_apiflag)
    {
    if (cpr_ccatalogname)
      length = strlen(cpr_ccatalogname);
    else
      length = 40;
    for (i = 0; i < length; i++)
      {
      if (cpr_ccatalogname[i] == ' ')
        {
        *lw_status = PDM_E_CATALOG_NOT_FOUND;
        return(PDM_E_CATALOG_NOT_FOUND);
        }
      }
  
    status = PDMrverify_catalog("", cpr_ccatalogname);
    _pdm_status("PDMrverify_catalog", status);
  
    if (status != PDM_S_SUCCESS)
      {
      *lw_status = status;
      return(status);
      }
  
    status = PDUcheck_partnum(cpr_ccatalogname, cpr_citemname, cpr_citemrev);
    _pdm_status("PDUcheck_partnum", status);
  
    if (status != PDM_S_SUCCESS)
      {
      *lw_status = PDM_E_PART_NOT_FOUND;
      return(PDM_E_PART_NOT_FOUND);
      }
    }
  
  status = PDUget_description_for_part(cpr_ccatalogname, cpr_citemname, 
                                       cpr_citemrev, &description);
  _pdm_status("PDUget_description_for_part", status);

  if (PDU_apiflag)
    {
    _pdm_debug("validating usageid for API", 0);
    /* validate cpr_usageid if given */
    if ((cpr_usageid) && (strcmp(cpr_usageid, "") != 0))
      {
      status = PDUvalidate_usageid(spr_mod_env, cpr_usageid);
      _pdm_status("PDUvalidate_usageid", status);
   
      if (status != PDM_S_SUCCESS)
        {
        *lw_status = status;
        return(status);
        }
      strcpy(usageid, "");
      strcpy(usageid, cpr_usageid);
      } 
    else
      {
      status = PDUapi_default_usageid(spr_mod_env, cpr_ccatalogname,
                                      cpr_citemname, cpr_citemrev, usageid);
      _pdm_status("PDUapi_default_usageid", status);
   
      if (status != PDM_S_SUCCESS)
        {
        *lw_status = status;
        return(status);
        }
      }
    }
  else
    {
    strcpy(usageid, "");
    strcpy(usageid, cpr_usageid);
    _pdm_debug("usageid = <%s>", usageid);
    }
  
  di$give_pathname(osnum = spr_mod_env->md_id.osnum, pathname = part_label);
  _pdm_debug("part label = %s", part_label);
  _pdm_debug("osnum = %d", spr_mod_env->md_id.osnum);
  strcat(part_label, ":usr:");
  strcat(part_label, usageid);

  PDUfill_in_string(&viewname, "");

  if (PDU_apiflag)
    {
    /* Verify cpr_quantity is valid if given */
    strcpy(quantity, "");
    _pdm_debug("quantity = %lf", cpr_quantity);
    sprintf(quantity, "%lf", cpr_quantity);
    status = PDUvalidate_quantity(quantity);
    _pdm_status("PDUvalidate_quantity", status);
    if (status != PDM_S_SUCCESS)
      {
      *lw_status = PDM_E_INVALID_VALUE;
      return(PDM_E_INVALID_VALUE);
      }
    }
  else
    {
    sprintf(quantity, "%lf", cpr_quantity);
    }

  /* Verify cpr_explode is Y or N */

  if ((cpr_explode) && (strcmp(cpr_explode, "") != 0))
    {
    if ((strcmp(cpr_explode, "Y") != 0) && (strcmp(cpr_explode, "N") != 0))
      {
      _pdm_debug("cpr_explode has invalid value <%s>", cpr_explode);
      *lw_status = PDM_E_INVALID_VALUE;
      return(PDM_E_INVALID_VALUE);
      }
    PDUfill_in_string(&explode, cpr_explode);
    }
  else if ((PDU_explode_BOM) && (strcmp(PDU_explode_BOM, "") != 0))
    PDUfill_in_string(&explode, PDU_explode_BOM);
  else
    PDUfill_in_string(&explode, "Y"); 
  
  /* verify cpr_attach is Y or N */
  if ((cpr_attach) && (strcmp(cpr_attach, "") != 0))
    {
    if ((strcmp(cpr_attach, "Y") != 0) && (strcmp(cpr_attach, "N") != 0))
      {
      _pdm_debug("cpr_attach has invalid value <%s>", cpr_attach);
      *lw_status = PDM_E_INVALID_VALUE;
      return(PDM_E_INVALID_VALUE);
      }
    PDUfill_in_string(&attach, cpr_attach);
    }
  else if (PDU_attach)
    PDUfill_in_string(&attach, "Y");
  else
    PDUfill_in_string(&attach, "N");

  /* verify cpr_alttagno is valid if given */
  if ((cpr_alttagno) && (strcmp(cpr_alttagno, "") != 0))
    {
    if (PDU_apiflag)
      {
      status = PDUvalidate_alttagno(spr_mod_env, cpr_ccatalogname,cpr_citemname,
                                    cpr_citemrev, cpr_alttagno);
      _pdm_status("PDUvalidate_alttagno", status);
  
      if (status != PDM_S_SUCCESS)
        {
        *lw_status = PDM_E_DUP_ALTTAGNO;
        return(PDM_E_DUP_ALTTAGNO);
        }
      }
    PDUfill_in_string(&alttag, cpr_alttagno);
    }
  else 
    PDUfill_in_string(&alttag, "");

  /* verify cpr_incstr is Y or N */
  if ((cpr_incstr) && (strcmp(cpr_incstr, "") != 0))
    {
    if ((strcmp(cpr_incstr, "Y") != 0) && (strcmp(cpr_incstr, "N") != 0))
      {
      _pdm_debug("cpr_incstr has invalid value <%s>", cpr_incstr);
      *lw_status = PDM_E_INVALID_VALUE;
      return(PDM_E_INVALID_VALUE);
      }
    PDUfill_in_string(&incstr, cpr_incstr);
    }
  else if ((PDU_incl_ASM) && (strcmp(PDU_incl_ASM, "") != 0))
    PDUfill_in_string(&incstr, PDU_incl_ASM);
  else
    PDUfill_in_string(&incstr, "Y");

  /* verify cpr_incbom is Y or N */
  if ((cpr_incbom) && (strcmp(cpr_incbom, "") != 0))
    {
    if ((strcmp(cpr_incbom, "Y") != 0) && (strcmp(cpr_incbom, "N") != 0))
      {
      _pdm_debug("cpr_incbom has invalid value <%s>", cpr_incbom);
      *lw_status = PDM_E_INVALID_VALUE;
      return(PDM_E_INVALID_VALUE);
      }
    PDUfill_in_string(&incbom, cpr_incbom);
    }
  else if ((PDU_incl_BOM) && (strcmp(PDU_incl_BOM, "") != 0))
    PDUfill_in_string(&incbom, PDU_incl_BOM);
  else 
    PDUfill_in_string(&incbom, "Y");

  status = PDUget_parttype(cpr_ccatalogname, cpr_citemname, cpr_citemrev, 
                           &p_parttype);
  _pdm_status("PDUget_parttype", status);

  PDUfill_in_string(&refresh->rev_parttype, p_parttype);
  if ((strcmp(p_parttype, "M") == 0) || (strcmp(p_parttype, "m") == 0))
    {
    *lw_status = PDM_E_INVALID_PART_TYPE;
    return(PDM_E_INVALID_PART_TYPE);
    }

  if ((strcmp(p_parttype, "N") == 0) || (strcmp(p_parttype, "n") == 0)) 
    {
    /* validate dynamic attribute input if given */
    _pdm_debug("non-graphic part placement", 0);
    if ((ir_dyn_count > 0) && ((cpr_dyn_names == NULL) || 
        (cpr_dyn_values == NULL)))
      {
      *lw_status = PDM_E_DYN_TRIP;
      return(PDM_E_DYN_TRIP);
      }
   else if ((ir_dyn_count <= 0) && ((cpr_dyn_names) || (cpr_dyn_values)))
     {
      *lw_status = PDM_E_DYN_TRIP;
      return(PDM_E_DYN_TRIP);
      }

   /* Verify placement is not cyclic */
   status = PDUis_cyclic_placement(cpr_ccatalogname, cpr_citemname,cpr_citemrev,
                                   &asm_bufr);
   _pdm_status ("PDUis_cyclic_placement", status);

   if (status == -1)
      {
       _pdm_debug("PDUis_cyclic_placement failed", 0);
       return(PDM_E_PLACE_PART);
      }

   if (status)
     {
     *lw_status = PDM_E_CYCLIC_PLACEMENT;
     status = PDM_E_CYCLIC_PLACEMENT;
     return(status);
     }

   /* Get child number seed from object space */
   di$give_pathname(
                    osnum = spr_mod_env->md_id.osnum,
                    pathname = child_dir
                   );

   strcat(child_dir,":");
   strcat(child_dir,"PDU");
   strcat(child_dir,":");
   strcat(child_dir,"child_no");
  
   /* Check to see if child number seed exists */
   status = di$ls(regexp = child_dir, ptr = &count);

   if (count == 0)
   /* Need to create a child number seed */
      {
       _pdm_debug("child_no seed will be created", 0);
       strcat(child_dir, ":");
       strcat(child_dir, "1");
       strcat(child_dir, ":");
       status = di$mkpath(pathname = child_dir);
       PDUfill_in_string(&child_no, "1");
      }

   else
     {
      /* Generate a child number */
      status = PDUgenerate_child_no(
                                    &child_no,
                                    spr_mod_env->md_id.osnum
                                   );
      _pdm_debug("Child_no = <%s>", child_no);
     }

   /* check instance no */
/* MJG - 10/3/95 - instance_no has already been generated in the case of graphic
 part placement only.  This function still needs to be called for the API and 
 for revise assembly */
   status = PDUgenerate_instance_number(
                                        cpr_ccatalogname,
                                        cpr_citemname, 
                                        cpr_citemrev,
                                        &instance_no,
                                        spr_mod_env
                                       );
   _pdm_debug("instance_no = <%d>", (char *)instance_no);
   
   /* based on the instanace no call PDUload_assy_struct_buffer */
   if (instance_no > 1)
     {
     co$part_get_attr(
                      msg = &msg,
                      mod_env = spr_mod_env, 
                      catalog = cpr_ccatalogname,
                      number = cpr_citemname, 
                      revision = cpr_citemrev, 
                      attr = "child_no",
                      value = attr_value,
                      type = &type
                     );

     PDUunquote(attr_value);

     di$give_pathname(
                     osnum = spr_mod_env->md_id.osnum,
                     pathname = assy_path 
                    );
     strcat(assy_path, ":ASSEMBLY:P");
     strcat(assy_path, attr_value);
     status = PDUload_assy_struct_buffer(
                                         spr_mod_env,
                                         &asm_bufr,
                                         -1,
                                         assy_path
                                        );
     _pdm_status("PDUload_assy_struct_buffer", status);

     if (status != PDM_S_SUCCESS)
       return(status);
     }

    PDUfill_in_string(&cofilename, "");
    /* call PDUadd_assy_struct_from_buffer */
    if (instance_no > 1)
      {
      status = PDUadd_assy_struct_from_buffer(
                                            spr_mod_env,
                                            child_no, 
                                            cofilename, 
                                            asm_bufr,
                                            2
                                           );
      }
    else
      {
      status = PDUadd_assy_struct_from_buffer(
                                            spr_mod_env,
                                            child_no, 
                                            cofilename, 
                                            asm_bufr,
                                            1
                                           );
     }
   _pdm_status("PDUadd_assy_struct_from_buffers", status);

   strcpy(assy_path, "");
   di$give_pathname(
                   osnum = spr_mod_env->md_id.osnum,
                   pathname = assy_path 
                  );
   strcat(assy_path, ":ASSEMBLY:P");
   strcat(assy_path, child_no);
   PDUmodify_exp(0, assy_path, "usage_id", usageid, spr_mod_env->md_id.osnum);
   PDUmodify_exp(0, assy_path, "quantity", quantity, spr_mod_env->md_id.osnum);
   PDUmodify_exp(0, assy_path, "attached", "N", spr_mod_env->md_id.osnum);
   PDUmodify_exp(0, assy_path, "description", description, 
                 spr_mod_env->md_id.osnum);
   status = PDUcreate_GRpart(
                             spr_mod_env,
                             cpr_ccatalogname,
                             cpr_citemname, 
                             cpr_citemrev,
                             child_no,
                             quantity,
                             alttag,
                             usageid,
                             viewname,
                             "",
                             p_parttype,
                             incbom,
                             incstr,
                             explode,
                             attach,
                             &part_id
                            );
   _pdm_status("PDUcreate_GRpart", status);
   if (status != PDM_S_SUCCESS)
     return(PDM_E_PLACE_PART);

   status = PDUincrement_child_no(spr_mod_env->md_id.osnum);
   _pdm_status("PDUincrement_child_no", status);

  _pdm_debug("checking for revise assembly", 0);
  if (forms.rev_assy_form_id)
    {
    FIf_is_displayed(forms.rev_assy_form_id, &displayed);
    if (displayed)
      {
      _pdm_debug("saving placement attributes", 0);
      current_rev_assy->p_childno = atoi(child_no);
      PDUfill_in_string(&(current_rev_assy)->p_tagno, PDU_tagno);
      PDUfill_in_string(&(current_rev_assy)->new_usageid, usageid);
      PDUfill_in_string(&(current_rev_assy)->p_quantity, quantity);
      PDUfill_in_string(&(current_rev_assy)->p_alttagno, alttag);
      PDUfill_in_string(&(current_rev_assy)->p_incbom, incbom);
      PDUfill_in_string(&(current_rev_assy)->p_incstr, incstr);
      PDUfill_in_string(&(current_rev_assy)->p_explode, explode);
      if (PDU_attach)
        PDUfill_in_string(&(current_rev_assy)->p_attached, "Y");
      else
        PDUfill_in_string(&(current_rev_assy)->p_attached, "N");
      }
    }

   /* edit placed part for all attributes */
   _pdm_debug("checking for dynamic attributes", 0);
   if ((ir_dyn_count > 0) && (cpr_dyn_names != NULL) && (cpr_dyn_values != 
        NULL))
     {
     _pdm_debug("ir_dyn_count = <%d>", ir_dyn_count);
     for ( i = 0; i < ir_dyn_count; i++)
       {
       status = co$part_get_attr(msg = &msg, mod_env = spr_mod_env,
                                 part = &part_id, attr = cpr_dyn_names[i], 
                                 value = attr_value, type = &type);
       if (!(status & msg & 1))
         {
         _pdm_debug("attribute %s does not exist in GRpart", cpr_dyn_names[i]);
         continue;
         }
       status = co$part_put_attr(msg = &msg, mod_env = spr_mod_env, 
                                 part = &part_id, attr = cpr_dyn_names[i], 
                                 value = cpr_dyn_values[i], 
                                 type = type);
       if (!(status & msg & 1))
         _pdm_debug("Edit of attribute %s failed", cpr_dyn_names[i]);
       else
         _pdm_debug("Edit of attribute %s successful", cpr_dyn_names[i]);
       }
     }

  /* set spw_part to part_id */
  if (spw_part == NULL)
    spw_part = (struct GRid *)malloc(sizeof(struct GRid));
  spw_part->objid = part_id.objid;
  spw_part->osnum = part_id.osnum;

  *lw_status = PDM_S_SUCCESS;
  return(PDM_S_SUCCESS);
  }
  else if ((strcmp(p_parttype, "P") != 0) && (strcmp(p_parttype, "p") != 0)) 
    {
    _pdm_debug("Standard part placement", 0);

    /* validate postitions if given */
    if ((dar_origin) && (dar_x_point) && (dar_y_point) && (spr_position_cs))
      {
      _pdm_debug("points and cs given", 0);
      *lw_status = PDM_E_BAD_POSITION;
      return(PDM_E_BAD_POSITION);
      }
    if ((dar_origin) && ((dar_x_point == NULL) || (dar_y_point == NULL)))
      {
      *lw_status = PDM_E_BAD_POSITION;
      return(PDM_E_BAD_POSITION);
      }
    if ((dar_x_point) && ((dar_origin == NULL) || (dar_y_point == NULL)))
      {
      *lw_status = PDM_E_BAD_POSITION;
      return(PDM_E_BAD_POSITION);
      }
    if ((dar_y_point) && ((dar_origin == NULL) || (dar_x_point == NULL)))
      {
      *lw_status = PDM_E_BAD_POSITION;
      return(PDM_E_BAD_POSITION);
      }

    /* validate dynamic attribute input if given */
    if ((ir_dyn_count > 0) && ((cpr_dyn_names == NULL) || 
        (cpr_dyn_values == NULL)))
      {
      *lw_status = PDM_E_DYN_TRIP;
      return(PDM_E_DYN_TRIP);
      }
   else if ((ir_dyn_count <= 0) && ((cpr_dyn_names) || (cpr_dyn_values)))
     {
      *lw_status = PDM_E_DYN_TRIP;
      return(PDM_E_DYN_TRIP);
      }

   if ((dar_origin == NULL) && (dar_x_point == NULL) && (dar_y_point == NULL) &&
       (spr_position_cs == NULL))
     {
     position = FALSE;
     PDUfill_in_string(&attach, "N");
     }

   /* Verify placement is not cyclic */
   status = PDUis_cyclic_placement(cpr_ccatalogname, cpr_citemname,cpr_citemrev,
                                   &asm_bufr);
   _pdm_status ("PDUis_cyclic_placement", status);

   if (status == -1)
      {
       _pdm_debug("PDUis_cyclic_placement failed", 0);
       return(PDM_E_PLACE_PART);
      }

   if (status)
     {
     *lw_status = PDM_E_CYCLIC_PLACEMENT;
     status = PDM_E_CYCLIC_PLACEMENT;
     return(status);
     }

   /* Verify n_cofilename if given */
   if ((cpr_cofilename) && (strcmp(cpr_cofilename, "") != 0))
     {
     if (PDU_apiflag)
       {
       status = PDUvalid_filename(cpr_ccatalogname, cpr_citemname, cpr_citemrev,
                                  cpr_cofilename);
       _pdm_status("PDUvalid_filename", status);
       if (status != PDM_S_SUCCESS)
         {
         *lw_status = PDM_E_FILE_NOT_FOUND;
         status = PDM_E_FILE_NOT_FOUND;
         return(status);
         }
       }
     PDUfill_in_string(&cofilename, cpr_cofilename);
     }

   if ((cofilename) && (strcmp(cofilename, "") != 0))
     _pdm_debug("file <%s> already given", cofilename);
   else if ((strcmp(attach, "Y") == 0) || (strcmp(attach, "y") == 0))
     {
     status = PDMget_filenames(cpr_ccatalogname, cpr_citemname, cpr_citemrev, 
                               &filename_bufr);
     _pdm_status("PDMget_filenmes", status);
     status = MEMbuild_array(filename_bufr);
     _pdm_status("MEMbuild_array", status);
     if (status != MEM_S_SUCCESS)
       {
       *lw_status = PDM_E_BUILD_ARRAY;
       return(PDM_E_BUILD_ARRAY);
       }
     PDUget_buffer_col(filename_bufr, "n_cofilename", &filename_col);
     filename_data = (char **)filename_bufr->data_ptr;
     PDUfill_in_string(&cofilename, filename_data[(filename_bufr->columns *
                           0) + filename_col]);
     if (cofilename == NULL)
       {
       *lw_status = PDM_E_OM_FILE;
       return(PDM_E_OM_FILE);
       }
     else if (strcmp(cofilename, "") == 0)
       {
       *lw_status = PDM_E_OM_FILE;
       return(PDM_E_OM_FILE);
       }
     }
   else
     PDUfill_in_string(&cofilename, "");

   /* Get child number seed from object space */
   di$give_pathname(
                    osnum = spr_mod_env->md_id.osnum,
                    pathname = child_dir
                   );

   strcat(child_dir,":");
   strcat(child_dir,"PDU");
   strcat(child_dir,":");
   strcat(child_dir,"child_no");
  
   /* Check to see if child number seed exists */
   status = di$ls(regexp = child_dir, ptr = &count);

   if (count == 0)
   /* Need to create a child number seed */
      {
       _pdm_debug("child_no seed will be created", 0);
       strcat(child_dir, ":");
       strcat(child_dir, "1");
       strcat(child_dir, ":");
       status = di$mkpath(pathname = child_dir);
       PDUfill_in_string(&child_no, "1");
      }

   else
     {
      /* Generate a child number */
      status = PDUgenerate_child_no(
                                    &child_no,
                                    spr_mod_env->md_id.osnum
                                   );
      _pdm_debug("Child_no = <%s>", child_no);
     }

   /* check instance no */
/* MJG - 10/3/95 - instance_no has already been generated in the case of graphic
 part placement only.  This function still needs to be called for the API and 
 for revise assembly */
   status = PDUgenerate_instance_number(
                                        cpr_ccatalogname,
                                        cpr_citemname, 
                                        cpr_citemrev,
                                        &instance_no,
                                        spr_mod_env
                                       );
   
   _pdm_debug("instance_no = <%d>", (char *)instance_no);

   /* based on the instanace no call PDUload_assy_struct_buffer */
   if (instance_no > 1)
     {
     co$part_get_attr(
                      msg = &msg,
                      mod_env = spr_mod_env, 
                      catalog = cpr_ccatalogname,
                      number = cpr_citemname, 
                      revision = cpr_citemrev, 
                      attr = "child_no",
                      value = attr_value,
                      type = &type
                     );

     PDUunquote(attr_value);

     di$give_pathname(
                     osnum = spr_mod_env->md_id.osnum,
                     pathname = assy_path 
                    );
     strcat(assy_path, ":ASSEMBLY:P");
     strcat(assy_path, attr_value);

     status = PDUload_assy_struct_buffer(
                                         spr_mod_env,
                                         &asm_bufr,
                                         -1,
                                         assy_path
                                        );
     _pdm_status("PDUload_assy_struct_buffer", status);
     if (status != PDM_S_SUCCESS)
       return(status);
     }

    /* call PDUadd_assy_struct_from_buffer */
    if (instance_no > 1)
      {
      status = PDUadd_assy_struct_from_buffer(
                                            spr_mod_env,
                                            child_no, 
                                            cofilename, 
                                            asm_bufr,
                                            2
                                           );
      }
    else
      {
      status = PDUadd_assy_struct_from_buffer(
                                            spr_mod_env,
                                            child_no, 
                                            cofilename, 
                                            asm_bufr,
                                            1
                                           );
     }
   _pdm_status("PDUadd_assy_struct_from_buffers", status);

   strcpy(assy_path, "");
   di$give_pathname(
                   osnum = spr_mod_env->md_id.osnum,
                   pathname = assy_path 
                  );
   strcat(assy_path, ":ASSEMBLY:P");
   strcat(assy_path, child_no);
   PDUmodify_exp(0, assy_path, "usage_id", usageid, spr_mod_env->md_id.osnum);
   PDUmodify_exp(0, assy_path, "quantity", quantity, spr_mod_env->md_id.osnum);
   PDUmodify_exp(0, assy_path, "attached", "Y", spr_mod_env->md_id.osnum);
   PDUmodify_exp(0, assy_path, "description", description, 
                 spr_mod_env->md_id.osnum);

   status = PDUupdate_local_flag_in_assembly(spr_mod_env);
   _pdm_status("PDUupdate_local_flag_in_assembly", status);

   if (asm_bufr)
     {
     MEMclose(&asm_bufr);
     asm_bufr = NULL;
     }

   /* MJG - 10/3/95 - only call PDUload_assy_struct_buffer if edit assy = N */
/* MJG - 11/22/95 - always call PDUload_assy_struct_buffer is part is being 
   placed from the revise assembly form, because it ignores the EAD switch. */
   if ((strcmp(edit_display, "Y") != 0) ||
       (PDU_form_id == forms.rev_assy_form_id))
     {
     status = PDUload_assy_struct_buffer(
                                       spr_mod_env,
                                       &asm_bufr,
                                       -1,
                                       assy_path
                                      );
     _pdm_status("PDUload_assy_struct_buffer", status);

     if (status != PDM_S_SUCCESS)
       return(status);
     }

/* MJG 11/22/95 - TR 139528288 - Do not display edit assy form when a part is
   being placed from the revise assy form */
   if ((strcmp(edit_display, "Y") == 0) &&
       (PDU_form_id != forms.rev_assy_form_id))
     {
     PDUmessage(PDS_M_PROCESSING_ASSY_DISP, 's');
     if (asm_bufr)
       {
       MEMclose(&asm_bufr);
       asm_bufr = NULL;
       }
     status = PDUload_assy_struct_buffer(spr_mod_env, &asm_bufr, -1, NULL);
     _pdm_status("PDUload_assy_struct_buffer", status);
     _pdm_debug("display edit display form", 0);
     status = PDUassembly_display_form(spr_mod_env, asm_bufr, TRUE,
                                       -1);
     _pdm_status("PDUassembly_display_form", status);
      if (status != PDM_S_SUCCESS)
        {
       status = PDUprocess_assembly_display(spr_mod_env, asm_bufr, FALSE, TRUE,
                                            FALSE);
        _pdm_status("PDUprocess_assembly_display", status);
        }
      else
        {
        status = WaitForEvent();
        if (!status)
          {
          status = PDUprocess_assembly_display(spr_mod_env, asm_bufr, FALSE,
                                            TRUE,FALSE);
          _pdm_status("PDUprocess_assembly_display", status);
          }
        else
          {
          PDUevaluate_exp(assy_path, "attached", &save_attach);
          PDUmodify_exp(0, assy_path,"attached", "Y", spr_mod_env->md_id.osnum);
          if (asm_bufr)
            {
            MEMclose(&asm_bufr);
            asm_bufr = NULL;
            }
          status = PDUload_assy_struct_buffer(spr_mod_env, &asm_bufr, -1, NULL);
          _pdm_status("PDUload_assy_struct_buffer", status);
          status = PDUprocess_assembly_display(spr_mod_env, asm_bufr, FALSE,
                                            TRUE,FALSE);
          _pdm_status("PDUprocess_assembly_display", status);
          }
        }
     }
   else
     {
     status = PDUprocess_assembly_display(spr_mod_env, asm_bufr, FALSE, TRUE, 
                                          FALSE);
     _pdm_status("PDUprocess_assembly_display", status);

     if (status != PDM_S_SUCCESS)
       return(status);
      }
   status = PDUcreate_GRpart(
                             spr_mod_env,
                             cpr_ccatalogname,
                             cpr_citemname, 
                             cpr_citemrev,
                             child_no,
                             quantity,
                             alttag,
                             usageid,
                             viewname,
                             "",
                             p_parttype,
                             incbom,
                             incstr,
                             explode,
                             attach,
                             &part_id
                            );
   _pdm_status("PDUcreate_GRpart", status);
   if (status != PDM_S_SUCCESS)
     return(PDM_E_PLACE_PART);

   status = PDUincrement_child_no(spr_mod_env->md_id.osnum);
   _pdm_status("PDUincrement_child_no", status);

  _pdm_debug("checking for revise assembly", 0);
  if (forms.rev_assy_form_id)
    {
    FIf_is_displayed(forms.rev_assy_form_id, &displayed);
    if (displayed)
      {
      _pdm_debug("saving placement attributes", 0);
      current_rev_assy->p_childno = atoi(child_no);
      PDUfill_in_string(&(current_rev_assy)->p_tagno, PDU_tagno);
      PDUfill_in_string(&(current_rev_assy)->new_usageid, usageid);
      PDUfill_in_string(&(current_rev_assy)->p_quantity, quantity);
      PDUfill_in_string(&(current_rev_assy)->p_alttagno, alttag);
      PDUfill_in_string(&(current_rev_assy)->p_incbom, incbom);
      PDUfill_in_string(&(current_rev_assy)->p_incstr, incstr);
      PDUfill_in_string(&(current_rev_assy)->p_explode, explode);
      if (PDU_attach)
        PDUfill_in_string(&(current_rev_assy)->p_attached, "Y");
      else
        PDUfill_in_string(&(current_rev_assy)->p_attached, "N");
      }
    }

   /* edit placed part for all attributes */
   if ((ir_dyn_count > 0) && (cpr_dyn_names != NULL) && (cpr_dyn_values != 
        NULL))
     {
     _pdm_debug("ir_dyn_count = <%d>", ir_dyn_count);
     for ( i = 0; i < ir_dyn_count; i++)
       {
       status = co$part_get_attr(msg = &msg, mod_env = spr_mod_env,
                                 part = &part_id, attr = cpr_dyn_names[i], 
                                 value = attr_value, type = &type);
       if (!(status & msg & 1))
         {
         _pdm_debug("attribute %s does not exist in GRpart", cpr_dyn_names[i]);
         continue;
         }
       status = co$part_put_attr(msg = &msg, mod_env = spr_mod_env, 
                                 part = &part_id, attr = cpr_dyn_names[i], 
                                 value = cpr_dyn_values[i], 
                                 type = type);
       if (!(status & msg & 1))
         _pdm_debug("Edit of attribute %s failed", cpr_dyn_names[i]);
       else
         _pdm_debug("Edit of attribute %s successful", cpr_dyn_names[i]);
       }
     }

  /* set spw_part to part_id */
  if (spw_part == NULL)
    spw_part = (struct GRid *)malloc(sizeof(struct GRid));
  spw_part->objid = part_id.objid;
  spw_part->osnum = part_id.osnum;

  if (!position)
    {
    *lw_status = PDM_S_SUCCESS;
    return(PDM_S_SUCCESS);
    }
  else if ((strcmp(p_parttype, "N") == 0) || (strcmp(p_parttype, "n") == 0))
    {
    *lw_status = PDM_S_SUCCESS;
    return(PDM_S_SUCCESS);
    }

  /* place by view alignment */
  if (spr_position_cs)
    {
    status = om$send(msg = message GRgencs.GRgetmatrix(&msg, src_matrix), 
                     senderid = NULL_OBJID,
                     targetid = spr_position_cs->objid, 
                     targetos = spr_position_cs->osnum);
    _pdm_status("GRgetmatrix", status);
    if (!(status & msg & 1))
      {
      status = pdmoDeletePartOccurrence(lw_status, spr_mod_env, &part_id);
      _pdm_status("pdmoDeletePartOccurrence", status);
      *lw_status = PDM_E_PLACE_PART;
      return(PDM_E_PLACE_PART);
      }
    }
  else
    {
    _pdm_debug("place part by 3 points", 0);
    status = PDUpoint_to_string(dar_origin, origin_str);
    _pdm_status("PDUpoint_to_string", status);
    status = PDUpoint_to_string(dar_x_point, x_point_str);
    _pdm_status("PDUpoint_to_string", status);
    status = PDUpoint_to_string(dar_y_point, y_point_str);
    _pdm_status("PDUpoint_to_string", status);
    status = PDUgenerate_coord_orientation(origin_str, x_point_str, 
                                           y_point_str, src_matrix);
    _pdm_status("PDUget_coord_sys_id", status);
    }
  status = PDUcreate_part_pointer(src_matrix, *spr_mod_env, usageid, 
                                  NULL, &cs_id);
  _pdm_status("PDUcreate_part_pointer", status);
  if (status != PDM_S_SUCCESS)
    {
    /*status = pdmoDeletePartOccurrence(lw_status, spr_mod_env, &part_id);
    _pdm_status("pdmoDeletePartOccurrence", status);*/
    *lw_status = PDM_E_PLACE_PART;
    return(PDM_E_PLACE_PART);
    }
   dp$display(msg = &msg, oids = &cs_id , mode = GRbd);
   sprintf(serial_no, "%d", cs_id.objid);
   status = co$part_put_attr(msg = &msg, mod_env = spr_mod_env, part = spw_part,
                            attr = "serial", value = serial_no, 
                            type = GR_DYNAMIC_ATTR);
    /* add coordinate system to GRpart */
    objects[0].obj_id.objid = cs_id.objid;
    objects[0].obj_id.osnum = spr_mod_env->md_id.osnum;
    objects[0].mod_env = *spr_mod_env;
    own_index[0] = PDU_K_MAXINT;
    status = om$send (msg = message GRowner.GRadd_components(&msg, spr_mod_env,
                                                             &num_objects,
                                                             objects,
                                                             own_index, NULL),
                      /*senderid = spw_part->objid,*/
                      senderid = NULL_OBJID,
                      targetid = spw_part->objid,
                      targetos = spw_part->osnum);

    status = PDMget_catno_partno(cpr_ccatalogname, cpr_citemname, cpr_citemrev, 
                                 &catalog_no,
                                 &item_no);
    _pdm_status("PDMget_catno_partno", status);
 
   if (status != PDM_S_SUCCESS)
     {
     _pdm_debug("SEVERE error: PDMget_catno_partno failed", 0);
     return(status);
     }

   status = PDMrcheck_part_status(cpr_ccatalogname, cpr_citemname, 
                                  cpr_citemrev);
   _pdm_status("PDMrcheck_part_status", status);

   if (status == PDM_I_NEVER_CHECKED_IN)
     {
     PDUmodify_exp(0, assy_path, "attached", "N", spr_mod_env->md_id.osnum);
     PDUmodify_exp(0, assy_path, "loaded", "N", spr_mod_env->md_id.osnum);
     PDUmodify_exp(0, assy_path, "local_flag", "", spr_mod_env->md_id.osnum);
     *lw_status = PDM_S_SUCCESS;
     return(PDM_S_SUCCESS);
     } 
             
   status = PDUverify_part('a');
   _pdm_status("PDUverify_part", status);

   if (status == PDM_S_SUCCESS)
     {
     status = PDUget_parttype(refresh->act_catalog, refresh->act_partid, 
                              refresh->act_revision, &active_parttype);
     _pdm_status("PDUget_parttype (active)", status);
     }
   else
     PDUfill_in_string(&active_parttype, "G");

   PDUmessage(PDS_M_LOADING_GRAPHICS, 's');

   status = pdmoAttachPart(spr_mod_env, spw_part,cpr_ccatalogname,cpr_citemname,
                           cpr_citemrev, cofilename, cpr_viewname, incstr,
                           catalog_no,item_no, child_no, active_parttype, 
                           attach);
   _pdm_status("pdmoAttachPart", status);

   if (status != PDM_S_SUCCESS)
     {
     co$part_put_attr(msg = &msg, mod_env = spr_mod_env,
                      part = &part_id, attr = "attach_flag",
                      value = "-1", type = GR_DYNAMIC_ATTR);
     *lw_status = status;
     return(status);
     }
  if ((child_no) && (strcmp(child_no, "") != 0))
    free(child_no);
  if ((explode) && (strcmp(explode, "") != 0))
    free(explode);
  if ((attach) && (strcmp(attach, "") != 0))
    free(attach);
  if ((incstr) && (strcmp(incstr, "") != 0))
    free(incstr);
  if ((incbom) && (strcmp(incbom, "") != 0))
    free(incbom);
  if ((tmpstr) && (strcmp(tmpstr, "") != 0))
    free(tmpstr);
  if ((tmpbom) && (strcmp(tmpbom, "") != 0))
    free(tmpbom);
  if ((tmpexp) && (strcmp(tmpexp, "") != 0))
    free(tmpexp);
  if ((p_parttype) && (strcmp(p_parttype, "") != 0))
    free(p_parttype);
  if ((active_parttype) && (strcmp(active_parttype, "") != 0))
    free(active_parttype);
  if ((cofilename) && (strcmp(cofilename, "") != 0))
    free(cofilename);
  if ((catalog_no) && (strcmp(catalog_no, "") != 0))
    free(catalog_no);
  if ((item_no) && (strcmp(item_no, "") != 0))
    free(item_no);
  if ((description) && (strcmp(description, "") != 0))
    free(description);
  if ((viewname) && (strcmp(viewname, "") != 0))
    free(viewname);
  if ((tmp_explode) && (strcmp(tmp_explode, "") != 0))
    free(tmp_explode);
  if ((alttag) && (strcmp(alttag, "") != 0))
    free(alttag);
  if (filename_bufr)
    MEMclose(&filename_bufr);
 if ((save_attach) && (strcmp(save_attach, "N") == 0))
   PDUmodify_exp(0, assy_path, "attached", "N", spr_mod_env->md_id.osnum);
 if ((save_attach) && (strcmp(save_attach, "") != 0))
   free(save_attach);

 if (asm_bufr)
   {
   MEMclose(&asm_bufr);
   asm_bufr = NULL;
   }

   status = PDUload_assy_struct_buffer(spr_mod_env, &asm_bufr, -1, assy_path);
   _pdm_status("PDUload_assy_struct_buffer", status);

   status = PDUprocess_assembly_display(spr_mod_env, asm_bufr, FALSE, TRUE,
                                        TRUE);
   _pdm_status("PDUprocess_assembly_display", status);

  *lw_status = status;
  }
  else
    {
    _pdm_debug("Parametric part placement", 0);
    if ((ir_dyn_count > 0) && ((cpr_dyn_names == NULL) || 
        (cpr_dyn_values == NULL)))
      {
      *lw_status = PDM_E_DYN_TRIP;
      return(PDM_E_DYN_TRIP);
      }
   else if ((ir_dyn_count <= 0) && ((cpr_dyn_names) || (cpr_dyn_values)))
     {
      *lw_status = PDM_E_DYN_TRIP;
      return(PDM_E_DYN_TRIP);
      }

    _pdm_debug("before checking dynloc attributes", 0);
    if ((ir_dynloc_count > 0) && ((cpr_dynloc_names == NULL) || 
        (spr_dynloc_id == NULL)))
      {
      *lw_status = PDM_E_DYN_LOC_TRIP;
      return(PDM_E_DYN_LOC_TRIP);
      }
   else if ((ir_dynloc_count <= 0) && ((cpr_dynloc_names) || (spr_dynloc_id)))
     {
      *lw_status = PDM_E_DYN_LOC_TRIP;
      return(PDM_E_DYN_LOC_TRIP);
      }
   if ((cpr_dynloc_names == NULL) && (spr_dynloc_id == NULL))
     {
     _pdm_debug("positionless part placement");
   /* Get child number seed from object space */
   di$give_pathname(
                    osnum = spr_mod_env->md_id.osnum,
                    pathname = child_dir
                   );

   strcat(child_dir,":");
   strcat(child_dir,"PDU");
   strcat(child_dir,":");
   strcat(child_dir,"child_no");
  
   /* Check to see if child number seed exists */
   status = di$ls(regexp = child_dir, ptr = &count);

   if (count == 0)
   /* Need to create a child number seed */
      {
       _pdm_debug("child_no seed will be created", 0);
       strcat(child_dir, ":");
       strcat(child_dir, "1");
       strcat(child_dir, ":");
       status = di$mkpath(pathname = child_dir);
       PDUfill_in_string(&child_no, "1");
      }

   else
     {
      /* Generate a child number */
      status = PDUgenerate_child_no(
                                    &child_no,
                                    spr_mod_env->md_id.osnum
                                   );
      _pdm_debug("Child_no = <%s>", child_no);
     }

     status = PDUcreate_GRpart(spr_mod_env, cpr_ccatalogname, cpr_citemname,
                               cpr_citemrev,child_no, quantity, alttag, usageid,
                               "","", p_parttype, incbom, incstr,explode,
                               attach, &part_id);
     _pdm_status("PDUcreate_GRpart", status);
     if (status != PDM_S_SUCCESS)
       return(PDM_E_PLACE_PART);
     status = PDUincrement_child_no(spr_mod_env->md_id.osnum);
     _pdm_status("PDUincrement_child_no", status);
    
/*
  _pdm_debug("PDU_tagno = <%s>", PDU_tagno);
  _pdm_debug("usageid = <%s>", usageid);
  _pdm_debug("quantity = <%s>", quantity);
  _pdm_debug("alttag = <%s>", alttag);
  _pdm_debug("incbom = <%s>", incbom);
  _pdm_debug("incstr = <%s>", incstr);
  _pdm_debug("explode = <%s>", explode);
  _pdm_debug("PDU_attach = <%d>", (char *)PDU_attach);
  _pdm_debug("child_no = <%d>", (char *)child_no);

  _pdm_debug("checking for revise assembly", 0);
  if (forms.rev_assy_form_id)
    {
    FIf_is_displayed(forms.rev_assy_form_id, &displayed);
    if ((displayed) && (current_rev_assy))
      {
      _pdm_debug("saving placement attributes", 0);
      _pdm_debug("setting childno", 0);
      current_rev_assy->p_childno = atoi(child_no);
      PDUfill_in_string(&(current_rev_assy)->p_tagno, PDU_tagno);
      _pdm_debug("writing to new_usageid", 0);
      PDUfill_in_string(&(current_rev_assy)->new_usageid, usageid);
      _pdm_debug("writing to p_quantity", 0);
      PDUfill_in_string(&(current_rev_assy)->p_quantity, quantity);
      _pdm_debug("writing to p_alttagno", 0);
      PDUfill_in_string(&(current_rev_assy)->p_alttagno, alttag);
      _pdm_debug("writing to p_incbom", 0);
      PDUfill_in_string(&(current_rev_assy)->p_incbom, incbom);
      _pdm_debug("writing to p_incstr", 0);
      PDUfill_in_string(&(current_rev_assy)->p_incstr, incstr);
      _pdm_debug("writing to p_explode", 0);
      PDUfill_in_string(&(current_rev_assy)->p_explode, explode);
      _pdm_debug("writing to p_attach", 0);
      if (PDU_attach)
        PDUfill_in_string(&(current_rev_assy)->p_attached, "Y");
      else
        PDUfill_in_string(&(current_rev_assy)->p_attached, "N");
      }
    }
*/

     /* extract child_no from part */
     _pdm_debug("calling co$part_get_attr", 0);
     co$part_get_attr(msg = &msg, mod_env = spr_mod_env, part = &part_id, 
                      attr = "child_no", value = attr_value, type = &type);
     PDUunquote(attr_value);
     _pdm_debug("attr_value = <%s>", attr_value);
     PDUfill_in_string(&child_no, attr_value);

     /* edit place part for all attributes */
      if ((ir_dyn_count > 0) && (cpr_dyn_names != NULL) && (cpr_dyn_values !=
           NULL))
        {
        _pdm_debug("ir_dyn_count = <%d>", ir_dyn_count);
        for ( i = 0; i < ir_dyn_count; i++)
          {
          status = co$part_get_attr(msg = &msg, mod_env = spr_mod_env,
                                    part = &part_id, attr = cpr_dyn_names[i],
                                    value = attr_value, type = &type);
          if (!(status & msg & 1))
            {
            _pdm_debug("attribute %s does not exist in GRpart", 
                        cpr_dyn_names[i]);
            continue;
            }
          status = co$part_put_attr(msg = &msg, mod_env = spr_mod_env,
                                    part = &part_id, attr = cpr_dyn_names[i],
                                    value = cpr_dyn_values[i],
                                    type = type);
          if (!(status & msg & 1))
            _pdm_debug("Edit of attribute %s failed", cpr_dyn_names[i]);
          else
            _pdm_debug("Edit of attribute %s successful", cpr_dyn_names[i]);
          }
        }
      status = PDMget_assembly_structure(cpr_ccatalogname, cpr_citemname, 
                                         cpr_citemrev, MAX_LEVEL, &asm_bufr);
      _pdm_status("PDMget_assembly_structure", status);
      
      if (asm_bufr == NULL)
        return(PDM_E_RETRIEVE_ASSEMBLY);
      else if (asm_bufr->rows == 0)
        return(PDM_E_RETRIEVE_ASSEMBLY);

      /* Extract catalogno from asm_bufr */
      status = MEMbuild_array(asm_bufr);
      _pdm_status("MEMbuild_array", status);
      if (status != MEM_S_SUCCESS)
        return(PDM_E_BUILD_ARRAY);
      asm_data = (char **)asm_bufr->data_ptr;
      PDUget_buffer_col(asm_bufr, "n_ccatalogno", &catno_col);
      PDUfill_in_string(&catalog_no, asm_data[catno_col]);

      /* Extract itemno from asm_bufr */
      PDUget_buffer_col(asm_bufr, "n_citemno", &itemno_col);
      PDUfill_in_string(&item_no, asm_data[itemno_col]);
      PDUfill_in_string(&cofilename, "");

      if (asm_bufr->rows > 1)
        {
        _pdm_debug("Add part's assembly structure to the assembly structure",
                    0);
        status = PDUadd_assy_struct_from_buffer(
                                                spr_mod_env,
                                                child_no,
                                                cofilename,
                                                asm_bufr,
                                                1
                                               );
       }

     _pdm_status("PDUadd_assy_struct_from_buffers", status);

     /* set spw_part to part_id */
     if (spw_part == NULL)
       spw_part = (struct GRid *)malloc(sizeof(struct GRid));
     spw_part->objid = part_id.objid;
     spw_part->osnum = part_id.osnum;
     return(PDM_S_SUCCESS);
     }
   _pdm_debug("Before closing buffers", 0);
   if (PDU_dyn_attr_bufr)
     {
     MEMclose(&PDU_dyn_attr_bufr);
     PDU_dyn_attr_bufr = NULL;
     }
   if (PDU_dyn_data_bufr)
     {
     MEMclose(&PDU_dyn_data_bufr);
     PDU_dyn_data_bufr = NULL;
     }
   if (PDU_dyn_value_bufr)
     {
     MEMclose(&PDU_dyn_value_bufr);
     PDU_dyn_value_bufr = NULL;
     }

   _pdm_debug("Before PDMquery_dynamic_attributes", 0);
   status = PDMquery_dynamic_attrs(cpr_ccatalogname, cpr_citemname, 
                                   cpr_citemrev, &PDU_dyn_attr_bufr,  
                                   &PDU_dyn_data_bufr, &PDU_dyn_value_bufr,
                                   &tmp_explode);
   _pdm_status("PDMquery_dynamic_attrs", status);
   
   if ((PDU_dyn_attr_bufr) && (PDU_dyn_data_bufr))
     {
     for (i = 0; i < ir_dyn_count; i++)
       {
       status = MEMbuild_array(PDU_dyn_attr_bufr);
       _pdm_status("MEMbuild_array", status);
       if (status != MEM_S_SUCCESS)
         {
         *lw_status = PDM_E_BUILD_BUFFER_ARRAY;
         return(PDM_E_BUILD_BUFFER_ARRAY);
         }
       row = PDUfind_attr_in_buffer(PDU_dyn_attr_bufr, cpr_dyn_names[i]);
       if (row == -1)
         {
         *lw_status = PDM_I_ATTR_NOT_FOUND;
         return(PDM_I_ATTR_NOT_FOUND);
         }
       status = MEMbuild_array(PDU_dyn_data_bufr);
       _pdm_status("MEMbuild_array", status);
       if (status != MEM_S_SUCCESS)
         {
         *lw_status = PDM_E_BUILD_BUFFER_ARRAY;
         return(PDM_E_BUILD_BUFFER_ARRAY);
         }
       status = MEMwrite_data(PDU_dyn_data_bufr, cpr_dyn_values[i], (row + 1), 
                              (PDU_DYN_DEFAULT_VAL_COL + 1));
       _pdm_status("MEMwrite_data", status);
       if (status != MEM_S_SUCCESS)
         {
         *lw_status = PDM_E_WRITE_BUFFER;
         return(PDM_E_WRITE_BUFFER);
         }
       }
     }
   PDUfill_in_string(&refresh->rev_catalog, cpr_ccatalogname);
   PDUfill_in_string(&refresh->rev_partid, cpr_citemname);
   PDUfill_in_string(&refresh->rev_revision, cpr_citemrev);
   PDUfill_in_string(&tmpstr, incstr);
   PDUfill_in_string(&tmpbom, incbom);
   PDUfill_in_string(&tmpexp, explode);
   PDUfill_in_string(&PDU_incl_ASM, incstr);
   PDUfill_in_string(&PDU_incl_BOM, incbom);
   PDUfill_in_string(&PDU_explode_BOM, explode);
   status = LoadLib_N_PrepareAttribs(spr_mod_env, NULL, &rg_grid, &hdr, 
                                        &numcoll);
   _pdm_status("LoadLib_N_PrepareAttribs", status);
  
   if (!status)
     {
     *lw_status = PDM_E_PLACE_PARAMETRIC_PART;
     return(PDM_E_PLACE_PARAMETRIC_PART);
     }
  
   status = BreakLocAndNonLocDYn(numcoll,&locatables, &prompts, &numloc);
   _pdm_status("BreakLocAndNonLocDYn", status);
 
   if (!status)
     {
     *lw_status = PDM_E_PLACE_PARAMETRIC_PART;
     return(PDM_E_PLACE_PARAMETRIC_PART);
      }

   if ((PALdyn_bufr) && (PALdyn_bufr->rows > 0))
     {
     status = PDUmerge_dynamic_attribute_bufrs(PALdyn_bufr);
     _pdm_status("PDUmerge_dynamic_attribute_bufrs", status);

     if (status != PDM_S_SUCCESS)
       return(status);
     }

  if ((filterbuf) && (filterbuf->rows > 0))
    {
    status = PDUfilter_dynamic_attribute_bufrs(filterbuf);
    _pdm_status("PDUfilter_dynamic_attribute_bufrs", status);
    }
 
  status = PDUgenerate_tag_no(&PDU_tagno, 0);
  _pdm_status("PDUgenerate_tag_no", status);

  status = PDUadd_static_dyn_attributes(&PDU_dyn_attr_bufr, &PDU_dyn_data_bufr,
                                        usageid, quantity, PDU_tagno, alttag);
  _pdm_status("PDUadd_static_dyn_attributes", status);

  if (filterbuf)
    {
    MEMclose(&filterbuf);
    filterbuf = NULL;
    }
   
  if (grid_list == NULL)
    {
    /* allocate grid_list */
    grid_list = (struct GRid *)malloc(sizeof(struct GRid) * (numloc + numcoll));
    }

  for (i = 0; i < ir_dynloc_count; i ++)
    {
    row = PDUfind_dynloc_name(cpr_dynloc_names[i], prompts, numloc);
    _pdm_debug("row found = <%d>", row);
    if (row == -1)
      {
      *lw_status = PDM_E_DYNLOC_NAME_NOT_FOUND;
      return(PDM_E_DYNLOC_NAME_NOT_FOUND);
      }
    grid_list[row] = spr_dynloc_id[i];
    _pdm_debug("grid_list: %d", grid_list[row].objid);
    }
  for ( i = 0; i < numcoll; i ++)
    {
    grid_list[(numloc + i)] = rg_grid[i];
    }
   
  numtemp = numloc + numcoll;
  for ( i = 0; i < numtemp; i ++)
    {
    _pdm_debug("grid_list: %d", grid_list[i].objid);
    }
  status = SetDynTemp(rg_grid, numcoll, 1,spr_mod_env);
  _pdm_status("SetDynTemp", status);

  if (!status)
    {
    *lw_status = PDM_E_PLACE_PARAMETRIC_PART;
    return(PDM_E_PLACE_PARAMETRIC_PART);
    }

  PDUfill_in_string(&PDU_usage_id, usageid);
  status = Instance_Macro(NULL,spr_mod_env, &hdr, &rg_grid[0], numtemp,numcoll);
  _pdm_status("Instance_Macro", status);

  PDUfill_in_string(&PDU_incl_ASM, tmpstr);
  PDUfill_in_string(&PDU_incl_BOM, tmpbom);
  PDUfill_in_string(&PDU_explode_BOM, tmpexp);
  PDUfill_in_string(&PDU_usage_id, NULL);
  if (!status) 
    {
    *lw_status = PDM_E_PLACE_PARAMETRIC_PART;
    return(PDM_E_PLACE_PARAMETRIC_PART);
    }
  PDUupdate_parametric_tag(spr_mod_env->md_id.osnum, PDU_tagno);
  PDUincrement_child_no(spr_mod_env->md_id.osnum);
  } /* end parametric part placement */

  if (asm_bufr)
    MEMclose(&asm_bufr);
  if (PDU_dyn_attr_bufr)
    {
    MEMclose(&PDU_dyn_attr_bufr);
    PDU_dyn_attr_bufr = NULL;
    }
  if (PDU_dyn_data_bufr)
    {
    MEMclose(&PDU_dyn_data_bufr);
    PDU_dyn_data_bufr = NULL;
    }
  if (PDU_dyn_value_bufr)
    {
    MEMclose(&PDU_dyn_value_bufr);
    PDU_dyn_value_bufr = NULL;
    }
  *lw_status = PDM_S_SUCCESS;
  return(PDM_S_SUCCESS);
  }


/* This function does an invisible, graphical part deletion and placement 
   for revise assembly. */

IGRint PDUreplace_part_for_revise_assembly(
				catalog,
				partid,
				revision,
				parttype,
                                file_list,
                                file_count,
				new_catalog,
				new_partid,
				new_revision,
				new_parttype,
				new_file_list,
				new_file_count,
				p_attached,
				p_quantity,
				p_usageid,
				p_alttagno,
				p_incbom,
				p_incstr,
				p_explode,
				old_usageid,
				new_part)
  char      *catalog;
  char      *partid;
  char      *revision;
  char      *parttype;
  char      *file_list[10];
  int        file_count;
  char      *new_catalog;
  char      *new_partid;
  char      *new_revision;
  char      *new_parttype;
  char      *new_file_list[10];
  int        new_file_count;
  char      *p_attached;
  char      *p_quantity;
  char      *p_usageid;
  char      *p_alttagno;
  char      *p_incbom;
  char      *p_incstr;
  char      *p_explode;
  char      *old_usageid;
  char      *new_part;
{
  IGRint    status = PDM_S_SUCCESS;
  IGRint    status1 = PDM_S_SUCCESS;
  IGRint    part_status = PDM_S_SUCCESS;
  IGRint    max_comp_count = 0;
  IGRint    component_count = 0;
  IGRint    num_objects = 1;
  IGRint    index = 0;
  IGRint    i = 1;
  IGRint    msg2;
  IGRint    file_type;
  IGRint    save_flag = 1;
  IGRint    design_count;
  IGRint    char_index = 0;
  IGRlong   msg;
  IGRlong   sts;
  IGRlong   NumberOfBytes, BytesReceived;
  IGRchar   class_msg[80];
  IGRchar   *filename = NULL;
  IGRchar   *plc_file = NULL;
  IGRchar   *edit_display = NULL;
  IGRchar   *new_filename = NULL;
  IGRchar   *title = NULL;
  IGRchar   *line = NULL;
  IGRchar   mount_name[40];
  IGRchar   mach_type;
  IGRchar   design_list[10][15];
  IGRshort  major;
  IGRshort  minor;
  IGRshort  found = FALSE;
  IGRshort  close_mod = FALSE;
  GRobjid   osid = NULL_OBJID;
  OMuword   osnum;
  GRobjid   objid;
  IGRdouble quantity;
  extern    IGRshort   PDU_attach;
  extern    struct PDUpart           *part;
  struct    GRid      *component_ids = NULL;
  struct    GRid      part_id;
  struct    GRid      src_coorid;
  struct    GRmd_env  mod_env;
  struct    GRobj_env objects[1];
  extern void PDUdelete_active_part_form();

  _pdm_debug("in the function PDUreplace_part_for_revise_assembly", 0);

  _pdm_debug("placing part:", 0);
  _pdm_debug("catalog = <%s>", new_catalog);
  _pdm_debug("partid = <%s>", new_partid);
  _pdm_debug("revision = <%s>", new_revision);

  _pdm_debug("parent part:", 0);
  _pdm_debug("catalog = <%s>", catalog);
  _pdm_debug("partid = <%s>", partid);
  _pdm_debug("revision = <%s>", revision);

  _pdm_debug("p_attached = <%s>", p_attached);
  _pdm_debug("p_quantity = <%s>", p_quantity);
  _pdm_debug("p_usageid = <%s>", p_usageid);
  _pdm_debug("old_usageid = <%s>", old_usageid);
  _pdm_debug("p_alttagno = <%s>", p_alttagno);
  _pdm_debug("p_incbom = <%s>", p_incbom);
  _pdm_debug("p_incstr = <%s>", p_incstr);
  _pdm_debug("p_explode = <%s>", p_explode);
  _pdm_debug("file_count = <%d>", (char *)file_count);
  _pdm_debug("new_file_count = <%d>", (char *)new_file_count);

  if (strcmp(new_part, "Y") == 0)
    _pdm_debug("part placement was just added to database", 0);

/* find the design file for the new part */
if ((strcmp(new_parttype, "P") != 0) && (strcmp(new_parttype, "p") != 0))
{
if (PDU_attach)
  {
  _pdm_debug("part will be attached", 0);

  if (new_file_count == 0)
    {
    _pdm_debug("part does not have any files", 0);
    PDUfill_in_string(&plc_file, NULL_STRING);
    PDU_attach = 0;
    PDUfill_in_string(&p_attached, "N");
    }

  if (PDU_attach)
    {
    _pdm_debug("check the file status of the part", 0);
    part_status = PDMrcheck_part_status(current_rev_assy->new_catalog,
                                   current_rev_assy->new_partid,
                                   current_rev_assy->new_revision);
    _pdm_status("PDMrcheck_part_status", part_status);
    if (part_status == PDM_I_NEVER_CHECKED_IN)
      {
      _pdm_debug("part has never been checked in", 0);
      found = FALSE;
      _pdm_debug("check to see if files have been created", 0);
      for (i = 0; i < new_file_count; ++i)
         {
         status = PDUverify_file(new_file_list[i]);
         _pdm_status("PDUverify_file", 0);
         if (status == PDM_S_SUCCESS)
           {
           found = TRUE;
           break;
           }
         }
      if (new_file_count == 0)
        found = TRUE;
      }
    else
      {
      _pdm_debug("part has been checked in before", 0);
      found = TRUE;
      }
  
    if (!found)
      {
      _pdm_debug("part's files have not been created", 0);
      _pdm_debug("resetting PDU_attach to FALSE", 0);
      PDU_attach = FALSE;
      }

    if ((new_file_count > 1) && (part_status == PDM_I_NEVER_CHECKED_IN))
      {
      /* find the design file */
      for (i = 0; i < new_file_count; ++i)
       {
       if (!(new_file_list[i]))
         continue;
       if (!strlen(new_file_list[i]))
         continue;

       _pdm_debug("number of files = <%d>", (char *)new_file_count);
       _pdm_debug("checking file <%s>", new_file_list[i]);
       PDUfill_in_string(&plc_file, new_file_list[i]);
  
       status = ex$is_om_file(
                              filename = plc_file,
                              p_major = &major,
                              p_minor = &minor,
                              p_mach_type = &mach_type,
                              p_file_type = &file_type
                             );
       _pdm_status("ex$is_om_file", status);
  
       if (status)
         {
         _pdm_debug("file <%s> is an OM file", plc_file);
         }
       else
         {
         _pdm_debug("file <%s> is NOT an OM file", plc_file);
         status = PDM_S_SUCCESS;
         continue;
         }
  
       _pdm_debug("Construct file mount name", 0);
       strcpy(mount_name, ":");
       strcat(mount_name, plc_file);
  
       _pdm_debug("mount_name = <%s>", mount_name);
  
       _pdm_debug("Get osnum of invis space", 0);
       status = ex$retrieve_module (
                                    filename = plc_file,
                                    file_no = &index,
                                    ftype = EX_invisible,
                                    flag = EX_read_write,
                                    fstat = EX_default,
                                    type = EX_ACTINV,
                                    mount_name = mount_name,
                                    msg = &msg2
                                   );
       _pdm_status ("ex$retrieve_module", status);

       if (!status)
          {
           _pdm_debug("ex$retrieve_module failed on <%s>", plc_file);
           return(PDM_E_OPEN_FILE);
          }
  
       _pdm_debug("opening object space", 0);
       status = ex$get_invis_info_by_index (
                                            index = index,
                                            mod_osnum = &osnum,
                                            mod_id = &objid,
                                            filed_id = &osid
                                           );
       _pdm_status ("ex$get_invis_info_by_index", status);

       if (!status)
          {
           _pdm_debug("ex$get_invis_info_by_index failed on <%s>", plc_file);
           return(PDM_E_OPEN_FILE);
          }
  
       NumberOfBytes = sizeof(mod_env);
       status = gr$get_module_env(
                               msg = &msg,
                               sizbuf = &NumberOfBytes,
                               buffer = &mod_env,
                               nret = &BytesReceived
                             );
  
       mod_env.md_id.osnum = osnum;
       mod_env.md_id.objid = objid;
  
       if (!(PDUis_PDU_design_file(&mod_env)))
         {
         _pdm_debug("file <%s> is not a design file", plc_file);
         status = PDM_S_SUCCESS;

         save_flag = 0;
         _pdm_debug("Close and do not save object space", 0);
         status = ex$close_module (
                                    index = index,
                                    flag = save_flag | EX_ACTINV,
                                    ftype = EX_invisible
                                   );
         _pdm_status ("ex$close_module", status);
       
         continue;
         }
       else
         {
         found = TRUE;

         save_flag = 0;
         _pdm_debug("Close and do not save object space", 0);
         status = ex$close_module (
                                    index = index,
                                    flag = save_flag | EX_ACTINV,
                                    ftype = EX_invisible
                                   );
         _pdm_status ("ex$close_module", status);
       
         break;
         }

       }
      if (!found)
        {
        _pdm_debug("could not find design file for part to be attached", 0);
        _pdm_debug("resetting PDU_attach to FALSE", 0);
        PDU_attach = FALSE;
        }
      }
    else if (new_file_count == 1)
      {
      PDUfill_in_string(&plc_file, new_file_list[0]);
      _pdm_debug("filename is <%s>", plc_file);
      }
    }
  }
else
  {
  _pdm_debug("part will not be attached", 0);
  PDUfill_in_string(&plc_file, NULL_STRING);
  }
}

  /* find the design file for the parent part */
  if (file_count == 0)
    {
    _pdm_debug("error finding design file for parent part", 0);
    return(PDM_E_DESIGN_FILE_NOT_FOUND);
    }

  /* initialize file list */
  for (index = 0; index < 10; ++index)
     design_list[index][0] = '\0';

  found = FALSE;
  design_count = 0;
  for (i = 0; i < file_count; ++i)
     {
     _pdm_debug("number of files = <%d>", (char *)file_count);
     _pdm_debug("checking file <%s>", file_list[i]);
     PDUfill_in_string(&filename, file_list[i]);

     status = ex$is_om_file(
                            filename = filename,
                            p_major = &major,
                            p_minor = &minor,
                            p_mach_type = &mach_type,
                            p_file_type = &file_type
                           );
     _pdm_status("ex$is_om_file", status);

     if (status)
       {
       _pdm_debug("file <%s> is an OM file", filename);
       found = TRUE;
       _pdm_debug("adding file <%s> to list of design files", filename);
       strcpy(design_list[design_count], filename);
       ++design_count;
       }
     else
       {
       _pdm_debug("file <%s> is NOT an OM file", filename);
       status = PDM_S_SUCCESS;
       continue;
       }
     }

  if (!found)
    {
    _pdm_debug("design file not found; must do nongraphic placement", 0);
    _pdm_debug("exiting PDUreplace_part_for_revise_assembly", 0);
    PDUcleanup_revise_assembly();
    return(PDM_E_DESIGN_FILE_NOT_FOUND);
    }

  _pdm_debug("parent part has <%d> design files", (char *)design_count);

  if (design_count > 10)
    {
    _pdm_debug("Error: number of files exceeds size of list", 0);
    return(PDM_E_NUM_FILES_EXCEEDS_LIST);
    }

  if (design_count > 1)
    {
    _pdm_debug("create buffer to display list of files", 0);
    if (PDU_ret_bufr)
      {
      MEMclose(&PDU_ret_bufr);
      PDU_ret_bufr = NULL;
      }

    MEMopen(&PDU_ret_bufr, 512);
    MEMwrite_format(PDU_ret_bufr, "n_cofilename", "char(15)");

    line = (char*) malloc (PDU_ret_bufr->row_size);
    memset (line, NULL, PDU_ret_bufr->row_size);

    char_index = 0;

    for (i = 0; i < design_count; ++i)
       {
       if ((design_list[i]) && (strlen(design_list[i])))
         PDUadd_buffer_string(line, &char_index, design_list[i]);
       else
         line[char_index++] = '\1';

       _pdm_debug("line = <%s>", line);

       status = MEMwrite(PDU_ret_bufr, line);
       _pdm_status("MEMwrite", status);
       if (status != MEM_S_SUCCESS)
         return(PDM_E_WRITE_BUFFER);
       status = PDM_S_SUCCESS;

       char_index = 0;
       memset (line, NULL, PDU_ret_bufr->row_size);
       }

    if (PDMdebug_on)
      MEMprint_buffer("PDU_ret_bufr", PDU_ret_bufr, PDU_DEBUG_FILE);

    _pdm_debug("display list of files", 0);
    status = PDUdisplay_checkin_files();
    _pdm_status("PDUdisplay_checkin_files", status);

    status = WaitForEvent();
    _pdm_status("WaitForEvent", status);

    if (!status)
      {
      _pdm_debug("file list form was cancelled", 0);
      return(PDM_E_CMD_CANCELLED);
      }

    PDUfill_in_string(&filename, PDU_checkin_file);
    }
  else if (design_count == 1)
    PDUfill_in_string(&filename, design_list[0]);

  _pdm_debug("design file is <%s>", filename);

  _pdm_debug("open OS for design file <%s>", filename);
  _pdm_debug("Construct file mount name", 0);
  strcpy(mount_name, ":");
  strcat(mount_name, filename);

  _pdm_debug("mount_name = <%s>", mount_name);

  _pdm_debug("Get osnum of invis space", 0);
  status = ex$retrieve_module (
                               filename = filename,
                               file_no = &index,
                               ftype = EX_invisible,
                               flag = EX_read_write,
                               fstat = EX_default,
                               type = EX_ACTINV,
                               mount_name = mount_name,
                               msg = &msg2
                              );
  _pdm_status ("ex$retrieve_module", status);

  if (!status)
     {
      _pdm_debug("ex$retrieve_module failed on <%s>", filename);
      PDUcleanup_revise_assembly();
      return(PDM_E_OPEN_FILE);
     }

  _pdm_debug("opening object space", 0);
  status = ex$get_invis_info_by_index (
                                       index = index,
                                       mod_osnum = &osnum,
                                       mod_id = &objid,
                                       filed_id = &osid
                                      );
  _pdm_status ("ex$get_invis_info_by_index", status);

  if (!status)
     {
      _pdm_debug("ex$get_invis_info_by_index failed on <%s>", filename);
      PDUcleanup_revise_assembly();
      return(PDM_E_OPEN_FILE);
     }

  close_mod = TRUE;

  NumberOfBytes = sizeof(mod_env);
  status = gr$get_module_env(
                          msg = &msg,
                          sizbuf = &NumberOfBytes,
                          buffer = &mod_env,
                          nret = &BytesReceived
                        );

  mod_env.md_id.osnum = osnum;
  mod_env.md_id.objid = objid;

  _pdm_debug("query for dynamic attrs", 0);
  status = PDUget_dynamic_data_for_rev_assy(mod_env, new_parttype);
  _pdm_status("PDUget_dynamic_data_for_rev_assy", status);
/* this function loads current_rev_assy with dyn_attr_count, names & values */
  if (status != PDM_S_SUCCESS)
    {
    PDUcleanup_revise_assembly();
    return(status);
    }

  _pdm_debug("resetting values after dyn attr", 0);
  PDUfill_in_string(&p_usageid, current_rev_assy->new_usageid);
  PDUfill_in_string(&p_quantity, current_rev_assy->p_quantity);
  PDUfill_in_string(&p_alttagno, current_rev_assy->p_alttagno);

  PDUmessage(PDM_E_CLEAR_FIELD, 's');

  PDUdelete_active_part_form();

  /* display active part form */
  title = (char *)PDUtranslate_message(PDM_I_PLACING_PART);
  PDUactive_part_form(new_catalog, new_partid, new_revision, "", title);

  /* get objid of part */
  _pdm_debug("calling pdmoGetPartidGivenUsageid", 0);
  _pdm_debug("usageid = <%s>", old_usageid);
  status = pdmoGetPartidGivenUsageid(old_usageid, &mod_env, &part_id);
  _pdm_status("pdmoGetPartidGivenUsageid", status);
  if (status != PDM_S_SUCCESS)
    {
    _pdm_debug("Close and do not save object space", 0);
    save_flag = 0;
    status1 = ex$close_module (
                               index = index,
                               flag = save_flag | EX_ACTINV,
                               ftype = EX_invisible
                              );
    _pdm_status ("ex$close_module", status1);
    PDUcleanup_revise_assembly();
    return(status);
    }

  _pdm_debug("calling GRget_number_components", 0);
  om$send(msg = message GRowner.GRget_number_components(&sts, &max_comp_count),
              senderid = NULL_OBJID,
              targetid = part_id.objid,
              targetos = part_id.osnum);
  _pdm_debug("%d components were found", max_comp_count);
  component_ids = (struct GRid * )malloc(sizeof (struct GRid) *
                   max_comp_count);
  om$send(msg = message GRowner.GRget_components(&sts, &mod_env,
                                                 component_ids,
                                                 max_comp_count,
                                                 &component_count, 0,
                                                 max_comp_count - 1),
          senderid = NULL_OBJID,
          targetid = part_id.objid,
          targetos = part_id.osnum);
   _pdm_debug("After getting components", 0);

  _pdm_debug("component_count = %d", (char *)component_count);
  found = FALSE;
  if (component_count > 0)
    {
    for ( i = 0; i < component_count; i = i + 1)
      {
      sts = om$get_classname(objid = component_ids[i].objid,
                             osnum = component_ids[i].osnum,
                             classname = class_msg);
      _pdm_debug("class is %s", class_msg);
      if (strcmp(class_msg, "GRgencs") == 0)
        {
        _pdm_debug("CS found", 0);
        objects[0].mod_env = mod_env;
        objects[0].obj_id.objid = component_ids[i].objid;
        objects[0].obj_id.osnum = component_ids[i].osnum;
        found = TRUE;
        }
      }
    if (!found)
      _pdm_debug("CS not found", 0);

    /* delete old part's coord sys from GRpart */
    _pdm_debug("calling GRremove_components", 0);
    om$send(msg = message GRowner.GRremove_components(&sts, &mod_env,
                                                     &num_objects,
                                                     objects),
              senderid = NULL_OBJID,
              targetid = part_id.objid,
              targetos = part_id.osnum);

    _pdm_debug("After removing components", 0);
    }

  _pdm_debug("calling pdmoDeletePartOccurrence", 0);
  status = pdmoDeletePartOccurrence(&sts, &mod_env, &part_id);
  _pdm_status("pdmoDeletePartOccurrence", status);
  if (status != PDM_S_SUCCESS)
    {
    save_flag = 0;
    status = ex$close_module (
                               index = index,
                               flag = save_flag | EX_ACTINV,
                               ftype = EX_invisible
                              );
    _pdm_status ("ex$close_module", status);

    status = PDM_E_PLACE_PART;
    PDUcleanup_revise_assembly();
    return(PDM_E_PLACE_PART);
    }

  /* place the new part */
  PDUfill_in_string(&PDU_usage_id, p_usageid);
  PDUfill_in_string(&PDU_explode_BOM, p_explode);
  PDUfill_in_string(&PDU_alt_tagno, p_alttagno);
  PDUfill_in_string(&PDU_incl_ASM, p_incstr);
  PDUfill_in_string(&PDU_incl_BOM, p_incbom);
  PDUfill_in_string(&PDU_quantity, p_quantity);
  sscanf(p_quantity, "%lf", &quantity);

  if (strcmp(p_attached, "Y") == 0)
    PDU_attach = TRUE;
  else
    PDU_attach = FALSE;

  _pdm_debug("PDU_attach = %d", (char *)PDU_attach);
  _pdm_debug("p_attached = <%s>", p_attached);

  if (PDU_edit_display)
    PDUfill_in_string(&edit_display, "Y");
  else
    PDUfill_in_string(&edit_display, "N");

  if (found)
    {
    _pdm_debug("CS found:  setting src_coorid", 0);
    src_coorid.objid = objects[0].obj_id.objid;
    src_coorid.osnum = objects[0].obj_id.osnum;
    }

  if ((strcmp(new_parttype, "P") != 0) && (strcmp(new_parttype, "p") != 0))
    {
    _pdm_debug("calling PDUdisplay_files_and_origins", 0);
    status = PDUdisplay_files_and_origins(new_catalog, new_partid, new_revision,
                                          &new_filename, &part->view);
    _pdm_status("PDUdisplay_files_and_origins", status);
    if (status != PDM_S_SUCCESS)
      {
      _pdm_debug("display files and origins failed", 0);
      }
    }

  PDUfill_in_string(&refresh->act_catalog, catalog);
  PDUfill_in_string(&refresh->act_partid, partid);
  PDUfill_in_string(&refresh->act_revision, revision);

  if (found)
    {
    status = pdmoPlacePart(
              	&msg,
		&mod_env,
		&part_id,
		new_catalog,
		new_partid,
		new_revision,
		new_filename,
		p_usageid,
                part->view,
		quantity,
		p_explode,
		p_attached,
		p_alttagno,
                p_incstr,
                p_incbom,
		current_rev_assy->dyn_attr_count,
		current_rev_assy->dyn_attr_names,
		current_rev_assy->dyn_attr_values,
		0,
		NULL,
		NULL,
		NULL,
		NULL,
		NULL,
		&src_coorid,
		edit_display);
    }
  else
    {
    _pdm_debug("CS was not found:  passing NULL for src_coorid", 0);
    status = pdmoPlacePart(
              	&msg,
		&mod_env,
		&part_id,
		new_catalog,
		new_partid,
		new_revision,
		new_filename,
		p_usageid,
                part->view,
		quantity,
		p_explode,
		p_attached,
		p_alttagno,
                p_incstr,
                p_incbom,
		current_rev_assy->dyn_attr_count,
		current_rev_assy->dyn_attr_names,
		current_rev_assy->dyn_attr_values,
		0,
		NULL,
		NULL,
		NULL,
		NULL,
		NULL,
		NULL,
		edit_display);
    }
  _pdm_status("pdmoPlacePart", status);

  if (status != PDM_S_SUCCESS)
    {
    PDUmessage(status, 's');
    status1 = pdmoDeletePartOccurrence(&msg, &mod_env, &part_id);
    _pdm_status("pdmoDeletePartOccurrence", status1);

    save_flag = 0;
    sts = ex$close_module (
                               index = index,
                               flag = save_flag | EX_ACTINV,
                               ftype = EX_invisible
                              );
    _pdm_status ("ex$close_module", sts);

    PDUcleanup_revise_assembly();
    return(status);
    }

  /* delete the old part's coord sys */

  om$send(msg = message GRgraphics.GRdelete
                                 (
                                  &sts,
                                  &mod_env
                                 ),
         senderid = NULL_OBJID,
         targetid = src_coorid.objid,
         targetos = src_coorid.osnum
        );

  PDUexecute_upon_save_for_rev_assy(&mod_env);

  _pdm_debug("Close and save object space", 0);
  save_flag = 1;
  sts = ex$close_module (
                               index = index,
                               flag = save_flag | EX_ACTINV,
                               ftype = EX_invisible
                              );
  _pdm_status ("ex$close_module", sts);

  _pdm_debug("make sure none of the files have been left open", 0);

  for (i = 0; i < design_count; ++i)
     {
     _pdm_debug("checking file <%s>", design_list[i]);
     sts = PDUis_file_open(design_list[i]);
     _pdm_status("PDUis_file_open", sts);

     if (sts)
       {
       _pdm_debug("file <%s> was left open", design_list[i]);
       _pdm_debug("Construct file mount name", 0);
       strcpy(mount_name, ":");
       strcat(mount_name, design_list[i]);
     
       _pdm_debug("mount_name = <%s>", mount_name);
     
       _pdm_debug("Get osnum of invis space", 0);
       sts = ex$retrieve_module (
                                 filename = design_list[i],
                                 file_no = &index,
                                 ftype = EX_invisible,
                                 flag = EX_read_write,
                                 fstat = EX_default,
                                 type = EX_ACTINV,
                                 mount_name = mount_name,
                                 msg = &msg2
                                );
       _pdm_status ("ex$retrieve_module", sts);
       if (!sts)
         {
         _pdm_debug("Close and save object space", 0);
         save_flag = 1;
         sts = ex$close_module (
                                      index = index,
                                      flag = save_flag | EX_ACTINV,
                                      ftype = EX_invisible
                                );
         _pdm_status ("ex$close_module", sts);
         }
       }
     }

/*
  _pdm_debug("checking file <%s>", plc_file);
  sts = PDUis_file_open(plc_file);
  _pdm_status("PDUis_file_open", sts);

  if (sts)
       {
       _pdm_debug("Construct file mount name", 0);
       strcpy(mount_name, ":");
       strcat(mount_name, plc_file);
     
       _pdm_debug("mount_name = <%s>", mount_name);
     
       _pdm_debug("Get osnum of invis space", 0);
       sts = ex$retrieve_module (
                                 filename = plc_file,
                                 file_no = &index,
                                 ftype = EX_invisible,
                                 flag = EX_read_write,
                                 fstat = EX_default,
                                 type = EX_ACTINV,
                                 mount_name = mount_name,
                                 msg = &msg2
                                );
       _pdm_status ("ex$retrieve_module", sts);
       if (!sts)
         {
         _pdm_debug("Close and do not save object space", 0);
         save_flag = 0;
         sts = ex$close_module (
                               index = index,
                               flag = save_flag | EX_ACTINV,
                               ftype = EX_invisible
                               );
         _pdm_status ("ex$close_module", sts);
         }
       }
*/

  PDUdelete_active_part_form();

  if (PDU_usage_id)
    {
    free(PDU_usage_id);
    PDU_usage_id = NULL;
    }

  _pdm_debug("freeing pointers", 0);
  if (filename) free(filename);
  if (plc_file) free(plc_file);
  if (edit_display) free(edit_display);
  if (new_filename) free(new_filename);
  if (title) free(title);

  return(status);
}

/* This function generates a usageid and queries for dynamic attrs for the 
   part that is being placed. */

IGRint PDUget_dynamic_data_for_rev_assy(mod_env, parttype)
 struct           GRmd_env  mod_env;
 char             *parttype;
{
 IGRlong          msg;
 IGRlong          stat;
 IGRlong          status;
 IGRint           display_flag;
 IGRint           index = 0;
 IGRchar          *p_explode = NULL;
 IGRchar          usageid[DI_PATH_MAX];

 _pdm_debug("in the function PDUget_dynamic_data_for_rev_assy", 0);

 if ((PDU_usage_id) && (strlen(PDU_usage_id)))
   {
   strcpy(usageid, PDU_usage_id);
   PDUfill_in_string(&(current_rev_assy)->new_usageid, usageid);
   }
 else
   {
   /* Default usage id */
   status = PDUapi_default_usageid(&mod_env, 
                                   current_rev_assy->new_catalog,
                                   current_rev_assy->new_partid,
                                   current_rev_assy->new_revision,
                                   usageid);
   _pdm_status("PDUapi_default_usageid", status);
  
   if (status != PDM_S_SUCCESS)
     return(status);
  
   PDUfill_in_string(&PDU_usage_id, usageid);
   PDUfill_in_string(&(current_rev_assy)->new_usageid, usageid);
   }

 /* default tagno */
 status = PDUgenerate_tag_no(&PDU_tagno, mod_env.md_id.osnum);
 _pdm_status("PDUgenerate_tag_no", status);
 _pdm_debug("tag_no = <%s>", PDU_tagno);

 PDUfill_in_string(&(current_rev_assy)->p_tagno, PDU_tagno);

 /* default quantity */
 PDUfill_in_string(&PDU_quantity, "1.000000");

 if (PDU_dyn_attr_bufr)
   {
   MEMclose(&PDU_dyn_attr_bufr);
   PDU_dyn_attr_bufr = NULL;
   }
 if (PDU_dyn_data_bufr)
   {
   MEMclose(&PDU_dyn_data_bufr);
   PDU_dyn_data_bufr = NULL;
   }
 if (PDU_dyn_value_bufr)
   {
   MEMclose(&PDU_dyn_value_bufr);
   PDU_dyn_value_bufr = NULL;
   }

 /* Extract dynamic attributes from PDM if any, and display them on form */
 stat = PDMquery_dynamic_attrs(
                               current_rev_assy->new_catalog,
                               current_rev_assy->new_partid, 
                               current_rev_assy->new_revision,
                               &PDU_dyn_attr_bufr,
                               &PDU_dyn_data_bufr,
                               &PDU_dyn_value_bufr,
                               &p_explode
                              );
 _pdm_status("PDMquery_dynamic_attrs", stat);

 /* Display dynamic attributes form, if necessary */
 if ((PDU_display_dyn_attr) || (strcmp(parttype, "P") == 0) ||
                               (strcmp(parttype, "p") == 0))
    {
    PDU_calling_form = forms.rev_assy_form_id;
    FIf_erase(PDU_calling_form);
    _pdm_debug("Calling PDUdynamic_attr_form", 0);
    stat = PDUdynamic_attr_form();
    _pdm_status("PDUdynamic_attr_form", stat);

    stat = WaitForEvent();
    _pdm_status("WaitForEvent", stat);
    if (!stat)
      {
      _pdm_debug("dynamic attr form was cancelled", 0);
      PDUmessage(PDM_E_CMD_CANCELLED, 's');
      return(PDM_E_CMD_CANCELLED);
      }

    PDUfill_in_string(&(current_rev_assy)->new_usageid, PDU_usage_id);
    PDUfill_in_string(&(current_rev_assy)->p_quantity, PDU_quantity);
    PDUfill_in_string(&(current_rev_assy)->p_alttagno, PDU_alt_tagno);
    }
  else
    {
    display_flag = PDUcheck_display_dynamic_attr(PDU_dyn_attr_bufr, 
                                                 PDU_dyn_data_bufr);
    _pdm_debug("display flag = <%d>", (char *)display_flag);
    if (display_flag)
      {
      PDU_calling_form = forms.rev_assy_form_id;
      FIf_erase(PDU_calling_form);
      _pdm_debug("Calling PDUdynamic_attr_form", 0);
      stat = PDUdynamic_attr_form();
      _pdm_status("PDUdynamic_attr_form", stat);

      stat = WaitForEvent();
      _pdm_status("WaitForEvent", stat);
      if (!stat)
        {
        _pdm_debug("dynamic attr form was cancelled", 0);
        PDUmessage(PDM_E_CMD_CANCELLED, 's');
        return(PDM_E_CMD_CANCELLED);
        }

      PDUfill_in_string(&(current_rev_assy)->new_usageid, PDU_usage_id);
      PDUfill_in_string(&(current_rev_assy)->p_quantity, PDU_quantity);
      PDUfill_in_string(&(current_rev_assy)->p_alttagno, PDU_alt_tagno);
      }
    }

 stat = PDUcreate_dynamic_arrays(
                                 PDU_dyn_attr_bufr,
                                 PDU_dyn_data_bufr,
                                 &(current_rev_assy)->dyn_attr_count,
                                 &(current_rev_assy)->dyn_attr_names, 
                                 &(current_rev_assy)->dyn_attr_values
                                );
 _pdm_status("PDUcreate_dynamic_arrays", stat);

 _pdm_debug("printing dynamic arrays", 0);
    if ((current_rev_assy->dyn_attr_count > 0) &&
        (current_rev_assy->dyn_attr_names) &&
        (current_rev_assy->dyn_attr_values))
      {
      for (index = 0; index < current_rev_assy->dyn_attr_count; ++index)
         {
         _pdm_debug("name = <%s>", current_rev_assy->dyn_attr_names[index]);
         _pdm_debug("value = <%s>", current_rev_assy->dyn_attr_values[index]);
         }
      }

 PDU_form_id = forms.rev_assy_form_id;

 if (p_explode) free (p_explode);

 return(stat);
}

/* This function does an invisible, graphical part placement for revise
   assembly. */

IGRint PDUplace_part_for_revise_assembly(
				catalog,
				partid,
				revision,
				parttype,
                                file_list,
                                file_count,
				new_catalog,
				new_partid,
				new_revision,
				new_parttype,
				new_file_list,
				new_file_count,
				p_attached,
				p_quantity,
				p_usageid,
				p_alttagno,
				p_incbom,
				p_incstr,
				p_explode,
				new_part)
  char      *catalog;
  char      *partid;
  char      *revision;
  char      *parttype;
  char      *file_list[10];
  int        file_count;
  char      *new_catalog;
  char      *new_partid;
  char      *new_revision;
  char      *new_parttype;
  char      *new_file_list[10];
  int        new_file_count;
  char      *p_attached;
  char      *p_quantity;
  char      *p_usageid;
  char      *p_alttagno;
  char      *p_incbom;
  char      *p_incstr;
  char      *p_explode;
  char      *new_part;
{
  IGRint    status = PDM_S_SUCCESS;
  IGRint    status1 = PDM_S_SUCCESS;
  IGRint    part_status = PDM_S_SUCCESS;
  IGRint    index = 0;
  IGRint    i = 1;
  IGRint    msg2;
  IGRint    file_type;
  IGRint    save_flag = 1;
  IGRint    design_count;
  IGRint    char_index = 0;
  IGRlong   msg;
  IGRlong   sts;
  IGRlong   NumberOfBytes, BytesReceived;
  IGRchar   *filename = NULL;
  IGRchar   *plc_file = NULL;
  IGRchar   *edit_display = NULL;
  IGRchar   *new_filename = NULL;
  IGRchar   *title = NULL;
  IGRchar   *line = NULL;
  IGRchar   mount_name[40];
  IGRchar   mach_type;
  IGRchar   design_list[10][15];
  IGRshort  major;
  IGRshort  minor;
  IGRshort  found = FALSE;
  IGRshort  close_mod = FALSE;
  GRobjid   osid = NULL_OBJID;
  OMuword   osnum;
  GRobjid   objid;
  IGRdouble quantity;
  extern    IGRshort   PDU_attach;
  extern    struct PDUpart           *part;
  struct    GRid      part_id;
  struct    GRmd_env  mod_env;
  extern void PDUdelete_active_part_form();

  _pdm_debug("in the function PDUplace_part_for_revise_assembly", 0);

  _pdm_debug("p_attached = <%s>", p_attached);

  _pdm_debug("placing part:", 0);
  _pdm_debug("catalog = <%s>", new_catalog);
  _pdm_debug("partid = <%s>", new_partid);
  _pdm_debug("revision = <%s>", new_revision);

  _pdm_debug("parent part:", 0);
  _pdm_debug("catalog = <%s>", catalog);
  _pdm_debug("partid = <%s>", partid);
  _pdm_debug("revision = <%s>", revision);

  _pdm_debug("p_attached = <%s>", p_attached);
  _pdm_debug("p_quantity = <%s>", p_quantity);
  _pdm_debug("p_usageid = <%s>", p_usageid);
  _pdm_debug("p_alttagno = <%s>", p_alttagno);
  _pdm_debug("p_incbom = <%s>", p_incbom);
  _pdm_debug("p_incstr = <%s>", p_incstr);
  _pdm_debug("p_explode = <%s>", p_explode);
  _pdm_debug("file_count = <%d>", (char *)file_count);
  _pdm_debug("new_file_count = <%d>", (char *)new_file_count);

  if (strcmp(new_part, "Y") == 0)
    _pdm_debug("part placement was just added to database", 0);

/* find the design file for the new part */
if ((strcmp(new_parttype, "P") != 0) && (strcmp(new_parttype, "p") != 0))
{
if (PDU_attach)
  {
  _pdm_debug("part will be attached", 0);

  if (new_file_count == 0)
    {
    _pdm_debug("part does not have any files", 0);
    PDUfill_in_string(&plc_file, NULL_STRING);
    PDU_attach = 0;
    PDUfill_in_string(&p_attached, "N");
    }

  if (PDU_attach)
    {
    _pdm_debug("check the file status of the part", 0);
    part_status = PDMrcheck_part_status(current_rev_assy->new_catalog,
                                   current_rev_assy->new_partid,
                                   current_rev_assy->new_revision);
    _pdm_status("PDMrcheck_part_status", part_status);
    if (part_status == PDM_I_NEVER_CHECKED_IN)
      {
      _pdm_debug("part has never been checked in", 0);
      found = FALSE;
      _pdm_debug("check to see if files have been created", 0);
      for (i = 0; i < new_file_count; ++i)
         {
         status = PDUverify_file(new_file_list[i]);
         _pdm_status("PDUverify_file", 0);
         if (status == PDM_S_SUCCESS)
           {
           found = TRUE;
           break;
           }
         }
      if (new_file_count == 0)
        found = TRUE;
      }
    else
      {
      _pdm_debug("part has been checked in before", 0);
      found = TRUE;
      }

    if (!found)
      {
      _pdm_debug("part's files have not been created", 0);
      _pdm_debug("resetting PDU_attach to FALSE", 0);
      PDU_attach = FALSE;
      }

    if ((new_file_count > 1) && (part_status == PDM_I_NEVER_CHECKED_IN))
      {
      /* find the design file */
      for (i = 0; i < new_file_count; ++i)
       {
       if (!(new_file_list[i]))
         continue;
       if (!strlen(new_file_list[i]))
         continue;

       _pdm_debug("number of files = <%d>", (char *)new_file_count);
       _pdm_debug("checking file <%s>", new_file_list[i]);
       PDUfill_in_string(&plc_file, new_file_list[i]);
  
       status = ex$is_om_file(
                              filename = plc_file,
                              p_major = &major,
                              p_minor = &minor,
                              p_mach_type = &mach_type,
                              p_file_type = &file_type
                             );
       _pdm_status("ex$is_om_file", status);
  
       if (status)
         {
         _pdm_debug("file <%s> is an OM file", plc_file);
         }
       else
         {
         _pdm_debug("file <%s> is NOT an OM file", plc_file);
         status = PDM_S_SUCCESS;
         continue;
         }
  
       _pdm_debug("Construct file mount name", 0);
       strcpy(mount_name, ":");
       strcat(mount_name, plc_file);
  
       _pdm_debug("mount_name = <%s>", mount_name);
  
       _pdm_debug("Get osnum of invis space", 0);
       status = ex$retrieve_module (
                                    filename = plc_file,
                                    file_no = &index,
                                    ftype = EX_invisible,
                                    flag = EX_read_write,
                                    fstat = EX_default,
                                    type = EX_ACTINV,
                                    mount_name = mount_name,
                                    msg = &msg2
                                   );
       _pdm_status ("ex$retrieve_module", status);

       if (!status)
          {
           _pdm_debug("ex$retrieve_module failed on <%s>", plc_file);
           return(PDM_E_OPEN_FILE);
          }
  
       _pdm_debug("opening object space", 0);
       status = ex$get_invis_info_by_index (
                                            index = index,
                                            mod_osnum = &osnum,
                                            mod_id = &objid,
                                            filed_id = &osid
                                           );
       _pdm_status ("ex$get_invis_info_by_index", status);

       if (!status)
          {
           _pdm_debug("ex$get_invis_info_by_index failed on <%s>", plc_file);
           return(PDM_E_OPEN_FILE);
          }
  
       NumberOfBytes = sizeof(mod_env);
       status = gr$get_module_env(
                               msg = &msg,
                               sizbuf = &NumberOfBytes,
                               buffer = &mod_env,
                               nret = &BytesReceived
                             );
  
       mod_env.md_id.osnum = osnum;
       mod_env.md_id.objid = objid;
  
       if (!(PDUis_PDU_design_file(&mod_env)))
         {
         _pdm_debug("file <%s> is not a design file", plc_file);
         status = PDM_S_SUCCESS;

         save_flag = 0;
         _pdm_debug("Close and do not save object space", 0);
         status = ex$close_module (
                                    index = index,
                                    flag = save_flag | EX_ACTINV,
                                    ftype = EX_invisible
                                   );
         _pdm_status ("ex$close_module", status);
       
         continue;
         }
       else
         {
         found = TRUE;

         save_flag = 0;
         _pdm_debug("Close and do not save object space", 0);
         status = ex$close_module (
                                    index = index,
                                    flag = save_flag | EX_ACTINV,
                                    ftype = EX_invisible
                                   );
         _pdm_status ("ex$close_module", status);
       
         break;
         }

       }
      if (!found)
        {
        _pdm_debug("could not find design file for part to be attached", 0);
        _pdm_debug("resetting PDU_attach to FALSE", 0);
        PDU_attach = FALSE;
        }
      }
    else if (new_file_count == 1)
      {
      PDUfill_in_string(&plc_file, new_file_list[0]);
      _pdm_debug("filename is <%s>", plc_file);
      }
    else if (new_file_count == 0)
      {
      PDUfill_in_string(&plc_file, NULL_STRING);
      _pdm_debug("filename is <%s>", plc_file);
      }
    }
  }
else
  {
  _pdm_debug("part will not be attached", 0);
  PDUfill_in_string(&plc_file, NULL_STRING);
  }
}

  /* find the design file for the parent part */
  if (file_count == 0)
    {
    _pdm_debug("error finding design file for parent part", 0);
    return(PDM_E_DESIGN_FILE_NOT_FOUND);
    }

  /* initialize file list */
  for (index = 0; index < 10; ++index)
     design_list[index][0] = '\0';

  found = FALSE;
  design_count = 0;
  for (i = 0; i < file_count; ++i)
     {
     _pdm_debug("number of files = <%d>", (char *)file_count);
     _pdm_debug("checking file <%s>", file_list[i]);
     PDUfill_in_string(&filename, file_list[i]);

     status = ex$is_om_file(
                            filename = filename,
                            p_major = &major,
                            p_minor = &minor,
                            p_mach_type = &mach_type,
                            p_file_type = &file_type
                           );
     _pdm_status("ex$is_om_file", status);

     if (status)
       {
       _pdm_debug("file <%s> is an OM file", filename);
       found = TRUE;
       _pdm_debug("adding file <%s> to list of design files", filename);
       strcpy(design_list[design_count], filename);
       ++design_count;
       }
     else
       {
       _pdm_debug("file <%s> is NOT an OM file", filename);
       status = PDM_S_SUCCESS;
       continue;
       }
     }

  if (!found)
    {
    _pdm_debug("design file not found; must do nongraphic placement", 0);
    _pdm_debug("exiting PDUplace_part_for_revise_assembly", 0);
    PDUcleanup_revise_assembly();
    return(PDM_E_DESIGN_FILE_NOT_FOUND);
    }

  _pdm_debug("parent part has <%d> design files", (char *)design_count);

  if (design_count > 10)
    {
    _pdm_debug("Error: number of files exceeds size of list", 0);
    return(PDM_E_NUM_FILES_EXCEEDS_LIST);
    }

  if (design_count > 1)
    {
    _pdm_debug("create buffer to display list of files", 0);
    if (PDU_ret_bufr)
      {
      MEMclose(&PDU_ret_bufr);
      PDU_ret_bufr = NULL;
      }

    _pdm_debug("create buffer and load files", 0);
    MEMopen(&PDU_ret_bufr, 512);
    MEMwrite_format(PDU_ret_bufr, "n_cofilename", "char(15)");

    line = (char*) malloc (PDU_ret_bufr->row_size);
    memset (line, NULL, PDU_ret_bufr->row_size);

    char_index = 0;

    for (i = 0; i < design_count; ++i)
       {
       if ((design_list[i]) && (strlen(design_list[i])))
         PDUadd_buffer_string(line, &char_index, design_list[i]);
       else
         line[char_index++] = '\1';

       _pdm_debug("line = <%s>", line);

       status = MEMwrite(PDU_ret_bufr, line);
       _pdm_status("MEMwrite", status);
       if (status != MEM_S_SUCCESS)
         return(PDM_E_WRITE_BUFFER);
       status = PDM_S_SUCCESS;

       char_index = 0;
       memset (line, NULL, PDU_ret_bufr->row_size);
       }

    if (PDMdebug_on)
      MEMprint_buffer("PDU_ret_bufr", PDU_ret_bufr, PDU_DEBUG_FILE);

    _pdm_debug("display list of files", 0);
    status = PDUdisplay_checkin_files();
    _pdm_status("PDUdisplay_checkin_files", status);

    status = WaitForEvent();
    _pdm_status("WaitForEvent", status);

    if (!status)
      {
      _pdm_debug("file list form was cancelled", 0);
      return(PDM_E_CMD_CANCELLED);
      }

    PDUfill_in_string(&filename, PDU_checkin_file);
    }
  else if (design_count == 1)
    PDUfill_in_string(&filename, design_list[0]);

  _pdm_debug("design file is <%s>", filename);

  _pdm_debug("open OS for design file <%s>", filename);
  _pdm_debug("Construct file mount name", 0);
  strcpy(mount_name, ":");
  strcat(mount_name, filename);

  _pdm_debug("mount_name = <%s>", mount_name);

  _pdm_debug("Get osnum of invis space", 0);
  status = ex$retrieve_module (
                               filename = filename,
                               file_no = &index,
                               ftype = EX_invisible,
                               flag = EX_read_write,
                               fstat = EX_default,
                               type = EX_ACTINV,
                               mount_name = mount_name,
                               msg = &msg2
                              );
  _pdm_status ("ex$retrieve_module", status);

  if (!status)
     {
      _pdm_debug("ex$retrieve_module failed on <%s>", filename);
      PDUcleanup_revise_assembly();
      return(PDM_E_OPEN_FILE);
     }

  _pdm_debug("opening object space", 0);
  status = ex$get_invis_info_by_index (
                                       index = index,
                                       mod_osnum = &osnum,
                                       mod_id = &objid,
                                       filed_id = &osid
                                      );
  _pdm_status ("ex$get_invis_info_by_index", status);

  if (!status)
     {
      _pdm_debug("ex$get_invis_info_by_index failed on <%s>", filename);
      PDUcleanup_revise_assembly();
      return(PDM_E_OPEN_FILE);
     }

  close_mod = TRUE;

  NumberOfBytes = sizeof(mod_env);
  status = gr$get_module_env(
                          msg = &msg,
                          sizbuf = &NumberOfBytes,
                          buffer = &mod_env,
                          nret = &BytesReceived
                        );

  mod_env.md_id.osnum = osnum;
  mod_env.md_id.objid = objid;

  _pdm_debug("query for dynamic attributes", 0);
  status = PDUget_dynamic_data_for_rev_assy(mod_env, new_parttype);
  _pdm_status("PDUget_dynamic_data_for_rev_assy", status);
/* this function loads current_rev_assy with dyn_attr_count, names & values */
  if (status != PDM_S_SUCCESS)
    {
    PDUcleanup_revise_assembly();
    return(status);
    }

  _pdm_debug("resetting values after dyn attr", 0);
  PDUfill_in_string(&p_usageid, current_rev_assy->new_usageid);
  PDUfill_in_string(&p_quantity, current_rev_assy->p_quantity);
  PDUfill_in_string(&p_alttagno, current_rev_assy->p_alttagno);

  PDUmessage(PDM_E_CLEAR_FIELD, 's');

  PDUdelete_active_part_form();

  /* display active part form */
  title = (char *)PDUtranslate_message(PDM_I_PLACING_PART);
  PDUactive_part_form(new_catalog, new_partid, new_revision, "", title);

  /* place the new part */
  _pdm_debug("setting global variables", 0);
  PDUfill_in_string(&PDU_usage_id, p_usageid);
  PDUfill_in_string(&PDU_explode_BOM, p_explode);
  PDUfill_in_string(&PDU_alt_tagno, p_alttagno);
  PDUfill_in_string(&PDU_incl_ASM, p_incstr);
  PDUfill_in_string(&PDU_incl_BOM, p_incbom);
  PDUfill_in_string(&PDU_quantity, p_quantity);
  sscanf(p_quantity, "%lf", &quantity);

  if (strcmp(p_attached, "Y") == 0)
    PDU_attach = TRUE;
  else
    PDU_attach = FALSE;

  _pdm_debug("PDU_attach = %d", (char *)PDU_attach);
  _pdm_debug("p_attached = <%s>", p_attached);

  if (PDU_edit_display)
    PDUfill_in_string(&edit_display, "Y");
  else
    PDUfill_in_string(&edit_display, "N");

  if ((strcmp(new_parttype, "P") != 0) && (strcmp(new_parttype, "p") != 0) &&
      (strlen(new_file_list[0])))
    {
    _pdm_debug("calling PDUdisplay_files_and_origins", 0);
    status = PDUdisplay_files_and_origins(new_catalog, new_partid, new_revision,
                                          &new_filename, &part->view);
    _pdm_status("PDUdisplay_files_and_origins", status);
    if (status != PDM_S_SUCCESS)
      {
      _pdm_debug("display files and origins failed");
      }
    }

  PDUfill_in_string(&refresh->act_catalog, catalog);
  PDUfill_in_string(&refresh->act_partid, partid);
  PDUfill_in_string(&refresh->act_revision, revision);

  status = pdmoPlacePart(
              	&msg,
		&mod_env,
		&part_id,
		new_catalog,
		new_partid,
		new_revision,
		new_filename,
		p_usageid,
                part->view,
		quantity,
		p_explode,
		p_attached,
		p_alttagno,
                p_incstr,
                p_incbom,
		current_rev_assy->dyn_attr_count,
		current_rev_assy->dyn_attr_names,
		current_rev_assy->dyn_attr_values,
		0,
		NULL,
		NULL,
		NULL,
		NULL,
		NULL,
		NULL,
		edit_display);
  _pdm_status("pdmoPlacePart", status);

  if (status != PDM_S_SUCCESS)
    {
    PDUmessage(status, 's');
    status1 = pdmoDeletePartOccurrence(&msg, &mod_env, &part_id);
    _pdm_status("pdmoDeletePartOccurrence", status1);

    save_flag = 0;
    sts = ex$close_module (
                               index = index,
                               flag = save_flag | EX_ACTINV,
                               ftype = EX_invisible
                              );
    _pdm_status ("ex$close_module", sts);

    PDUcleanup_revise_assembly();
    return(status);
    }

  PDUexecute_upon_save_for_rev_assy(&mod_env);

  _pdm_debug("Close and save object space", 0);
  save_flag = 1;
  sts = ex$close_module (
                               index = index,
                               flag = save_flag | EX_ACTINV,
                               ftype = EX_invisible
                              );
  _pdm_status ("ex$close_module", sts);

  _pdm_debug("make sure none of the files have been left open", 0);
  for (i = 0; i < design_count; ++i)
     {
     _pdm_debug("checking file <%s>", design_list[i]);
     sts = PDUis_file_open(design_list[i]);
     _pdm_status("PDUis_file_open", sts);

     if (sts)
       {
       _pdm_debug("file <%s> was left open", design_list[i]);
       _pdm_debug("Construct file mount name", 0);
       strcpy(mount_name, ":");
       strcat(mount_name, design_list[i]);
     
       _pdm_debug("mount_name = <%s>", mount_name);
     
       _pdm_debug("Get osnum of invis space", 0);
       sts = ex$retrieve_module (
                                 filename = design_list[i],
                                 file_no = &index,
                                 ftype = EX_invisible,
                                 flag = EX_read_write,
                                 fstat = EX_default,
                                 type = EX_ACTINV,
                                 mount_name = mount_name,
                                 msg = &msg2
                                );
       _pdm_status ("ex$retrieve_module", sts);
       if (!sts)
         {
         _pdm_debug("Close and save object space", 0);
         save_flag = 1;
         sts = ex$close_module (
                                      index = index,
                                      flag = save_flag | EX_ACTINV,
                                      ftype = EX_invisible
                                );
         _pdm_status ("ex$close_module", sts);
         }
       }
     }

  PDUdelete_active_part_form();

  if (PDU_usage_id)
    {
    free(PDU_usage_id);
    PDU_usage_id = NULL;
    }

  if (filename) free(filename);
  if (plc_file) free(plc_file);
  if (edit_display) free(edit_display);
  if (new_filename) free(new_filename);
  if (title) free(title);

  return(status);
}

IGRint PDUcheck_part_files_for_PDU_parts(catalog, partid, revision)
IGRchar  *catalog;
IGRchar  *partid;
IGRchar  *revision;
{
  IGRint    status = PDM_S_SUCCESS;
  IGRint    row;
  IGRint    file_col = 0;
  IGRint    index = 0;
  IGRlong    msg;
  IGRint    msg2;
  IGRint    file_type;
  IGRint    save_flag = 0;
  IGRlong   NumberOfBytes, BytesReceived;
  IGRchar   *plc_file = NULL;
  IGRchar   **data_row;
  IGRchar   mount_name[40];
  IGRchar   mach_type;
  IGRshort  major;
  IGRshort  minor;
  GRobjid   osid = NULL_OBJID;
  OMuword   osnum;
  GRobjid   objid;
  struct    GRmd_env  mod_env;
  MEMptr    file_buffer = NULL;

  _pdm_debug("in the function PDUcheck_part_files_for_PDU_parts", 0);

  status = PDMrcheck_part_status(catalog, partid, revision);
  _pdm_status("PDMrcheck_part_status", status);
  if (status != PDM_I_NEVER_CHECKED_IN)
    {
    _pdm_debug("part has never been checked in; returning 0", 0);
    return(0);
    }

  status = PDMget_filenames(catalog, partid, revision, &file_buffer);
  _pdm_status("PDMget_filenames", status);

  if (!file_buffer)
    {
    _pdm_debug("part does not have any files; returning 0", 0);
    return(0);
    }
  else if (file_buffer->rows == 0)
    {
    _pdm_debug("part does not have any files; returning 0", 0);
    return(0);
    }

  status = MEMbuild_array(file_buffer);
  _pdm_status("MEMbuild_array", status);
  if (status != MEM_S_SUCCESS)
    return(PDM_E_BUILD_BUFFER_ARRAY);
  PDUsetup_buffer(file_buffer, ROW, &data_row);

  status = PDUget_buffer_col(file_buffer, "n_cofilename", &file_col);
  _pdm_status("PDUget_buffer_col", status);
  if (status != PDM_S_SUCCESS)
    {
    MEMclose(&file_buffer);
    file_buffer = NULL;
    return(status);
    }

  _pdm_debug("part has %d files", (char *)(file_buffer->rows));

  for (row = 0; row < file_buffer->rows; ++row)
     {
     PDUfill_in_string(&plc_file,
                       data_row[(file_buffer->columns * row) + file_col]);


     _pdm_debug("checking file <%s>", plc_file);
  
     status = ex$is_om_file(
                              filename = plc_file,
                              p_major = &major,
                              p_minor = &minor,
                              p_mach_type = &mach_type,
                              p_file_type = &file_type
                             );
     _pdm_status("ex$is_om_file", status);
  
     if (status)
       {
       _pdm_debug("file <%s> is an OM file", plc_file);
       }
     else
       {
       _pdm_debug("file <%s> is NOT an OM file", plc_file);
       status = PDM_S_SUCCESS;
       continue;
       }
  
     _pdm_debug("Construct file mount name", 0);
     strcpy(mount_name, ":");
     strcat(mount_name, plc_file);
  
     _pdm_debug("mount_name = <%s>", mount_name);
 
     _pdm_debug("Get osnum of invis space", 0);
     status = ex$retrieve_module (
                                    filename = plc_file,
                                    file_no = &index,
                                    ftype = EX_invisible,
                                    flag = EX_read_write,
                                    fstat = EX_default,
                                    type = EX_ACTINV,
                                    mount_name = mount_name,
                                    msg = &msg2
                                   );
     _pdm_status ("ex$retrieve_module", status);

     if (!status)
        {
         _pdm_debug("ex$retrieve_module failed on <%s>", plc_file);
         return(PDM_E_OPEN_FILE);
        }

     _pdm_debug("opening object space", 0);
     status = ex$get_invis_info_by_index (
                                            index = index,
                                            mod_osnum = &osnum,
                                            mod_id = &objid,
                                            filed_id = &osid
                                           );
     _pdm_status ("ex$get_invis_info_by_index", status);

     if (!status)
        {
         _pdm_debug("ex$get_invis_info_by_index failed on <%s>", plc_file);
         return(PDM_E_OPEN_FILE);
        }
  
     NumberOfBytes = sizeof(mod_env);
     status = gr$get_module_env(
                               msg = &msg,
                               sizbuf = &NumberOfBytes,
                               buffer = &mod_env,
                               nret = &BytesReceived
                             );
  
     mod_env.md_id.osnum = osnum;
     mod_env.md_id.objid = objid;
  
     if (!(PDUis_PDU_file(mod_env)))
       {
       _pdm_debug("file <%s> is not a design file", plc_file);
       status = PDM_S_SUCCESS;

       save_flag = 0;
       _pdm_debug("Close and do not save object space", 0);
       status = ex$close_module (
                                  index = index,
                                  flag = save_flag | EX_ACTINV,
                                  ftype = EX_invisible
                                 );
       _pdm_status ("ex$close_module", status);
     
       continue;
       }
     else
       {
       save_flag = 0;
       _pdm_debug("Close and do not save object space", 0);
       status = ex$close_module (
                                  index = index,
                                  flag = save_flag | EX_ACTINV,
                                  ftype = EX_invisible
                                 );
       _pdm_status ("ex$close_module", status);

       return(1);
       }
     }

  return(0);
}

IGRint PDUdelete_part_for_revise_assembly(
                                file_list,
                                file_count,
				old_usageid,
				del_catalog,
				del_partid,
				del_revision)
  char      *file_list[10];
  int        file_count;
  char      *old_usageid;
  char      *del_catalog;
  char      *del_partid;
  char      *del_revision;
{
  IGRint    status = PDM_S_SUCCESS;
  IGRint    status1 = PDM_S_SUCCESS;
  IGRint    part_status = PDM_S_SUCCESS;
  IGRint    max_comp_count = 0;
  IGRint    component_count = 0;
  IGRint    num_objects = 1;
  IGRint    index = 0;
  IGRint    i = 1;
  IGRint    msg2;
  IGRint    file_type;
  IGRint    save_flag = 1;
  IGRint    design_count;
  IGRint    char_index = 0;
  IGRlong   msg;
  IGRlong   sts;
  IGRlong   NumberOfBytes, BytesReceived;
  IGRchar   class_msg[80];
  IGRchar   *filename = NULL;
  IGRchar   *title = NULL;
  IGRchar   *line = NULL;
  IGRchar   *save_cat = NULL;
  IGRchar   *save_part = NULL;
  IGRchar   *save_rev = NULL;
  IGRchar   mount_name[40];
  IGRchar   mach_type;
  IGRchar   design_list[10][15];
  IGRshort  major;
  IGRshort  minor;
  IGRshort  found = FALSE;
  IGRshort  close_mod = FALSE;
  GRobjid   osid = NULL_OBJID;
  OMuword   osnum;
  GRobjid   objid;
  extern    struct PDUpart           *part;
  struct    GRid      *component_ids = NULL;
  struct    GRid      part_id;
  struct    GRid      src_coorid;
  struct    GRmd_env  mod_env;
  struct    GRobj_env objects[1];
  struct    PDUparts_list *list = NULL;
  extern void PDUdelete_active_part_form();

  _pdm_debug("in the function PDUdelete_part_for_revise_assembly", 0);

  _pdm_debug("deleting part: <%s>", old_usageid);

  _pdm_debug("parent part file_count = <%d>", (char *)file_count);

  /* find the design file for the parent part */
  if (file_count == 0)
    {
    _pdm_debug("error finding design file for parent part", 0);
    return(PDM_E_DESIGN_FILE_NOT_FOUND);
    }

  /* initialize file list */
  for (index = 0; index < 10; ++index)
     design_list[index][0] = '\0';

  found = FALSE;
  design_count = 0;
  for (i = 0; i < file_count; ++i)
     {
     _pdm_debug("number of files = <%d>", (char *)file_count);
     _pdm_debug("checking file <%s>", file_list[i]);
     PDUfill_in_string(&filename, file_list[i]);

     status = ex$is_om_file(
                            filename = filename,
                            p_major = &major,
                            p_minor = &minor,
                            p_mach_type = &mach_type,
                            p_file_type = &file_type
                           );
     _pdm_status("ex$is_om_file", status);

     if (status)
       {
       _pdm_debug("file <%s> is an OM file", filename);
       found = TRUE;
       _pdm_debug("adding file <%s> to list of design files", filename);
       strcpy(design_list[design_count], filename);
       ++design_count;
       }
     else
       {
       _pdm_debug("file <%s> is NOT an OM file", filename);
       status = PDM_S_SUCCESS;
       continue;
       }
     }

  if (!found)
    {
    _pdm_debug("design file not found; must do nongraphic delete", 0);
    _pdm_debug("exiting PDUdelete_part_for_revise_assembly", 0);
    PDUcleanup_revise_assembly();
    return(PDM_E_DESIGN_FILE_NOT_FOUND);
    }

  _pdm_debug("parent part has <%d> design files", (char *)design_count);

  if (design_count > 10)
    {
    _pdm_debug("Error: number of files exceeds size of list", 0);
    return(PDM_E_NUM_FILES_EXCEEDS_LIST);
    }

  if (design_count > 1)
    {
    _pdm_debug("create buffer to display list of files", 0);
    if (PDU_ret_bufr)
      {
      MEMclose(&PDU_ret_bufr);
      PDU_ret_bufr = NULL;
      }

    MEMopen(&PDU_ret_bufr, 512);
    MEMwrite_format(PDU_ret_bufr, "n_cofilename", "char(15)");

    line = (char*) malloc (PDU_ret_bufr->row_size);
    memset (line, NULL, PDU_ret_bufr->row_size);

    char_index = 0;

    for (i = 0; i < design_count; ++i)
       {
       if ((design_list[i]) && (strlen(design_list[i])))
         PDUadd_buffer_string(line, &char_index, design_list[i]);
       else
         line[char_index++] = '\1';

       _pdm_debug("line = <%s>", line);

       status = MEMwrite(PDU_ret_bufr, line);
       _pdm_status("MEMwrite", status);
       if (status != MEM_S_SUCCESS)
         return(PDM_E_WRITE_BUFFER);
       status = PDM_S_SUCCESS;

       char_index = 0;
       memset (line, NULL, PDU_ret_bufr->row_size);
       }

    if (PDMdebug_on)
      MEMprint_buffer("PDU_ret_bufr", PDU_ret_bufr, PDU_DEBUG_FILE);

    _pdm_debug("display list of files", 0);
    status = PDUdisplay_checkin_files();
    _pdm_status("PDUdisplay_checkin_files", status);

    status = WaitForEvent();
    _pdm_status("WaitForEvent", status);

    if (!status)
      {
      _pdm_debug("file list form was cancelled", 0);
      return(PDM_E_CMD_CANCELLED);
      }

    PDUfill_in_string(&filename, PDU_checkin_file);
    }
  else if (design_count == 1)
    PDUfill_in_string(&filename, design_list[0]);

  _pdm_debug("design file is <%s>", filename);

  _pdm_debug("open OS for design file <%s>", filename);
  _pdm_debug("Construct file mount name", 0);
  strcpy(mount_name, ":");
  strcat(mount_name, filename);

  _pdm_debug("mount_name = <%s>", mount_name);

  _pdm_debug("Get osnum of invis space", 0);
  status = ex$retrieve_module (
                               filename = filename,
                               file_no = &index,
                               ftype = EX_invisible,
                               flag = EX_read_write,
                               fstat = EX_default,
                               type = EX_ACTINV,
                               mount_name = mount_name,
                               msg = &msg2
                              );
  _pdm_status ("ex$retrieve_module", status);

  if (!status)
     {
      _pdm_debug("ex$retrieve_module failed on <%s>", filename);
      PDUcleanup_revise_assembly();
      return(PDM_E_OPEN_FILE);
     }

  _pdm_debug("opening object space", 0);
  status = ex$get_invis_info_by_index (
                                       index = index,
                                       mod_osnum = &osnum,
                                       mod_id = &objid,
                                       filed_id = &osid
                                      );
  _pdm_status ("ex$get_invis_info_by_index", status);

  if (!status)
     {
      _pdm_debug("ex$get_invis_info_by_index failed on <%s>", filename);
      PDUcleanup_revise_assembly();
      return(PDM_E_OPEN_FILE);
     }

  close_mod = TRUE;

  NumberOfBytes = sizeof(mod_env);
  status = gr$get_module_env(
                          msg = &msg,
                          sizbuf = &NumberOfBytes,
                          buffer = &mod_env,
                          nret = &BytesReceived
                        );

  mod_env.md_id.osnum = osnum;
  mod_env.md_id.objid = objid;

  PDUmessage(PDM_E_CLEAR_FIELD, 's');

  PDUdelete_active_part_form();

  /* display active part form */
  title = (char *)PDUtranslate_message(PDM_I_DELETING_PART);
  PDUactive_part_form(del_catalog, del_partid, del_revision, "", title);

  /* get objid of part */
  _pdm_debug("calling pdmoGetPartidGivenUsageid", 0);
  _pdm_debug("usageid = <%s>", old_usageid);
  status = pdmoGetPartidGivenUsageid(old_usageid, &mod_env, &part_id);
  _pdm_status("pdmoGetPartidGivenUsageid", status);
  if (status != PDM_S_SUCCESS)
    {
    _pdm_debug("Close and do not save object space", 0);
    save_flag = 0;
    status1 = ex$close_module (
                               index = index,
                               flag = save_flag | EX_ACTINV,
                               ftype = EX_invisible
                              );
    _pdm_status ("ex$close_module", status1);
    PDUcleanup_revise_assembly();
    return(status);
    }

  _pdm_debug("calling GRget_number_components", 0);
  om$send(msg = message GRowner.GRget_number_components(&sts, &max_comp_count),
              senderid = NULL_OBJID,
              targetid = part_id.objid,
              targetos = part_id.osnum);
  _pdm_debug("%d components were found", max_comp_count);
  component_ids = (struct GRid * )malloc(sizeof (struct GRid) *
                   max_comp_count);
  om$send(msg = message GRowner.GRget_components(&sts, &mod_env,
                                                 component_ids,
                                                 max_comp_count,
                                                 &component_count, 0,
                                                 max_comp_count - 1),
          senderid = NULL_OBJID,
          targetid = part_id.objid,
          targetos = part_id.osnum);
   _pdm_debug("After getting components", 0);

  _pdm_debug("component_count = %d", (char *)component_count);
  found = FALSE;
  if (component_count > 0)
    {
    for ( i = 0; i < component_count; i = i + 1)
      {
      sts = om$get_classname(objid = component_ids[i].objid,
                             osnum = component_ids[i].osnum,
                             classname = class_msg);
      _pdm_debug("class is %s", class_msg);
      if (strcmp(class_msg, "GRgencs") == 0)
        {
        _pdm_debug("CS found", 0);
        objects[0].mod_env = mod_env;
        objects[0].obj_id.objid = component_ids[i].objid;
        objects[0].obj_id.osnum = component_ids[i].osnum;
        found = TRUE;
        }
      }
    if (!found)
      _pdm_debug("CS not found", 0);

    /* delete old part's coord sys from GRpart */
    _pdm_debug("calling GRremove_components", 0);
    om$send(msg = message GRowner.GRremove_components(&sts, &mod_env,
                                                     &num_objects,
                                                     objects),
              senderid = NULL_OBJID,
              targetid = part_id.objid,
              targetos = part_id.osnum);

    _pdm_debug("After removing components", 0);
    }

  _pdm_debug("set refresh->act variables for PDMdetach", 0);
  if (refresh->act_catalog && refresh->act_partid && refresh->act_revision)
    {
    PDUfill_in_string(&save_cat, refresh->act_catalog);
    PDUfill_in_string(&save_part, refresh->act_partid);
    PDUfill_in_string(&save_rev, refresh->act_revision);
    }

  PDUfill_in_string(&refresh->act_catalog, del_catalog);
  PDUfill_in_string(&refresh->act_partid, del_partid);
  PDUfill_in_string(&refresh->act_revision, del_revision);

  _pdm_debug("calling pdmoDeletePartOccurrence", 0);
  status = pdmoDeletePartOccurrence(&sts, &mod_env, &part_id);
  _pdm_status("pdmoDeletePartOccurrence", status);
  if (status != PDM_S_SUCCESS)
    {
    save_flag = 0;
    status = ex$close_module (
                               index = index,
                               flag = save_flag | EX_ACTINV,
                               ftype = EX_invisible
                              );
    _pdm_status ("ex$close_module", status);

    status = PDM_E_DELETE_GRPART;
    PDUcleanup_revise_assembly();
    return(PDM_E_DELETE_GRPART);
    }

  if (found)
    {
    _pdm_debug("CS found:  setting src_coorid", 0);
    src_coorid.objid = objects[0].obj_id.objid;
    src_coorid.osnum = objects[0].obj_id.osnum;
    }

  /* delete the old part's coord sys */

  om$send(msg = message GRgraphics.GRdelete
                                 (
                                  &sts,
                                  &mod_env
                                 ),
         senderid = NULL_OBJID,
         targetid = src_coorid.objid,
         targetos = src_coorid.osnum
        );

  PDUexecute_upon_save_for_rev_assy(&mod_env);

  _pdm_debug("Close and save object space", 0);
  save_flag = 1;
  sts = ex$close_module (
                               index = index,
                               flag = save_flag | EX_ACTINV,
                               ftype = EX_invisible
                              );
  _pdm_status ("ex$close_module", sts);

  _pdm_debug("make sure none of the files have been left open", 0);

  for (i = 0; i < design_count; ++i)
     {
     _pdm_debug("checking file <%s>", design_list[i]);
     sts = PDUis_file_open(design_list[i]);
     _pdm_status("PDUis_file_open", sts);

     if (sts)
       {
       _pdm_debug("file <%s> was left open", design_list[i]);
       _pdm_debug("Construct file mount name", 0);
       strcpy(mount_name, ":");
       strcat(mount_name, design_list[i]);
     
       _pdm_debug("mount_name = <%s>", mount_name);
     
       _pdm_debug("Get osnum of invis space", 0);
       sts = ex$retrieve_module (
                                 filename = design_list[i],
                                 file_no = &index,
                                 ftype = EX_invisible,
                                 flag = EX_read_write,
                                 fstat = EX_default,
                                 type = EX_ACTINV,
                                 mount_name = mount_name,
                                 msg = &msg2
                                );
       _pdm_status ("ex$retrieve_module", sts);
       if (!sts)
         {
         _pdm_debug("Close and save object space", 0);
         save_flag = 1;
         sts = ex$close_module (
                                      index = index,
                                      flag = save_flag | EX_ACTINV,
                                      ftype = EX_invisible
                                );
         _pdm_status ("ex$close_module", sts);
         }
       }
     }

  PDUdelete_active_part_form();

  if (PDU_usage_id)
    {
    free(PDU_usage_id);
    PDU_usage_id = NULL;
    }

  if (save_cat && save_part && save_rev)
    {
    PDUfill_in_string(&refresh->act_catalog, save_cat);
    PDUfill_in_string(&refresh->act_partid, save_part);
    PDUfill_in_string(&refresh->act_revision, save_rev);
    }

  if (filename) free(filename);
  if (title) free(title);
  if (save_cat) free(save_cat);
  if (save_part) free(save_part);
  if (save_rev) free(save_rev);

  return(status);
}

end implementation COpdu; 
