class implementation COpdu;
/*
   This file contains all functions for creating and manipulating an  
   assembly structure. 

   Author: Jamal Shakra
   Date: 28-11-91
*/

/* Include file section */
#include        <stdio.h>
#include        <unistd.h>
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
#include        "MEMstruct.h"
#include        "MEMerrordef.h"
#include        "comnmacros.h"
#include        "ctype.h"
#include        "PDUuser.h"
#include        "PDUfile_def.h"
#include        "PDUgrpart.h"
#include        "PDUnode.h"
#include        "FI.h"
#include        "PDUforms.h"
#include        "exdef.h"
#include        "exmacros.h"
#include        "expriv.h"
#include        "PDUrev_str.h"


/* Global external variables */
extern  int      PDMdebug_on;

/* Global variables */
struct   PDUattach_node   *PDU_attach_info;

/* Imported messages */

/*
 * This function adds the assembly structure of a given part to that of 
 * the design part. The part info are loaded from a PDM buffer. 
 */
IGRint  PDUadd_assy_struct_from_buffer(
                                       mod_env,
                                       child_no,
                                       file_name,
                                       asm_struct_bufr,
                                       add_mode
                                      )
 struct GRmd_env *mod_env;            /* INPUT */
 IGRchar         *child_no;           /* INPUT */
 IGRchar         *file_name;          /* INPUT */
 MEMptr          asm_struct_bufr;     /* INPUT */
 IGRshort        add_mode;            /* INPUT */

 {
  IGRlong    status = PDM_S_SUCCESS;
  IGRchar    **asm_entry = NULL;
  IGRint     level_col;
  IGRint     parent_col;
  IGRint     child_col;
  IGRint     cat_col;
  IGRint     part_col;
  IGRint     rev_col;
  IGRint     desc_col;
  IGRint     usage_col;
  IGRint     quant_col;
  IGRint     attach_col;
  IGRint     file_col;
  IGRint     item_no_col;
  IGRint     cat_no_col;
  IGRint     part_type_col;
  IGRint     refid_col;
  IGRint     level_no;
  IGRint     count = 0;
  IGRchar    assy_path[DI_PATH_MAX];
  IGRchar    p_path[DI_PATH_MAX];
  IGRchar    part_path[DI_PATH_MAX];
  IGRchar    tmp_path[DI_PATH_MAX];
  IGRchar    level_no_str[10];
  IGRchar    *parent_no = NULL;
  IGRchar    *level = NULL;
  IGRchar    *child = NULL;
  IGRchar    *ptr = NULL;
  IGRshort   free_mod = FALSE;
  IGRint     bufsiz;
  IGRint     i;
  extern IGRchar *PDU_incl_ASM;

  _pdm_debug("In the PDUadd_assy_struct_from_buffer function", 0);

  /* Check to see if display buffer is NULL */
  if (!asm_struct_bufr)
     {
      _pdm_debug("assembly structure buffer is NULL", 0);
      return(PDM_S_SUCCESS);
     }
  
  if (asm_struct_bufr->rows > 0)
     {
      /* Extract part assembly info from buffer */
      MEMbuild_array(asm_struct_bufr);
      PDUsetup_buffer(
                      asm_struct_bufr,
                      ROW,
                      &asm_entry
                     );

      /* Extract level column no */
      PDUget_buffer_col(
                        asm_struct_bufr,
                        "p_level",
                        &level_col
                       );

      /* Extract parent no column no */
      PDUget_buffer_col(
                        asm_struct_bufr,
                        "p_pchildno",
                        &parent_col
                       );

      /* Extract child no column no */
      PDUget_buffer_col(
                        asm_struct_bufr,
                        "p_childno",
                        &child_col
                       );

      /* Extract catalog column no */
      PDUget_buffer_col(
                        asm_struct_bufr,
                        "n_catalogname",
                        &cat_col
                       );

      /* Extract part number column no */
      PDUget_buffer_col(
                        asm_struct_bufr,
                        "n_itemname",
                        &part_col
                       );

      /* Extract revision column no */
      PDUget_buffer_col(
                        asm_struct_bufr,
                        "n_itemrev",
                        &rev_col
                       );

      /* Extract description column no */
      PDUget_buffer_col(
                        asm_struct_bufr,
                        "n_itemdesc",
                        &desc_col
                       );

      /* Extract usage id column no */
      PDUget_buffer_col(
                        asm_struct_bufr,
                        "p_usageid",
                        &usage_col
                       );

      /* Extract quantity column no */
      PDUget_buffer_col(
                        asm_struct_bufr,
                        "p_quantity",
                        &quant_col
                       );

      /* Extract attachment column no */
      PDUget_buffer_col(
                        asm_struct_bufr,
                        "p_attached",
                        &attach_col
                       );

      /* Extract file name column no */
      PDUget_buffer_col(
                        asm_struct_bufr,
                        "n_cofilename",
                        &file_col
                       );

      /* Extract catalog no */
      PDUget_buffer_col(
                        asm_struct_bufr,
                        "n_ccatalogno",
                        &cat_no_col
                       );

      /* Extract item no */
      PDUget_buffer_col(
                        asm_struct_bufr,
                        "n_citemno",
                        &item_no_col
                       );

      /* Extract item no */
      PDUget_buffer_col(
                        asm_struct_bufr,
                        "p_parttype",
                        &part_type_col
                       );

      /* Extract item no */
      PDUget_buffer_col(
                        asm_struct_bufr,
                        "p_refid",
                        &refid_col
                       );
    }

 else
     {
      _pdm_debug("assembly structure buffer has no rows", 0);
      return(0);
     }

 /* Default module env. to current if mod_env is NULL */
 if (!mod_env)
    {
     mod_env = (struct GRmd_env *) malloc(sizeof(struct GRmd_env));
     bufsiz = sizeof(struct GRmd_env);
     gr$get_module_env(sizbuf = &bufsiz, buffer = mod_env);
     free_mod = TRUE;
    }

 /* Initialize paths */
 assy_path[0] = '\0';
 part_path[0] = '\0';
 p_path[0] = '\0';
 tmp_path[0] = '\0';

 /* Construct path to assembly structure */
 di$give_pathname(
                  osnum = mod_env->md_id.osnum,
                  pathname = assy_path
                 );

 strcat(assy_path, ":ASSEMBLY");
 strcpy(p_path, ":");

 if ((add_mode == 1) || (add_mode == 2)) /* 1- Placement time, 2- Copy time */
    {
     /* Make sure part is standard graphic */
     /* Commented out by JBP to allow non-graphic part placements */
      /*if ( (strcmp(asm_entry[part_type_col], "G") != 0) &&
           (strcmp(asm_entry[part_type_col], "g") != 0) )
         {
          _pdm_debug("encountered a non-graphic part", 0);

          if (free_mod)
             {
              free(mod_env);
              mod_env = NULL;
             }

          return(PDM_S_SUCCESS);
         }*/

     /* Need to create part's assembly structure */
     strcat(p_path, "P");
     strcat(p_path, child_no);
     strcat(p_path, ":");
     strcpy(part_path, assy_path);
     strcat(part_path, p_path);

     /* If entry exists, remove it */
     strcpy(tmp_path, part_path);
     PDUstrip_dir_entry(tmp_path);

     status = di$ls(regexp = tmp_path, ptr = &count);

     if ( (count > 0) && (status == DIR_S_SUCCESS) )
        {
         /* Remove entry */
         status = PDUremove_assembly(tmp_path, mod_env);
         _pdm_status("PDUremove_assembly", status);
        }

     /* Add part directory entry into assembly structure */
     status = di$mkpath(pathname = part_path);
     _pdm_status("di$mkpath", status);

     PDUstrip_dir_entry(part_path);

     /* Create part assembly info under this directory */
     PDUcreate_exp(
                   TEXT,
                   part_path,
                   "level",
                   "1",
                   mod_env->md_id.osnum
                  );

     PDUcreate_exp(
                   TEXT,
                   part_path,
                   "parent_no",
                   "0",
                   mod_env->md_id.osnum
                  );

     PDUcreate_exp(
                   TEXT,
                   part_path,
                   "child_no",
                   child_no,
                   mod_env->md_id.osnum
                  );

     PDUcreate_exp(
                   TEXT,
                   part_path,
                   "catalog_name",
                   asm_entry[cat_col],
                   mod_env->md_id.osnum
                  );

     PDUcreate_exp(
                   TEXT,
                   part_path,
                   "part_number",
                   asm_entry[part_col],
                   mod_env->md_id.osnum
                  );

     PDUcreate_exp(
                   TEXT,
                   part_path,
                   "revision",
                   asm_entry[rev_col],
                   mod_env->md_id.osnum
                  );

     PDUcreate_exp(
                   TEXT,
                   part_path,
                   "description",
                   asm_entry[desc_col],
                   mod_env->md_id.osnum
                  );

     PDUcreate_exp(
                   TEXT,
                   part_path,
                   "part_type",
                   asm_entry[part_type_col],
                   mod_env->md_id.osnum
                  );

     PDUcreate_exp(
                   TEXT,
                   part_path,
                   "attached",
                   asm_entry[attach_col],
                   mod_env->md_id.osnum
                  );

     PDUcreate_exp(
                   TEXT,
                   part_path,
                   "quantity",
                   asm_entry[quant_col],
                   mod_env->md_id.osnum
                  );

     PDUcreate_exp(
                   TEXT,
                   part_path,
                   "usage_id",
                   asm_entry[usage_col],
                   mod_env->md_id.osnum
                  );

     PDUcreate_exp(
                   TEXT,
                   part_path,
                   "file_name",
                   file_name,
                   mod_env->md_id.osnum
                  );

     PDUcreate_exp(
                   TEXT,
                   part_path,
                   "catalog_no",
                   asm_entry[cat_no_col],
                   mod_env->md_id.osnum
                  ); 

     PDUcreate_exp(
                   TEXT,
                   part_path,
                   "item_no",
                   asm_entry[item_no_col],
                   mod_env->md_id.osnum
                  );

     PDUcreate_exp(
                   TEXT,
                   part_path,
                   "loaded",
                   "N",
                   mod_env->md_id.osnum
                  );

     PDUcreate_exp(
                   TEXT,
                   part_path,
                   "refid",
                   "", 
                   mod_env->md_id.osnum
                  );

     PDUcreate_exp(
                   TEXT,
                   part_path,
                   "local_flag",
                   "",
                   mod_env->md_id.osnum
                  );

     PDUcreate_exp(
                   TEXT,
                   part_path,
                   "delete_flag",
                   "N",
                   mod_env->md_id.osnum
                  );
     
     strcpy(assy_path, part_path); 
     strcpy(p_path, ":");
    }

 /*if (((add_mode == 1) || (add_mode == 2)) && 
     ((strcmp(PDU_incl_ASM, "N") == 0) ||
     (strcmp(PDU_incl_ASM, "n") == 0)))
   return(PDM_S_SUCCESS);*/

 /* Loop in adding subassemblies to assembly structure */
 for (i = 1; i < asm_struct_bufr->rows; ++i)
     {
      /* Make sure part is standard graphic */
     /* Commented out by JBP to allow non-graphic part placements */
      /*if ( (strcmp(asm_entry[(asm_struct_bufr->columns*i)+part_type_col],
            "G") != 0) &&
           (strcmp(asm_entry[(asm_struct_bufr->columns*i)+part_type_col],
            "g") != 0) )
         {
          _pdm_debug("encountered a non-graphic part", 0);

          continue;
         }*/
 
      /* Extract level no for the current row */
      PDUfill_in_string(
                        &level,
                        asm_entry[(asm_struct_bufr->columns*i)+level_col]
                       );

      /* Extract child no for the current row */
      PDUfill_in_string(
                        &child,
                        asm_entry[(asm_struct_bufr->columns*i)+child_col]
                       );

      sscanf(level, "%d", &level_no);

      if (add_mode == 2)
        level_no = level_no - 1;

      ptr = p_path;
      count = 0;

      while ( (count < level_no) && (ptr[0] != '\0') )
            {
             if (ptr[0] == ':')
                ++count;

             if (count == level_no)
                break;

             ++ptr;
            } /* end while loop */

      *(ptr + 1) = '\0';

      strcat(p_path, "P");
      strcat(p_path, child);
      strcat(p_path, ":");
      strcpy(part_path, assy_path);
      strcat(part_path, p_path);

      /* Increment level no if nth level part */
      if ((add_mode == 1) || (add_mode == 2)) /* Placement time */
         {
          ++level_no;
          _pdm_debug("incremented level no = %d", level_no);
         }

      /* Extract parent no for the current row */
      PDUfill_in_string(
                        &parent_no,
                        asm_entry[(asm_struct_bufr->columns*i)+parent_col]
                       );
      _pdm_debug("parent_no = <%s>", parent_no);

      /* Need to update parent_no if 1st-level nth level part */
      if ( (add_mode == 1) && (level_no == 2) &&
           (strcmp(parent_no, "0") == 0) )
         {
          /* Change parent_no to the parent's child_no */
          _pdm_debug("changing extracted parent no", 0);
          PDUfill_in_string(&parent_no, child_no);
         }

      /* Add child directory entry into assembly structure */
      status = di$mkpath(pathname = part_path);
      _pdm_status("di$mkpath", status);

      PDUstrip_dir_entry(part_path);

      /* Create part assembly info under this directory */
      sprintf(level_no_str, "%d", level_no);
      _pdm_debug("level_no_str = <%s>", level_no_str);

      PDUcreate_exp(
                    TEXT,
                    part_path,
                    "level",
                    level_no_str,
                    mod_env->md_id.osnum 
                   );

      PDUcreate_exp(
                    TEXT,
                    part_path,
                    "parent_no",
                    parent_no,
                    mod_env->md_id.osnum 
                   );
 
      PDUcreate_exp(
                    TEXT,
                    part_path,
                    "child_no",
                    asm_entry[(asm_struct_bufr->columns * i) + child_col],
                    mod_env->md_id.osnum 
                   );

      PDUcreate_exp(
                    TEXT,
                    part_path,
                    "catalog_name",
                    asm_entry[(asm_struct_bufr->columns * i) + cat_col],
                    mod_env->md_id.osnum 
                   );

      PDUcreate_exp(
                    TEXT,
                    part_path, 
                    "part_number",
                    asm_entry[(asm_struct_bufr->columns * i) + part_col],
                    mod_env->md_id.osnum 
                   );

      PDUcreate_exp(
                    TEXT,
                    part_path, 
                    "revision", 
                    asm_entry[(asm_struct_bufr->columns * i) + rev_col],
                    mod_env->md_id.osnum 
                   );

      PDUcreate_exp(
                    TEXT,
                    part_path,
                    "description",
                    asm_entry[(asm_struct_bufr->columns*i) + desc_col],
                    mod_env->md_id.osnum 
                   );

      PDUcreate_exp(
                    TEXT,
                    part_path,
                    "part_type",
                    asm_entry[(asm_struct_bufr->columns*i) + part_type_col],
                    mod_env->md_id.osnum
                   );

      PDUcreate_exp(
                    TEXT,
                    part_path,
                    "attached",
                    asm_entry[(asm_struct_bufr->columns*i)+attach_col], 
                    mod_env->md_id.osnum 
                   );

      PDUcreate_exp(
                    TEXT,
                    part_path, 
                    "quantity",
                    asm_entry[(asm_struct_bufr->columns*i) + quant_col],
                    mod_env->md_id.osnum 
                   );

      PDUcreate_exp(
                    TEXT,
                    part_path,
                    "usage_id",
                    asm_entry[(asm_struct_bufr->columns*i) + usage_col],
                    mod_env->md_id.osnum 
                   );

      PDUcreate_exp(
                    TEXT,
                    part_path,
                    "file_name", 
                    asm_entry[(asm_struct_bufr->columns*i) + file_col],
                    mod_env->md_id.osnum 
                   );    

      PDUcreate_exp(
                    TEXT,
                    part_path,
                    "catalog_no", 
                    asm_entry[(asm_struct_bufr->columns*i) + cat_no_col],
                    mod_env->md_id.osnum 
                   );    

      PDUcreate_exp(
                    TEXT,
                    part_path,
                    "item_no", 
                    asm_entry[(asm_struct_bufr->columns*i) + item_no_col],
                    mod_env->md_id.osnum 
                   );    

      PDUcreate_exp(
                    TEXT,
                    part_path,
                    "loaded",
                    "N",
                    mod_env->md_id.osnum 
                   );

      PDUcreate_exp(
                    TEXT,
                    part_path,
                    "refid",
                    asm_entry[(asm_struct_bufr->columns*i) + refid_col],
                    mod_env->md_id.osnum 
                   );

      PDUcreate_exp(
                    TEXT,
                    part_path,
                    "local_flag",
                    "",
                    mod_env->md_id.osnum 
                   );

      PDUcreate_exp(
                    TEXT,
                    part_path,
                    "delete_flag",
                    "N",
                    mod_env->md_id.osnum 
                   );

     } /* End for loop */

  /* Free up vriables */
  if (parent_no)
     free(parent_no);

  if (child)
     free(child);
  
  if (level)
     free(level);

  if (free_mod)
     {
      free(mod_env);
      mod_env = NULL;
     }

  return(PDM_S_SUCCESS);
 }  


/*
 * This function updates the displayed attribute in the assembly structure.
 */
IGRint  PDUupdate_display_in_assembly(
                                      mod_env,
                                      assy_struct_buffer
                                     )

 struct GRmd_env *mod_env;                        /* INPUT */
 MEMptr          assy_struct_buffer;              /* INPUT */

 {
  IGRchar        **asm_entry = NULL;
  IGRchar        *level_no = NULL;
  IGRchar        *child_no = NULL;
  IGRchar        *attached = NULL;
  IGRint         level_col;
  IGRint         child_col;
  IGRint         attach_col;
  IGRint         i;
  IGRint         level;
  IGRint         count;
  IGRchar        assy_path[DI_PATH_MAX];
  IGRchar        part_path[DI_PATH_MAX];
  IGRchar        p_path[DI_PATH_MAX];
  IGRchar        *ptr;
  IGRshort       free_mod = FALSE;
  IGRint         bufsiz;
  IGRint         start_row;


  _pdm_debug("In the PDUupdate_display_in_assembly function", 0);

  /* Default module env. to current if mod_env is NULL */
  if (!mod_env)
     {
      mod_env = (struct GRmd_env *) malloc(sizeof(struct GRmd_env));
      bufsiz = sizeof(struct GRmd_env);
      gr$get_module_env(sizbuf = &bufsiz, buffer = mod_env);
      free_mod = TRUE;
     }

  /* Make sure buffer is not empty */
  if (!assy_struct_buffer)
     {
      _pdm_debug("assembly buffer is NULL", 0);
      return(0);
     }

  if (assy_struct_buffer->rows > 0)
     {
      _pdm_debug("updating the displayed attribute in assembly", 0);

      /* Extract part assembly info from buffer */
      MEMbuild_array(assy_struct_buffer);
      PDUsetup_buffer(
                      assy_struct_buffer,
                      ROW,
                      &asm_entry
                     );

      /* Extract level column no */
      PDUget_buffer_col(
                        assy_struct_buffer,
                        "p_level",
                        &level_col
                       );

      /* Extract child no column no */
      PDUget_buffer_col(
                        assy_struct_buffer,
                        "p_childno",
                        &child_col
                       );

      /* Extract attached attribute col. */
      PDUget_buffer_col(
                        assy_struct_buffer,
                        "p_attached",
                        &attach_col
                       );

      /* Initialize paths */
      assy_path[0] = '\0';
      part_path[0] = '\0';
      p_path[0] = '\0';

      /* Construct path to assembly structure */
      di$give_pathname(
                       osnum = mod_env->md_id.osnum,
                       pathname = assy_path
                      );

      strcat(assy_path, ":ASSEMBLY");
      strcpy(p_path, ":");

      if ((asm_entry[(assy_struct_buffer->columns*0)+level_col]) &&
        (strcmp(asm_entry[(assy_struct_buffer->columns*0)+level_col], "") != 0))
        start_row = 0;
      else
        start_row = 1;

      /* Modify the displayed attribute in each row */
      for (i = start_row; i < assy_struct_buffer->rows; ++i)
          {
           /* Extract level no for the current row */
           PDUfill_in_string(
                             &level_no,
                             asm_entry[(assy_struct_buffer->columns*i)+level_col]
                            );

           /* Extract child no for the current row */
           PDUfill_in_string(
                             &child_no,
                             asm_entry[(assy_struct_buffer->columns*i)+child_col]
                            );

           /* Extract attached attr. for the current row */
           PDUfill_in_string(
                             &attached,
                             asm_entry[(assy_struct_buffer->columns*i)+attach_col]
                            );

            sscanf(level_no, "%d", &level); 
             
            ptr = p_path;
            count = 0;

            while ( (count < level) && (ptr[0] != '\0') )
                  {
                   if (ptr[0] == ':')
                      ++count;

                   if (count == level)
                      break;

                   ++ptr;
                  } /* end while loop */

           *(ptr + 1) = '\0';

           strcat(p_path, "P");
           strcat(p_path, child_no);

           strcpy(part_path, assy_path);
           strcat(part_path, p_path);

           _pdm_debug("updating display for <%s>", part_path);

           /* Update the part's display in assy struct */
           PDUmodify_exp(
                         0,
                         part_path,
                         "attached",
                         attached,
                         mod_env->md_id.osnum 
                        );

           strcat(p_path, ":");

          } /* end for i loop */

      /* Free up variables */
      if (level_no)
         free(level_no);

      if (child_no)
         free(child_no);

      if (attached)
         free(attached);

      if (free_mod)
         {
          free(mod_env);
          mod_env = NULL;
         }

      return(PDM_S_SUCCESS);
     }
  
  return(0);
 }

/*
 * This function loads the assembly structure of the design file into 
 * the PDM assembly structure buffer.
 */
IGRint  PDUload_assy_struct_buffer(
                                   mod_env,
                                   assy_struct_buffer,
                                   max_level,
                                   path
                                  )

 struct GRmd_env *mod_env;                        /* INPUT */
 MEMptr          *assy_struct_buffer;             /* OUTPUT */
 IGRint          max_level;                       /* INPUT */
 IGRchar         *path;                           /* INPUT */

 {
  IGRlong        status = PDM_S_SUCCESS;
  IGRchar        *level = NULL;
  IGRchar        *parent_no = NULL;
  IGRchar        *child_no = NULL;
  IGRchar        *catalog_name = NULL;
  IGRchar        *part_number = NULL;
  IGRchar        *revision = NULL;
  IGRchar        *description = NULL;
  IGRchar        *attached = NULL;
  IGRchar        *quantity = NULL;
  IGRchar        *usage_id = NULL;
  IGRchar        *file_name = NULL;
  IGRchar        *loaded = NULL;
  IGRchar        *refid = NULL;
  IGRchar        *local_flag = NULL;
  IGRchar        *delete_flag = NULL;
  IGRchar        *item_no = NULL;
  IGRchar        *catalog_no = NULL;
  IGRchar        *part_type = NULL;
  IGRchar        *entry = NULL;
  IGRchar        *row = NULL;
  IGRchar        **parts;
  IGRint         part_count = 0;
  IGRint         i;
  IGRchar        part_path[DI_PATH_MAX];
  IGRshort       free_mod = FALSE;
  IGRint         bufsiz;


  _pdm_debug("In the PDUload_assy_struct_buffer function",0);

  /* Default module env. to current if mod_env is NULL */
  if (!mod_env)
     {
      mod_env = (struct GRmd_env *) malloc(sizeof(struct GRmd_env));
      bufsiz = sizeof(struct GRmd_env);
      gr$get_module_env(sizbuf = &bufsiz, buffer = mod_env);
      free_mod = TRUE;
     }

  /* Make sure buffer is formatted */
  if (*assy_struct_buffer)
     {
      MEMclose(assy_struct_buffer);
      *assy_struct_buffer = NULL;
     }

  /* Format assembly structure buffer */
  status = PDMassembly_attributes(assy_struct_buffer);
  _pdm_status("PDMassembly_attributes", status);

  if (status != PDM_S_SUCCESS)
     {
      PDUmessage(status, 's');
      return(status);
     }

  if (!path)
     {
      /* Write an empty row in the 0th row */
      status = MEMwrite(
                    *assy_struct_buffer,
                    "\1\1\1\1\1\1\1\1\1\1\1\1\1\1\1\1\1\1\1\1\1\1\1\1\1\1\1\1" 
                       );
      _pdm_status("MEMwrite", status);

      if (status != MEM_S_SUCCESS)
         {
          _pdm_debug("MEMwrite failed", 0);
          return(status);
         }
     }

  else
      {
       _pdm_debug("Path given. Extract first level information", 0);

       strcpy(part_path, path);
       row =  
           (IGRchar *)malloc(sizeof(IGRchar) * (*assy_struct_buffer)->row_size);
       memset(row, NULL, (*assy_struct_buffer)->row_size);

       /* Extract value for part item number */
       status = PDUevaluate_exp(
                                part_path,
                                "item_no",
                                &item_no
                               );
         
       if (status != PDM_S_SUCCESS)
          {
           _pdm_debug("PDUevaluate_exp failed", 0);
           return(0);
          }

       /* Extract value for part catalog number */
       status = PDUevaluate_exp(
                                part_path,
                                "catalog_no",
                                &catalog_no
                               );

       if (status != PDM_S_SUCCESS)
          {
           _pdm_debug("PDUevaluate_exp failed", 0);
           return(0);
          }

        /* Extract value for part level number */
        status = PDUevaluate_exp(
                                 part_path,
                                 "level",
                                 &level
                                );

        if (status != PDM_S_SUCCESS)
           {
            _pdm_debug("PDUevaluate_exp failed", 0);
            return(0);
           }

        /* Extract value for part parent number */
        status = PDUevaluate_exp(
                                 part_path,
                                 "parent_no",
                                 &parent_no
                                );

        if (status != PDM_S_SUCCESS)
           {
            _pdm_debug("PDUevaluate_exp failed", 0);
            return(0);
           }

        /* Extract value for part child number */
        status = PDUevaluate_exp(
                                 part_path,
                                 "child_no",
                                 &child_no
                                );
 
        if (status != PDM_S_SUCCESS)
           {
            _pdm_debug("PDUevaluate_exp failed", 0);
            return(0);
           }

        /* Extract value for part catalog */
        status = PDUevaluate_exp(
                                 part_path,
                                 "catalog_name",
                                 &catalog_name
                                );

        if (status != PDM_S_SUCCESS)
           {
            _pdm_debug("PDUevaluate_exp failed", 0);
            return(0);
           }

        /* Extract value for part number */
        status = PDUevaluate_exp(
                                 part_path,
                                 "part_number",
                                 &part_number
                                );

        if (status != PDM_S_SUCCESS)
           {
            _pdm_debug("PDUevaluate_exp failed", 0);
            return(0);
           }

        /* Extract value for part revision */
        status = PDUevaluate_exp(
                                 part_path,
                                 "revision",
                                 &revision
                                );

        if (status != PDM_S_SUCCESS)
           {
            _pdm_debug("PDUevaluate_exp failed", 0);
            return(0);
           }

        /* Extract value for part description */
        status = PDUevaluate_exp(
                                 part_path,
                                 "description",
                                 &description
                                );

        if (status != PDM_S_SUCCESS)
           {
            _pdm_debug("PDUevaluate_exp failed", 0);
            return(0);
           }

        /* Extract value for explicit attachment flag */
        status = PDUevaluate_exp(
                                 part_path,
                                 "attached",
                                 &attached
                                );

        if (status != PDM_S_SUCCESS)
           {
            _pdm_debug("PDUevaluate_exp failed", 0);
            return(0);
           }

        /* Extract value for part quantity */
        status = PDUevaluate_exp(
                                 part_path,
                                 "quantity",
                                 &quantity
                                );

        if (status != PDM_S_SUCCESS)
           {
            _pdm_debug("PDUevaluate_exp failed", 0);
            return(0);
           }

        /* Extract value for part usage id */
        status = PDUevaluate_exp(
                                 part_path,
                                 "usage_id",
                                 &usage_id
                                );

        if (status != PDM_S_SUCCESS)
           {
            _pdm_debug("PDUevaluate_exp failed", 0);
            return(0);
           }
 
        /* Extract value for part file name */
        status = PDUevaluate_exp(
                                 part_path,
                                 "file_name",
                                 &file_name
                                );

        if (status != PDM_S_SUCCESS)
           {
            _pdm_debug("PDUevaluate_exp failed", 0);
            return(0);
           }

       /* Extract value for part loaded attribute */
       status = PDUevaluate_exp(
                                part_path,
                                "loaded",
                                &loaded
                               );

       if (status != PDM_S_SUCCESS)
          {
           _pdm_debug("PDUevaluate_exp failed", 0);
           return(0);
          }

      /* Extract refid attribute */
      status = PDUevaluate_exp(
                               part_path,
                               "refid",
                               &refid
                              );

      if (status != PDM_S_SUCCESS)
         {
          _pdm_debug("PDUevaluate_exp failed", 0);
          return(0);
         }

      /* Extract local_flag attribute */
      status = PDUevaluate_exp(
                               part_path,
                               "local_flag",
                               &local_flag
                              );

      if (status != PDM_S_SUCCESS)
         {
          _pdm_debug("PDUevaluate_exp failed", 0);
          return(0);
         }

      /* Extract delete_flag attribute */
      status = PDUevaluate_exp(
                               part_path,
                               "delete_flag",
                               &delete_flag
                              );
  
      if (status != PDM_S_SUCCESS)
         {
          _pdm_debug("PDUevaluate_exp failed", 0);
          return(0);
         }

      /* Extract part_type attribute */
      status = PDUevaluate_exp(
                               part_path,
                               "part_type",
                               &part_type
                              );

      if (status != PDM_S_SUCCESS)
         {
          _pdm_debug("PDUevaluate_exp failed", 0);
          return(0);
         }

      /* Construct row for assembly structure buffer */
      sprintf(
              row,
"\1\1\1%s\1%s\1%s\1\1\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1\1\1\1\1\1%s\1%s\1%s\1%s\1%s\1",
              catalog_no,
              item_no,
              level,
              parent_no,
              child_no,
              catalog_name,
              part_number,
              revision,
              description,
              attached,
              quantity,
              usage_id,
              file_name,
              part_type,
              loaded,
              refid,
              local_flag,
              delete_flag
             );

      /* Write part info to assembly buffer */
      status = MEMwrite(*assy_struct_buffer, row);
      _pdm_status("MEMwrite", status);

      if (status != MEM_S_SUCCESS)
         {
          _pdm_debug("MEMwrite failed", 0);
          return(status);
         }

      if (row)
         free(row);
     } 
     
  
  if (!path)
     {
      /* Construct path to assembly structure */
      di$give_pathname(
                       osnum = mod_env->md_id.osnum,
                       pathname = part_path
                      );

      strcat(part_path, ":ASSEMBLY");
     }

  /* Extract list of DIrectory objects from given parts path */
  status = di$find (
                    start_dir = part_path,
                    regexp = "P*",
                    lines = &parts,
                    ptr = &part_count,
                    max_level = max_level 
                   );

  /* Check to see if there is any parts in assembly structure */
  if (part_count <= 0)
     {
      _pdm_debug("no parts found in assembly structure", 0);

      /* Free up parts  and part_count */
      if (parts)
         {
          di$free (lines = parts, count = part_count);
          status = PDM_S_SUCCESS;
         }

      else
         status = PDM_S_SUCCESS;
      
      return(status);
     }

  /* Extract part assembly information */
  _pdm_debug("part count = %d", part_count);

  /* Allocate space for row */
  row = (IGRchar *)malloc(sizeof(IGRchar) * (*assy_struct_buffer)->row_size);
  memset(row, NULL, (*assy_struct_buffer)->row_size);

  for (i = 0; i < part_count; ++i)
      {
       /* Drop last ":" from entry */
       _pdm_debug("parts[i] = <%s>", parts[i]);

       PDUfill_in_string(&entry, parts[i]);

       PDUstrip_dir_entry(entry);


       /* Extract value for part item number */
       status = PDUevaluate_exp(
                                entry,
                                "item_no",
                                &item_no
                               );
         
       if (status != PDM_S_SUCCESS)
          {
           _pdm_debug("PDUevaluate_exp failed", 0);
           return(0);
          }

       /* Extract value for part catalog number */
       status = PDUevaluate_exp(
                                entry,
                                "catalog_no",
                                &catalog_no
                               );

       if (status != PDM_S_SUCCESS)
          {
           _pdm_debug("PDUevaluate_exp failed", 0);
           return(0);
          }

       /* Extract value for part level number */
       status = PDUevaluate_exp(
                                entry,
                                "level",
                                &level
                               );

       if (status != PDM_S_SUCCESS)
          {
           _pdm_debug("PDUevaluate_exp failed", 0);
           return(0);
          }

       /* Extract value for part parent number */
       status = PDUevaluate_exp(
                                entry,
                                "parent_no",
                                &parent_no
                               );

       if (status != PDM_S_SUCCESS)
          {
           _pdm_debug("PDUevaluate_exp failed", 0);
           return(0);
          }

       /* Extract value for part child number */
       status = PDUevaluate_exp(
                                entry,
                                "child_no",
                                &child_no
                               );
 
       if (status != PDM_S_SUCCESS)
          {
           _pdm_debug("PDUevaluate_exp failed", 0);
           return(0);
          }

       /* Extract value for part catalog */
       status = PDUevaluate_exp(
                                entry,
                                "catalog_name",
                                &catalog_name
                               );

       if (status != PDM_S_SUCCESS)
          {
           _pdm_debug("PDUevaluate_exp failed", 0);
           return(0);
          }

       /* Extract value for part number */
       status = PDUevaluate_exp(
                                entry,
                                "part_number",
                                &part_number
                               );

       if (status != PDM_S_SUCCESS)
          {
           _pdm_debug("PDUevaluate_exp failed", 0);
           return(0);
          }

       /* Extract value for part revision */
       status = PDUevaluate_exp(
                                entry,
                                "revision",
                                &revision
                               );

       if (status != PDM_S_SUCCESS)
          {
           _pdm_debug("PDUevaluate_exp failed", 0);
           return(0);
          }

       /* Extract value for part description */
       status = PDUevaluate_exp(
                                entry,
                                "description",
                                &description
                               );

       if (status != PDM_S_SUCCESS)
          {
           _pdm_debug("PDUevaluate_exp failed", 0);
           return(0);
          }

       /* Extract value for explicit attachment flag */
       status = PDUevaluate_exp(
                                entry,
                                "attached",
                                &attached
                               );

       if (status != PDM_S_SUCCESS)
          {
           _pdm_debug("PDUevaluate_exp failed", 0);
           return(0);
          }

       /* Extract value for part quantity */
       status = PDUevaluate_exp(
                                entry,
                                "quantity",
                                &quantity
                               );

       if (status != PDM_S_SUCCESS)
          {
           _pdm_debug("PDUevaluate_exp failed", 0);
           return(0);
          }

       /* Extract value for part usage id */
       status = PDUevaluate_exp(
                                entry,
                                "usage_id",
                                &usage_id
                               );

       if (status != PDM_S_SUCCESS)
          {
           _pdm_debug("PDUevaluate_exp failed", 0);
           return(0);
          }

       /* Extract value for part file name */
       status = PDUevaluate_exp(
                                entry,
                                "file_name",
                                &file_name
                               );

       if (status != PDM_S_SUCCESS)
          {
           _pdm_debug("PDUevaluate_exp failed", 0);
           return(0);
          }

       /* Extract value for part loaded attribute */
       status = PDUevaluate_exp(
                                entry,
                                "loaded",
                                &loaded
                               );

       if (status != PDM_S_SUCCESS)
          {
           _pdm_debug("PDUevaluate_exp failed", 0);
           return(0);
          }

       /* Extract refid attribute */
       status = PDUevaluate_exp(
                                entry,
                                "refid",
                                &refid
                               );

       if (status != PDM_S_SUCCESS)
          {
           _pdm_debug("PDUevaluate_exp failed", 0);
           return(0);
          }

       /* Extract local_flag attribute */
       status = PDUevaluate_exp(
                                entry,
                                "local_flag",
                                &local_flag
                               );

       if (status != PDM_S_SUCCESS)
          {
           _pdm_debug("PDUevaluate_exp failed", 0);
           return(0);
          }

       /* Extract delete_flag attribute */
       status = PDUevaluate_exp(
                                entry,
                                "delete_flag",
                                &delete_flag
                               );

       if (status != PDM_S_SUCCESS)
          {
           _pdm_debug("PDUevaluate_exp failed", 0);
           return(0);
          }

       /* Extract part_type attribute */
       status = PDUevaluate_exp(
                                entry,
                                "part_type",
                                &part_type
                               );

       if (status != PDM_S_SUCCESS)
          {
           _pdm_debug("PDUevaluate_exp failed", 0);
           return(0);
          }

       /* Construct row for assembly structure buffer */
       sprintf(
               row,
"\1\1\1%s\1%s\1%s\1\1\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1\1\1\1\1\1%s\1%s\1%s\1%s\1%s\1",
               catalog_no,
               item_no,
               level,
               parent_no,
               child_no,
               catalog_name,
               part_number,
               revision,
               description,
               attached,
               quantity,
               usage_id,
               file_name,
               part_type,
               loaded,
               refid,
               local_flag,
               delete_flag
              );

       /* Write part info to assembly buffer */
       status = MEMwrite(*assy_struct_buffer, row);
       _pdm_status("MEMwrite", status);

       if (status != MEM_S_SUCCESS)
          {
           _pdm_debug("MEMwrite failed", 0);
           return(status);
          }

       /* Clear row */
       memset(row, NULL, (*assy_struct_buffer)->row_size);

      } /* end of for loop */

  /* Need to free part attr names */
  if (level)
     free(level);

  if (parent_no)
     free(parent_no);

  if (child_no)
     free(child_no);

  if (catalog_name)
     free(catalog_name);

  if (part_number)
     free(part_number);

  if (revision)
     free(revision);

  if (description)
     free(description);

  if (attached)
     free(attached);

  if (quantity)
     free(quantity);

  if (usage_id)
     free(usage_id);

  if (file_name)
     free(file_name);

  if (loaded)
     free(loaded);
      
  if (refid)
     free(refid);

  if (item_no)
     free(item_no);

  if (catalog_no)
     free(catalog_no);

  if (local_flag)
     free(local_flag);

  if (delete_flag)
     free(delete_flag);

  if (part_type)
     free(part_type);

  if (free_mod)
     {
      free(mod_env);
      mod_env = NULL;
     }

  if (PDMdebug_on)
      MEMprint_buffer(
                      "assembly buffer (OS -> BUFFER)",
                       *assy_struct_buffer,
                       PDU_DEBUG_FILE
                     );

  /* Free up parts and part_count */  
  if (parts)
     {
      di$free (lines = parts, count = part_count);
      status = PDM_S_SUCCESS;
     }

  else
     status = PDM_S_SUCCESS;

  return(status);
 }


/*
 * This function loads the load structure of the design file into
 * the PDM copy attach buffer.
 */
IGRint  PDUload_copy_attach_buffer(
                                   mod_env,
                                   max_level,
                                   copy_attach_buffer
                                  )

 struct GRmd_env *mod_env;                        /* INPUT */
 IGRint          max_level;                       /* INPUT */
 MEMptr          *copy_attach_buffer;             /* OUTPUT */

 {
  IGRlong                   status = PDM_S_SUCCESS;
  IGRshort                  free_mod = FALSE;
  IGRint                    bufsiz;
  IGRchar                   assy_path[DI_PATH_MAX];
  IGRchar                   **parts = NULL;
  IGRint                    part_count = 0;
  IGRint                    i;
  IGRshort                  unique_flag;
  IGRchar                   *loaded = NULL;
  IGRchar                   *catalog = NULL;
  IGRchar                   *number = NULL;
  IGRchar                   *revision = NULL;
  IGRchar                   *filename = NULL;
  IGRchar                   *local_flag = NULL;
  IGRchar                   *cat_no = NULL;
  IGRchar                   *item_no = NULL;
  struct  PDUref_node       *head = NULL;
  struct  PDUref_node       *tail = NULL;
  struct  PDUref_node       *buffer_files = NULL;
  struct  PDUref_node       *temp = NULL;
  struct  PDUref_node       *top = NULL; 


  _pdm_debug("In the PDUload_copy_attach_buffer function", 0);

  /* Default module env. to current if mod_env is NULL */
  if (!mod_env)
     {
      mod_env = (struct GRmd_env *) malloc(sizeof(struct GRmd_env));
      bufsiz = sizeof(struct GRmd_env);
      gr$get_module_env(sizbuf = &bufsiz, buffer = mod_env);
      free_mod = TRUE;
     }


  /* Construct path to part directory */
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
                   max_level = max_level 
                  );

  if ( (status == DIR_S_SUCCESS) && (part_count > 0) )
     {
      /* Make sure buffer is formatted */
      if (*copy_attach_buffer)
         {
         MEMclose(copy_attach_buffer);
         *copy_attach_buffer = NULL;
         }

      /* Format copy attach buffer */
      PDMopen_buffer(
                     7,
                     copy_attach_buffer 
                    );

      for (i = 0; i < part_count; ++i)
          {
           PDUstrip_dir_entry(parts[i]);

           /* Get part loaded attribute */
/* ALR  6/23/94  Too many parameters */
/*
           status = PDUevaluate_exp(
                                    parts[i],
                                    "loaded",
                                    &loaded,
                                    mod_env->md_id.osnum
                                   );
*/
           status = PDUevaluate_exp(
                                    parts[i],
                                    "loaded",
                                    &loaded
                                   );

           if (status != PDM_S_SUCCESS)
              {
               _pdm_debug("could not evaluate loaded attr.", 0);
               return(0);
              }

           if (strcmp(loaded, "N") != 0)
              {
               /* Get part local flag */
/* ALR  6/23/94  Too many parameters */
/*
               status = PDUevaluate_exp(
                                        parts[i],
                                        "local_flag",
                                        &local_flag,
                                        mod_env->md_id.osnum
                                       );
*/
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

               if ( (strcmp(local_flag, "D") == 0) || 
                    (strcmp(local_flag, "C") == 0) ||
                    (strcmp(local_flag, "S") == 0) )
                  {
                   _pdm_debug("part is already local", 0);
                   continue;
                  }

               /* Get part file name */
/* ALR  6/23/94  Too many parameters */
/*
               status = PDUevaluate_exp(
                                        parts[i],
                                        "file_name",
                                        &filename,
                                        mod_env->md_id.osnum
                                       );
*/
               status = PDUevaluate_exp(
                                        parts[i],
                                        "file_name",
                                        &filename
                                       );

               if (status != PDM_S_SUCCESS)
                  {
                   _pdm_debug("could not evaluate file_name attr.", 0);
                   return(0);
                  }

               if (filename == NULL)
                 continue;
               else if (strcmp(filename, "") == 0)
                 continue;
               /* Check to see if file is unique */
               unique_flag = TRUE;
               top = buffer_files;

               while (top)
                     {
                      if (strcmp(top->filename, filename) == 0)
                         {
                          _pdm_debug("file already included", 0);
                          unique_flag = FALSE;
                          break;
                         }

                      else
                          top = top->next;

                     } /* end while */

               if (unique_flag == TRUE)
                  {
                   /* Extract part catalog name */
/* ALR  6/23/94  Too many parameters */
/*
                   status = PDUevaluate_exp(
                                            parts[i],
                                            "catalog_name",
                                            &catalog,
                                            mod_env->md_id.osnum
                                           );
*/
                   status = PDUevaluate_exp(
                                            parts[i],
                                            "catalog_name",
                                            &catalog
                                           );

                   if (status != PDM_S_SUCCESS)
                      {
                       _pdm_debug("could not evaluate catalog attr", 0);
                       return(0);
                      }

                   /* Extract part number */
/* ALR  6/23/94  Too many parameters */
/*
                   status = PDUevaluate_exp(
                                            parts[i],
                                            "part_number",
                                            &number,
                                            mod_env->md_id.osnum
                                           );
*/
                   status = PDUevaluate_exp(
                                            parts[i],
                                            "part_number",
                                            &number
                                           );
                       
                   if (status != PDM_S_SUCCESS)
                      {
                       _pdm_debug("could not evaluate number attr", 0);
                       return(0);
                      }

                   /* Extract part revision */
/* ALR  6/23/94  Too many parameters */
/*
                   status = PDUevaluate_exp(
                                            parts[i],
                                            "revision",
                                            &revision,
                                            mod_env->md_id.osnum
                                           );
*/
                   status = PDUevaluate_exp(
                                            parts[i],
                                            "revision",
                                            &revision
                                           );

                   if (status != PDM_S_SUCCESS)
                      {
                       _pdm_debug("could not evaluate revision attr", 0);
                       return(0);
                      }

                   /* Extract part catalog no */
/* ALR  6/23/94  Too many parameters */
/*
                   status = PDUevaluate_exp(
                                            parts[i],
                                            "catalog_no",
                                            &cat_no,
                                            mod_env->md_id.osnum
                                           );
*/
                   status = PDUevaluate_exp(
                                            parts[i],
                                            "catalog_no",
                                            &cat_no
                                           );

                   if (status != PDM_S_SUCCESS)
                      {
                       _pdm_debug("could not evaluate cat no attr", 0);
                       return(0);
                      }

                   /* Extract part item no */
/* ALR  6/23/94  Too many parameters */
/*
                   status = PDUevaluate_exp(
                                            parts[i],
                                            "item_no",
                                            &item_no,
                                            mod_env->md_id.osnum
                                           );
*/
                   status = PDUevaluate_exp(
                                            parts[i],
                                            "item_no",
                                            &item_no
                                           );

                   if (status != PDM_S_SUCCESS)
                      {
                       _pdm_debug("could not evaluate item no attr", 0);
                       return(0);
                      }

                   status = PDUload_local_file_buffer(
                                                      cat_no,
                                                      item_no,
                                                      catalog,
                                                      number,
                                                      revision,
                                                      filename,
                                                      copy_attach_buffer 
                                                    );
                   _pdm_status("PDUload_local_file_buffer", status);

                   /* Create a node with buffer unique file info */
                   temp = (struct PDUref_node *)
                                        malloc(sizeof(struct PDUref_node));

                   /* Initialize temp fields */
                   temp->filename = NULL;
                   temp->description = NULL;
                   temp->next = NULL;

                   PDUfill_in_string(&(temp->filename), filename);

                   if (buffer_files)
                      {
                       /* Get to the end of list */
                       tail = buffer_files;
                       while (tail->next)
                             {
                              tail = tail->next;
                             }

                       /* Add part to file link list */
                       tail->next = temp;
                      }

                   else
                       {
                        buffer_files = temp;
                       }
                  }
              }

          } /* end for i loop */
     }

  else
      {
       _pdm_debug("no parts found in assembly structure", 0);
       return(PDM_S_SUCCESS);
      }

  /* Free up variables */
  if (buffer_files)
     {
      head = buffer_files;

      while (buffer_files)
            {
             buffer_files = buffer_files->next;
             free(head);
             head = buffer_files;
            }

     } /* end while loop */

  if (filename)
     free(filename);

  if (loaded)
     free(loaded);

  if (catalog)
     free(catalog);

  if (number)
     free(number);

  if (revision)
     free(revision);

  if (cat_no)
     free(cat_no);

  if (item_no)
     free(item_no);

  if (local_flag)
     free(local_flag);

  if (parts)
     di$free(lines = parts, count = part_count);

  if (free_mod)
     {
      free(mod_env);
      mod_env = NULL;
     }

  return(PDM_S_SUCCESS);
 }


/*
 * This function loads the no load structure of the design file into
 * the PDM detach buffer.
 */
IGRint  PDUload_detach_buffer(
                              mod_env,
                              max_level,
                              save,
                              detach_buffer
                             )

 struct GRmd_env *mod_env;                        /* INPUT */
 IGRint          max_level;                       /* INPUT */
 IGRshort        save;                            /* INPUT */
 MEMptr          *detach_buffer;                  /* OUTPUT */

 {
  IGRlong                   status = PDM_S_SUCCESS;
  IGRshort                  free_mod = FALSE;
  IGRint                    bufsiz;
  IGRchar                   assy_path[DI_PATH_MAX];
  IGRchar                   **parts = NULL;
  IGRint                    part_count = 0;
  IGRint                    i, j;
  IGRshort                  load_file = FALSE;
  IGRshort                  unique_flag;
  IGRchar                   *loaded = NULL;
  IGRchar                   *catalog = NULL;
  IGRchar                   *number = NULL;
  IGRchar                   *revision = NULL;
  IGRchar                   *filename = NULL;
  IGRchar                   *file = NULL;
  IGRchar                   *cat_no = NULL;
  IGRchar                   *item_no = NULL;
  IGRchar                   *local_flag = NULL;
  IGRchar                   *delete_flag = NULL;
  struct  PDUref_node       *head = NULL;
  struct  PDUref_node       *tail = NULL;
  struct  PDUref_node       *buffer_files = NULL;
  struct  PDUref_node       *temp = NULL;
  struct  PDUref_node       *top = NULL; 


  _pdm_debug("In the PDUload_detach_buffer function", 0);

  /* Default module env. to current if mod_env is NULL */
  if (!mod_env)
     {
      mod_env = (struct GRmd_env *) malloc(sizeof(struct GRmd_env));
      bufsiz = sizeof(struct GRmd_env);
      gr$get_module_env(sizbuf = &bufsiz, buffer = mod_env);
      free_mod = TRUE;
     }

  /* Construct path to part directory */
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
                   max_level = max_level 
                  );

  if ( (status == DIR_S_SUCCESS) && (part_count > 0) )
     {
      /* Make sure buffer is formatted */
      if (*detach_buffer)
         {
         MEMclose(detach_buffer);
         *detach_buffer = NULL;
         }

      /* Format detach buffer */
      PDMopen_buffer(
                     7,
                     detach_buffer 
                    );

      /* Load detach buffer */
      for (i = 0; i < part_count; ++i)
          {
           load_file = FALSE;
           PDUstrip_dir_entry(parts[i]);

           /* Get part local flag */
/* ALR  6/23/94  Too many parameters */
/*
           status = PDUevaluate_exp(
                                    parts[i],
                                    "local_flag",
                                    &local_flag,
                                    mod_env->md_id.osnum
                                   );
*/
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


           /* Skip parts with no local files */
           if ( (strcmp(local_flag, "D") != 0) && 
                (strcmp(local_flag, "C") != 0) &&
                (strcmp(local_flag, "S") != 0) )
              continue;

           if (!save)
              {
               /* Consider local parts in current design session only */
               if (strcmp(local_flag, "D") == 0)
                  load_file = TRUE;

               else
                   continue;
              }

           /* Get part file name */
/* ALR  6/23/94  Too many parameters */
/*
           status = PDUevaluate_exp(
                                    parts[i],
                                    "file_name",
                                    &filename,
                                    mod_env->md_id.osnum
                                   );
*/
           status = PDUevaluate_exp(
                                    parts[i],
                                    "file_name",
                                    &filename
                                   );

           if (status != PDM_S_SUCCESS)
              {
               _pdm_debug("could not evaluate file_name attr.", 0);
               return(0);
              }

           if (save)
              {
               load_file = FALSE;

               /* Get part loaded attribute */
/* ALR  6/23/94  Too many parameters */
/*
               status = PDUevaluate_exp(
                                        parts[i],
                                        "loaded",
                                        &loaded,
                                        mod_env->md_id.osnum
                                       );
*/
               status = PDUevaluate_exp(
                                        parts[i],
                                        "loaded",
                                        &loaded
                                       );

               if (status != PDM_S_SUCCESS)
                  {
                   _pdm_debug("could not evaluate loaded attr.", 0);
                   return(0);
                  }

               /* Get part delete_flag attribute */
/* ALR  6/23/94  Too many parameters */
/*
               status = PDUevaluate_exp(
                                        parts[i],
                                        "delete_flag",
                                        &delete_flag,
                                        mod_env->md_id.osnum
                                       );
*/
               status = PDUevaluate_exp(
                                        parts[i],
                                        "delete_flag",
                                        &delete_flag
                                       );

               if (status != PDM_S_SUCCESS)
                  {
                   _pdm_debug("could not evaluate delete_flag attr.", 0);
                   return(0);
                  }

               if ( (strcmp(loaded, "N") == 0) ||
                    (strcmp(delete_flag, "Y") == 0) )
                  {
                   load_file = TRUE;

                   for (j = 0; j < part_count; ++ j)
                       {
                        /* Get part loaded attribute */
/* ALR  6/23/94  Too many parameters */
/*
                        status = PDUevaluate_exp(
                                                 parts[j],
                                                 "loaded",
                                                 &loaded,
                                                 mod_env->md_id.osnum
                                                );
*/
                        status = PDUevaluate_exp(
                                                 parts[j],
                                                 "loaded",
                                                 &loaded
                                                );

                        if (status != PDM_S_SUCCESS)
                           {
                            _pdm_debug("could not evaluate loaded attr.", 0);
                            return(0);
                           }

                        /* Get part filename attribute */
/* ALR  6/23/94  Too many parameters */
/*
                        status = PDUevaluate_exp(
                                                 parts[j],
                                                 "file_name",
                                                 &file,
                                                 mod_env->md_id.osnum
                                                );
*/
                        status = PDUevaluate_exp(
                                                 parts[j],
                                                 "file_name",
                                                 &file
                                                );

                        if (status != PDM_S_SUCCESS)
                           {
                            _pdm_debug("could not evaluate file attr.", 0);
                            return(0);
                           }

                        /* Get part delete flag attribute */
/* ALR  6/23/94  Too many parameters */
/*
                        status = PDUevaluate_exp(
                                                 parts[j],
                                                 "delete_flag",
                                                 &delete_flag,
                                                 mod_env->md_id.osnum
                                                );
*/
                        status = PDUevaluate_exp(
                                                 parts[j],
                                                 "delete_flag",
                                                 &delete_flag
                                                );

                        if (status != PDM_S_SUCCESS)
                           {
                            _pdm_debug("could not evaluate delete attr.", 0);
                            return(0);
                           }

                        if ( (strcmp(loaded, "N") != 0) &&
                             (strcmp(filename, file) == 0)  &&
                             (strcmp(delete_flag, "Y") != 0) )
                             {
                              load_file = FALSE; 
                              break;
                             }

                       } /* end for j loop */
                  }

               else
                   continue;
              }

           if (load_file)
              {
               /* Check to see if file is unique */
               unique_flag = TRUE;
               top = buffer_files;

               while (top)
                     {
                      if (strcmp(top->filename, filename) == 0)
                         {
                          _pdm_debug("file already included", 0);
                          unique_flag = FALSE;
                          break;
                         }

                      else
                          top = top->next;

                     } /* end while */

               if (unique_flag == TRUE)
                  {
                   PDUmodify_exp(
                                  0,
                                  parts[i],
                                  "local_flag",
                                  "",
                                  mod_env->md_id.osnum);
                   /* Extract part catalog name */
/* ALR  6/23/94  Too many parameters */
/*
                   status = PDUevaluate_exp(
                                            parts[i],
                                            "catalog_name",
                                            &catalog,
                                            mod_env->md_id.osnum
                                           );
*/
                   status = PDUevaluate_exp(
                                            parts[i],
                                            "catalog_name",
                                            &catalog
                                           );

                   if (status != PDM_S_SUCCESS)
                      {
                       _pdm_debug("could not evaluate catalog attr", 0);
                       return(0);
                      }

                   /* Extract part number */
/* ALR  6/23/94  Too many parameters */
/*
                   status = PDUevaluate_exp(
                                            parts[i],
                                            "part_number",
                                            &number,
                                            mod_env->md_id.osnum
                                           );
*/
                   status = PDUevaluate_exp(
                                            parts[i],
                                            "part_number",
                                            &number
                                           );
                       
                   if (status != PDM_S_SUCCESS)
                      {
                       _pdm_debug("could not evaluate number attr", 0);
                       return(0);
                      }

                   /* Extract part revision */
/* ALR  6/23/94  Too many parameters */
/*
                   status = PDUevaluate_exp(
                                            parts[i],
                                            "revision",
                                            &revision,
                                            mod_env->md_id.osnum
                                           );
*/
                   status = PDUevaluate_exp(
                                            parts[i],
                                            "revision",
                                            &revision
                                           );

                   if (status != PDM_S_SUCCESS)
                      {
                       _pdm_debug("could not evaluate revision attr", 0);
                       return(0);
                      }

                   /* Extract part catalog no */
/* ALR  6/23/94  Too many parameters */
/*
                   status = PDUevaluate_exp(
                                            parts[i],
                                            "catalog_no",
                                            &cat_no,
                                            mod_env->md_id.osnum
                                           );
*/
                   status = PDUevaluate_exp(
                                            parts[i],
                                            "catalog_no",
                                            &cat_no
                                           );

                   if (status != PDM_S_SUCCESS)
                      {
                       _pdm_debug("could not evaluate cat no attr", 0);
                       return(0);
                      }

                   /* Extract part item no */
/* ALR  6/23/94  Too many parameters */
/*
                   status = PDUevaluate_exp(
                                            parts[i],
                                            "item_no",
                                            &item_no,
                                            mod_env->md_id.osnum
                                           );
*/
                   status = PDUevaluate_exp(
                                            parts[i],
                                            "item_no",
                                            &item_no
                                           );

                   if (status != PDM_S_SUCCESS)
                      {
                       _pdm_debug("could not evaluate item no attr", 0);
                       return(0);
                      }

                   /* MJG - if the file is already local, do not add it to the 
                      buffer - 9/22/95 */
/* 1/5/96 MJG - TR 139524757 - Removed condition added on 9/22/95.  Fix should 
   be done on PDM side. */

                     status = PDUload_local_file_buffer(
                                                        cat_no,
                                                        item_no,
                                                        catalog,
                                                        number,
                                                        revision,
                                                        filename,
                                                        detach_buffer 
                                                       );
                     _pdm_status("PDUload_local_file_buffer", status);
  
                     /* Create a node with buffer unique file info */
                     temp = (struct PDUref_node *)
                                              malloc(sizeof(struct PDUref_node));
  
                     /* Initialize temp fields */
                     temp->filename = NULL;
                     temp->description = NULL;
                     temp->next = NULL;
  
                     PDUfill_in_string(&(temp->filename), filename);
  
                     if (buffer_files)
                        {
                         /* Get to the end of list */
                         tail = buffer_files;
                         while (tail->next)
                               {
                                tail = tail->next;
                               }
  
                         /* Add part to file link list */
                         tail->next = temp;
                        }
  
                     else
                         {
                          buffer_files = temp;
                         }
                  }
              }

          } /* end for i loop */
     }

  else
      {
       _pdm_debug("no parts found in assembly structure", 0);
       return(PDM_S_SUCCESS);
      }

  if (buffer_files)
     {
      head = buffer_files;

      while (buffer_files)
            {
             buffer_files = buffer_files->next;
             free(head);
             head = buffer_files;
            }

     } /* end while loop */

  if (filename)
     free(filename);

  if (loaded)
     free(loaded);

  if (catalog)
     free(catalog);

  if (number)
     free(number);

  if (revision)
     free(revision);

  if (cat_no)
     free(cat_no);

  if (item_no)
     free(item_no);

  if (local_flag)
     free(local_flag);

  if (file)
     free(file);

  if (delete_flag)
     free(delete_flag);

  if (parts)
     di$free(lines = parts, count = part_count);

  if (free_mod)
     {
      free(mod_env);
      mod_env = NULL;
     }

  return(PDM_S_SUCCESS);
 }


/*
 * This function loads the no load structure of the design file into
 * the PDM delete local buffer.
 */
IGRint  PDUload_delete_buffer(
                              mod_env,
                              max_level,
                              delete_buffer
                             )

 struct GRmd_env *mod_env;                        /* INPUT */
 IGRint          max_level;                       /* INPUT */
 MEMptr          *delete_buffer;                  /* OUTPUT */

 {
  IGRlong                   status = PDM_S_SUCCESS;
  IGRshort                  free_mod = FALSE;
  IGRint                    bufsiz;
  IGRchar                   assy_path[DI_PATH_MAX];
  IGRchar                   **parts = NULL;
  IGRint                    part_count = 0;
  IGRint                    i;
  IGRshort                  load_file = FALSE;
  IGRshort                  unique_flag;
  IGRchar                   *catalog = NULL;
  IGRchar                   *number = NULL;
  IGRchar                   *revision = NULL;
  IGRchar                   *filename = NULL;
  IGRchar                   *cat_no = NULL;
  IGRchar                   *item_no = NULL;
  IGRchar                   *local_flag = NULL;
  struct  PDUref_node       *head = NULL;
  struct  PDUref_node       *tail = NULL;
  struct  PDUref_node       *buffer_files = NULL;
  struct  PDUref_node       *temp = NULL;
  struct  PDUref_node       *top = NULL; 


  _pdm_debug("In the PDUload_delete_buffer function", 0);

  /* Default module env. to current if mod_env is NULL */
  if (!mod_env)
     {
      mod_env = (struct GRmd_env *) malloc(sizeof(struct GRmd_env));
      bufsiz = sizeof(struct GRmd_env);
      gr$get_module_env(sizbuf = &bufsiz, buffer = mod_env);
      free_mod = TRUE;
     }

  /* Construct path to part directory */
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
                   max_level = max_level 
                  );

  if ( (status == DIR_S_SUCCESS) && (part_count > 0) )
     {
      /* Make sure buffer is formatted */
      if (*delete_buffer)
         {
         MEMclose(delete_buffer);
         *delete_buffer = NULL;
         }

      /* Format delete buffer */
      PDMopen_buffer(
                     7,
                     delete_buffer 
                    );

      /* Load delete buffer */
      for (i = 0; i < part_count; ++i)
          {
           load_file = TRUE;
           PDUstrip_dir_entry(parts[i]);

           /* Get part local flag */
/* ALR  6/23/94  Too many parameters */
/*
           status = PDUevaluate_exp(
                                    parts[i],
                                    "local_flag",
                                    &local_flag,
                                    mod_env->md_id.osnum
                                   );
*/
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


           /* Skip parts with no local files */
           if ( (strcmp(local_flag, "C") != 0) &&
                (strcmp(local_flag, "S") != 0) )
              continue;

           /* Get part file name */
/* ALR  6/23/94  Too many parameters */
/*
           status = PDUevaluate_exp(
                                    parts[i],
                                    "file_name",
                                    &filename,
                                    mod_env->md_id.osnum
                                   );
*/
           status = PDUevaluate_exp(
                                    parts[i],
                                    "file_name",
                                    &filename
                                   );

           if (status != PDM_S_SUCCESS)
              {
               _pdm_debug("could not evaluate file_name attr.", 0);
               return(0);
              }

           if (load_file)
              {
               /* Check to see if file is unique */
               unique_flag = TRUE;
               top = buffer_files;

               while (top)
                     {
                      if (strcmp(top->filename, filename) == 0)
                         {
                          _pdm_debug("file already included", 0);
                          unique_flag = FALSE;
                          break;
                         }

                      else
                          top = top->next;

                     } /* end while */

               if (unique_flag == TRUE)
                  {
                   /* Extract part catalog name */
/* ALR  6/23/94  Too many parameters */
/*
                   status = PDUevaluate_exp(
                                            parts[i],
                                            "catalog_name",
                                            &catalog,
                                            mod_env->md_id.osnum
                                           );
*/
                   status = PDUevaluate_exp(
                                            parts[i],
                                            "catalog_name",
                                            &catalog
                                           );

                   if (status != PDM_S_SUCCESS)
                      {
                       _pdm_debug("could not evaluate catalog attr", 0);
                       return(0);
                      }

                   /* Extract part number */
/* ALR  6/23/94  Too many parameters */
/*
                   status = PDUevaluate_exp(
                                            parts[i],
                                            "part_number",
                                            &number,
                                            mod_env->md_id.osnum
                                           );
*/
                   status = PDUevaluate_exp(
                                            parts[i],
                                            "part_number",
                                            &number
                                          );
                       
                   if (status != PDM_S_SUCCESS)
                      {
                       _pdm_debug("could not evaluate number attr", 0);
                       return(0);
                      }

                   /* Extract part revision */
/* ALR  6/23/94  Too many parameters */
/*
                   status = PDUevaluate_exp(
                                            parts[i],
                                            "revision",
                                            &revision,
                                            mod_env->md_id.osnum
                                           );
*/
                   status = PDUevaluate_exp(
                                            parts[i],
                                            "revision",
                                            &revision
                                           );

                   if (status != PDM_S_SUCCESS)
                      {
                       _pdm_debug("could not evaluate revision attr", 0);
                       return(0);
                      }

                   /* Extract part catalog no */
/* ALR  6/23/94  Too many parameters */
/*
                   status = PDUevaluate_exp(
                                            parts[i],
                                            "catalog_no",
                                            &cat_no,
                                            mod_env->md_id.osnum
                                           );
*/
                   status = PDUevaluate_exp(
                                            parts[i],
                                            "catalog_no",
                                            &cat_no
                                           );

                   if (status != PDM_S_SUCCESS)
                      {
                       _pdm_debug("could not evaluate cat no attr", 0);
                       return(0);
                      }

                   /* Extract part item no */
/* ALR  6/23/94  Too many parameters */
/*
                   status = PDUevaluate_exp(
                                            parts[i],
                                            "item_no",
                                            &item_no,
                                            mod_env->md_id.osnum
                                           );
*/
                   status = PDUevaluate_exp(
                                            parts[i],
                                            "item_no",
                                            &item_no
                                           );

                   if (status != PDM_S_SUCCESS)
                      {
                       _pdm_debug("could not evaluate item no attr", 0);
                       return(0);
                      }

                   status = PDUload_local_file_buffer(
                                                      cat_no,
                                                      item_no,
                                                      catalog,
                                                      number,
                                                      revision,
                                                      filename,
                                                      delete_buffer 
                                                     );
                   _pdm_status("PDUload_local_file_buffer", status);

                   /* Create a node with buffer unique file info */
                   temp = (struct PDUref_node *)
                                            malloc(sizeof(struct PDUref_node));

                   /* Initialize temp fields */
                   temp->filename = NULL;
                   temp->description = NULL;
                   temp->next = NULL;

                   PDUfill_in_string(&(temp->filename), filename);

                   if (buffer_files)
                      {
                       /* Get to the end of list */
                       tail = buffer_files;
                       while (tail->next)
                             {
                              tail = tail->next;
                             }

                       /* Add part to file link list */
                       tail->next = temp;
                      }

                   else
                       {
                        buffer_files = temp;
                       }
                  }
              }

          } /* end for i loop */
     }

  else
      {
       _pdm_debug("no parts found in assembly structure", 0);
       return(PDM_S_SUCCESS);
      }

  if (buffer_files)
     {
      head = buffer_files;

      while (buffer_files)
            {
             buffer_files = buffer_files->next;
             free(head);
             head = buffer_files;
            }

     } /* end while loop */

  if (filename)
     free(filename);

  if (catalog)
     free(catalog);

  if (number)
     free(number);

  if (revision)
     free(revision);

  if (cat_no)
     free(cat_no);

  if (item_no)
     free(item_no);

  if (local_flag)
     free(local_flag);

  if (parts)
     di$free(lines = parts, count = part_count);

  if (free_mod)
     {
      free(mod_env);
      mod_env = NULL;
     }

  return(PDM_S_SUCCESS);
 }


/*
 * This function flags all parts in the assembly structure with their files
 * being copied locally. 
 */
IGRint  PDUflag_local_parts_in_assembly(
                                        mod_env,
                                        flag,
                                        copy_attach_buffer
                                       )

 struct GRmd_env *mod_env;                        /* INPUT */
 IGRchar         *flag;                           /* INPUT */
 MEMptr          copy_attach_buffer;              /* INPUT */

 {
  IGRlong                   status = PDM_S_SUCCESS;
  IGRshort                  free_mod = FALSE;
  IGRchar                   **asm_entry = NULL;
  IGRint                    bufsiz;
  IGRchar                   assy_path[DI_PATH_MAX];
  IGRchar                   **parts = NULL;
  IGRint                    part_count = 0;
  IGRint                    i, j;
  IGRint                    file_col;
  IGRchar                   *filename = NULL;


  _pdm_debug("In the function PDUflag_local_parts_in_assembly", 0);

  if (!copy_attach_buffer)
     {
      _pdm_debug("copy_attach_buffer is NULL", 0);
      return(PDM_S_SUCCESS);
     }

  if (copy_attach_buffer->rows <= 0)
     {
      _pdm_debug("copy_attach_buffer has no rows to flag", 0);
      return(PDM_S_SUCCESS);
     }

  /* Set up pointers to copy attach buffer */
  MEMbuild_array(copy_attach_buffer);
  PDUsetup_buffer(
                  copy_attach_buffer,
                  ROW,
                  &asm_entry
                 );

  /* Extract file column no */
  PDUget_buffer_col(
                    copy_attach_buffer,
                    "n_cofilename",
                    &file_col
                   );
  
  /* Default module env. to current if mod_env is NULL */
  if (!mod_env)
     {
      mod_env = (struct GRmd_env *) malloc(sizeof(struct GRmd_env));
      bufsiz = sizeof(struct GRmd_env);
      gr$get_module_env(sizbuf = &bufsiz, buffer = mod_env);
      free_mod = TRUE;
     }

  /* Construct path to part directory */
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
      /* Flag parts on file name match */
      for (i = 0; i < copy_attach_buffer->rows; ++i)
          {
           for (j = 0; j < part_count; ++j)
               {
                /* Get part file_name attribute */
                PDUstrip_dir_entry(parts[j]);

/* ALR  6/23/94  Too many parameters */
/*
                status = PDUevaluate_exp(
                                         parts[j],
                                         "file_name",
                                         &filename,
                                         mod_env->md_id.osnum
                                        );
*/
                status = PDUevaluate_exp(
                                         parts[j],
                                         "file_name",
                                         &filename
                                        );

                if (status != PDM_S_SUCCESS)
                   {
                    _pdm_debug("could not evaluate file_name attr.", 0);
                    return(0);
                   }

                if (strcmp(
                           filename,
                           asm_entry[(copy_attach_buffer->columns*i)+file_col]
                          ) == 0)
                   {
                    /* Update local_flag attribute */
                    PDUmodify_exp(
                                  0,
                                  parts[j],
                                  "local_flag",
                                  flag,
                                  mod_env->md_id.osnum
                                 );
                   }

               } /* end for j loop */

          } /* end for i loop */
     }

  else
      {
       _pdm_debug("no parts found in assembly structure", 0);
       return(PDM_S_SUCCESS);
      }

  /* Free up variables */
  if (parts)
     di$free(lines = parts, count = part_count);

  if (filename)
     free(filename);

  if (free_mod)
     {
      free(mod_env);
      mod_env = NULL;
     }

  return(PDM_S_SUCCESS);
 }


/*
 * This function unflags all parts in the assembly structure.
 */
IGRint  PDUunflag_local_parts_in_assembly(mod_env)

 struct GRmd_env *mod_env;                        /* INPUT */

 {
  IGRlong                   status = PDM_S_SUCCESS;
  IGRshort                  free_mod = FALSE;
  IGRint                    bufsiz;
  IGRchar                   assy_path[DI_PATH_MAX];
  IGRchar                   **parts = NULL;
  IGRint                    part_count = 0;
  IGRint                    i;
  IGRchar                   *filename = NULL;


  _pdm_debug("In the function PDUunflag_local_parts_in_assembly", 0);

  /* Default module env. to current if mod_env is NULL */
  if (!mod_env)
     {
      mod_env = (struct GRmd_env *) malloc(sizeof(struct GRmd_env));
      bufsiz = sizeof(struct GRmd_env);
      gr$get_module_env(sizbuf = &bufsiz, buffer = mod_env);
      free_mod = TRUE;
     }

  /* Construct path to part directory */
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
      /* Unflag parts on file name match */
      for (i = 0; i < part_count; ++i)
          {
           /* Get part file_name attribute */
/* ALR  6/23/94  Too many parameters */
/*
           status = PDUevaluate_exp(
                                    parts[i],
                                    "file_name",
                                    &filename,
                                    mod_env->md_id.osnum
                                   );
*/
           status = PDUevaluate_exp(
                                    parts[i],
                                    "file_name",
                                    &filename
                                   );

           if (status != PDM_S_SUCCESS)
              {
               _pdm_debug("could not evaluate file_name attr.", 0);
               return(0);
              }

           if (strcmp(filename, "") == 0)
              {
               _pdm_debug("file name is empty", 0);
               return(0);
              }

           /* Unflag local part */
           PDUstrip_dir_entry(parts[i]);

           /* Update local_flag attribute */
           PDUmodify_exp(
                         0,
                         parts[i],
                         "local_flag",
                         "",
                         mod_env->md_id.osnum
                        );

          } /* end for i loop */
     }

  else
      {
       _pdm_debug("no parts found in assembly structure", 0);
       return(PDM_S_SUCCESS);
      }

  /* Free up variables */
  if (parts)
     di$free(lines = parts, count = part_count);

  if (filename)
     free(filename);

  if (free_mod)
     {
      free(mod_env);
      mod_env = NULL;
     }

  return(PDM_S_SUCCESS);
 }



/*
 * This function flags deleted parts in the assembly structure.
 */
IGRint  PDUflag_deleted_parts_in_assembly(
                                          mod_env,
                                          part_path
                                         )

 struct GRmd_env *mod_env;                        /* INPUT */
 IGRchar         part_path[DI_PATH_MAX];          /* INPUT */
 {
  IGRlong                   status = PDM_S_SUCCESS;
  IGRshort                  free_mod = FALSE;
  IGRint                    bufsiz;
  IGRchar                   **parts = NULL;
  IGRint                    part_count = 0;
  IGRint                    i;
  

  _pdm_debug("In the function PDUflag_deleted_parts_in_assembly", 0);

  /* Default module env. to current if mod_env is NULL */
  if (!mod_env)
     {
      mod_env = (struct GRmd_env *) malloc(sizeof(struct GRmd_env));
      bufsiz = sizeof(struct GRmd_env);
      gr$get_module_env(sizbuf = &bufsiz, buffer = mod_env);
      free_mod = TRUE;
     }

  PDUstrip_dir_entry(part_path);

  /* Flag 1st-level part for deletion */
  PDUmodify_exp(
                0,
                part_path,
                "delete_flag",
                "Y",
                mod_env->md_id.osnum
               );

  /* Extract list of DIrectory objects from given parts path */
  status = di$find (
                    start_dir = part_path,
                    regexp = "P*",
                    lines = &parts,
                    ptr = &part_count,
                    max_level = -1 
                   );

  if ( (status == DIR_S_SUCCESS) && (part_count > 0) )
     {
      /* Flag children parts for deletion */
      for (i = 0; i < part_count; ++i)
          {
           PDUstrip_dir_entry(parts[i]);

           PDUmodify_exp(
                         0,
                         parts[i],
                         "delete_flag",
                         "Y",
                         mod_env->md_id.osnum
                        );
         
          } /* end for i loop */
     }

  /* Free up variables */
  if (parts)
     di$free(lines = parts, count = part_count);

  if (free_mod)
     {
      free(mod_env);
      mod_env = NULL;
     }

  return(PDM_S_SUCCESS);
 }



/*
 * This function deletes flagged parts in the assembly structure.
 */
IGRint  PDUdelete_flagged_parts_in_assembly(mod_env)

 struct GRmd_env *mod_env;                        /* INPUT */
 {
  IGRlong                   status = PDM_S_SUCCESS;
  IGRshort                  free_mod = FALSE;
  IGRint                    bufsiz;
  IGRchar                   **parts = NULL;
  IGRchar                   *delete_flag = NULL;
  IGRchar                   assy_path[DI_PATH_MAX];
  IGRint                    part_count = 0;
  IGRint                    i;


  _pdm_debug("In the function PDUdelete_flagged_parts_in_assembly", 0);

  /* Default module env. to current if mod_env is NULL */
  if (!mod_env)
     {
      mod_env = (struct GRmd_env *) malloc(sizeof(struct GRmd_env));
      bufsiz = sizeof(struct GRmd_env);
      gr$get_module_env(sizbuf = &bufsiz, buffer = mod_env);
      free_mod = TRUE;
     }

  /* Construct path to part directory */
  di$give_pathname(
                   osnum = mod_env->md_id.osnum,
                   pathname = assy_path
                  );

  strcat(assy_path, ":ASSEMBLY");

  /* Extract assembly first-level entries from assy. structure */
  status = di$find(
                   start_dir = assy_path,
                   regexp = "P*",
                   lines = &parts,
                   ptr = &part_count,
                   max_level = 1 
                  );

  if ( (status == DIR_S_SUCCESS) && (part_count > 0) )
     {
      for (i = 0; i < part_count; ++i)
          {
           PDUstrip_dir_entry(parts[i]);

           /* Get part delete_flag attribute */
/* ALR  6/23/94  Too many parameters */
/*
           status = PDUevaluate_exp(
                                    parts[i],
                                    "delete_flag",
                                    &delete_flag,
                                    mod_env->md_id.osnum
                                   );
*/
           status = PDUevaluate_exp(
                                    parts[i],
                                    "delete_flag",
                                    &delete_flag
                                   );

           if (status != PDM_S_SUCCESS)
              {
               _pdm_debug("could not evaluate delete attr.", 0);
               return(0);
              }

           if (strcmp(delete_flag, "Y") == 0)
              {
               /* Delete assembly entries for flagged part */
               status = PDUremove_assembly(parts[i], mod_env);
               _pdm_status("PDUremove_assembly", status);
              }

          } /* end for i loop */
     }

  else
      {
       _pdm_debug("no parts found in assembly", 0);
       return(PDM_S_SUCCESS);
      }

  /* Free up variables */
  if (delete_flag)
     free(delete_flag);

  if (parts)
     di$free(lines = parts, count = part_count);

  if (free_mod)
     {
      free(mod_env);
      mod_env = NULL;
     }

  return(PDM_S_SUCCESS);
 }



/*
 * This function flags local parts for save in the assembly structure.
 */
IGRint  PDUflag_local_parts_for_save_in_assembly(mod_env)

 struct GRmd_env *mod_env;                        /* INPUT */
 {
  IGRlong                   status = PDM_S_SUCCESS;
  IGRshort                  free_mod = FALSE;
  IGRint                    bufsiz;
  IGRchar                   **parts = NULL;
  IGRchar                   *loaded = NULL;
  IGRchar                   *local_flag = NULL;
  IGRchar                   *delete_flag = NULL;
  IGRchar                   assy_path[DI_PATH_MAX];
  IGRint                    part_count = 0;
  IGRint                    i;


  _pdm_debug("In the function PDUflag_local_parts_for_save_in_assembly", 0);

  /* Default module env. to current if mod_env is NULL */
  if (!mod_env)
     {
      mod_env = (struct GRmd_env *) malloc(sizeof(struct GRmd_env));
      bufsiz = sizeof(struct GRmd_env);
      gr$get_module_env(sizbuf = &bufsiz, buffer = mod_env);
      free_mod = TRUE;
     }

  /* Construct path to assembly directory */
  di$give_pathname(
                   osnum = mod_env->md_id.osnum,
                   pathname = assy_path
                  );

  strcat(assy_path, ":ASSEMBLY");

  /* Extract list of DIrectory objects from given parts path */
  status = di$find (
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

           /* Extract value for part loaded attr. */
           status = PDUevaluate_exp(
                                    parts[i],
                                    "loaded",
                                    &loaded
                                   );

           if (status != PDM_S_SUCCESS)
              {
               _pdm_debug("could not evaluate loaded attr.", 0);
               return(0);
              }

           /* Extract value for part local_flag attr. */
           status = PDUevaluate_exp(
                                    parts[i],
                                    "local_flag",
                                    &local_flag
                                   );

           if (status != PDM_S_SUCCESS)
              {
               _pdm_debug("could not evaluate local flag attr.", 0);
               return(0);
              }

           /* Extract value for part delete_flag attr. */
           status = PDUevaluate_exp(
                                    parts[i],
                                    "delete_flag",
                                    &delete_flag
                                   );

           if (status != PDM_S_SUCCESS)
              {
               _pdm_debug("could not evaluate delete flag attr.", 0);
               return(0);
              }

           if ( (strcmp(loaded, "Y") == 0) &&
                (strcmp(local_flag, "D") == 0) &&
                (strcmp(delete_flag, "Y") != 0) )
              {
               /* Flag part for save */
                PDUmodify_exp(
                              0,
                              parts[i],
                              "local_flag",
                              "S",
                              mod_env->md_id.osnum
                             );
              }

          } /* end for i loop */
     }

  /* Free up variables */
  if (loaded)
     free(loaded);

  if (local_flag)
     free(local_flag);

  if (delete_flag)
     free(delete_flag);

  if (parts)
     di$free(lines = parts, count = part_count);

  if (free_mod)
     {
      free(mod_env);
      mod_env = NULL;
     }

  return(PDM_S_SUCCESS);
 }



/* 
 * This function loads the child buffer for checkin command.
 */
IGRint  PDUload_child_buffer(
                             child_buffer,
                             mod_env 
                            )
 MEMptr     *child_buffer;           /* INPUT */
 struct     GRmd_env    mod_env;     /* INPUT */

  {
   IGRlong                   status = PDM_S_SUCCESS;
   IGRlong                   msg;
   IGRchar                   value[MAX_VALUE];
   IGRint                    count = 0;
   IGRint                    type;
   IGRint                    char_index;
   IGRchar                   *child_no = NULL;
   IGRchar                   *catalog = NULL;
   IGRchar                   *number = NULL;
   IGRchar                   *revision = NULL;
   IGRchar                   *attached = NULL;
   IGRchar                   *quantity = NULL;
   IGRchar                   *usage_id = NULL;
   IGRchar                   *tag_no = NULL;
   IGRchar                   *alt_tag = NULL;
   IGRchar                   *incl_BOM = NULL;
   IGRchar                   *explode_BOM = NULL;
   IGRchar                   *incl_asm = NULL;
   IGRchar                   *file_name = NULL;
   IGRchar                   *history = NULL;
   IGRchar                   *catalog_no = NULL;
   IGRchar                   *item_no = NULL;
   IGRchar                   *row = NULL;
   IGRchar                   assy_path[DI_PATH_MAX];
   IGRchar                   file_dir[DI_PATH_MAX];
   struct  PDUpart_node      *part_ids = NULL;
   struct  PDUpart_node      *head = NULL;


 
   _pdm_debug("In the PDUload_child_buffer function", 0);

   /* Check to see if parts exist in obj space */
   if ( !PDUdo_parts_exist(1, mod_env.md_id.osnum) )
      {
       _pdm_debug("no parts found to checkin", 0);
       return(PDM_S_SUCCESS);
      }

   /* Extract all PDU GRparts from object space */
   status = PDUget_all_GRpart_ids(
                                  mod_env.md_id.osnum,
                                  &part_ids,
                                  &count
                                 );
   _pdm_status("PDUget_all_GRpart_ids", status);

   if ( (count == 0) || (!part_ids) )
        {
         _pdm_debug("no PDU GRpart parts found to checkin", 0);
         return(PDM_S_SUCCESS);
        }
 
   /* Create and format child buffer, if necessary */
   if (*child_buffer == NULL)
      {
       status = PDUformat_buffer(PDU_CHILD_BUFR, child_buffer);
       _pdm_status("PDUformat_buffer", status);
      }

   /* Construct path to file directory */
   di$give_pathname(
                    osnum = mod_env.md_id.osnum,
                    pathname = file_dir
                   );

   /* Loop thru extracting part checkin info, write info to child buffer */
   head = part_ids;

   while (head)
         {
          /* Extract child no */
          co$part_get_attr (
                            msg = &msg,
                            mod_env = &mod_env,
                            part = &(head->part_id),
                            attr = "child_no",
                            value = value,
                            type = &type
                           );

          /* Store value in child_no */
          PDUunquote(value);
          PDUfill_in_string(&child_no, value);

          /* Extract catalog name */
          co$part_get_attr (
                            msg = &msg,
                            mod_env = &mod_env,
                            part = &(head->part_id),
                            attr = "CATALOG",
                            value = value,
                            type = &type
                           );

          /* Store value in catalog */
          PDUfill_in_string(&catalog, value);

          /* Extract part number */
          co$part_get_attr (
                            msg = &msg,
                            mod_env = &mod_env,
                            part = &(head->part_id),
                            attr = "NUMBER",
                            value = value,
                            type = &type
                           );
          
          /* Store value in number */
          PDUfill_in_string(&number, value);

          /* Extract part revision */
          co$part_get_attr (
                            msg = &msg,
                            mod_env = &mod_env,
                            part = &(head->part_id),
                            attr = "REVISION",
                            value = value,
                            type = &type
                           );
          
          /* Store value in revision */
          PDUfill_in_string(&revision, value);

          /* Extract attach flag */
          co$part_get_attr (
                            msg = &msg,
                            mod_env = &mod_env,
                            part = &(head->part_id),
                            attr = "attach_flag",
                            value = value,
                            type = &type
                           );

           if (strcmp(value, "-1.000000") != 0)
              {
               PDUfill_in_string(&attached, "Y");
              }

           else
               {
                PDUfill_in_string(&attached, "N");
               }

          /* Extract quantity */
          co$part_get_attr (
                            msg = &msg,
                            mod_env = &mod_env,
                            part = &(head->part_id),
                            attr = "quantity",
                            value = value,
                            type = &type
                           );
          
          /* Store value in quantity */
          PDUfill_in_string(&quantity, value);

          /* Extract usage id */
          co$part_get_attr (
                            msg = &msg,
                            mod_env = &mod_env,
                            part = &(head->part_id),
                            attr = "usage_id",
                            value = value,
                            type = &type
                           );
          
          /* Store value in usage_id */
          PDUunquote(value);
          PDUfill_in_string(&usage_id, value);

          /* Extract tag no */
          co$part_get_attr (
                            msg = &msg,
                            mod_env = &mod_env,
                            part = &(head->part_id),
                            attr = "tag",
                            value = value,
                            type = &type
                           );
          
          /* Store value in tag_no */
          PDUunquote(value);
          PDUfill_in_string(&tag_no, value);

          /* Extract alt tag no */
          co$part_get_attr (
                            msg = &msg,
                            mod_env = &mod_env,
                            part = &(head->part_id),
                            attr = "alt_tag",
                            value = value,
                            type = &type
                           );
          
          /* Store value in alt_tag */
          PDUunquote(value);
          PDUfill_in_string(&alt_tag, value);

          /* Extract include BOM flag */
          co$part_get_attr (
                            msg = &msg,
                            mod_env = &mod_env,
                            part = &(head->part_id),
                            attr = "incl_BOM",
                            value = value,
                            type = &type
                           );
          
          /* Store value in incl_BOM */
          PDUfill_in_string(&incl_BOM, value);

          /* Extract include strucure flag */
          co$part_get_attr (
                            msg = &msg,
                            mod_env = &mod_env,
                            part = &(head->part_id),
                            attr = "incl_asm",
                            value = value,
                            type = &type
                           );
          
          /* Store value in incl_asm */
          PDUfill_in_string(&incl_asm, value);

          /* Extract explode BOM flag */
          co$part_get_attr (
                            msg = &msg,
                            mod_env = &mod_env,
                            part = &(head->part_id),
                            attr = "explode_BOM",
                            value = value,
                            type = &type
                           );

          /* Store value in explode_BOM */
          PDUfill_in_string(&explode_BOM, value);

          /* Extract history */
          co$part_get_attr (
                            msg = &msg,
                            mod_env = &mod_env,
                            part = &(head->part_id),
                            attr = "history",
                            value = value,
                            type = &type
                           );
          
          /* Store value in history */
          PDUfill_in_string(&history, value);

          /* Construct full path to part's assembly structure */
          strcpy(assy_path, file_dir);
          strcat(assy_path, ":ASSEMBLY:P");
          strcat(assy_path, child_no);

          _pdm_debug("assy-path = <%s>", assy_path);

          /* Extract catalog no from assembly structure */
          status = PDUevaluate_exp(
                                   assy_path,
                                   "catalog_no",
                                   &catalog_no
                                  );
          _pdm_status("PDUevaluate_exp", status);

          if (status != PDM_S_SUCCESS)
            {
            status = PDMget_catno_partno(catalog, number, revision,
                                         &catalog_no, &item_no);
            _pdm_status("PDMget_catno_partno",status);
            }

          /* Extract item no from assembly structure */
          status = PDUevaluate_exp(
                                   assy_path,
                                   "item_no",
                                   &item_no
                                  );
          _pdm_status("PDUevaluate_exp", status);

          if (status != PDM_S_SUCCESS)
            {
            status = PDMget_catno_partno(catalog, number, revision,
                                         &catalog_no, &item_no);
            _pdm_status("PDMget_catno_partno",status);
            }

          /* Extract file name from assembly structure */
          status = PDUevaluate_exp(
                                   assy_path,
                                   "file_name",
                                   &file_name
                                  );
          _pdm_status("PDUevaluate_exp", status);

          if (status != PDM_S_SUCCESS)
            {
            status = PDUget_filename_for_part(catalog, number, revision,
                                              &file_name);
            _pdm_status("PDUget_filename_for_part", status);
            }

          /* Free row */
          if (row) 
             free(row);

           /* Allocate space for row */
         row =
             (IGRchar *)malloc(sizeof(IGRchar)*(*child_buffer)->row_size);
             memset(row, NULL, (*child_buffer)->row_size);

         char_index = 0;

         /* Write checkin info to child buffer */
         if (child_no == NULL)
            row[char_index++] = '\1';
         else if (strcmp(child_no, "") == 0)
            row[char_index++] = '\1';
         else
            PDUadd_buffer_string(row, &char_index, child_no);

         if (catalog == NULL)
            row[char_index++] = '\1';
         else if (strcmp(catalog, "") == 0)
            row[char_index++] = '\1';
         else
            PDUadd_buffer_string(row, &char_index, catalog);

         if (number == NULL)
            row[char_index++] = '\1';
         else if (strcmp(number, "") == 0)
            row[char_index++] = '\1';
         else
            PDUadd_buffer_string(row, &char_index, number);

         if (revision == NULL)
            row[char_index++] = '\1';
         else if (strcmp(revision, "") == 0)
            row[char_index++] = '\1';
         else
            PDUadd_buffer_string(row, &char_index, revision);

         if (attached == NULL)
            row[char_index++] = '\1';
         else if (strcmp(attached, "") == 0)
            row[char_index++] = '\1';
         else
            PDUadd_buffer_string(row, &char_index, attached);

         if (quantity == NULL)
            row[char_index++] = '\1';
         else if (strcmp(quantity, "") == 0)
            row[char_index++] = '\1';
         else
            PDUadd_buffer_string(row, &char_index, quantity);

         if (usage_id == NULL)
            row[char_index++] = '\1';
         else if (strcmp(usage_id, "") == 0)
            row[char_index++] = '\1';
         else
            PDUadd_buffer_string(row, &char_index, usage_id);

         if (tag_no == NULL)
            row[char_index++] = '\1';
         else if (strcmp(tag_no, "") == 0)
            row[char_index++] = '\1';
         else
            PDUadd_buffer_string(row, &char_index, tag_no);

         if (alt_tag == NULL)
            row[char_index++] = '\1';
         else if (strcmp(alt_tag, "") == 0)
            row[char_index++] = '\1';
         else
            PDUadd_buffer_string(row, &char_index, alt_tag);

         if (incl_BOM == NULL)
            row[char_index++] = '\1';
         else if (strcmp(incl_BOM, "") == 0)
            row[char_index++] = '\1';
         else
            PDUadd_buffer_string(row, &char_index, incl_BOM);

          if (incl_asm == NULL)
            row[char_index++] = '\1';
         else if (strcmp(incl_asm, "") == 0)
            row[char_index++] = '\1';
         else
            PDUadd_buffer_string(row, &char_index, incl_asm);

         if (explode_BOM == NULL)
            row[char_index++] = '\1';
         else if (strcmp(explode_BOM, "") == 0)
            row[char_index++] = '\1';
         else
            PDUadd_buffer_string(row, &char_index, explode_BOM);

         if (file_name == NULL)
            row[char_index++] = '\1';
         else if (strcmp(file_name, "") == 0)
            row[char_index++] = '\1';
         else
            PDUadd_buffer_string(row, &char_index, file_name);

         if (history == NULL)
            row[char_index++] = '\1';
         else if (strcmp(history, "") == 0)
            row[char_index++] = '\1';
         else
            PDUadd_buffer_string(row, &char_index, history);

         if (catalog_no == NULL)
            row[char_index++] = '\1';
         else if (strcmp(catalog_no, "") == 0)
            row[char_index++] = '\1';
         else
            PDUadd_buffer_string(row, &char_index, catalog_no);

         if (item_no == NULL)
            row[char_index++] = '\1';
         else if (strcmp(item_no, "") == 0)
            row[char_index++] = '\1';
         else
            PDUadd_buffer_string(row, &char_index, item_no);

         /* Add entry for level no */
         row[char_index++] = '\1';

         _pdm_debug("row = <%s>", row);

         /* Write part info to child buffer */
         status = MEMwrite(*child_buffer, row);
         _pdm_status("MEMwrite", status);

         if (status != MEM_S_SUCCESS)
            {
             _pdm_debug("SEVERE error: could not write to child buffer", 0);
             return(status);
            }
          
         /* Procede to next part */
         head = head->next;

         } /* end while loop */

   /* Free part attr names */
   if (child_no)
      free(child_no);
   
   if (catalog)
      free(catalog);

   if (number)
      free(number);

   if (revision)
      free(revision);

   if (attached)
      free(attached);

   if (quantity)
      free(quantity);

   if (usage_id)
      free(usage_id);

   if (tag_no)
      free(tag_no);

   if (alt_tag)
      free(alt_tag);

   if (incl_BOM)
      free(incl_BOM);

   if (explode_BOM)
      free(explode_BOM);

   if (file_name)
      free(file_name);

   if (history)
      free(history);

   if (catalog_no)
      free(catalog_no);

   if (item_no)
      free(item_no);

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

   if (PDMdebug_on)
       MEMprint_buffer("child buffer", *child_buffer, PDU_DEBUG_FILE);    
   
   return(PDM_S_SUCCESS);
  }

/* 
 * This function loads the attach buffer for checkin command.
 */
IGRint  PDUload_attach_buffer(
                              attach_buffer,
                              mod_env 
                             )
 MEMptr     *attach_buffer;          /* INPUT */
 struct     GRmd_env    mod_env;     /* INPUT */

  {
   IGRlong                   status = PDM_S_SUCCESS;
   IGRchar                   *row = NULL;
   struct PDUattach_node     *attach_list = NULL;
   struct PDUattach_node     *head = NULL;

 
   _pdm_debug("In the PDUload_attach_buffer function", 0);

   /* Construct the attach list */
   status = PDUappend_attach_list(&mod_env, &attach_list);
   _pdm_status("PDUappend_attach_list", status);

   if (status != PDM_S_SUCCESS)
      {
       _pdm_debug("PDUappend_attach_list failed", 0);
       return(0);
      }

   if (attach_list)
      {
       status = PDMopen_buffer(2, attach_buffer);
       _pdm_status("PDMopen_buffer", status);

       /* Allocate space for row */
       row = (IGRchar *)malloc(sizeof(IGRchar)*(*attach_buffer)->row_size);
      }

   else
       {
        _pdm_debug("no attached parts found", 0);
        return(PDM_S_SUCCESS);
       }

   head = attach_list;

   while (head)
         {
          /* Initialize row */
          memset(row, NULL, (*attach_buffer)->row_size);

          /* Construct buffer row */
          sprintf(
                  row,
                  "%s\1%s\1%s\1",
                  head->catalog_no,
                  head->item_no,
                  head->file_name
                 );

          _pdm_debug("row = <%s>", row);

          /* Write attach info to attach buffer */
          status = MEMwrite(*attach_buffer, row);
          _pdm_status("MEMwrite", status);

          if (status != MEM_S_SUCCESS)
             {
              _pdm_debug("MEMwrite failed", 0);
              return(0);
             }

          /* Process next node */
          head = head->next;

         } /* end while loop */

   if (PDMdebug_on)
      MEMprint_buffer("attach buffer", *attach_buffer, PDU_DEBUG_FILE);    

   /* Free variables */
   if (row)
      free(row);

   /* Free up attach list */
   if (attach_list)
      {
       head = attach_list;

       while (attach_list)
             {
              attach_list = attach_list->next;
              free(head);
              head = attach_list;
             }
      } /* end while loop */

   return(PDM_S_SUCCESS);
  }


/*
 * This function removes an assembly from the object space.
 */
IGRint	PDUremove_assembly(
                           assembly_path,
                           mod_env
                          )

 IGRchar       assembly_path[DI_PATH_MAX];     /* INPUT */
 struct        GRmd_env  *mod_env;             /* INPUT */

  {
  IGRint	    status = PDM_S_SUCCESS;	
  IGRchar           entry[DI_PATH_MAX];     
  IGRchar           part_path[DI_PATH_MAX];     
  IGRchar           **parts;           
  IGRint            part_count = 0;        
  IGRint            exp_count = 0;        
  IGRint            i;                
  IGRint            j;
  OM_p_CLASSLIST    classlist;
  OM_p_CLASSLIST    num_classlist;
  OMuword           classid;
  OMuword           num_classid;
  IGRlong           NumberOfBytes, BytesReceived;
  IGRlong           msg;
  struct PDUid      *exp_ids;
  FILE              *pdu_debug_file;
 


  _pdm_debug("In the function PDUremove_assembly", 0);

  _pdm_debug("assembly path = <%s>", assembly_path);

  /* Extract list of parts from given assembly path */
  status = di$find (
                    start_dir = assembly_path,
                    regexp = "P*",
                    lines = &parts,
                    ptr = &part_count,
                    max_level = -1
                   );
       
 /* Get the class id of GRpart */
 status = om$get_classid(
                         classname = "text_exp",
                         p_classid = &classid
                        );
 
 status = om$get_classid(
                         classname = "expression",
                         p_classid = &num_classid
                        );
 /* Malloc classlist */
 classlist = (struct OM_sd_classlist *) malloc (sizeof
                        (struct OM_sd_classlist));

 /* Initialize certain field in classlist */
 classlist->w_count = 1;
 classlist->w_flags = OM_CLST_internal;
 classlist->p_classes = &classid;

 /* Malloc classlist */
 num_classlist = (struct OM_sd_classlist *) malloc (sizeof
                        (struct OM_sd_classlist));

 /* Initialize certain field in classlist */
 num_classlist->w_count = 1;
 num_classlist->w_flags = OM_CLST_internal;
 num_classlist->p_classes = &num_classid;

 _pdm_debug("class id = %d", classid);

 /* Get current module environment information, if mod_env = NULL */
 if (!mod_env)
    {
     NumberOfBytes = sizeof(*mod_env);
     status = gr$get_module_env(
                                msg = &msg,
                                sizbuf = &NumberOfBytes,
                                buffer = mod_env,
                                nret = &BytesReceived
                               );
    }

 /* Check to see if part count is 0 */
  if (part_count == 0)
     {
      _pdm_debug("no parts found in assembly",0);

      /* Extract parent expressions */
      strcpy(part_path, assembly_path);
      strcat(part_path, ":*");

      status = di$dump (
                        regexp = part_path,
                        p_classes = classlist,
                        grids = ( DIgrid **) &exp_ids,
                        ptr = &exp_count
                       );

      if ( (exp_count > 0) && (status == DIR_S_SUCCESS) )
         {
          /* Delete parent expressions */
          _pdm_debug("exp_count = %d", exp_count);
          for (i = 0; i < exp_count; ++i)
              {
               status = PDUdelete_exp(exp_ids[i], *mod_env);
               _pdm_status("PDUdelete_exp", status);

               /* Remove expression from part directory */
               status = di$rm_objid(
                                    objid = exp_ids[i].objid,
                                    osnum = exp_ids[i].osnum
                                   );
               _pdm_status("di$rm_objid",status);
              }
         }

      else
          {
           _pdm_debug("part <%s> is an ultimate parent", assembly_path);
          }
     

      status = di$dump (
                        regexp = part_path,
                        p_classes = num_classlist,
                        grids = ( DIgrid **) &exp_ids,
                        ptr = &exp_count
                       );

      if ( (exp_count > 0) && (status == DIR_S_SUCCESS) )
         {
          /* Delete parent expressions */
          _pdm_debug("exp_count = %d", exp_count);
          for (i = 0; i < exp_count; ++i)
              {
               status = PDUdelete_exp(exp_ids[i], *mod_env);
               _pdm_status("PDUdelete_exp", status);

               /* Remove expression from part directory */
               status = di$rm_objid(
                                    objid = exp_ids[i].objid,
                                    osnum = exp_ids[i].osnum
                                   );
               _pdm_status("di$rm_objid",status);
              }
         }

      else
          {
           _pdm_debug("part <%s> is an ultimate parent", assembly_path);
          }

      /* Delete parent directory */
      strcpy(part_path, assembly_path);
      strcat(part_path, ":");

      _pdm_debug("part directory = <%s>", part_path); 
      status = di$rmdir(dirname = part_path, path = NULL);

      /* Check to see if deleted part was the only part in assembly, if
       * so, delete the root ASSEMBLY entry.
       */
      di$give_pathname(
                       osnum = (*mod_env).md_id.osnum,
                       pathname = assembly_path
                      );

      strcat(assembly_path,":");
      strcat(assembly_path,"ASSEMBLY:*");
      _pdm_debug("assembly_path = <%s>", assembly_path);

      /* Check to see if no more parts exist in assembly */
      status = di$ls(regexp = assembly_path, ptr = &part_count);
      _pdm_status("di$ls", status);

      _pdm_debug("%d part(s) found under ASSEMBLY", part_count);

      *((IGRchar *)strrchr(assembly_path,'*')) = '\0';
      _pdm_debug("ASSEMBLY root path <%s>", assembly_path);

      if ( (part_count == 0) || (status != DIR_S_SUCCESS) )
         {
          /* Delete ASSEMBLY root directory */
          status = di$rmdir(dirname = assembly_path, path = NULL);
         }

      return(PDM_S_SUCCESS);
     }

  _pdm_debug("%d part(s) were found in assembly", part_count);

  if (PDMdebug_on)
     {
      /* Open debug file */
      pdu_debug_file = (FILE *) fopen (PDU_DEBUG_FILE, "a");

      for (i = 0; i < part_count; ++i)
          {
           fprintf(
                   pdu_debug_file,
                   "PDU -- parts[%d] = <%s>\n", i, parts[i]
                  );
          }

      /* Close debug file */
      fclose(pdu_debug_file);
     }

  /* Remove leaf_level directories and expressions */
  for (i = part_count - 1; i >= 0; --i)
      {
       strcpy(entry, parts[i]);
       strcat(entry,"*");
       _pdm_debug("entry = <%s>", entry);

       /* Extract all expression objects under current part */
       status = di$dump (
                         regexp = entry,
                         p_classes = classlist,
                         grids = (DIgrid **) &exp_ids,
                         ptr = &exp_count
                        );
       _pdm_debug("exp count = %d", exp_count);
       _pdm_status("di$dump", status);

       if ( (exp_count > 0) && (status == DIR_S_SUCCESS) )
          {
           /* Delete current part expressions */
           for (j = 0; j < exp_count; ++j)
               {
                status = PDUdelete_exp(exp_ids[j], *mod_env);
                _pdm_status("PDUdelete_exp", status);

                if (status != PDM_S_SUCCESS)
                   {
                    _pdm_debug("PDUdelete_exp failed", 0);
                    break;
                   }

                /* Remove expression from part directory */
                status = di$rm_objid(
                                     objid = exp_ids[j].objid,
                                     osnum = exp_ids[j].osnum
                                    );
                _pdm_status("di$rm_objid",status);
               }
          }

       else
          { 
           _pdm_debug("SEVERE error: no expressions found", 0);
           return(PDM_S_SUCCESS);
          }

       status = di$dump (
                         regexp = entry,
                         p_classes = num_classlist,
                         grids = (DIgrid **) &exp_ids,
                         ptr = &exp_count
                        );
       _pdm_debug("exp count = %d", exp_count);
       _pdm_status("di$dump", status);

       if ( (exp_count > 0) && (status == DIR_S_SUCCESS) )
          {
           /* Delete current part expressions */
           for (j = 0; j < exp_count; ++j)
               {
                status = PDUdelete_exp(exp_ids[j], *mod_env);
                _pdm_status("PDUdelete_exp", status);

                if (status != PDM_S_SUCCESS)
                   {
                    _pdm_debug("PDUdelete_exp failed", 0);
                    break;
                   }

                /* Remove expression from part directory */
                status = di$rm_objid(
                                     objid = exp_ids[j].objid,
                                     osnum = exp_ids[j].osnum
                                    );
                _pdm_status("di$rm_objid",status);
               }
          }

       else
          { 
           _pdm_debug("no numeric expressions found", 0);
          }

       /* Delete part directory */
       /* Delete part directory */
       _pdm_debug("part directory = <%s>", parts[i]);
       status = di$rmdir(dirname = parts[i], path = NULL);
      }
 
  /* Extract parent expressions, if any */
  strcpy(part_path, assembly_path);
  strcat(part_path, ":*");

  status = di$dump (
                    regexp = part_path,
                    p_classes = classlist,
                    grids = (DIgrid **) &exp_ids,
                    ptr = &exp_count
                   );

  if ( (exp_count > 0) && (status == DIR_S_SUCCESS) )
     {
      /* Delete parent expressions */
      for (i = 0; i < exp_count; ++i)
          {
           status = PDUdelete_exp(exp_ids[i], *mod_env);
           _pdm_status("PDUdelete_exp", status);

           if (status != PDM_S_SUCCESS)
              {
               _pdm_debug("PDUdelete_exp failed", 0);
               break;
              }

           /* Remove expression from part directory */
           status = di$rm_objid(
                                objid = exp_ids[i].objid,
                                osnum = exp_ids[i].osnum
                               );
           _pdm_status("di$rm_objid",status);
          }
     }

  else
     {
      _pdm_debug("part <%s> is an ultimate parent", assembly_path);
     }

  status = di$dump (
                    regexp = part_path,
                    p_classes = num_classlist,
                    grids = (DIgrid **) &exp_ids,
                    ptr = &exp_count
                   );

  if ( (exp_count > 0) && (status == DIR_S_SUCCESS) )
     {
      /* Delete parent expressions */
      for (i = 0; i < exp_count; ++i)
          {
           status = PDUdelete_exp(exp_ids[i], *mod_env);
           _pdm_status("PDUdelete_exp", status);

           if (status != PDM_S_SUCCESS)
              {
               _pdm_debug("PDUdelete_exp failed", 0);
               break;
              }

           /* Remove expression from part directory */
           status = di$rm_objid(
                                objid = exp_ids[i].objid,
                                osnum = exp_ids[i].osnum
                               );
           _pdm_status("di$rm_objid",status);
          }
     }

  else
     {
      _pdm_debug("part <%s> is an ultimate parent", assembly_path);
     }

  strcpy(part_path, assembly_path);
  strcat(part_path, ":");

  _pdm_debug("part directory = <%s>", part_path);
  status = di$rmdir(dirname = part_path, path = NULL);

  /* Check to see if deleted part was the only part in assembly, if
   * so, delete the root ASSEMBLY entry.
   */
  di$give_pathname(
                   osnum = (*mod_env).md_id.osnum,
                   pathname = assembly_path
                  );

  strcat(assembly_path,":");
  strcat(assembly_path,"ASSEMBLY");

  /* Check to see if no more parts exist in assembly */
  status = di$ls(regexp = assembly_path, ptr = &part_count);

  if ( (part_count == 0) && (status == DIR_S_SUCCESS) )
     {
      /* Delete ASSEMBLY root directory */
      strcat(assembly_path, ":");
      status = di$rmdir(dirname = assembly_path, path = NULL);
     }

  /* Free up parts and part_count */
  di$free (lines = parts, count = part_count);

  return(PDM_S_SUCCESS);
 }


/*
 * This function creates the automatic assembly toggle directory.
 */
IGRint  PDUextract_auto_assy_toggle(
                                    osnum,
                                    toggle_value
                                   )

 OMuword      osnum;            /* INPUT */
 IGRchar      **toggle_value;   /* OUTPUT */
  {

   IGRlong       status = PDM_S_SUCCESS;
   IGRchar       file_dir[DI_PATH_MAX];
   IGRchar       **toggles;
   IGRint        entry_count;
   IGRint        count = 0;
   OM_S_OBJID    osid = NULL_OBJID;


   _pdm_debug("In the PDUextract_auto_assy_toggle function", 0);

   /* Check if need to get active design module info */
   if (osnum == 0)
     {
     /* Get active module info */
     status = ex$get_cur_mod ( id = &osid, osnum = &osnum );
     _pdm_debug("osnum = %d", osnum);
     _pdm_rstatus ("ex$get_cur_mod", status);
     }

   /* Construct path to assembly structure */
   di$give_pathname(
                    osnum = osnum,
                    pathname = file_dir 
                   );

   strcat(file_dir, ":PDU:auto_assy_toggle");

   /* Check to see if toggle directory already exists */
   di$ls(regexp = file_dir, ptr = &count);

   if (count > 0)
      {
       _pdm_debug("auto assy toggle already exists", 0);
       DIstmocpy(file_dir, "PDU", "auto_assy_toggle", "", NULL, osnum);

       /* Get the tag value for the part */
       status = di$find(
                        start_dir = file_dir,
                        regexp = "*",
                        lines = &toggles,
                        grids = NULL,
                        ptr = &entry_count,
                        max_level = 1,
                        deep = NULL,
                        options = NULL
                       );

       if (status == DIR_S_SUCCESS)
          {
           status = PDUextract_dir_value(
                                         toggles[0],
                                         "auto_assy_toggle",
                                         toggle_value
                                        );
           if (status == PDM_S_SUCCESS)
              {
               /* Free up tags  and entry_count */
               di$free (lines = toggles, count = entry_count);
               status = PDM_S_SUCCESS;
              }
          }

       return(status);
      }

   else
      {
       /* Need to create toggle entry */
       strcat(file_dir, ":");
       strcat(file_dir, "Y");
       strcat(file_dir, ":");
       di$mkpath(pathname = file_dir);

       /* Load default value */
       PDUfill_in_string(toggle_value, "Y");
       status = PDM_S_SUCCESS;
      }

   return(status);
  }

/*
 * This function updates the automatic assembly toggle directory.
 */
IGRint  PDUupdate_auto_assy_toggle(
                                   osnum,
                                   old_value,
                                   new_value
                                  )

 OMuword      osnum;            /* INPUT */
 IGRchar      *old_value;       /* INPUT */
 IGRchar      *new_value;       /* INPUT */
  {

   IGRlong       status = PDM_S_SUCCESS;
   IGRchar       file_dir[DI_PATH_MAX];
   IGRchar       tmp_dir[DI_PATH_MAX];
   OM_S_OBJID    osid = NULL_OBJID;


   _pdm_debug("In the PDUupdate_auto_assy_toggle function", 0);

   /* Check if need to get active design module info */
   if (osnum == 0)
     {
     /* Get active module info */
     status = ex$get_cur_mod ( id = &osid, osnum = &osnum );
     _pdm_debug("osnum = %d", osnum);
     _pdm_rstatus ("ex$get_cur_mod", status);
     }

   /* Construct path to toggle value */
   di$give_pathname(
                    osnum = osnum,
                    pathname = file_dir 
                   );

   strcat(file_dir, ":PDU:auto_assy_toggle");
   sprintf(tmp_dir, "%s:%s:", file_dir, old_value);

   /* Remove old toggle directory */
   di$rmdir(dirname = tmp_dir, path = NULL);

   /* Create new toggle directory with new value */
   strcat(file_dir, ":");
   strcat(file_dir, new_value);
   strcat(file_dir, ":");
   di$mkpath(pathname = file_dir);

   return(PDM_S_SUCCESS);
  }


/*
 * This function loads the local files buffer for part attachment.
 */
IGRint  PDUload_local_file_buffer(
                                  cat_no,
                                  item_no,
                                  catalog,
                                  number,
                                  revision,
                                  file_name,
                                  local_files
                                 )

 IGRchar     *cat_no;
 IGRchar     *item_no;
 IGRchar     *catalog;
 IGRchar     *number;
 IGRchar     *revision;
 IGRchar     *file_name;
 MEMptr      *local_files;

 {
  IGRlong     status = PDM_S_SUCCESS;
  IGRchar     *row = NULL;

  _pdm_debug("In the PDUload_local_file_buffer function", 0);

  /* Malloc and initialize row */
  row = (IGRchar *) malloc (sizeof(IGRchar)* (*local_files)->row_size);
  memset(row, NULL, sizeof(IGRchar) * (*local_files)->row_size);

  sprintf(
          row,
          "%s\1%s\1%s\1%s\1%s\1%s\1\1",
          cat_no,
          item_no,
          catalog,
          number,
          revision,
          file_name
         );

  _pdm_debug("row = <%s>", row);

  status = MEMwrite(*local_files, row);
  _pdm_status("MEMwrite", status);

  if (status == MEM_S_SUCCESS)
     status = PDM_S_SUCCESS;

  if (row)
     free(row);

  return(status);
 }

/*
 * This function loads the copy macro lib buffer for part attachment.
 */
IGRint  PDUload_macrolibrary_copy_buffer(
                                         catalog,
                                         number,
                                         revision,
                                         detached_parts 
                                        )

 IGRchar     *catalog;
 IGRchar     *number;
 IGRchar     *revision;
 MEMptr      *detached_parts;

 {
  IGRlong     status = PDM_S_SUCCESS;
  IGRchar     *row = NULL;

  _pdm_debug("In the PDUload_macrolibrary_copy_buffer function", 0);

  /* Format copy buffer, if necessary */
  if (!(*detached_parts))
     {
      status = PDUformat_macrolib_copy_bufr(detached_parts);
      _pdm_status("PDUformat_macrolib_copy_bufr", status);
     }

  /* Malloc and initialize row */
  row = (IGRchar *) malloc (sizeof(IGRchar)* (*detached_parts)->row_size);
  memset(row, NULL, sizeof(IGRchar) * (*detached_parts)->row_size);

  /* Write data to buffer to copy */
  sprintf(
          row,
          "\1\1%s\1%s\1%s\1\1%s\1",
          catalog,
          number,
          revision,
          "N"
         );

  _pdm_debug("row = <%s>", row);

  status = MEMwrite(*detached_parts, row);
  _pdm_status("MEMwrite", status);

  if (status == MEM_S_SUCCESS)
     status = PDM_S_SUCCESS;

  if (row)
     free(row);

  return(status);
 }

/*
 * This function updates the attach info in a given obj space. 
 */
IGRint  PDUupdate_attach_info(
                              mod_env,
                              attach_info_bufr
                             )
 struct    GRmd_env         mod_env;                     /* INPUT */
 MEMptr                     attach_info_bufr;            /* INPUT */


 {
  IGRlong           status = PDM_S_SUCCESS;
  IGRchar           **attach_entry;
  IGRchar           **row_data;
  IGRchar           attach_dir[DI_PATH_MAX];
  IGRchar           dir_path[DI_PATH_MAX];
  IGRchar           entry[DI_PATH_MAX];
  IGRint            item_no_col;
  IGRint            cat_no_col;
  IGRchar           part_no[10];
  IGRint            i, j;
  IGRint            entry_count = 0;
  IGRint            exp_count = 0;
  OM_p_CLASSLIST    classlist;
  OMuword           classid;
  struct PDUid      *exp_ids; 


 _pdm_debug("In the PDUupdate_attach_info function", 0);

 /* Construct ATTACH_INFO entry */
 di$give_pathname(
                  osnum = mod_env.md_id.osnum,
                  pathname = attach_dir 
                 );

 strcat(attach_dir, ":ATTACH_INFO");

 /* Extract list of attach info */
 status = di$find (
                   start_dir = attach_dir,
                   regexp = "P*",
                   lines = &attach_entry,
                   ptr = &entry_count,
                   max_level = 1
                  );

 if ( (status == DIR_S_SUCCESS) && (entry_count > 0) )
    {
     _pdm_debug("need to purge old attach information", 0);

     /* Get the class id of text_exp */
     status = om$get_classid(
                             classname = "text_exp",
                             p_classid = &classid
                            );

     /* Malloc classlist */
     classlist = (struct OM_sd_classlist *) malloc (sizeof
                            (struct OM_sd_classlist));

     /* Initialize certain field in classlist */
     classlist->w_count = 1;
     classlist->w_flags = OM_CLST_internal;
     classlist->p_classes = &classid;

     _pdm_debug("class id = %d", classid);

     /* Remove old attach info directory, if it exists */
     for (i = 0; i < entry_count; ++i)
         {
          strcpy(entry, attach_entry[i]);
          strcat(entry, "*");

          /* Extract all expression objects under node */
          status = di$dump (
                            regexp = entry,
                            p_classes = classlist,
                            grids = (DIgrid **) &exp_ids,
                            ptr = &exp_count
                           );
          _pdm_debug("exp count = %d", exp_count);

          if ( (exp_count > 0) && (status == DIR_S_SUCCESS) )
             {
              /* Delete expressions */
              for (j = 0; j < exp_count; ++j)
                  {
                   status = PDUdelete_exp(exp_ids[j], mod_env);
                   _pdm_status("PDUdelete_exp", status);

                   if (status != PDM_S_SUCCESS)
                      {
                       _pdm_debug("PDUdelete_exp failed", 0);
                       break;
                      }

                   /* Remove expression from part directory */
                   status = di$rm_objid(
                                        objid = exp_ids[j].objid,
                                        osnum = exp_ids[j].osnum
                                       );
                   _pdm_status("di$rm_objid",status);
                  } /* end j loop */ 
             }

          else
              {
               _pdm_debug("no expressions found, deleting direcory anyway.", 0);
              }

         /* Delete part directory */
         status = di$rmdir(dirname = attach_entry[i], path = NULL);
         } /* end i for loop */

         /* Remove ATTACH_INFO directory */
         strcat(attach_dir, ":");
         status = di$rmdir(dirname = attach_dir, path = NULL);
     }

 else
     {
      _pdm_debug("no old attach info found to purge", 0);

      /* Remove ATTACH_INFO directory, if it exists */
      strcat(attach_dir, ":");
      _pdm_debug("removing <%s> directory", attach_dir);

      status = di$rmdir(dirname = attach_dir, path = NULL);
      _pdm_status("di$rmdir", status);
     }

 /* Check to see if attach_info_bufr loaded */
 if (attach_info_bufr)
    {
     _pdm_debug("attach_info_bufr is not empty", 0);

     /* Setup buffer */
     MEMbuild_array(attach_info_bufr);
     PDUsetup_buffer(
                     attach_info_bufr,
                     ROW,
                     &row_data
                    );

     /* Extract catalog_no column no */
     PDUget_buffer_col(
                       attach_info_bufr,
                       "n_catalogno",
                       &cat_no_col
                      );

     /* Extract item_no column no */
     PDUget_buffer_col(
                       attach_info_bufr,
                       "n_itemno",
                       &item_no_col
                      );

     /* Create ATTACH_INFO directory */
     di$mkpath(pathname = attach_dir);

     /* Loop thru buffer creating attach info */
     for (i = 0; i < attach_info_bufr->rows; ++i)
         {
          sprintf(part_no, "%s%d", "P", i + 1);

          status = DIstmocpy(
                             dir_path, 
                             "ATTACH_INFO",
                             part_no,
                             "", 
                             NULL, 
                             mod_env.md_id.osnum
                            );
          _pdm_status("DIstmocpy", status);

          /* Create ATTACH_INFO directory */
          status = di$mkpath(pathname = dir_path);
          _pdm_status("di$mkpath", status);

          PDUstrip_dir_entry(dir_path);

          /* Create catalog no */
          PDUcreate_exp(
                        TEXT,
                        dir_path,
                        "catalog_no",
                        row_data[(attach_info_bufr->columns * i)+cat_no_col], 
                        mod_env.md_id.osnum
                       );

          /* Create item no */
          PDUcreate_exp(
                        TEXT,
                        dir_path,
                        "item_no",
                        row_data[(attach_info_bufr->columns * i)+item_no_col],
                        mod_env.md_id.osnum 
                       );

         } /* end of i for loop */
    }

  return(PDM_S_SUCCESS);
 }


/*
 * This function creates the attach information buffer.
 */
IGRint  PDUcreate_attach_info_buffer(attach_info_bufr)
 MEMptr *attach_info_bufr;             /* INPUT */

 {
  IGRchar                     *row = NULL;
  IGRchar                     file_path[DI_PATH_MAX];
  IGRchar                     assy_path[DI_PATH_MAX];
  IGRlong                     status = PDM_S_SUCCESS;
  IGRint                      count = 0;
  FILE                        *pdu_debug_file;
  struct PDUattach_node       *head = NULL;  
  struct  PDUref_node         *head1 = NULL;
  struct GRmd_env             mod_env;
  IGRint                      bufsiz;

  extern struct PDUref_node   *PDU_ref_filenames;


  _pdm_debug("In the PDUcreate_attach_info_buffer function", 0);

  /* Initialize PDU_attach_info is NULL */
  PDU_attach_info = NULL;

  /* Get current module info. */
  gr$get_module_env(sizbuf = &bufsiz, buffer = &mod_env);

  /* Get list of all attached ref. files */
  status = PDUget_all_ref_file_names(&mod_env);
  _pdm_status("PDUget_all_ref_file_names", status);

  if ( (PDU_ref_filenames != NULL) && (PDM_debug_on == 1) )
     {
      /* Open debug file */
      pdu_debug_file = fopen (PDU_DEBUG_FILE, "a");

      fprintf(
              pdu_debug_file,
              "PDU -- list of unique EMS attached files:\n"
             );

      head1 = PDU_ref_filenames;
      while (head1)
            {
             fprintf(pdu_debug_file, "\n");

             fprintf(
                     pdu_debug_file,
                     "PDU -- file name = <%s>\n", head1->filename
                    );

             fprintf(
                     pdu_debug_file,
                     "PDU -- ref. id = <%d>\n", (head1->ref_id).objid
                    );

             fprintf(
                     pdu_debug_file,
                     "PDU -- ref. osnum = <%d>\n", (head1->ref_id).osnum
                    );

             head1 = head1->next;
            }

      fprintf(pdu_debug_file, "\n");

      /* Close debug file */
      fclose(pdu_debug_file);
     }

  /* Load attach info. */
  head1 = PDU_ref_filenames;

  while (head1)
        {
         count = 0;

         /* Get full path to ref. attachment */
         status = di$give_pathname(
                                   osnum = (head1->ref_id).osnum,
                                   pathname = file_path
                                  );
         _pdm_status("di$give_pathname", status);

         strcpy(assy_path, file_path);
         strcat(assy_path, ":ASSEMBLY");

         status = di$ls(regexp = assy_path, ptr = &count);
         _pdm_status("di$ls", status);

         /* Make sure "ASSEMBLY" directory exists */
         if ( (status == DIR_S_SUCCESS) && (count > 0) )
            {
             /* Look for PDU attachments */
             status = PDUappend_attach_list(assy_path);
             _pdm_status("PDUappend_attach_list", status);

             if (status != PDM_S_SUCCESS)
                {
                 _pdm_debug("PDUappend_attach_list failed", 0);

                 /* Free PDU_ref_filenames */
                 if (PDU_ref_filenames)
                    {
                     head1 = PDU_ref_filenames;

                     while (PDU_ref_filenames)
                           {
                            PDU_ref_filenames = PDU_ref_filenames->next;
                            free(head1);
                            head1 = PDU_ref_filenames;
                           }
                    }

                     return(status);       
                }
            }

         /* Process next ref. object */
         head1 = head1->next;

        } /* end while loop */


  if ( (PDU_attach_info) && (PDMdebug_on) )
     {
      /* Open debug file */
      pdu_debug_file = (FILE *) fopen (PDU_DEBUG_FILE, "a");

      fprintf(
              pdu_debug_file,
              "PDU -- list of unique PDU attached file info:\n"
             );

      fprintf(pdu_debug_file, "\n");

      head = PDU_attach_info;
      while (head)
            {
             fprintf(
                     pdu_debug_file,
                     "PDU -- catalog_no = <%s>       item_no = <%s>\n",
                     head->catalog_no,
                     head->item_no
                    );

             head = head->next;
            }

      fprintf(pdu_debug_file, "\n");

      /* Close debug file */
      fclose(pdu_debug_file);
     }

  if (PDU_attach_info == NULL)
     {
      _pdm_debug("no ref files attached were found", 0);

      /* Free PDU_ref_filenames */
      if (PDU_ref_filenames)
         {
          head1 = PDU_ref_filenames;

          while (PDU_ref_filenames)
                {
                 PDU_ref_filenames = PDU_ref_filenames->next;
                 free(head1);
                 head1 = PDU_ref_filenames;
                }
         }

      return(PDM_S_SUCCESS);
     }

  /* Open and format attach info buffer */
  PDMopen_buffer(
                 2,
                 attach_info_bufr
                );

  row = (IGRchar *)malloc(sizeof(IGRchar)*(*attach_info_bufr)->row_size);

  /* Load attach info for attachment files */
  head = PDU_attach_info;
  while (head)
        {
         /* Initialize row */
         memset(row, NULL, (*attach_info_bufr)->row_size);

         /* Construct buffer row */
         sprintf(
                 row,
                 "%s\1%s\1",
                 head->catalog_no,
                 head->item_no
                );

         /* Write buffer to row */ 
         status = MEMwrite(*attach_info_bufr, row);

         /* Process next node */
         head = head->next;

        } /* end while loop */

  if (status == MEM_S_SUCCESS)
     status = PDM_S_SUCCESS;

  /* Free variables */
  if (PDU_attach_info)
     {
      free(PDU_attach_info);
      PDU_attach_info = NULL;
     }

  if (row)
     free(row);

  /* Free PDU_ref_filenames */
  if (PDU_ref_filenames)
     {
      head1 = PDU_ref_filenames;

      while (PDU_ref_filenames)
            {
             PDU_ref_filenames = PDU_ref_filenames->next;
             free(head1);
             head1 = PDU_ref_filenames;
            }
     }

  return(status);
 }


/*
 * This function builds the attach list from the assembly structure.
 */
IGRint  PDUappend_attach_list(
                               mod_env, 
                               attach_list
                             )
  struct GRmd_env           *mod_env;            /* INPUT */
  struct PDUattach_node     **attach_list;       /* OUTPUT */
  {
   IGRlong                    status = PDM_S_SUCCESS;
   IGRchar                    **parts = NULL;
   IGRint                     parts_count = 0;
   IGRchar                    *local_flag = NULL;
   IGRchar                    *catalog_no = NULL;
   IGRchar                    *item_no = NULL;
   IGRchar                    *file_name = NULL;
   IGRshort                   part_found;
   IGRint                     i;
   IGRchar                    assy_path[DI_PATH_MAX];
   struct PDUattach_node *head;
   struct PDUattach_node *tail;
   struct PDUattach_node *temp;

   
   _pdm_debug("In the PDUappend_attach_list function", 0);

   /* Construct path to obj. space file */
   di$give_pathname(
                    osnum = mod_env->md_id.osnum,
                    pathname = assy_path
                   );

   /* Construct path to the assembly structure */
   strcat(assy_path, ":ASSEMBLY");

   /* Find all part instances under specified parts path */
   status = di$find(
                    start_dir = assy_path,
                    regexp = "P*",
                    lines = &parts,
                    ptr = &parts_count,
                    max_level = -1
                   );

   if ( (status == DIR_S_SUCCESS) && (parts_count > 0) )
      {
       for (i = 0; i < parts_count; ++i)
           { 
            /* Strip out last ":" */
            PDUstrip_dir_entry(parts[i]);

            /* Extract value for part "local_flag" attribute */
            status = PDUevaluate_exp(
                                     parts[i],
                                     "local_flag",
                                     &local_flag
                                    );

            if (status != PDM_S_SUCCESS)
               {
                _pdm_debug("SEVERE error: could not evaluate local attr.", 0);
                return(0);
               }

            if ( (strcmp(local_flag, "D") != 0) &&
                 (strcmp(local_flag, "C") != 0) &&
                 (strcmp(local_flag, "S") != 0) )
               {
                _pdm_debug("part <%s> is not local", parts[i]);
                continue;
               }

            /* Extract catalog no */
            status = PDUevaluate_exp(
                                     parts[i],
                                     "catalog_no",
                                     &catalog_no
                                    );

            if (status != PDM_S_SUCCESS)
               {
                _pdm_debug("SEVERE error: could not evaluate catalog_no", 0);
                return(0);
               }

            _pdm_debug("extracted catalog no = <%s>", catalog_no);

            /* Extract item number */
            status = PDUevaluate_exp(
                                     parts[i],
                                     "item_no",
                                     &item_no
                                    );

            if (status != PDM_S_SUCCESS)
               {
                _pdm_debug("SEVERE error: could not evaluate item_no", 0);
                return(0);
               }

            _pdm_debug("extracted item number = <%s>", item_no);

            /* Extract file number */
            status = PDUevaluate_exp(
                                     parts[i],
                                     "file_name",
                                     &file_name
                                    );

            if (status != PDM_S_SUCCESS)
               {
                _pdm_debug("SEVERE error: could not evaluate file_name", 0);
                return(0);
               }

            _pdm_debug("extracted file name = <%s>", file_name);

            /* Check to see if part is already in attach list */
            part_found = FALSE;
            head = *attach_list;
            while (head)
                  {
                   if (
                       (strcmp(head->catalog_no, catalog_no) == 0) &&
                       (strcmp(head->item_no, item_no) == 0)
                      )
                      {
                       _pdm_debug("part <%s> is a duplicate", parts[i]);
                       part_found = TRUE;
                       break;
                      }

                    head = head->next;
                   } /* end while loop */

            if (part_found == FALSE)
               {
                /* Create node with attach info */
                temp = (struct PDUattach_node *)
                       malloc(sizeof(struct PDUattach_node));
    
                /* Initialize temp fields */
                temp->catalog_no = NULL;
                temp->item_no = NULL;
                temp->file_name = NULL;
                temp->next = NULL;

                /* Create attach info node */
                PDUfill_in_string(&(temp->catalog_no), catalog_no);
                PDUfill_in_string(&(temp->item_no), item_no);
                PDUfill_in_string(&(temp->file_name), file_name);

                /* Add node to the end of attach list */
                if (*attach_list)
                   {
                    _pdm_debug("new part will be added to end of list", 0);

                    /* Get to the end of list */
                    tail = *attach_list;
                    while (tail->next)
                          {
                           tail = tail->next;
                          }

                    /* Add part to attach link list */
                    tail->next = temp;
                   }

                else
                   {
                    _pdm_debug("new part will be added to front", 0);

                    /* This is the first node in the list */
                    *attach_list = temp;
                   }
               }

           } /* end for loop */

       /* Free variables */
       if (local_flag)
          free(local_flag);

       if (catalog_no)
          free(catalog_no);

       if (item_no)
          free(item_no);

       if (file_name)
          free(file_name);

       if (parts)
          di$free(lines = parts, count = parts_count);
      }

   else
       {
        _pdm_debug("no part instances were found", 0);
        return(PDM_S_SUCCESS);
       }

   return(status);
  }


/*
 * This function updates the assembly structure of an object space. 
 */
IGRint  PDUupdate_assembly_structure(
                                     mod_env,
                                     invis_os,
                                     assy_struct_bufr
                                    )
  struct GRmd_env           *mod_env;            /* INPUT */
  IGRshort                  invis_os;            /* INPUT */
  MEMptr                    assy_struct_bufr;    /* OUTPUT */
  {
   IGRlong                    status = PDM_S_SUCCESS;
   IGRshort                   free_mod = FALSE;
   IGRint                     bufsiz;
   IGRint                     part_count = 0;
   IGRchar                    assy_path[DI_PATH_MAX];
   struct PDUdisplay_list     *display_list = NULL;
   struct PDUdisplay_list     *head = NULL;


   _pdm_debug("In the PDUupdate_assembly_structure function", 0);

   /* Default module env. to current if mod_env is NULL */
   if (!mod_env)
      {
       mod_env = (struct GRmd_env *) malloc(sizeof(struct GRmd_env));
       bufsiz = sizeof(struct GRmd_env);
       gr$get_module_env(sizbuf = &bufsiz, buffer = mod_env);
       free_mod = TRUE;
      }

   /* Generate saved display list, if any. */
   status = PDUgenerate_display_list(
                                     mod_env,
                                     FALSE,
                                     &display_list
                                    );
   _pdm_status("PDUgenerate_display_list", status);

   if (status != PDM_S_SUCCESS)
      {
       _pdm_debug("PDUgenerate_display_list failed", 0);
       return(0);
      }
    
   /* Construct path to assy. struc. in obj space */
   di$give_pathname(
                    osnum = mod_env->md_id.osnum,
                    pathname = assy_path
                   );

   strcat(assy_path, ":ASSEMBLY");

   status = di$ls(regexp = assy_path, ptr = &part_count);
   _pdm_status("di$ls", status);

   if (((part_count == 0) || (status != DIR_S_SUCCESS) ) && 
        (assy_struct_bufr == NULL))
      {
       _pdm_debug("no parts found in assembly structure", 0);
       return(PDM_S_SUCCESS);
      }
  else if ((part_count == 0) || (status != DIR_S_SUCCESS))
      {
      _pdm_debug("not assembly information on object space", 0);
      }
  else
     {
     /* Remove the old ASSEMBLY structure directory */
     status = PDUremove_assembly(assy_path, mod_env);
     _pdm_status("PDUremove_assembly", status);
     }

   /* Fix for TR#139422592 - bug in 2.2 caused assembly files not to be
      stamped */
   /*if (!(PDUis_PDU_design_file(mod_env)))
     {
     _pdm_debug("File is not stamped", 0);
     return(PDM_S_SUCCESS);
     }*/
   if (assy_struct_bufr == NULL)
     {
     _pdm_debug("File is atomic", 0);
     return(PDM_S_SUCCESS);
     }
   /* Construct updated assy. struct. */
   status = PDUadd_assy_struct_from_buffer(
                                           mod_env,
                                           "",
                                           "",
                                           assy_struct_bufr,
                                           0 
                                          );
   _pdm_debug("PDUadd_assy_struct_from_buffer", status);
  
   if (status != PDM_S_SUCCESS)
      {
       _pdm_debug("PDUadd_assy_struct_from_buffer failed", 0);
       return(0);
      }

   /* Check consitency between obj space and new assy struct. */
   status = PDUcheck_assembly_consistency(
                                          assy_struct_bufr,
                                          mod_env
                                         );
   _pdm_status("PDUcheck_assembly_consistency", status);

   if (status != PDM_S_SUCCESS)
      {
       _pdm_debug("PDUcheck_assembly_consistency failed", 0);
       return(0);
      }

   /* Remove assy. entries that do not have GRparts */
   status = PDUremove_non_existent_parts_from_assy_struct(*mod_env);
   _pdm_status("PDUremove_non_existent_parts_from_assy_struct", status);

   /* Update display info. */
   status = PDUupdate_display_info(
                                   mod_env,
                                   FALSE, 
                                   display_list
                                  );
   _pdm_status("PDUupdate_display_info", status);

   if (status != PDM_S_SUCCESS)
      {
       _pdm_debug("PDUupdate_display_info failed", 0);
       return(0);
      }

   if (!invis_os)
      {
       /* Process updated assembly structure */
       status = PDUprocess_assembly_display(
                                            mod_env,
                                            NULL,
                                            0,
                                            1,
                                            0
                                           );
       _pdm_status("PDUprocess_assembly_display", status);

       if (status != PDM_S_SUCCESS)
          {
           _pdm_debug("PDUprocess_assembly_display failed", 0);
           return(0);
          }
      }

   /* Free variables */
   if (free_mod)
      {
       free(mod_env);
       mod_env = NULL;
      }

   if (display_list)
      {
       head = display_list;

       while (display_list)
             {
              display_list = display_list->next;
              free(head);
              head = display_list;
             }

      } /* end while loop */

   return(PDM_S_SUCCESS);
  }


/*
 * This function generates the saved display info from the assy. struct.
 */
IGRint  PDUgenerate_display_list(
                                 mod_env,
                                 load_refid,
                                 display_list 
                                )
  struct GRmd_env           *mod_env;            /* INPUT */
  IGRshort                  load_refid;          /* INPUT */
  struct PDUdisplay_list    **display_list;      /* OUTPUT */
  {
   IGRlong                    status = PDM_S_SUCCESS;
   IGRshort                   free_mod = FALSE;
   IGRint                     bufsiz;
   IGRint                     part_count = 0;
   IGRchar                    assy_path[DI_PATH_MAX];
   IGRchar                    **parts = NULL;
   IGRchar                    *attached = NULL;
   IGRchar                    *refid = NULL;
   IGRint                     i;
   struct PDUdisplay_list     *tail = NULL;
   struct PDUdisplay_list     *temp = NULL;

   _pdm_debug("In the PDUgenerate_display_list function", 0);
 
   /* Default module env. to current if mod_env is NULL */
   if (!mod_env)
      {
       mod_env = (struct GRmd_env *) malloc(sizeof(struct GRmd_env));
       bufsiz = sizeof(struct GRmd_env);
       gr$get_module_env(sizbuf = &bufsiz, buffer = mod_env);
       free_mod = TRUE;
      }

   /* Construct path to ASSEMBLY directory */
   di$give_pathname(
                    osnum = mod_env->md_id.osnum,
                    pathname = assy_path
                   );

   strcat(assy_path, ":");
   strcat(assy_path, "ASSEMBLY");

   /* Check to see if ASSEMBLY directory exists */
   status = di$ls(regexp = assy_path, ptr = &part_count);
   _pdm_status("di$ls", status);

   if ( (part_count == 0) || (status != DIR_S_SUCCESS) )
      {
       _pdm_debug("no parts found in assembly structure", 0);
       return(PDM_S_SUCCESS);
      }

   /* Extract list of DIrectory objects from given parts path */
   part_count = 0;
   status = di$find (
                     start_dir = assy_path,
                     regexp = "P*",
                     lines = &parts,
                     ptr = &part_count,
                     max_level = -1 
                    );

   if (part_count  > 0)
      {
       for (i = 0; i < part_count; ++i)
           {
            /* Drop last ":" from entry */
            PDUstrip_dir_entry(parts[i]);

            /* Extract value for explicit attachment flag */
            status = PDUevaluate_exp(
                                     parts[i],
                                     "attached",
                                     &attached
                                    );

            if (status != PDM_S_SUCCESS)
               {
                _pdm_debug("could not evaluate attached attr.", 0);
                return(0);
               }

            if (load_refid)
               {
                /* Extract value for ref id */
                status = PDUevaluate_exp(
                                         parts[i],
                                         "refid",
                                         &refid
                                        );

                if (status != PDM_S_SUCCESS)
                   {
                    _pdm_debug("could not evaluate refid attr.", 0);
                    return(0);
                   }
               }

            else
                PDUfill_in_string(&refid, "");

            /* Allocate space for node */
            temp = (struct PDUdisplay_list *)
                           malloc(sizeof(struct PDUdisplay_list));

            /* Initialize temp node */
            strcpy(temp->part_path, parts[i]);
            strcpy(temp->displayed, attached);
            strcpy(temp->ref_id, refid);
            temp->next = NULL;

            /* Load display list */
            if (*display_list)
               {
                /* Get to the end of list */
                tail = *display_list;
                while (tail->next)
                      {
                       tail = tail->next;
                      }

                /* Add part to attach link list */
                tail->next = temp;
               }

            else
                {
                 /* This is the first node in the list */
                 *display_list = temp;
                }

           } /* end for i loop */
      }

   /* Free up variables */
   if (free_mod)
      {
       free(mod_env);
       mod_env = NULL;
      }

   if (parts)
      di$free(lines = parts, count = part_count);

   if (attached)
      free(attached);

   if (refid)
      free(refid);


   return(PDM_S_SUCCESS);
  }


/*
 * This function updates the display info. in the assy. struct. 
 */
IGRint  PDUupdate_display_info(
                               mod_env,
                               update_refid,
                               display_list
                              )
  struct GRmd_env           *mod_env;            /* INPUT */
  IGRshort                  update_refid;        /* INPUT */
  struct PDUdisplay_list    *display_list;       /* INPUT */
  {
   IGRlong                    status = PDM_S_SUCCESS;
   IGRshort                   free_mod = FALSE;
   IGRint                     bufsiz;
   IGRint                     part_count = 0;
   IGRchar                    *entry = NULL;
   IGRchar                    assy_path[DI_PATH_MAX];
   IGRchar                    **parts = NULL;
   IGRint                     i;
   struct PDUdisplay_list     *head = NULL;

   _pdm_debug("In the PDUupdate_display_info function", 0);

   /* Check if display list is empty */
   if (!display_list)
      {
       _pdm_debug("display list is empty", 0);
       return(PDM_S_SUCCESS);
      }

   /* Default module env. to current if mod_env is NULL */
   if (!mod_env)
      {
       mod_env = (struct GRmd_env *) malloc(sizeof(struct GRmd_env));
       bufsiz = sizeof(struct GRmd_env);
       gr$get_module_env(sizbuf = &bufsiz, buffer = mod_env);
       free_mod = TRUE;
      }

   /* Construct path to ASSEMBLY directory */
   di$give_pathname(
                    osnum = mod_env->md_id.osnum,
                    pathname = assy_path
                   );

   strcat(assy_path, ":");
   strcat(assy_path, "ASSEMBLY");

   /* Check to see if ASSEMBLY directory exists */
   status = di$ls(regexp = assy_path, ptr = &part_count);
   _pdm_status("di$ls", status);

   if ( (part_count == 0) || (status != DIR_S_SUCCESS) )
      {
       _pdm_debug("no parts found in assembly structure", 0);
       return(PDM_S_SUCCESS);
      }

   /* Extract list of DIrectory objects from given parts path */
   part_count = 0;
   status = di$find (
                     start_dir = assy_path,
                     regexp = "P*",
                     lines = &parts,
                     ptr = &part_count,
                     max_level = -1
                    );

   if (part_count  > 0)
      {
       /* Update display info. in assembly structure */
       head = display_list;
       while (head)
             {
              for (i = 0; i < part_count; ++i)
                  {
                   /* Drop last ':' from path */
                   PDUfill_in_string(&entry, parts[i]); 
                   PDUstrip_dir_entry(entry);

                   if (strcmp(head->part_path, entry) == 0)
                      {
                       /* Update the part's display in assy struct */
                       PDUmodify_exp(
                                     0,
                                     head->part_path,
                                     "attached",
                                     head->displayed,
                                     mod_env->md_id.osnum
                                    );

                       /* Check to see if need update ref_id */
                       if (update_refid)
                          {
                           PDUmodify_exp(
                                         0,
                                         head->part_path,
                                         "refid",
                                         head->ref_id,
                                         mod_env->md_id.osnum
                                        );
                          }

                       break;
                      }

                  } /* end for i loop */

              /* Process next node */
              head = head->next;

             } /* end while loop */
      }

   /* Free up variables */
   if (entry)
      free(entry);

   if (free_mod)
     {
      free(mod_env);
      mod_env = NULL;
     }

   if ( parts)
      di$free (lines = parts, count = part_count);

   return(PDM_S_SUCCESS);
  }

end implementation COpdu;
