class implementation COpdu;
/*
   This file contains all functions for creating and manipulating the  
   assembly display structure. 

   Author: Jamal Shakra
   Date: 9-2-93 
*/

/* Include file section */
#include        "stdio.h"
#include        "OMlimits.h"
#include        "unistd.h"
#include        "DIdef.h"
#include        "DItypedef.h"
#include        "DIprims.h"
#include        "DIglob.h"
#include        "PDUerror.h"
#include        "PDUstr.h"
#include        "PDUintdef.h"
#include        "PDUpart.h"
#include        "msdef.h"
#include        "godef.h"
#include        "igrdp.h"
#include        "partmacros.h"
#include        "part.h"
#include        "partdef.h"
#include        "string.h"
#include        "dpmacros.h"
#include        "grdpbmacros.h"
#include        "OMindex.h"
#include        "OMtypes.h"
#include        "MEMstruct.h"
#include        "MEMerrordef.h"
#include        "comnmacros.h"
#include        "ctype.h"
#include        "PDUuser.h"
#include        "PDUfile_def.h"
#include        "PDUgrpart.h"
#include        "PDUnode.h"
#include        "refdef.h"
#include        "referr.h"
#include        "ref.h"
#include        "exmacros.h"
#include        "grmacros.h"
#include        "PDUforms.h"
#include        "FI.h"


/* Global external variables */
extern  OMuword  OPP_GRpart_class_id;
extern  OMuword  OPP_GRcontext_class_id;
extern  OMuword  OPP_GRdvattach_class_id;
extern  int      PDMdebug_on;
extern struct PDUref_info_node   *PDU_ref_parent_child_list;
extern struct PDUpath_list       *PDU_part_path_list;
extern char *PDU_filename;
extern struct PDUforms forms;

/* Imported messages */
from  GRreffile   import       GRrfload;
from  GRreffile   import       GRrfunload;
from  GRreffile   import       GRrfclose;
from  GRreffile   import       GRchgrfprops;
from  GRreffile   import       GRgetrfprops;
from  GRreffile   import       GRgetdescription;
from  GRgraphics  import       GRgetprops;
from  GRgraphics  import       GRchgprops;
from  GRgraphics  import       GRconstruct;

/*
 * This function updates the loaded attribute in the assembly structure. 
 */

IGRint  PDUupdate_load_in_assembly(mod_env)

 struct GRmd_env  *mod_env;             /* INPUT */

 {
  IGRlong        status = PDM_S_SUCCESS;
  IGRchar        assy_path[DI_PATH_MAX];
  IGRchar        **parts = NULL;
  IGRint         part_count = 0;
  IGRchar        *entry = NULL;
  IGRchar        *attached = NULL;
  IGRchar        *delete_flag = NULL;
  IGRchar        *part_type = NULL;
  IGRint         i;
  IGRshort       free_mod = FALSE;
  IGRint         bufsiz;

  _pdm_debug("In the PDUupdate_load_in_assembly function", 0);

  /* Default module env. to current if mod_env is NULL */
  if (!mod_env)
     {
      mod_env = (struct GRmd_env *) malloc(sizeof(struct GRmd_env));
      bufsiz = sizeof(struct GRmd_env);
      gr$get_module_env(sizbuf = &bufsiz, buffer = mod_env);
      free_mod = TRUE;
     }

  /* Construct path to assembly structure */
  di$give_pathname(
                   osnum = mod_env->md_id.osnum,
                   pathname = assy_path
                  );

  strcat(assy_path, ":ASSEMBLY");

  /* Extract list of DIrectory objects from given assembly path */
  status = di$find (
                    start_dir = assy_path,
                    regexp = "P*",
                    lines = &parts,
                    ptr = &part_count,
                    max_level = -1 
                   );

  _pdm_debug("part_count = %d", (char *)part_count);

  if (part_count == 0)
     {
      _pdm_debug("no parts found to update load structure", 0);
     
      /* Free up space */
      if (free_mod)
         {
          free(mod_env);
          mod_env = NULL;
         }

      return(PDM_S_SUCCESS);
     }

  /* Update the loaded attribute for each part in assembly */
  for (i = 0; i < part_count; ++i)
      {
       /* Drop last ":" from entry */
       _pdm_debug("parts[i] = <%s>", parts[i]);

       PDUfill_in_string(&entry, parts[i]);

       PDUstrip_dir_entry(entry);

       /* Extract value for part delete_flag attr. */
       status = PDUevaluate_exp(
                                entry,
                                "delete_flag",
                                &delete_flag
                               );

       if (status != PDM_S_SUCCESS)
          {
           _pdm_debug("could not evaluate delete flag attr.", 0);
           return(0);
          }

       /* Skip parts marked for deletion */
       if (strcmp(delete_flag, "Y") == 0)
          continue;

       status = PDUevaluate_exp(
                                entry,
                                "part_type",
                                &part_type
                               );

       if (status != PDM_S_SUCCESS)
          {
           _pdm_debug("could not evaluate part_type attr.", 0);
           return(0);
          }
       _pdm_debug("part_type attr = <%s>", part_type);

       /* Skip parts marked for deletion */
       /* added checkfor part type N to prevent parents getting loaded. */
       _pdm_debug("checking part_type", 0);
       if ((strcmp(part_type, "P") == 0) || (strcmp(part_type, "p") == 0) ||
           (strcmp(part_type, "N") == 0) || (strcmp(part_type, "n") == 0))
         {
         _pdm_debug("part is either non-graphic or parametric; continue", 0);
         continue;
         }

       /* Set loaded attr. to "N" initially. */
       _pdm_debug("initializing loaded attr to N", 0);
       PDUmodify_exp(
                     0,
                     entry,
                     "loaded",
                     "N",
                     mod_env->md_id.osnum
                    );

       /* Extract value for part attached attr. */
       status = PDUevaluate_exp(
                                entry,
                                "attached",
                                &attached
                               );

       if (status != PDM_S_SUCCESS)

          {
           _pdm_debug("could not evaluate attached attr.", 0);
           return(0);
          }

       if (strcmp(attached, "N") != 0)
          {
          _pdm_debug("modifying loaded attr", 0);
          _pdm_debug("attached = <%s>", attached);
          _pdm_debug("delete_flag = <%s>", delete_flag);
          _pdm_debug("part_type = <%s>", part_type);

           /* Modify the loaded attribute to "Y" */
           PDUmodify_exp(
                         0,
                         entry,
                         "loaded",
                         "Y",
                         mod_env->md_id.osnum
                        );

           *((IGRchar *)strrchr(entry, ':')) = '\0';

           /* Make sure part parents are loaded too */
           _pdm_debug("loading parent parts", 0);
           _pdm_debug("entry = <%s>", entry);
           _pdm_debug("assy_path = <%s>", assy_path);

           while (strcmp(entry, assy_path))
                 {
                  PDUmodify_exp(
                                0,
                                entry,
                                "loaded",
                                "Y",
                                mod_env->md_id.osnum
                               );

                  *((IGRchar *)strrchr(entry, ':')) = '\0';
                 } /* end while loop */
          }

      } /* end for i loop */

  /* Free up variables */
  if (entry)
     free(entry);

  if (attached)
     free(attached);

  if (delete_flag)
     free(delete_flag);

  /* Free up parts and part_count */
  if (parts)
     {
      di$free (lines = parts, count = part_count);
     }

  if (free_mod)
     {
      free(mod_env);
      mod_env = NULL;
     }

  return(PDM_S_SUCCESS);
 }


/*
 * This function adds a node to the path list.
 */

void PDUadd_path_node(path)
   IGRchar         *path;
  {
   struct PDUpath_list         *tail = NULL;
   struct PDUpath_list         *temp = NULL;

   _pdm_debug("In the PDUadd_path_node function", 0);

   /* Create a node with path info */
   temp = (struct PDUpath_list *) malloc(sizeof(struct PDUpath_list));

   /* Initialize temp fields */
   strcpy(temp->path, path);
   temp->next = NULL;

   /* Add node to the end of PDU_part_path_list */
   if (PDU_part_path_list)
      {
       /* Get to the end of list */
       tail = PDU_part_path_list;
       while (tail->next)
             {
              tail = tail->next;
             }

       /* Add node to end of link list */
       tail->next = temp;
      }

   else
       {
        /* This is the first node in the list */
        PDU_part_path_list = temp;
       }
  }


/*
 * This function updates the reference file display behavior based on 
 * the assembly structure.
 */

IGRint  PDUupdate_part_display(mod_env)

 struct GRmd_env  *mod_env;             /* INPUT */
 
 {
  IGRlong                   status = PDM_S_SUCCESS;
  IGRlong                   msg = MSSUCC;
  IGRshort                  free_mod = FALSE;
  IGRint                    bufsiz;
  IGRchar                   assy_path[DI_PATH_MAX];
  IGRchar                   **parts = NULL;
  IGRint                    part_count = 0;
  IGRint                    i;
  IGRchar                   *loaded = NULL;
  IGRchar                   *attached = NULL;
  IGRchar                   *refid = NULL;
  IGRchar                   *delete_flag = NULL;
  IGRchar                   *level = NULL;
  IGRshort                  flag = 0;
  IGRulong                  ref_properties;
  IGRshort                  properties;
  IGRshort                  update_req = FALSE;
  struct  GRid              ref_id;
  struct  GRid              context_id;
  struct  GRid              part_id;

  extern struct PDUref_node *PDU_ref_filenames;


  _pdm_debug("In the PDUupdate_part_display function", 0);

  /* Default module env. to current if mod_env is NULL */
  if (!mod_env)
     {
      mod_env = (struct GRmd_env *) malloc(sizeof(struct GRmd_env));
      bufsiz = sizeof(struct GRmd_env);
      gr$get_module_env(sizbuf = &bufsiz, buffer = mod_env);
      free_mod = TRUE;
     }

  /* Manage display 1st_level detached parts, if any */
  status = PDUupdate_1st_level_detached_parts_display(mod_env);
  _pdm_status("PDUupdate_1st_level_detached_parts_display", status);

  /* Construct path to ASSEMBLY directory */
  di$give_pathname(
                   osnum = mod_env->md_id.osnum,
                   pathname = assy_path
                  );

  strcat(assy_path, ":ASSEMBLY");

  /* Extract part's children entries from assy. structure */
  status = di$find(
                   start_dir = assy_path,
                   regexp = "P*",
                   lines = &parts,
                   ptr = &part_count,
                   max_level = -1 
                  );

  if ( (status == DIR_S_SUCCESS) && (part_count > 0) )
     {
      for (i = 0; i < part_count; ++i)
          {
          PDUstrip_dir_entry(parts[i]);

           /* Get part delete flag attribute */
           status = PDUevaluate_exp(
                                    parts[i],
                                    "delete_flag",
                                    &delete_flag
                                   );

           _pdm_status("PDUevalute_exp delete_flag", status);

           if (status != PDM_S_SUCCESS)
              {
               _pdm_debug("could not evaluate delete flag attr.", 0);
               return(0);
              }

           /* Skip parts marked for deletion */
           _pdm_debug("delete_flag = <%s>", delete_flag);
           if (strcmp(delete_flag, "Y") == 0)
              continue;

           /* Get part loaded attribute */
           status = PDUevaluate_exp(
                                    parts[i],
                                    "loaded",
                                    &loaded
                                    );

           _pdm_status("PDUevalute_exp loaded", status);

           if (status != PDM_S_SUCCESS)
              {
               _pdm_debug("could not evaluate loaded attr.", 0);
               return(0);
              }

           /* Get part refid */
           status = PDUevaluate_exp(
                                    parts[i],
                                    "refid",
                                    &refid
                                   );

           _pdm_status("PDUevalute_exp refid", status);

           if (status != PDM_S_SUCCESS)
              {
               _pdm_debug("could not evaluate refid attr.", 0);
               return(0);
              }

           /* Get part attached attr. */
           status = PDUevaluate_exp(
                                    parts[i],
                                    "attached",
                                    &attached
                                    );

           _pdm_status("PDUevaluate_exp attached", status);
           if (status != PDM_S_SUCCESS)
              {
               _pdm_debug("could not evaluate attached attr.", 0);
               return(0);
              }

           status = PDUevaluate_exp(
                                    parts[i],
                                    "level",
                                    &level
                                    );

           _pdm_status("PDUevaluate_exp attached", status);
           if (status != PDM_S_SUCCESS)
              {
               _pdm_debug("could not evaluate attached attr.", 0);
               return(0);
              }

           /* Skip empty refids */
           if ( (strcmp(refid, "") == 0) || (strcmp(refid, "-1") == 0) )
              continue;

           /* Read ref. id. and context id. */
           if (refid)
              {
               status = PDUread_refid_string(
                                             refid,
                                             &ref_id,
                                             &context_id
                                            );
               _pdm_status("PDUrefid_string", status);

               if (status != PDM_S_SUCCESS)
                  {
                   _pdm_debug("PDUread_refid_string failed", 0);
                   return(0);
                  }

               /* Get PDU GRpart id from ref_id. */
               status = PDUget_GRpart_from_refid(
                                                 mod_env,
                                                 &ref_id,
                                                 &part_id
                                                );
               _pdm_status("PDUget_GRpart_from_refid", status);

               if (status != PDM_S_SUCCESS)
                 {
                 update_req = TRUE;
                 continue;
                 }
              }

           /* Get ref. graphic property word */
           status = om$send (
                             msg = message GRgraphics.GRgetprops
                                       (&msg, &properties),
                             senderid = NULL_OBJID,
                             targetid = ref_id.objid,
                             targetos = ref_id.osnum
                            );
           _pdm_debug("GRgraphics,GRgetprops", 0);
           if ( !(status & msg & 1) )
              {
               _pdm_debug("GRgraphics.getprops failed %d", msg);
               return(0);
              }

           /* Get ref. special property word */
           status = om$send (
                             msg = message GRreffile.GRgetrfprops
                                       (&msg, &ref_properties),
                             senderid = NULL_OBJID,
                             targetid = ref_id.objid,
                             targetos = ref_id.osnum
                            );
           _pdm_debug("GRgraphics.GRgetrfprops", 0);

           if ( !(status & msg & 1) )
              {
               _pdm_debug("GRreffile.getrfprops failed", 0);
               return(0);
              }

           if (strcmp(loaded, "N") != 0)
              {
               /* Check to see if part is already loaded in list */
               /* Reference files at the first level are getting loaded */
               /* everytime this function is called regardless of whether */
               /* it needs to be loaded or not. Do not know if this was done 
               /* because of a posible limitation I am not aware of. */
               /* if a limitation is discovered, the call may be necessary */
               /* additional checks besides level number. */
               /* Commented out for performance reasons. 5/22. JBP */
               /*if (strcmp(level, "1") == 0)
                 {
                   status = om$send (
                                     msg = message GRreffile.GRrfunload (&msg),
                                     senderid = NULL_OBJID,
                                     targetid = ref_id.objid,
                                     targetos = ref_id.osnum
                                    );
                   _pdm_debug("GRreffile.GRrfload", 0);
                 }*/
                   /* Set load bit to load */
                   flag = 2;
                   /* Load ref. attachment */
                   if (ref_properties & GRRF_UNLOADED)
                      {
                      _pdm_debug("File is not loaded", 0);
                      ref_properties &= ~GRRF_UNLOADED;
                   status = om$send (
                                     msg = message GRreffile.GRrfload (&msg),
                                     senderid = NULL_OBJID,
                                     targetid = ref_id.objid,
                                     targetos = ref_id.osnum
                                    ); 
                   _pdm_debug("GRreffile.GRrfload", 0);

                      }

                   status = om$send (
                                     msg = message GRreffile.GRchgrfprops
                                           (&msg, &flag, &ref_properties),
                                     senderid = NULL_OBJID,
                                     targetid = ref_id.objid,
                                     targetos = ref_id.osnum
                                    );
                   _pdm_debug("GRreffile.GRchgrfprops", 0);

                   if ( !(status & msg & 1) )
                      {
                       _pdm_debug("GRreffile.GRchgrfprops failed", 0);
                       return(0);
                      }
                   
              }

           /* Get part attached attr. */
           status = PDUevaluate_exp(
                                    parts[i],
                                    "attached",
                                    &attached
                                    );

           _pdm_status("PDUevaluate_exp attached", status);
           if (status != PDM_S_SUCCESS)
              {
               _pdm_debug("could not evaluate attached attr.", 0);
               return(0);
              }

           /* Set part display property accordingly */
           if (strcmp(attached, "N") != 0)
              {
               _pdm_debug("set part display to ON", 0);

               flag = -1;

               if ( !(properties & GRIS_DISPLAYABLE) )
                 {
                  properties |= GRIS_DISPLAYABLE; 
                
               status = om$send (
                                 msg = message GRgraphics.GRchgprops
                                       (&msg, &flag, &properties),
                                 senderid = NULL_OBJID,
                                 targetid = ref_id.objid,
                                 targetos = ref_id.osnum
                                );

               if ( !(status & msg & 1) )
                  {
                   _pdm_debug("GRgraphics.GRchgprops failed", 0);
                   return(0);
                  }
                }

               /* Check to see if parent's display is ON */
               status = PDUevaluate_exp(
                                        parts[i],
                                        "level",
                                        &level
                                       );
           _pdm_status("PDUevaluate_exp level", status);

               if (status != PDM_S_SUCCESS)
                  {
                   _pdm_debug("PDUevaluate_exp failed", 0);
                   return(0);
                  }

               while (strcmp(level, "1") != 0)
                     {
                      *((IGRchar *)strrchr(parts[i], ':')) = '\0';

                      status = PDUevaluate_exp(
                                               parts[i],
                                               "level",
                                               &level
                                              );

                      if (status != PDM_S_SUCCESS)
                         {
                          _pdm_debug("PDUevaluate_exp failed", 0);
                          return(0);
                         }

                     } /* end while loop */

               /* Extract attached attr. */
               status = PDUevaluate_exp(
                                        parts[i],
                                        "attached",
                                        &attached
                                       );
           _pdm_status("PDUevaluate_exp attached", status);

               if (status != PDM_S_SUCCESS)
                  {
                   _pdm_debug("PDUevaluate_exp failed", 0);
                   return(0);
                  }

               if (strcmp(attached, "Y") == 0) 
                  {
                   /* Set display ON */
                  dp$display(msg = &msg,
                              oids = &ref_id,
                              mode = GRbd
                             );
                  }
                }
           else
               {
                _pdm_debug("set part display to OFF", 0);

                /* Set display OFF */
                dp$display(
                           msg = &msg,
                           oids = &ref_id,
                           mode = GRbe
                          );

                flag = -1;

                if (properties & GRIS_DISPLAYABLE)
                  {
                   properties &= ~GRIS_DISPLAYABLE;
                  }

                  status = om$send (
                                  msg = message GRgraphics.GRchgprops
                                        (&msg, &flag, &properties),
                                    senderid = NULL_OBJID,
                                    targetid = ref_id.objid,
                                    targetos = ref_id.osnum
                                 );

                if ( !(status & msg & 1) )
                   {
                    _pdm_debug("GRreffile.GRchgprops failed", 0);
                    return(0);
                   }
                dp$display(
                           msg = &msg,
                           oids = &ref_id,
                           mode = GRbe
                          );
                dp$display(
                           msg = &msg,
                           oids = &ref_id,
                           mode = GRbe
                          );
               }

          } /* end for i loop */

      if (loaded)
         {
         free(loaded);
         loaded = NULL;
         }

      if (attached)
         {
         free(attached);
         attached = NULL;
         }

      if (refid)
         {
         free(refid);
         refid = NULL;
         }

      if (delete_flag)
         {
         free(delete_flag);
         delete_flag = NULL;
         }

      if (level)
         {
         free(level);
         level = NULL;
         }

      if (parts)
         di$free(lines = parts, count = part_count);

      if (free_mod)
         {
          free(mod_env);
          mod_env = NULL;
         }
     } 

  else
      {
       _pdm_debug("no parts found in assembly structure", 0);
       return(PDM_S_SUCCESS);
      }


  if (update_req)
    dp$update(msg = &msg);
  return(PDM_S_SUCCESS);
 }


/*
 * This function updates the display of 1st-level parts based on
 * the assembly structure.
 */

IGRint  PDUupdate_1st_level_detached_parts_display(mod_env)

 struct GRmd_env  *mod_env;             /* INPUT */

 {
  IGRlong                   status = PDM_S_SUCCESS;
  IGRlong                   msg = MSSUCC;
  IGRshort                  free_mod = FALSE;
  IGRint                    bufsiz;
  IGRchar                   assy_path[DI_PATH_MAX];
  IGRchar                   part_path[DI_PATH_MAX];
  IGRchar                   child_no[MAX_VALUE];
  IGRchar                   attach_flag[MAX_VALUE];
  IGRchar                   catalog[MAX_VALUE];
  IGRchar                   number[MAX_VALUE];
  IGRchar                   revision[MAX_VALUE];
  IGRint                    part_count = 0;
  IGRchar                   *attached = NULL;
  IGRchar                   *delete_flag = NULL;
  IGRchar                   *filename = NULL;
  IGRchar                   *viewname = NULL;
  IGRchar                   *catalog_no = NULL;
  IGRchar                   *item_no = NULL;
  IGRchar                   *active_parttype = NULL;
  IGRint                    type;
  struct  PDUpart_node      *part_ids = NULL;
  struct  PDUpart_node      *head = NULL;
  MEMptr                    copy_attach_buffer = NULL;
  MEMptr                    status_buffer = NULL;
  extern struct PDUrefresh  *refresh;


  _pdm_debug("In the PDUupdate_1st_level_detached_parts_display function", 0);

  /* Default module env. to current if mod_env is NULL */
  if (!mod_env)
     {
      mod_env = (struct GRmd_env *) malloc(sizeof(struct GRmd_env));
      bufsiz = sizeof(struct GRmd_env);
      gr$get_module_env(sizbuf = &bufsiz, buffer = mod_env);
      free_mod = TRUE;
     }

  /* Extract all PDU GRparts from object space */
  status = PDUget_all_GRpart_ids(
                                 mod_env->md_id.osnum,
                                 &part_ids,
                                 &part_count
                                );
  _pdm_status("PDUget_all_GRpart_ids", status);

  if ( (part_count == 0) || (!part_ids) )
     {
      _pdm_debug("no PDU GRpart parts found", 0);
      return(PDM_S_SUCCESS);
     }

  /* Construct path to ASSEMBLY directory */
  di$give_pathname(
                   osnum = mod_env->md_id.osnum,
                   pathname = assy_path 
                  );

  strcat(assy_path, ":ASSEMBLY:");

  /* Update 1st_level detached parts display */
  head = part_ids;

  while (head)
        {
         /* Extract child no */
         co$part_get_attr (
                           msg = &msg,
                           mod_env = mod_env,
                           part = &(head->part_id),
                           attr = "child_no",
                           value = child_no,
                           type = &type
                          );

         /* Store value in child_no */
         PDUunquote(child_no);

         strcpy(part_path, assy_path);
         strcat(part_path, "P");
         strcat(part_path, child_no);

         /* Extract value for part delete_flag attribute */
         status = PDUevaluate_exp(
                                  part_path,
                                  "delete_flag",
                                  &delete_flag
                                 );

         if (status != PDM_S_SUCCESS)
            {
             _pdm_debug("could not evaluate delete flag attr.", 0);
             return(0);
            }

         /* Skip parts marked for deletion */
         if (strcmp(delete_flag, "Y") == 0)
            {
             _pdm_debug("encountered a deleted part", 0);

             /* Free up variables */
             if (delete_flag)
                free(delete_flag);

             /* Process next part */
             head = head->next;

             continue;
            }

         /* Extract value for part attached attribute */
         status = PDUevaluate_exp(
                                  part_path,
                                  "attached",
                                  &attached
                                 );

         if (status != PDM_S_SUCCESS)
            {
             _pdm_debug("could not evaluate attached attr.", 0);
             return(0);
            }

         _pdm_debug("extracted attached value = <%s>", attached);

         if ((strcmp(attached, "N") != 0) && (strcmp(attached, "") != 0))
            {
             /* Extract attach flag */
             co$part_get_attr (
                               msg = &msg,
                               mod_env = mod_env,
                               part = &(head->part_id),
                               attr = "attach_flag",
                               value = attach_flag,
                               type = &type
                              );

             if ( (strcmp(attach_flag, "-1.000000") == 0) ||
                  (strcmp(attach_flag, "-2.000000") == 0) )
                {
                 _pdm_debug("encountered a detached part", 0);

                 /* Extract part catalog */
                 co$part_get_attr (
                                   msg = &msg,
                                   mod_env = mod_env,
                                   part = &(head->part_id),
                                   attr = "CATALOG",
                                   value = catalog,
                                   type = &type
                                  );

                 /* Extract part number */
                 co$part_get_attr (
                                   msg = &msg,
                                   mod_env = mod_env,
                                   part = &(head->part_id),
                                   attr = "NUMBER",
                                   value = number,
                                   type = &type
                                  );

                 /* Extract part revision */
                 co$part_get_attr (
                                   msg = &msg,
                                   mod_env = mod_env,
                                   part = &(head->part_id),
                                   attr = "REVISION",
                                   value = revision,
                                   type = &type
                                  ); 

                 /* Extract value for part catalog no */
                 status = PDUevaluate_exp(
                                          part_path,
                                          "catalog_no",
                                          &catalog_no
                                         );

                 if (status != PDM_S_SUCCESS)
                    {
                     _pdm_debug("could not evaluate catalog_no attr.", 0);
                     return(0);
                    }

                 /* Extract value for part item no */
                 status = PDUevaluate_exp(
                                          part_path,
                                          "item_no",
                                          &item_no
                                         );

                 if (status != PDM_S_SUCCESS)
                    {
                     _pdm_debug("could not evaluate item_no attr.", 0);
                     return(0);
                    }

                 /* Display part file(s) and origin(s) */
                 status = PDUdisplay_files_and_origins(
                                                       catalog,
                                                       number,
                                                       revision,
                                                       &filename,
                                                       &viewname
                                                      );

                 if (status != PDM_S_SUCCESS)
                    {
                     _pdm_debug("PDUdisplay_files_and_origins failed", 0);
                    }
                 else
                 {
                 PDMopen_buffer(7, &copy_attach_buffer);
                 status = PDUload_local_file_buffer(catalog_no, item_no, 
                                                    catalog, number, revision, 
                                                    filename, 
                                                    &copy_attach_buffer);
                 _pdm_status("PDUload_local_file_buffer", status);
                 
                 if (copy_attach_buffer->rows > 0) 
                   {
                   status = PDMcopy_attach(copy_attach_buffer, 
                                                  &status_buffer);
                   _pdm_status("PDMcopy_attach", status);
                   PDUmodify_exp(0, part_path, "local_flag", "D",
                                 mod_env->md_id.osnum);
                   }
                 status = PDUverify_part('a');
                 _pdm_status("PDUverify_part", status);
                 if (status == PDM_S_SUCCESS)
                   {
                   status = PDUget_parttype(refresh->act_catalog, 
                                            refresh->act_partid, 
                                            refresh->act_revision, 
                                            &active_parttype);
                   _pdm_status("PDUget_parttype", status);
                   }
                 else
                   {
                   PDUfill_in_string(&active_parttype, "G");
                   }
                 /* Attach part */
                 status = pdmoAttachPart(
                                         mod_env,
                                         &(head->part_id),
                                         catalog,
                                         number,
                                         revision,
                                         filename,
                                         viewname,
                                         "Y",
                                         catalog_no,
                                         item_no,
                                         child_no,
                                         active_parttype,
                                         "Y" 
                                        );
                 _pdm_status("pdmoAttachPart", status);
                 if (active_parttype)
                   free(active_parttype);

                 if (status != PDM_S_SUCCESS)
                    {
                     _pdm_debug("pdmoAttachPart failed", 0);
                     return(0);
                    }
                 }
                }
            }

         /* Process next part */
         head = head->next;

        } /* end while loop */

  /* Free up variables */
  if (delete_flag)
     free(delete_flag);

  if (attached)
     free(attached);

  if (catalog_no)
     free(catalog_no);

  if (item_no)
     free(item_no);

  if (filename)
     free(filename);

  if (viewname)
     free(viewname);

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
      free(mod_env);
      mod_env = NULL;
     }
 
  return(PDM_S_SUCCESS);
 }


/* 
 * This function adds a node to the ref. parent-child list.
 */
void  PDUadd_refid_node(
                        level,
                        refid,
                        PDUpart
                       )

 IGRint           level;                  /* INPUT */
 IGRchar          refid[20];              /* INPUT */
 IGRshort         PDUpart;                /* INPUT */
 {
  struct PDUref_info_node         *tail = NULL;
  struct PDUref_info_node         *temp = NULL;
  struct PDUref_info_node         *reverse = NULL;

  _pdm_debug("In the PDUadd_refid_node function", 0);

  /* Create a node with ref. parent-child  info */
  temp = (struct PDUref_info_node *) malloc(sizeof(struct PDUref_info_node));
  _pdm_debug("level = <%d>", level);

  /* Initialize temp fields */
  temp->level = level;
  strcpy(temp->refid, refid); 
  (temp->parent_id)[0] = '\0';
  temp->PDUpart = PDUpart;
  temp->part_found = FALSE;
  temp->prev = NULL;
  temp->next = NULL;

  /* Add node to the end of PDU_ref_parent_child_list */
  if (PDU_ref_parent_child_list)
     {
      /* Get to the end of list */
      tail = PDU_ref_parent_child_list;
      while (tail->next)
            {
             if (strcmp(tail->refid, temp->refid) == 0)
               {
               _pdm_debug("refid already added", 0);
               if (temp)
                 free(temp);
               return;
               }
             tail = tail->next;
            }

      /* Add node to end of link list */
      tail->next = temp;
      temp->prev = tail;

      /* Find parent for newly added node */
      reverse = temp->prev;
     
      while (reverse) 
            {
             if ( (reverse->level) == (level - 1) )
                {
                 _pdm_debug("a parent was found", 0);
                 strcpy(temp->parent_id, reverse->refid);
                 break;
                } 

             /* Process previous node */
             reverse = reverse->prev;
            }
     }

  else
      {
       /* This is the first node in the list */
       PDU_ref_parent_child_list = temp;
      }
 }


/*
 * This function given a reference object id, it will return the PDU GRpart
 * that owns it, if any. 
 */

IGRint  PDUget_GRpart_from_refid(
                                 mod_env,
                                 ref_id,
                                 part_id
                                )

 struct GRmd_env  *mod_env;              /* INPUT */
 struct GRid      *ref_id;               /* INPUT */
 struct GRid      *part_id;              /* OUTPUT */

 {
  IGRlong             msg;
  IGRint              chan_count = 0;
  OMuint              obj_count = 0;
  OM_S_CHANSELECT     chan;
  OM_S_OBJECT_LINKAGE *list = NULL;
  OMuword             classid;
  IGRint              i;


  _pdm_debug("In the PDUget_GRpart_from_refid function", 0);

  if (ref_id)
     {
      /* Set channel indices */
      chan.type = OM_e_name;
      chan.u_sel.name = "GRconnector.to_owners";

      _pdm_debug("objid = %d", ref_id->objid);
      _pdm_debug("osnum = %d", ref_id->osnum);
      msg = om$get_channel_count(
                           osnum = ref_id->osnum,
                           objid = ref_id->objid,
                           p_chanselect = &chan,
                           count = (OMuint *)&chan_count
                          );
      _pdm_status("om$get_channel_count", msg); 
      _pdm_debug("channel_count = %d", chan_count);

      
      if (chan_count > 0)
         {
          /* Allocate memory for the list of objects */
          list = (OM_S_OBJECT_LINKAGE *)
                              malloc(sizeof(OM_S_OBJECT_LINKAGE) * chan_count);

          /* Get the owning GRpart object */
          msg = om$get_channel_objects(
                                       objid = ref_id->objid,
                                       osnum = ref_id->osnum,
                                       p_chanselect = &chan,
                                       list = list,
                                       size = chan_count,
                                       count = &obj_count
                                      );

          if (! (1 & msg )) 
             {
              _pdm_debug("om$get_channel_objects failed", 0);
              return(0);
             }

          for (i = 0; i < obj_count; ++i)
              {
               /* Get classid of owner */
               msg = om$get_classid(
                                    osnum = list[i].osnum,
                                    objid = list[i].S_objid,
                                    p_classid = &classid
                                   );

               if (! (1 & msg ))
                  {
                   _pdm_debug("om$get_classid failed", 0);
                   return(0);
                  }
               _pdm_debug("classid = %d", classid);
               if (classid == OPP_GRpart_class_id)
                  {
                   /* Make sure owner is a PDU GRpart */
                   part_id->osnum = list[i].osnum;
                   part_id->objid = list[i].S_objid;

                   if (PDUis_PDU_part(part_id, mod_env))
                      {
                       _pdm_debug("PDU GRpart owner found", 0);
                       return(PDM_S_SUCCESS);
                      }
                  }
               else if (classid == OPP_GRdvattach_class_id)
                 {
                 _pdm_debug("drawing attachment", 0);
                 return(PDM_S_SUCCESS);
                 }
               else
                   continue;

              } /* end for loop */
         }

      else
          {
           _pdm_debug("ref id %d does not have an owner", ref_id->objid);
           return(0);
          }
     }

  if (list)
    free(list);
  return(0);
 }


/* 
 * This function constructs the refid string to be stored in the assembly
 * structure.
 */

IGRint  PDUconstruct_refid_string(
                                  ref_id,
                                  context_id,
                                  refid_string
                                 )

 struct GRid      *ref_id;             /* INPUT */
 struct GRid      *context_id;         /* INPUT */
 IGRchar          refid_string[20];    /* OUTPUT */
 {
  _pdm_debug("In the PDUconstruct_refid_string function", 0);

  /* Construct refid string */
  sprintf(
          refid_string,
          "%d|%d|%d",
          ref_id->objid,
          context_id->objid,
          ref_id->osnum
         );

  _pdm_debug("constructed refid string = <%s>", refid_string);

  return(PDM_S_SUCCESS);
 } 


/*
 * This function returns the ref. id and the context id. given a refid string.
 */

IGRint  PDUread_refid_string(
                             refid_string,
                             ref_id,
                             context_id
                            )

 IGRchar          *refid_string;       /* INPUT */
 struct GRid      *ref_id;             /* OUTPUT */
 struct GRid      *context_id;         /* OUTPUT */
 {
  IGRchar         *ptr;
  IGRint          tmposnum;

  _pdm_debug("In the PDUread_refid_string function", 0);

  if (!refid_string)
     {
      _pdm_debug("refid_string is NULL", 0);
      return(0);
     }

  if (strcmp(refid_string, "") == 0)
     {
      _pdm_debug("refid_string is empty", 0);
      return(0);
     }

  if (strcmp(refid_string, "-1") == 0)
     {
      _pdm_debug("refid_string = -1", 0);
      return(0);
     }

  /* Extract osnum */
  ptr = strrchr(refid_string, '|');

  if (!ptr)
     {
      _pdm_debug("Invalid refid value", 0);
      return(0);
     }

  ++ptr;
  _pdm_debug("ptr = <%s>", ptr);
  sscanf(ptr, "%d", &tmposnum);
  _pdm_debug("tmposnum =<%d>", tmposnum);
  ref_id->osnum=tmposnum;
  context_id->osnum=tmposnum;
  /* Extract context id. obj. id. */
  *((IGRchar *)strrchr(refid_string, '|')) = '\0';
  ptr = strrchr(refid_string, '|');
  ++ptr;
  sscanf(ptr, "%d", &(context_id->objid));

  /* Extract ref. id. obj. id. */
  *((IGRchar *)strrchr(refid_string, '|')) = '\0';
  sscanf(refid_string, "%d", &(ref_id->objid));

  _pdm_debug("read ref. id = %d", ref_id->objid);
  _pdm_debug("read complex id = %d", context_id->objid);
  _pdm_debug("read osnum = %d", ref_id->osnum);

  return(PDM_S_SUCCESS);
 }


/* 
 * This function sets the display of a reference file object at 
 * initialization time.
 */

IGRboolean  PDMset_reffile_display(
                                   construct,
                                   mount_name,
                                   ref_id,
                                   context_id,
                                   depth,
                                   displayed,
                                   loaded
                                  )

 IGRboolean    construct;               /* INPUT */
 IGRchar       *mount_name;             /* INPUT */
 struct GRid   *ref_id;                 /* INPUT */
 struct GRid   *context_id;             /* INPUT */
 IGRint        depth;                   /* INPUT */
 IGRboolean    *displayed;              /* OUTPUT */
 IGRboolean    *loaded;                 /* OUTPUT */
 {
  IGRint                          status = PDM_S_SUCCESS;
  IGRlong                         msg = MSSUCC;
  struct GRid                     part_id;
  struct GRmd_env                 mod_env;
  IGRchar                         refid_string[20];
  IGRchar                         assy_path[DI_PATH_MAX];
  IGRchar                         child_no[MAX_VALUE];
  IGRchar                         cat_no[MAX_VALUE];
  IGRchar                         itm_no[MAX_VALUE];
  IGRchar                         *catalog_no = NULL;
  IGRchar                         *item_no = NULL;
  IGRint                          part_count = 0;
  IGRint                          count = 0;
  IGRchar                         **parts = NULL;
  IGRchar                         *attach = NULL;
  IGRchar                         *load = NULL;
  IGRchar                         *refid = NULL;
  IGRchar                         *delete_flag = NULL;
  IGRchar                         *file_name = NULL;
  IGRint                          type;
  IGRint                          i;
  IGRchar                         *entry = NULL;
  IGRchar                         *ptr;
  IGRchar                         ref_descr[DI_PATH_MAX];
  IGRchar                         tmp_str[DI_PATH_MAX];
  IGRchar                         description[DI_PATH_MAX];
  IGRint                          bufsiz;
  IGRshort                        flag = 0;
  IGRshort                        file_found = TRUE;
  IGRint                          cnt = 0;
  IGRint                          disp = 0;
  struct PDUref_info_node         *head = NULL;

  extern struct PDUref_info_node  *PDU_ref_parent_child_list;
  extern IGRshort                 PDU_activate_reffile_display;


  _pdm_debug("In the PDMset_reffile_display function", 0);

/*
  if (forms.rev_assy_form_id)
    {
    FIf_is_displayed(forms.rev_assy_form_id, &disp);
    if (disp)
      {
      _pdm_debug("reconstructing mount_name", 0);
      strcpy(mount_name, ":test:ref:");
      strcat(mount_name, PDU_filename);
      }
    }
*/

  /* Increment depth */
  ++depth;
  _pdm_debug("mount name = <%s>", mount_name);

  _pdm_debug("depth = %d", depth);
  ptr = strrchr(mount_name, ':');
  if (ptr)
    {
    ++ptr;
    _pdm_debug("ptr = <%s>", ptr);
    status = PDUverify_file(ptr);
    _pdm_status("PDUverify_file", status);
    if ((status != PDM_S_SUCCESS) && (depth != 1))
      {
      _pdm_debug("file does not exist locally", 0);
      file_found = FALSE;
      }
    }
    
  /* Check to see if ref. file display is to be deactivated */
  if (!PDU_activate_reffile_display)
     {
      _pdm_debug("ref. file display is deactivated", 0);
      return(FALSE);
     }
 
  /* Check if ref. object is being constructed */
  if (construct)
     {
      _pdm_debug("ref. obj. %d is being constructed", ref_id->objid);

      /* Construct refid search string */
      status = PDUconstruct_refid_string(
                                         ref_id,
                                         context_id,
                                         refid_string
                                        );

      /* Make sure it is a PDU attachment */
      flag = 0;
      status = om$send(
                       msg = message GRreffile.GRgetdescription
                                     (&msg, &flag, ref_descr),
                       senderid = NULL_OBJID, 
                       targetos = ref_id->osnum,
                       targetid = ref_id->objid
                      );

      if ( !(status & msg & 1) )
         {
          _pdm_debug("GRreffile.GRgetdescription failed", 0);
          return(FALSE);
         }

      _pdm_debug("extracted ref. desc. = <%s>", ref_descr);

      strcpy(description, ref_descr);

      if (strcmp(ref_descr, "") != 0)
         {
          ptr = ref_descr;

          while ( (ptr[0] != '\0') && (cnt < 3) )
                {
                 ++ptr; 
                 ++cnt;
                }

          if (cnt == 3)
             {
              ptr[0] = '\0';
              if (strcmp(ref_descr, "PDU") == 0) 
                 {
                  _pdm_debug("encountered a PDU attachment", 0);

                  /* Add ref. id to ref. parent-child list */
                  PDUadd_refid_node(
                                    depth,
                                    refid_string,
                                    TRUE 
                                   );

                  PDUprint_parent_child_list();

                  /* Extract catalog and item no */
                  strcpy(tmp_str, description);
                  ptr = (char *)strchr(tmp_str, ':');
                  ++ptr;
                  *((IGRchar *)strchr(ptr, ':')) = '\0';
                  strcpy(cat_no, ptr);

                  strcpy(tmp_str, description);
                  ptr = (char *)strchr(tmp_str, ':');
                  ++ptr;
                  ptr = (char *)strchr(ptr, ':');
                  ++ptr;
                  *((IGRchar *)strchr(ptr, ':')) = '\0';
                  strcpy(itm_no, ptr);

                  _pdm_debug("catalog no = <%s>", cat_no);
                  _pdm_debug("item no = <%s>", item_no);

                  /* Construct path to assembly structure */
                  di$give_pathname(
                                   osnum = ref_id->osnum,
                                   pathname = assy_path
                                  );

                  strcat(assy_path, ":ASSEMBLY");

                  /* Extract DIrectory objects from given assembly path */
                  status = di$find (
                                    start_dir = assy_path,
                                    regexp = "P*",
                                    lines = &parts,
                                    ptr = &part_count,
                                    max_level = 1
                                   );

                  if (part_count > 0)
                     { 
                      for (i = 0; i < part_count; ++i)
                          {
                           PDUstrip_dir_entry(parts[i]);

                           /* Extract value for part catalog no attr. */
                           status = PDUevaluate_exp(
                                                    parts[i],
                                                    "catalog_no",
                                                    &catalog_no
                                                   );

                           if (status != PDM_S_SUCCESS)
                              {
                               _pdm_debug("could not evaluate cat no attr.", 0);
                               return(FALSE);
                              }

                           /* Extract value for part item no attr. */
                           status = PDUevaluate_exp(
                                                    parts[i],
                                                    "item_no",
                                                    &item_no
                                                   );

                           if (status != PDM_S_SUCCESS)
                              {
                               _pdm_debug("could not evaluate item no attr.", 0);
                               return(FALSE);
                              }

                           /* Extract value for part reffid attr. */
                           status = PDUevaluate_exp(
                                                    parts[i],
                                                    "refid",
                                                    &refid
                                                   );

                           if (status != PDM_S_SUCCESS)
                              {
                               _pdm_debug("could not evaluate refid attr.", 0)
;
                               return(FALSE);
                              }

                           if ( (strcmp(refid, "") == 0) &&
                                (strcmp(catalog_no, cat_no) == 0) &&
                                (strcmp(item_no, itm_no) == 0) )
                              {
                               _pdm_debug("Update refid value", 0); 
                               
                               PDUmodify_exp(
                                             0,
                                             parts[i],
                                             "refid",
                                             refid_string,
                                             ref_id->osnum
                                            );


                               /* Free up variables */
                               if (catalog_no)
                                  free(catalog_no);

                               if (item_no)
                                  free(item_no);

                               if (refid)
                                  free(refid);

                               *loaded = TRUE;
                               break;
                              }
                             
                          }
                     }

                  return(TRUE);
                 }
             }
         }

      /* Add ref. id to ref. parent-child list */
      PDUadd_refid_node(
                        depth,
                        refid_string,
                        FALSE 
                       );

      PDUprint_parent_child_list();

      return(FALSE);
     }

  /* Get active module environment */
  bufsiz = sizeof(struct GRmd_env);
  gr$get_module_env(sizbuf = &bufsiz, buffer = &mod_env);

  /* Construct refid search string */
  status = PDUconstruct_refid_string(
                                     ref_id,
                                     context_id,
                                     refid_string
                                    );

  /* Check to see if refid is owned by a PDU GRpart */
  status = PDUget_GRpart_from_refid(
                                    &mod_env,
                                    ref_id,
                                    &part_id
                                   );
  _pdm_status("PDUget_GRpart_from_refid", status);

  if (status != PDM_S_SUCCESS)
     {
      _pdm_debug("encountered an EMS attachment", 0);

      /* Add ref. id to ref. parent-child list */
      PDUadd_refid_node(
                        depth,
                        refid_string,
                        FALSE
                       );

      PDUprint_parent_child_list();

      return(FALSE);
     }

  _pdm_debug("GRpart id = %d", part_id.objid);
  _pdm_debug("GRpart osnum = %d", part_id.osnum);
  _pdm_debug("mod_env.md_id.osnum = %d", mod_env.md_id.osnum);
  _pdm_debug("depth = <%d>", depth);

  if ((depth == 1) && (part_id.osnum != mod_env.md_id.osnum))
    {
    depth = (part_id.osnum - mod_env.md_id.osnum);
    depth++;
    }

  _pdm_debug("depth = <%d>", depth);
  /* Add ref. id to ref. parent-child list */
  PDUadd_refid_node(
                    depth,
                    refid_string,
                    TRUE
                   );

  PDUprint_parent_child_list();

  /* Construct path to assembly structure in active object space */
  di$give_pathname(
                   osnum = mod_env.md_id.osnum,
                   pathname = assy_path
                  );

  strcat(assy_path, ":ASSEMBLY");

  /* Check to see if ASSEMBLY structure exists */
  status = di$ls(regexp = assy_path, ptr = &count);
  
  if (count <= 0)
     {
      _pdm_debug("SEVERE error: ASSEMBLY structure does not exist", 0);
      return(FALSE);
     }

  /* Check to see if 1st-level part */
  if (depth == 1)
     {
      _pdm_debug("encountered a 1st-level part", 0);

      /* Extract part child no */
      status = co$part_get_attr (
                                 msg = &msg,
                                 mod_env = &mod_env,
                                 part = &part_id,
                                 attr = "child_no",
                                 value = child_no,
                                 type = &type
                                );

      if (msg == MSSUCC)
         {
          /* Unquote child no */
          PDUunquote(child_no);

          /* Construct path to part */
          strcat(assy_path, ":");
          strcat(assy_path, "P");
          strcat(assy_path, child_no);

          /* Extract value for part delete_flag attribute */
          status = PDUevaluate_exp(
                                   assy_path,
                                   "delete_flag",
                                   &delete_flag
                                  );

          if (status != PDM_S_SUCCESS)
             {
              _pdm_debug("could not evaluate delete flag attr.", 0);
              return(FALSE);
             }

          /* Skip parts marked for deletion */
          if (strcmp(delete_flag, "Y") == 0)
             {
              _pdm_debug("encountered a deleted part", 0);

              *displayed = FALSE;
              *loaded = FALSE;

              /* Free up variables */
              if (delete_flag)
                 free(delete_flag);

              return(TRUE);
             }

          /* Extract value for part attached attribute */
          status = PDUevaluate_exp(
                                   assy_path,
                                   "attached",
                                   &attach
                                  );

          if (status != PDM_S_SUCCESS)
             {
              _pdm_debug("could not evaluate attached attr.", 0);
              return(FALSE);
             }

          _pdm_debug("extracted attached value = <%s>", attach);

          /* Extract the corresponding loaded attribute */
          status = PDUevaluate_exp(
                                   assy_path,
                                   "loaded",
                                   &load
                                  );

          if (status != PDM_S_SUCCESS)
             {
              _pdm_debug("could not evaluate loaded attr.", 0);
              return(FALSE);
             }

          _pdm_debug("extracted loaded value = <%s>", load);

          /* Set displayed property in the reffile object */
          if (strcmp(attach, "N") == 0)
             {
              _pdm_debug("setting reffile displayed to FALSE", 0);
              *displayed = FALSE;

              /* Set display ON */
              dp$display(
                         msg = &msg,
                         oids = &part_id,
                         mode = GRbe
                        );
              /* Set display OFF */
              dp$display(
                         msg = &msg,
                         oids = &part_id,
                         mode = GRbe
                        );
             }

          else
              {
               _pdm_debug("setting reffile displayed to TRUE", 0);
               *displayed = TRUE;

               /* Set display ON */
               dp$display(
                          msg = &msg,
                          oids = &part_id,
                          mode = GRbd
                         );
              }

          /* Set loaded property in the reffile object */
          if (strcmp(load, "N") == 0)
             {
              _pdm_debug("setting reffile loaded to FALSE", 0);
              *loaded = FALSE;
             }

          else
              {
               _pdm_debug("setting reffile loaded to TRUE", 0);
               *loaded = TRUE;
              }

          if (!file_found)
            {
            *loaded = FALSE;
            *displayed = FALSE;
            }

          /* Construct refid search string */
          status = PDUconstruct_refid_string(
                                             ref_id,
                                             context_id,
                                             refid_string
                                            );

          /* Update refid attribute */
          status = PDUmodify_exp(
                                 0,
                                 assy_path,
                                 "refid",
                                 refid_string,
                                 mod_env.md_id.osnum
                                );

          /* Mark part as found in the parent child list */
          if (PDU_ref_parent_child_list)
             {
              head = PDU_ref_parent_child_list;
              while (head->next)
                    {
                     head = head->next;
                    } /* end while loop */

              head->part_found = TRUE;
             }

          /* Store part path in processed parts list */
          /*
          PDUadd_path_node(assy_path);
          */

          /* Free up variables */
          if (attach)
             free(attach);

          if (load)
             free(load);

          if (delete_flag)
             free(delete_flag);

          return(TRUE);
         }

      else
          {
           _pdm_debug("co$part_get_attr failed", 0);
           return(FALSE);
          }
     }

  /* Extract list of DIrectory objects from given parts path */
  status = di$find(
                   start_dir = assy_path,
                   regexp = "P*",
                   lines = &parts,
                   ptr = &part_count,
                   max_level = depth 
                  );

  if (status != DIR_S_SUCCESS)
     {
      _pdm_debug("SEVERE error: di$find failed", 0);
      return(FALSE);
     }

  /* Check to see if there is any parts in assembly structure */
  if (part_count <= 0)
     {
      _pdm_debug("SEVERE error: no parts found in assembly structure", 0);

      /* Free up parts and part_count */
      if (parts)
         {
          di$free (lines = parts, count = part_count);
          return(FALSE);
         }

      else
          return(FALSE);
     }

  for (i = 0; i < part_count; ++i)
      {
       /* Drop last ":" from entry */
       _pdm_debug("parts[i] = <%s>", parts[i]);

       PDUfill_in_string(&entry, parts[i]);

       PDUstrip_dir_entry(entry);


       /* Extract value for part delete_flag attribute */
       status = PDUevaluate_exp(
                                entry,
                                "delete_flag",
                                &delete_flag
                               );

       if (status != PDM_S_SUCCESS)
          {
           _pdm_debug("could not evaluate delete flag attr.", 0);
           return(FALSE);
          }

       /* Skip parts marked for deletion */
       if (strcmp(delete_flag, "Y") == 0)
          {
           _pdm_debug("encountered a deleted part", 0);
           continue;
          }

       /* Extract value for part refid attribute */
       status = PDUevaluate_exp(
                                entry,
                                "refid",
                                &refid
                               );

       if (status == PDM_S_SUCCESS)
          {
           /* Check if there is a match */
           _pdm_debug("refid_string = <%s>", refid_string);
           if (strcmp(refid, refid_string) != 0)
              {
               _pdm_debug("skip to next entry", 0);
               continue;
              }

           _pdm_debug("a match was found", 0);

           /* Extract the corresponding attached attribute */
           status = PDUevaluate_exp(
                                    entry,
                                    "attached",
                                    &attach
                                   );

           if (status != PDM_S_SUCCESS)
              {
               _pdm_debug("SEVERE error: PDUevaluate_exp failed on attached attr", 0);
               return(FALSE);
              }

           _pdm_debug("extracted attached value = <%s>", attach);

           /* Extract the corresponding loaded attribute */
           status = PDUevaluate_exp(
                                    entry,
                                    "loaded",
                                    &load
                                   );

           if (status != PDM_S_SUCCESS)
              {
               _pdm_debug("SEVERE error: PDUevaluate_exp failed on loaded attr", 0);
               return(FALSE);
              }

           _pdm_debug("extracted loaded value = <%s>", load);

           /* Set displayed property in the reffile object */
           if (strcmp(attach, "N") == 0)
              {
               _pdm_debug("setting reffile displayed to FALSE", 0);
               *displayed = FALSE;
              } 

           else
               {
                _pdm_debug("setting reffile displayed to TRUE", 0);
                *displayed = TRUE;
               }

           /* Set loaded property in the reffile object */
           if (strcmp(load, "N") == 0)
              {
               _pdm_debug("setting reffile loaded to FALSE", 0);
               *loaded = FALSE;
              }

           else
               {
                _pdm_debug("setting reffile loaded to TRUE", 0);
                *loaded = TRUE;
               }

           status = PDUevaluate_exp(
                                    entry,
                                    "file_name",
                                    &file_name
                                   );

           if (status != PDM_S_SUCCESS)
              {
               _pdm_debug("SEVERE error: PDUevaluate_exp failed on attached attr", 0);
               return(FALSE);
              }

           status = PDUverify_file(file_name);
           if (status != PDM_S_SUCCESS)
             {
             *loaded = FALSE;
             *displayed = FALSE;
             }

           /* Mark part as found in the parent child list */
           if (PDU_ref_parent_child_list)
              {
               head = PDU_ref_parent_child_list;
               while (head->next)
                     {
                      head = head->next;
                     } /* end while loop */

               head->part_found = TRUE;
              }

           /* Store part path in processed parts list */
           /*
           PDUadd_path_node(entry);
           */

           /* Free up variables */
           if (parts)
               di$free (lines = parts, count = part_count);

           if (attach)
              free(attach);

           if (load)
              free(load);

           if (entry)
              free(entry);

           if (refid)
              free(refid);

           if (delete_flag)
              free(delete_flag);

           return(TRUE);
          }

       else
           {
            _pdm_debug("SEVERE error: refid attr. does not exist", 0);
            return(FALSE);
           }

      } /* end for i loop */

  /* A match was not found, must infer value from assembly structure */
  _pdm_debug("a match was not found, need to infer value", 0);

  status = PDUmap_refid_to_assembly(
                                    &mod_env,
                                    refid_string,
                                    &part_id,
                                    displayed,
                                    loaded,
                                    depth
                                   );
  _pdm_status("PDUmap_refid_to_assembly", status);

  if (status != PDM_S_SUCCESS)
     {
      _pdm_debug("PDUmap_refid_to_assembly failed", 0);
 
      /* Free up variables */
      if (parts)
         di$free (lines = parts, count = part_count);

      if (attach)
         free(attach);

      if (load)
         free(load);

      if (entry)
         free(entry);

      if (refid)
         free(refid);

      if (delete_flag)
         free(delete_flag);

      return(TRUE);
     }

  /* Mark part as found in the parent child list */
  if (PDU_ref_parent_child_list)
     {
      head = PDU_ref_parent_child_list;
      while (head->next)
            {
             head = head->next;
            } /* end while loop */

      head->part_found = TRUE;
     }

  /* Free up variables */
  if (parts)
     di$free (lines = parts, count = part_count);

  if (attach)
     free(attach);

  if (load)
     free(load);

  if (entry)
     free(entry);

  if (refid)
     free(refid);

  if (delete_flag)
     free(delete_flag);

  return(TRUE);
 }


/*
 * This function maps a ref. id. to its corresponding display info. in the 
 * assembly structure.
 */

IGRint  PDUmap_refid_to_assembly(
                                 mod_env,
                                 refid_string,
                                 part_id,
                                 displayed,
                                 loaded,
                                 depth
                                )

 struct GRmd_env     *mod_env;                /* INPUT */
 IGRchar             refid_string[20];        /* INPUT */
 struct GRid         *part_id;                /* INPUT */
 IGRboolean          *displayed;              /* OUTPUT */
 IGRboolean          *loaded;                 /* OUTPUT */
 IGRint              depth;                   /* INPUT */
 {
  IGRint             status = PDM_S_SUCCESS;
  IGRlong            msg; 
  IGRchar            child_no[MAX_VALUE];
  IGRint             type;
  IGRchar            parentid_string[20];
  IGRint             count = 0;
  IGRint             part_count = 0;
  IGRchar            assy_path[DI_PATH_MAX];
  IGRchar            child_path[DI_PATH_MAX];
  IGRchar            **parts = NULL;
  IGRchar            *entry = NULL;
  IGRchar            *attach = NULL;
  IGRchar            *refid = NULL;
  IGRchar            *load = NULL;
  IGRchar            *file_name = NULL;
  IGRint             i;
  IGRint             j;


  _pdm_debug("In the PDUmap_refid_to_assembly function", 0);

  
  if (!part_id)
     {
      _pdm_debug("part id is NULL", 0);
      return(0);
     }

  /* Extarct part child no from PDU GRpart */
  co$part_get_attr(
                   msg = &msg,
                   mod_env = mod_env,
                   part = part_id,
                   attr = "child_no",
                   value = child_no,
                   type = &type
                  );

  /* Unquote child_no value */
  PDUunquote(child_no);

  _pdm_debug("child no is <%s>", child_no);

  /* Find ref. id parent */
  parentid_string[0] = '\0';
  status = PDUfind_refid_parent(
                                refid_string,
                                parentid_string
                               );
  _pdm_status("PDUfind_refid_parent", status);

  if (status != PDM_S_SUCCESS)
     {
      _pdm_debug("PDUfind_refid_parent failed", 0);
      return(0);
     }

  /* Construct path to assembly structure in active object space */
  di$give_pathname(
                   osnum = mod_env->md_id.osnum,
                   pathname = assy_path
                  );
  strcat(assy_path, ":ASSEMBLY");

  /* Get part in assembly structure that matches parentid_string */
  status = di$find(
                   start_dir = assy_path,
                   regexp = "P*",
                   lines = &parts,
                   ptr = &part_count,
                   max_level = -1
                  );

  if (status != DIR_S_SUCCESS)
     {
      _pdm_debug("SEVERE error: di$find failed", 0);
      return(0);
     }

  if (part_count <= 0)
     {
      _pdm_debug("no parts were found in assembly structure", 0);
      return(0);
     }

  for (i = 0; i < part_count; ++i)
      {
       /* Drop last ":" from entry */
       _pdm_debug("parts[i] = <%s>", parts[i]);

       PDUfill_in_string(&entry, parts[i]);

       PDUstrip_dir_entry(entry);

       /* Extract value for part refid attribute */
       status = PDUevaluate_exp(
                                entry,
                                "refid",
                                &refid
                               );

       if (status == PDM_S_SUCCESS)
          {
           _pdm_debug("refid = <%s>", refid);
           _pdm_debug("parentid_string = <%s>", parentid_string);
           /* Check if there is a match */
           if (strcmp(refid, parentid_string) != 0)
              {
               _pdm_debug("skip to next entry", 0);
               continue;
              }

           _pdm_debug("a match was found", 0);
           _pdm_debug("parent assy. path = <%s>", entry);

           /* Construct child assy. path */
           strcpy(child_path, entry);
           strcat(child_path, ":");
           strcat(child_path, "P");
           strcat(child_path, child_no);

           _pdm_debug("child assy. path = <%s>", child_path);

           /* Check to see if child_path exists */
           count = 0;
           status = di$ls(regexp = child_path, ptr = &count);

           if (count <= 0)
              {
               _pdm_debug("child path was not found");
               status = PDUfind_next_parent(parentid_string, (depth - 1));
               _pdm_status("PDUfind_next_parent", status);
               _pdm_debug("parentid_string = <%s>", parentid_string);
               for (j = 0; j < part_count; ++j)
                  {
                  /* Drop last ":" from entry */
                  _pdm_debug("parts[j] = <%s>", parts[j]);

                  PDUfill_in_string(&entry, parts[j]);

                  PDUstrip_dir_entry(entry);

                  /* Extract value for part refid attribute */
                  status = PDUevaluate_exp(
                                entry,
                                "refid",
                                &refid
                               );
                  if (strcmp(refid, parentid_string) == 0)
                    {
                    strcpy(child_path, entry);
                    strcat(child_path, ":");
                    strcat(child_path, "P");
                    strcat(child_path, child_no);
                    count = 0;
                   status = di$ls(regexp = child_path, ptr = &count);
                   if (count <= 0)
                   return(0);
                   }
                 }
              }

           /* Extract the corresponding attached attribute */
           status = PDUevaluate_exp(
                                    child_path,
                                    "attached",
                                    &attach
                                   );

           if (status != PDM_S_SUCCESS)
              {
               _pdm_debug("SEVERE error: PDUevaluate_exp failed on attached attr", 0);
               return(0);
              }

           status = PDUevaluate_exp(
                                    child_path,
                                    "file_name",
                                    &file_name
                                   );

           if (status != PDM_S_SUCCESS)
              {
               _pdm_debug("SEVERE error: PDUevaluate_exp failed on attached attr", 0);
               return(0);
              }
           _pdm_debug("extracted attached value = <%s>", attach);

           /* Extract the corresponding loaded attribute */
           status = PDUevaluate_exp(
                                    child_path,
                                    "loaded",
                                    &load
                                   );

           if (status != PDM_S_SUCCESS)
              {
               _pdm_debug("SEVERE error: PDUevaluate_exp failed on loaded attr", 0);
               return(0);
              }

           _pdm_debug("extracted loaded value = <%s>", load);

           status = PDUis_filename_to_be_loaded(assy_path,file_name);
           _pdm_status("PDUis_filename_to_be_loaded", status);
           if (status)
             {
             PDUfill_in_string(&load, "Y");
             _pdm_debug("new loaded value = <%s>", load);
             status = PDUmodify_exp(
                                  0,
                                  child_path,
                                  "loaded",
                                  load,
                                  mod_env->md_id.osnum
                                 );
             }
    
            status = PDUverify_file(file_name);
            if (status != PDM_S_SUCCESS)
             status = PDUmodify_exp(
                                  0,
                                  child_path,
                                  "loaded",
                                  "Y",
                                  mod_env->md_id.osnum
                                 );

           /* Set displayed property in the reffile object */
           if (strcmp(attach, "N") == 0)
              {
               _pdm_debug("setting reffile displayed to FALSE", 0);
               *displayed = FALSE;
              }

           else
               {
                _pdm_debug("setting reffile displayed to TRUE", 0);
                *displayed = TRUE;
               }

           /* Set loaded property in the reffile object */
           if (strcmp(load, "N") == 0)
              {
               _pdm_debug("setting reffile loaded to FALSE", 0);
               *loaded = FALSE;
              }

           else
               {
                _pdm_debug("setting reffile loaded to TRUE", 0);
                *loaded = TRUE;
               }

           /* Update refid attribute */
           status = PDUmodify_exp(
                                  0,
                                  child_path,
                                  "refid",
                                  refid_string,
                                  mod_env->md_id.osnum
                                 );

           /* Store part path in processed parts list */
           /*
           PDUadd_path_node(child_path);
           */

           /* Free up variables */
           if (parts)
               di$free (lines = parts, count = part_count);

           if (attach)
              free(attach);

           if (load)
              free(load);

           if (entry)
              free(entry);

           if (refid)
              free(refid);

           return(PDM_S_SUCCESS);
          }

      } /* end for i loop */
 
  return(0);
 }


/*
 * This function finds the parent of a given ref. id.
 */

IGRint  PDUfind_refid_parent(
                             child_id,
                             parent_id
                            )

 IGRchar          child_id[20];              /* INPUT */
 IGRchar          parent_id[20];             /* OUTPUT */
 {
  struct PDUref_info_node         *head = NULL;

  _pdm_debug("In the PDUfind_refid_parent function", 0);

  /* Search ref. info. link list for a matching child */
  head = PDU_ref_parent_child_list;

  if (!head)
     {
      _pdm_debug("PDU_ref_parent_child_list is NULL", 0);
      return(0);
     }

  while (head)
        {
         if (strcmp(head->refid, child_id) == 0)
            {
             _pdm_debug("a match was found on child", 0);
            
             /* Check to see if parent is a PDU part */
             if (head->PDUpart)
                {
                 /* Return parent id */
                 strcpy(parent_id, head->parent_id);
                 return(PDM_S_SUCCESS);
                }
            }

         /* Process next node */
         head = head->next;
        } /* end while loop */

  return(0);
 }


/*
 * This function frees up PDU_part_path_list link list.
 */

void  PDUfree_path_list()
 {
  struct PDUpath_list         *head = NULL;

  _pdm_debug("In the PDUfree_path_list function", 0);

  if (PDU_part_path_list)
     {
      head = PDU_part_path_list;

      while (PDU_part_path_list)
            {
             PDU_part_path_list = PDU_part_path_list->next;
             free(head);
             head = PDU_part_path_list;
            } /* end while loop */

      PDU_part_path_list = NULL;
     }
 }


/* 
 * This function frees up PDU_ref_parent_child_list link list.
 */

void  PDUfree_refid_list()
 {
  struct PDUref_info_node         *head = NULL;

  _pdm_debug("In the PDUfree_refid_list function", 0);

  if (PDU_ref_parent_child_list)
     {
      head = PDU_ref_parent_child_list;

      while (PDU_ref_parent_child_list)
            {
             PDU_ref_parent_child_list = PDU_ref_parent_child_list->next;
             free(head);
             head = PDU_ref_parent_child_list;
            } /* end while loop */

      PDU_ref_parent_child_list = NULL;
     }
 }


/*
 * This function manages the display of an assembly.
 */

IGRint  PDUprocess_assembly_display(
                                    mod_env,
                                    assy_struct_bufr,
                                    display,
                                    display_mode,
                                    update_display
                                   )

 struct GRmd_env  *mod_env;             /* INPUT */
 MEMptr           assy_struct_bufr;     /* INPUT */
 IGRshort         display;              /* INPUT */
 IGRshort         display_mode;         /* INPUT */
 IGRshort         update_display;       /* INPUT */

 {
  IGRlong        status = PDM_S_SUCCESS;
  IGRshort       free_mod = FALSE;
  IGRint         bufsiz;
  MEMptr         copy_attach_buffer = NULL;
  MEMptr         status_buffer = NULL;

  _pdm_debug("In the PDUprocess_assembly_display function", 0);

  /* Default module env. to current if mod_env is NULL */
  if (!mod_env)
     {
      mod_env = (struct GRmd_env *) malloc(sizeof(struct GRmd_env));
      bufsiz = sizeof(struct GRmd_env);
      gr$get_module_env(sizbuf = &bufsiz, buffer = mod_env);
      free_mod = TRUE;
     }

  /* Check to see if assembly buffer is loaded. */
  if (display)
     {
      if (!assy_struct_bufr)
         {
          _pdm_debug("SEVERE error: assy_struct_bufr is NULL", 0);
          return(0);
         }

      if (assy_struct_bufr->rows > 1)
         {
          /* Upadte display attr. in assembly structure */
          status = PDUupdate_display_in_assembly(
                                                 mod_env,
                                                 assy_struct_bufr
                                                );
          _pdm_status("PDUupdate_display_in_assembly", status);

          if (status != PDM_S_SUCCESS)
             {
              _pdm_debug("PDUupdate_display_in_assembly failed", 0);
              return(0);
             }
         }

      else
          {
           _pdm_debug("part is atomic", 0);
           return(PDM_S_SUCCESS);
          }
     }

  /* Update load structure in assembly */
  status = PDUupdate_load_in_assembly(mod_env);
  _pdm_status("PDUupdate_load_in_assembly", status);

  if (status != PDM_S_SUCCESS)
     {
      _pdm_debug("PDUupdate_load_in_assembly failed", 0);
      return(0);
     }

  /* Check to see if assembly files need to be copied to local */
  status = PDUload_copy_attach_buffer(
                                      mod_env,
                                      -1,
                                      &copy_attach_buffer
                                     );
  _pdm_status("PDUload_copy_attach_buffer", status);

  if (status != PDM_S_SUCCESS)
     {
      _pdm_debug("PDUload_copy_attach_buffer failed", 0);
      return(0);
     }

  if (display_mode)
     {
      /* Design time */
      if (copy_attach_buffer)
         {
          if (copy_attach_buffer->rows > 0)
             {

              status = PDMcopy_attach(
                                      copy_attach_buffer,
                                      &status_buffer
                                     );
              _pdm_status("PDMcopy_attach", status);

              if (status != PDM_S_SUCCESS)
                 {
                  if (status == PDM_E_CMD_CANCELLED)
                     {
                      _pdm_debug("command was cancelled", 0);
                      return(PDM_S_SUCCESS);
                     }

                  _pdm_debug("SEVERE error: PDMcopy_attach failed", 0);
                  return(0);
                 }

              /* Flag assembly parts */
              status = PDUflag_local_parts_in_assembly(
                                                       mod_env,
                                                       "D",
                                                       copy_attach_buffer
                                                      );
              _pdm_status("PDUflag_local_parts_in_assembly", status);

              if (status != PDM_S_SUCCESS)
                 {
                  _pdm_debug("PDUflag_local_parts_in_assembly failed", 0);
                  return(0);
                 }
             }
         }

      if (update_display)
         {
          /* Update assembly display */
          status = PDUupdate_part_display(mod_env);
          _pdm_status("PDUupdate_part_display", status);

          if (status != PDM_S_SUCCESS)
             {
              _pdm_debug("PDUupdate_part_display failed", 0);
              return(0);
             }
         }
     }

  else
      {
       /* Checkout time */
       if (copy_attach_buffer)
          {
           if (copy_attach_buffer->rows > 0)
              {
               if (PDM_debug_on)
                 MEMprint_buffer("copy_attach_buffer", copy_attach_buffer, 
                                 PDU_DEBUG_FILE); 
               status = PDMRetrieveAssyFiles(
                                             copy_attach_buffer,
                                             &status_buffer
                                            );
               _pdm_status("PDMRetrieve_AssyFiles", status);

               if (status != PDM_S_SUCCESS)
                  {
                   if (status == PDM_E_CMD_CANCELLED)
                      {
                       _pdm_debug("command was cancelled", 0);
                       return(PDM_S_SUCCESS);
                      }

                   _pdm_debug("SEVERE error: PDMRetrieve_AssyFiles failed", 0);
                   return(0);
                  }

               /* Flag assembly parts */
               status = PDUflag_local_parts_in_assembly(
                                                        mod_env,
                                                        "C",
                                                        copy_attach_buffer
                                                       );
               _pdm_status("PDUflag_local_parts_in_assembly", status);

               if (status != PDM_S_SUCCESS)
                  {
                   _pdm_debug("PDUflag_local_parts_in_assembly failed", 0);
                   return(0);
                  }
              }
          }
      }

  /* Free up variables */
  if (free_mod)
     {
      free(mod_env);
      mod_env = NULL;
     }

  if (copy_attach_buffer)
     MEMclose(&copy_attach_buffer);

  return(PDM_S_SUCCESS);
 }
                       


/*
 * This function updates the local_flag attribute in the assembly structure.
 */

IGRint  PDUupdate_local_flag_in_assembly(mod_env)

 struct GRmd_env  *mod_env;             /* INPUT */

 {
  IGRlong        status = PDM_S_SUCCESS;
  IGRchar        assy_path[DI_PATH_MAX];
  IGRchar        **parts = NULL;
  IGRint         part_count = 0;
  IGRchar        *file_name = NULL;
  IGRchar        *file = NULL;
  IGRchar        *local_flag = NULL;
  IGRchar        *level = NULL;
  IGRchar        *next_level = NULL;
  IGRint         i, j;
  IGRshort       free_mod = FALSE;
  IGRint         bufsiz;

  _pdm_debug("In the PDUupdate_local_flag_in_assembly function", 0);

  /* Default module env. to current if mod_env is NULL */
  if (!mod_env)
     {
      mod_env = (struct GRmd_env *) malloc(sizeof(struct GRmd_env));
      bufsiz = sizeof(struct GRmd_env);
      gr$get_module_env(sizbuf = &bufsiz, buffer = mod_env);
      free_mod = TRUE;
     }

  /* Construct path to assembly structure */
  di$give_pathname(
                   osnum = mod_env->md_id.osnum,
                   pathname = assy_path
                  );

  strcat(assy_path, ":ASSEMBLY");

  /* Extract list of DIrectory objects from given assembly path */
  status = di$find (
                    start_dir = assy_path,
                    regexp = "P*",
                    lines = &parts,
                    ptr = &part_count,
                    max_level = -1
                   );

  if (part_count > 0)
     {
      for (i = 0; i < part_count; ++i)
          {
           /* Get ith part local_flag attr. */
           PDUstrip_dir_entry(parts[i]);
           _pdm_debug("<<< comparing local_flag for <%s> >>>", parts[i]);
           status = PDUevaluate_exp(
                                    parts[i],
                                    "local_flag",
                                    &local_flag
                                   );

           if (status != PDM_S_SUCCESS)
              {
               _pdm_debug("could not evaluate local_flag attr.", 0);
               return(0);
              }
           _pdm_debug("local_flag = <%s>", local_flag);

           if (strcmp(local_flag, "") == 0)
              {
               _pdm_debug("entering inner loop: i = %d", i);
               for (j = 0; j < part_count; ++j)
                   {
/* MJG - 11/9/95 - If the parts are equal, continue */
                   if (strcmp(parts[i], parts[j]) == 0)
                     {
                     _pdm_debug("don't compare part to itself; CONTINUE", 0);
                     continue;
                     }

                    /* Get ith part file_name attr. */
                    PDUstrip_dir_entry(parts[j]);
                    status = PDUevaluate_exp(
                                             parts[i],
                                             "file_name",
                                             &file_name
                                            );

                    if (status != PDM_S_SUCCESS)
                       {
                        _pdm_debug("could not evaluate file_name attr.", 0);
                        return(0);
                       }
                    _pdm_debug("first file_name = <%s>", file_name);

/* MJG - 11/9/95 - if the filename is blank, the local flag will always be
   blank, and thus does not need to be modified. BREAK if the filename is
   blank.
*/
                    if ((file_name) && (!strlen(file_name)))
                      {
                      _pdm_debug("filename is empty; BREAK", 0);
                      break;
                      }

                    /* Get jth part local_flag attr. */
                    status = PDUevaluate_exp(
                                             parts[j],
                                             "local_flag",
                                             &local_flag
                                            );

                    if (status != PDM_S_SUCCESS)
                       {
                        _pdm_debug("could not evaluate local_flag attr.", 0);
                        return(0);
                       }
                    _pdm_debug("local_flag = <%s>", local_flag);

                    /* Get jth part file_name attr. */
                    status = PDUevaluate_exp(
                                             parts[j],
                                             "file_name",
                                             &file
                                             );

                    if (status != PDM_S_SUCCESS)
                       {
                        _pdm_debug("could not evaluate file_name attr.", 0);
                        return(0);
                       }
                    _pdm_debug("second file_name = <%s>", file);

                    if ( (strcmp(file, file_name) == 0) &&
                         (strcmp(local_flag, "") != 0) )
                       {
                       _pdm_debug("<<< modifying local flag >>>", 0);
                        /* Modify ith part local_flag attr. */
                        PDUmodify_exp(
                                      0,
                                      parts[i],
                                      "local_flag",
                                      local_flag,
                                      mod_env->md_id.osnum
                                     );
/* MJG - 11/9/95 - Break after modifying the local flag */
                       _pdm_debug("BREAK after modify", 0);
                       break;
                       }

                   } /* end for j loop */
              _pdm_debug("exiting inner loop");
              }
/* MJG - 11/9/95 - If the local flag for the parent has already been set, it 
   can be assumed that it has also been set for the attachments.  Skip these 
   parts.
*/
            else
              {
              _pdm_debug("file has already been checked; bypassing children", 0);
              /* Get ith part level attr. */
              status = PDUevaluate_exp(
                                       parts[i],
                                       "level",
                                       &level
                                      );

              if (status != PDM_S_SUCCESS)
                 {
                  _pdm_debug("could not evaluate level attr.", 0);
                  return(0);
                 }
              _pdm_debug("level = <%s>", level);

              PDUfill_in_string(&next_level, NULL_STRING);

              while (strcmp(level, next_level) != 0)
                {
                i = i + 1;
                if (i >= part_count)
                  {
                  _pdm_debug("reached end of array; breaking", 0);
                  break;
                  }

                _pdm_debug("calling PDUstrip_dir_entry", 0);
                PDUstrip_dir_entry(parts[i]);
                /* Get ith part level attr. */
                status = PDUevaluate_exp(
                                         parts[i],
                                         "level",
                                         &next_level
                                        );
  
                if (status != PDM_S_SUCCESS)
                   {
                    _pdm_debug("could not evaluate level attr.", 0);
                    return(0);
                   }
                _pdm_debug("next_level = <%s>", next_level);
                }
              /* reset i */
              i = i - 1;
              }

          } /* end for i loop */

      /* Free up variables */
      if (file_name)
         free(file_name);

      if (file)
         free(file);

      if (local_flag)
         free(local_flag);

      if (level)
         free(level);

      if (next_level)
         free(next_level);

      if (parts)
         di$free(lines = parts, count = part_count);

      if (free_mod)
         {
          free(mod_env);
          mod_env = NULL;
         }
     }

  else
      {
       _pdm_debug("no parts found in assembly", 0);
       return(PDM_S_SUCCESS);
      }

  return(PDM_S_SUCCESS);
 }


/*
 * This function given a reference object id, it will return the PDU GRpart
 * that owns it, if any.
 */

IGRint  PDUget_context_from_refid(
                                  ref_id,
                                  context_id
                                 )

 struct GRid      *ref_id;               /* INPUT */
 struct GRid      *context_id;           /* OUTPUT */

 {
  IGRlong             msg;
  OMuint              chan_count = 0;
  OMuint              obj_count = 0;
  OM_S_CHANSELECT     chan;
  OM_S_OBJECT_LINKAGE *list = NULL;
  IGRint              i;


  _pdm_debug("In the PDUget_context_from_refid function", 0);

  if (ref_id)
     {
      /* Set channel indices */
      chan.type = OM_e_name;
      chan.u_sel.name = "GRreffile.to_context";

      om$get_channel_count(
                           osnum = ref_id->osnum,
                           objid = ref_id->objid,
                           p_chanselect = &chan,
                           count = &chan_count
                          );

      if (chan_count > 0)
         {
          /* Allocate memory for the list of objects */
          list = (OM_S_OBJECT_LINKAGE *)
                              malloc(sizeof(OM_S_OBJECT_LINKAGE) * chan_count);

          /* Get the context object */
          msg = om$get_channel_objects(
                                       objid = ref_id->objid,
                                       osnum = ref_id->osnum,
                                       p_chanselect = &chan,
                                       list = list,
                                       size = chan_count,
                                       count = &obj_count
                                      );

          if (! (1 & msg ))
             {
              _pdm_debug("om$get_channel_objects failed", 0);
              return(0);
             }

          for (i = 0; i < obj_count; ++i)
              {
               if ( list[i].osnum == ref_id->osnum )
                  {
                   /* Load context object */
                   context_id->osnum = list[i].osnum;
                   context_id->objid = list[i].S_objid;

                   return(PDM_S_SUCCESS);
                  }

              } /* end for loop */
         }

      else
          {
           _pdm_debug("ref id %d does not have no context", ref_id->objid);
           return(0);
          }
     }

  return(0);
 }


/*
 * This function prints out the contents of path link list.
 */

IGRint  PDUprint_parent_child_list()
  {
   struct     PDUref_info_node  *head = NULL;

   _pdm_debug("In the PDUprint_parent_child_list function",0);

   head = PDU_ref_parent_child_list;

   if (!head)
      {
       _pdm_debug("parent child list is empty", 0);
       return(PDM_S_SUCCESS);
      }

   _pdm_debug("parent child list",0);

   while(head)
        {
         _pdm_debug(" ", 0);
         _pdm_debug("child level = %d", head->level);
         _pdm_debug("child refid = <%s>", head->refid);
         _pdm_debug("is child a PDU part = %d", head->PDUpart);
         _pdm_debug("parent ref id = <%s>", head->parent_id);
         _pdm_debug("was part found = %d", head->part_found);
         _pdm_debug("******************************************************",0);

         head = head->next;
        }

   return(PDM_S_SUCCESS);
  }


/* 
 * This function constructs the PDUasmmgr object in the active object space.
 */

IGRint PDUconstruct_asm_mgr_object(
                                   mod_env,
                                   super_object
                                  )
  struct GRmd_env *mod_env;            /* INPUT */
  struct GRid     *super_object;       /* OUTPUT */
  {
   IGRlong        status = PDM_S_SUCCESS;
   IGRshort       free_mod = FALSE;
   IGRint         bufsiz;

   _pdm_debug("In the PDUconstruct_asm_mgr_object function", 0);

   /* Default module env. to current if mod_env is NULL */
   if (!mod_env)
      {
       mod_env = (struct GRmd_env *) malloc(sizeof(struct GRmd_env));
       bufsiz = sizeof(struct GRmd_env);
       gr$get_module_env(sizbuf = &bufsiz, buffer = mod_env);
       free_mod = TRUE;
      }

   /* Construct PDU asm. mgr. super */
   status = ex$get_super (
                          mod_id = mod_env->md_id.objid,
                          mod_osnum = mod_env->md_id.osnum,
                          super_name = "PDUasmmgr",
                          create = TRUE,
                          super_class = "PDUasmmgr",
                          super_id = &(super_object->objid),
                          super_osnum = &(super_object->osnum)
                         );

   if (status != OM_S_SUCCESS)
      {
       _pdm_debug("ex$get_super failed", 0);
       return(0);
      }

   /* Free variables */
   if (free_mod)
      {
       free(mod_env);
       mod_env = NULL;
      }

   return(PDM_S_SUCCESS);
  }


/*
 * This function detects any changes to the assembly structure stored in
 * the object space when a newer version of a ref. file is loaded.
 */

IGRint PDUdetect_assembly_change(mod_env)

 struct GRmd_env  *mod_env;             /* INPUT */
  {
   IGRlong                   status = PDM_S_SUCCESS;
   struct PDUref_info_node   *head1 = NULL;
   struct PDUpath_list       *head2 = NULL;
   IGRshort                  change = FALSE;
   IGRshort                  found = FALSE;
   IGRint                    i;
   IGRchar                   assy_path[DI_PATH_MAX];
   IGRchar                   **parts = NULL;
   IGRint                    part_count = 0;
   IGRshort                  free_mod = FALSE;
   IGRint                    bufsiz;

   _pdm_debug("In the PDUdetect_assembly_change function", 0);

   /* Default module env. to current if mod_env is NULL */
   if (!mod_env)
      {
       mod_env = (struct GRmd_env *) malloc(sizeof(struct GRmd_env));
       bufsiz = sizeof(struct GRmd_env);
       gr$get_module_env(sizbuf = &bufsiz, buffer = mod_env);
       free_mod = TRUE;
      }

   if (PDU_ref_parent_child_list)
      {
       head1 = PDU_ref_parent_child_list;

       while (head1)
             {
              if ( (head1->PDUpart) && !(head1->part_found) )
                 {
                  _pdm_debug("an assembly change was detected", 0);
                  
                  change = TRUE;
                  break;
                 }

              /* Process next node */
              head1 = head1->next;

             } /* end while loop */
      }

   if (!change)
      {
       if (PDU_part_path_list)
          {
           /* Construct path to assembly structure */
           di$give_pathname(
                            osnum = mod_env->md_id.osnum,
                            pathname = assy_path
                           );

           strcat(assy_path, ":ASSEMBLY");

           /* Extract list of DIrectory objects from given assembly path */
           status = di$find (
                             start_dir = assy_path,
                             regexp = "P*",
                             lines = &parts,
                             ptr = &part_count,
                             max_level = -1
                            );

           if (part_count > 0)
              {
               for (i = 0; i < part_count; ++i)
                   {
                    PDUstrip_dir_entry(parts[i]);
                    head2 = PDU_part_path_list;
                    found = FALSE;

                    while (head2)
                          {
                           if (strcmp(parts[i], head2->path) == 0)
                              {
                               found = TRUE;
                               break;
                              }

                           /* Process next node */
                           head2 = head2->next;

                          } /* end while loop */

                    if (!found)
                       {
                        _pdm_debug("an assembly change was detected", 0);

                        change = TRUE;
                        break;
                       }

                    } /* end for i loop */
              }

           else
               {
                _pdm_debug("no parts found in assembly", 0);

                /* Free up variables */
                if (free_mod)
                   {
                    free(mod_env);
                    mod_env = NULL;
                   }
               
                PDUfree_refid_list();
                PDUfree_path_list();

                return(PDM_S_SUCCESS);
               }
          }
      }
  
   /* Display message to user for notification */
   if (change)
      {
       printf("an assembly change was detected\n");
      }

   /* Free up variables */
   if (free_mod)
      {
       free(mod_env);
       mod_env = NULL;
      }

   /* Free up parts and part_count */
   if ( parts)
      {
       di$free (lines = parts, count = part_count);
      }

   PDUfree_refid_list();
   /*
   PDUfree_path_list();
   */
 
   return(PDM_S_SUCCESS);
  }

IGRint PDUis_filename_to_be_loaded(assy_path, file_name)

char *assy_path;
char *file_name;

  {
  
  IGRint             status = PDM_S_SUCCESS;
  IGRint             part_count = 0;
  IGRchar            **parts = NULL;
  IGRchar            *entry = NULL;
  IGRchar            *load = NULL;
  IGRchar            *tmp_file = NULL;
  IGRint             i;
  IGRint             loaded = FALSE;

  _pdm_debug("In PDUis_filename_to_be_loaded, file = <%s>", file_name);

  status = di$find(
                   start_dir = assy_path,
                   regexp = "P*",
                   lines = &parts,
                   ptr = &part_count,
                   max_level = -1
                  );

  if (status != DIR_S_SUCCESS)
     {
      _pdm_debug("SEVERE error: di$find failed", 0);
      return(0);
     }

  if (part_count <= 0)
     {
      _pdm_debug("no parts were found in assembly structure", 0);
      return(0);
     }

  for (i = 0; i < part_count; ++i)
      {
       /* Drop last ":" from entry */
       _pdm_debug("parts[i] = <%s>", parts[i]);

       PDUfill_in_string(&entry, parts[i]);

       PDUstrip_dir_entry(entry);

       /* Extract value for part refid attribute */
       status = PDUevaluate_exp(
                                entry,
                                "file_name",
                                &tmp_file
                               );

       if (status == PDM_S_SUCCESS)
          {
           _pdm_debug("tmpfile = <%s>", tmp_file);
           /* Check if there is a match */
           if (strcmp(file_name, tmp_file) != 0)
              {
               _pdm_debug("skip to next entry", 0);
               continue;
              }

           _pdm_debug("a match was found", 0);

           /* Extract the corresponding loaded attribute */
           status = PDUevaluate_exp(
                                    entry,
                                    "loaded",
                                    &load
                                   );

           if (status != PDM_S_SUCCESS)
              {
               _pdm_debug("SEVERE error: PDUevaluate_exp failed on loaded attr", 0);
               return(0);
              }

           _pdm_debug("extracted loaded value = <%s>", load);

           /* Set loaded property in the reffile object */
           if (strcmp(load, "Y") == 0)
              {
              loaded = TRUE;
              break;
              }

           else
             {
              loaded = FALSE;
             }

           }
        }
      if (parts)
        di$free (lines = parts, count = part_count);

      if (load)
        free(load);

      if (entry)
        free(entry);

      if (tmp_file)
        free(tmp_file);
    
     return(loaded);
     }

IGRint  PDUupdate_refids_in_assembly(mod_env,filename, refid_string)

 struct GRmd_env  *mod_env;             /* INPUT */
 char  *filename;             /* INPUT */
 char *refid_string;


 {
  IGRlong        status = PDM_S_SUCCESS;
  IGRchar        assy_path[DI_PATH_MAX];
  IGRchar        **parts = NULL;
  IGRint         part_count = 0;
  IGRchar        *file_name = NULL;
  IGRchar        *refid = NULL;
  IGRchar        *level = NULL;
  IGRint         i;
  IGRshort       free_mod = FALSE;
  IGRint         bufsiz;

  _pdm_debug("In the PDUupdate_refids_in_assembly function", 0);

  /* Default module env. to current if mod_env is NULL */
  if (!mod_env)
     {
      mod_env = (struct GRmd_env *) malloc(sizeof(struct GRmd_env));
      bufsiz = sizeof(struct GRmd_env);
      gr$get_module_env(sizbuf = &bufsiz, buffer = mod_env);
      free_mod = TRUE;
     }

  /* Construct path to assembly structure */
  di$give_pathname(
                   osnum = mod_env->md_id.osnum,
                   pathname = assy_path
                  );

  strcat(assy_path, ":ASSEMBLY");

  /* Extract list of DIrectory objects from given assembly path */
  status = di$find (
                    start_dir = assy_path,
                    regexp = "P*",
                    lines = &parts,
                    ptr = &part_count,
                    max_level = -1
                   );

  if (part_count > 0)
     {
      for (i = 0; i < part_count; ++i)
          {
           /* Get ith part local_flag attr. */
           PDUstrip_dir_entry(parts[i]);
           status = PDUevaluate_exp(
                                    parts[i],
                                    "level",
                                    &level
                                   );

           if (status != PDM_S_SUCCESS)
              {
               _pdm_debug("could not evaluate local_flag attr.", 0);
               return(0);
              }

           if (strcmp(level, "1") != 0)
              {
              status = PDUevaluate_exp(
                                       parts[i],
                                       "file_name",
                                       &file_name
                                            );

               if (status != PDM_S_SUCCESS)
                 {
                  _pdm_debug("could not evaluate file_name attr.", 0);
                  return(0);
                  }

               status = PDUevaluate_exp(
                                        parts[i],
                                        "refid",
                                        &refid
                                       );

               if (status != PDM_S_SUCCESS)
                 {
                  _pdm_debug("could not evaluate local_flag attr.", 0);
                  return(0);
                  }

                if ( (strcmp(filename, file_name) == 0) &&
                     (strcmp(refid, "") == 0) )
                       {
                        /* Modify ith part local_flag attr. */
                        PDUmodify_exp(
                                      0,
                                      parts[i],
                                      "refid",
                                      refid_string,
                                      mod_env->md_id.osnum
                                     );
                       }

              }

          } /* end for i loop */

      /* Free up variables */
      if (file_name)
         free(file_name);

      if (refid)
        free(refid);

      if (parts)
         di$free(lines = parts, count = part_count);

      if (free_mod)
         {
          free(mod_env);
          mod_env = NULL;
         }
     }

  else
      {
       _pdm_debug("no parts found in assembly", 0);
       return(PDM_S_SUCCESS);
      }

  return(PDM_S_SUCCESS);
 }

IGRint  PDUfind_next_parent(
                             parent_id,
                             depth
                            )

 IGRchar          parent_id[20];             /* OUTPUT */
 IGRint           depth;
 {
  struct PDUref_info_node         *head = NULL;
  IGRchar         tmp_id[20];

  _pdm_debug("In the PDUfind_next_parent function", 0);

  /* Search ref. info. link list for a matching child */
  head = PDU_ref_parent_child_list;

  if (!head)
     {
      _pdm_debug("PDU_ref_parent_child_list is NULL", 0);
      return(0);
     }

  while (head)
        {
         if (strcmp(head->refid, parent_id) == 0)
           {
           strcpy(parent_id, tmp_id);
           return(PDM_S_SUCCESS);
           }
         else if (head->level == depth)
            {
             _pdm_debug("a match was found on child", 0);
            
             /* Check to see if parent is a PDU part */
             if (head->PDUpart)
                {
                 /* Return parent id */
                 strcpy(tmp_id, head->refid);
                }
            }

         /* Process next node */
         head = head->next;
        } /* end while loop */

  return(0);
 }

IGRint  PDUchange_parentid_of_refid(
                             child_id,
                             parent_id
                            )

 IGRchar          child_id[20];              /* INPUT */
 IGRchar          parent_id[20];             /* INPUT */
 {
  struct PDUref_info_node         *head = NULL;

  _pdm_debug("In the PDUchange_parentid_of_refid function", 0);

  /* Search ref. info. link list for a matching child */
  head = PDU_ref_parent_child_list;

  if (!head)
     {
      _pdm_debug("PDU_ref_parent_child_list is NULL", 0);
      return(0);
     }

  while (head)
        {
         if (strcmp(head->refid, child_id) == 0)
            {
             _pdm_debug("a match was found on child", 0);
            
             /* Check to see if parent is a PDU part */
             if (head->PDUpart)
                {
                 /* Return parent id */
                 strcpy(head->parent_id,parent_id);
                 return(PDM_S_SUCCESS);
                }
            }

         /* Process next node */
         head = head->next;
        } /* end while loop */

  return(0);
 }
end implementation COpdu;
