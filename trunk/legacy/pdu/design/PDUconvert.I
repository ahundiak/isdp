class implementation COpdu;
/*
   This file contains functions for converting 1.3.0/1.4.0 PDU object 
   sace to 2.0.0 PDU space. 

   Author: Jamal Shakra 
   Date: 06-12-92
*/

/* Include file section */
#include        "stdio.h"
#include        "PDUstr.h"
#include        "partmacros.h"
#include        "part.h"
#include        "acdef.h"
#include        "acmacros.h"
#include        "ACdb_info.h"
#include        "macro.h"
#include        "grdpbdef.h"
#include        "grdpb.h"
#include        "grdpbmacros.h"
#include        "growner.h"
#include        "grgsmacros.h"
#include        "grmessage.h"
#include        "igrdp.h"
#include        "madef.h"
#include        "exdef.h"
#include        "exmacros.h"
#include        "expriv.h"
#include        "dp.h"
#include        "dpdef.h"
#include        "grcoordsys.h"
#include        "csdef.h"
#include        "msdef.h"
#include        "PDUint.h"
#include        "PDUintdef.h"
#include        "string.h"
#include        "grsymdef.h"
#include        "grsym.h"
#include        "grownerdef.h"
#include        "dpmacros.h"
#include        "comiscmac.h"
#include        "coplcmac.h"
#include        "cotxmacros.h"
#include        "partdef.h"
#include        "DItypedef.h"
#include        "DIdef.h"
#include        "DIglob.h"
#include        "DIprims.h"
#include        "expmacros.h"
#include        "csmacros.h"
#include        "PDUpart.h"
#include        "PDUinform.h"
#include        "PDUfile_def.h"
#include        "PDUconvert.h"
#include        "PDUassy.h"
#include        "PDUnode.h"
#include        "MEMstruct.h"
#include        "MEMerrordef.h" 
#include        "PDUgrpart.h"
#include        "FI.h"
#include        "PDUforms.h"
#include        "PDUform_def.h"
#include	"PDUerror.h"


/* External variables declaration section */
extern struct PDUrefresh *refresh;
extern struct PDUforms forms;
extern short  PDU_dynamics_on;

/* Global variables */

/* Imported messages */
from  GRowner     import       GRadd_components;
from  GRowner     import       GRremove_components;
from  GRowner     import       GRget_components;
from  GRowner     import       GRget_number_components;
from  GRcsmgr     import       GRget_acs_info;
from  GRcsmgr     import       GRset_active_cs;
from  GRgraphics  import       GRdelete;
from  GRreffile   import       GRgetenvironment;
from  GRreffile   import       GRputdescription;
from  GRreffile   import       GRgetdescription;
from  GRreffile   import       GRinquireref;


/*
 * This function converts 1.4 part pointers to 2.0. 
 */

IGRint PDUconvert_part_pointers (mod_env, active, convert_flag)

 struct GRmd_env  mod_env;		/* INPUT */
 IGRshort         active;               /* INPUT */
 IGRshort         *convert_flag;        /* OUTPUT */
{
 IGRlong          msg,sts;
 IGRlong          status;
 IGRshort         cstype;
 GRobjid          csmgr_id;
 struct GRid      act_coorid;
 struct GRid      csobj;
 struct GRid      ref_objid;
 struct GRid      part_id;
 struct GRid      *component_ids;
 IGRint           component_count = 0;
 IGRint           tag_cnt_count = 0;
 IGRchar          tag_dir[DI_PATH_MAX];
 IGRchar          child_dir[DI_PATH_MAX];
 IGRchar          old_parts_dir[DI_PATH_MAX];
 IGRchar          tmp_tag[DI_PATH_MAX];
 IGRchar          tmp_alttag[DI_PATH_MAX];
 IGRchar          tmp_usage_id[DI_PATH_MAX];
 IGRchar          tmp_viewname[DI_PATH_MAX];
 IGRchar          tmp_childno[DI_PATH_MAX];
 IGRchar          tmp_value[DI_PATH_MAX];
 IGRchar          old_dir[DI_PATH_MAX];
 IGRchar          assy_path[DI_PATH_MAX];
 IGRmatrix        placement_matrix;
 struct  GRid     *old_part_ids;
 struct  GRid     *bad_objids;
 IGRint           part_count = 0;
 IGRint           badobj_count = 0;
 IGRint           i, k, m, n, p;
 IGRint           num_objects = 1;
 struct PDUreport report;
 IGRint           count = 0;
 IGRint           tag_count = 0;
 IGRint           childno_count = 0;
 IGRint           max_comp_count = 0;
 IGRint           entry_count = 0;
 IGRint           instance_no;
 IGRint           item_no_col;
 IGRint           cat_no_col;
 IGRint           file_name_col;
 IGRshort         ref_found;
 IGRshort         flag;
 IGRchar          part_label[MAX_VALUE];
 IGRchar          *tag_no = NULL;
 IGRchar          *child_no = NULL;
 IGRchar          *alt_tagno = NULL;
 IGRchar          **attributes;
 IGRchar          **values;
 IGRchar          **old_dyn_names = NULL;
 IGRchar          **old_dyn_values = NULL;
 IGRchar          **old_dyn_types = NULL;
 IGRchar          **row_data;
 IGRint           *attribute_type;
 IGRint           attribute_count = 0;
 IGRint           exp_count;
 IGRint           explode_flag;
 IGRchar          part_date[26];
 IGRchar          serial_no[10];
 IGRchar          attach_value[10];
 IGRchar          s[DI_PATH_MAX];
 IGRchar          *inc_bom = NULL;
 IGRchar          *inc_asm = NULL;
 IGRchar          *explode = NULL;
 IGRint           GRpart_comp_no;
 IGRint           basic_attr_count = 15;
 IGRshort         increment_tag_no = FALSE;
 IGRshort         part_added;
 IGRchar          attr_value[MAX_VALUE];
 IGRchar          *catpartrev = NULL;
 IGRchar          **catpartrevs = NULL;
 IGRchar          **tag_cnt_entry = NULL;
 IGRchar          **exp_names = NULL;
 IGRchar          **part_type_data;
 IGRchar          regexp[MAX_VALUE];
 IGRchar          *tag_cnt_value = NULL;
 IGRchar          *exp_name = NULL;
 IGRchar          *exp_value = NULL;
 IGRchar          *exp_type = NULL;
 IGRchar          *part_type = NULL;
 IGRchar          *file_name = NULL;
 IGRchar          *catalog_no = NULL;
 IGRchar          *item_no = NULL;
 IGRchar          description[DI_PATH_MAX];
 IGRchar          *tmp_ptr;
 IGRchar          *seq_no = NULL;
 char             *msg_str = NULL;
 OM_p_CLASSLIST   classlist;
 OMuword          classid;
 struct PDUnth_ref_objects   *ref_list = NULL;
 struct PDUnth_ref_objects   *head1;
 struct GRobj_env objects[1];
 struct GRobj_env GRpart_objects[2];
 struct PDUold_part_list *old_part_list = NULL;
 struct PDUold_part_list *temp;
 struct PDUold_part_list *head;
 struct PDUold_part_list *tail;
 MEMptr           part_type_buffer = NULL;
 MEMptr           assy_struct_bufr = NULL;
 FILE             *pdu_debug_file;
 
/* BETH  added for debug */
 int			part_not_found = FALSE;

 _pdm_debug("In the PDUconvert_part_pointers function", 0);

 
 /* Need to save the active coordinate system */
 status =  cs$get_mgr (
                       msg = &msg,
                       osnum = mod_env.md_id.osnum,
                       module = mod_env.md_id.objid,
                       csmgr = &csmgr_id
                      );

 /* Get the obj id of the most recently defined coor sys */
 status = om$send(
                  msg = message GRcsmgr.GRget_acs_info
                                                      (
                                                        &msg,
                                                        NULL,
                                                        NULL,
                                                        NULL,
                                                        NULL,
                                                        NULL,
                                                        NULL,
                                                        &cstype,
                                                        &act_coorid
                                                      ),
                  senderid = NULL_OBJID,
                  targetid = csmgr_id,
                  targetos = mod_env.md_id.osnum
                 );

 /* Get the <:filename:PDU:parts> path */
 di$give_pathname(osnum = mod_env.md_id.osnum, pathname = old_parts_dir);
 strcat(old_parts_dir, ":PDU:parts");

 _pdm_debug("full old parts path = <%s>", old_parts_dir);

 /* Check to see if part pointer conversion is necessary */
 status = di$ls(regexp = old_parts_dir, ptr = &count);
 _pdm_status("di$ls", status);

 if ( (status != DIR_S_SUCCESS) || (count == 0) )
    {
     _pdm_debug("part pointer conversion has already been made", 0);
     *convert_flag = 1;
     return(PDM_S_SUCCESS);
    }

 /* Get the class id of GRclhdr */
 status = om$get_classid(
                         classname = "GRclhdr",
                         p_classid = &classid
                        );
 _pdm_debug("GRclhdr class id = %d", classid);

 /* Malloc classlist */
 classlist = (struct OM_sd_classlist *) malloc (sizeof
                        (struct OM_sd_classlist));

 /* Initialize certain field in classlist */
 classlist->w_count = 1;
 classlist->w_flags = OM_CLST_internal;
 classlist->p_classes = &classid;

 /* Construct regexp */
 strcpy(regexp, old_parts_dir);
 strcat(regexp, ":*");

 /* Extract all PDU 1.4 part pointers */
 part_count = 0;
 status = di$dump (
                   regexp = regexp,
                   p_classes = classlist,
                   grids = (DIgrid **)&old_part_ids,
                   ptr = &part_count
                  );

 if (part_count <= 0)
    {
     _pdm_debug("no PDU 1.4 part pointers were found", 0);

     /* Remove old parts directores, if they exist */
     status = di$find (
                       start_dir = old_parts_dir,
                       regexp = "*!*!*",
                       lines = &catpartrevs,
                       max_level = 1,
                       ptr = &entry_count
                      );

     if (entry_count > 0)
        {
         for (i = 0; i < entry_count; ++i)
             {
              /* Extract cat!part!rev string from full path entry */
              *((IGRchar *)strrchr(catpartrevs[i], ':')) = '\0';

              catpartrev = strchr(catpartrevs[i], '!');

              while (catpartrev[0] != ':')
                    catpartrev = catpartrev - 1;

              catpartrev = catpartrev + 1;

              _pdm_debug("catpartrev = <%s>", catpartrev);

              /* Remove part <cat!part!rev> entry */
              status = PDUremove_tree(
                                      mod_env.md_id.osnum,
                                      "",
                                      catpartrev
                                     );
              _pdm_status("PDUremove_tree", status);
             } /* end i for loop */
        }
 
     /* Remove the "converted" directory, if it exists */
     strcpy(old_dir, old_parts_dir);
     strcat(old_dir, ":converted:");
     status = di$rmdir(dirname = old_dir, path = NULL);
     _pdm_status("di$rmdir", status);

     /* Remove "tag_cnt" directory value, if it exists */
     strcpy(old_dir, old_parts_dir);
     strcat(old_dir, ":tag_cnt");

     di$find (
              start_dir = old_dir,
              regexp = "*",
              lines = &tag_cnt_entry,
              max_level = 1,
              ptr = &tag_cnt_count
             );

     if (tag_cnt_count > 0)
        {
         status = PDUextract_dir_value(
                                       tag_cnt_entry[0],
                                       "tag_cnt",
                                       &tag_cnt_value
                                      );

         strcat(old_dir, ":");
         strcat(old_dir, tag_cnt_value);
         strcat(old_dir, ":");

         status = di$rmdir(dirname = old_dir, path = NULL);
         _pdm_status("di$rmdir", status);
        }

     /* Remove the "tag_cnt" directory, if it exists */
     strcpy(old_dir, old_parts_dir);
     strcat(old_dir, ":tag_cnt:");

     status = di$rmdir(dirname = old_dir, path = NULL);
     _pdm_status("di$rmdir", status);

     /* Make sure no other objects exist under "parts" directory */
     status = di$find (
                       start_dir = old_parts_dir,
                       regexp = "*",
                       grids = (DIgrid **)&bad_objids,
                       max_level = 1,
                       ptr = &badobj_count
                      );

     if (badobj_count > 0)
        {
         for (i = 0; i < badobj_count; ++i)
             {
              /* Erase remaining objects */
              dp$display(
                         msg = &sts,
                         oids = &(bad_objids[i]),
                         mode = GRbe
                        );

              /* Delete remaining objects */
              om$send(
                      msg = message GRgraphics.GRdelete(
                                                        &sts,
                                                        &mod_env
                                                        ),
                      senderid = NULL_OBJID,
                      targetid = bad_objids[i].objid,
                      targetos = bad_objids[i].osnum
                     );
              }
        }


     /* Delete parts directory, if it exists */
     strcat(old_parts_dir, ":");
     status = di$rmdir(dirname = old_parts_dir, path = NULL);
     _pdm_status("di$rmdir", status);

     /* Free variables */
     if (catpartrevs)
        di$free(lines = catpartrevs, count = entry_count);

     if (tag_cnt_entry)
        di$free(lines = tag_cnt_entry, count = tag_cnt_count);

     return(PDM_S_SUCCESS);
    }

 _pdm_debug("%d PDU 1.4 part pointer(s) were found", part_count);

 /* Get list of all 1st-level attached ref. file objects */
 status = PDUget_all_reffile_objects(
                                     mod_env.md_id.osnum,
                                     0,
                                     &ref_list
                                    );
 _pdm_status("PDUget_all_reffile_objects", status);

 /* For each old part pointer, perform conversion */
 for (i = 0; i < part_count; ++i)
     {
      /* Extract part pointer info from cell */
      report.type = PDU_REPORT_CONVERT;
      report.data = NULL;
      report.items = PDU_CONVERT_COLS;

      status = PDUget_attr (&(old_part_ids[i]), &report);
      _pdm_status ("PDUget_attr(1st level part info)", status);

      if (1 & status)
         {
          if (PDM_debug_on)
            {
             /* Open debug file */
             pdu_debug_file = (FILE *)fopen (PDU_DEBUG_FILE, "a");

             fprintf(pdu_debug_file,
                               "PDU -- List of 1.4 Part Pointer Info:\n\n");

             for (m = 0; m < PDU_CONVERT_COLS; m = m + 1)
                 {
                  fprintf(pdu_debug_file,
                        "PDU -- report.data[%d] = <%s> \n", m, report.data[m]);
                 }

             fprintf(pdu_debug_file, "\n");

             /* Close debug file */
             fclose(pdu_debug_file);
            }

          PDUstring_to_matrix(report.data[3], placement_matrix);
          status = PDUdump_matrix(placement_matrix);
          _pdm_status("PDUdump_matrix", status);

          /* Get number of part pointer components */
          om$send(
                  msg = message GRowner.GRget_number_components(
                                                                &sts,
                                                                &max_comp_count
                                                               ),
                  senderid = NULL_OBJID,
                  targetid = old_part_ids[i].objid,
                  targetos = old_part_ids[i].osnum
                 );

          _pdm_debug("%d components were found", max_comp_count);


          /* Malloc component_ids */
          component_ids = 
                 (struct GRid *) malloc(sizeof(struct GRid) * max_comp_count);

          /* Get objids of all part pointer components */
          om$send(
                  msg = message GRowner.GRget_components(
                                                         &sts,
                                                         &mod_env,
                                                         component_ids,
                                                         max_comp_count,
                                                         &component_count,
                                                         0,
                                                         max_comp_count - 1 
                                                        ),
                  senderid = NULL_OBJID,
                  targetid = old_part_ids[i].objid,
                  targetos = old_part_ids[i].osnum
                 );

          if (component_count <= 0)
             {
              _pdm_debug("SEVERE error: no part components found", 0);
              return(0);
             }

          ref_found = FALSE;

          /* Exclude ref objects from deletion in old parts */
          head1 = ref_list;
          while ( head1 != NULL && ref_found == FALSE )
              {
               for (k = 0; k < component_count; ++k)
                   {
                    if ( (component_ids[k].objid == head1->obj_id.objid) &&
                         (component_ids[k].osnum == head1->obj_id.osnum) )
                       {
                        /* Store ref. objid for new GRpart construction */
                        ref_objid.objid = head1->obj_id.objid;
                        ref_objid.osnum = head1->obj_id.osnum;
    
                        objects[0].obj_id.objid = head1->obj_id.objid;
                        objects[0].obj_id.osnum = head1->obj_id.osnum;
                        objects[0].mod_env = mod_env;

                        PDUfill_in_string(&seq_no, head1->seq_no);

                        /* Remove ref. object from part cell group */
                        _pdm_debug(
                                   "removing %d ref. file from cell group",
                                   head1->obj_id.objid 
                                  );

                        om$send(
                                msg = message GRowner.GRremove_components
                                                     (
                                                      &sts,
                                                      &mod_env,
                                                      &num_objects,
                                                      objects
                                                     ),
                                senderid = NULL_OBJID,
                                targetid = old_part_ids[i].objid,
                                targetos = old_part_ids[i].osnum
                               );

                        ref_found = TRUE;
                        break;
                       }

                   } /* end k for loop */

                /* Process next record */
                 head1 = head1->next;

              } /* end while loop */

          /* Convert ref_objid to string */
          if (ref_found)
             {
              sprintf(attach_value, "%d", ref_objid.objid);
             }

          else
              {
               strcpy(attach_value, "-1");
              }

          /* Erase PDU 1.4 part pointer text strings */
          dp$display(
                     msg = &sts,
                     oids = &(old_part_ids[i]),
                     mode = GRbe
                    );

          /* Delete PDU 1.4 part pointer text strings */
          om$send(
                  msg = message GRgraphics.GRdelete(
                                                    &sts,
                                                    &mod_env
                                                   ),
                  senderid = NULL_OBJID,
                  targetid = old_part_ids[i].objid,
                  targetos = old_part_ids[i].osnum
                 );

          /* -ABB ONLY- Convert catalog name to lower case */
          convert_tolower(report.data[0], report.data[0]);

          /* Replace all ',' occurences with '.' in part revision. */
          PDUreplace_commas(report.data[2]);

          status = PDUgenerate_instance_number(
                                               report.data[0],
                                               report.data[1],
                                               report.data[2],
                                               &instance_no,
                                               &mod_env
                                              );
          _pdm_debug("instance no = %d", instance_no);

          /* Default usage id if necessary */
          if(strcmp(report.data[7], "...") == 0)
            {
             sprintf(
                     part_label,
                     "%s %s #%d",
                     report.data[1],
                     report.data[2],
                     instance_no
                    );

            }

          else
              {
               /* Make sure usage id is unique */
               if (!PDUis_usage_unique(report.data[7]))
                  {
                   /* Default usage id */
                   sprintf(
                           part_label,
                           "%s %s #%d",
                           report.data[1],
                           report.data[2],
                           instance_no
                          );
                  }

               else
                   {
                    strcpy(part_label, report.data[7]);
                   }
              }

          /* Check to see if part label exceeds 25 characters */
          if (strlen(part_label) > 25)
             {
              /* Use catalog no/part no pairs in the default usage id */
              status = PDMget_catno_partno(
                                           report.data[0],
                                           report.data[1],
                                           report.data[2],
                                           &catalog_no,
                                           &item_no
                                          );
              _pdm_status("PDMget_catno_partno", status);

              if (status != PDM_S_SUCCESS)
                 {
                  _pdm_debug("SEVERE error: PDMget_catno_partno failed", 0);
	          part_not_found = TRUE;

                  /* Display message on the screen */
                  printf(
                         "Part <%s %s %s> was not found in database\n",
                         report.data[0],
                         report.data[1],
                         report.data[2]
                        );

                  continue;
                 }

/* BETH get the instance number again using the catalog no and the item
   no. 7/13/92 */
          status = PDUgenerate_instance_number_cvt(
                                               report.data[0],
					       catalog_no, 
                                               report.data[1],
					       item_no, 
                                               report.data[2],
                                               &instance_no,
                                               &mod_env
                                              );
          _pdm_debug("instance no = %d", instance_no);


              /* Default usage id */
              sprintf(
                      part_label,
                      "%s %s #%d",
                      catalog_no,
                      item_no,
                      instance_no
                     );
             }

          /* Create PDU 2.0 part pointer */
          status = PDUcreate_part_pointer(
                                          placement_matrix,
                                          mod_env,
                                          part_label,
                                          NULL,
                                          &csobj
                                         );
          _pdm_status("PDUcreate_part_pointer", status);

          if (status != PDM_S_SUCCESS)
             { 
              _pdm_debug("PDUcreate_part_pointer failed", 0);

              /* Display a message to user */
              msg_str = (char *)PDUtranslate_message(PDM_E_CONVERSION_FAILED);
              UI_status(msg_str);

              return(status);
             }

          /* csobj. will be used as serial number */
          sprintf(serial_no,"%d", csobj.objid);

          /* Update display of new part pointer */
          if (active)
          dp$display(
                     msg = &sts,
                     oids = &csobj,
                     mode = GRbd
                    );

          /* Get tag number from object space */
          di$give_pathname(
                           osnum = mod_env.md_id.osnum,
                           pathname = tag_dir
                          );

          strcat(tag_dir,":");
          strcat(tag_dir,"PDU");
          strcat(tag_dir,":");
          strcat(tag_dir,"tag_no");

          /* Check to see if tag seed exists */
          status = di$ls(regexp = tag_dir, ptr = &tag_count);

          if (tag_count == 0)
          /* Need to create a tag seed */
             {
              _pdm_debug("tag seed will be created", 0);
              strcat(tag_dir, ":");
              strcat(tag_dir, "1");
              strcat(tag_dir, ":");
              status = di$mkpath(pathname = tag_dir);
             }

          /* Get child number seed from object space */
          di$give_pathname(
                           osnum = mod_env.md_id.osnum,
                           pathname = child_dir
                          );

          strcat(child_dir,":");
          strcat(child_dir,"PDU");
          strcat(child_dir,":");
          strcat(child_dir,"child_no");

          /* Check to see if child number seed exists */
          status = di$ls(regexp = child_dir, ptr = &childno_count);


          if (childno_count == 0)
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
                                           mod_env.md_id.osnum
                                          );
             _pdm_debug("child_no = <%s>", child_no);
            }

          if (instance_no == 1)
          /* This is the first instance, need to generate a unique tag number */
             {
              status = PDUgenerate_tag_no(
                                          &tag_no,
                                          mod_env.md_id.osnum
                                         );

              _pdm_debug("tag_no = <%s>", tag_no);

              /* Set increment tag no flag to TRUE */
              increment_tag_no = TRUE;

              /* Get alt tag no */
              status = PDUget_alttag_no(
                                        &alt_tagno,
                                        mod_env.md_id.osnum,
                                        report.data[0], /* catalog */
                                        report.data[1], /* part id */
                                        report.data[2]  /* revision */
                                       );
              _pdm_status("PDUget_alttag_no", status);
              if (status != PDM_S_SUCCESS)
                 {
                  _pdm_debug("Defaulting alt_tagno to empty string",0);
                  PDUfill_in_string(&alt_tagno, "");
                 }
             }

          else
              {
               /* Other instances exist, get tag_no from any instance */
               status = co$part_get_attr (
                                          msg = &msg,
                                          mod_env = &mod_env,
                                          catalog = report.data[0],
                                          number = report.data[1],
                                          revision = report.data[2],
                                          attr = "tag",
                                          value = attr_value
                                        );

               if (msg != MSSUCC)
                  {
                   _pdm_debug("Part placement failed", 0);

                   /* Display a message to user */
                   msg_str = (char *)PDUtranslate_message(PDM_E_CONVERSION_FAILED);
                   UI_status(msg_str);

                   return(0);
                  }


               /* Unquote tag no */
               PDUunquote(attr_value);
               PDUfill_in_string(&tag_no, attr_value);
  
               /* Get alt. tag number from any instance */
               status = co$part_get_attr (
                                          msg = &msg,
                                          mod_env = &mod_env,
                                          catalog = report.data[0],
                                          number = report.data[1],
                                          revision = report.data[2],
                                          attr = "alt_tag",
                                          value = attr_value
                                        );

               if (msg != MSSUCC)
                  {
                   _pdm_debug("Part placement failed", 0);

                   /* Display a message to user */
                   msg_str = (char *)PDUtranslate_message(PDM_E_CONVERSION_FAILED);
                   UI_status(msg_str);

                   return(0);
                  }

               /* Unquote alt tag no */
               PDUunquote(attr_value);
               PDUfill_in_string(&alt_tagno, attr_value);
              }

          /* Enforce text type on tagno */
          sprintf(tmp_tag,"\"%s\"", tag_no);

          /* Enforce text type on usage id */
          if (strcmp(part_label, "") != 0)
             {
              sprintf(tmp_usage_id,"\"%s\"", part_label);
             }

          else
              {
               strcpy(tmp_usage_id, "");
              }

          /* Enforce text type on view name */
          if (strcmp(report.data[8], "") != 0)
             {
              sprintf(tmp_viewname,"\"%s\"", report.data[8]);
             }

          else
              {
               strcpy(tmp_viewname, "");
              }

          /* Enforce text type on alt_tagno */
          if (strcmp(alt_tagno, "") != 0)
             {
              sprintf(tmp_alttag,"\"%s\"", alt_tagno);
             }

          else
              {
               strcpy(tmp_alttag, "");
              }

          /* Enforce text type on child number */
          sprintf(tmp_childno,"\"%s\"", child_no);

          /* Get include bom value and put it in inc_bom */
          status = PDUget_incbom(
                                 &inc_bom,
                                 mod_env.md_id.osnum,
                                 report.data[0], /* catalog */
                                 report.data[1], /* part id */
                                 report.data[2], /* revision */
                                 report.data[6]  /* serial no */
                                );
          _pdm_status("PDUget_incbom", status);
          if (status != PDM_S_SUCCESS)
             {
              _pdm_debug("Defaulting inc_bom to 'Y'",0);
              PDUfill_in_string(&inc_bom, "Y");
             }

          /* Get include asm structure value and put it in inc_asm */
          status = PDUget_incasm(
                                 &inc_asm,
                                 mod_env.md_id.osnum,
                                 report.data[0], /* catalog */
                                 report.data[1], /* part id */
                                 report.data[2], /* revision */
                                 report.data[6]  /* serial no */
                                );
          _pdm_status("PDUget_incasm", status);
          if (status != PDM_S_SUCCESS)
             {
              _pdm_debug("Defaulting inc_asm to 'Y'",0);
              PDUfill_in_string(&inc_asm, "Y");
             }

          /* Get the explode value and put it in explode */
          status = PDUget_explodebom(
                                     &explode,
                                     mod_env.md_id.osnum,
                                     report.data[0], /* catalog */
                                     report.data[1], /* part id */
                                     report.data[2], /* revision */
                                     report.data[6]  /* serial no */
                                    );
          _pdm_status("PDUget_explodebom", status);
          if (status != PDM_S_SUCCESS)
             {
              _pdm_debug("Defaulting explode to 'Y'",0);
              PDUfill_in_string(&explode, "Y");
             }
         
          /* Check if there are any dynamic attributes */
          di$give_pathname(
                           osnum = mod_env.md_id.osnum,
                           pathname = regexp
                          );

          /* Construct <cat!part!rev> string */
          sprintf(
                  s,
                  "%s!%s!%s",
                  report.data[0],
                  report.data[1],
                  report.data[2]
                 );

          strcat(regexp, ":PDU:parts:");
          strcat(regexp, s);
          strcat(regexp, ":serial:");
          strcat(regexp, report.data[6]);
          strcat(regexp, ":*");

          /* Get the class id of text_exp */
          status = om$get_classid(
                                  classname = "text_exp",
                                  p_classid = &classid
                                 );
          _pdm_debug("text_exp class id = %d", classid);

          /* Malloc classlist */
          classlist = (struct OM_sd_classlist *) malloc (sizeof
                                 (struct OM_sd_classlist));

          /* Initialize certain field in classlist */
          classlist->w_count = 1;
          classlist->w_flags = OM_CLST_internal;
          classlist->p_classes = &classid;
          exp_count = 0;

          status = di$dump(
                           regexp = regexp,
                           p_classes = classlist,
                           lines = &exp_names,
                           ptr = &exp_count
                          );
          _pdm_status ("di$dump", status);

          if (exp_count > 0)
             {
              _pdm_debug("%d dynamic attribute(s) were found", exp_count);

              /* Allocate space for old_dyn_names */
              old_dyn_names = (IGRchar **)malloc(exp_count * sizeof(IGRchar *));
              memset((char *)old_dyn_names, NULL, sizeof(IGRchar *) * exp_count);

              /* Allocate space for old_dyn_values */
              old_dyn_values =(IGRchar **)malloc(exp_count * sizeof(IGRchar *));
              memset((char *)old_dyn_values, NULL, sizeof(IGRchar *) * exp_count);

              /* Allocate space for old_dyn_types */
              old_dyn_types = (IGRchar **)malloc(exp_count * sizeof(IGRchar *));
              memset((char *)old_dyn_types, NULL, sizeof(IGRchar *) * exp_count);

              p = 0;

              for (n = 0; n < exp_count; ++n)
                  {
                   /* Extract dynamic attribute name */
                   exp_name = strrchr(exp_names[n], ':');
                   exp_name = exp_name + 1;

                   if (exp_name[0] != '\0')
                      {
                       tmp_ptr = exp_name;
                       while (tmp_ptr[0] != ' ')
                             ++tmp_ptr;

                       tmp_ptr[0] = '\0';

                       _pdm_debug("old part dyn attr name = <%s>", exp_name);

                       /* Get dyn attr value */
                       *((IGRchar *)strrchr(exp_names[n], ':')) = '\0';

                       status = PDUevaluate_exp(
                                                exp_names[n],
                                                exp_name,
                                                &exp_value
                                               );
                       _pdm_status("PDUevaluate_exp", status);
                       _pdm_debug("old part dyn attr value = <%s>", exp_value);

                       /* Get dyn attr type */
                       status = PDUget_exp_type(
                                                exp_names[n],
                                                exp_name,
                                                &exp_type
                                               );
                       _pdm_status("PDUget_exp_type", status);
                       _pdm_debug("old part dyn type = <%s>", exp_type);
    
                       PDUfill_in_string(&(old_dyn_names[p]), exp_name);
                       PDUfill_in_string(&(old_dyn_values[p]), exp_value);
                       PDUfill_in_string(&(old_dyn_types[p]), exp_type);

                       p = p + 1;
                      }

                  } /* end n for loop */
             }

          else
              {
               _pdm_debug("no dyn attrs found for part <%s>", report.data[1]);
              }

          /* Check to see if part has already been added to old_part_list */
          part_added = FALSE;
          head = old_part_list;
          while (head)
                {
                 if ( (strcmp(head->catalog, report.data[0]) == 0) &&
                      (strcmp(head->number, report.data[1]) == 0) &&
                      (strcmp(head->revision, report.data[2]) == 0) )
                    {
                      part_added = TRUE;

                      PDUfill_in_string(
                                        &part_type,
                                        head->part_type
                                       );
                      
                      break;
                     }

                  head = head->next;
                }

          if (part_added == TRUE)
             {
              /* Check to see if part is non-graphic */
              if ( (strcmp(part_type, "N") == 0) ||
                   (strcmp(part_type, "n") == 0) )
                 {
                  _pdm_debug("converting a non-graphic part", 0);

                  /* Remove coor sys */
                  csobj.osnum = mod_env.md_id.osnum;

                  /* Erase coor sys */
                  dp$display(
                             msg = &sts,
                             oids = &csobj,
                             mode = GRbe
                            );

                  /* Delete coor sys */
                  om$send(
                          msg = message GRgraphics.GRdelete
                                                  (
                                                   &sts,
                                                   &mod_env
                                                  ),
                          senderid = mod_env.md_id.objid,
                          targetid = csobj.objid,
                          targetos = csobj.osnum
                         );

                  /* Create a PDU GRpart */
                  status =  PDUcreate_GRpart (
                                              &mod_env,
                                              report.data[0],
                                              report.data[1],
                                              report.data[2],
                                              report.data[4],
                                              tmp_alttag,
                                              tmp_usage_id,
                                              tmp_viewname,
                                              "",
                                              report.data[5],
                                              part_type,
                                              inc_bom,
                                              inc_asm,
                                              explode,
                                              FALSE,
                                              &part_id
                                             );
                  _pdm_debug("PDUcreate_GRpart", status);

                  if (status != PDM_S_SUCCESS)
                     {
                      _pdm_debug("PDUcreate_GRpart failed", 0);

                      /* Display a message to user */
                      msg_str = (char *)PDUtranslate_message(PDM_E_CONVERSION_FAILED);
                      UI_status(msg_str);

                      return(status);
                     }

                  else
                      {
                       goto cleanup;
                      }
                 }
             }

          if (part_added == FALSE)
             {
              /* Get part type from PDM */
              status = PDMquery_part_type(
                                          report.data[0],
                                          report.data[1],
                                          report.data[2],
                                          &part_type_buffer
                                         );
              _pdm_status("PDMquery_part_type",status);

              if (status == PDM_S_SUCCESS)
                 {
                  status = MEMbuild_array(part_type_buffer);
                  _pdm_status("MEMbuild_array",status);

                  if (status != MEM_S_SUCCESS)
                     {
                      MEMclose(part_type_buffer);
                      return(PDM_E_BUILD_BUFFER_ARRAY);
                     }

                  part_type_data = (char **)part_type_buffer->data_ptr;
                  if (
                      strcmp(part_type_data[(part_type_buffer->columns*0)+0],
                      "") ! = 0
                     )
                     {
                      PDUfill_in_string(
                             &part_type,
                             part_type_data[( part_type_buffer->columns * 0)+0]
                                       );

                      /* Check to see if part is non-graphic */
                      if ( (strcmp(part_type, "N") == 0) ||
                           (strcmp(part_type, "n") == 0) )
                         {
                          _pdm_debug("converting a non-graphic part", 0);

                          /* Remove coor sys */
                          csobj.osnum = mod_env.md_id.osnum;

                          /* Erase coor sys */
                          dp$display(
                                     msg = &sts,
                                     oids = &csobj,
                                     mode = GRbe
                                    );

                          /* Delete coor sys */
                          om$send(
                                  msg = message GRgraphics.GRdelete
                                                          (
                                                           &sts,
                                                           &mod_env
                                                          ),
                                  senderid = mod_env.md_id.objid,
                                  targetid = csobj.objid,
                                  targetos = csobj.osnum
                                 );
  
                          /* Create a PDU GRpart */
                          status =  PDUcreate_GRpart (
                                                      &mod_env,
                                                      report.data[0],
                                                      report.data[1],
                                                      report.data[2],
                                                      report.data[4],
                                                      tmp_alttag,
                                                      tmp_usage_id,
                                                      tmp_viewname,
                                                      "",
                                                      report.data[5],
                                                      part_type,
                                                      inc_bom,
                                                      inc_asm,
                                                      explode,
                                                      FALSE,
                                                      &part_id
                                                     );
                          _pdm_debug("PDUcreate_GRpart", status);

                          if (status != PDM_S_SUCCESS)
                             {
                              _pdm_debug("PDUcreate_GRpart failed", 0);

                              /* Display a message to user */
                              msg_str = (char *)PDUtranslate_message(PDM_E_CONVERSION_FAILED);
                              UI_status(msg_str);

                              return(status);
                             }

                          else
                              {
                               goto cleanup;
                              }
                         }

                     }
                 } 

              else
                 {
                  _pdm_debug("PDMquery_part_type failed", 0);

                  /* Display a message to user */
                  msg_str = (char *)PDUtranslate_message(PDM_E_CONVERSION_FAILED);
                  UI_status(msg_str);

                  return(0);
                 }
             }

          attribute_count = basic_attr_count + exp_count;

          _pdm_debug("attribute count = %d", attribute_count);
    
          attributes = (IGRchar **) malloc(attribute_count*sizeof(char *));
          memset((char *)attributes, NULL, attribute_count*sizeof(char *));

          values = (IGRchar **) malloc(attribute_count*sizeof(char *));
          memset((char *)values, NULL, attribute_count*sizeof(char *));

          attribute_type = (IGRint *) malloc(attribute_count*sizeof(int));
          memset((char *)attribute_type, GR_STATIC_ATTR, attribute_count*sizeof(int));

          /* Get part date */
          PDUget_date(part_date);

          PDUfill_in_string(&attributes[0], "tag");
          PDUfill_in_string(&attributes[1], "serial");
          PDUfill_in_string(&attributes[2], "quantity");
          PDUfill_in_string(&attributes[3], "alt_tag");
          PDUfill_in_string(&attributes[4], "usage_id");
          PDUfill_in_string(&attributes[5], "view_name");
          PDUfill_in_string(&attributes[6], "history");
          PDUfill_in_string(&attributes[7], "date");
          PDUfill_in_string(&attributes[8], "attach_flag");
          PDUfill_in_string(&attributes[9], "child_no");
          PDUfill_in_string(&attributes[10], "incl_BOM");
          PDUfill_in_string(&attributes[11], "incl_asm");
          PDUfill_in_string(&attributes[12], "explode_BOM");
          PDUfill_in_string(&attributes[13], "part_type");
          PDUfill_in_string(&attributes[14], "macro_name");

          PDUfill_in_string(&values[0], tmp_tag);
          PDUfill_in_string(&values[1], serial_no);
          PDUfill_in_string(&values[2], report.data[4]);
          PDUfill_in_string(&values[3], tmp_alttag);
          PDUfill_in_string(&values[4], tmp_usage_id);
          PDUfill_in_string(&values[5], tmp_viewname);
          PDUfill_in_string(&values[6], report.data[5]);
          PDUfill_in_string(&values[7], part_date);
          PDUfill_in_string(&values[8], attach_value);
          PDUfill_in_string(&values[9], tmp_childno);
          PDUfill_in_string(&values[10], inc_bom);
          PDUfill_in_string(&values[11], inc_asm);
          PDUfill_in_string(&values[12], explode);
          PDUfill_in_string(&values[13], part_type); 
          PDUfill_in_string(&values[14], "");

          attribute_type[0] = GR_STATIC_ATTR;
          attribute_type[1] = GR_DYNAMIC_ATTR;
          attribute_type[2] = GR_DYNAMIC_ATTR;
          attribute_type[3] = GR_STATIC_ATTR;
          attribute_type[4] = GR_DYNAMIC_ATTR;
          attribute_type[5] = GR_DYNAMIC_ATTR;
          attribute_type[6] = GR_DYNAMIC_ATTR;
          attribute_type[7] = GR_DYNAMIC_ATTR;
          attribute_type[8] = GR_DYNAMIC_ATTR;
          attribute_type[9] = GR_DYNAMIC_ATTR;
          attribute_type[10] = GR_DYNAMIC_ATTR;
          attribute_type[11] = GR_DYNAMIC_ATTR;
          attribute_type[12] = GR_DYNAMIC_ATTR;
          attribute_type[13] = GR_STATIC_ATTR;
          attribute_type[14] = GR_STATIC_ATTR;

          /* Load dyn attrs, if any. */
          for (m = 0; m < exp_count; m = m + 1)
             {
              /* Load dynamic attributes names */
              PDUfill_in_string(
                                &attributes[m + basic_attr_count],
                                old_dyn_names[m] 
                               );

              /* Check dyn attr type */
              if (strcmp(old_dyn_types[m], "TEXT") == 0)
                 {
                  _pdm_debug("attr <%s> is of type TEXT", old_dyn_names[m]);

                  /* Need to quote attr value */
                  sprintf(tmp_value, "\"%s\"", old_dyn_values[m]);
                 } 

              else
                  strcpy(tmp_value, old_dyn_values[m]);

              /* Load dynamic attributes values */
              PDUfill_in_string(
                                &values[m + basic_attr_count],
                                tmp_value 
                               );
             } /* end for m loop */

          if (PDM_debug_on)
            {
             /* Open debug file */
             pdu_debug_file = (FILE *)fopen (PDU_DEBUG_FILE, "a");

             for (m = 0; m < attribute_count; m = m + 1)
                 {
                  fprintf(pdu_debug_file,
                          "PDU -- attributes[%d] = <%s> \n", m, attributes[m]);
                  fprintf(pdu_debug_file,
                          "PDU -- values[%d] = <%s> \n", m, values[m]);
                  fprintf(pdu_debug_file,
                    "PDU -- attribute_type[%d] = <%d>\n", m,attribute_type[m]);
                 }
        
             /* Close debug file */
             fclose(pdu_debug_file);
            }

          /* Add coor sys to GRpart */
          GRpart_comp_no = 1;
          GRpart_objects[0].obj_id.objid = csobj.objid;
          GRpart_objects[0].obj_id.osnum = csobj.osnum;
          GRpart_objects[0].mod_env = mod_env;

          /* Add ref file obj, if any, to GRpart */
          if (ref_found)
             {
              GRpart_objects[1].obj_id.objid = ref_objid.objid;
              GRpart_objects[1].obj_id.osnum = ref_objid.osnum;
              GRpart_objects[1].mod_env = mod_env;
 
              GRpart_comp_no = 2;
             }


          /* Construct the part attribute system */
          status = co$part_construct (
                                      msg = &msg,
                                      mod_env = &mod_env,
                                      catalog = report.data[0],
                                      number = report.data[1],
                                      revision = report.data[2],
                                      description = "",
                                      part = &part_id,
                                      attr = attributes,
                                      value = values,
                                      type = attribute_type,
                                      num = attribute_count,
                                      object = GRpart_objects,
                                      num_objects = GRpart_comp_no 
                                     );

          if (msg == MSSUCC)
            {
cleanup:
             /* Need to increment tag no seed, if necessary */
             if (increment_tag_no == TRUE)
                {
                 PDUincrement_tag_no(mod_env.md_id.osnum);
                 increment_tag_no = FALSE;
                }

             /* Get part assembly structure */
             if (strcmp(explode, "Y") == 0)
                {
                 explode_flag = MAX_LEVEL;
                }

             else
                  {
                   explode_flag = -1;
                  }

             status = PDMget_assembly_structure(
                                                report.data[0],
                                                report.data[1],
                                                report.data[2],
                                                explode_flag,
                                                &assy_struct_bufr
                                               );
             _pdm_status("PDMget_assembly_structure", status);

             if (status != PDM_S_SUCCESS)
                {
                 /* Display a message */
                }

             
             if (assy_struct_bufr == NULL)
                {
                 _pdm_debug("SEVERE error: assy_struct_bufr is empty", 0);
            
                 /* Erase part pointer */
                 dp$display(
                            msg = &sts,
                            oids = &part_id,
                            mode = GRbe
                           );
                 
                 /* Erase part again */
                 dp$display(
                            msg = &sts,
                            oids = &part_id,
                            mode = GRbe
                           );
                 
                 /* Roll back and delete GRpart */
                 om$send(
                          msg = message GRgraphics.GRdelete(
                                                         &sts,
                                                         &mod_env
                                                           ),
                          senderid = NULL_OBJID,
                          targetid = part_id.objid,
                          targetos = part_id.osnum
                         );
                 
                 /* Display message to user */
                 _pdm_debug("Part Pointer Conversion Failed", 0);
                 return(0);
                }

             MEMbuild_array(assy_struct_bufr);
             PDUsetup_buffer(
                             assy_struct_bufr,
                             ROW,
                             &row_data
                            );

             /* Extract catalog no column no */
             PDUget_buffer_col(
                               assy_struct_bufr,
                               "n_ccatalogno",
                               &cat_no_col
                              );
             
             /* Extract item no column no */
             PDUget_buffer_col(
                               assy_struct_bufr,
                               "n_citemno",
                               &item_no_col
                              );
             
             /* Extract file name column no */
             PDUget_buffer_col(
                               assy_struct_bufr,
                               "n_cofilename",
                               &file_name_col
                              );
             
             /* Extract catalog no from buffer */
             PDUfill_in_string(&catalog_no, row_data[cat_no_col]);
             
             /* Extract item no from buffer */
             PDUfill_in_string(&item_no, row_data[item_no_col]);
             
             /* Extract file name from buffer */
             PDUfill_in_string(&file_name, row_data[file_name_col]);
             
             if ( (ref_found) && (strcmp(seq_no, "0") == 0) )
                {
                 /* Construct new ref. description */
                 sprintf(
                         description,
                         "PDU:%s:%s:%s", 
                         catalog_no,
                         item_no,
                         file_name
                        );

                 _pdm_debug("new ref. file description = <%s>", description);

                 /* Modify ref. file description */
                 flag = 0;
                 status = om$send(
                                  msg = message GRreffile.GRputdescription
                                            (&msg, &flag, description),
                                  senderid = NULL_OBJID,
                                  targetos = ref_objid.osnum,
                                  targetid = ref_objid.objid 
                                 );
                 _pdm_status2 ("GRreffile.GRputdescription", status, msg);
                }

             if (assy_struct_bufr->rows > 0)
                {
                 /*status = PDUadd_assy_struct_from_buffer(
                                                         &mod_env,
                                                         child_no,
                                                         file_name,
                                                         assy_struct_bufr,
                                                         1
                                                        );

                 _pdm_status("PDUadd_assy_struct_from_buffer", status);*/
                }

             if (strcmp(explode, "Y") != 0)
                {
                 /* Change explode attr to 'N' */
                 status = co$part_put_attr (
                                            msg = &msg,
                                            mod_env = &mod_env,
                                            part = &part_id,
                                            attr = "explode_BOM",
                                            value = "N",
                                            type = GR_DYNAMIC_ATTR
                                           );
                }

             /* Update attached attr to 'Y', if attached */
             if (ref_found)
                {
                 di$give_pathname(
                                  osnum = mod_env.md_id.osnum,
                                  pathname = assy_path 
                                 );

                 strcat(assy_path, ":ASSEMBLY:P");
                 strcat(assy_path, child_no);
                 _pdm_debug("part assy. path = <%s>", assy_path);

                 PDUmodify_exp(
                               0,
                               assy_path,
                               "attached",
                               "Y",
                               mod_env.md_id.osnum
                              );
                }

             /* Need to increment child number seed */
             PDUincrement_child_no(mod_env.md_id.osnum);
             _pdm_debug("current child_no = <%s>", child_no);

             /* Add part, if not found in old_part_list */
             if (part_added == FALSE)
                {
                 /* Create a node with old part info */
                 temp = (struct PDUold_part_list *)
                                      malloc(sizeof(struct PDUold_part_list));

                 /* Initialize temp fields */
                 temp->catalog = NULL;
                 temp->number = NULL;
                 temp->revision = NULL;
                 temp->part_type = NULL;
                 temp->next = NULL;

                 PDUfill_in_string(&(temp->catalog), report.data[0]);
                 PDUfill_in_string(&(temp->number), report.data[1]);
                 PDUfill_in_string(&(temp->revision), report.data[2]);
                 PDUfill_in_string(&(temp->part_type), part_type);

                 /* Add node to the end of list */
                 if (old_part_list)
                    {
                     /* Get to the end of list */
                     tail = old_part_list;
                     while (tail->next)
                           {
                            tail = tail->next;
                           }

                     /* Add part to list */
                     tail->next = temp;
                    }

                 else
                    {
                     /* This is the first node in the list */
                     old_part_list = temp;
                    }
                }

             /* Free variables */
             PDUfree_string_array(&values, attribute_count);
    
             /* Free attributes */
             PDUfree_string_array(&attributes, attribute_count);

             if ( report.data )
                {
                 PDUfree_list(report.data, report.items, 1);
                 free (report.data);
                }
            }
         }

      else
          {
           _pdm_debug("PDUget_attr failed", 0);
           
           _pdm_debug("Part Pointer Conversion Failed", 0);

           /* Display a message to user */
           msg_str = (char *)PDUtranslate_message(PDM_E_CONVERSION_FAILED);
           UI_status(msg_str);

           return(0);
          }

     } /* end i for loop */

 /* Remove old parts directores, if they exist */
 status = di$find (
                   start_dir = old_parts_dir,
                   regexp = "*!*!*",
                   lines = &catpartrevs,
                   max_level = 1,
                   ptr = &entry_count
                  );

 if (entry_count > 0)
    {
     for (i = 0; i < entry_count; i = i + 1)
         {
          /* Extract cat!part!rev string from full path entry */
          *((IGRchar *)strrchr(catpartrevs[i], ':')) = '\0';

          catpartrev = strchr(catpartrevs[i], '!');

          while (catpartrev[0] != ':')
                catpartrev = catpartrev - 1; 

          catpartrev = catpartrev + 1;

          _pdm_debug("catpartrev = <%s>", catpartrev);

          /* Remove part <cat!part!rev> entry */
          status = PDUremove_tree(
                                  mod_env.md_id.osnum,
                                  "",
                                  catpartrev
                                 );
          _pdm_status("PDUremove_tree", status);
         } /* end i for loop */
    }

 /* Remove the "converted" directory, if it exists */
 strcpy(old_dir, old_parts_dir);
 strcat(old_dir, ":converted:");
 status = di$rmdir(dirname = old_dir, path = NULL);
 _pdm_status("di$rmdir", status);

 /* Remove "tag_cnt" directory value, if it exists */
 strcpy(old_dir, old_parts_dir);
 strcat(old_dir, ":tag_cnt");

 di$find (
          start_dir = old_dir,
          regexp = "*",
          lines = &tag_cnt_entry,
          max_level = 1,
          ptr = &tag_cnt_count
         );

 if (tag_cnt_count > 0)
    {
     status = PDUextract_dir_value(
                                   tag_cnt_entry[0],
                                   "tag_cnt",
                                   &tag_cnt_value
                                  );

     strcat(old_dir, ":");
     strcat(old_dir, tag_cnt_value);
     strcat(old_dir, ":");

     status = di$rmdir(dirname = old_dir, path = NULL);
     _pdm_status("di$rmdir", status);
    }

 /* Remove the "tag_cnt" directory, if it exists */
 strcpy(old_dir, old_parts_dir);
 strcat(old_dir, ":tag_cnt:");
 status = di$rmdir(dirname = old_dir, path = NULL);
 _pdm_status("di$rmdir", status);

 /* Make sure no other objects exist under "parts" directory */
 status = di$find (
                   start_dir = old_parts_dir,
                   regexp = "*",
                   grids = (DIgrid **)&bad_objids,
                   max_level = 1,
                   ptr = &badobj_count
                  );

 if (badobj_count > 0)
    {
     for (i = 0; i < badobj_count; i = i + 1)
         {
          /* Erase remaining objects */
          dp$display(
                     msg = &sts,
                     oids = &(bad_objids[i]),
                     mode = GRbe
                    );

          /* Delete remaining objects */
          om$send(
                  msg = message GRgraphics.GRdelete(
                                                    &sts,
                                                    &mod_env
                                                    ),
                  senderid = NULL_OBJID,
                  targetid = bad_objids[i].objid,
                  targetos = bad_objids[i].osnum
                 );
          }
    }

 /* Delete old parts directory */
 strcat(old_parts_dir, ":");
 status = di$rmdir(dirname = old_parts_dir, path = NULL);
 _pdm_status("di$rmdir", status);

 if (active)
    {
     /* Restore active coordinate system */
     status = om$send(
                      msg = message GRcsmgr.GRset_active_cs
                                           (
                                            &msg,
                                            &mod_env,
                                            act_coorid.objid
                                           ),
                      senderid = NULL_OBJID,
                      targetid = csmgr_id,
                      targetos = mod_env.md_id.osnum
                     );
    }

 /* Free variables */
 _pdm_debug("freeing variables", 0);

 if (catpartrevs)
    di$free(lines = catpartrevs, count = entry_count);

 if (tag_cnt_entry)
    di$free(lines = tag_cnt_entry, count = tag_cnt_count);

 if (exp_names)
    di$free(lines = exp_names, count = exp_count);

 if (old_part_list)
    free(old_part_list);

 if (ref_list)
    {
     head1 = ref_list;

     while (ref_list)
           {
            ref_list = ref_list->next;
            free(head1);
            head1 = ref_list;
           }
    }

 if (old_dyn_names)
    PDUfree_string_array(&old_dyn_names, exp_count);

 if (old_dyn_types)
    PDUfree_string_array(&old_dyn_types, exp_count);

 if (old_dyn_values)
    PDUfree_string_array(&old_dyn_values, exp_count);

 if (tag_cnt_value)
    free(tag_cnt_value);

 if (tag_no)
    free(tag_no);

 if (alt_tagno)
    free(alt_tagno);

 if (child_no)
    free(child_no);

 if (inc_bom)
    free(inc_bom);

 if (inc_asm)
    free(inc_asm);

 if (explode)
    free(explode);

 if (exp_value)
    free(exp_value);

 if (exp_type)
    free(exp_type);

 if (part_type)
    free(part_type);

 if (file_name)
    free(file_name);

 if (catalog_no)
    free(catalog_no);

 if (item_no)
    free(item_no);

 if (seq_no)
    free(seq_no);

 if (part_type_buffer)
    MEMclose(&part_type_buffer);

 if (part_not_found)
    return(PDM_E_PART_NOT_FOUND);

 return(PDM_S_SUCCESS);
}

IGRint PDUconvert_part_origins (mod_env, active, convert_flag)

 struct GRmd_env  mod_env;              /* INPUT */
 IGRshort         active;               /* INPUT */
 IGRshort         *convert_flag;        /* OUTPUT */
{
 IGRdouble        origin[3];
 IGRlong          msg, sts;
 IGRlong          status;
 IGRshort         cstype;
 GRobjid          csmgr_id;
 struct GRid      act_coorid;
 struct GRid      csobj;
 IGRchar          regexp[DI_PATH_MAX];
 IGRchar          origins_dir[DI_PATH_MAX];
 IGRchar          view_dir[DI_PATH_MAX];
 IGRmatrix        placement_matrix, sv_rotation;
 struct  GRid     *origin_ids;
 struct  GRid     *bad_objids;
 IGRchar          **origins = NULL;
 IGRint           count = 0;
 IGRint           origin_count = 0;
 IGRint           badobj_count = 0;
 IGRint           i;
 IGRchar          *view_name;
 GRobjid          sv_objid;
 IGRpoint         sv_origin;
 IGRlong          error_var, n;
 IGRdouble        scales[3];
 IGRdouble        angle;
 OM_p_CLASSLIST   classlist;
 OMuword          classid;
 struct var_list  var_list[3];
 char              *msg_str = NULL;


 _pdm_debug("In the PDUconvert_part_origins function", 0);

 /* Need to save the active coordinate system */
 status =  cs$get_mgr (
                       msg = &msg,
                       osnum = mod_env.md_id.osnum,
                       module = mod_env.md_id.objid,
                       csmgr = &csmgr_id
                      );


 /* Get the obj id of the most recently defined coor sys */
 status = om$send(
                  msg = message GRcsmgr.GRget_acs_info
                                                      (
                                                        &msg,
                                                        NULL,
                                                        NULL,
                                                        NULL,
                                                        NULL,
                                                        NULL,
                                                        NULL,
                                                        &cstype,
                                                        &act_coorid
                                                      ),
                  senderid = NULL_OBJID,
                  targetid = csmgr_id,
                  targetos = mod_env.md_id.osnum
                 );

 /* Get the <:filename:PDU:origins> path */
 di$give_pathname(osnum = mod_env.md_id.osnum, pathname = origins_dir);
 strcat(origins_dir, ":PDU:origins");

 _pdm_debug("full origins path = <%s>", origins_dir);

 /* Check to see if origin conversion is necessary */ 
 status = di$ls(regexp = origins_dir, ptr = &count);
 _pdm_status("di$ls", status);

 if ( (status != DIR_S_SUCCESS) || (count == 0) )
    {
     _pdm_debug("origin conversion has already been made", 0);
     *convert_flag = 1;
     return(PDM_S_SUCCESS);
    }

 /* Get the class id of GRclhdr */
 status = om$get_classid(
                         classname = "GRclhdr",
                         p_classid = &classid
                        );
 _pdm_debug("GRclhdr class id = %d", classid);

 /* Malloc classlist */
 classlist = (struct OM_sd_classlist *) malloc (sizeof
                        (struct OM_sd_classlist));

 /* Initialize certain field in classlist */
 classlist->w_count = 1;
 classlist->w_flags = OM_CLST_internal;
 classlist->p_classes = &classid;

 /* Construct regexp */
 strcpy(regexp, origins_dir);
 strcat(regexp, ":*");

 _pdm_debug("regexp = <%s>", regexp);

 /* Extract all PDU 1.4 origin objects */
 origin_count = 0;
 status = di$dump (
                   regexp = regexp,
                   p_classes = classlist,
                   lines = &origins,
                   grids = (DIgrid **)&origin_ids,
                   ptr = &origin_count
                  );

 if (origin_count <= 0)
    {
     _pdm_debug("no PDU 1.4 origins were found", 0);

     /* Make sure no other objects exist under "origins" directory */
     status = di$find (
                       start_dir = origins_dir,
                       regexp = "*",
                       grids = (DIgrid **)&bad_objids,
                       max_level = 1,
                       ptr = &badobj_count
                      );

     if (badobj_count > 0)
        {
         for (i = 0; i < badobj_count; ++i)
             {
              /* Erase remaining objects */
              dp$display(
                         msg = &sts,
                         oids = &(bad_objids[i]),
                         mode = GRbe
                        );

              /* Delete remaining objects */
              om$send(
                      msg = message GRgraphics.GRdelete(
                                                        &sts,
                                                        &mod_env
                                                        ),
                      senderid = NULL_OBJID,
                      targetid = bad_objids[i].objid,
                      targetos = bad_objids[i].osnum
                     );
              }
        }


     /* Delete origins directory, if it exists */
     strcat(origins_dir, ":");
     status = di$rmdir(dirname = origins_dir, path = NULL);
     _pdm_status("di$rmdir", status);

     return(PDM_S_SUCCESS);
    }

 _pdm_debug("%d PDU 1.4 origin(s) were found", origin_count);

 /* For each origin, perform conversion */
 for (i = 0; i < origin_count; ++i)
     {
      /* Each origins entry need to be reduced to view name only */
      *((IGRchar *)strrchr(origins[i], '*')) = '\0';

      view_name = strrchr(origins[i], ':') + 1;

      /* Extract objid of saved view corresponding to view_name */
      di$give_pathname(
                       osnum = mod_env.md_id.osnum,
                       pathname = view_dir
                      );

      strcat(view_dir,":views:savedviews:GRsavedviews");

      di$translate(
                   objname = view_name,
                   path = view_dir,
                   p_objid = &(sv_objid)
                  );

      _pdm_debug("translated saved view objid = %d", sv_objid);

      /* Extarct saved view rotation matrix, and origin point */
      var_list[0].var = VIEW_ORIGIN;
      var_list[0].var_ptr = (IGRchar *)sv_origin;
      var_list[0].num_bytes = sizeof (IGRpoint);
      var_list[0].bytes_returned = &n;
      var_list[1].var = VIEW_ROTATION;
      var_list[1].var_ptr = (IGRchar *)sv_rotation;
      var_list[1].num_bytes = sizeof(IGRdouble)*16;
      var_list[1].bytes_returned = &n;
      var_list[2].var = (IGRint)END_PARAM;

      status = dp$inq_set_saved_view (
                                      msg = &msg,
                                      osnum = mod_env.md_id.osnum,
                                      vw_objid = sv_objid,
                                      which_error = &error_var,
                                      var_list = var_list
                                     );
      _pdm_status("dp$inq_set_saved_view", status);

      _pdm_debug("sv_origin[0] = %lf", sv_origin[0]);
      _pdm_debug("sv_origin[1] = %lf", sv_origin[1]);
      _pdm_debug("sv_origin[2] = %lf", sv_origin[2]);

      _pdm_debug("saved view rotation matrix:", 0);
      PDUdump_matrix(sv_rotation);

      /* Construct new origin placement matrix */
      scales[0] = 1.000000;
      scales[1] = 1.000000;
      scales[2] = 1.000000;

      angle = 0.000000;

      GRsmplmat(
                &msg,
                &angle,
                scales,
                sv_origin,
                sv_rotation,
                placement_matrix
               );
  
      _pdm_debug("new origin placement matrix:", 0);
      PDUdump_matrix(placement_matrix);

      /* Erase PDU 1.4 origin */
      dp$display(
                 msg = &sts,
                 oids = &(origin_ids[i]),
                 mode = GRbe
                );

      /* Delete 1.4 origin */
      om$send(
              msg = message GRgraphics.GRdelete(
                                                &sts,
                                                &mod_env
                                               ),
              senderid = NULL_OBJID,
              targetid = origin_ids[i].objid,
              targetos = origin_ids[i].osnum
             );

      /* Create PDU 2.0 origin */
      origin[0] = 0.0;
      origin[1] = 0.0;
      origin[2] = 0.0;

      status = PDUcreate_origin(
                                placement_matrix,
                                mod_env,
                                view_name,
                                NULL,
                                origin,
                                0,
                                &csobj
                               );
      _pdm_status("PDUcreate_origin", status);

      if (status != PDM_S_SUCCESS)
         {
          _pdm_debug("PDUcreate_origin failed", 0);

          /* Display a message to user */
          msg_str = (char *)PDUtranslate_message(PDM_E_CONVERSION_FAILED);
          UI_status(msg_str);
          
          return(status);
         }

      /* Update display */
      dp$display(
                 msg = &sts,
                 oids = &csobj,
                 mode = GRbd
                );

     } /* end for i loop */

 /* Make sure no other objects exist under "origins" directory */
 status = di$find (
                   start_dir = origins_dir,
                   regexp = "*",
                   grids = (DIgrid **)&bad_objids,
                   max_level = 1,
                   ptr = &badobj_count
                  );

 if (badobj_count > 0)
    {
     for (i = 0; i < badobj_count; ++i)
         {
          /* Erase remaining objects */
          dp$display(
                     msg = &sts,
                     oids = &(bad_objids[i]),
                     mode = GRbe
                    );

          /* Delete remaining objects */
          om$send(
                  msg = message GRgraphics.GRdelete(
                                                    &sts,
                                                    &mod_env
                                                    ),
                  senderid = NULL_OBJID,
                  targetid = bad_objids[i].objid,
                  targetos = bad_objids[i].osnum
                 );
          }
    }

 /* Delete origins directory */
 strcat(origins_dir, ":");
 status = di$rmdir(dirname = origins_dir, path = NULL);
 _pdm_status("di$rmdir", status);

 if (active)
    {
     /* Restore active coordinate system */
     status = om$send(
                      msg = message GRcsmgr.GRset_active_cs
                                           (
                                            &msg,
                                            &mod_env,
                                            act_coorid.objid
                                           ),
                      senderid = NULL_OBJID,
                      targetid = csmgr_id,
                      targetos = mod_env.md_id.osnum
                     );
    }

 /* Free variables */
 _pdm_debug("Free variables", 0);
 if (origins)
    di$free(lines = origins, count = origin_count);

 return(PDM_S_SUCCESS);
}


/*
 * This function provides support for 1.4 BOM attachments conversion.
 */
IGRint  PDUprocess_BOM_attachments(mod_env, attach_info_bufr)
 struct GRmd_env  mod_env;                  /* INPUT */
 MEMptr           *attach_info_bufr;        /* INPUT,OUTPUT */
{
 IGRlong                     status = PDM_S_SUCCESS;
 IGRlong                     msg;
 IGRshort                    flag = 0;
 IGRint                      ref_count = 0;
 IGRchar                     *cat_no = NULL;
 IGRchar                     *item_no = NULL;
 IGRchar                     *catalog = NULL;
 IGRchar                     *number = NULL;
 IGRchar                     *revision = NULL;
 IGRchar                     *tmp_ptr;
 IGRchar                     *row1 = NULL;
 IGRchar                     *row2 = NULL;
 IGRchar                     ref_file_name[DI_PATH_MAX];
 IGRchar                     description[DI_PATH_MAX];
 IGRchar                     ref_descr[DI_PATH_MAX];
 char                        *msg_str = NULL;
 MEMptr                      BOM_files = NULL;
 MEMptr                      status_buffer = NULL;
 struct PDUnth_ref_objects   *ref_list = NULL;
 struct PDUnth_ref_objects   *head;

 _pdm_debug("In the PDUprocess_BOM_attachments function", 0);

 /* Get list of all attached ref. file objects including nth-level */
 status = PDUget_all_reffile_objects(
                                     mod_env.md_id.osnum,
                                     1,
                                     &ref_list
                                    );
 _pdm_status("PDUget_all_reffile_objects", status);

 head = ref_list;
 while (head)
       {
        ++ref_count;
        head = head->next;
       }

 _pdm_debug("%d ref. file objects were found", ref_count);

 if (ref_count > 0)
    {
     /* Need to format BOM buffer first */
     PDMopen_buffer(
                    7,
                    &BOM_files
                   );

     /* Check to see if attach_info_bufr buffer needs to be formatted */
     if ( !(*attach_info_bufr) )
        {
         PDMopen_buffer(
                        2,
                        attach_info_bufr 
                       );
        }

     if (*attach_info_bufr) 
         {
          /* Allocate space for row2 */
          row2 = (IGRchar *)
                 malloc(sizeof(IGRchar) * (*attach_info_bufr)->row_size);
         }

     /* Allocate space for row1 */
     row1 = (IGRchar *) malloc(sizeof(IGRchar) * BOM_files->row_size);

     head = ref_list;

     while (head)
           {
            if (strcmp(head->seq_no, "BOM") == 0)
               {
                _pdm_debug("encountered a BOM attachment", 0);

                /* Extract ref. file description */
                flag = 0;
                status = om$send(
                                 msg = message GRreffile.GRgetdescription
                                     ( &msg, &flag, ref_descr ),
                                 senderid = NULL_OBJID,
                                 targetos = head->obj_id.osnum,
                                 targetid = head->obj_id.objid
                                );
                _pdm_status2 ("GRreffile.GRgetdescription", status, msg);
                _pdm_debug ("reffile description = <%s>", ref_descr );

                if (1&status)
                   {
                    /* Extract cat_no and item_no from ref. description */
                    *((IGRchar *)strrchr(ref_descr, ':')) = '\0';

                    tmp_ptr = strrchr(ref_descr, ':');
                    ++tmp_ptr;
                    PDUfill_in_string(&item_no, tmp_ptr);
                    *((IGRchar *)strrchr(ref_descr, ':')) = '\0';
                    tmp_ptr = strrchr(ref_descr, ':');
                    ++tmp_ptr;
                    PDUfill_in_string(&cat_no, tmp_ptr);

                    /* Initialize row1 */
                    memset(row1, NULL, BOM_files->row_size);

                    /* Construct a buffer row1 */
                    sprintf(
                            row1,
                            "%s\1%s\1\1\1\1\1LOAD\1",
                            cat_no,
                            item_no
                           );

                    /* Write row1 to buffer */
                    status = MEMwrite(BOM_files, row1);

                    if (status != MEM_S_SUCCESS)
                       {
                        _pdm_debug("MEMwrite failed", 0);

                        /* Display a message to user */
                        msg_str = (char *)PDUtranslate_message(PDM_E_CONVERSION_FAILED);
                        UI_status(msg_str);

                        return(status);
                       }

                    /* Initialize row2 */
                    memset(row2, NULL, (*attach_info_bufr)->row_size);

                    /* Construct a buffer row2 */
                    sprintf(
                            row2,
                            "%s\1%s\1",
                            cat_no,
                            item_no
                           ); 

                    /* Write row2 to buffer */
                    status = MEMwrite(*attach_info_bufr, row2);

                    if (status != MEM_S_SUCCESS)
                       {
                        _pdm_debug("MEMwrite failed", 0);

                        /* Display a message to user */
                        msg_str = (char *)PDUtranslate_message(PDM_E_CONVERSION_FAILED);
                        UI_status(msg_str);

                        return(status);
                       }
                   }

                /* Process next ref. file */
                head = head->next;

                continue;
               }

            if ( (strcmp(head->seq_no, "PDU") != 0) &&
                 (strcmp(head->seq_no, "0") != 0) )
                 {
                  _pdm_debug("encountered a BOM attachment", 0);

                  /* Extract ref. file description */
                  flag = 0;
                  status = om$send(
                                   msg = message GRreffile.GRgetdescription
                                       ( &msg, &flag, ref_descr ),
                                   senderid = NULL_OBJID,
                                   targetos = head->obj_id.osnum,
                                   targetid = head->obj_id.objid
                                  );
                  _pdm_status2 ("GRreffile.GRgetdescription", status, msg);
                  _pdm_debug ("reffile description = <%s>", ref_descr );

                  if (1&status)
                     {
                      /* Extract catalog/part/revision from ref. description */
                      *((IGRchar *)strrchr(ref_descr, ':')) = '\0';

                      tmp_ptr = strrchr(ref_descr, ':');
                      ++tmp_ptr;
                      PDUfill_in_string(&revision, tmp_ptr);
                      *((IGRchar *)strrchr(ref_descr, ':')) = '\0';
                      tmp_ptr = strrchr(ref_descr, ':');
                      ++tmp_ptr;
                      PDUfill_in_string(&number, tmp_ptr);
                      *((IGRchar *)strrchr(ref_descr, ':')) = '\0';
                      tmp_ptr = strrchr(ref_descr, ':');
                      ++tmp_ptr;
                      PDUfill_in_string(&catalog, tmp_ptr);

                      /* -ABB ONLY- Convert catalog name to lower case */
                      convert_tolower(catalog, catalog);

                      /* Get cat_no and item_no pair */
                      status = PDMget_catno_partno(
                                                   catalog,
                                                   number,
                                                   revision,
                                                   &cat_no,
                                                   &item_no
                                                  );
                      _pdm_status("PDMget_catno_partno", status);

                      if (status == PDM_S_SUCCESS)
                         {
                          /* Initialize row1 */
                          memset(row1, NULL, BOM_files->row_size);

                          /* Construct a buffer row1 */
                          sprintf(
                                  row1,
                                  "%s\1%s\1\1\1\1\1LOAD\1",
                                  cat_no,
                                  item_no
                                 );

                          /* Write row1 to buffer */
                          status = MEMwrite(BOM_files, row1);

                          if (status != MEM_S_SUCCESS)
                             {
                              _pdm_debug("MEMwrite failed", 0);

                              /* Display a message to user */
                              msg_str = (char *)PDUtranslate_message(PDM_E_CONVERSION_FAILED);
                              UI_status(msg_str);

                              return(status);
                             }

                          /* Initialize row2 */
                          memset(row2, NULL, (*attach_info_bufr)->row_size);

                          /* Construct a buffer row2 */
                          sprintf(
                                  row2,
                                  "%s\1%s\1",
                                  cat_no,
                                  item_no
                                 );

                          /* Write row2 to buffer */
                          status = MEMwrite(*attach_info_bufr, row2);

                          if (status != MEM_S_SUCCESS)
                             {
                              _pdm_debug("MEMwrite failed", 0);

                              /* Display a message to user */
                              msg_str = (char *)PDUtranslate_message(PDM_E_CONVERSION_FAILED);
                              UI_status(msg_str);

                              return(status);
                             }

                          /* Get ref. file name */
                          status = PDUget_ref_file_name(
                                                        head->obj_id,
                                                        mod_env,
                                                        ref_file_name
                                                       );
                          _pdm_status("PDUget_ref_file_name", status);

                          if (status != PDM_S_SUCCESS)
                             {
                              _pdm_debug("PDUget_ref_file_name failed", 0);
                        
                              /* Display a message to user */
                              msg_str = (char *)PDUtranslate_message(PDM_E_CONVERSION_FAILED);
                              UI_status(msg_str);

                              return(status);
                             }

                          /* Construct new ref. description */
                          sprintf(
                                  description,
                                  "BOM:%s:%s:%s",
                                  cat_no,
                                  item_no,
                                  ref_file_name
                                 );

                          _pdm_debug("new ref. file description = <%s>",
                                     description);

                          /* Modify ref. file description */
                          flag = 0;
                          status = om$send(
                                       msg = message GRreffile.GRputdescription
                                                (&msg, &flag, description),
                                       senderid = NULL_OBJID,
                                       targetos = head->obj_id.osnum,
                                       targetid = head->obj_id.objid
                                          );
                          _pdm_status2 ("GRreffile.GRputdescription",
                                        status, msg);
                         }

                      else
                          {
                           _pdm_debug("PDMget_catno_partno failed", 0);

                           /* Display a message to user */
                           msg_str = (char *)PDUtranslate_message(PDM_E_CONVERSION_FAILED);
                           UI_status(msg_str);

                           return(status);
                          }
                     }
                 }

            /* Process next ref. file */
            head = head->next;

           } /* end while loop */ 

     if ( (BOM_files) && (BOM_files->rows > 0) )
        {
        /* Copy BOM attachment files locally */
        status = PDMcopy_attach(
                                BOM_files,
                                &status_buffer
                               );
        _pdm_status("PDMcopy_attach", status);

        if (status != PDM_S_SUCCESS)
           {
            _pdm_debug("PDMcopy_attach failed", 0);

            /* Display a message to user */
            msg_str = (char *)PDUtranslate_message(PDM_E_CONVERSION_FAILED);
            UI_status(msg_str);

            return(status);
           }
       }
    }

 else
     {
      _pdm_debug("No ref. files found", 0);
      return(PDM_S_SUCCESS);
     }

 /* Free variables */
 if (cat_no)
    free(cat_no);

 if (item_no)
    free(item_no);

 if (catalog)
    free(catalog);
  
 if (number)
    free(number);

 if (revision)
    free(revision);

 if (row1)
    free(row1);

 if (row2)
    free(row2);

 if (ref_list) 
    free(ref_list);

 if (BOM_files)
    MEMclose(&BOM_files);

 if ( (*attach_info_bufr)->rows <= 0 )
    {
     MEMclose(attach_info_bufr);
     *attach_info_bufr = NULL;
    }

 if (status_buffer)
    MEMclose(&status_buffer);

 return(PDM_S_SUCCESS);
}

/*
 * This function adds BOM attachments info to PDU_attach_info link list.
 */
IGRint  PDUadd_BOM_attachments_to_linklist()
{
 IGRlong  status = PDM_S_SUCCESS;
 IGRlong  msg;
 IGRshort flag = 0;
 IGRchar  ref_descr[DI_PATH_MAX];
 IGRchar  *cat_no = NULL;
 IGRchar  *item_no = NULL;
 IGRchar  *tmp_ptr;
 IGRshort part_found; 
 IGRlong  NumberOfBytes, BytesReceived;
 struct GRmd_env  mod_env;
 struct PDUattach_node *head1 = NULL;
 struct PDUattach_node *tail = NULL;
 struct PDUattach_node *temp = NULL;
 struct PDUnth_ref_objects   *ref_list = NULL;
 struct PDUnth_ref_objects   *head = NULL;
 extern  struct   PDUattach_node  *PDU_attach_info;


 _pdm_debug("In the PDUadd_BOM_attachments_to_linklist function", 0);

 /* Get active module information */
 NumberOfBytes = sizeof(mod_env);
 status = gr$get_module_env(
                            msg = &msg,
                            sizbuf = &NumberOfBytes,
                            buffer = &mod_env,
                            nret = &BytesReceived
                           );

 /* Get 1st-level ref. file objects from active space */
 status = PDUget_all_reffile_objects(
                                     mod_env.md_id.osnum,
                                     0,
                                     &ref_list
                                    );
 _pdm_status("PDUget_all_reffile_objects", status);

 if (ref_list)
    {
     /* Add BOM attachments info to PDU_attach_info list */
     head = ref_list;
     while (head)
           {
            if (strcmp(head->seq_no, "BOM") == 0)
               {
                /* Extract ref. file description */
                flag = 0;
                status = om$send(
                                 msg = message GRreffile.GRgetdescription
                                     ( &msg, &flag, ref_descr ),
                                 senderid = NULL_OBJID,
                                 targetos = head->obj_id.osnum,
                                 targetid = head->obj_id.objid
                                );
                _pdm_status2 ("GRreffile.GRgetdescription", status, msg);
                _pdm_debug ("reffile description = <%s>", ref_descr );

                if (1&status)
                   {
                    /* Extract cat_no and item_no from ref. description */
                    *((IGRchar *)strrchr(ref_descr, ':')) = '\0';

                    tmp_ptr = strrchr(ref_descr, ':');
                    ++tmp_ptr;
                    PDUfill_in_string(&item_no, tmp_ptr);
                    *((IGRchar *)strrchr(ref_descr, ':')) = '\0';
                    tmp_ptr = strrchr(ref_descr, ':');
                    ++tmp_ptr;
                    PDUfill_in_string(&cat_no, tmp_ptr);
 
                    /* Check to see if part is already in attach list */
                    part_found = FALSE;
                    head1 = PDU_attach_info;
                    while (head1)
                          {
                           if (
                               (strcmp(head1->catalog_no, cat_no) == 0) &&
                               (strcmp(head1->item_no, item_no) == 0)
                              )
                              {
                               part_found = TRUE;
                               break;
                              }

                            head1 = head1->next;
                           } /* end inner while loop */

                    if (part_found == FALSE)
                       {
                        /* Create node with attach info */
                        temp = (struct PDUattach_node *)
                               malloc(sizeof(struct PDUattach_node));

                        /* Initialize temp fields */
                        temp->catalog_no = NULL;
                        temp->item_no = NULL;
                        temp->next = NULL;

                        /* Create attach info node */
                        PDUfill_in_string(&(temp->catalog_no), cat_no);
                        PDUfill_in_string(&(temp->item_no), item_no);

                        /* Add node to the end of PDU_attach_info */
                        if (PDU_attach_info)
                           {
                            _pdm_debug("new part will be added to end of list",
                                       0);

                            /* Get to the end of list */
                            tail = PDU_attach_info;
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
                            PDU_attach_info = temp;
                           }
                       }
                   }
               }
           
            /* Process next ref. file */
            head = head->next;

           } /* end outer while loop */
    }

 /* Free variables */
 if (cat_no)
    free(cat_no);

 if (item_no)
    free(item_no);

 if (ref_list)
    free(ref_list);

 return(PDM_S_SUCCESS);
}

/* Function to replace all commas in a string with periods */
IGRint PDUreplace_commas(string)
 IGRchar *string;
 {
  IGRint   status = PDM_S_SUCCESS;
  IGRchar  *ptr;

  /* Replace comma occurences with periods in string */
  while (ptr = strrchr(string, ','))
         *ptr = '.';
  
  return(status);
 }

/*
 * Function to convert 1.3-1.4 object spaces to 2.0.
 */
IGRint PDUcvt_20objspace()
 {
 IGRlong          status, sts, msg;
 struct GRmd_env  mod_env;
 struct GRmd_env  ref_mod_env;
 IGRchar          file_path[DI_PATH_MAX];
 IGRchar          attr_value[MAX_VALUE];
 IGRchar          serial[MAX_VALUE];
 IGRint           ref_count = 0;
 IGRint           type;
 IGRint           count = 0;
 IGRshort         convert_flag1;
 IGRshort         convert_flag2;
 IGRlong          NumberOfBytes, BytesReceived;
 char             *msg_str = NULL;
 struct PDUnth_ref_objects   *ref_list = NULL; 
 struct PDUnth_ref_objects   *head = NULL; 
 struct PDUpart_node         *head1 = NULL;
 struct PDUpart_node         *part_ids = NULL;
 IGRchar           user_msg[200];
 IGRchar           **attributes = NULL;
 IGRchar           **values = NULL;
 IGRint            *attribute_type;
 IGRint            attribute_count;
 struct GRid       part_id;
 int dynflag = 2;
 int nret;
 int sizbuf;
 IGRchar          filename[DI_PATH_MAX];


 _pdm_debug("In the PDUcvt_20objspace function", 0);

 strcpy(user_msg, "Severe error encountered while performing PDU object space conversion. Please 'Exit Without Save' and open a worksheet with PDU/PDM support.");

 /* Get active module information */
 NumberOfBytes = sizeof(mod_env);
 status = gr$get_module_env(
                            msg = &sts,
                            sizbuf = &NumberOfBytes,
                            buffer = &mod_env,
                            nret = &BytesReceived
                           );
 di$give_pathname(
                  osnum = mod_env.md_id.osnum,
                  pathname = filename
                 );

_pdm_debug("checking for dynamics", 0);
 status = gr$get_dynamics_on(msg = &sts, sizbuf = &sizbuf, buffer = &dynflag,
                    nret = &nret);
 _pdm_status("gr$get_dynamics_on", status);
 _pdm_debug("dynflag (before PDUget_all_GRpart_ids) = <%d>", dynflag);
 if (dynflag)
   PDU_dynamics_on = TRUE;
 else
   PDU_dynamics_on = FALSE;

 /* Delete coor sys frm non-graphic parts 2.2 change */
 status = PDUget_all_GRpart_ids(
                                mod_env.md_id.osnum,
                                &part_ids,
                                &count
                               );
 _pdm_status("PDUget_all_GRpart_ids", status);

 head1 = part_ids;

 while (head1)
       {
        /* Extract GRpart part_type */
        co$part_get_attr (
                          msg = &msg,
                          mod_env = &mod_env,
                          part = &(head1->part_id),
                          attr = "part_type",
                          value = attr_value,
                          type = &type
                         );

        /* Extract GRpart serial attribute */
        co$part_get_attr (
                          msg = &msg,
                          mod_env = &mod_env,
                          part = &(head1->part_id),
                          attr = "serial",
                          value = serial,
                          type = &type
                         );

        if ( ((strcmp(attr_value, "N") == 0) ||
              (strcmp(attr_value, "n") == 0)) &&
             (strcmp(serial, "-1.000000") != 0) && 
             (strcmp(serial, "-2.000000") != 0) )
             {
              /* Get GRpart attrs of part */
              status  = PDUget_GRpart_all_attrs(
                                                mod_env,
                                                NULL,
                                                NULL,
                                                NULL,
                                                &attributes,
                                                &values,
                                                &attribute_type,
                                                &attribute_count,
                                                &(head1->part_id),
                                                0
                                               );
              _pdm_status("PDUget_GRpart_all_attrs", status);

              if (status != PDM_S_SUCCESS)
                 {
                  _pdm_debug("PDUget_GRpart_all_attrs failed", 0);

                  /* Display a message to user */
                  msg_str = (char *)PDUtranslate_message(PDM_E_NGRAPH_CONVERSION_FAILED);
                  UI_status(msg_str);
                  UI_error(user_msg);

                  return(status);
                 }

              /* Dlete the old GRpart */
              om$send(
                      msg = message GRgraphics.GRdelete (&msg, &mod_env),
                      senderid = NULL_OBJID,
                      targetid = (head1->part_id).objid,
                      targetos = (head1->part_id).osnum 
                     );

              /* Skip uniqueness attributes */
              attributes = attributes + 4;
              values = values + 4;
              attribute_type = attribute_type + 4;
              attribute_count = attribute_count - 4;

              /* Construct the new part attribute system */
              status = co$part_construct (
                                          msg = &msg,
                                          mod_env = &mod_env,
                                          catalog = *(values - 4),
                                          number = *(values - 2),
                                          revision = *(values - 3),
                                          description = *(values - 1),
                                          part = &part_id,
                                          attr = attributes,
                                          value = values,
                                          type = attribute_type,
                                          num = attribute_count
                                         );
              _pdm_status("co$part_construct", msg);

              if (msg != MSSUCC)
                 {
                  _pdm_debug("co$part_construct failed", 0);

                  /* Display a message to user */
                  msg_str = (char *)PDUtranslate_message(PDM_E_NGRAPH_CONVERSION_FAILED);
                  UI_status(msg_str);
                  UI_error(user_msg);

                  return(status);          
                 }
              
              /* Set serial to '-1' */
              co$part_put_attr (
                                msg = &msg,
                                mod_env = &mod_env,
                                part = &part_id,
                                attr = "serial",
                                value = "-1",
                                type = GR_DYNAMIC_ATTR
                               );
             }

        head1 = head1->next;

       } /* end while loop */

 /* Free attributes, and values */
 if (attributes)
    PDUfree_string_array(&attributes, attribute_count);

 if (values)
    PDUfree_string_array(&values, attribute_count);

 /* Free part_ids */
 if (part_ids)
    {
     head1 = part_ids;

     while (part_ids)
           {
            part_ids = part_ids->next;
            free(head1);
            head1 = part_ids;
           }
    }
 

 /* Get the <:filename> path */
 di$give_pathname(osnum = mod_env.md_id.osnum, pathname = file_path);

 _pdm_debug("Converting <%s>", file_path);

 convert_flag1 = 0;
 convert_flag2 = 0;


 /* Convert active obj. space origins */
 status = PDUconvert_part_origins(mod_env, 1, &convert_flag1);
 _pdm_status("PDUconvert_part_origins", status);

 if (status != PDM_S_SUCCESS)
    {
     _pdm_debug("PDUconvert_part_origins failed", 0);

     /* Display a message to user */
     msg_str = (char *)PDUtranslate_message(PDM_E_CONVERSION_FAILED);
     UI_status(msg_str);

     UI_error(user_msg);

     return(status);
    }


 /* Convert active obj. space part pointers */
 status = PDUconvert_part_pointers(mod_env, 1, &convert_flag2);
 _pdm_status("PDUconvert_part_pointers", status);

 if (status != PDM_S_SUCCESS)
    {
     _pdm_debug("PDUconvert_part_pointers failed", 0);

     /* Display a message to user */
     msg_str = (char *)PDUtranslate_message(PDM_E_CONVERSION_FAILED);
     UI_status(msg_str);

     UI_error(user_msg);

     return(status);
    }

 if ( (convert_flag1 == 1) && (convert_flag2 == 1) )
    {
     _pdm_debug("<%s> has already been converted", file_path);
    }


 /* Get list of all attached ref. file objects including nth-level */
 status = PDUget_all_reffile_objects(
                                     mod_env.md_id.osnum,
                                     1,
                                     &ref_list
                                    );
 _pdm_status("PDUget_all_reffile_objects", status);

 head = ref_list;
 while (head)
       {
        ref_count = ref_count + 1;
        head = head->next;
       }

 _pdm_debug("%d ref. file objects were found", ref_count);

 /* Perform conversion on each ref. file */
 head = ref_list;
 while (head)
       {
        /* Get ref. file module environment */
         status = om$send(
                         msg = message GRreffile.GRgetenvironment
                                       (&msg, &mod_env, &ref_mod_env),
                         senderid = NULL_OBJID,
                         targetos = head->obj_id.osnum,
                         targetid = head->obj_id.objid
                        );
         _pdm_status2 ("GRreffile.GRgetenvironment", status, msg);

         if (1&status && msg == MSSUCC)
            {
             /* Get the <:filename> path */
             di$give_pathname(
                              osnum = ref_mod_env.md_id.osnum,
                              pathname = file_path
                             );
             _pdm_debug("converting ref. file <%s>", file_path);

             convert_flag1 = 0;
             convert_flag2 = 0;

             /* Convert ref. obj. space origins */
             status = PDUconvert_part_origins(ref_mod_env, 1, &convert_flag1);
             _pdm_status("PDUconvert_part_origins", status);

             if (status != PDM_S_SUCCESS)
                {
                 _pdm_debug(
                            "PDUconvert_part_origins failed on osnum %d", 
                            ref_mod_env.md_id.osnum
                           );

                 /* Display a message to user */
                 msg_str = (char *)PDUtranslate_message(PDM_E_CONVERSION_FAILED);
                 UI_status(msg_str);

                 UI_error(user_msg);

                 return(status);
                }

             /* Convert ref. obj. space part pointers */
             status = PDUconvert_part_pointers(ref_mod_env, 1, &convert_flag2);
             _pdm_status("PDUconvert_part_pointers", status);

             if (status != PDM_S_SUCCESS)
                {
                 _pdm_debug(
                            "PDUconvert_part_pointers failed on osnum %d",
                       	    ref_mod_env.md_id.osnum
                           );

                 /* Display a message to user */
                 msg_str = (char *)PDUtranslate_message(PDM_E_CONVERSION_FAILED);
                 UI_status(msg_str);

                 UI_error(user_msg);
 
                 return(status);
                }

                if ( (convert_flag1 == 1) && (convert_flag2 == 1) )
                   {
                    _pdm_debug("<%s> has already been converted", file_path);
                   }

            }

         else
             {
              _pdm_debug("GRreffile.GRgetenvironment failed", 0);

              /* Process next ref. file */
              head = head->next;
              continue;
             }

        /* Process next ref. file */
        head = head->next;

       } /* end while loop */

 /* Free variables */
 if (ref_list)
    {
     head = ref_list;

     while (ref_list)
           {
            ref_list = ref_list->next;
            free(head);
            head = ref_list;
           }
    }

  return(PDM_S_SUCCESS);
 }

IGRint PDUconvert_file_for_similar_mode(file_list, file_count)
 IGRchar          **file_list;
 IGRint           file_count;
{
 IGRint           index = 0;
 GRobjid          osid = NULL_OBJID;
 OMuword          osnum;
 GRobjid          objid;
 char             part_path[DI_PATH_MAX];
 IGRchar          *local_flag = NULL;
 struct GRmd_env  mod_env;
 IGRint           child_col = 0;
 IGRint           file_col = 0;
 IGRint           save_flag = 1;
 IGRchar          **data_row;
 IGRchar          *child_no = NULL;
 MEMptr           assy_bufr = NULL;
 IGRchar          **parts = NULL;
 IGRchar          mount_name[40];
 IGRint           msg;
 IGRint           part_count = 0;
 IGRint           i = 0;
 IGRshort         major;
 IGRshort         minor;
 IGRchar          mach_type;
 IGRint           file_type;
 IGRlong          status = PDM_S_SUCCESS;
 IGRchar          *mess = NULL;
 char             old_origins_dir[DI_PATH_MAX];
 char             old_parts_dir[DI_PATH_MAX];
 IGRshort         cvt_file = FALSE;
 IGRint           count = 0;
 IGRlong          NumberOfBytes, BytesReceived;


 _pdm_debug("in the function PDUconvert_file_for_similar_mode", 0);

 _pdm_debug("find om files", 0);

  NumberOfBytes = sizeof(mod_env);
  status = gr$get_module_env(
                             msg = &msg,
                             sizbuf = &NumberOfBytes,
                             buffer = &mod_env,
                             nret = &BytesReceived
                            );

 if (file_count > 0)
  {
  for (i = 0; i < file_count; ++i)
     {
     _pdm_debug("number of files = <%d>", (char *)file_count);
     _pdm_debug("checking file <%s>", file_list[i]);
     status = ex$is_om_file(
                            filename = file_list[i],
                            p_major = &major,
                            p_minor = &minor,
                            p_mach_type = &mach_type,
                            p_file_type = &file_type
                           );
     _pdm_status("ex$is_om_file", status);

     if (status)
       {
       _pdm_debug("file <%s> is an OM file", file_list[i]);
       }
     else
       {
       _pdm_debug("file <%s> is NOT an OM file", file_list[i]);
       status = PDM_S_SUCCESS;
       continue;
       }

     _pdm_debug("Construct file mount name", 0);
     strcpy(mount_name, ":");
     strcat(mount_name, file_list[i]);
   
     _pdm_debug("mount_name = <%s>", mount_name);

     _pdm_debug("Get osnum of invis space", 0);
     status = ex$retrieve_module (
                                  filename = file_list[i],
                                  file_no = &index,
                                  ftype = EX_invisible,
                                  flag = EX_read_write,
                                  fstat = EX_default,
                                  type = EX_ACTINV,
                                  mount_name = mount_name,
                                  msg = &msg
                                 );
     _pdm_status ("ex$retrieve_module", status);
   
     if (!status)
        {
         _pdm_debug("ex$retrieve_module failed on <%s>", file_list[i]);
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
         _pdm_debug("ex$get_invis_info_by_index failed on <%s>", file_list[i]);
         return(PDM_E_OPEN_FILE);
        }
   
     mod_env.md_id.osnum = osnum;
     mod_env.md_id.objid = objid;
   
     /* JBP: Convert file if necessary */
     cvt_file = FALSE;
     di$give_pathname(
                      osnum = osnum,
                      pathname = old_origins_dir
                      );
     strcat(old_origins_dir, ":PDU:origins");
     status = di$ls(regexp = old_origins_dir, ptr = &count);
     _pdm_status("di$ls", status);
     if ((status == DIR_S_SUCCESS) || (count > 0))
       cvt_file = TRUE;
     di$give_pathname(
                     osnum = osnum,
                     pathname = old_parts_dir
                     );
     strcat(old_parts_dir, ":PDU:parts");
     status = di$ls(regexp = old_parts_dir, ptr = &count);
     _pdm_status("di$ls", status);
     if ((status == DIR_S_SUCCESS) || (count > 0))
       cvt_file = TRUE;

     if (cvt_file)
       {
       status = PDUcvt_20objspace_for_checkout(mod_env);
       _pdm_status("PDUcvt_20objspace_for_checkout", status);
       /* stamp design file because 1.4 files did not have stamps */
       status = PDUstamp_PDU_design_file(mod_env);
       _pdm_status("PDUstamp_PDU_design_file", status);
       /* update db is not required here because we force checkin during
          similar  mode */
       status = ex$close_module (
                                 index = index,
                                 flag = save_flag | EX_ACTINV,
                                 ftype = EX_invisible
                                );
       status = PDM_S_SUCCESS;
       continue;
       }

/*  MJG:  Older PDU design files do not have a stamp 12/23/94
     if (!(PDUis_PDU_design_file(&mod_env)))
       {
       _pdm_debug("file <%s> is not a design file", file_list[i]);
       status = ex$close_module (
                                 index = index,
                                 flag = save_flag | EX_ACTINV,
                                 ftype = EX_invisible
                                );
       status = PDM_S_SUCCESS;
       continue;
       }
*/

     /* Construct path to <filename>:PDU_DESIGN_FILE directory */
     _pdm_debug("calling di$give_pathname", 0);
     di$give_pathname(
                      osnum = osnum,
                      pathname = part_path
                     );
   
     strcat(part_path, ":ASSEMBLY");
   
     _pdm_debug("Extract list of DIrectory objects from given assembly path", 0);
     _pdm_debug("part_path = <%s>", part_path);
     status = di$find (
                       start_dir = part_path,
                       regexp = "P*",
                       lines = &parts,
                       ptr = &part_count,
                       max_level = -1
                      );
     _pdm_status ("di$find", status);

     if (status != DIR_S_SUCCESS)
       {
       _pdm_debug("part is not an assembly", 0);
       _pdm_debug("Close and save object space", 0);
       status = ex$close_module (
                                 index = index,
                                 flag = save_flag | EX_ACTINV,
                                 ftype = EX_invisible
                                );
       _pdm_status ("ex$close_module", status);
       status = PDM_S_SUCCESS;
       continue;
       }

     if (parts)
       _pdm_debug("parts[0] = <%s>", parts[0]);
     else
        _pdm_debug("parts[0] is NULL", 0);
   
     PDUstrip_dir_entry(parts[0]);
     _pdm_debug("calling PDUevaluate_exp", 0);
     status = PDUevaluate_exp(
                              parts[0],
                              "local_flag",
                              &local_flag
                             );
    
     if (status == PDM_S_SUCCESS)
       {
       _pdm_debug("file is not 2.2", 0);
       status = ex$close_module (
                                 index = index,
                                 flag = save_flag | EX_ACTINV,
                                 ftype = EX_invisible
                                );
       status = PDM_S_SUCCESS;
       continue;
       }
   
     _pdm_debug("calling PDUremove_assembly", 0);
     status = PDUremove_assembly(part_path, &mod_env);
     _pdm_status("PDUremove_assembly", status);
   
     if (!assy_bufr)
       {
       _pdm_debug("retrieving structure of part <%s>", refresh->rev_partid);
       status = PDMget_assembly_structure(refresh->rev_catalog,
                 refresh->rev_partid, refresh->rev_revision, 50, &assy_bufr, 0);
       _pdm_status("PDMget_assembly_structure", status);
     
       if ((status != PDM_S_SUCCESS) && (status != PDM_E_PART_NOT_ASSEMBLY))
         {
         _pdm_debug("failed to get assembly structure", 0);
         PDUmessage(status, 's');
         mess = (char *) PDUtranslate_message(status);
         FIg_set_text(forms.part_operations_form_id, FI_MSG_FIELD, mess);
         save_flag = 0;
         status = ex$close_module (
                                 index = index,
                                 flag = save_flag | EX_ACTINV,
                                 ftype = EX_invisible
                                );
         save_flag = 1;
         return(status);
         }
     
       if (!assy_bufr)
         {
         _pdm_debug("assembly buffer is NULL", 0);
         PDUmessage(status, 's');
         mess = (char *) PDUtranslate_message(status);
         FIg_set_text(forms.part_operations_form_id, FI_MSG_FIELD, mess);
         save_flag = 0;
         status = ex$close_module (
                                 index = index,
                                 flag = save_flag | EX_ACTINV,
                                 ftype = EX_invisible
                                );
         save_flag = 1;
         return(status);
         }
       }
   
     if (!assy_bufr)
       {
       _pdm_debug("ERROR>>> assy_bufr is NULL", 0);
       PDUmessage(PDM_E_RETRIEVE_ASSEMBLY, 's');
       mess = (char *) PDUtranslate_message(PDM_E_RETRIEVE_ASSEMBLY);
       FIg_set_text(forms.part_operations_form_id, FI_MSG_FIELD, mess);
       save_flag = 0;
       status = ex$close_module (
                               index = index,
                               flag = save_flag | EX_ACTINV,
                               ftype = EX_invisible
                              );
       save_flag = 1;
       return(status);
       }
   
     MEMbuild_array(assy_bufr);
     PDUsetup_buffer(assy_bufr, ROW, &data_row);
     PDUget_buffer_col(assy_bufr, "p_childno", &child_col);
     PDUget_buffer_col(assy_bufr, "n_cofilename", &file_col);
   
     PDUfill_in_string(&child_no, data_row[(assy_bufr->columns * 0) + child_col]);
     /*PDUfill_in_string(&filename, data_row[(assy_bufr->columns * 0) + file_col]);*/
   
     status = PDUadd_assy_struct_from_buffer
                                            (
                                             &mod_env,
                                             "",
                                             "",
                                             assy_bufr,
                                             0
                                            );
     _pdm_status("PDUadd_assy_struct_from_buffer", status);
   
     if (status != PDM_S_SUCCESS)
        {
         _pdm_debug("PDUadd_assy_struct_from_buffer failed", 0);
         save_flag = 0;
         status = ex$close_module (
                                 index = index,
                                 flag = save_flag | EX_ACTINV,
                                 ftype = EX_invisible
                              );
         save_flag = 1;
         return(0);
        }
   
     _pdm_debug("Close and save object space", 0);
     status = ex$close_module (
                               index = index,
                               flag = save_flag | EX_ACTINV,
                               ftype = EX_invisible
                              );
     _pdm_status ("ex$close_module", status);
     }
  }
 else
  _pdm_debug("file_count is not greater than 0", 0);

 return(PDM_S_SUCCESS);
}

IGRint PDUcvt_20objspace_for_checkout(mod_env)
 struct GRmd_env mod_env;
 {
 IGRlong          status, msg;
 struct GRmd_env  ref_mod_env;
 IGRchar          file_path[DI_PATH_MAX];
 IGRchar          attr_value[MAX_VALUE];
 IGRchar          serial[MAX_VALUE];
 IGRint           ref_count = 0;
 IGRint           type;
 IGRint           count = 0;
 IGRshort         convert_flag1;
 IGRshort         convert_flag2;
 char             *msg_str = NULL;
 struct PDUnth_ref_objects   *ref_list = NULL; 
 struct PDUnth_ref_objects   *head = NULL; 
 struct PDUpart_node         *head1 = NULL;
 struct PDUpart_node         *part_ids = NULL;
 IGRchar           user_msg[200];
 IGRchar           **attributes = NULL;
 IGRchar           **values = NULL;
 IGRint            *attribute_type;
 IGRint            attribute_count;
 struct GRid       part_id;


 _pdm_debug("In the PDUcvt_20objspace_for_checkout function", 0);

 strcpy(user_msg, "Severe error encountered while performing PDU object space conversion. Please 'Exit Without Save' and open a worksheet with PDU/PDM support.");

 /* Get active module information */

 /* Delete coor sys frm non-graphic parts 2.2 change */
 status = PDUget_all_GRpart_ids(
                                mod_env.md_id.osnum,
                                &part_ids,
                                &count
                               );
 _pdm_status("PDUget_all_GRpart_ids", status);

 head1 = part_ids;

 while (head1)
       {
        /* Extract GRpart part_type */
        co$part_get_attr (
                          msg = &msg,
                          mod_env = &mod_env,
                          part = &(head1->part_id),
                          attr = "part_type",
                          value = attr_value,
                          type = &type
                         );

        /* Extract GRpart serial attribute */
        co$part_get_attr (
                          msg = &msg,
                          mod_env = &mod_env,
                          part = &(head1->part_id),
                          attr = "serial",
                          value = serial,
                          type = &type
                         );

        if ( ((strcmp(attr_value, "N") == 0) ||
              (strcmp(attr_value, "n") == 0)) &&
             (strcmp(serial, "-1.000000") != 0) && 
             (strcmp(serial, "-2.000000") != 0) )
             {
              /* Get GRpart attrs of part */
              status  = PDUget_GRpart_all_attrs(
                                                mod_env,
                                                NULL,
                                                NULL,
                                                NULL,
                                                &attributes,
                                                &values,
                                                &attribute_type,
                                                &attribute_count,
                                                &(head1->part_id),
                                                0
                                               );
              _pdm_status("PDUget_GRpart_all_attrs", status);

              if (status != PDM_S_SUCCESS)
                 {
                  _pdm_debug("PDUget_GRpart_all_attrs failed", 0);

                  /* Display a message to user */
                  msg_str = (char *)PDUtranslate_message(PDM_E_NGRAPH_CONVERSION_FAILED);
                  UI_status(msg_str);
                  UI_error(user_msg);

                  return(status);
                 }

              /* Dlete the old GRpart */
              om$send(
                      msg = message GRgraphics.GRdelete (&msg, &mod_env),
                      senderid = NULL_OBJID,
                      targetid = (head1->part_id).objid,
                      targetos = (head1->part_id).osnum 
                     );

              /* Skip uniqueness attributes */
              attributes = attributes + 4;
              values = values + 4;
              attribute_type = attribute_type + 4;
              attribute_count = attribute_count - 4;

              /* Construct the new part attribute system */
              status = co$part_construct (
                                          msg = &msg,
                                          mod_env = &mod_env,
                                          catalog = *(values - 4),
                                          number = *(values - 2),
                                          revision = *(values - 3),
                                          description = *(values - 1),
                                          part = &part_id,
                                          attr = attributes,
                                          value = values,
                                          type = attribute_type,
                                          num = attribute_count
                                         );
              _pdm_status("co$part_construct", msg);

              if (msg != MSSUCC)
                 {
                  _pdm_debug("co$part_construct failed", 0);

                  /* Display a message to user */
                  msg_str = (char *)PDUtranslate_message(PDM_E_NGRAPH_CONVERSION_FAILED);
                  UI_status(msg_str);
                  UI_error(user_msg);

                  return(status);          
                 }
              
              /* Set serial to '-1' */
              co$part_put_attr (
                                msg = &msg,
                                mod_env = &mod_env,
                                part = &part_id,
                                attr = "serial",

                                value = "-1",
                                type = GR_DYNAMIC_ATTR
                               );
             }

        head1 = head1->next;

       } /* end while loop */

 /* Free attributes, and values */
 if (attributes)
    PDUfree_string_array(&attributes, attribute_count);

 if (values)
    PDUfree_string_array(&values, attribute_count);

 /* Free part_ids */
 if (part_ids)
    {
     head1 = part_ids;

     while (part_ids)
           {
            part_ids = part_ids->next;
            free(head1);
            head1 = part_ids;
           }
    }
 

 /* Get the <:filename> path */
 di$give_pathname(osnum = mod_env.md_id.osnum, pathname = file_path);

 _pdm_debug("Converting <%s>", file_path);

 convert_flag1 = 0;
 convert_flag2 = 0;

 /* Convert active obj. space origins */
 status = PDUconvert_part_origins(mod_env, 0, &convert_flag1);
 _pdm_status("PDUconvert_part_origins", status);

 if (status != PDM_S_SUCCESS)
    {
     _pdm_debug("PDUconvert_part_origins failed", 0);

     /* Display a message to user */
     msg_str = (char *)PDUtranslate_message(PDM_E_CONVERSION_FAILED);
     UI_status(msg_str);

     UI_error(user_msg);

     return(status);
    }

 /* Convert active obj. space part pointers */
 status = PDUconvert_part_pointers(mod_env, 0, &convert_flag2);
 _pdm_status("PDUconvert_part_pointers", status);

 if (status != PDM_S_SUCCESS)
    {
     _pdm_debug("PDUconvert_part_pointers failed", 0);

     /* Display a message to user */
     msg_str = (char *)PDUtranslate_message(PDM_E_CONVERSION_FAILED);
     UI_status(msg_str);

     UI_error(user_msg);

     return(status);
    }

 if ( (convert_flag1 == 1) && (convert_flag2 == 1) )
    {
     _pdm_debug("<%s> has already been converted", file_path);
    }

 /* Get list of all attached ref. file objects including nth-level */
 status = PDUget_all_reffile_objects(
                                     mod_env.md_id.osnum,
                                     1,
                                     &ref_list
                                    );
 _pdm_status("PDUget_all_reffile_objects", status);

 head = ref_list;
 while (head)
       {
        ref_count = ref_count + 1;
        head = head->next;
       }

 _pdm_debug("%d ref. file objects were found", ref_count);

 /* Perform conversion on each ref. file */
 head = ref_list;
 while (head)
       {
        /* Get ref. file module environment */
         status = om$send(
                         msg = message GRreffile.GRgetenvironment
                                       (&msg, &mod_env, &ref_mod_env),
                         senderid = mod_env.md_id.objid,
                         targetos = head->obj_id.osnum,
                         targetid = head->obj_id.objid
                        );
         _pdm_status2 ("GRreffile.GRgetenvironment", status, msg);

         if (1&status && msg == MSSUCC)
            {
             /* Get the <:filename> path */
             di$give_pathname(
                              osnum = ref_mod_env.md_id.osnum,
                              pathname = file_path
                             );
             _pdm_debug("converting ref. file <%s>", file_path);

             convert_flag1 = 0;
             convert_flag2 = 0;

             /* Convert ref. obj. space origins */
             status = PDUconvert_part_origins(ref_mod_env, 1, &convert_flag1);
             _pdm_status("PDUconvert_part_origins", status);

             if (status != PDM_S_SUCCESS)
                {
                 _pdm_debug(
                            "PDUconvert_part_origins failed on osnum %d", 
                            ref_mod_env.md_id.osnum
                           );

                 /* Display a message to user */
                 msg_str = (char *)PDUtranslate_message(PDM_E_CONVERSION_FAILED);
                 UI_status(msg_str);

                 UI_error(user_msg);

                 return(status);
                }

             /* Convert ref. obj. space part pointers */
             status = PDUconvert_part_pointers(ref_mod_env, 1, &convert_flag2);
             _pdm_status("PDUconvert_part_pointers", status);

             if (status != PDM_S_SUCCESS)
                {
                 _pdm_debug(
                            "PDUconvert_part_pointers failed on osnum %d",
                       	    ref_mod_env.md_id.osnum
                           );

                 /* Display a message to user */
                 msg_str = (char *)PDUtranslate_message(PDM_E_CONVERSION_FAILED);
                 UI_status(msg_str);

                 UI_error(user_msg);
 
                 return(status);
                }

                if ( (convert_flag1 == 1) && (convert_flag2 == 1) )
                   {
                    _pdm_debug("<%s> has already been converted", file_path);
                   }

            }

         else
             {
              _pdm_debug("GRreffile.GRgetenvironment failed", 0);

              /* Process next ref. file */
              head = head->next;
              continue;
             }

        /* Process next ref. file */
        head = head->next;

       } /* end while loop */

 /* Free variables */
 if (ref_list)
    {
     head = ref_list;

     while (ref_list)
           {
            ref_list = ref_list->next;
            free(head);
            head = ref_list;
           }
    }

  return(PDM_S_SUCCESS);
 }
end implementation COpdu;
