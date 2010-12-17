class implementation COpdu;
/*
  PMdlprto.I contains the function pdmoDeletePartOccurrence for the API

  Author: Jenny Parris
*/

/* Include file section */
#include        "stdio.h"
#include        "unistd.h"
#include        "ctype.h"
#include        <sys/stat.h>
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
#include        "PDUuser.h"
#include        "PDUfile_def.h"
#include        "PDUconvert.h"
#include        "PDUqueue.h"
#include        "PDUassy.h"
#include        "PDUnode.h"
#include        "PDUstorage.h"


/* Imported messages */
from  GRowner     import       GRadd_components;
from  GRreffile   import       GRchglevels;
from  GRgraphics  import       GRconstruct;
from  GRgraphics  import       GRxform;
from  GRgraphics  import       GRdelete;
from  GRgencs     import       GRgetmatrix;
from  GRreffile   import       GRgetenvironment;
from  GRreffile   import       GRgetdescription;
from  GRreffile   import       GRinquireref;
from  GRcsmgr     import       GRcstoggle_display;

IGRlong pdmoDeleteMacroLibraryEntry(osnum, macrolibrary)

  OMuword osnum;
  char *macrolibrary;
  {
  IGRlong status;
  IGRint  sts;
  char dir_name[DI_PATH_MAX];
  GRspacenum lib_osnum;
  IGRint invisible_index;
 
  _pdm_debug("In the pdmoDeleteMacroLibrary function", 0);

  status = di$give_pathname(osnum = osnum, pathname = dir_name);
  strcat(dir_name, ":constructs_lib:");
  strcat(dir_name, macrolibrary);
  _pdm_debug("dir_name = <%s>", dir_name);
  status = di$give_osnum(pathname = dir_name, p_osnum = &lib_osnum);
  if (!(status & 1))
    return(PDM_E_DETACH_MACRO_LIB);
  if (ex$is_invis(mod_osnum = lib_osnum, index = &invisible_index))
    {
    _pdm_debug("close OS invisibly", 0);
    sts = ex$close_module(ftype = EX_invisible, index = invisible_index);
    if (sts) 
      {
      _pdm_debug("ex$close_module successful", 0);
      ACopen_init();
      }
    }
  return(PDM_S_SUCCESS);
  }

IGRlong pdmoDeletePartOccurrence(lw_status,spr_mod_env, spr_part)

  IGRlong *lw_status;            /* Output: Status of function for PPL API */
  struct GRmd_env *spr_mod_env;  /* Input: Module information */
  struct GRid     *spr_part;     /* Input: Object ID of part to be deleted */
  {
  long status;
  extern short PDU_activate_delete;
  extern IGRlong PDMDeletePartOccurrence();
  
  PDU_activate_delete = FALSE;
  status = PDMDeletePartOccurrence(lw_status, spr_mod_env, spr_part);
  _pdm_status("PDMDeletePartOccurrence", status);
  PDU_activate_delete = TRUE;
  
  return(status);
  }

IGRlong PDMDeletePartOccurrence(lw_status,spr_mod_env, spr_part)

  IGRlong *lw_status;            /* Output: Status of function for PPL API */
  struct GRmd_env *spr_mod_env;  /* Input: Module information */
  struct GRid     *spr_part;     /* Input: Object ID of part to be deleted */
  {
  IGRlong msg;
  IGRlong status;
  IGRlong NumberOfBytes;
  IGRlong BytesReceived;
  IGRshort free_mod = FALSE;
  IGRint  type;
  IGRchar attr_value[MAX_VALUE];
  IGRchar attach_value[MAX_VALUE];
  IGRchar part_path[DI_PATH_MAX];
  IGRchar *child_no = NULL;
  extern short PDU_activate_delete;
  extern  IGRlong pdmoDetachPart();
  extern  IGRlong pdmoDetachParametricPart();
  
  _pdm_debug("In PDMDeletePartOccurrence", 0);

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

  if (spr_part == NULL)
    {
    if (free_mod)
      {
      free(spr_mod_env);
      spr_mod_env = NULL;
      }
    *lw_status = PDM_E_NULL_OBJID;
    return(PDM_E_NULL_OBJID);
    }

  /* verify spr_part exists in the object space */

  /* Check for part of part to be deleted */
  status = PDUis_parametric_part(spr_part);
  _pdm_status("PDUis_parametric_part", status);

  if (!status)
    {
    /* part is not parametric */
    _pdm_debug("part is not parametric", 0);
    /* extract attach value from the object space */
    status = co$part_get_attr(msg = &msg, 
                              mod_env = spr_mod_env,
                              part = spr_part, 
                              attr = "attach_flag", value = attach_value, 
                              type = &type);
    if (msg != MSSUCC)
      {
      if (free_mod)
        {
        free(spr_mod_env);
        spr_mod_env = NULL;
        }
      *lw_status = PDM_E_INVALID_PART_POINTER;
      return(PDM_E_INVALID_PART_POINTER);
      }
    else if (strcmp(attach_value, "") == 0)
      {
      if (free_mod)
        {
        free(spr_mod_env);
        spr_mod_env = NULL;
        }
      *lw_status = PDM_E_INVALID_PART_POINTER;
      return(PDM_E_INVALID_PART_POINTER);
      }

    /* construct part to file directory */
    strcpy(part_path, "");
    di$give_pathname(osnum = spr_mod_env->md_id.osnum, 
                     pathname = part_path);
   
    status = co$part_get_attr(msg = &msg, 
                              mod_env = spr_mod_env,
                              part = spr_part, 
                              attr = "child_no", value = attr_value, 
                              type = &type);
    if (msg != MSSUCC)
      {
      *lw_status = PDM_E_INVALID_PART_POINTER;
      return(PDM_E_INVALID_PART_POINTER);
      }
    else if (strcmp(attr_value, "") == 0)
      {
      *lw_status = PDM_E_INVALID_PART_POINTER;
      return(PDM_E_INVALID_PART_POINTER);
      }
    PDUunquote(attr_value);
    PDUfill_in_string(&child_no, attr_value);

    /* extract parttype from the object space */
    status = co$part_get_attr(msg = &msg, 
                              mod_env = spr_mod_env,
                              part = spr_part, 
                              attr = "part_type", value = attr_value, 
                              type = &type);
    if (msg != MSSUCC)
      {
      if (free_mod)
        {
        free(spr_mod_env);
        spr_mod_env = NULL;
        }
      *lw_status = PDM_E_INVALID_PART_POINTER;
      return(PDM_E_INVALID_PART_POINTER);
      }
    else if (strcmp(attr_value, "") == 0)
     {
      if (free_mod)
        {
        free(spr_mod_env);
        spr_mod_env = NULL;
        }
     *lw_status = PDM_E_INVALID_PART_POINTER;
     return(PDM_E_INVALID_PART_POINTER);
     }
 
    /* erase part pointer */
    if (!PDU_activate_delete)
      {
      dp$display(msg = &status, oids = spr_part, mode = GRbe);
    
      /* delete GRpart */
      status = om$send(msg = message GRgraphics.GRdelete(&msg, spr_mod_env),
                       senderid = spr_mod_env->md_id.objid,
                       targetid = spr_part->objid, 
                       targetos = spr_part->osnum);
       if (!(status & msg & 1))
         {
         if (free_mod)
           {
           free(spr_mod_env);
           spr_mod_env = NULL;
           }
         *lw_status = PDM_E_DELETE_GRPART;
         return(PDM_E_DELETE_GRPART);
         }
       }

    strcat(part_path, ":ASSEMBLY:P");
    strcat(part_path, child_no);
    status = PDUflag_deleted_parts_in_assembly(spr_mod_env, part_path);
    _pdm_status("PDUremove_assembly", status);

    if (status != PDM_S_SUCCESS)
      {
      if (free_mod)
        {
        free(spr_mod_env);
        spr_mod_env = NULL;
        }
      *lw_status = status;
      return(status);
      }
    }
  else
    {
    /* part is parametric */
    _pdm_debug("part to be deleted is parametric", 0);
    status = delete_prpart(spr_part, spr_mod_env);
    _pdm_status("delete_prpart", status);

    if (!status)
      {
      if (free_mod)
        {
        free(spr_mod_env);
        spr_mod_env = NULL;
        }
      *lw_status = PDM_E_DELETE_PARAMETRIC_PART;
      return(PDM_E_DELETE_PARAMETRIC_PART);
      }

    status = pdmoDetachParametricPart(spr_mod_env, spr_part);
    _pdm_status("pdmoDetachParametricPart", status);

    if (status != PDM_S_SUCCESS)
      {
      if (free_mod)
        {
        free(spr_mod_env);
        spr_mod_env = NULL;
        }
      *lw_status = PDM_E_DETACH_MACRO_LIB;
      return(PDM_E_DETACH_MACRO_LIB);
      }
    }
  if (free_mod)
    {
    free(spr_mod_env);
    spr_mod_env = NULL;
    }
  *lw_status = PDM_S_SUCCESS;
  return(PDM_S_SUCCESS);
  }

 
IGRlong pdmoDetachPart(spr_mod_env, spr_part)
  struct GRmd_env *spr_mod_env;  /* Input: Module information */
  struct GRid     *spr_part;     /* Input: Object ID of part to be deleted */

  {
  IGRlong msg, status;
  IGRint  type;
  IGRint  count;
  IGRint  part_count;
  IGRint  i;
  IGRshort file_found;
  IGRshort unique_flag;
  IGRchar attr_value[MAX_VALUE];
  IGRchar part_path[DI_PATH_MAX];
  IGRchar assy_path[DI_PATH_MAX];
  IGRchar part_dir[DI_PATH_MAX];
  IGRchar s[DI_PATH_MAX];
  IGRchar *catalog = NULL;
  IGRchar *number = NULL;
  IGRchar *revision = NULL;
  IGRchar *filename = NULL;
  IGRchar *cat_no = NULL;
  IGRchar *item_no = NULL;
  IGRchar *child_no = NULL;
  IGRchar *attached_value = NULL;
  IGRchar *file_value = NULL;
  IGRchar **parts = NULL;
  struct GRid        *part_ids = NULL;
  struct GRid        refid;
  struct PDUref_node *head = NULL;
  struct PDUref_node *temp = NULL;
  struct PDUref_node *buffer_files = NULL;
  struct PDUref_node *tail = NULL;
  struct PDUref_node *top = NULL;
  extern struct PDUref_node *PDU_ref_filenames;
  MEMptr delete_list = NULL;
  extern MEMptr PDU_detach_buffer;

  _pdm_debug("pdmoDetachPart", 0);
     
 status = co$part_get_attr(msg = &msg, 
                           mod_env = spr_mod_env,
                           part = spr_part, 
                           attr = "attach_flag", value = attr_value, 
                           type = &type);
  if (msg != MSSUCC)
    return(PDM_E_INVALID_PART_POINTER);
  else if (strcmp(attr_value, "") == 0)
     return(PDM_E_INVALID_PART_POINTER);

  sscanf(attr_value, "%d", &refid.objid);
  refid.osnum = spr_mod_env->md_id.osnum;
  dp$display(msg = &status, oids = spr_part, mode = GRbe);
  status = om$send(msg = message GRgraphics.GRdelete(&msg, spr_mod_env),
                   senderid = spr_mod_env->md_id.objid,
                   targetid = refid.objid, 
                   targetos = refid.osnum);
  if (!(status & msg & 1))
    return(PDM_E_DETACH_PART);

  /*objects[0].obj_id.objid = refid.objid;
  objects[0].obj_id.osnum = refid.osnum;
  objects[0].obj_id.mod_env = *spr_mod_env;*/
  
  /* extract catalog from object space */
  status = co$part_get_attr(msg = &msg, 
                            mod_env = spr_mod_env,
                            part = spr_part, 
                            attr = "CATALOG", value = attr_value, 
                            type = &type);
  if (msg != MSSUCC)
    return(PDM_E_INVALID_PART_POINTER);
  else if (strcmp(attr_value, "") == 0)
     return(PDM_E_INVALID_PART_POINTER);
   PDUfill_in_string(&catalog, attr_value);

  /* extract part number from object space */
  status = co$part_get_attr(msg = &msg, 
                            mod_env = spr_mod_env,
                            part = spr_part, 
                            attr = "NUMBER", value = attr_value, 
                            type = &type);
  if (msg != MSSUCC)
    return(PDM_E_INVALID_PART_POINTER);
  else if (strcmp(attr_value, "") == 0)
    return(PDM_E_INVALID_PART_POINTER);
  PDUfill_in_string(&number, attr_value);

  /* extract part revision from object space */
  status = co$part_get_attr(msg = &msg, 
                            mod_env = spr_mod_env,
                            part = spr_part, 
                            attr = "REVISION", value = attr_value, 
                            type = &type);
  if (msg != MSSUCC)
    return(PDM_E_INVALID_PART_POINTER);
  else if (strcmp(attr_value, "") == 0)
    return(PDM_E_INVALID_PART_POINTER);
  PDUfill_in_string(&revision, attr_value);

  /* extract part child no from object space */
  status = co$part_get_attr(msg = &msg, 
                            mod_env = spr_mod_env,
                            part = spr_part, 
                            attr = "child_no", value = attr_value, 
                            type = &type);
  if (msg != MSSUCC)
    return(PDM_E_INVALID_PART_POINTER);
  else if (strcmp(attr_value, "") == 0)
    return(PDM_E_INVALID_PART_POINTER);
  PDUunquote(attr_value);
  PDUfill_in_string(&child_no, attr_value);

  /* construct path to part directory */
  di$give_pathname(osnum = spr_mod_env->md_id.osnum, pathname = part_dir);
  sprintf(s, "%s:parts:%s:%s!%s:", part_dir, catalog, number, revision);
  _pdm_debug("full path = <%s>", s);

  /* check to see if part is attached in another occurrence */
  status = PDUget_GRparts_ids(s, &part_ids, &count);
  _pdm_status("PDUget_GRparts_ids", status);

  if (count <= 0)
    return(PDM_E_NO_PARTS_IN_OS);

  if (count > 0)
    {
    /* Open PDU_detach_buffer if necessary */
    if (PDU_detach_buffer == NULL)
      PDMopen_buffer(7, &PDU_detach_buffer);

    /* open delete buffer */
    PDMopen_buffer(7, &delete_list);

    /* loop thru extracting attachment flag */
    for (i = 0; i < count; i++)
      {
      if ((spr_part->objid == part_ids[i].objid) &&
          (spr_part->osnum == part_ids[i].osnum))
        continue;
      co$part_get_attr(msg = &msg, 
                       mod_env = spr_mod_env, 
                       part = &part_ids[i], 
                       attr = "attach_flag", 
                       value = attr_value, 
                       type = &type);
     if ((strcmp(attr_value, "-1.000000") != 0) &&  
         (strcmp(attr_value, "-2.000000") != 0))
       {
       _pdm_debug("part is attached in another occurrence", 0);
       MEMclose(&PDU_detach_buffer);
       PDU_detach_buffer = NULL;
       return(PDM_S_SUCCESS);
       }
      }
    /* Get list of all attached reference files */
    status = PDUget_all_ref_file_names(spr_mod_env);
    _pdm_status("PDUget_all_ref_file_names", status);

    /* extract part filename */
    strcpy(part_path, part_dir); 
    strcat(part_path, ":ASSEMBLY:P");
    strcat(part_path, child_no);
    _pdm_debug("part_path = <%s>", part_path);

/* ALR  6/32/94  Too many parameters */
/*
    PDUevaluate_exp(part_path, "file_name", &filename, 
                    spr_mod_env->md_id.osnum);
*/
    PDUevaluate_exp(part_path, "file_name", &filename);

    /* check to see if parent needs to be added to delete list */
    file_found = FALSE;
    head = PDU_ref_filenames;

    while (head)
      {
      if (strcmp(head->filename, filename) == 0)
        {
        file_found = TRUE;
        break;
        }
      head = head->next;
      }
      
    if (!file_found)
      {
      /* extract part catalog no */
/* ALR  6/32/94  Too many parameters */
/*
      status = PDUevaluate_exp(part_path, "catalog_no", &cat_no, 
                               spr_mod_env->md_id.osnum);
*/
      status = PDUevaluate_exp(part_path, "catalog_no", &cat_no);
      _pdm_status("PDUevalauate_exp", status);

      /* extract part item no */
/* ALR  6/32/94  Too many parameters */
/*
      status = PDUevaluate_exp(part_path, "item_no", &item_no, 
                                spr_mod_env->md_id.osnum);
*/
      status = PDUevaluate_exp(part_path, "item_no", &item_no);
      _pdm_status("PDUevaluate_exp", status);

      status = PDUload_local_file_buffer(cat_no, item_no, catalog, number, 
                                         revision, filename, &delete_list);
      _pdm_status("PDUload_local_file_buffer", status);

      status = PDUload_local_file_buffer(cat_no, item_no, catalog, number, 
                                         revision, filename, 
                                         &PDU_detach_buffer);
      _pdm_status("PDUload_local_file_buffer", status);
      
      /* create a node with buffer unique file information */
      temp = (struct PDUref_node *)malloc(sizeof(struct PDUref_node));
      temp->filename = NULL;
      temp->next = NULL;
      PDUfill_in_string(&(temp->filename), filename);
       
      /* Add file nod to end of unique file list */
      if (buffer_files)
        {
        /* Add to end of list */
        tail = buffer_files;
        while (tail->next)
          {
          tail = tail->next;
          }
        tail->next = temp;
        }
      else
        {
        /* First node in the linklist */
        buffer_files = temp;
        }
      }
      /* extract part's children entries from assembly structure */
      strcpy(assy_path, part_dir); 
      strcat(assy_path, ":ASSEMBLY:P");
      strcat(assy_path, child_no);
      _pdm_debug("assy_path = <%s>", assy_path);

      status = di$find(start_dir = assy_path, regexp = "P*", lines = &parts,
                       ptr = &part_count, max_level = -1);
      if ((status == DIR_S_SUCCESS) && (part_count > 0))
        {
        _pdm_debug("Part to be detached is an assembly", 0);
        /* check to see if any of the children are attached */
        for ( i = 0; i < part_count; i++)
          {
          /* extract the attached attribute for the child */
          *((IGRchar *)strrchr(parts[i], ':')) = '\0';
/* ALR  6/32/94  Too many parameters */
/*
          status = PDUevaluate_exp(parts[i], "attached", &attached_value, 
                                   spr_mod_env->md_id.osnum);
*/
          status = PDUevaluate_exp(parts[i], "attached", &attached_value); 
          _pdm_status("PDUevaluate_exp", status);
          if (strcmp(attached_value, "Y") == 0)
            {
            _pdm_debug("A child is attached", 0);
            /* get child's filename */
/* ALR  6/32/94  Too many parameters */
/*
            status = PDUevaluate_exp(parts[i], "file_name", &file_value, 
                                     spr_mod_env->md_id.osnum);
*/
            status = PDUevaluate_exp(parts[i], "file_name", &file_value); 
            _pdm_status("PDUevaluate_exp", status);
            /* check to see if file already attached */
            file_found = FALSE;
            head = PDU_ref_filenames;
            while (head)
              {
              if (strcmp(head->filename, file_value) == 0)
                {
                file_found = TRUE;
                break;
                }
              head = head->next;
              }
            if (!file_found)
              {
              /* check to see if file is unique */
              unique_flag = TRUE;
              top = buffer_files;
              while (top)
                {
                if (strcmp(top->filename, file_value) == 0)
                  {
                  _pdm_debug("file is not unique", 0);
                  unique_flag = FALSE;
                  break;
                  } 
                top = top->next;
                }
              if (unique_flag)
                {
                /* extract child's catalog */
/* ALR  6/32/94  Too many parameters */
/*
                status = PDUevaluate_exp(parts[i], "catalog_name", &catalog, 
                                         spr_mod_env->md_id.osnum);
*/
                status = PDUevaluate_exp(parts[i], "catalog_name", &catalog); 
                _pdm_status("PDUevaluate_exp(catalog_name)", status);
                
               /* extract child's part name */
/* ALR  6/32/94  Too many parameters */
/*
               status = PDUevaluate_exp(parts[i], "part_number", &number, 
                                         spr_mod_env->md_id.osnum);
*/
               status = PDUevaluate_exp(parts[i], "part_number", &number);
               _pdm_status("PDUevaluate_exp(part_number)", status);
                
               /* extract child's revision */
/* ALR  6/32/94  Too many parameters */
/*
               status = PDUevaluate_exp(parts[i], "revision", &revision, 
                                         spr_mod_env->md_id.osnum);
*/
               status = PDUevaluate_exp(parts[i], "revision", &revision); 
               _pdm_status("PDUevaluate_exp(revision)", status);

               /* extract child's catalog no */
/* ALR  6/32/94  Too many parameters */
/*
               status = PDUevaluate_exp(parts[i], "catalog_no", &cat_no, 
                                         spr_mod_env->md_id.osnum);
*/
               status = PDUevaluate_exp(parts[i], "catalog_no", &cat_no);
               _pdm_status("PDUevaluate_exp(catalog_no)", status);

               /* extract child's item no */
/* ALR  6/32/94  Too many parameters */
/*
               status = PDUevaluate_exp(parts[i], "item_no", &cat_no, 
                                         spr_mod_env->md_id.osnum);
*/
               status = PDUevaluate_exp(parts[i], "item_no", &cat_no); 
               _pdm_status("PDUevaluate_exp(item_no)", status);

              /* load child info into file buffer */
              status = PDUload_local_file_buffer(cat_no, item_no, catalog,
                                                 number, revision, file_value,
                                                 &delete_list);
              _pdm_status("PDUload_local_file_buffer", status);

              if (status != PDM_S_SUCCESS)
                return(status);

              /* load child info in PDU_detach_buffer */
              status = PDUload_local_file_buffer(cat_no, item_no, catalog, 
                                                 number, revision, file_value, 
                                                 &PDU_detach_buffer);
              _pdm_status("PDUload_local_file_buffer", status);

              if (status != PDM_S_SUCCESS)
                return(status);
 
             /* create a node with child's unique file info */
             _pdm_debug("create temp structure", 0);
             temp = (struct PDUref_node *) malloc(sizeof(struct PDUref_node));
             
             /* initialize fields in structure */
             temp->filename = NULL;
             temp->next = NULL;
             
             /* load values into node */
             _pdm_debug("file_value = <%s>", file_value);
             PDUfill_in_string(&temp->filename, file_value);
             _pdm_debug("temp->filename = <%s>", temp->filename);
      
             /* add file node to the end of the list */
             if (buffer_files)
               {
               _pdm_debug("adding file node to end of list", 0);
               tail = buffer_files;
               while (tail->next)
                 {
                 tail = tail->next;
                 }
               tail->next = temp;
               }
             else
               {
               _pdm_debug("adding file node to top of list", 0);
               buffer_files = temp;
               }
             }
           }
         }
       _pdm_debug("End for loop", 0);
       } /* end for to loop throght children of assembly */
     }
   if (delete_list->rows > 0)
     {
     _pdm_debug("Delete files locally", 0);
     status = PDMdetach_part(delete_list);
     _pdm_status("PDMdetach_part", status);
     
     if (status != PDM_S_SUCCESS)
       {
       _pdm_debug("PDMdetach_part failed", 0);
       if (PDU_ref_filenames)
         {
         head = PDU_ref_filenames;
         while (PDU_ref_filenames)
           {
           PDU_ref_filenames = PDU_ref_filenames->next;
           free(head);
           head = PDU_ref_filenames;
           }
          }
        if (delete_list)
          {
          MEMclose(&delete_list);
          delete_list = NULL;
          }
        if (PDU_detach_buffer)
          {
          MEMclose(&PDU_detach_buffer);
          PDU_detach_buffer = NULL;
          }
        if (parts)
          di$free(lines = parts, count = part_count);
        if (buffer_files)
          {
          head = buffer_files;
          while (buffer_files)
            {
            buffer_files = buffer_files->next;
            free(head);
            head = buffer_files;
            }
           }
         if ((file_value) && (strcmp(file_value, "") != 0))
           free(file_value);
         if ((filename) && (strcmp(filename, "") != 0))
           free(filename);
         if ((attached_value) && (strcmp(attached_value, "") != 0))
           free(attached_value);
         if ((catalog) && (strcmp(catalog, "") != 0))
           free(catalog);
         if ((number) && (strcmp(number, "") != 0))
           free(number);
         if ((revision) && (strcmp(revision, "") != 0))
           free(revision);
         if ((item_no) && (strcmp(item_no, "") != 0))
           free(item_no);
         if ((cat_no) && (strcmp(cat_no, "") != 0))
           free(cat_no);
         return(status);
         } 
       }
     }
   if (PDU_ref_filenames)
     {
     head = PDU_ref_filenames;
     while (PDU_ref_filenames)
       {
       PDU_ref_filenames = PDU_ref_filenames->next;
       free(head);
       head = PDU_ref_filenames;
       }
     }
   if (delete_list)
     {
     MEMclose(&delete_list);
     delete_list = NULL;
     }
   if (PDU_detach_buffer)
     {
     MEMclose(&PDU_detach_buffer);
     PDU_detach_buffer = NULL;
     }
   if (parts)
     di$free(lines = parts, count = part_count);
   if (buffer_files)
     {
      head = buffer_files;
      while (buffer_files)
        {
        buffer_files = buffer_files->next;
        free(head);
        head = buffer_files;
        }
     }
   if ((file_value) && (strcmp(file_value, "") != 0))
     free(file_value);
   if ((filename) && (strcmp(filename, "") != 0))
     free(filename);
   if ((attached_value) && (strcmp(attached_value, "") != 0))
     free(attached_value);
   if ((catalog) && (strcmp(catalog, "") != 0))
     free(catalog);
   if ((number) && (strcmp(number, "") != 0))
     free(number);
   if ((revision) && (strcmp(revision, "") != 0))
     free(revision);
   if ((item_no) && (strcmp(item_no, "") != 0))
     free(item_no);
   if ((cat_no) && (strcmp(cat_no, "") != 0))
     free(cat_no);
    return(PDM_S_SUCCESS);
   }

IGRlong pdmoDetachParametricPart(spr_mod_env, spr_part)
  struct GRmd_env *spr_mod_env;  /* Input: Module information */
  struct GRid     *spr_part;     /* Input: Object ID of part to be deleted */

  {
  IGRlong status;
  IGRint  i;
  IGRint  j;
  IGRint  count = 0;
  IGRint  filename_col;
  IGRint  max_rows;
  IGRint  err_code;
  IGRshort last_occurrence;
  IGRchar dir_name[DI_PATH_MAX];
  IGRchar s[DI_PATH_MAX];
  IGRchar entry[DI_PATH_MAX];
  IGRchar query[256];
  IGRchar *filename= NULL;
  IGRchar *filename1= NULL;
  IGRchar *ptr= NULL;
  IGRchar *file_str= NULL;
  IGRchar *file_str1= NULL;
  IGRchar *output_str= NULL;
  IGRchar *macrocat= NULL;
  IGRchar *macropart= NULL;
  IGRchar *macrorev= NULL;
  IGRchar *params[3];
  IGRchar **param_vals = NULL;
  IGRchar **file_data = NULL;
  IGRchar **entries = NULL;
  struct  PDUcat_node *param_cat_list = NULL;
  struct  PDUcat_node *head = NULL;
  struct  PDUcat_node *tmp = NULL;
  struct  stat        file_status;
  struct  stat        buf;
  extern struct PDUstorage *storage;
  FILE    *infile = NULL;
  MEMptr  local_files = NULL;
  extern MEMptr  PDU_detach_macro_lib;

  _pdm_debug("In pdmoDetachParametricPart", 0);
  /* extract part info */
  param_vals = NULL;
  params[0] = "n_catalogname";
  params[1] = "n_itemname";
  params[2] = "n_itemrev";
  
  status = get_parameter_values(spr_part, params, 3, &param_vals);
  _pdm_status("get_parameter_values", status);

  if (!status)
    return(PDM_E_INVALID_PARAMETRIC_PART);
  /* load param catalog list */
  param_cat_list = NULL;
  status = PDUprepare_param_cats_list(spr_mod_env, &param_cat_list);
  _pdm_status("PDUprepare_param_cats_list", status);
   
  if (status != PDM_S_SUCCESS)
    return(status);
  /* delete localted part's catalog from param_cat_list */
  last_occurrence = FALSE;
  head = param_cat_list;
  if (head)
    tmp = head->next;
  while (head)
    {
    if (strcmp(param_cat_list->catalog, param_vals[0]) == 0)
      {
      if (param_cat_list->count == 1)
        {
        /* last occurrence */
        _pdm_debug("last parametric part occurrence", 0);
        last_occurrence = TRUE;
        /* delete node */
        if (param_cat_list->next == NULL)
          {
          free(param_cat_list);
          param_cat_list = NULL;
          }
        else
          {
          tmp = param_cat_list;
          param_cat_list = param_cat_list->next;
          free(tmp);
          }
       }
     break;
     }
   else
     {
     if (tmp)
       {
       if (strcmp(tmp->catalog, param_vals[0]) == 0)
         {
         if (tmp->count == 1)
           {
           /* flag last parametric part occurrence */
           last_occurrence = TRUE;
           /* delete node */
           head->next = tmp->next;
           free(tmp);
           }
         break;
         }
       }
     else
       break;
     }
    /* process next node */
    head = head->next;
    tmp = tmp->next;
    } /* end while loop */
  if (last_occurrence)
    {
    /* cleanup macro tag directory */
    status = di$give_pathname(osnum = spr_mod_env->md_id.osnum,
                              pathname = dir_name);
    strcat(dir_name,":PDU:mac_tag_no");
    sprintf(s,"!%s!%s!%s", param_vals[0], param_vals[1], param_vals[2]);
    status = di$find(start_dir = dir_name, regexp = "*", lines = &entries, 
                     max_level = 1, ptr = &count);
    if (status != DIR_S_SUCCESS)
      return(PDM_E_DIR_ACCESS);
    if (count > 0)
      {
      for (i = 0; i < count; i++)
        {
        strcpy(entry, entries[i]);
        PDUstrip_dir_entry(entry);
        *((char *)strrchr(entry, '!')) = '\0';
        ptr = (char *)strchr(entry, '!');
        if (strcmp(s, ptr) == 0)
          {
          status = PDUrmdir(entries[i]);
          _pdm_status("PDUrmdir", status);
          break;
          }
        }
      if (entries)
        di$free(lines = entries, count = count);
      }
    status = PDMdetach_macro_library(param_vals[0], param_cat_list, 
                                     &local_files);
    _pdm_status("PDMdetach_macro_library", status);
    
    if (status != PDM_S_SUCCESS)
      {
      _pdm_debug("PDMdetach_macro_library failed", 0);
      /* free up param_cat_list */
      if (param_cat_list)
        {
        head = param_cat_list;
        while (param_cat_list)
          {
          param_cat_list = param_cat_list->next;
          if (head->catalog)
            free(head->catalog);
          free(head);
          head = param_cat_list;
          }
        }
      if (param_vals)
        {
        for ( j = 0; j < 3; j = j++)
          free(param_vals[j]);
        free(param_vals);
        }
      return(status);
      }
    else if ((local_files) && (local_files->rows > 0))
      {
      _pdm_debug("file(s) needed to be removed locally", 0);
      status = MEMbuild_array(local_files);
      _pdm_status("MEMbuild_array", status);
      if (status != MEM_S_SUCCESS)
        return(PDM_E_BUILD_BUFFER_ARRAY);
      PDUget_buffer_col(local_files, "n_cofilename", &filename_col);
      file_data = (char **)local_files->data_ptr;
      for ( i = 0; i < local_files->rows; i ++)
        {
        PDUfill_in_string(&filename, file_data[(local_files->columns * i) +
                          filename_col]);
        /* check for cpio files */
        file_str = (char *)malloc(strlen(storage->path_name) +
                                  strlen(filename) + 3);
        strcpy(file_str, "");
        sprintf(file_str, "%s/%s%s",storage->path_name,".", filename);
        status = stat(file_str, &file_status);
        if (status == 0)
          {
          _pdm_debug("deleting cpio files", 0);
          status = stat(file_str, &buf);
          if (buf.st_size == 0)
            {
            _pdm_debug("file has a size of 0", 0);
            continue;
            }
          if ((infile = fopen(file_str, "r")) == NULL)
            continue;
          while (status == PDM_S_SUCCESS)
            {
            status = PDUread_refresh_file(&filename1, file_str, infile);
            if (status != PDM_S_SUCCESS)
              {
              fclose(infile);
              break;
              }
            file_str1 = (char *)malloc(strlen(storage->path_name) +
                                      strlen(filename1) + 2);
            strcpy(file_str1, "");
            sprintf(file_str1, "%s/%s", storage->path_name, filename1);
            _pdm_debug("delete file  <%s> locally", file_str1);
            status = stat(file_str1, &file_status);
            if (status == 0)
              {
              unlink(file_str);
              status = pdmoDeleteMacroLibraryEntry(spr_mod_env->md_id.osnum, 
                                                   filename1);
              }
            status = PDM_S_SUCCESS;
            }
          status = unlink(file_str);
          pdmoDeleteMacroLibraryEntry(spr_mod_env->md_id.osnum, filename);
          }
        _pdm_debug("deleting non cpio files", 0);
        sprintf(file_str, "%s/%s", storage->path_name, filename);
        status = stat(file_str, &file_status);
        if (status == 0)
          {
          /* delete the file locally */
          status = unlink(file_str);
          status = pdmoDeleteMacroLibraryEntry(spr_mod_env->md_id.osnum, 
                                               filename);
          }
        } /* end for loop to delete files */
      /* get macro library partnumber and revision from the database */
      sprintf(query, "select p_macrocat, p_macropartno, p_macrorev from pdmparamloc where n_catalogname = '%s'", param_vals[0]);
      status = RISquery(query, &max_rows, &output_str, &err_code);
      if (status < 0)
        return(PDM_E_LIBRARY_NOT_FOUND);
 
      /* extract macro catalog */
      ptr = (char *)strtok(output_str,"~");
      macrocat = (char *)malloc(strlen(ptr) + 1);
      strcpy(macrocat, ptr);

      /* extract macro partnumber */
      ptr = (char *)strtok(output_str,"~");
      macropart = (char *)malloc(strlen(ptr) + 1);
      strcpy(macropart, ptr);

      /* extract macro partrev */
      ptr = (char *)strtok(output_str,"~");
      macrorev = (char *)malloc(strlen(ptr) + 1);
      strcpy(macrorev, ptr);

      /* record macro library being detached */
      status = PDUload_macrolibrary_copy_buffer(macrocat, macropart, macrorev,
                                                 &PDU_detach_macro_lib);
      _pdm_status("PDUload_macrolibrary_copy_buffer", status);
      if (status != PDM_S_SUCCESS)
        return(status);
      
      PDUupdate_copy_macro_lib_bufr(param_vals[0]);
      }
    }     
  /* free up param_cat_list */
  if (param_cat_list)
    {
    head = param_cat_list;
    while (param_cat_list)
      {
      param_cat_list = param_cat_list->next;
      if (head->catalog)
        free(head->catalog);
      free(head);
      head = param_cat_list;
      }
    }

  if (param_vals)
    {
    for ( j = 0; j < 3; j++)
      free(param_vals[j]);
    free(param_vals);
    }

  if (local_files)
    MEMclose(&local_files);
  if ((macrocat) && (strcmp(macrocat, "") != 0))
    free(macrocat);
  if ((macropart) && (strcmp(macropart, "") != 0))
    free(macropart);
  if ((macrorev) && (strcmp(macrorev, "") != 0))
    free(macrorev);
  if ((filename) && (strcmp(filename, "") != 0))
    free(filename);
  if ((filename1) && (strcmp(filename1, "") != 0))
    free(filename1);
  return (PDM_S_SUCCESS);
  }

IGRlong  pdmoGetPartidGivenUsageid(cpr_usageid, spr_mod_env, spw_part)

 IGRchar *cpr_usageid;		
 struct  GRmd_env  *spr_mod_env;
 struct  GRid      *spw_part;
 {
  IGRlong    status = PDM_S_SUCCESS;
  IGRlong    msg;
  IGRlong NumberOfBytes;
  IGRlong BytesReceived;
  IGRshort free_mod = FALSE;
  IGRint     count = 0;
  IGRint     type;
  IGRchar    attr_value[MAX_VALUE];
  IGRchar    **params = NULL;
  IGRchar    **param_vals = NULL;
  struct     PDUpart_node      *part_ids = NULL;
  struct     PDUpart_node      *parametric_ids = NULL;
  struct     PDUpart_node      *head = NULL;

 
  _pdm_debug("In the pdmoGetPartidGivenUsageid function", 0);

  if (cpr_usageid == NULL)
    return(PDM_E_NULL_USAGEID);
  else if (strcmp(cpr_usageid, "") == 0)
    return(PDM_E_NULL_USAGEID);

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

  /* Check for usage id across GRparts */
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
    _pdm_debug("getting usageid value", 0);
    co$part_get_attr(msg = &msg, mod_env = spr_mod_env, part = &(head->part_id),
                     attr = "usage_id", value = attr_value, type = &type);
    _pdm_debug("after getting usageid", 0);

    /* Unqoute usage id */
    PDUunquote(attr_value);
    _pdm_debug("attr_value = <%s>", attr_value);
    if (strcmp(attr_value, cpr_usageid) == 0)
      {
      _pdm_debug("Usageid was found", 0);
      if (spw_part == NULL)
        spw_part = (struct GRid *)malloc(sizeof(struct GRid));
          
      spw_part->objid = head->part_id.objid;
      spw_part->osnum = head->part_id.osnum;
      _pdm_debug("spw_part->objid = <%d>", spw_part->objid);
      _pdm_debug("spw_part->osnum = <%d>", spw_part->osnum);
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
      return(PDM_S_SUCCESS);
      }
    head = head->next;
    } /* end while loop */

  /* Check for usage id across parametric parts */
  status = PDUget_all_parametric_ids(
                                     spr_mod_env->md_id.osnum,
                                     &parametric_ids,
                                     &count
                                    );
  _pdm_status("PDUget_all_parametric_ids", status);

  _pdm_debug("count = <%d>", count);
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
      return(-1);
      }
    if (strcmp(param_vals[0], cpr_usageid) == 0)
      {
      _pdm_debug("usage id <%s> found", cpr_usageid);
      /* Free parametric_ids */
      if (spw_part == NULL)
        spw_part = (struct GRid *)malloc(sizeof(struct GRid));
          
      spw_part->objid = head->part_id.objid;
      spw_part->osnum = head->part_id.osnum;
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
       return (PDM_S_SUCCESS);
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

   if (free_mod)
     {
     free(spr_mod_env);
     spr_mod_env = NULL;
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
     
  return(PDM_E_USAGEID_NOT_FOUND);
 }

IGRlong pdmoCleanupMacroLibraryAttachment(spr_mod_env, catalog, partnum,
                                          revision)
  struct GRmd_env *spr_mod_env;  /* Input: Module information */
  char *catalog;
  char *partnum;
  char *revision;
  {
  IGRlong status;
  IGRint  i;
  IGRint  j;
  IGRint  count = 0;
  IGRint  filename_col;
  IGRint  max_rows;
  IGRint  err_code;
  IGRshort last_occurrence;
  IGRchar dir_name[DI_PATH_MAX];
  IGRchar s[DI_PATH_MAX];
  IGRchar entry[DI_PATH_MAX];
  IGRchar query[256];
  IGRchar *filename= NULL;
  IGRchar *filename1= NULL;
  IGRchar *ptr= NULL;
  IGRchar *file_str= NULL;
  IGRchar *file_str1= NULL;
  IGRchar *output_str= NULL;
  IGRchar *macrocat= NULL;
  IGRchar *macropart= NULL;
  IGRchar *macrorev= NULL;
  IGRchar **file_data = NULL;
  IGRchar **entries = NULL;
  struct  PDUcat_node *param_cat_list = NULL;
  struct  PDUcat_node *head = NULL;
  struct  PDUcat_node *tmp = NULL;
  struct  stat        file_status;
  struct  stat        buf;
  extern struct PDUstorage *storage;
  FILE    *infile = NULL;
  MEMptr  local_files = NULL;
  extern MEMptr  PDU_detach_macro_lib;

  _pdm_debug("In pdmoCleanupMacroLibraryAttachment", 0);
  /* extract part info */
  /* load param catalog list */
  param_cat_list = NULL;
  status = PDUprepare_param_cats_list(spr_mod_env, &param_cat_list);
  _pdm_status("PDUprepare_param_cats_list", status);
   
  if (status != PDM_S_SUCCESS)
    return(status);
  /* delete localted part's catalog from param_cat_list */
  last_occurrence = FALSE;
  head = param_cat_list;
  if (head)
    tmp = head->next;
  while (head)
    {
    if (strcmp(param_cat_list->catalog, catalog) == 0)
      {
      if (param_cat_list->count == 1)
        {
        /* last occurrence */
        _pdm_debug("last parametric part occurrence", 0);
        last_occurrence = TRUE;
        /* delete node */
        if (param_cat_list->next == NULL)
          {
          free(param_cat_list);
          param_cat_list = NULL;
          }
        else
          {
          tmp = param_cat_list;
          param_cat_list = param_cat_list->next;
          free(tmp);
          }
       }
     break;
     }
   else
     {
     if (tmp)
       {
       if (strcmp(tmp->catalog, catalog) == 0)
         {
         if (tmp->count == 1)
           {
           /* flag last parametric part occurrence */
           last_occurrence = TRUE;
           /* delete node */
           head->next = tmp->next;
           free(tmp);
           }
         break;
         }
       }
     else
       break;
     }
    /* process next node */
    head = head->next;
    tmp = tmp->next;
    } /* end while loop */
  if (last_occurrence)
    {
    /* cleanup macro tag directory */
    status = di$give_pathname(osnum = spr_mod_env->md_id.osnum,
                              pathname = dir_name);
    strcat(dir_name,":PDU:mac_tag_no");
    sprintf(s,"!%s!%s!%s", catalog, partnum, revision);
    status = di$find(start_dir = dir_name, regexp = "*", lines = &entries, 
                     max_level = 1, ptr = &count);
    if (status != DIR_S_SUCCESS)
      return(PDM_E_DIR_ACCESS);
    if (count > 0)
      {
      for (i = 0; i < count; i++)
        {
        strcpy(entry, entries[i]);
        PDUstrip_dir_entry(entry);
        *((char *)strrchr(entry, '!')) = '\0';
        ptr = (char *)strchr(entry, '!');
        if (strcmp(s, ptr) == 0)
          {
          status = PDUrmdir(entries[i]);
          _pdm_status("PDUrmdir", status);
          break;
          }
        }
      if (entries)
        di$free(lines = entries, count = count);
      }
    status = PDMdetach_macro_library(catalog, param_cat_list, 
                                     &local_files);
    _pdm_status("PDMdetach_macro_library", status);
    
    if (status != PDM_S_SUCCESS)
      {
      _pdm_debug("PDMdetach_macro_library failed", 0);
      /* free up param_cat_list */
      if (param_cat_list)
        {
        head = param_cat_list;
        while (param_cat_list)
          {
          param_cat_list = param_cat_list->next;
          if (head->catalog)
            free(head->catalog);
          free(head);
          head = param_cat_list;
          }
        }
      }
    else if ((local_files) && (local_files->rows > 0))
      {
      _pdm_debug("file(s) needed to be removed locally", 0);
      status = MEMbuild_array(local_files);
      _pdm_status("MEMbuild_array", status);
      if (status != MEM_S_SUCCESS)
        return(PDM_E_BUILD_BUFFER_ARRAY);
      PDUget_buffer_col(local_files, "n_cofilename", &filename_col);
      file_data = (char **)local_files->data_ptr;
      for ( i = 0; i < local_files->rows; i ++)
        {
        PDUfill_in_string(&filename, file_data[(local_files->columns * i) +
                          filename_col]);
        /* check for cpio files */
        file_str = (char *)malloc(strlen(storage->path_name) +
                                  strlen(filename) + 3);
        strcpy(file_str, "");
        sprintf(file_str, "%s/%s%s",storage->path_name,".", filename);
        status = stat(file_str, &file_status);
        if (status == 0)
          {
          _pdm_debug("deleting cpio files", 0);
          status = stat(file_str, &buf);
          if (buf.st_size == 0)
            {
            _pdm_debug("file has a size of 0", 0);
            continue;
            }
          if ((infile = fopen(file_str, "r")) == NULL)
            continue;
          while (status == PDM_S_SUCCESS)
            {
            status = PDUread_refresh_file(&filename1, file_str, infile);
            if (status != PDM_S_SUCCESS)
              {
              fclose(infile);
              break;
              }
            file_str1 = (char *)malloc(strlen(storage->path_name) +
                                      strlen(filename1) + 2);
            strcpy(file_str1, "");
            sprintf(file_str1, "%s/%s", storage->path_name, filename1);
            _pdm_debug("delete file  <%s> locally", file_str1);
            status = stat(file_str1, &file_status);
            if (status == 0)
              {
              unlink(file_str);
              status = pdmoDeleteMacroLibraryEntry(spr_mod_env->md_id.osnum, 
                                                   filename1);
              }
            status = PDM_S_SUCCESS;
            }
          status = unlink(file_str);
          pdmoDeleteMacroLibraryEntry(spr_mod_env->md_id.osnum, filename);
          }
        _pdm_debug("deleting non cpio files", 0);
        sprintf(file_str, "%s/%s", storage->path_name, filename);
        status = stat(file_str, &file_status);
        if (status == 0)
          {
          /* delete the file locally */
          status = unlink(file_str);
          status = pdmoDeleteMacroLibraryEntry(spr_mod_env->md_id.osnum, 
                                               filename);
          }
        } /* end for loop to delete files */
      /* get macro library partnumber and revision from the database */
      sprintf(query, "select p_macrocat, p_macropartno, p_macrorev from pdmparamloc where n_catalogname = '%s'", catalog);
      status = RISquery(query, &max_rows, &output_str, &err_code);
      if (status < 0)
        return(PDM_E_LIBRARY_NOT_FOUND);
 
      /* extract macro catalog */
      ptr = (char *)strtok(output_str,"~");
      macrocat = (char *)malloc(strlen(ptr) + 1);
      strcpy(macrocat, ptr);

      /* extract macro partnumber */
      ptr = (char *)strtok(output_str,"~");
      macropart = (char *)malloc(strlen(ptr) + 1);
      strcpy(macropart, ptr);

      /* extract macro partrev */
      ptr = (char *)strtok(output_str,"~");
      macrorev = (char *)malloc(strlen(ptr) + 1);
      strcpy(macrorev, ptr);

      /* record macro library being detached */
      status = PDUload_macrolibrary_copy_buffer(macrocat, macropart, macrorev,
                                                 &PDU_detach_macro_lib);
      _pdm_status("PDUload_macrolibrary_copy_buffer", status);
      if (status != PDM_S_SUCCESS)
        return(status);
      
      PDUupdate_copy_macro_lib_bufr(catalog);
      }
    }     
  /* free up param_cat_list */
  if (param_cat_list)
    {
    head = param_cat_list;
    while (param_cat_list)
      {
      param_cat_list = param_cat_list->next;
      if (head->catalog)
        free(head->catalog);
      free(head);
      head = param_cat_list;
      }
    }

  if (local_files)
    MEMclose(&local_files);
  if ((macrocat) && (strcmp(macrocat, "") != 0))
    free(macrocat);
  if ((macropart) && (strcmp(macropart, "") != 0))
    free(macropart);
  if ((macrorev) && (strcmp(macrorev, "") != 0))
    free(macrorev);
  if ((filename) && (strcmp(filename, "") != 0))
    free(filename);
  if ((filename1) && (strcmp(filename1, "") != 0))
    free(filename1);
  return (PDM_S_SUCCESS);
  }
end implementation COpdu; 
