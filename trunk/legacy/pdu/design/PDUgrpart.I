class implementation COpdu;
/*
   This file contains all functions for creating and manipulating a part pointer
   using GRpart representation. 2.0

   Author: Jamal Shakra 
   Date: 08-08-91
*/

/* Include file section */
#include        "stdio.h"
#include        "unistd.h"
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
#include        "PDUuser.h"
#include        "PDUfile_def.h"
#include        "PDUconvert.h"
#include        "PDUqueue.h"
#include        "PDUassy.h"


/* External variables declaration section */
extern struct PDUuser    *user;
extern struct PDUrefresh    *refresh;
extern struct PDUqueue_info *PDU_queue_info;
extern IGRshort PDU_macro_call;

/* Global variables */
struct GRid  *PDU_src_part_id;
struct GRid  *PDU_dst_part_id;
struct GRid  *PDU_part_id;
struct GRid  *PDU_origin_id;
struct PDUpart_node  *PDU_parts_id_list;
struct PDUpart_node  *PDU_origins_id_list;
struct PDUref_node   *PDU_ref_filenames; 


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
from  GRreffile   import       GRrfload;
from  GRcsmgr     import       GRcstoggle_display;


/*
 * This function creates a PDU GRpart. 
 */

IGRint PDUcreate_GRpart (
                         mod_env,               /* module environment */
                         catalog, 		/* catalog name */
                         number,                /* part number */
                         revision,              /* part revision */
                         child_no,              /* child no, if any */
                         quantity,              /* quantity */
                         alt_tagno,             /* alt tag no */
                         usage_id,              /* usage id */
                         view_name,             /* view name */
                         history,               /* history */
                         part_type,             /* part type */
                         incbom,                /* include in BOM */
                         incstr,                /* include in structure */
                         explode,               /* explode in BOM */
                         attach,                /* attach part? */
                         part_id 		/* part's id */
                        )

 struct GRmd_env  *mod_env;		/* INPUT */
 IGRchar          *catalog;		/* INPUT */
 IGRchar          *number;              /* INPUT */
 IGRchar          *revision;            /* INPUT */
 IGRchar          *child_no;            /* INPUT */
 IGRchar          *quantity;            /* INPUT */
 IGRchar          *alt_tagno;           /* INPUT */
 IGRchar          *usage_id;            /* INPUT */
 IGRchar          *view_name;           /* INPUT */
 IGRchar          *history;             /* INPUT */
 IGRchar          *part_type;           /* INPUT */
 IGRchar          *incbom;              /* INPUT */
 IGRchar          *incstr;              /* INPUT */
 IGRchar          *explode;             /* INPUT */
 IGRshort         attach;               /* INPUT */
 struct GRid      *part_id;		/* OUTPUT */
{
 IGRlong          msg;
 IGRlong          status = PDM_S_SUCCESS;
 IGRint           i;
 IGRint           basic_attr_count = 15;
 IGRint           attribute_count;
 IGRint           instance_no;
 IGRchar          **attrs;
 IGRchar          **data;
 IGRchar          attr_value[MAX_VALUE];
 IGRchar          text_value[MAX_VALUE];
 IGRchar          **attributes;
 IGRchar          **values;
 IGRchar          *tag_no = NULL;
 IGRchar          *local_alttag = NULL;
 IGRchar          *p_explode = NULL;
 IGRchar          tmp_tag[DI_PATH_MAX];
 IGRchar          tmp_alttag[DI_PATH_MAX];
 IGRchar          tmp_usage_id[DI_PATH_MAX];
 IGRchar          tmp_childno[DI_PATH_MAX];
 IGRchar          part_date[26];
 IGRint           *attribute_type;
 IGRshort         increment_tag_no;
 MEMptr           dyn_attr_bufr = NULL;
 MEMptr           dyn_value_bufr = NULL;
 MEMptr           dyn_data_bufr = NULL;
 FILE             *pdu_debug_file;
 IGRshort         free_mod = FALSE;
 IGRint           bufsiz;



 _pdm_debug("In the PDUcreate_GRpart function", 0);

 
 /* Default module env. to current if mod_env is NULL */
 if (!mod_env)
    {
     mod_env = (struct GRmd_env *) malloc(sizeof(struct GRmd_env));
     bufsiz = sizeof(struct GRmd_env);
     gr$get_module_env(sizbuf = &bufsiz, buffer = mod_env);
     free_mod = TRUE;
    }

 /* Get tag number from object space */
 status = PDUgenerate_tag_no(&tag_no, mod_env->md_id.osnum);
 _pdm_status("PDUgenerate_tag_no", status);

 _pdm_debug("tag_no = <%s>", tag_no);

 if (!child_no)
    {
     /* Generate a child number */
     status = PDUgenerate_child_no(
                                   &child_no,
                                   mod_env->md_id.osnum
                                  );
     _pdm_status("PDUgenerate_child_no", status);

     _pdm_debug("child_no = <%s>", child_no);
    }

 /* Get instance number for new part */
 increment_tag_no = FALSE;
 status = PDUgenerate_instance_number(
                                      catalog,
                                      number,
                                      revision,
                                      &instance_no,
                                      mod_env
                                     );
 _pdm_debug("instance no = %d", instance_no);

 if (instance_no == 1)
     {
      /* Set increment tag no flag to TRUE */
      increment_tag_no = TRUE;
      PDUfill_in_string(&local_alttag, alt_tagno);
     }

 else
     {
      /* Other instances exist, get tag_no from any instance */
      status = co$part_get_attr (
                                 msg = &msg,
                                 mod_env = mod_env,
                                 catalog = catalog,
                                 number = number,
                                 revision = revision,
                                 attr = "tag",
                                 value = attr_value
                                );

      if (msg != MSSUCC)
         {
          _pdm_debug("co$part_get_attr failed on tag", 0);
          return(status);
         }

      /* Unquote tag no */
      PDUunquote(attr_value);
      PDUfill_in_string(&tag_no, attr_value);

      /* Get alt. tag number from any instance */
      status = co$part_get_attr (
                                 msg = &msg,
                                 mod_env = mod_env,
                                 catalog = catalog,
                                 number = number,
                                 revision = revision,
                                 attr = "alt_tag",
                                 value = attr_value
                                );

      if (msg != MSSUCC)
         {
          _pdm_debug("co$part_get_attr failed on alt_tag", 0);
          return(status);
         }

      /* Unquote alt tag no */
      PDUunquote(attr_value);
      PDUfill_in_string(&local_alttag, attr_value);
     }

 /* Enforce text type on tagno */
 sprintf(tmp_tag,"\"%s\"", tag_no);

 /* Enforce text type on usage id */
 if (strcmp(usage_id, "") != 0)
    {
     sprintf(tmp_usage_id,"\"%s\"", usage_id);
    }

 else
     {
      strcpy(tmp_usage_id, "");
     }

 /* Enforce text type on local_alttag */
 if ( (local_alttag) && (strcmp(local_alttag, "") != 0) )
    {
     sprintf(tmp_alttag,"\"%s\"", local_alttag);
    }

 else
     {
      strcpy(tmp_alttag, "");
     }

 /* Enforce text type on child number */
 sprintf(tmp_childno,"\"%s\"", child_no);

 /* Get dynamic attributes for part */
 status = PDMquery_dynamic_attrs(
                                 catalog,
                                 number,
                                 revision,
                                 &dyn_attr_bufr,
                                 &dyn_data_bufr,
                                 &dyn_value_bufr,
                                 &p_explode
                                );
 _pdm_status("PDMquery_dynamic_attrs", status);

 if ( (status != PDM_S_SUCCESS) || (dyn_attr_bufr == NULL) )
    {
     _pdm_debug("No Dynamic Attributes Were Defined For Part <%s>", number);
    }

 if (dyn_attr_bufr)
    {
     attribute_count = dyn_attr_bufr->rows + basic_attr_count;
    }

 else
     attribute_count = basic_attr_count;

 _pdm_debug("attribute count = %d", attribute_count);

 /* Allocate and initialize attributes, values, and types */
 attributes = (IGRchar **) malloc(attribute_count*sizeof(char *));
 memset((char *)attributes, NULL, attribute_count*sizeof(char *));

 values = (IGRchar **) malloc(attribute_count*sizeof(char *));
 memset((char *)values, NULL, attribute_count*sizeof(char *));

 attribute_type = (IGRint *) malloc(attribute_count*sizeof(int));
 memset((char *)attribute_type, GR_STATIC_ATTR, attribute_count*sizeof(int));

 /* Get part creation date */
 PDUget_date(part_date);

 /* Set attributes, values, and attribute_types */
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
 PDUfill_in_string(&values[1], "-1");
 PDUfill_in_string(&values[2], quantity);
 PDUfill_in_string(&values[3], tmp_alttag);
 PDUfill_in_string(&values[4], tmp_usage_id);
 PDUfill_in_string(&values[5], view_name);
 PDUfill_in_string(&values[6], history);
 PDUfill_in_string(&values[7], part_date);
 PDUfill_in_string(&values[8], "-1");
 PDUfill_in_string(&values[9], tmp_childno);
 PDUfill_in_string(&values[10], incbom);
 PDUfill_in_string(&values[11], incstr);
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

 /* Load dynamic attributes, if any */

 if (dyn_attr_bufr) 
    {
      _pdm_debug("Load dynamic attributes", 0);

      if (dyn_attr_bufr->rows > 0) 
         {
           MEMbuild_array(dyn_attr_bufr);

           status = PDUsetup_buffer(
                                    dyn_attr_bufr,
                                    ROW, 
                                    &attrs
                                   );

           for (i = 0; i < dyn_attr_bufr->rows; i = i + 1)
             {
              /* Load dynamic attributes names */
              PDUfill_in_string(
                                &attributes[i+basic_attr_count],
                                attrs[(dyn_attr_bufr->columns * i) + 
                                PDU_DYN_ATTR_COL]
                               );
             }

         if (dyn_data_bufr) 
            {
             if (dyn_data_bufr->rows > 0)
                {
                 MEMbuild_array(dyn_data_bufr);
                 status = PDUsetup_buffer(
                                          dyn_data_bufr,
                                          ROW,
                                          &data
                                         );

                 for (i = 0; i < dyn_data_bufr->rows; i = i + 1)
                     {
                      /* Enforce text type on text attributes */
                      if ((strncmp(attrs[(dyn_attr_bufr->columns * i) + 
                           PDU_DYN_DATA_COL], "char", 4) == 0) ||
                         (strncmp(attrs[(dyn_attr_bufr->columns * i) + 
                           PDU_DYN_DATA_COL], "timestamp", 9) == 0))
                         {
                          if (strcmp(data[(dyn_data_bufr->columns * i) + 
                              PDU_DYN_DEFAULT_VAL_COL], "") == 0)
                             {
                              /* Default dynamic attrs values to "" */
                              _pdm_debug("defaulting text attr value", 0);

                              PDUfill_in_string(
                                            &values[i + basic_attr_count],
                                            ""
                                               );
                             }

                          else
                              {
                               sprintf(text_value,"\"%s\"", 
                                       data[(dyn_data_bufr->columns * i) + 
                                       PDU_DYN_DEFAULT_VAL_COL]);
                               PDUfill_in_string(
                                            &values[i + basic_attr_count],
                                            text_value 
                                                );
                              }
                         }

                      else
                         {
                          if (strcmp(data[(dyn_data_bufr->columns * i) + 
                              PDU_DYN_DEFAULT_VAL_COL], "") == 0)
                             {
                              /* Default dynamic attrs values to 0 */
                              _pdm_debug("defaulting arithmetic attr value", 0);

                              PDUfill_in_string(
                                            &values[i + basic_attr_count],
                                            "0"
                                               );
                             }

                          else 
                              { 
                               /* Load dynamic attributes values */
                               PDUfill_in_string(
                                            &values[i + basic_attr_count],
                                            data[(dyn_data_bufr->columns * i) +
                                            PDU_DYN_DEFAULT_VAL_COL]
                                                );
                              }
                        }
                     }
                 }

               else
                 {
                  _pdm_debug("SEVERE error: data buffer has no rows", 0);
                 }
             }

         else
             {
              _pdm_debug("dyn_data_bufr is empty", 0);
             }

         /* Default dynamic attributes types */
         for (i = 0; i < dyn_attr_bufr->rows; i = i + 1)
             {
              attribute_type[i + basic_attr_count] = GR_DYNAMIC_ATTR;
             }
          }
    }

 if (PDM_debug_on)
    {
     /* Open debug file */
     pdu_debug_file = (FILE *) fopen (PDU_DEBUG_FILE, "a");

     for (i = 0; i < attribute_count; i = i + 1)
         {
          fprintf(pdu_debug_file,
                      "PDU -- attributes[%d] = <%s> \n", i, attributes[i]);
          fprintf(pdu_debug_file,
                      "PDU -- values[%d] = <%s> \n", i, values[i]);
          fprintf(pdu_debug_file,
                     "PDU -- attribute_type[%d] = <%d>\n", i,attribute_type[i]);
         }

     /* Close debug file */
     fclose(pdu_debug_file);
    }

 /* Construct GRpart */
 status = co$part_construct (
                             msg = &msg,
                             mod_env = mod_env,
                             catalog = catalog,
                             number = number,
                             revision = revision,
                             part = part_id,
                             attr = attributes,
                             value = values,
                             type = attribute_type,
                             num = attribute_count
                            ); 
 _pdm_status("co$part_construct",status);

 if (msg == MSSUCC)
    {
     PDUincrement_tag_no(mod_env->md_id.osnum);

     /* Check to see if part needs to be attached */
     if (attach)
        {
         /* Modify attach flag to indicate this */
         co$part_put_attr (
                           msg = &msg,
                           mod_env = mod_env,
                           part = part_id,
                           attr = "attach_flag",
                           value = "-2",
                           type = GR_DYNAMIC_ATTR 
                          );
        }
    }

 else 
     {
      _pdm_debug("PDUcreate_GRpart failed",0);
      status = PDM_E_GR_PART;

      /* Free buffers */
      if (dyn_attr_bufr)
         {
          MEMclose(&dyn_attr_bufr);
         }

       if (dyn_data_bufr)
          {
           MEMclose(&dyn_data_bufr);
          }

       if (dyn_value_bufr)
          {
           MEMclose(&dyn_value_bufr);
          }

       /* Free values */
        PDUfree_string_array(&values, attribute_count);

        /* Free attributes */
        PDUfree_string_array(&attributes, attribute_count);

        /* Free types */
        if (attribute_type)
           {
            free(attribute_type);
           }

        if (free_mod)
           {
            free(mod_env);
            mod_env = NULL;
           }

      return(status);
     }

 /* Free buffers */
 if (dyn_attr_bufr)
    {
     MEMclose(&dyn_attr_bufr);
    }

 if (dyn_data_bufr)
    {
     MEMclose(&dyn_data_bufr);
    }

 if (dyn_value_bufr)
    {
     MEMclose(&dyn_value_bufr);
    }

 /* Free values */
 PDUfree_string_array(&values, attribute_count);

 /* Free attributes */
 PDUfree_string_array(&attributes, attribute_count);

 /* Free types */
 if (attribute_type)
    {
     free(attribute_type);
    }

 if (free_mod)
    {
     free(mod_env);
     mod_env = NULL;
    }
 
 return(PDM_S_SUCCESS);
}
 
/*
 * This function extracts a part pointer object id.  
 */

IGRint PDUget_GRpart (
                      mod_env,          /* module environment */
                      catalog, 		/* catalog name */
                      number,		/* part number */
                      revision,         /* part revision */
                      part_id 		/* part's id */
                     )

 struct GRmd_env  mod_env;		/* INPUT */
 IGRchar          *catalog;		/* INPUT */
 IGRchar          *number;		/* INPUT */	
 IGRchar          *revision;            /* INPUT */
 struct GRid      part_id;		/* OUTPUT */
{
 IGRlong          msg;
 IGRlong          status = PDM_S_SUCCESS;

 _pdm_debug("In the PDUget_GRpart function",0);

 status = co$part_get_template (
                               msg = &msg,
                               mod_env = &mod_env,
                               catalog = catalog,
                               number = number,
                               revision = revision,
                               part = &part_id
                              ); 
 _pdm_status("co$part_get_template",status);

 if (msg != MSSUCC)
    {
     _pdm_debug("PDUget_GRpart failed",0);
     status = PDM_E_GR_PART;
     return(status);
    }
 
 return(PDM_S_SUCCESS);
}
 
/*
  This function modifies a part pointer content.  
*/

IGRint PDUmodify_GRpart (
                         mod_env,		/* module environment */
                         catalog, 		/* catalog name */
                         number, 		/* part's number */
                         revision,              /* part's revision */
                         part_id, 		/* part's id */
                         attribute, 		/* part's attribute */
                         value, 		/* attribute values */
                         attribute_type, 	/* attribute type */
                         number_or_id           /* part number or objid */
                        )

 struct GRmd_env  mod_env;		/* INPUT */
 IGRchar          *catalog;		/* INPUT */
 IGRchar          *number;		/* INPUT */
 IGRchar          *revision;            /* INPUT */
 struct GRid      part_id;		/* INPUT */
 IGRchar          *attribute;		/* INPUT */	
 IGRchar          *value;		/* INPUT */
 IGRint           attribute_type;	/* INPUT */
 IGRint           number_or_id;         /* INPUT */
{
 IGRlong          msg;
 IGRlong          status = PDM_S_SUCCESS;

 _pdm_debug("In the PDUmodify_GRpart function",0);

 if (number_or_id == PART_NUMBER)
 /* part number is used */
    {
     status = co$part_put_attr (
                                msg = &msg,
                                mod_env = &mod_env,
                                catalog = catalog,
                                number = number,
                                revision = revision,
                                attr = attribute,
                                value = value,
                                type = attribute_type
                               ); 
    }
 
 else
 /* part id is used */
    {
     status = co$part_put_attr (
                                msg = &msg,
                                mod_env = &mod_env,
                                part = &part_id,
                                attr = attribute,
                                value = value,
                                type = attribute_type
                               ); 
    }

 _pdm_status("co$part_put_attr",status);

 if (msg != MSSUCC)
    {
     _pdm_debug("PDUmodify_GRpart failed",0);
     status = PDM_E_GR_PART;
     return(status);
    }

 return(PDM_S_SUCCESS);
}
 
/*
  This function removes attributes name/value pairs from a part pointer.  
*/

IGRint PDUremove_GRpart_attr (
                              mod_env,		/* module environment */
                              catalog,  	/* catalog name */
                              number,   	/* part's number */
                              revision,         /* part's revision */
                              part_id,  	/* part's id */
                              attribute, 	/* part's attribute */
                              number_or_id      /* number or part id */
                             )

 struct GRmd_env  mod_env;		/* INPUT */
 IGRchar          *catalog;		/* INPUT */
 IGRchar          *number;		/* INPUT */
 IGRchar          *revision;            /* INPUT */
 struct GRid      part_id;		/* INPUT */
 IGRchar          *attribute;		/* INPUT */
 IGRchar          number_or_id;         /* INPUT */	
{
 IGRlong          msg;
 IGRlong          status = PDM_S_SUCCESS;

 _pdm_debug("In the PDUremove_GRpart_attr function",0);

 if (number_or_id == PART_NUMBER)
 /* part number is used */
    {
     status = co$part_rem_attr (
                                msg = &msg,
                                mod_env = &mod_env,
                                catalog = catalog,
                                number = number,
                                revision = revision,
                                attr = attribute
                               ); 
    }

 else
 /* part id is used */
    {
     status = co$part_rem_attr (
                                msg = &msg,
                                mod_env = &mod_env,
                                part = &part_id,
                                attr = attribute
                               ); 
    }

 _pdm_status("co$part_rem_attr",status);

 if (msg != MSSUCC)
    {
     _pdm_debug("PDUremove_GRpart_attr failed",0);
     status = PDM_E_GR_PART;
     return(status);
    }
 
 return(PDM_S_SUCCESS);
}
 
/*
  This function extracts an attribute value for a given attribute.  
*/

IGRint PDUextract_GRpart_attr_value (
                                     mod_env,	    /* module environment */
                                     catalog, 	    /* catalog name */
                                     number,	    /* part's number */
                                     revision,      /* part's revision */
                                     part_id, 	    /* part's id */
                                     attribute,     /* part's attribute */
                                     number_or_id,  /* number or id */
                                     value,         /* attribute value */
                                     attribute_type /* attribute type */
                                    )

 struct GRmd_env  mod_env;		/* INPUT */
 IGRchar          *catalog;		/* INPUT */
 IGRchar          *number;		/* INPUT */
 IGRchar          *revision;            /* INPUT */
 struct GRid      part_id;		/* INPUT */
 IGRchar          *attribute;		/* INPUT */	
 IGRint           number_or_id;         /* INPUT */
 IGRchar          value[MAX_VALUE];	/* OUTPUT */
 IGRint           attribute_type;	/* OUTPUT */ 
{
 IGRlong          msg;
 IGRlong          status = PDM_S_SUCCESS;

 _pdm_debug("In the PDUextract_GRpart_attr_value function",0);

 if (number_or_id == PART_NUMBER)
 /* part number is used */
    {
     status = co$part_get_attr (
                                msg = &msg,
                                mod_env = &mod_env,
                                catalog = catalog,
                                number = number,
                                revision = revision,
                                attr = attribute,
                                value = value,
                                type = &attribute_type
                               ); 
    }

 else
 /* part id is used */
   {
     status = co$part_get_attr (
                                msg = &msg,
                                mod_env = &mod_env,
                                part = &part_id,
                                attr = attribute,
                                value = value,
                                type = &attribute_type
                               ); 
   } 

 _pdm_status("co$part_get_attr",status);

 if (msg != MSSUCC)
    {
     _pdm_debug("PDUextract_GRpart_attr_value failed",0);
     status = PDM_E_GR_PART;
     return(status);
    }
 
 return(PDM_S_SUCCESS);
}
 
/*
  This function gets all attribute/value pairs for a given part pointer. 
*/

IGRint PDUget_GRpart_all_attrs (
                                mod_env,        /* module environment */
                                catalog,        /* part catalog */
                                number, 	/* part number */
                                revision,       /* part revision */
                                attributes, 	/* part's attributes */
                                values, 	/* attributes values */
                                attribute_types,/* attributes type */
                                attribute_count,/* attributes count */
                                part_id, 	/* part's id */
                                number_or_id    /* number or id */
                               )

 struct GRmd_env  mod_env;				/* INPUT */
 IGRchar          *catalog;				/* INPUT */
 IGRchar          *number;              		/* INPUT */
 IGRchar          *revision;            		/* INPUT */
 IGRchar          ***attributes;			/* OUTPUT */	
 IGRchar          ***values;				/* OUTPUT */
 IGRint           **attribute_types;			/* OUTPUT */
 IGRint           *attribute_count;			/* INPUT/OUTPUT */
 struct GRid      *part_id;				/* INPUT */
 IGRint           number_or_id;         		/* INPUT */
{
 IGRlong          msg;
 IGRint           i;
 IGRlong          status = PDM_S_SUCCESS;

 _pdm_debug("In the PDUget_GRpart_all_attrs  function",0);

 if (number_or_id == PART_NUMBER)
 /* part number is used */
    {
     _pdm_debug("quering by part number", 0);
     status = co$part_get_all_attr (
                                    mod_env = &mod_env,
                                    msg = &msg,
                                    catalog = catalog,
                                    number = number,
                                    revision = revision,
                                    num = attribute_count
                                   );
    }

 else
 /* part id is used */
    {
     _pdm_debug("quering by part id", 0);
     _pdm_debug("part id at entry = %d", part_id->objid);
     _pdm_debug("part osnum at entry = %d", part_id->osnum);

     status = co$part_get_all_attr (
                                    mod_env = &mod_env,
                                    msg = &msg,
                                    part = part_id,
                                    num = attribute_count
                                   );
    }

 _pdm_status("co$part_get_all_attr(1)", status);

 if (msg != MSSUCC)
    {
     _pdm_debug("co$part_get_all_attr failed", 0);
     return(status);
    }

 if ( (*attribute_count > 0) && (msg == MSSUCC) )
    {
     /* malloc and initialize attribue pointers */
     *attributes = (IGRchar **) malloc (sizeof(IGRchar *) * (*attribute_count));
     *values = (IGRchar **) malloc (sizeof(IGRchar *) * (*attribute_count));
     *attribute_types = (IGRint *) malloc (sizeof(IGRint) * (*attribute_count));

     memset((char *)*attributes, NULL, sizeof(IGRchar *) * (*attribute_count));
     memset((char *)*values, NULL, sizeof(IGRchar *) * (*attribute_count));
     memset((char *)*attribute_types,GR_STATIC_ATTR,sizeof(IGRint)*(*attribute_count));

     for (i = 0; i < *attribute_count; ++i)
         {
          (*attributes)[i] = (IGRchar *) malloc (sizeof(IGRchar) * MAX_ATTR);
          (*values)[i] = (IGRchar *) malloc (sizeof(IGRchar) * MAX_VALUE);
         }

     if (number_or_id == PART_NUMBER)
     /* part number is used */
        {
         status = co$part_get_all_attr (
                                        msg = &msg,
                                        mod_env = &mod_env,
                                        catalog = catalog,
                                        number = number, 
                                        revision = revision,
                                        attr = *attributes,
                                        value = *values,
                                        type = *attribute_types,
                                        num = attribute_count
                                       ); 
        }

     else
     /* part id is used */
        {
         status = co$part_get_all_attr (
                                        msg = &msg,
                                        mod_env = &mod_env,
                                        part = part_id,
                                        attr = *attributes,
                                        value = *values,
                                        type = *attribute_types,
                                        num = attribute_count
                                       ); 
        }

     _pdm_status("co$part_get_all_attr(2)",status);

     if (msg != MSSUCC)
        {
         _pdm_debug("PDUget_GRpart_all_attrs(2) failed",0);
         status = PDM_E_GR_PART;
         return(status);
        }
    }

 else
    {
     _pdm_debug("No attributes found for this part",0);
     status = PDM_S_SUCCESS;
     return(status);
    }
 
 return(PDM_S_SUCCESS);
}
 
/*
  This function returns a list of parts information in a given catalog. 
*/

IGRint PDUget_GRparts (
                        mod_env,        /* module environment */
                        catalog, 	/* catalog name */
                        numbers,	/* parts numbers */
                        descriptions,   /* parts names  */
                        revisions,      /* parts revisions */
                        quantities,	/* parts quantities */
                        list_size,      /* part list size */
                        part_ids 	/* list of representative parts */
                      )

 struct GRmd_env  mod_env;			/* INPUT */
 IGRchar          *catalog;			/* INPUT */
 IGRchar          **numbers;		        /* OUTPUT */
 IGRchar          **descriptions;		/* OUTPUT */	
 IGRchar          **revisions;		        /* OUTPUT */
 IGRint           *quantities;		  	/* OUTPUT */
 IGRint           list_size;    		/* INPUT/OUTPUT */
 struct GRid      *part_ids;			/* OUTPUT */
{
 IGRlong          msg;
 IGRint           i;
 IGRlong          status = PDM_S_SUCCESS;

 _pdm_debug("In the PDUget_GRparts  function",0);

 /* get number of parts in the specified catalog */
 status = co$part_get_parts (
                             msg = &msg,
                             mod_env = &mod_env,
                             num = &list_size
                            );
 _pdm_status("co$part_get_parts(1)",0);

 if ( (list_size > 0) && (msg == MSSUCC) )
    {
     /* malloc and initialize part info pointers */
     numbers = (IGRchar **) malloc (sizeof(IGRchar *) * list_size);
     descriptions = (IGRchar **) malloc (sizeof(IGRchar *) * list_size);
     revisions = (IGRchar **) malloc (sizeof(IGRchar *) * list_size);
     part_ids = (struct GRid *) malloc (sizeof(struct GRid) * list_size);

     memset((char *)numbers, NULL, sizeof(IGRchar *) * list_size);
     memset((char *)descriptions, NULL, sizeof(IGRchar *) * list_size);
     memset((char *)revisions, NULL, sizeof(IGRchar *) * list_size);
     memset((char *)part_ids, NULL, sizeof(struct GRid) * list_size);

     for (i = 0; i < list_size; ++i)
         {
          numbers[i] = (IGRchar *) malloc (sizeof(IGRchar) * MAX_VALUE);
          descriptions[i] = (IGRchar *) malloc (sizeof(IGRchar) * MAX_VALUE);
          revisions[i] = (IGRchar *) malloc (sizeof(IGRchar) * MAX_VALUE);
         }

     status = co$part_get_parts (
                                 msg = &msg,
                                 mod_env = &mod_env,
                                 catalog = catalog,
                                 number = numbers, 
                                 name = descriptions,
                                 revision = revisions,
                                 part = part_ids,
                                 quantity = quantities,
                                 num = &list_size
                                ); 
     _pdm_status("co$part_get_parts(2)",status);

     if (msg != MSSUCC)
        {
         _pdm_debug("PDUget_GRparts(2) failed",0);
         status = PDM_E_GR_PART;
         return(status);
        }
    }
 
 else
   {
    _pdm_debug("No GRparts found in catalog <%s>", catalog);
    status = PDM_S_SUCCESS;
    return(status);
   }
 
 return(PDM_S_SUCCESS);
}

/*
  This function sends a message to all parts of the same type in a catalog.  
*/

IGRint PDUpass_GRparts (
                        mod_env,	/* module environment */
                        catalog,  	/* catalog name */
                        number,   	/* part's number */
                        revision,       /* part's revision */
                        pass_msg,       /* message to pass */
                        senderid,       /* sender obj. id */
                        senderos        /* sender space number */
                       )

 struct GRmd_env  mod_env;		/* INPUT */
 IGRchar          *catalog;		/* INPUT */
 IGRchar          *number;		/* INPUT */
 IGRchar          *revision;            /* INPUT */
 OM_p_MESSAGE     pass_msg;             /* INPUT */
 GRobjid          senderid;             /* INPUT */
 GRspacenum       senderos;             /* INPUT */
{
 IGRlong          msg;
 IGRlong          status = PDM_S_SUCCESS;

 _pdm_debug("In the PDUpass_GRparts function",0);

 status = co$part_pass (
                         msg = &msg,
                         mod_env = &mod_env,
                         catalog = catalog,
                         number = number,
                         revision = revision,
                         pass_msg = pass_msg,
                         senderid = senderid,
                         senderos = senderos
                       ); 
 _pdm_status("co$part_pass",status);

 if (msg != MSSUCC)
    {
     _pdm_debug("PDUpass_GRparts failed",0);
     status = PDM_E_GR_PART;
     return(status);
    }
 
 return(PDM_S_SUCCESS);
}

/* 
 * This function is used to generate a part instance number.
 */

IGRint PDUgenerate_instance_number(
                                   catalog,	/* INPUT */
                                   number,	/* INPUT */
                                   revision,	/* INPUT */
                                   instance_no,	/* OUTPUT */
                                   mod_env	/* INPUT */
                                  )

 IGRchar	 *catalog;
 IGRchar	 *number;
 IGRchar	 *revision;
 IGRint		 *instance_no;
 struct GRmd_env *mod_env;

{
 IGRlong  msg;
 IGRlong  status;
 IGRchar  s[DI_PATH_MAX];
 IGRchar  usage_id[DI_PATH_MAX];
 IGRchar  parts_dir[DI_PATH_MAX];
 IGRchar  attr_value[MAX_VALUE];
 IGRint   count = 0;
 IGRint   type = 0;
 IGRint   i;
 IGRshort unique = FALSE;
 IGRshort found;
 struct GRid      *part_ids = NULL;
 
 _pdm_debug("In the PDUgenerate_instance_number function", 0);

 *instance_no = 1;
 
 /* Get the <:filename:parts:catalog:number!revision> path */
 di$give_pathname(osnum = mod_env->md_id.osnum, pathname = parts_dir);
 _pdm_debug("parts_dir = <%s>", parts_dir);

 sprintf(
         s,
         "%s:parts:%s:%s!%s:",
         parts_dir,
         catalog,
         number,
         revision
        );

 _pdm_debug("part full path = <%s>", s);
 
 /* Get all part occurences */
 status = PDUget_GRparts_ids(
                             s,
                             &part_ids,
                             &count
                            );

 if (count == 0)
    {
     _pdm_debug("first occurence of part", 0);
     *instance_no = 1;
     return(PDM_S_SUCCESS);
    }

 /* Generate unique instence number */
 while (!unique)
       {
        ++(*instance_no);
        
        /* Construct usage id */
        sprintf(
                usage_id,
                "%s %s #%d",
                number,
                revision,
                *instance_no
               );

        found = FALSE;

        /* Loop thru making sure usage id is unique */
        for (i = 0; i < count; ++i)
            {
             co$part_get_attr (
                               msg = &msg,
                               mod_env = mod_env,
                               part = &part_ids[i],
                               attr = "usage_id",
                               value = attr_value,
                               type = &type
                              );

             /* Unquote value */
             PDUunquote(attr_value);

             if (strcmp(attr_value, usage_id) == 0)
                {
                 found = TRUE;
                 break;
                }
            } /* end for loop */

         if (!found)
            unique = TRUE;

       } /* end while loop */
 
 _pdm_debug("generated instance_no = %d", *instance_no);

 /* Free up part_ids */
 if (part_ids)
   {
     free(part_ids);
   }

 return(PDM_S_SUCCESS);
 }

/*
 * This function generates a part tag number.
 */ 

IGRint	PDUgenerate_tag_no (tag_value, osnum)

 IGRchar        **tag_value;       /* OUTPUT */
 OMuword        osnum;             /* INPUT */
 {
  IGRint	status = PDM_S_SUCCESS;	
  IGRint        i;
  IGRint        count = 0;	
  IGRint        entry_count = 0;	
  IGRint        mac_entry_count = 0;	
  IGRchar       dir_path[DI_PATH_MAX];
  IGRchar       tag_dir[DI_PATH_MAX];
  IGRchar       mac_tag_dir[DI_PATH_MAX];
  IGRchar       mac_tag_entry[DI_PATH_MAX];
  IGRchar       *mac_tag_value = NULL;
  IGRchar       *tmp_mac_tag_entry = NULL;
  IGRchar       **tags; 
  IGRchar       **mac_tags; 
  OM_S_OBJID    osid = NULL_OBJID;


  _pdm_debug("In the function PDUgenerate_tag_no", 0);

  /* Check if need to get active design module info */
 if (osnum == 0)
    {
     /* Get active module info */
     status = ex$get_cur_mod ( id = &osid, osnum = &osnum );
     _pdm_status("ex$get_cur_mod", status);
    }

  /* Check to see if part is parametric */
  _pdm_debug("refresh->rev_parttype = %s", refresh->rev_parttype);
  if (strcmp(refresh->rev_parttype, "P") == 0)
     {
      /* Check to see if tag no. could be obtained from mac_tag_no dir */
      sprintf(
              mac_tag_entry, 
              "%s!%s!%s",
              refresh->rev_catalog,
              refresh->rev_partid,
              refresh->rev_revision
             );

      /* Construct path to mac_tag_no directory */
      di$give_pathname(
                       osnum = osnum,
                       pathname = mac_tag_dir
                      );

      strcat(mac_tag_dir,":");
      strcat(mac_tag_dir,"PDU");
      strcat(mac_tag_dir,":");
      strcat(mac_tag_dir,"mac_tag_no");

      /* Get the mac tag value for the part */
      status = di$find(
                       start_dir = mac_tag_dir,
                       regexp = "*",
                       lines = &mac_tags,
                       grids = NULL,
                       ptr = &mac_entry_count,
                       max_level = 1,
                       deep = NULL,
                       options = NULL
                      );

      if (mac_entry_count == 0)
         {
          _pdm_debug("no mac tag entries found", 0);
 
          /* Generate tag no. the old way */
          di$give_pathname(
                           osnum = osnum,
                           pathname = tag_dir
                          );

          strcat(tag_dir,":");
          strcat(tag_dir,"PDU");
          strcat(tag_dir,":");
          strcat(tag_dir,"tag_no");

          /* Check to see if tag seed exists */
          status = di$ls(regexp = tag_dir, ptr = &count);

          if (count == 0)
          /* Need to create a tag seed */
            {
             _pdm_debug("tag seed will be created", 0);
             strcat(tag_dir, ":");
             strcat(tag_dir, "1");
             strcat(tag_dir, ":");
             status = di$mkpath(pathname = tag_dir);
             _pdm_status("di$mkpath", status);

             PDUfill_in_string(tag_value, "1");

             return(PDM_S_SUCCESS);
            }

          else
              {
               status = DIstmocpy(dir_path, "PDU", "tag_no", "", NULL, osnum);
               if ( 1&status )
                  {
                   /* Get the tag value for the part */
                   status = di$find(
                                    start_dir = dir_path,
                                    regexp = "*",
                                    lines = &tags,
                                    grids = NULL,
                                    ptr = &entry_count,
                                    max_level = 1,
                                    deep = NULL,
                                    options = NULL
                                   );

                   if (status == DIR_S_SUCCESS)
                      {
                       status = PDUextract_dir_value(
                                                     tags[0],
                                                     "tag_no",
                                                     tag_value
                                                    );
                       if (status == PDM_S_SUCCESS)
                          {
                           _pdm_debug("extracted tag value = <%s>", *tag_value);

                           /* Free up tags  and entry_count */
                           di$free (lines = tags, count = entry_count);
                         }
                      }
                  }
              }

          return(status);
         }

      else
          {
           _pdm_debug("%d mac tag entries were found", mac_entry_count);

           /* Loop thru looking for a matching mac tag entry */
           for (i = 0; i < mac_entry_count; ++i)
               {
                /* Get rid off ":" at end of entry */
                PDUstrip_dir_entry(mac_tags[i]);

                tmp_mac_tag_entry = (IGRchar *)strchr(mac_tags[i], '!');
                ++tmp_mac_tag_entry;

                mac_tag_value = (IGRchar *)strrchr(mac_tags[i], '!');
                ++mac_tag_value;

                *((IGRchar *)strrchr(mac_tags[i], '!')) = '\0';

                /* Check if there is a match */
                if (strcmp(mac_tag_entry, tmp_mac_tag_entry) == 0)
                   {
                    _pdm_debug("match was found", 0);
                    PDUfill_in_string(tag_value, mac_tag_value);

                    /* Free up mac_tags  and mac_entry_count */
                    di$free (lines = mac_tags, count = mac_entry_count);

                    return(PDM_S_SUCCESS);
                   }
                
               } /* end for i loop */

            /* Free up mac_tags  and mac_entry_count */
            di$free (lines = mac_tags, count = mac_entry_count);
          }
     }

  /* Get tag number from object space */
  di$give_pathname(
                   osnum = osnum,
                   pathname = tag_dir
                  );

  strcat(tag_dir,":");
  strcat(tag_dir,"PDU");
  strcat(tag_dir,":");
  strcat(tag_dir,"tag_no");

  /* Check to see if tag seed exists */
  status = di$ls(regexp = tag_dir, ptr = &count);

  if (count == 0)
  /* Need to create a tag seed */
    {
     _pdm_debug("tag seed will be created", 0);
     strcat(tag_dir, ":");
     strcat(tag_dir, "1");
     strcat(tag_dir, ":");
     status = di$mkpath(pathname = tag_dir);
     PDUfill_in_string(tag_value, "1");

     return(PDM_S_SUCCESS);
    }

  status = DIstmocpy(dir_path, "PDU", "tag_no", "", NULL, osnum);
  if ( 1&status )
     {
       /* Get the tag value for the part */
       status = di$find(
                        start_dir = dir_path,
                        regexp = "*",
                        lines = &tags,
                        grids = NULL,
                        ptr = &entry_count,
                        max_level = 1,
                        deep = NULL,
                        options = NULL
                       );

       if (status == DIR_S_SUCCESS) 
          {
           status = PDUextract_dir_value(tags[0], "tag_no", tag_value);
           if (status == PDM_S_SUCCESS)
              {
               _pdm_debug("extracted tag value = <%s>", *tag_value);

               /* Free up tags  and entry_count */
               di$free (lines = tags,count = entry_count);
              }
          }
     }

  return (status);
  }

/*
 * This function generates a part child number.
 */ 

IGRint	PDUgenerate_child_no (child_value,osnum)

 IGRchar        **child_value;       /* OUTPUT */
 OMuword        osnum;               /* INPUT */
 {
  IGRint	status = PDM_S_SUCCESS;	
  IGRint        count = 0;
  IGRint        entry_count;	
  IGRchar       dir_path[DI_PATH_MAX];
  IGRchar       child_dir[DI_PATH_MAX];
  IGRchar       **children; 

  _pdm_debug("In the function PDUgenerate_child_no", 0);

  /* Get child number seed from object space */
  di$give_pathname(
                   osnum = osnum,
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
     PDUfill_in_string(child_value, "1");

     return(PDM_S_SUCCESS);
    }

  status = DIstmocpy(dir_path, "PDU", "child_no", "", NULL, osnum);
  if ( 1&status )
     {
       /* Get the child value for the part */
       status = di$find(
                        start_dir = dir_path,
                        regexp = "*",
                        lines = &children,
                        grids = NULL,
                        ptr = &entry_count,
                        max_level = 1,
                        deep = NULL,
                        options = NULL
                       );

       if (status == DIR_S_SUCCESS) 
          {
           status = PDUextract_dir_value(
                                         children[0],
                                         "child_no",
                                         child_value
                                        );
           if (status == PDM_S_SUCCESS)
              {
               /* Free up children  and entry_count */
               di$free (lines = children, count = entry_count);
               status = PDM_S_SUCCESS; 
              }
          }
     }
  return (status);
  }

/*
 * This function increments the tag number seed.
 */

IGRint	PDUincrement_tag_no (osnum)

 OMuword        osnum;            /* INPUT */
 {
  IGRint	status = PDM_S_SUCCESS;	
  IGRchar       new_tag[DI_PATH_MAX];
  IGRint        cnt;
  IGRchar       dir_path[DI_PATH_MAX];
  IGRchar       *tag_value = NULL; 

  _pdm_debug("In the function PDUincrement_tag_no", 0);

  status = DIstmocpy(dir_path, "PDU", "tag_no", "", NULL, osnum);
  if ( 1&status )
     {
       /* Get the tag seed value for the part */
       PDUgenerate_tag_no(&tag_value, osnum);
       _pdm_debug("tag_value = <%s>", tag_value);

       /* Remove tag seed directory */
       _pdm_debug("removing old tag dir", 0);
       di$rmdir(dirname = tag_value, path = dir_path);

       /* Increment tag value */
       sscanf(tag_value, "%d", &cnt);
       ++cnt;

       /* Back to string again */
       sprintf(new_tag, "%d", cnt);
       _pdm_debug("new tag = <%s>", new_tag);

       /* Create the new tag seed */
       DIstrcat(dir_path, new_tag);
       strcat(dir_path, ":");
       _pdm_debug("new tag path = <%s>", dir_path);
       di$mkpath(pathname = dir_path);
     }
  return (status);
  }

/*
 * This function increments the child number seed.
 */

IGRint	PDUincrement_child_no (osnum)

 OMuword        osnum;            /* INPUT */
 {
  IGRint	status = PDM_S_SUCCESS;	
  IGRchar        new_child[DI_PATH_MAX];
  IGRint        cnt;
  IGRchar       dir_path[DI_PATH_MAX];
  IGRchar       *child_value = NULL; 

  _pdm_debug("In the function PDUincrement_child_no", 0);

  status = DIstmocpy(dir_path, "PDU", "child_no", "", NULL, osnum);
  if ( 1&status )
     {
       /* Get the child seed value for the part */
       PDUgenerate_child_no(&child_value, osnum);
       _pdm_debug("child_value = <%s>", child_value);

       /* Remove child seed directory */
       _pdm_debug("removing old child dir", 0);
       di$rmdir(dirname = child_value, path = dir_path);

       /* Increment child value */
       sscanf(child_value, "%d", &cnt);
       ++cnt;

       /* Back to string again */
       sprintf(new_child, "%d", cnt);
       _pdm_debug("new child = <%s>", new_child);

       /* Create the new child seed */
       DIstrcat(dir_path, new_child);
       strcat(dir_path, ":");
       _pdm_debug("new child path = <%s>", dir_path);
       di$mkpath(pathname = dir_path);
     }
  return (status);
  }

/*
 * This function displays GRparts.
 */
 
IGRint	PDUdisplay_GRpart ( 
                           part_id,
                           display_flag
                          )

  struct GRid            part_id;
  IGRshort		 display_flag;
  {
  IGRlong         status;
  IGRlong	  msg;
  struct GRid     part[1];
  enum   GRdpmode display_mode = GRbd;

  _pdm_debug("In the PDUdisplay_GRpart function",0);

  /* Display a graphic object */
  if (display_flag  == 1)
     {
      display_mode = GRbd;
     }

  if (display_flag  == 0)
  /* Erase a graphic object */
     {
      display_mode = GRbe;
     }

  if (display_flag  == 2)
  /* Erase a graphic object in highlight */
     {
      display_mode = GRhe;
     }

  if (display_flag  == 3)
  /* Draw in both background and highlight */
     {
      display_mode = GRbdhd;
     }

  if (display_flag  == 4)
  /* Erase from both background and highlight */
     {
      display_mode = GRbehe;
     }

  if (display_flag  == 5)
  /* Erase from  background and draw in highlight */
     {
      display_mode = GRbehd;
     }

  part[0].objid = part_id.objid;
  part[0].osnum = part_id.osnum;

  status = dp$display (
                        msg = &msg,
			mode = display_mode,
			oids = part
		      );
  return (PDM_S_SUCCESS);
  }

/*
 * This function graphically attaches a reference file to a GRpart.
 */

IGRint	PDUattach_ref_to_GRpart (
                                 mod_env,              /* module environment */
                                 part_id,	       /* GRpart's id */ 
                                 placement_matrix,     /* placement matrix */
                                 view_name,            /* view name */
                                 file_name,            /* file name */
                                 catalog_no,           /* catalog no */
                                 item_no,              /* item no */
                                 display,              /* display ref. ? */
                                 drawing,              /* if drawing part */
                                 background,           /* if background */
                                 rot_matrix,           /* rotation matrix */
                                 origin,               /* drawing view origin */
                                 cs_id,                /* coosr sys id */
                                 refobj                /* ref. obj. id */
                                )
  struct GRmd_env *mod_env;             /* INPUT */
  struct GRid     part_id;		/* INPUT */
  IGRmatrix       placement_matrix;	/* INPUT */
  IGRchar         *view_name;           /* INPUT */
  IGRchar         *file_name;           /* INPUT */
  IGRchar         *catalog_no;          /* INPUT */
  IGRchar         *item_no;             /* INPUT */
  IGRshort        display;              /* INPUT */
  IGRshort        drawing;              /* INPUT */
  IGRshort        background;           /* INPUT */
  IGRmatrix       rot_matrix;           /* INPUT */
  IGRpoint        origin;               /* INPUT */
  struct GRid     *cs_id;               /* INPUT */
  struct GRid	  *refobj;              /* OUTPUT */
  
 {
  IGRlong	                   status = PDM_S_SUCCESS;
  IGRint	                   object_num = 1;
  IGRint	                   own_index[1];
  IGRint                           i;
  IGRshort                         on_off_flag;
  IGRshort                         ActiveLevel;
  IGRlong                          msg = PDM_S_SUCCESS;
  IGRlong                          NumberOfBytes, BytesReceived;
  IGRint                           levels[32];
  IGRint                           ref_count = 0;
  IGRint                           size;
  IGRchar                          description[DI_PATH_MAX];
  IGRchar                          ref_filename[DI_PATH_MAX];
  IGRint                           ref_prop;
  IGRshort                         properties;
  IGRboolean                       pass_on;
  struct IGRlbsys	           lbs_geom;
  struct GRrf_info	           rf_info;
  struct GRobj_env	           objects[1];
  struct IGRdisplay                ActiveDisplay;
  struct GRvg_construct            attachment;
  struct GRid                      dv_id;
  struct PDUid                     *ref_objects;
  struct GRinquire_list            ref_list[2];
  IGRshort                         free_mod = FALSE;
  IGRint                           bufsiz;
  extern short  PDU_clipping_on;
  

  _pdm_debug("In PDUattach_ref_to_GRpart function", 0 );

  _pdm_debug("part_id.objid = %d", part_id.objid);
  _pdm_debug("part_id.osnum = %d", part_id.osnum);
  _pdm_debug("catalog no at entry = <%s>", catalog_no);
  _pdm_debug("item no at entry = <%s>", item_no);

  _pdm_debug("placement matrix:",0);
  PDUdump_matrix(placement_matrix);

  /* Default module env. to current if mod_env is NULL */
  if (!mod_env)
    {
     mod_env = (struct GRmd_env *) malloc(sizeof(struct GRmd_env));
     bufsiz = sizeof(struct GRmd_env);
     gr$get_module_env(sizbuf = &bufsiz, buffer = mod_env);
     free_mod = TRUE;
    }

  /* Get active level */
  NumberOfBytes = sizeof(IGRshort);
  status = gr$get_active_level (
                                msg = &msg,
                                sizbuf = &NumberOfBytes,
                                buffer = &ActiveLevel,
                                nret = &BytesReceived 
                               );

  /* Get active display */
  NumberOfBytes = sizeof(struct IGRdisplay);
  status = gr$get_active_display (
                                  msg = &msg,
                                  sizbuf = &NumberOfBytes,
                                  buffer = &ActiveDisplay,
                                  nret = &BytesReceived 
                                 );

  /* Initialize structures used to construct a ref. file object */
  attachment.msg        = &msg;
  attachment.env_info   = mod_env;
  attachment.display    = &ActiveDisplay;
  attachment.level      = ActiveLevel;
  attachment.properties = GRIS_NEW | GRIS_LOCATABLE | GRIS_DISPLAYABLE; 
  attachment.newflag    = FALSE;
  attachment.name       = NULL;

  if (!display)
     attachment.properties &= ~GRIS_DISPLAYABLE;

  /* Copy placement matrix into lbs */
  for (i = 0; i < 16; ++i) 
      {
       lbs_geom.matrix[i] = placement_matrix[i];
      }

  /* lbs diagonals are design file limits */
  lbs_geom.diag_pt1[0] = GRDGNLIMITS_MIN_D;
  lbs_geom.diag_pt1[1] = GRDGNLIMITS_MIN_D;
  lbs_geom.diag_pt1[2] = GRDGNLIMITS_MIN_D;
  lbs_geom.diag_pt2[0] = GRDGNLIMITS_MAX_D;
  lbs_geom.diag_pt2[1] = GRDGNLIMITS_MAX_D;
  lbs_geom.diag_pt2[2] = GRDGNLIMITS_MAX_D;

  /* A local bounded system is required for reference file attachment */
  attachment.geometry = (IGRchar *) &lbs_geom;

  /* Set up structures for reference file object construction */
  attachment.class_attr = (IGRchar *) &rf_info;

  /* Construct ref. description */
  sprintf(description, "PDU:%s:%s:%s", catalog_no, item_no, file_name);

  if (background)
     ref_prop = GRRF_SAVED_VIEW_USED | GRIS_TEMPORARY | GRRF_BACKGROUND;
 
  else
      ref_prop = GRRF_SAVED_VIEW_USED | GRIS_TEMPORARY;

  rf_info.filename = file_name;
  rf_info.named_view = view_name;
  rf_info.description = description;
  rf_info.ref_properties = (IGRuint *)&ref_prop;
  rf_info.prism_classname = NULL;
  rf_info.clip_poly = NULL;
  rf_info.scale = "1";

  _pdm_debug("file_name = <%s>", file_name);
  _pdm_debug("view_name = <%s>", view_name);

  refobj->osnum = part_id.osnum;
  refobj->objid = part_id.objid;

  /* Make attachment file writable */
  /* ALR  1/19/94  TR139313379 & 139311051 */
  GRforce_writable(&msg, file_name, NULL);
  _pdm_status("GRforce_writable", msg);

  /* Check to see if attachment type is drawing */
  if (drawing)
     {
      properties = GRIS_NEW | GRIS_LOCATABLE | GRIS_DISPLAYABLE;

      if (!display)
         properties &= ~GRIS_DISPLAYABLE; 

      if (background)
         ref_prop = GRIS_MODEL_ATTACHMENT | GRRF_BACKGROUND;

      else
          ref_prop = GRIS_MODEL_ATTACHMENT;

      status = GRconstruct_dv(
                              &msg,
                              mod_env,
                              properties,
                              &ActiveDisplay,
                              ActiveLevel,
                              view_name,
                              "Drawing Main View",
                              NULL,
                              &rf_info,
                              "GRdrawview",
                              rot_matrix,
                              origin,
                              NULL,
                              &dv_id,
                              cs_id
                             ); 
      _pdm_status("GRconstruct_dv", status);

      if (status & msg & 1)
         status = PDM_S_SUCCESS;

      else
          {
           _pdm_debug("GRconstruct_dv failed", 0);
           return(status);
          }
     }

  else
      {
       /* Construct regular reference file attachment object */
       status = om$construct (
                              classname = "GRreffile", 
                              p_objid = &(refobj->objid),
	        	      msg = message GRgraphics.GRconstruct(&attachment),
	     		      osnum = refobj->osnum 
                             );
       _pdm_rstatus2 (
                      "om$construct (GRconstruct) of GRreffile",
     	              status, *(attachment.msg)
                     );

       if ( ( 1&status ) && ( *(attachment.msg) == MSSUCC ) )
          {
           _pdm_debug("ref. attachment successful", 0);
           status = PDM_S_SUCCESS;
          }

       else
           {
            if ( *(attachment.msg) == GRFILENOTFOUND )
               status = PDM_E_FILE_NOT_FOUND;
            else if ( *(attachment.msg) == GRVIEWNOTFOUND )
               status = PDM_E_VIEW_NOT_FOUND;
            else if ( (*(attachment.msg) == MSFAIL) && (status == OM_E_ABORT) )
               status = PDM_E_VIEW_NOT_FOUND;
           }
      }

  if (status == PDM_S_SUCCESS)
     {
      /* Add constructed ref. object to GRpart */
      if (drawing)
         {
          objects[0].obj_id.objid = dv_id.objid;
          objects[0].obj_id.osnum = dv_id.osnum;
         }

      else
          {
           objects[0].obj_id.objid = refobj->objid;
           objects[0].obj_id.osnum = refobj->osnum;
          }

      /* Make ref. file attachment shrink-wrap */
      _pdm_debug("calling GRrfshwr", 0);
      if (!PDU_clipping_on)
        GRrfshwrclip(&msg, &(objects[0].obj_id));
      objects[0].mod_env = *mod_env;
      own_index[0] = PDU_K_MAXINT;

      status = om$send (
                        msg = message GRowner.GRadd_components
                                             (
                                              &msg,
		                              mod_env,
                                              &object_num,
			                      objects,
                                              own_index,
                                              NULL
                                             ),
		        senderid = part_id.objid,
			targetid = part_id.objid,
		        targetos = part_id.osnum 
                      );
      _pdm_rstatus2 ("GRowner.GRadd_components (GRpart-->GRreffile)",
		        status, msg);

      if ( 1&status ) 
         {
            if (drawing)
               {
                /* Get all ref. file objects */
                status = PDUget_reffile_objects(
                                                mod_env->md_id.osnum,
                                                &ref_objects,
                                                &ref_count
                                               );
                _pdm_status("PDUget_reffile_objects", status);

                if (ref_count <= 0)
                   {
                    _pdm_debug("SEVERE error: no ref file objects found", 0);
                    return(status);
                   }

                /* Set ref. request */
                ref_list[0].var = REFERENCE_FILE_NAME;
                ref_list[0].var_ptr = ref_filename;
                ref_list[0].num_requested = DI_PATH_MAX;
                ref_list[1].var = END_REPORT_REQUEST;
                pass_on = FALSE;
                size = sizeof(DI_PATH_MAX);

                /* Loop thru extracting ref. file names */
                for (i = 0; i < ref_count; ++i)
                    {
                      _pdm_debug("calling GRreffile.GRinquireref", 0);

                      status = om$send(
                                       msg = message GRreffile.GRinquireref
                                                              (
                                                               &msg,
                                                               mod_env,
                                                               ref_list,
                                                               &size,
                                                               &pass_on,
                                                               NULL 
                                                              ),
                                       senderid = mod_env->md_id.objid,
                                       targetid = ref_objects[i].objid,
                                       targetos = ref_objects[i].osnum
                                      );

                     _pdm_debug("extracted ref. file = <%s>", ref_filename);

                     /* Find obj id of drawing ref file */
                     if (strcmp(ref_filename, file_name) == 0)
                        {
                         _pdm_debug("a ref match was found", 0);
                         break;
                        }

                    } /* end for loop */

                _pdm_debug("drawing ref. id = %d", ref_objects[i].objid);
              
                /* Turn off part pointer in drawing ref. attachment */
                on_off_flag = 0;
                PDUsetlevels(levels);
                status = om$send (
                                  msg = message GRreffile.GRchglevels
                                                         (
                                                          &msg,
                                                          &on_off_flag,
                                                          levels
                                                         ),
                                  senderid = part_id.objid,
                                  targetid = ref_objects[i].objid,
                                  targetos = ref_objects[i].osnum 
                                 );
                _pdm_rstatus2("GRreffile.GRchglevels (off)", status, msg);

                if (1&status)
                   {
                    /*refobj->objid = dv_id.objid; 
                    refobj->osnum = dv_id.osnum; */
                    refobj->objid = ref_objects[i].objid;
                    refobj->osnum = ref_objects[i].osnum;

                    status = PDM_S_SUCCESS;
                   }

                else
                    {
                     _pdm_debug("GRreffile.GRchglevels (off) failed", 0);
                    }

               }

           else
               {
                /* Turn off part pointer in ref. attachment */
                on_off_flag = 0;
                PDUsetlevels(levels);
                status = om$send (
                                  msg = message GRreffile.GRchglevels
                                                         (
                                                          &msg,
                                                          &on_off_flag,
                                                          levels
                                                         ),
                                  senderid = part_id.objid,
                                  targetid = refobj->objid,
                                  targetos = refobj->osnum
                                 );
                _pdm_rstatus2("GRreffile.GRchglevels (off)", status, msg);

                if (1&status)
                   {
                    status = PDM_S_SUCCESS;
                   }

                else
                    {
                     _pdm_debug("GRreffile.GRchglevels (off) failed", 0);
                    }
               }
         }

        else
           {
            _pdm_debug("GRowner.GRadd_components failed", 0);
           }
	}

     else
	{
         _pdm_debug("graphical attachment failed", 0);
	}

  /* Free up variables */
  if (free_mod)
     {
      free(mod_env);
      mod_env = NULL;
     }

  return (status);
 }


/*
 * This function graphically aligns a GRpart.
 */

IGRint	PDUalign_GRpart (
                         src_alignment_matrix,  /* source matrix */ 
                         dst_alignment_matrix,  /* destination matrix */
                         src_objid,             /* source obj id */
                         mod_env                /* module environment */ 
                        )
  IGRmatrix	src_alignment_matrix;   	/* INPUT */
  IGRmatrix     dst_alignment_matrix;		/* INPUT */
  struct GRid   src_objid;                      /* INPUT */
  struct GRmd_env mod_env;                      /* INPUT */
  
 {

  struct PDUpoint    origin1;
  struct PDUpoint    origin2;
  struct PDUpoint    sys1_pt2;
  struct PDUpoint    sys1_pt3;
  struct PDUpoint    sys2_pt2;
  struct PDUpoint    sys2_pt3;
  struct GRid        new_id;
  struct GRevent     event[6];
  struct GRevent     *events[6];
  IGRlong            sts, msg;
  IGRlong            status;
  IGRshort           matrix_type;
  IGRmatrix          align_matrix;
  IGRint             four = 4;
  
  _pdm_debug("In PDUalign_GRpart function",0);
 
  /* Extract the origin of source alignment */
  status = PDUmatrix_to_point (
                               src_alignment_matrix,
                               &origin1
                              );
 
  /* Need to find x-axis point and y-axis points on first alignment */
  MAinvmx (
           &sts,
           &four,
           src_alignment_matrix,
           src_alignment_matrix
          );

  status = PDUadd_points (
                          src_alignment_matrix,
                          origin1,
                          &sys1_pt2,
                          0,
                          1,
                          2
                         );

  status = PDUadd_points (
                          src_alignment_matrix,
                          origin1,
                          &sys1_pt3,
                          4,
                          5,
                          6
                         );

  event[0].event.button.x = origin1.x;
  event[0].event.button.y = origin1.y;
  event[0].event.button.z = origin1.z;
  event[1].event.button.x = sys1_pt2.x;
  event[1].event.button.y = sys1_pt2.y;
  event[1].event.button.z = sys1_pt2.z;
  event[2].event.button.x = sys1_pt3.x;
  event[2].event.button.y = sys1_pt3.y;
  event[2].event.button.z = sys1_pt3.z;
  events[0] = &(event[0]);
  events[1] = &(event[1]);
  events[2] = &(event[2]);

  /* Extract the origin of destination alignment */
  status = PDUmatrix_to_point (
                               dst_alignment_matrix,
                               &origin2
                              );
 
  /* Need to find 2nd and 3rd points on destination alignment */
  MAinvmx (
           &sts,
           &four,
           dst_alignment_matrix,
           dst_alignment_matrix
          );

  status = PDUadd_points (
                          dst_alignment_matrix,
                          origin2,
                          &sys2_pt2,
                          0,
                          1,
                          2
                         );

  status = PDUadd_points (
                          dst_alignment_matrix,
                          origin2,
                          &sys2_pt3,
                          4,
                          5,
                          6
                         );

  event[3].event.button.x = origin2.x;
  event[3].event.button.y = origin2.y;
  event[3].event.button.z = origin2.z;
  event[4].event.button.x = sys2_pt2.x;
  event[4].event.button.y = sys2_pt2.y;
  event[4].event.button.z = sys2_pt2.z;
  event[5].event.button.x = sys2_pt3.x;
  event[5].event.button.y = sys2_pt3.y;
  event[5].event.button.z = sys2_pt3.z;
  events[3] = &(event[3]);
  events[4] = &(event[4]);
  events[5] = &(event[5]);

  /* Calculate alignment matrix */
  status = co$align_mx (
                        msg = &msg,
                        caller_id = mod_env.md_id.objid,
                        caller_os = mod_env.md_id.osnum,
                        events = events,
                        matrix = align_matrix
                       );

  /* Erase source GRpart object */
  status = PDUdisplay_GRpart(
                             src_objid,
                             0
                            );

  /* Move and rotate source GRpart around destination alignment */
  MAtypemx (
            &sts,
            align_matrix,
            &matrix_type
           );

  status = om$send (
                    msg = message GRgraphics.GRxform(
                                                     &sts,
                                                     &mod_env,
                                                     &matrix_type,
                                                     align_matrix,
                                                     &(new_id.objid)
                                                    ),
                    senderid = mod_env.md_id.objid,
                    targetid = src_objid.objid,
                    targetos = src_objid.osnum 
                   );

  if (1&status)
     {
      /* Display new and aligned GRpart */
      new_id.osnum = mod_env.md_id.osnum;
      status = PDUdisplay_GRpart(
                                 new_id,
                                 1
                                );

      status = PDM_S_SUCCESS;
     }

  return(status);
 }

/*
 * This function returns a list of 1st-level reference file objid's.
 */
IGRint  PDUget_reffile_objects(
                               osnum,
                               ref_objects,
                               ref_count 
                              )
 OMuword       osnum;			/* INPUT */
 struct PDUid  **ref_objects;		/* OUTPUT */
 IGRint        *ref_count;		/* OUTPUT */

{
 IGRint        status = PDM_S_SUCCESS;
 struct PDUid  ref_mgr;
 OM_S_CHANSELECT  refs;


 _pdm_debug("In the function PDUget_reffile_objects",0);

 ref_mgr.osnum = osnum;

 /* Get objid of reference file manager in object space */
 status =  ex$get_objid_from_NOD (
                                  NODname = "IGENOD",
                                  objname = REFERENCE_FILE_MANAGER,
                                  pobjid = &(ref_mgr.objid),
                                  mod_osnum = ref_mgr.osnum 
                                 );
 _pdm_rstatus ("ex$get_objid_from_NOD", status);

 if ( 1&status )
    {
     _pdm_debug ("ref_mgr objid = %d", ref_mgr.objid);
     
     /* Construct Super_rfmgr.mgr channel */
     status = om$make_chanselect (
                                  channame = "Super_rfmgr.mgr",
                                  p_chanselect = &refs
                                 );
     _pdm_status ("om$make_chanselect", status);

     if ( 1&status )
        {
        /* Get count of reference file attachments */
        status = om$get_channel_count (
                                       objid = ref_mgr.objid,
                                       osnum = ref_mgr.osnum,
                                       p_chanselect = &refs,
                                       count = (OMuint *)ref_count
                                      );
        _pdm_status ("om$get_channel_count", status);
        _pdm_debug("channel_count for ref objects is %d", *ref_count);
       
        *ref_objects = (struct PDUid *) malloc ( sizeof(struct PDUid) *
                                           *ref_count );
        /* Get ref. file objects */ 
        status = PDUget_objects (&ref_mgr, &refs, *ref_objects, ref_count);
        _pdm_status ("PDUget_objects", status);
        }
    }

 return(status);
}


/*
 * This function returns a list of all reference file objid's.
 */
IGRint  PDUget_all_reffile_objects(
                                   osnum,
                                   include_nth_level,
                                   ref_list
                                  )
 OMuword                     osnum;             /* INPUT */
 IGRshort                    include_nth_level; /* INPUT */
 struct PDUnth_ref_objects   **ref_list;        /* OUTPUT */
{
 IGRint        status = PDM_S_SUCCESS;
 IGRlong       msg = MSSUCC;
 struct PDUid  ref_mgr;
 IGRchar       ref_dir[DI_PATH_MAX];
 IGRchar       **entries;
 IGRchar       *seq_no = NULL;
 IGRint        entry_count = 0;
 IGRint        ref_count = 0;
 IGRint        i, j;
 IGRshort      flag;
 OMuword       current_osnum;
 IGRchar       ref_descr[DI_PATH_MAX];
 struct PDUid  *ref_objects;     
 OM_S_CHANSELECT  refs;
 struct PDUnth_ref_objects   *tail = NULL;
 struct PDUnth_ref_objects   *temp = NULL;


 _pdm_debug("In the function PDUget_all_reffile_objects",0);

 ref_mgr.osnum = osnum;

 /* Get objid of reference file manager in active object space */
 status =  ex$get_objid_from_NOD (
                                  NODname = "IGENOD",
                                  objname = REFERENCE_FILE_MANAGER,
                                  pobjid = &(ref_mgr.objid),
                                  mod_osnum = ref_mgr.osnum
                                 );
 _pdm_rstatus ("ex$get_objid_from_NOD", status);

 if ( 1&status )
    {
     _pdm_debug ("ref_mgr objid in active space = %d", ref_mgr.objid);

     /* Construct Super_rfmgr.mgr channel */
     status = om$make_chanselect (
                                  channame = "Super_rfmgr.mgr",
                                  p_chanselect = &refs
                                 );
     _pdm_status ("om$make_chanselect", status);

     if ( 1&status )
        {
        /* Get count of reference file attachments */
        status = om$get_channel_count (
                                       objid = ref_mgr.objid,
                                       osnum = ref_mgr.osnum,
                                       p_chanselect = &refs,
                                       count = (OMuint *)&ref_count
                                      );
        _pdm_status ("om$get_channel_count", status);
        _pdm_debug("channel_count for ref objects is %d", ref_count);

        if (ref_count <= 0)
           {
            _pdm_debug("osnum %d has no ref files", ref_mgr.osnum);
            return(PDM_S_SUCCESS);
           }

        ref_objects = (struct PDUid *) malloc ( sizeof(struct PDUid) *
                                           ref_count );
        /* Get ref. file objects */
        status = PDUget_objects (&ref_mgr, &refs, ref_objects, &ref_count);
        _pdm_status ("PDUget_objects", status);

        _pdm_debug("ref count = %d", ref_count);

        /* Add 1st-level ref. objids to link list */
        if (ref_count > 0)
           {
            for (i = 0; i < ref_count; ++i)
                {
                 /* Make sure it is a PDU attachment */
                 flag = 0;
                 status = om$send(
                                  msg = message GRreffile.GRgetdescription
                                     ( &msg, &flag, ref_descr ),
                                  senderid = ref_mgr.objid,
                                  targetos = ref_objects[i].osnum,
                                  targetid = ref_objects[i].objid 
                                 );
                 _pdm_status2 ("GRreffile.GRgetdescription", status, msg);
                 _pdm_debug ("reffile description = <%s>", ref_descr );

                 if ( (1&status) && (strcmp(ref_descr, "") != 0) ) 
                    {
                     if (strrchr(ref_descr, ':') == NULL)
                        {
                         _pdm_debug("encountered a non PDU ref file", 0);
                         continue;
                        }

                     /* Extract sequence number from description */
                     PDUfill_in_string(&seq_no, ref_descr);
                     *((IGRchar *)strchr(seq_no, ':')) = '\0';

                     _pdm_debug("sequence no = <%s>", seq_no);

                     /* Create a node */
                     temp = (struct PDUnth_ref_objects *)
                                      malloc(sizeof(struct PDUnth_ref_objects));

                     /* Load temp fields */
                     temp->obj_id.objid = ref_objects[i].objid;
                     temp->obj_id.osnum = ref_objects[i].osnum;
                     temp->level = 1;
                     temp->seq_no = NULL;
                     PDUfill_in_string(&(temp->seq_no), seq_no);
                     temp->next = NULL;

                     /* Add node to list */
                     if (*ref_list)
                        {
                         /* Get to the end of list */
                         tail = *ref_list;
                         while (tail->next)
                               {
                                tail = tail->next;
                               }

                         /* Add part to ref link list */
                         _pdm_debug("adding a node to end of link list", 0);

                         tail->next = temp;
                        }
    
                     else
                        {
                         /* This is the first node in the list */
                         _pdm_debug("adding a node as the first node", 0);

                         *ref_list = temp;
                        }
                    } 

                } /* end for i loop */
           }

        else
            {
             _pdm_debug("no ref. attachments were found", 0);
             return(PDM_S_SUCCESS);
            }

        /* Construct file path */
        di$give_pathname(osnum = osnum, pathname = ref_dir);

/* MJG 2/5/96 Should we be using refnames instead of just ref?
        strcat(ref_dir, ":ref:refnames");
*/

        strcat(ref_dir, ":ref");

        status = di$find(
                         start_dir = ref_dir,
                         regexp = "*",
                         lines = &entries,
                         ptr = &entry_count,
                         max_level = 1
                        );

        if ( (status != DIR_S_SUCCESS) || (entry_count <= 0) )
           {
            _pdm_debug("no ref directory found", 0);
            return(PDM_S_SUCCESS);
           }

        /* Process nth-level ref. attachments */
        if ( (entry_count > 0) && (include_nth_level) )
           {
            for (i = 1; i < entry_count; ++i)
                {
                 _pdm_debug("ref entry = <%s>", entries[i]);
                 *((IGRchar *)strrchr(entries[i],':')) = '\0';

                 /* Get osnum of ref. entry */
                 di$give_osnum(pathname = entries[i], p_osnum = &current_osnum);
                 _pdm_debug("current osnum = %d", current_osnum);

                 ref_mgr.osnum = current_osnum;

                 /* Get objid of ref file manager in active object space */
                 status =  ex$get_objid_from_NOD (
                                               NODname = "IGENOD",
                                               objname = REFERENCE_FILE_MANAGER,
                                               pobjid = &(ref_mgr.objid),
                                               mod_osnum = ref_mgr.osnum
                                                 );
                 _pdm_rstatus ("ex$get_objid_from_NOD", status);

                 if (1&status)
                    {
                     _pdm_debug ("ref_mgr objid in ref. obj. space = %d",
                                  ref_mgr.objid);

                     /* Get count of reference file attachments */
                     ref_count = 0;
                     status = om$get_channel_count (
                                                    objid = ref_mgr.objid,
                                                    osnum = ref_mgr.osnum,
                                                    p_chanselect = &refs,
                                                    count = (OMuint *)&ref_count
                                                   );
                     _pdm_status ("om$get_channel_count", status);
                     _pdm_debug("channel_count for ref objects is %d",
                                                                    ref_count);
                     if (ref_count <= 0)
                        {
                         _pdm_debug("osnum %d has no ref files", ref_mgr.osnum);
                         continue;
                        }

                     ref_objects = (struct PDUid *)
                                   malloc ( sizeof(struct PDUid) * ref_count );

                     /* Get ref. file objects */
                     status = PDUget_objects (
                                              &ref_mgr,
                                              &refs, 
                                              ref_objects,
                                              &ref_count
                                             );
                     _pdm_status ("PDUget_objects", status);

                     /* Add 1st-level ref. objids to link list */
                     if (ref_count > 0)
                        {
                         for (j = 0; j < ref_count; ++j)
                             {
                              /* Make sure it is a PDU attachment */
                              flag = 0;
                              status = om$send
                                       (
                                        msg = message GRreffile.GRgetdescription
                                                   ( &msg, &flag, ref_descr ),
                                        senderid = ref_mgr.objid,
                                        targetos = ref_objects[j].osnum,
                                        targetid = ref_objects[j].objid
                                       );
                              _pdm_status2 ("GRreffile.GRgetdescription",
                                             status, msg);
                              _pdm_debug ("reffile description = <%s>",
                                          ref_descr );

                              if ( (1&status) && (strcmp(ref_descr, "") != 0) )
                                 {
                                  if (strrchr(ref_descr, ':') == NULL)
                                     {
                                      _pdm_debug(
                                               "encountered a non PDU ref file",
                                               0
                                                );
                                      continue;
                                     }

                                  /* Extract sequence number from description */
                                  PDUfill_in_string(&seq_no, ref_descr);
                                  *((IGRchar *)strchr(seq_no, ':')) = '\0';

                                  _pdm_debug("sequence no = <%s>", seq_no);

                                  /* Create a node */
                                  temp = (struct PDUnth_ref_objects *)
                                      malloc(sizeof(struct PDUnth_ref_objects));

                                  /* Load temp fields */
                                  temp->obj_id.objid = ref_objects[j].objid;
                                  temp->obj_id.osnum = ref_objects[j].osnum;
                                  temp->level = i + 1;
                                  temp->seq_no = NULL;
                                  PDUfill_in_string(&(temp->seq_no), seq_no);

                                  temp->next = NULL;

                                  /* Add node to list */
                                  if (*ref_list)
                                     {
                                      /* Get to the end of list */
                                      tail = *ref_list;
                                      while (tail->next)
                                            {
                                             tail = tail->next;
                                            }

                                      /* Add part to ref link list */
                                      tail->next = temp;
                                     }

                                  else
                                     {
                                      /* This is the first node in the list */
                                      *ref_list = temp;
                                     }
                                 }

                             } /* end for j loop */
                        }
                    }

                else
                    {
                     _pdm_debug("osnum %d has no ref files", ref_mgr.osnum);
                     continue;
                    }

                } /* end i for loop */

            /* Free entries */
            di$free(lines = entries, count = entry_count);

            if (seq_no)
               free(seq_no);
           }
         
        }
    }

 else
     {
      _pdm_debug("osnum %d has no ref files", ref_mgr.osnum);
      return(PDM_S_SUCCESS);
     }

 return(PDM_S_SUCCESS);
}

/*
 * This function returns a list of coord. sys objid's.
 */
IGRint  PDUget_coordsys_objects(
                                osnum,
                                coord_objects,
                                coord_count 
                               )
 OMuword       osnum;			/* INPUT */
 struct PDUid  **coord_objects;		/* OUTPUT */
 IGRint        *coord_count;		/* OUTPUT */

{
 IGRlong       msg = MSSUCC;
 IGRint        status = PDM_S_SUCCESS;
 struct PDUid  coord_mgr;
 OM_S_OBJID    osid = NULL_OBJID;
 OM_S_CHANSELECT  cschan;


 _pdm_debug("In the function PDUget_coordsys_objects",0);

 coord_mgr.osnum = osnum;

 /* Get objid of coordinate system manager in object space */
 status =  cs$get_mgr (
                       msg = &msg,
                       osnum = osnum,
                       module = osid,
                       csmgr = &(coord_mgr.objid)
                      );
 _pdm_rstatus ("cs$get_mgr", status);

 if ( 1&status )
    {
     _pdm_debug ("csmgr objid = %d", coord_mgr.objid);
     
     /* Construct cschan channel */
     status = om$make_chanselect (
                                  channame = PDU_OWNER_CHANNAME,
                                  p_chanselect = &cschan
                                 );
     _pdm_status ("om$make_chanselect", status);

     if ( 1&status )
        {
        /* Get count of coord sys */
        status = om$get_channel_count (
                                       objid = coord_mgr.objid,
                                       osnum = coord_mgr.osnum,
                                       p_chanselect = &cschan,
                                       count = (OMuint *)coord_count
                                      );
        _pdm_status ("om$get_channel_count", status);
        _pdm_debug("channel_count for coord sys objects is %d", *coord_count);
       
        *coord_objects = (struct PDUid *) malloc ( sizeof(struct PDUid) *
                                           *coord_count );
        /* Get ref. file objects */ 
        status = PDUget_objects (
                                 &coord_mgr,
                                 &cschan, 
                                 *coord_objects,
                                 coord_count
                                );
        _pdm_status ("PDUdir_get_objects", status);
        }
    }

 return(status);
}


/*
 * This function turns off all part pointers in the active object space.
 */
IGRint  PDUturn_off_part_pointers()
                               
{
 IGRlong       msg = MSSUCC;
 IGRint        status = PDM_S_SUCCESS;
 IGRint        i;
 IGRint        ref_count = 0;
 IGRint        coord_count = 0;
 IGRint        on_off_flag;
 GRobjid       csmgr;
 struct PDUid  *ref_objects;
 struct PDUid  *coord_objects;
 struct GRmd_env       ref_mod_env;
 struct GRmd_env mod_env;
 IGRlong          NumberOfBytes, BytesReceived;


 _pdm_debug("In the function PDUturn_off_part_pointers",0);

 /* Get active module environment */
 NumberOfBytes = sizeof(mod_env);
 status = gr$get_module_env(
                            msg = &msg,
                            sizbuf = &NumberOfBytes,
                            buffer = &mod_env,
                            nret = &BytesReceived
                           );


  /* Get ref. file objects in the active space */
  status = PDUget_reffile_objects(
                                  mod_env.md_id.osnum,
                                  &ref_objects,
                                  &ref_count
                                 );
  _pdm_debug("ref file obj found = %d", ref_count);

  if (ref_count <= 0)
     {
      _pdm_debug("no ref file objects found",0);
      return(status);
     }
          
  /* Loop in turning off part pointers */
  for (i = 0; i < ref_count; ++i)
         {
          /* Get the environment info from the ref file object */
          status = om$send(
                           msg = message GRreffile.GRgetenvironment
                                                  (
                                                    &msg,
                                                    &mod_env,
                                                    &ref_mod_env
                                                   ),
                               senderid = mod_env.md_id.objid,
                               targetid = ref_objects[i].objid,
                               targetos = ref_objects[i].osnum
                              );
              _pdm_rstatus2("GRreffile.GRgetenvironment", status, msg);

              if (! (( 1&status ) && ( msg == MSSUCC )) )
                 {
                  _pdm_debug("GRreffile.GRgetenvironment failed",0);
                  return(status);
                 }

              /* Get objid of coordinate system manager */
              status =  cs$get_mgr (
                                    msg = &msg,
                                    osnum = ref_mod_env.md_id.osnum,
                                    module = ref_mod_env.md_id.objid,
                                    csmgr = &csmgr
                                   );
              _pdm_rstatus ("cs$get_mgr", status);

              /* Turn off part pointers in reference file */
              status = om$send (
                                msg = message GRcsmgr.GRcstoggle_display
                                                  (
                                                   &msg,
                                                   &ref_mod_env,
                                                   &on_off_flag
                                                  ),
                               senderid = ref_mod_env.md_id.objid,
                               targetid = csmgr,
                               targetos = ref_mod_env.md_id.osnum
                              );
              _pdm_rstatus2("GRcsmgr.GRcstoggle_display", status, msg);

              if (on_off_flag == 1)
              {
               status = om$send (
                                 msg = message GRcsmgr.GRcstoggle_display
                                                  (
                                                   &msg,
                                                   &ref_mod_env,
                                                   &on_off_flag
                                                  ),
                                senderid = ref_mod_env.md_id.objid,
                                targetid = csmgr,
                                targetos = ref_mod_env.md_id.osnum
                               );
               _pdm_rstatus2("GRcsmgr.GRcstoggle_display", status, msg);
              }

              /* Extract coord sys objects in ref file */
              status = PDUget_coordsys_objects(
                                               ref_mod_env.md_id.osnum,
                                               &coord_objects,
                                               &coord_count
                                              );
              if (coord_count <= 0)
                 {
                  _pdm_debug("no coord sys objects found", 0);
                  return(status);
                 }

              /* Loop in erasing all coord sys */
              _pdm_debug("ref_mod_env.md_id.osnum = %d", 
                          ref_mod_env.md_id.osnum);

              _pdm_debug("ref_mod_env.md_id.objid = %d",
                          ref_mod_env.md_id.objid);

              /* Redisplay ref file */
              status = dp$display(
                                  msg = &msg,
                                  mode = GRbe,
                                  oids = &(ref_objects[i])
                                 );
             /*
              status = dp$display(
                                  msg = &msg,
                                  mode = GRbd,
                                  oids = &(ref_objects[i])
                                 );
             */


              /*
              for (j = 0; j < coord_count; ++j)
                  {
                   _pdm_debug("j = %d", j);

                   _pdm_debug("coord_objects[j].objid = %d",
                               coord_objects[j].objid);
                   _pdm_debug("coord_objects[j].osnum = %d",
                               coord_objects[i].osnum);

                   status = dp$display(
                                       msg = &msg,
                                       osnum = ref_mod_env.md_id.osnum,
                                       objid = ref_mod_env.md_id.objid, 
                                       mode = GRbe,
                                       oids = &(coord_objects[j]) 
                                      );

                   _pdm_rstatus2("dp$display", status, msg);
                  }
               */

             }  /* End for loop */

 return(status);
}

/*
 * This function guarantees the uniqueness of the usage id 
 */
IGRint  PDUis_usage_unique(usage_id)

 IGRchar *usage_id;		/* INPUT */
 {
  IGRlong    status = PDM_S_SUCCESS;
  IGRlong    NumberOfBytes, BytesReceived;
  IGRlong    msg;
  IGRint     count = 0;
  IGRint     type;
  IGRchar    attr_value[MAX_VALUE];
  IGRchar    cs_full_name[MAX_VALUE];
  GRobjid    csid;
  IGRchar    **params = NULL;
  IGRchar    **param_vals = NULL;
  struct GRmd_env  mod_env;
  struct     PDUpart_node      *part_ids = NULL;
  struct     PDUpart_node      *parametric_ids = NULL;
  struct     PDUpart_node      *head = NULL;

 
  _pdm_debug("In the PDUis_usage_unique function", 0);

  /* Get current module environment information */
  NumberOfBytes = sizeof(mod_env);
  status = gr$get_module_env(
                             msg = &msg,
                             sizbuf = &NumberOfBytes,
                             buffer = &mod_env,
                             nret = &BytesReceived
                            );

  _pdm_debug("usage_id = <%s>", usage_id);

  /* Get path to "<filename>:usr" */
  di$give_pathname(
                   osnum = mod_env.md_id.osnum,
                   pathname = cs_full_name 
                  );

  strcat(cs_full_name, ":usr:");
  strcat(cs_full_name, usage_id);

  /* Check to see if usage id is unique across coord sys */
  status = PDUget_coord_sys_id(
                               mod_env,
                               cs_full_name,
                               &csid 
                              );
  _pdm_status("PDUget_coord_sys_id", status);

  if (status == PDM_S_SUCCESS)
     {
      _pdm_debug("usage id <%s> is not unique", usage_id);

      return(0);
     } 

  /* Check to see if usage id is unique across GRparts */
  status = PDUget_all_GRpart_ids(
                                  mod_env.md_id.osnum,
                                  &part_ids,
                                  &count
                                 );
  _pdm_status("PDUget_all_GRpart_ids", status);

  head = part_ids;

  while (head)
        {
         /* Extract GRpart usage id */
         co$part_get_attr (
                            msg = &msg,
                            mod_env = &mod_env,
                            part = &(head->part_id),
                            attr = "usage_id",
                            value = attr_value,
                            type = &type
                           );

         /* Unqoute usage id */
         PDUunquote(attr_value);

         if (strcmp(attr_value, usage_id) == 0)
            {
             _pdm_debug("usage id <%s> is not unique", usage_id);

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

             return (0);
            }

         head = head->next;

        } /* end while loop */

  /* Check to see if usage id is unique across parametric parts */
  status = PDUget_all_parametric_ids(
                                     mod_env.md_id.osnum,
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

         status = get_parameter_values(
                                       &(head->part_id),
                                       params,
                                       1,
                                       &param_vals
                                      );
         if (!status)
            {
             _pdm_debug("get_parameter_values failed", 0);
             return(-1);
            }

         if (strcmp(param_vals[0], usage_id) == 0)
            {
             _pdm_debug("usage id <%s> is not unique", usage_id);
             
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

             return (0);
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
     
  return(1);
 }

/*
 * This function guarantees the uniqueness of the alt tag number 
 */

IGRint  PDUis_alt_tag_unique(alt_tag)

 IGRchar *alt_tag;		/* INPUT */
 {
  IGRlong    status = PDM_S_SUCCESS;
  IGRlong    NumberOfBytes, BytesReceived;
  IGRchar    parts_dir[DI_PATH_MAX];
  IGRchar    value[MAX_VALUE];
  IGRlong    msg, i, j;
  IGRint     count = 0;
  IGRint     entry_count = 0;
  IGRchar    **entries;
  IGRint     type;
  IGRchar    *part_alt_tag = NULL;
  IGRchar    *part_tag = NULL;
  struct GRmd_env  mod_env;
  struct GRid      *part_ids = NULL;
  extern IGRchar   *PDU_tagno;
 
  _pdm_debug("In the PDUis_alt_tag_unique function", 0);

  _pdm_debug("checking uniqueness of <%s> alt tag no", alt_tag);

  /* Get current module environment information */
  NumberOfBytes = sizeof(mod_env);
  status = gr$get_module_env(
                             msg = &msg,
                             sizbuf = &NumberOfBytes,
                             buffer = &mod_env,
                             nret = &BytesReceived
                            );

  /* Find all part entries of the form <filename:parts:*:*!*:> */
  di$give_pathname(osnum = mod_env.md_id.osnum, pathname = parts_dir);

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
      return(1);
     }

  if (entry_count == 0)
     {
      /* alt is unique */
      _pdm_debug("alt is unique", 0);
      return(1);
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
           return(status);
          }

       /* Check to see if alt tag number is unique */
       if (count > 0)
          {
           /* Loop thru extracting alt tag number for each GRpart */
           for (j = 0; j < count; ++j)
               {
                /* Extract alt tag number */
                status = co$part_get_attr (
                                           msg = &msg,
                                           mod_env = &mod_env,
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
                                           mod_env = &mod_env,
                                           part = &(part_ids[j]),
                                           attr = "tag",
                                           value = value,
                                           type = &type
                                          );
                /* Unquote tag no */
                PDUunquote(value);
                PDUfill_in_string(&part_tag, value);
                _pdm_debug("extracted tag = <%s>", part_tag);

                if ( (strcmp(part_alt_tag, alt_tag) == 0) &&
                     (strcmp(part_tag, PDU_tagno) != 0) )
                   {
                    _pdm_debug("alt tag is not unigue", 0);
                    di$free(lines = entries, count = entry_count);
                    free(part_tag);
                    free(part_alt_tag);

                    /* Free up part_ids */
                    if (part_ids)
                       free(part_ids);

                    return(0);
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

     return(1);
 }

/*
 * This function checks to see if an OM file is a PDU file. 
 */
IGRint  PDUis_PDU_file(mod_env)
 struct GRmd_env  mod_env;         /* INPUT */
 {

  _pdm_debug("In the PDUis_PDU_file function", 0);

  /* Check to see if object space has any parts in it */
  if (PDUdo_parts_exist(1, mod_env.md_id.osnum) )
     {
      _pdm_debug("parts were found", 0);
      return(1);
     }

  else
      if (PDUdo_origins_exist(1, mod_env.md_id.osnum) )
         {
          _pdm_debug("origins exist", 0);
          return(1);
         }

  return(0);
 }
  

/*
 * This function extracts all the GRparts in a given part type.  
 */
IGRint  PDUget_GRparts_ids(part_entry, part_ids, count)

 IGRchar          part_entry[DI_PATH_MAX];    /* INPUT */
 struct GRid      **part_ids;              /* OUTPUT */
 IGRint           *count;                  /* OUTPUT */
 {
  IGRlong    status = PDM_S_SUCCESS;
  IGRchar    parts_dir[DI_PATH_MAX];
  OM_p_CLASSLIST   classlist;
  OMuword          classid;
  

 _pdm_debug("In the PDUget_GRparts_ids function", 0);
  
 _pdm_debug("part entry = <%s>", part_entry);

 /* part entry is of the form <filename:parts:catalog:num!rev:> */

 *count = 0;

 strcpy(parts_dir, part_entry);
 strcat(parts_dir,"*");

 /* Get GRpart class id */
 status = om$get_classid(
                         classname = "GRpart",
                         p_classid = &classid
                        );

 /* Malloc classlist */
 classlist = (struct OM_sd_classlist *) malloc (sizeof
                        (struct OM_sd_classlist));

 /* Initialize certain fields in classlist */
 classlist->w_count = 1;
 classlist->w_flags = OM_CLST_internal;
 classlist->p_classes = &classid;

 /* Extract GRpart ids */
 status = di$dump(
                  regexp = parts_dir,
                  p_classes = classlist,
                  grids = (DIgrid **)part_ids,
                  ptr = count
                 );

 if (status == DIR_S_SUCCESS)
    {
      if (*count > 0) 
         {
          _pdm_debug("%d GRparts were found", *count);
          return(PDM_S_SUCCESS);
         }

      else
         {
          _pdm_debug("no GRparts found", 0);
          return(PDM_S_SUCCESS);
         }
    }

  return(status);
 }


/*
 * This function extracts all PDU GRparts in a given object space.  
 */
IGRint  PDUget_all_GRpart_ids(
                              osnum,
                              part_ids,
                              total_count
                             )

 OMuword                   osnum;                   /* INPUT */
 struct  PDUpart_node      **part_ids;              /* OUTPUT */
 IGRint                    *total_count;            /* OUTPUT */
 {
  IGRlong                  status = PDM_S_SUCCESS;
  IGRchar                  parts_dir[DI_PATH_MAX];
  IGRchar                  entry[DI_PATH_MAX];
  IGRchar                  **parts;
  OM_S_OBJID               osid = NULL_OBJID;
  OM_p_CLASSLIST           classlist;
  OMuword                  classid;
  struct PDUpart_node      *temp = NULL;
  struct PDUpart_node      *tail = NULL;
  struct GRid              *objects = NULL;
  IGRint                   count = 0;
  IGRint                   part_count = 0;
  IGRint                   i, j;
  

 _pdm_debug("In the PDUget_all_GRpart_ids function", 0);

 /* Initialize part ids list */
 *part_ids = NULL;

 /* Initialize total count */
 *total_count = 0;

 /* Check if need to get active design module info */
 if (osnum == 0)
    {
     /* Get active module info */
     status = ex$get_cur_mod ( id = &osid, osnum = &osnum );
    }
  
 /* Check to see if "parts" directory exists */
 di$give_pathname(
                  osnum = osnum,
                  pathname = parts_dir
                 );

 strcat(parts_dir,":parts");

 di$ls(regexp = parts_dir, ptr = &count);

 if (count <= 0)
    {
     _pdm_debug("no parts found in object space", 0);
     return(PDM_S_SUCCESS);
    }

 /* Extract part types from obj space */
 status = di$find (
                   start_dir = parts_dir,
                   regexp = "*!*",
                   lines = &parts,
                   ptr = &part_count,
                   max_level = -1
                  );

 if (status != DIR_S_SUCCESS)
    {
     _pdm_debug("di$find failed",0);
     return(status);
    }

 if (part_count <= 0)
    {
     _pdm_debug("no parts were found in object space", 0);
     return(PDM_S_SUCCESS);
    }

 _pdm_debug("part type count = %d", part_count);

 /* Get GRpart class id */
 status = om$get_classid(
                         classname = "GRpart",
                         p_classid = &classid
                        );

 /* Malloc classlist */
 classlist = (struct OM_sd_classlist *) malloc (sizeof
                        (struct OM_sd_classlist));

 /* Initialize certain fields in classlist */
 classlist->w_count = 1;
 classlist->w_flags = OM_CLST_internal;
 classlist->p_classes = &classid;

 /* Loop thru part types extracting part ids */
 for (i = 0; i < part_count; ++i)
     {
      count = 0;
      PDUstrip_dir_entry(parts[i]);
      strcpy(entry, parts[i]);
      strcat(entry, ":");
      strcat(entry, "*");
      _pdm_debug("regexp = <%s>", entry);

      /* Extract GRpart ids */
      status = di$dump(
                       regexp = entry,
                       p_classes = classlist,
                       grids = (DIgrid **)&objects,
                       ptr = &count
                      );

      if (status != DIR_S_SUCCESS)
         {
          _pdm_debug("di$dump failed", 0);
          return(status);
         }

      if (count == 0)
         {
          _pdm_debug("no parts found under part type", 0);
          continue;
         }
 
      else
         {
          /* Add parts ids to part ids list */
          _pdm_debug("part type instence count = %d", count);

          for (j = 0; j < count; ++j)
              {
               temp =
                   (struct PDUpart_node *) malloc(sizeof(struct PDUpart_node));

               /* Initialize temp fields */
               temp->part_id.objid = objects[j].objid;
               temp->part_id.osnum = objects[j].osnum;
               temp->next = NULL;

               if (*part_ids)
                  {
                   _pdm_debug("adding node to end of list", 0);

                   tail = *part_ids;
                   while (tail->next)
                         {
                          tail = tail->next;
                         }

                   tail->next = temp;
                  }

               else
                  {
                   _pdm_debug("adding first node to list", 0);

                   *part_ids = temp;
                  }

               /* Increment total part count */
               ++(*total_count);

              } /* end j for loop */
         }
     } /* end i for loop */

  status = PDM_S_SUCCESS;

  /* Free parts */
  if (parts)
     di$free(lines = parts, count = part_count);

  /* Free up objects */
  if (objects)
     free(objects);

  return(status);
 }

/*
 * This function extracts the origin, x-axis point, and y-axis point from
 * a given coordinate system. Those three points define the orientation
 * of the coordinate system.
 */
IGRint  PDUextract_coord_orientation(
                                     coord_id,
                                     origin,
                                     x_point,
                                     y_point
                                    )
 struct  GRid coord_id;   	/* INPUT */
 IGRchar **origin;              /* OUTPUT */
 IGRchar **x_point;             /* OUTPUT */
 IGRchar **y_point;             /* OUTPUT */

 {
  IGRlong    status = PDM_S_SUCCESS;
  IGRlong    sts;
  IGRint     four = 4;
  IGRmatrix  trans_matrix;
  IGRpoint   origin_double;
  IGRpoint   x_point_double;
  IGRpoint   y_point_double;
  struct PDUpoint origin_pt;
  struct PDUpoint x_axis_pt;
  struct PDUpoint y_axis_pt;
 
  _pdm_debug("In the PDUextract_coord_orientation function", 0);

  /* Malloc origin, x_point, and y_point */
  *origin = (IGRchar *)malloc(256 * sizeof(IGRchar));
  *x_point = (IGRchar *)malloc(256 * sizeof(IGRchar));
  *y_point = (IGRchar *)malloc(256 * sizeof(IGRchar));

  /* Extract the transition matrix for the given coord id */
  status = om$send(
                   msg = message GRgencs.GRgetmatrix
                                                    (
                                                     &sts,
                                                     trans_matrix
                                                    ),
                   senderid = NULL_OBJID,
                   targetid = coord_id.objid,
                   targetos = coord_id.osnum
                  );

  /* Extract the origin of the coordinate system */
  status = PDUmatrix_to_point (
                               trans_matrix,
                               &origin_pt
                              );

  /* Need to find x-axis and y-axis points on coord sys */
  MAinvmx (
           &sts,
           &four,
           trans_matrix,
           trans_matrix
          );

  /* Find a point on x_axis */
  status = PDUadd_points (
                          trans_matrix,
                          origin_pt,
                          &x_axis_pt,
                          0,
                          1,
                          2
                         );

  /* Find a point on y_axis */
  status = PDUadd_points (
                          trans_matrix,
                          origin_pt,
                          &y_axis_pt,
                          4,
                          5,
                          6
                         );

  /* Convert origin point to string */
  origin_double[0] = origin_pt.x;
  origin_double[1] = origin_pt.y;
  origin_double[2] = origin_pt.z;

  status = PDUpoint_to_string(origin_double, *origin);

  /* Convert x_axis point to string */
  x_point_double[0] = x_axis_pt.x;
  x_point_double[1] = x_axis_pt.y;
  x_point_double[2] = x_axis_pt.z;

  status = PDUpoint_to_string(x_point_double, *x_point);

  /* Convert y_axis point to string */
  y_point_double[0] = y_axis_pt.x;
  y_point_double[1] = y_axis_pt.y;
  y_point_double[2] = y_axis_pt.z;

  status = PDUpoint_to_string(y_point_double, *y_point);


  return(status);
 }


/*
 * This function generates the orientation of a coord system given three
 * points.
 */
IGRint  PDUgenerate_coord_orientation(
                                      origin,
                                      x_point,
                                      y_point,
                                      trans_matrix
                                     )

 IGRchar *origin;		/* INPUT */
 IGRchar *x_point;		/* INPUT */
 IGRchar *y_point;		/* INPUT */
 IGRmatrix trans_matrix; 	/* OUTPUT */
 {
  IGRlong    status = PDM_S_SUCCESS;
  IGRlong    msg;
  IGRpoint   point1;
  IGRpoint   point2;
  IGRpoint   point3;
  IGRdouble  scales[3];
  IGRdouble  angle;
  IGRmatrix  rot_matrix;
  struct PDUpoint   origin_pt;
  struct PDUpoint   x_axis_pt;
  struct PDUpoint   y_axis_pt;
  
 
  _pdm_debug("In the PDUgenerate_coord_orientation function", 0);

  _pdm_debug("origin at entry = <%s>", origin);
  _pdm_debug("x_point at entry = <%s>", x_point);
  _pdm_debug("y_point at entry = <%s>", y_point);

  /* Convert string origin to point */
  status = PDUstring_to_point(origin, &origin_pt);

  /* Convert string x_axis to point */
  status = PDUstring_to_point(x_point, &x_axis_pt);

  /* Convert string y_axis to point */
  status = PDUstring_to_point(y_point, &y_axis_pt);

  point1[0] = origin_pt.x;
  point1[1] = origin_pt.y;
  point1[2] = origin_pt.z;

  point2[0] = x_axis_pt.x;
  point2[1] = x_axis_pt.y;
  point2[2] = x_axis_pt.z;

  point3[0] = y_axis_pt.x;
  point3[1] = y_axis_pt.y;
  point3[2] = y_axis_pt.z;

  _pdm_debug("point1[0] = %lf", point1[0]);
  _pdm_debug("point1[1] = %lf", point1[1]);
  _pdm_debug("point1[2] = %lf", point1[2]);

  _pdm_debug("point2[0] = %lf", point2[0]);
  _pdm_debug("point2[1] = %lf", point2[1]);
  _pdm_debug("point2[2] = %lf", point2[2]);
  
  _pdm_debug("point3[0] = %lf", point3[0]);
  _pdm_debug("point3[1] = %lf", point3[1]);
  _pdm_debug("point3[2] = %lf", point3[2]);

  /* Extract the coord system rotation matrix */
  status = MA3protmx(
                     &msg,
                     point1,
                     point2,
                     point3,
                     rot_matrix
                    ); 

  PDUdump_matrix(rot_matrix);

  /* Extract the coord system transition (orientation) matrix */
  scales[0] = 1.000000;
  scales[1] = 1.000000;
  scales[2] = 1.000000;

  angle = 0.000000;

  GRsmplmat(
            &msg,
            &angle,
            scales,
            point1,
            rot_matrix,
            trans_matrix
           );

  PDUdump_matrix(trans_matrix);

  return(status);
 }

/* 
 * This function checks the consistency between the assembly structure in the
 * data base and that in the active design.
 */
IGRint  PDUcheck_assembly_consistency(
                                      assy_struct_bufr,
                                      mod_env 
                                     )
 MEMptr  assy_struct_bufr;       /* INPUT */
 struct GRmd_env *mod_env;       /* INPUT */
 {
  IGRlong                 status = PDM_S_SUCCESS;
  IGRchar                 attr_value[MAX_VALUE];
  IGRchar                 **data;
  IGRint                  type;
  IGRint                  total_count = 0;
  IGRint                  parametrics_count = 0;
  IGRlong                 msg;
  IGRint                  *new_part_flag;
  IGRint                  i,j;
  IGRshort                found;
  OM_S_OBJID              osid;
  IGRint                  resp;
  IGRint                  pos;
  IGRint                  file_col;
  IGRint                  cat_no_col;
  IGRint                  item_no_col;
  IGRint                  child_col;
  IGRint                  cat_col;
  IGRint                  part_col;
  IGRint                  rev_col;
  IGRint                  desc_col;
  IGRint                  usage_col;
  IGRint                  quant_col;
  IGRint                  attach_col;
  IGRint                  alttag_col;
  IGRint                  explode_col;
  IGRint                  incbom_col;
  IGRint                  incstr_col;
  IGRint                  type_col;
  IGRint                  level_col;
  IGRchar                 *part_cat = NULL;
  IGRchar                 *part_num = NULL;
  IGRchar                 *part_rev = NULL;
  IGRchar                 *part_childno = NULL;
  IGRchar                 *catalog = NULL;
  IGRchar                 *number = NULL;
  IGRchar                 *revision = NULL;
  IGRchar                 *usage_id = NULL;
  IGRchar                 *quantity = NULL;
  IGRchar                 *attached = NULL;
  IGRchar                 *child_no = NULL;
  IGRchar                 *catalog_no = NULL;
  IGRchar                 *item_no = NULL;
  IGRchar                 *file_name = NULL;
  IGRchar                 *tag_no = NULL;
  IGRchar                 *alt_tagno = NULL;
  IGRchar                 *incbom = NULL;
  IGRchar                 *incstr = NULL;
  IGRchar                 *explode = NULL;
  IGRchar                 *part_type = NULL;
  IGRshort                GRAPHIC = FALSE;
  IGRshort                attach = FALSE;
  IGRchar                 **params = NULL;
  IGRchar                 **param_vals = NULL;
  struct GRid             part_id;
  struct PDUpart_node     *parts_ids = NULL;
  struct PDUpart_node     *parametric_ids = NULL;
  struct PDUpart_node     *temp = NULL;
  struct PDUpart_node     *node = NULL;
  struct PDUpart_node     *head = NULL;
  struct PDUpart_node     *tail = NULL;
  MEMptr                  part_asm_bufr = NULL;
  MEMptr                  file_bufr = NULL; 
  IGRchar                 assy_path[DI_PATH_MAX];


 
  _pdm_debug("In the PDUcheck_assembly_consistency function", 0);
 
  /* Check if need to get active design module info */

  if (assy_struct_bufr)
     {
      if (assy_struct_bufr->rows > 0)
         {
          /* Setup buffer */
          if (PDM_debug_on)
            MEMprint_buffer("assy_struct_bufr", assy_struct_bufr, 
                            PDU_DEBUG_FILE);
          MEMbuild_array(assy_struct_bufr);
          PDUsetup_buffer(assy_struct_bufr, ROW, &data);

          /* Extract catalog column no */
          PDUget_buffer_col(
                            assy_struct_bufr,
                            "n_catalogname",
                            &cat_col
                           );

          /* Extract part number column no */
          PDUget_buffer_col(
                            assy_struct_bufr,
                            "n_itemname",
                            &part_col
                           );

          /* Extract revision column no */
          PDUget_buffer_col(
                            assy_struct_bufr,
                            "n_itemrev",
                            &rev_col
                           );

          /* Extract description column no */
          PDUget_buffer_col(
                            assy_struct_bufr,
                            "n_itemdesc",
                            &desc_col
                           );

          /* Extract usage id column no */
          PDUget_buffer_col(
                            assy_struct_bufr,
                            "p_usageid",
                            &usage_col
                           );

          /* Extract quantity column no */
          PDUget_buffer_col(
                            assy_struct_bufr,
                            "p_quantity",
                            &quant_col
                           );

          /* Extract attachment column no */
          PDUget_buffer_col(
                            assy_struct_bufr,
                            "p_attached",
                            &attach_col
                           );

          /* Extract alt tag no column no */
          PDUget_buffer_col(
                            assy_struct_bufr,
                            "p_alttagno",
                            &alttag_col
                           );

          /* Extract explode column no */
          PDUget_buffer_col(
                            assy_struct_bufr,
                            "p_explode",
                            &explode_col
                           );

          /* Extract include BOM column no */
          PDUget_buffer_col(
                            assy_struct_bufr,
                            "p_incbom",
                            &incbom_col
                           );

          /* Extract include assembly column no */
          PDUget_buffer_col(
                            assy_struct_bufr,
                            "p_incstr",
                            &incstr_col
                           );

          /* Extract part type column no */
          PDUget_buffer_col(
                            assy_struct_bufr,
                            "p_parttype",
                            &type_col
                           );

          /* Extract part catalog no col no */
          PDUget_buffer_col(
                            assy_struct_bufr,
                            "n_ccatalogno",
                            &cat_no_col
                           );

          /* Extract part item no col no */
          PDUget_buffer_col(
                            assy_struct_bufr,
                            "n_citemno",
                            &item_no_col
                           );

          /* Extract part file name col no */
          PDUget_buffer_col(
                            assy_struct_bufr,
                            "n_cofilename",
                            &file_col
                           );

          /* Extract part child no col no */
          PDUget_buffer_col(
                            assy_struct_bufr,
                            "p_childno",
                            &child_col
                           );

          /* Extract level no column no */
          PDUget_buffer_col(
                            assy_struct_bufr,
                            "p_level",
                            &level_col
                           );
         }
     }

  /* Extract part pointers from object space */
  status = PDUget_all_GRpart_ids(
                                 mod_env->md_id.osnum,
                                 &parts_ids,
                                 &total_count
                                ); 
  _pdm_status("PDUget_all_GRpart_ids", status);

  /* Extract all parametric parts */
  status = PDUget_all_parametric_ids(
                                     mod_env->md_id.osnum,
                                     &parametric_ids,
                                     &parametrics_count
                                    );
  _pdm_status("PDUget_all_parametric_ids", status);

  total_count = total_count + parametrics_count;

  /* Case I: if assembly buffer is empty and no parts found in obj space */
  if ( (total_count == 0) && (assy_struct_bufr->rows  == 1) ) 
     {
      _pdm_debug("assembly is consistent in Case I", 0);
      return(PDM_S_SUCCESS);
     }

  /* Case II: if no parts were found in obj space and assembly buffer is
   *          not empty.
   */
  if (assy_struct_bufr)
  if ( (total_count == 0) && (assy_struct_bufr->rows > 1) )
     {
      _pdm_debug("new parts need to be added Case II", 0);

      /* Format delete part local file */
      PDMopen_buffer(
                     7,
                     &file_bufr
                    );

      for (i = 1; i < assy_struct_bufr->rows; ++i)
          {
           if (atoi(data[(assy_struct_bufr->columns * i) + level_col]) != 1)
              continue;

           /* Extract certain attrs from current row */
           PDUfill_in_string(
                             &catalog,
                             data[(assy_struct_bufr->columns * i)+cat_col]
                            );

           PDUfill_in_string(
                             &number,
                             data[(assy_struct_bufr->columns * i)+part_col]
                            );

           PDUfill_in_string(
                             &revision,
                             data[(assy_struct_bufr->columns * i)+rev_col]
                            );

           PDUfill_in_string(
                             &usage_id,
                             data[(assy_struct_bufr->columns * i)+usage_col]
                            );

           PDUfill_in_string(
                             &quantity,
                             data[(assy_struct_bufr->columns * i)+quant_col]
                            );

           PDUfill_in_string(
                             &attached,
                             data[(assy_struct_bufr->columns*i)+attach_col]
                            );

           PDUfill_in_string(
                             &alt_tagno,
                             data[(assy_struct_bufr->columns*i)+alttag_col]
                            );

           PDUfill_in_string(
                             &explode,
                             data[(assy_struct_bufr->columns*i)+explode_col]
                            );

           PDUfill_in_string(
                             &incbom,
                             data[(assy_struct_bufr->columns*i)+incbom_col]
                            );

           PDUfill_in_string(
                             &incstr,
                             data[(assy_struct_bufr->columns*i)+incstr_col]
                            );

           PDUfill_in_string(
                             &part_type,
                             data[(assy_struct_bufr->columns*i)+type_col]
                            );

           PDUfill_in_string(
                             &refresh->rev_parttype,
                             data[(assy_struct_bufr->columns*i)+type_col]
                            );

           PDUfill_in_string(
                             &item_no,
                             data[(assy_struct_bufr->columns*i)+item_no_col]
                            );

           PDUfill_in_string(
                             &catalog_no,
                             data[(assy_struct_bufr->columns*i)+cat_no_col]
                            );

           PDUfill_in_string(
                             &file_name,
                             data[(assy_struct_bufr->columns*i)+file_col]
                            );

           PDUfill_in_string(
                             &child_no,
                             data[(assy_struct_bufr->columns*i)+child_col]
                            );

           GRAPHIC = ( (strcmp(part_type, "G") == 0) ||
                       (strcmp(part_type, "g") == 0) ||
                       (strcmp(part_type, "D") == 0) ||
                       (strcmp(part_type, "d") == 0) ) ;

           if ( ((strcmp(attached, "Y") == 0) ||
                (strcmp(attached, "y") == 0)) && GRAPHIC )
              {
               /* Load delete local file info to buffer */
               status = PDUload_local_file_info(
                                                catalog,
                                                number,
                                                revision,
                                  data[(assy_struct_bufr->columns*i)+child_col],
                                                assy_struct_bufr,
                                                &file_bufr
                                               );
               _pdm_status("PDUload_local_file_info", status);

               if (status != PDM_S_SUCCESS)
                  {
                   _pdm_debug("PDUload_local_file_info failed", 0);
                   return(status);
                  }

               if (PDM_debug_on)
                  MEMprint_buffer("file_bufr", file_bufr, PDU_DEBUG_FILE);
              }


           /* Get assembly structure of part */
           status = PDMget_assembly_structure(
                                              catalog,
                                              number,
                                              revision,
                                              MAX_LEVEL,
                                              &part_asm_bufr,
                                              1
                                             );
           _pdm_status("PDMget_assembly_structure", status);

           if (part_asm_bufr == NULL)
              {
               _pdm_debug("SEVERE error: part_asm_bufr is empty", 0);
               return(0);
              }

           /* Add part to assembly structure */
           status = PDUadd_assy_struct_from_buffer
                                                (
                                                 mod_env,
                                                 child_no,
                                                 file_name,
                                                 part_asm_bufr,
                                                 1
                                                );
           _pdm_status("PDUadd_assy_struct_from_buffer", status);

           if (status != PDM_S_SUCCESS)
              {
               _pdm_debug("PDUadd_assy_struct_from_buffer failed", 0);
               return(0);
              }

           /* Create a PDU GRpart */
           status =  PDUcreate_GRpart (
                                       mod_env,
                                       catalog,
                                       number,
                                       revision,
                                       child_no,
                                       quantity,
                                       alt_tagno,
                                       usage_id,
                                       "",
                                       "",
                                       part_type,
                                       incbom,
                                       incstr,
                                       explode,
                                       attach,
                                       &part_id
                                      );
           _pdm_debug("PDUcreate_GRpart", status);

           if (status != PDM_S_SUCCESS)
              {
               _pdm_debug("PDUcreate_GRpart failed", 0);

               if (catalog)
                  free(catalog);

               if (number)
                  free(number);

               if (revision)
                  free(revision);

               if (usage_id)
                  free(usage_id);

               if (quantity)
                  free(quantity);

               if (attached)
                  free(attached);

               if (child_no)
                  free(child_no);

               if (tag_no)
                  free(tag_no);

               if (alt_tagno)
                  free(alt_tagno);

               if (incbom)
                  free(incbom);

               if (explode)
                  free(explode);

               if (incstr)
                  free(incstr);

               if (part_type)
                  free(part_type);

               if (catalog_no)
                  free(catalog_no);

               if (item_no)
                  free(item_no);

               if (file_name)
                  free(file_name);

               return(status);
              }

           else
               {
                /* Need to increment child number seed */
                PDUincrement_child_no(mod_env->md_id.osnum);

                /* Update refid attr. to indicate positionless part */
                di$give_pathname(
                                 osnum = mod_env->md_id.osnum,
                                 pathname = assy_path
                                );

                strcat(assy_path, ":ASSEMBLY:P");
                strcat(assy_path, child_no);

                /* Update the part's display in assy struct */
                PDUmodify_exp(
                              0,
                              assy_path,
                              "refid",
                              "-1",
                              mod_env->md_id.osnum
                             );
               }

          } /* end for loop */

      if (file_bufr->rows > 0)
         {
          /* Delete graphic part files placed non-graphically with attach="Y" */
          status = PDMdetach_part(file_bufr);
          _pdm_status("PDMdetach_part", status);

          if (status != PDM_S_SUCCESS)
             {
              _pdm_debug("PDMrdelete_local_files failed", 0);
              return(status);
             }
         }
      
      /* Free variables */
      if (catalog)
         free(catalog);

      if (number)
         free(number);

      if (revision)
         free(revision);

      if (usage_id)
         free(usage_id);

      if (quantity)
         free(quantity);

      if (attached)
         free(attached);

      if (child_no)
         free(child_no);

      if (tag_no)
         free(tag_no);

      if (alt_tagno)
         free(alt_tagno);

      if (incbom)
         free(incbom);

      if (explode)
         free(explode);

      if (incstr)
         free(incstr);

      if (part_type)
         free(part_type);

      if (catalog_no)
          free(catalog_no);

      if (item_no)
         free(item_no);

      if (file_name)
         free(file_name);

      if (part_asm_bufr)
         MEMclose(&part_asm_bufr);

      if (file_bufr)
          MEMclose(&file_bufr);

      return(PDM_S_SUCCESS);
     }

  /* Case III: if parts were found in obj space and assembly buffer is 
   *           empty.
   */
  if ( (total_count > 0) && (assy_struct_bufr) && (assy_struct_bufr->rows == 1))
     {
      _pdm_debug("parts need to be deleted Case III", 0);

      if (parts_ids)
         {
          /* Delete GRparts. */
          _pdm_debug("delete GRpart", 0);

          head = parts_ids;
          while(head)
            {
             /* Delete part */
             om$send(
                     msg = message GRgraphics.GRdelete(
                                                       &msg,
                                                       mod_env
                                                      ),
                     senderid = mod_env->md_id.objid,
                     targetid = (head->part_id).objid,
                     targetos = (head->part_id).osnum
                    );

             /* Process next node */
             head = head->next;
            } /* end while loop */ 
         }

      if (parametric_ids)
         {
          _pdm_debug("calling delete parametric part command", 0);

          head = parametric_ids;
          while(head)
            {
             pdmoDeletePartOccurrence(&status, mod_env, &(head->part_id));

             /* Process next node */
             head = head->next;
            } /* end while loop */ 
         }

      return(PDM_S_SUCCESS);
     }

  /* Case IV: if parts were found in obj space and assembly structure 
   *          is not empty.
   */
  if (assy_struct_bufr->rows)
  if ( (total_count > 0) && (assy_struct_bufr->rows > 1) )
     {
      _pdm_debug("total_count = <%d>", total_count);
      /* Format delete part local file */
      PDMopen_buffer(
                     7,
                     &file_bufr
                    );

      new_part_flag = (IGRint *)malloc(sizeof(IGRint)*assy_struct_bufr->rows);

      /* Initialize new_part_flag entries to TRUE */
      new_part_flag[0] = FALSE;
      for (i = 1; i < assy_struct_bufr->rows; ++i)
          new_part_flag[i] = TRUE;
 
      if ( (parametric_ids) && (parts_ids) )
         {
          /* Get to the end of parts_ids list */
          head = parts_ids;

          while (head->next)
               {
                head = head->next;
               }

          head->next = parametric_ids;

          parametric_ids = NULL;

          temp = parts_ids;
         }

      else if (parametric_ids)
              {
               temp = parametric_ids;
              }

      else if (parts_ids)
              {
               temp = parts_ids;
              }
      
      while(temp)      
          {
           if (PDUis_parametric_part(&(temp->part_id)))
              {
               /* Extract child no from parametric part */
               params = (IGRchar **) malloc(4*sizeof(IGRchar *));
               memset((IGRchar *)params, NULL, 4*sizeof(IGRchar *));

               PDUfill_in_string(&params[0], "n_catalogname");
               PDUfill_in_string(&params[1], "n_itemname");
               PDUfill_in_string(&params[2], "n_itemrev");
               PDUfill_in_string(&params[3], "serial_no");

               status = get_parameter_values(
                                             &(temp->part_id),
                                             params,
                                             4,
                                             &param_vals
                                            );
               if (!status)
                  {
                   _pdm_debug("get_parameter_values failed", 0);
                   return(status);
                  }

               PDUfill_in_string(&part_cat, param_vals[0]);
               PDUfill_in_string(&part_num, param_vals[1]);
               PDUfill_in_string(&part_rev, param_vals[2]);
               PDUfill_in_string(&part_childno, param_vals[3]);
              }

           else
               {
                /* Extract child no from GRpart part */
                status = co$part_get_attr (
                                           msg = &msg,
                                           mod_env = mod_env,
                                           part = &(temp->part_id),
                                           attr = "child_no",
                                           value = attr_value,
                                           type = &type
                                          );

                if (msg != MSSUCC)
                   {
                    _pdm_debug("SEVERE error: co$part_get_attr failed", 0);
                    return(0);
                   }
           
                /* Unquote child no */
                PDUunquote(attr_value);
                
                PDUfill_in_string(&part_childno, attr_value);

                /* Extract catalog from GRpart part */
                status = co$part_get_attr (
                                           msg = &msg,
                                           mod_env = mod_env,
                                           part = &(temp->part_id),
                                           attr = "CATALOG",
                                           value = attr_value,
                                           type = &type
                                          );

                if (msg != MSSUCC)
                   {
                    _pdm_debug("SEVERE error: co$part_get_attr failed", 0);
                    return(0);
                   }

                PDUfill_in_string(&part_cat, attr_value);

                /* Extract number from GRpart part */
                status = co$part_get_attr (
                                           msg = &msg,
                                           mod_env = mod_env,
                                           part = &(temp->part_id),
                                           attr = "NUMBER",
                                           value = attr_value,
                                           type = &type
                                          );

                if (msg != MSSUCC)
                   {
                    _pdm_debug("SEVERE error: co$part_get_attr failed", 0);
                    return(0);
                   }

                PDUfill_in_string(&part_num, attr_value);

                /* Extract revision from GRpart part */
                status = co$part_get_attr (
                                           msg = &msg,
                                           mod_env = mod_env,
                                           part = &(temp->part_id),
                                           attr = "REVISION",
                                           value = attr_value,
                                           type = &type
                                          );

                if (msg != MSSUCC)
                   {
                    _pdm_debug("SEVERE error: co$part_get_attr failed", 0);
                    return(0);
                   }

                PDUfill_in_string(&part_rev, attr_value);
               }
 
           found = FALSE;
           for (j = 1; j < assy_struct_bufr->rows; j++) 
               {
               if (strcmp(data[(assy_struct_bufr->columns * j) + level_col], 
                   "1") != 0)
                continue;
                if ( (strcmp(part_childno,
                     data[(assy_struct_bufr->columns * j) + child_col]) == 0)&&
                     (strcmp(part_cat,
                     data[(assy_struct_bufr->columns * j) + cat_col]) == 0)&&
                     (strcmp(part_num,
                     data[(assy_struct_bufr->columns * j) + part_col]) == 0)&&
                     (strcmp(part_rev,
                     data[(assy_struct_bufr->columns * j) + rev_col]) == 0)
                   )
                   {
                    _pdm_debug("part found", 0);

                    found = TRUE;
                    new_part_flag[j] = FALSE;
                    break;
                   }
               }

           if (found == FALSE)
              {
               _pdm_debug("part need to be deleted Case IV", 0);
               
               node = (struct PDUpart_node *)
                      malloc(sizeof(struct PDUpart_node));

               node->part_id = temp->part_id;
               node->next = NULL;

               if (PDUis_parametric_part(&(temp->part_id)))
                  {
                   pdmoDeletePartOccurrence(&status, mod_env, &(temp->part_id));
                  }

               else
                   {
                    /* Delete GRpart */
                    om$send(
                            msg = message GRgraphics.GRdelete(
                                                              &msg,
                                                              mod_env
                                                             ),
                            senderid = mod_env->md_id.objid,
                            targetid = (temp->part_id).objid,
                            targetos = (temp->part_id).osnum
                           );
                   }
              }

           /* Process next part */
           temp = temp->next;
           
          } /* end while loop */

      /* Check if need to create new parts */
      for (i = 1; i < assy_struct_bufr->rows; i ++)
          {
          _pdm_debug("level = <%s>", data[(assy_struct_bufr->columns * i) + 
                     level_col]);
        if (strcmp(data[(assy_struct_bufr->columns * i) + level_col], "1") != 0)
              continue;
         if (new_part_flag[i] == 0)
           _pdm_debug("new_part_flag is 0", 0);
         else
           _pdm_debug("new_part_flag = %d", new_part_flag[i]);

           if (new_part_flag[i])
              {
               _pdm_debug("create new part", 0);

               /* Extract certain attrs from current row */
               PDUfill_in_string(
                                 &catalog,
                                 data[(assy_struct_bufr->columns * i)+cat_col]
                                );

               PDUfill_in_string(
                                 &number,
                                 data[(assy_struct_bufr->columns * i)+part_col]
                                );

               PDUfill_in_string(
                                 &revision,
                                 data[(assy_struct_bufr->columns * i)+rev_col]
                                );

               PDUfill_in_string(
                                 &usage_id,
                                 data[(assy_struct_bufr->columns * i)+usage_col]
                                );

               PDUfill_in_string(
                                 &quantity,
                                 data[(assy_struct_bufr->columns * i)+quant_col]
                                );

               PDUfill_in_string(
                                 &attached,
                                 data[(assy_struct_bufr->columns*i)+attach_col]
                                );

               PDUfill_in_string(
                                 &alt_tagno,
                                 data[(assy_struct_bufr->columns*i)+alttag_col]
                                );

               PDUfill_in_string(
                                 &explode,
                                 data[(assy_struct_bufr->columns*i)+explode_col]
                                );

               PDUfill_in_string(
                                 &incbom,
                                 data[(assy_struct_bufr->columns*i)+incbom_col]
                                );

               PDUfill_in_string(
                                 &incstr,
                                 data[(assy_struct_bufr->columns*i)+incstr_col]
                                );

               PDUfill_in_string(
                                 &part_type,
                                 data[(assy_struct_bufr->columns*i)+type_col]
                                );

               PDUfill_in_string(
                                 &catalog_no,
                                 data[(assy_struct_bufr->columns*i)+cat_no_col]
                                );

               PDUfill_in_string(
                                 &item_no,
                                 data[(assy_struct_bufr->columns*i)+item_no_col]
                                );

               PDUfill_in_string(
                                 &file_name,
                                 data[(assy_struct_bufr->columns*i)+file_col]
                                );

               GRAPHIC = ( (strcmp(part_type, "G") == 0) ||
                           (strcmp(part_type, "g") == 0) ||
                           (strcmp(part_type, "D") == 0) ||
                           (strcmp(part_type, "d") == 0) ) ;

               if ( ((strcmp(attached, "Y") == 0) ||
                    (strcmp(attached, "y") == 0)) && GRAPHIC )
                  {
                   /* Load delete local file info to buffer */
                   status = PDUload_local_file_info(
                                                    catalog,
                                                    number,
                                                    revision,
                                  data[(assy_struct_bufr->columns*i)+child_col],
                                                    assy_struct_bufr,
                                                    &file_bufr
                                                   );
                   _pdm_status("PDUload_local_file_info", status);

                   if (status != PDM_S_SUCCESS)
                      {
                       _pdm_debug("PDUload_local_file_info failed", 0);
                       return(status);
                      }

                   if (PDM_debug_on)
                      MEMprint_buffer("file_bufr", file_bufr, PDU_DEBUG_FILE);
                  }

               /* Get child no */
               status = PDUgenerate_child_no(
                                             &child_no,
                                             mod_env->md_id.osnum
                                            );

               /* Get assembly structure of part */
               status = PDMget_assembly_structure(
                                                  catalog,
                                                  number,
                                                  revision,
                                                  MAX_LEVEL,
                                                  &part_asm_bufr,
                                                  1
                                                 );
               _pdm_status("PDMget_assembly_structure", status);

               if (part_asm_bufr == NULL)
                  {
                   _pdm_debug("SEVERE error: part_asm_bufr is empty", 0);
                   return(0);
                  }

               /* Add part to assembly structure */
               status = PDUadd_assy_struct_from_buffer
                                                    (
                                                     mod_env,
                                                     child_no,
                                                     file_name,
                                                     part_asm_bufr,
                                                     1
                                                    );
               _pdm_status("PDUadd_assy_struct_from_buffer", status);

               if (status != PDM_S_SUCCESS)
                  {
                   _pdm_debug("PDUadd_assy_struct_from_buffer failed", 0);
                   return(0);
                  }


               /* Create a PDU GRpart */
               status =  PDUcreate_GRpart (
                                           mod_env,
                                           catalog,
                                           number,
                                           revision, 
                                           child_no,
                                           quantity,
                                           alt_tagno,
                                           usage_id,
                                           "",
                                           "",
                                           part_type,
                                           incbom,
                                           incstr,
                                           explode,
                                           attach,
                                           &part_id 
                                          );
               _pdm_debug("PDUcreate_GRpart", status);

               if (status != PDM_S_SUCCESS)
                  {
                   _pdm_debug("PDUcreate_GRpart failed", 0);
                   return(status);
                  }

               else
                   {
                    /* Need to increment child number seed */
                    PDUincrement_child_no(mod_env->md_id.osnum);

                    /* Update refid attr. to indicate positionless part */
                    di$give_pathname(
                                     osnum = mod_env->md_id.osnum,
                                     pathname = assy_path
                                    );

                    strcat(assy_path, ":ASSEMBLY:P");
                    strcat(assy_path, child_no);

                    /* Update the part's display in assy struct */
                    PDUmodify_exp(
                                  0,
                                  assy_path,
                                  "refid",
                                  "-1",
                                  mod_env->md_id.osnum
                                 );
                   }
              }
          } /* end for i loop */

      if (file_bufr->rows > 0)
         {
          /* Delete graphic part files placed non-graphically with attach="Y" */
          status = PDMdetach_part(file_bufr);
          _pdm_status("PDMdetach_part", status);

          if (status != PDM_S_SUCCESS)
             {
              _pdm_debug("PDMdetach_part failed", 0);
              return(status);
             }
         }

      /* Free new_part_flag */
      if (new_part_flag)
         {
          free(new_part_flag);
         }

      if (catalog)
         free(catalog);

      if (number)
         free(number);

      if (revision)
         free(revision);

      if (usage_id)
         free(usage_id);

      if (quantity)
         free(quantity);

      if (attached)
         free(attached);

      if (child_no)
         free(child_no);

      if (tag_no)
         free(tag_no);

      if (alt_tagno)
         free(alt_tagno);

      if (incbom)
         free(incbom);

      if (explode)
         free(explode);

      if (incstr)
         free(incstr);

      if (part_type)
         free(part_type);

      if (catalog_no)
         free(catalog_no);

      if (item_no)
         free(item_no);

      if (file_name)
         free(file_name);

      if (part_cat)
         free(part_cat);

      if (part_num)
         free(part_num);

      if (part_rev)
         free(part_rev);

      if (part_childno)
         free(part_childno);

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

      if (part_asm_bufr)
         MEMclose(&part_asm_bufr);

      if (file_bufr)
         MEMclose(&file_bufr);

      return(PDM_S_SUCCESS);
     }
  
  _pdm_debug("SEVERE error: Unknown consistency case", 0);
  return(0);
 }

/*
 * This function extracts all unique attached ref. files in a given
 * object space.  
 */
IGRint  PDUget_all_ref_file_names(mod_env)

 struct GRmd_env               *mod_env;                /* INPUT */
 {
  IGRlong                        msg = MSSUCC;
  IGRlong                        status = PDM_S_SUCCESS;
  IGRint                         ref_count = 0;
  IGRint                         size;
  IGRint                         i;
  IGRchar                        ref_filename[DI_PATH_MAX];
  unsigned short                 ref_props;
  struct  GRinquire_list         ref_list[4]; 
  struct  GRinquire_list         ref_list1[3]; 
  struct  GRinfo_processor       processor;
  struct  PDUid                  *ref_objects = NULL;
  IGRboolean                     pass_on;
  extern  IGRint                 PDUprocess_ref_files();
  struct PDUref_node             *temp = NULL;
  struct PDUref_node             *head = NULL;
  struct PDUref_node             *tail = NULL;
  IGRshort                       add_file;
  struct GRid                    ref_id;
  
 
 _pdm_debug("In the PDUget_all_ref_file_names function", 0);

 /* Get 1st-level ref objects */
 status = PDUget_reffile_objects(
                                 (*mod_env).md_id.osnum,
                                 &ref_objects,
                                 &ref_count
                                );
 _pdm_status("PDUget_reffile_objects", status);

 if (ref_count <= 0)
    {
     _pdm_debug("no 1st-level ref attachments found", 0);
     return(PDM_S_SUCCESS);
    }

 /* Set ref. request for first level attachments */
 ref_list1[0].var = REFERENCE_FILE_NAME;
 ref_list1[0].var_ptr = ref_filename;
 ref_list1[0].num_requested = DI_PATH_MAX;
 ref_list1[1].var = FILE_PROPERTIES;
 ref_list1[1].var_ptr = (IGRchar *) &ref_props;
 ref_list1[1].num_requested = sizeof(unsigned short);
 ref_list1[2].var = END_REPORT_REQUEST;
 pass_on = FALSE;
 size = sizeof(DI_PATH_MAX);

 /* Load 1st-level ref file names regardless of attachment type */
 for (i = 0; i < ref_count; ++i)
     {
      add_file = TRUE;

      status = om$send(
                       msg = message GRreffile.GRinquireref
                                              (
                                               &msg,
                                               mod_env,
                                               ref_list1,
                                               &size,
                                               &pass_on,
                                               NULL
                                              ),
                       senderid = (*mod_env).md_id.objid,
                       targetid = ref_objects[i].objid,
                       targetos = ref_objects[i].osnum
                      );

      /* Check to see if ref. file is unloaded */
      if (ref_props & GRRF_UNLOADED)
         {
          _pdm_debug("skip unloaded ref. objects", 0);
          continue;
         }

      if (PDU_ref_filenames)
         {
          head = PDU_ref_filenames;
          while (head)
                {
                 if (strcmp(head->filename, ref_filename) == 0)
                    {
                     _pdm_debug("file name already exists", 0);
                     add_file = FALSE;
                     break;
                    }
               head = head->next;
              }
         }

      if (add_file == TRUE)
         {
          /* Add ref. name to ref_names list */
          temp = (struct PDUref_node *) malloc(sizeof(struct PDUref_node));

          /* Initialize temp fields */
          temp->description = NULL;
          temp->filename = NULL;
          (temp->ref_id).objid = ref_objects[i].objid;
          (temp->ref_id).osnum = ref_objects[i].osnum;
          temp->next = NULL;
          

          PDUfill_in_string(&(temp->filename), ref_filename);

          if (PDU_ref_filenames)
             {
              _pdm_debug("adding node to end of list", 0);

              tail = PDU_ref_filenames;
              while (tail->next)
                    {
                     tail = tail->next;
                    }

              tail->next = temp;
             }

          else
              {
               _pdm_debug("adding first node to list", 0);
               PDU_ref_filenames = temp;
              }
          }
     }


 /* Set ref. request for nth-level attachments */
 ref_list[0].var = REFERENCE_FILE_NAME;
 ref_list[0].var_ptr = ref_filename;
 ref_list[0].num_requested = DI_PATH_MAX;
 ref_list[1].var = FILE_PROPERTIES;
 ref_list[1].var_ptr = (IGRchar *) &ref_props;
 ref_list[1].num_requested = sizeof(unsigned short);
 ref_list[2].var = REFERENCE_ID;
 ref_list[2].var_ptr = (IGRchar *) &ref_id;
 ref_list[2].num_requested = sizeof(struct GRid);
 ref_list[3].var = END_REPORT_REQUEST;
 pass_on = TRUE;
 size = sizeof(DI_PATH_MAX);

 /* Set processor structure info */
 processor.processor_function = PDUprocess_ref_files;
 processor.info = NULL;

 /* Loop thru all 1st level ref objects */
 for (i = 0; i < ref_count; ++i)
     {
      _pdm_debug("calling GRreffile.GRinquireref", 0);

      status = om$send(
                       msg = message GRreffile.GRinquireref(
                                                            &msg,
                                                            mod_env,
                                                            ref_list, 
                                                            &size,
                                                            &pass_on,
                                                            &processor 
                                                           ),
                       senderid = (*mod_env).md_id.objid,
                       targetid = ref_objects[i].objid,
                       targetos = ref_objects[i].osnum
                      );

     } /* end for loop */

  return(PDM_S_SUCCESS);
 }

 /*
 * This function extracts all unique catalog_no/item_no pairs from ref. file 
 * objects in the active object space.
 */
IGRint  PDUget_all_catalogno_itemno_pairs()

 {
  IGRlong                        msg = MSSUCC;
  IGRlong                        status = PDM_S_SUCCESS;
  IGRint                         ref_count = 0;
  IGRint                         size;
  IGRint                         i;
  struct  GRinquire_list         ref_list[2];
  struct  GRinfo_processor       processor;
  struct  PDUid                  *ref_objects = NULL;
  IGRboolean                     pass_on;
  struct  GRmd_env               mod_env;
  IGRlong                        NumberOfBytes, BytesReceived;
  struct  GRref_instance_data    ref_instance;
  extern  IGRint                 PDUextract_ref_file_description();


 _pdm_debug("In the PDUget_all_catalogno_itemno_pairs function", 0);
 
 /* Get active module information */
 NumberOfBytes = sizeof(mod_env);
 status = gr$get_module_env(
                            msg = &msg,
                            sizbuf = &NumberOfBytes,
                            buffer = &mod_env,
                            nret = &BytesReceived
                           );

 /* Get 1st-level ref objects */
 status = PDUget_reffile_objects(
                                 mod_env.md_id.osnum,
                                 &ref_objects,
                                 &ref_count
                                );
 _pdm_status("PDUget_reffile_objects", status);

 if (ref_count <= 0)
    {
     _pdm_debug("no 1st-level ref attachments found", 0);
     return(PDM_S_SUCCESS);
    }

 /* Set ref. request */
 ref_list[0].var = REFERENCE_INSTANCE_DATA;
 ref_list[0].var_ptr = (IGRchar *)&ref_instance;
 ref_list[0].num_requested = sizeof(struct GRref_instance_data);
 ref_list[1].var = END_REPORT_REQUEST;
 pass_on = TRUE;
 size = sizeof(DI_PATH_MAX);

 /* Set processor structure info */
 processor.processor_function = PDUextract_ref_file_description;
 processor.info = NULL;

 /* Loop thru all 1st level ref objects */
 for (i = 0; i < ref_count; ++i)
     {
      _pdm_debug("calling GRreffile.GRinquireref", 0);

      status = om$send(
                       msg = message GRreffile.GRinquireref(
                                                            &msg,
                                                            &mod_env,
                                                            ref_list,
                                                            &size,
                                                            &pass_on,
                                                            &processor
                                                           ),
                       senderid = mod_env.md_id.objid,
                       targetid = ref_objects[i].objid,
                       targetos = ref_objects[i].osnum
                      );

     } /* end for loop */

  return(PDM_S_SUCCESS);
 }


/*
 * This function checks to see if PDU parts exist in active object space.
 */
IGRint  PDUdo_parts_exist(invis_flag, osnum)
  IGRshort     invis_flag;          /* INPUT */
  OMuword      osnum;               /* INPUT */
 {
  IGRlong      status = PDM_S_SUCCESS;
  IGRint       count = 0;
  IGRchar      parts_dir[DI_PATH_MAX];
  IGRchar      **lines;
  IGRint       nb_lines;
  OM_S_OBJID   osid = NULL_OBJID;
  struct GRid  dir_grid;


  _pdm_debug("In the PDUdo_parts_exist function", 0);

  if (!invis_flag)
     {
      /* Get active module info */
      status = ex$get_cur_mod ( id = &osid, osnum = &osnum );
      _pdm_status("ex$get_cur_mod", status);
     }

  /* Check to see if parametric parts exist */
  if (get_nblines_in_dir(
                         &nb_lines,
                         &lines,
                         &dir_grid,
                         osnum
                        )
     )
     {
      _pdm_debug("parametric parts exist", 0);

      /* Free lines */
      if (lines)
         {
          di$free(lines = lines, count = nb_lines);
          return(1);
         }
     }

  /* Check to see if "parts" directory exists */
  di$give_pathname(
                   osnum = osnum,
                   pathname = parts_dir
                  );

  strcat(parts_dir,":parts");

  di$ls(regexp = parts_dir, ptr = &count);

  if (count <= 0)
     {
      _pdm_debug("no parts found in object space", 0);
      return(0);
     } 

  /* Parts directory may exist, but may be empty */
  count = 0;
  status = di$find (
                    start_dir = parts_dir,
                    regexp = "*",
                    ptr = &count,
                    max_level = -1
                   );

  if (status != DIR_S_SUCCESS)
     {
      _pdm_debug("no parts were found in object space", 0);
      return(0);
     }

  if (count <= 0)
     {
      _pdm_debug("no parts were found in object space", 0);
      return(0);
     }

  return(1);
 }

/*
 * This function checks to see if a part exists in active object space.
 */
IGRint  PDUdoes_part_exist(
                           catalog,
                           number,
                           revision
                          )

 IGRchar       *catalog;           /* INPUT */
 IGRchar       *number;            /* INPUT */
 IGRchar       *revision;          /* INPUT */
 {
  IGRlong      status = PDM_S_SUCCESS;
  OMuword      osnum;
  IGRint       count = 0;
  IGRchar      part_dir[DI_PATH_MAX];
  IGRchar      s[DI_PATH_MAX];
  OM_S_OBJID   osid = NULL_OBJID;
  struct GRid  *part_ids = NULL;

  _pdm_debug("In the PDUdoes_part_exists function", 0);

  /* Get active module info */
  status = ex$get_cur_mod ( id = &osid, osnum = &osnum );
  _pdm_status("ex$get_cur_mod", status);

  /* Construct path to part directory */
  di$give_pathname(
                   osnum = osnum,
                   pathname = part_dir
                  );

  /* Construct path to part directory */
  sprintf(
          s,
          "%s:parts:%s:%s!%s:",
          part_dir,
          catalog,
          number,
          revision
         );

  status = PDUget_GRparts_ids(
                              s,
                              &part_ids,
                              &count
                             );
  _pdm_status("PDUget_GRparts_ids", status);

  if (count <= 0)
     {
      _pdm_debug("part does not exist in active obj space", 0);
      return(0);
     }

  /* Free variables */
  if (part_ids)
     free(part_ids);

  return(1);
 }

/*
 * This function checks to see if PDU positionless parts exist in 
 * the active object space.
 */
IGRint  PDUdo_positionless_parts_exist()
 {
  IGRlong                   status = PDM_S_SUCCESS;
  IGRlong                   msg;
  IGRchar                   serial_no[MAX_VALUE];
  IGRchar                   part_type[MAX_VALUE];
  IGRint                    count = 0;
  IGRint                    type;
  struct GRmd_env           mod_env;
  struct PDUpart_node       *parts_ids = NULL;
  struct PDUpart_node       *head = NULL;
  IGRlong                   NumberOfBytes, BytesReceived;

  _pdm_debug("In the PDUdo_positionless_parts_exist function", 0);

  /* Get active module environment */
  NumberOfBytes = sizeof(mod_env);
  status = gr$get_module_env(
                             msg = &msg,
                             sizbuf = &NumberOfBytes,
                             buffer = &mod_env,
                             nret = &BytesReceived
                            );

  /* Extract PDU GRparts from active obj space */
  status = PDUget_all_GRpart_ids(
                                 mod_env.md_id.osnum,
                                 &parts_ids,
                                 &count
                                );
  _pdm_status("PDUget_all_GRpart_ids", status);

  /* Check to see if there are any positionless parts */
  if (count > 0)
     {
      head = parts_ids;
      while (head)
            {
             /* Extract serial no from GRparts */
             co$part_get_attr (
                               msg = &msg,
                               mod_env = &mod_env,
                               part = &(head->part_id),
                               attr = "serial",
                               value = serial_no,
                               type = &type
                              );

             /* Extract part type from GRpart */
             co$part_get_attr (
                               msg = &msg,
                               mod_env = &mod_env,
                               part = &(head->part_id),
                               attr = "part_type",
                               value = part_type,
                               type = &type
                              );

             /* Check to see if part is positionless */
             if ( (strcmp(serial_no, "-1.000000") == 0) &&
                  (strcmp(part_type, "n") != 0) &&
                  (strcmp(part_type, "N") != 0) )
                {
                 _pdm_debug("at least one positionless part was found", 0);

                 /* Free parts_ids */
                 if (parts_ids)
                    {
                     head = parts_ids;
              
                     while (parts_ids)
                           {
                            parts_ids = parts_ids->next;
                            free(head);
                            head = parts_ids;
                           }
                    }

                 return(1);
                }

             /* Process next part */
             head = head->next;
            }
     }

  else
      {
       _pdm_debug("no PDU parts found in active obj space", 0);
       return(0);
      }

 /* Free parts_ids */
 if (parts_ids)
    {
     head = parts_ids;

     while (parts_ids)
           {
            parts_ids = parts_ids->next;
            free(head);
            head = parts_ids;
           }
    }

 return(0);
 }

/* 
 * This function initializes pointers used in replace command.
 */
IGRint PDUinitialize_replace_pointers()
 {
  _pdm_debug("PDUinitialize_replace_pointers", 0);

  PDU_src_part_id = NULL;
  PDU_dst_part_id = NULL;
  PDU_part_id = NULL;
  PDU_origin_id = NULL;
  PDU_parts_id_list = NULL;
  PDU_origins_id_list = NULL;
  PDU_queue_info = NULL;

  return(1);
 }

/*
 * This function extracts all PDU parts catalogs from the obj space.
 */
IGRint  PDUlist_catalogs_in_obj_space(
                                      osnum,
                                      disp_bufr
                                     )
 OMuword     osnum;
 MEMptr      *disp_bufr;
 {
  IGRlong    status = PDM_S_SUCCESS;
  IGRchar    parts_path[DI_PATH_MAX];
  IGRchar    **catalogs = NULL;
  IGRchar    *catalog_name = NULL;
  IGRchar    *row = NULL;
  IGRint     count = 0;
  IGRint     i;
  OM_S_OBJID osid;

  _pdm_debug("In the PDUlist_catalogs_in_obj_space function", 0);

  /* Check if need to get active design module info */
  if (osnum == 0)
     {
     /* Get active module info */
     status = ex$get_cur_mod ( id = &osid, osnum = &osnum );
     _pdm_status("ex$get_cur_mod", status);
     }

  /* Extract part obj space path */
  di$give_pathname(
                   osnum = osnum,
                   pathname = parts_path
                  );

  /* Construct parts path */
  strcat(parts_path, ":parts");

  /* Extract all catalogs under the parts directory */
  status = di$find(
                   start_dir = parts_path,
                   regexp = "*",
                   lines = &catalogs,
                   ptr = &count,
                   max_level = 1
                  );

  if ( (status != DIR_S_SUCCESS) || (count <= 0) )
     {
      _pdm_debug("no catalogs found", 0);
      return(PDM_S_SUCCESS); 
     }

  /* Need to load catalogs to a display buffer */
  if (count > 0)
     {
      /* Open display buffer */
      PDMopen_buffer(8, disp_bufr);

      row = (IGRchar *) malloc (sizeof(IGRchar) * (*disp_bufr)->row_size);
      memset(row, NULL, sizeof(IGRchar) * (*disp_bufr)->row_size);

      for (i = 0; i < count; ++i)
          {
           PDUstrip_dir_entry(catalogs[i]);
           ++catalog_name;

           if (strcmp(catalog_name, "local") != 0)
              {
               /* Write row to buffer */
               sprintf(row, "%s\1", catalog_name);
               MEMwrite(*disp_bufr, row);
              }
          }

      /* Need to free variables */
      if (catalogs)
         di$free(lines = catalogs, count = count);

      if (row)
         free(row);
     }

  return(status);
 } 

/*
 * This function extracts all PDU parts in a catalog from the active obj space.
 */
IGRint  PDUlist_parts_in_obj_space(
                                   catalog,
                                   disp_bufr
                                  )
 IGRchar     *catalog;
 MEMptr      *disp_bufr;
 {
  IGRlong    msg;
  IGRlong    status = PDM_S_SUCCESS;
  IGRchar    parts_path[DI_PATH_MAX];
  IGRchar    description[MAX_VALUE];
  IGRchar    part_type[MAX_VALUE];
  IGRchar    **parts = NULL;
  IGRchar    *number = NULL;
  IGRchar    *revision = NULL;
  IGRchar    *row = NULL;
  IGRint     count = 0;
  IGRint     type;
  IGRint     i;
  struct     GRmd_env  mod_env;
  IGRlong    NumberOfBytes, BytesReceived;

  _pdm_debug("In the PDUlist_parts_in_obj_space function", 0);

  /* Get active module information */
  NumberOfBytes = sizeof(mod_env);
  status = gr$get_module_env(
                             msg = &msg,
                             sizbuf = &NumberOfBytes,
                             buffer = &mod_env,
                             nret = &BytesReceived
                            );

  /* Extract part obj space path */
  di$give_pathname(
                   osnum = mod_env.md_id.osnum,
                   pathname = parts_path
                  );

  /* Construct parts path */
  strcat(parts_path, ":parts:");
  strcat(parts_path, catalog);

  /* Extract all parts under the given catalog */
  status = di$find(
                   start_dir = parts_path,
                   regexp = "*",
                   lines = &parts,
                   ptr = &count,
                   max_level = 1
                  );

  if ( (status != DIR_S_SUCCESS) || (count <= 0) )
     {
      _pdm_debug("no parts found", 0);
      return(PDM_S_SUCCESS); 
     }

  /* Need to load parts to a display buffer */
  if (count > 0)
     {
      /* Open display buffer */
      PDMopen_buffer(9, disp_bufr);

      row = (IGRchar *) malloc (sizeof(IGRchar) * (*disp_bufr)->row_size);
      memset(row, NULL, sizeof(IGRchar) * (*disp_bufr)->row_size);

      for (i = 0; i < count; ++i)
          {
           /* Extract revision */
           PDUstrip_dir_entry(parts[i]);
           revision = (IGRchar *)strrchr(parts[i], '!');
           ++revision;

           /* Extract number */
           *((IGRchar *)strrchr(parts[i], '!')) = '\0';
           number = (IGRchar *)strrchr(parts[i], ':');
           ++number;

           /* Extract description */
           co$part_get_attr (
                             msg = &msg,
                             mod_env = &mod_env,
                             catalog = catalog,
                             number = number,
                             revision = revision,
                             attr = "NAME",
                             value = description,
                             type = &type
                            );

           /* Extract part type */
           co$part_get_attr (
                             msg = &msg,
                             mod_env = &mod_env,
                             catalog = catalog,
                             number = number,
                             revision = revision,
                             attr = "part_type",
                             value = part_type,
                             type = &type
                            );

           /* Write row to buffer */
           sprintf(
                   row,
                   "%s\1%s\1%s\1%s\1",
                   number,
                   revision,
                   description,
                   part_type 
                  );
           MEMwrite(*disp_bufr, row);
          }

      /* Need to free variables */
      if (parts)
         di$free(lines = parts, count = count);

      if (row)
         free(row);
     }

  return(status);
 } 

/*
 * This function, given a part catalog and nubmer, extracts all the revisions
 * from the object space. 
 */
IGRint  PDUlist_revisions_in_obj_space(
                                       osnum,
                                       catalog,
                                       number,
                                       disp_bufr
                                      )
 OMuword     osnum;
 IGRchar     *catalog;
 IGRchar     *number;
 MEMptr      *disp_bufr;
 {
  IGRlong    status = PDM_S_SUCCESS;
  IGRchar    parts_path[DI_PATH_MAX];
  IGRchar    regexp[DI_PATH_MAX];
  IGRchar    **revisions = NULL;
  IGRchar    *revision_name = NULL;
  IGRchar    *row = NULL;
  IGRint     count = 0;
  IGRint     i;
  OM_S_OBJID osid;

  _pdm_debug("In the PDUlist_revisions_in_obj_space function", 0);

  /* Check if need to get active design module info */
  if (osnum == 0)
     {
     /* Get active module info */
     status = ex$get_cur_mod ( id = &osid, osnum = &osnum );
     _pdm_status("ex$get_cur_mod", status);
     }

  /* Extract part obj space path */
  di$give_pathname(
                   osnum = osnum,
                   pathname = parts_path
                  );

  /* Construct parts path */
  strcat(parts_path, ":parts:");
  strcat(parts_path, catalog);

  /* Construct regular expression */
  strcpy(regexp, number);
  strcat(regexp, "!*");

  /* Extract all revisions under the parts directory */
  status = di$find(
                   start_dir = parts_path,
                   regexp = regexp,
                   lines = &revisions,
                   ptr = &count,
                   max_level = 1
                  );

  if ( (status != DIR_S_SUCCESS) || (count <= 0) )
     {
      _pdm_debug("no revisions found", 0);
      return(PDM_S_SUCCESS); 
     }

  /* Need to load revisions to a display buffer */
  if (count > 0)
     {
      /* Open display buffer */
      PDMopen_buffer(10, disp_bufr);

      row = (IGRchar *) malloc (sizeof(IGRchar) * (*disp_bufr)->row_size);
      memset(row, NULL, sizeof(IGRchar) * (*disp_bufr)->row_size);

      for (i = 0; i < count; ++i)
          {
           PDUstrip_dir_entry(revisions[i]);
           revision_name = (IGRchar *)strrchr(revisions[i], '!');
           ++revision_name;

           /* Write row to buffer */
           sprintf(row, "%s\1", revision_name);
           MEMwrite(*disp_bufr, row);
          }

      /* Need to free variables */
      if (revisions)
         di$free(lines = revisions, count = count);

      if (row)
         free(row);
     }

  return(status);
 } 

/*
 * This function lists the usage ids for all PDU GRparts from the
 * active object space.
 */
IGRint  PDUlist_usage_ids_in_obj_space(disp_bufr)
 MEMptr      *disp_bufr;    /* OUTPUT */
 {
  IGRlong                   status = PDM_S_SUCCESS;
  IGRlong                   msg;
  IGRchar                   value[MAX_VALUE];
  IGRchar                   *row = NULL;
  IGRint                    count = 0;
  IGRint                    type;
  struct GRmd_env           mod_env;
  struct PDUpart_node       *parts_ids = NULL;
  struct PDUpart_node       *head = NULL;
  IGRlong                   NumberOfBytes, BytesReceived;

  _pdm_debug("In the PDUlist_usage_ids_in_obj_space function", 0);

  /* Get active module environment */
  NumberOfBytes = sizeof(mod_env);
  status = gr$get_module_env(
                             msg = &msg,
                             sizbuf = &NumberOfBytes,
                             buffer = &mod_env,
                             nret = &BytesReceived
                            );

  /* Extract PDU GRparts from active obj space */
  status = PDUget_all_GRpart_ids(
                                 mod_env.md_id.osnum,
                                 &parts_ids,
                                 &count
                                );
  _pdm_status("PDUget_all_GRpart_ids", status);

  /* Need to load usage ids to a display buffer */
  if (count > 0)
     {
      /* Open display buffer */
      PDMopen_buffer(11, disp_bufr);

      row = (IGRchar *) malloc (sizeof(IGRchar) * (*disp_bufr)->row_size);
      
      head = parts_ids;
      while (head) 
            {
             /* Extract usage id from GRparts */
             co$part_get_attr (
                               msg = &msg,
                               mod_env = &mod_env,
                               part = &(head->part_id),
                               attr = "usage_id",
                               value = value,
                               type = &type 
                              );

             /* Unquote usage id */
             PDUunquote(value);

             /* Write row to buffer */
             memset(row, NULL, sizeof(IGRchar) * (*disp_bufr)->row_size);
             sprintf(row, "%s\1", value);
             MEMwrite(*disp_bufr, row);

             /* Process next part */
             head = head->next;
            }

      /* Need to free variables */
      if (parts_ids)
         {
          head = parts_ids;

          while (parts_ids)
                {
                 parts_ids = parts_ids->next;
                 free(head);
                 head = parts_ids;
                }
         }

      if (row)
         free(row);

      status = PDM_S_SUCCESS;
     }

  else
      {
       _pdm_debug("no usage ids found in obj space", 0);
       status = PDM_S_SUCCESS;
      }

  return(status);
 }

/*
 * This function, given a catalog, part number, and  revision, extracts all 
 * usage ids in the active object space.
 */
IGRint  PDUlist_part_usage_ids_in_obj_space(
                                            catalog,
                                            number,
                                            revision,
                                            disp_bufr
                                           )
 IGRchar     *catalog;                 /* INPUT */
 IGRchar     *number;                  /* INPUT */
 IGRchar     *revision;                /* INPUT */
 MEMptr      *disp_bufr;               /* OUTPUT */
 
 {
  IGRlong                   status = PDM_S_SUCCESS;
  IGRlong                   msg;
  IGRchar                   value[MAX_VALUE];
  IGRchar                   *row = NULL;
  IGRint                    i;
  IGRint                    count = 0;
  IGRint                    type;
  IGRchar                   part_dir[DI_PATH_MAX];
  IGRchar                   s[DI_PATH_MAX];
  struct GRmd_env           mod_env;
  struct GRid               *part_ids = NULL;
  IGRlong                   NumberOfBytes, BytesReceived;

  _pdm_debug("In the PDUlist_part_usage_ids_in_obj_space function", 0);

  /* Get active module environment */
  NumberOfBytes = sizeof(mod_env);
  status = gr$get_module_env(
                             msg = &msg,
                             sizbuf = &NumberOfBytes,
                             buffer = &mod_env,
                             nret = &BytesReceived
                            );
  
  /* Construct path to part directory */
  di$give_pathname(
                   osnum = mod_env.md_id.osnum,
                   pathname = part_dir
                  );

  /* Construct path to part directory */
  sprintf(
          s,
          "%s:parts:%s:%s!%s:",
          part_dir,
          catalog,
          number,
          revision
         );

  /* Extract PDU GRparts from active obj space */
  status = PDUget_GRparts_ids(
                              s,
                              &part_ids,
                              &count
                             );
  _pdm_status("PDUget_GRparts_ids", status);

  /* Need to load part usage ids to a display buffer */
  if (count > 0)
     {
      /* Open display buffer */
      PDMopen_buffer(11, disp_bufr);

      row = (IGRchar *) malloc (sizeof(IGRchar) * (*disp_bufr)->row_size);

      for (i = 0; i < count; ++i)
          {
           /* Extract usage id from GRparts */
           co$part_get_attr (
                             msg = &msg,
                             mod_env = &mod_env,
                             part = &part_ids[i],
                             attr = "usage_id",
                             value = value,
                             type = &type
                            );

           /* Unquote usage id */
           PDUunquote(value);

           /* Write row to buffer */
           memset(row, NULL, sizeof(IGRchar) * (*disp_bufr)->row_size);
           sprintf(row, "%s\1", value);
           MEMwrite(*disp_bufr, row);

          } /* end for loop */

      /* Need to free variables */
      if (part_ids)
         free(part_ids);

      if (row)
         free(row);

      status = PDM_S_SUCCESS;
     }

  else
      {
       _pdm_debug("no usage ids found for this part in obj space", 0);
       status = PDM_S_SUCCESS;
      }

  return(status);
 }

/* This function extracts the part type for a given part from the active 
 * object space.
 */
IGRint  PDUextract_part_type_from_obj_space(
                                            catalog,
                                            number,
                                            revision,
                                            part_type
                                           )
  IGRchar    *catalog;
  IGRchar    *number;
  IGRchar    *revision;
  IGRchar    **part_type;
  {
   IGRlong    status = PDM_S_SUCCESS;
   IGRlong    msg;
   IGRint     type;
   IGRchar    value[MAX_VALUE];
   struct     GRmd_env  mod_env;
   IGRlong    NumberOfBytes, BytesReceived;

   _pdm_debug("In the PDUextract_part_type_from_obj_space function", 0);
 
  /* Get active module information */
  NumberOfBytes = sizeof(mod_env);
  status = gr$get_module_env(
                             msg = &msg,
                             sizbuf = &NumberOfBytes,
                             buffer = &mod_env,
                             nret = &BytesReceived
                            );

   /* Extract part type */
   co$part_get_attr (
                     msg = &msg,
                     mod_env = &mod_env,
                     catalog = catalog,
                     number = number,
                     revision = revision,
                     attr = "part_type",
                     value = value,
                     type = &type
                    );

   if (msg == MSSUCC)
      {
       PDUfill_in_string(part_type, value);
       status = PDM_S_SUCCESS;
      }

   else
      {
       _pdm_debug("co$part_get_attr failed", 0);
      }

   return(status);
  }

/* This function removes all parts in the assembly structure that do not 
 * exist as GRparts in a given object space.
 */
IGRint  PDUremove_non_existent_parts_from_assy_struct(mod_env)
 struct     GRmd_env    mod_env;
 {
  IGRlong  msg;
  IGRlong  status = PDM_S_SUCCESS;
  IGRchar  assy_path[DI_PATH_MAX];
  IGRchar  part_path[DI_PATH_MAX];
  IGRchar  **parts;
  IGRchar  *child_value = NULL;
  IGRchar  attr_value[MAX_VALUE];
  IGRint   total_count = 0;
  IGRint   part_count = 0;
  IGRint   type;
  IGRint   i;
  IGRshort found;
  struct   PDUpart_node      *parts_ids = NULL;
  struct   PDUpart_node      *head = NULL;
  

  _pdm_debug("In the PDUremove_non_existent_parts_from_assy_struct function",0);
  
  /* Get obj ids off all PDU GRparts in obj space */
  status = PDUget_all_GRpart_ids(
                                 mod_env.md_id.osnum,
                                 &parts_ids,
                                 &total_count
                                );
  _pdm_status("PDUget_all_GRpart_ids", status);

  /* Construct path to assy struc in obj space */
  di$give_pathname(
                   osnum = mod_env.md_id.osnum,
                   pathname = assy_path 
                  );

  strcat(assy_path, ":ASSEMBLY");
  _pdm_debug("full path to ASSEMBLY dir = <%s>", assy_path);

 if (!parts_ids)
    {
     status = PDUremove_assembly(assy_path, &mod_env);
     _pdm_status("PDUremove_assembly", status);
     return(status);
    }

  /* Extract all first-level parts in assy struct */
  status = di$find (
                    start_dir = assy_path,
                    regexp = "P*",
                    lines = &parts,
                    ptr = &part_count,
                    max_level = 1
                   );

  if ( (status == DIR_S_SUCCESS) && (part_count > 0) )
     {
      /* Loop thru removing non-existing parts from assy struct */
      for (i = 0; i < part_count; ++i)
          {
           /* Get the child attached attribute */
           PDUstrip_dir_entry(parts[i]);

           status = PDUevaluate_exp(
                                    parts[i],
                                    "child_no",
                                    &child_value
                                   );
           _pdm_status("PDUevaluate_exp", status);

           found = FALSE;
           head = parts_ids;
           while (head)
                 {
                  /* Extract child no from GRpart */
                  co$part_get_attr (
                                    msg = &msg,
                                    mod_env = &mod_env,
                                    part = &(head->part_id),
                                    attr = "child_no",
                                    value = attr_value,
                                    type = &type
                                   );

                  /* Unquote child no */
                  PDUunquote(attr_value);

                  if (strcmp(attr_value, child_value) == 0)
                     {
                      _pdm_debug("part exists as GRpart", 0);
                      found = TRUE;
                      break;
                     }

                   /* Move to next part */
                   head = head->next;

                 } /* End while loop */

           /* Delete part from assy if not found as GRpart */
           if (!found)
              {
               strcpy(part_path, assy_path);
               strcat(part_path, ":P");
               strcat(part_path, child_value);

               status = PDUremove_assembly(part_path, &mod_env);
               _pdm_status("PDUremove_assembly", status);
              }
          } /* end for loop */

      /* Free variables */
      if (parts)
         di$free(lines = parts, count = part_count);

      if (parts_ids)
         {
          head = parts_ids;

          while (parts_ids)
                {
                 parts_ids = parts_ids->next;
                 free(head);
                 head = parts_ids;
                }
         }

      if (child_value)
         free(child_value);
     }

  else
     {
      _pdm_debug("no parts found in assembly", 0);
      return(0);
     }
  
  return(status);
 }

/* 
 * This function creates a unique list of active obj ref file names.
 */
 IGRint PDUprocess_ref_files(   
                             msg,
                             inquire_requests,
                             processor_info,
                             nest_indicator
                            )
 IGRlong                *msg;
 struct GRinquire_list  inquire_requests[2];
 IGRchar                *processor_info;
 IGRint                 *nest_indicator;
 {
  struct PDUref_node             *temp = NULL;
  struct PDUref_node             *head = NULL;
  struct PDUref_node             *tail = NULL;
  IGRshort                       add_file;

  _pdm_debug("In the PDUprocess_ref_files function", 0);

  if (*nest_indicator != 0)
     {
      _pdm_debug("processing inquirey across spaces... ", 0);
      return(PDM_S_SUCCESS);
     }

   /* Check to see file name does not already exist in global list */
   add_file = TRUE;

   if (PDU_ref_filenames)
      {
       head = PDU_ref_filenames;
       while (head)
             {
              if (strcmp(head->filename, inquire_requests[0].var_ptr) == 0)
                 {
                  _pdm_debug("file name already exists", 0);
                  add_file = FALSE;
                  break;
                 }
               head = head->next;
              }
       }

   /* Check to see if ref file is not background or not loaded */
   if ( (*((unsigned short *)inquire_requests[1].var_ptr) & GRRF_UNLOADED) ||
        (*((unsigned short *)inquire_requests[1].var_ptr) & GRRF_BACKGROUND) )
      {
       _pdm_debug("file <%s> is not loaded", inquire_requests[0].var_ptr);
       add_file = FALSE;
      }

   if (add_file == TRUE)
      {
       /* Add ref. name to ref_names list */
       temp = (struct PDUref_node *) malloc(sizeof(struct PDUref_node));

       /* Initialize temp fields */
       temp->description = NULL;
       temp->filename = NULL;
       (temp->ref_id).objid =
                            ((struct GRid *)inquire_requests[2].var_ptr)->objid;
       (temp->ref_id).osnum =
                            ((struct GRid *)inquire_requests[2].var_ptr)->osnum;
  
       temp->next = NULL;

       PDUfill_in_string(&(temp->filename), inquire_requests[0].var_ptr);

       if (PDU_ref_filenames)
          {
           _pdm_debug("adding node to end of list", 0);

           tail = PDU_ref_filenames;
           while (tail->next)
                 {
                  tail = tail->next;
                 }

           tail->next = temp;
          }

       else
           {
            _pdm_debug("adding first node to list", 0);
            PDU_ref_filenames = temp;
           }
       }

  return(PDM_S_SUCCESS);
 }

/*
 * This function creates a unique list of PDU ref file descriptions.
 */
 IGRint PDUextract_ref_file_description(
                                        msg,
                                        inquire_requests,
                                        processor_info,
                                        nest_indicator
                                       )
 IGRlong                *msg;
 struct GRinquire_list  inquire_requests[2];
 IGRchar                *processor_info;
 IGRint                 *nest_indicator;
 {
  struct PDUref_node             *temp = NULL;
  struct PDUref_node             *head = NULL;
  struct PDUref_node             *tail = NULL;
  IGRshort                       add_description;

  _pdm_debug("In the PDUextract_ref_file_description function", 0);

  if (*nest_indicator != 0)
     {
      _pdm_debug("processing inquirey across spaces... ", 0);
      return(PDM_S_SUCCESS);
     }

   _pdm_debug("ref desc = <%s>",
      ((struct GRref_instance_data *)inquire_requests[0].var_ptr)->description);


   /* Make sure description is a PDU one */
   if (
       strncmp(
       ((struct GRref_instance_data *)inquire_requests[0].var_ptr)->description,
       "PDU",
       3
       ) != 0
      )
      {
       _pdm_debug("Encountered a non PDU ref description", 0);
       return(PDM_S_SUCCESS);
      }

   /* Check to see description does not already exist in global list */
   add_description = TRUE;

   if (PDU_ref_filenames)
      {
       head = PDU_ref_filenames;
       while (head)
             {
              if (strcmp(head->description,
                        ((struct GRref_instance_data *)
                          inquire_requests[0].var_ptr)->description) == 0 )
                 {
                  _pdm_debug("ref description already exists", 0);
                  add_description = FALSE;
                  break;
                 }
               head = head->next;
              }
       }

    if (add_description == TRUE)
      {
       /* Add ref. description to PDU_ref_filenames list */
       temp = (struct PDUref_node *) malloc(sizeof(struct PDUref_node));

       /* Initialize temp fields */
       temp->filename = NULL;
       temp->description = NULL;
       temp->next = NULL;

       PDUfill_in_string(&(temp->description),
       ((struct GRref_instance_data*)inquire_requests[0].var_ptr)->description);

       if (PDU_ref_filenames)
          {
           _pdm_debug("adding node to end of list", 0);

           tail = PDU_ref_filenames;
           while (tail->next)
                 {
                  tail = tail->next;
                 }

           tail->next = temp;
          }

       else
           {
            _pdm_debug("adding first node to list", 0);
            PDU_ref_filenames = temp;
           }
       }

  _pdm_debug("exiting PDUextract_ref_file_description function", 0);

  return(PDM_S_SUCCESS);
 }


/*
 * This function removes the stamp PDU_DESIGN_FILE from the given space.
 */
IGRint  PDUremove_PDU_file_stamp(mod_env)
 struct GRmd_env  mod_env;
 {
  IGRlong    status = PDM_S_SUCCESS;
  IGRchar    stamp_dir[DI_PATH_MAX];

  _pdm_debug("In the PDUremove_PDU_file_stamp", 0);

  /* Construct path to stamp directory */
  di$give_pathname(
                   osnum = mod_env.md_id.osnum,
                   pathname = stamp_dir
                  );

  strcat(stamp_dir, ":PDU_DESIGN_FILE:");

  /* Remove stamp, if it exists */
  status = di$rmdir(dirname = stamp_dir, path = NULL);
  _pdm_status("di$rmdir", status);

  return(status);
 }


/*
 * This function creates the stamp PDU_DESIGN_FILE in the given space.
 */
IGRint  PDUstamp_PDU_design_file(mod_env)
 struct GRmd_env  mod_env;
 {
  IGRlong    status = PDM_S_SUCCESS;
  IGRchar    stamp_dir[DI_PATH_MAX];

  _pdm_debug("In the PDUstamp_PDU_design_file", 0);

  /* Construct path to stamp directory */
  di$give_pathname(
                   osnum = mod_env.md_id.osnum,
                   pathname = stamp_dir
                  );

  strcat(stamp_dir, ":PDU_DESIGN_FILE:");

  /* Create stamp */
  _pdm_debug("stamp_dir = <%s>", stamp_dir);
  status = di$mkpath(pathname = stamp_dir);
  _pdm_status("di$mkpath", status);

  return(status);
 }


/*
 * This function extracts the instance data structure for the given ref objid. 
 */
IGRint  PDUget_ref_instance_data(ref_id, ref_instance)
 struct  GRid                        ref_id;
 struct  GRref_instance_data         *ref_instance;
 {
  IGRlong                        msg = MSSUCC;
  IGRlong                        status = PDM_S_SUCCESS;
  IGRint                         size;
  struct  GRinquire_list         ref_list[2];
  IGRboolean                     pass_on;
  struct  GRmd_env               mod_env;
  IGRlong                        NumberOfBytes, BytesReceived;


 _pdm_debug("In the PDUget_ref_instance_data function", 0);

 /* Get active module information */
 NumberOfBytes = sizeof(mod_env);
 status = gr$get_module_env(
                            msg = &msg,
                            sizbuf = &NumberOfBytes,
                            buffer = &mod_env,
                            nret = &BytesReceived
                           );

 /* Set ref. request */
 ref_list[0].var = REFERENCE_INSTANCE_DATA;
 ref_list[0].var_ptr = (IGRchar *)ref_instance;
 ref_list[0].num_requested = sizeof(struct GRref_instance_data);
 ref_list[1].var = END_REPORT_REQUEST;
 pass_on = FALSE;
 size = sizeof(DI_PATH_MAX);

 status = om$send(
                  msg = message GRreffile.GRinquireref(
                                                       &msg,
                                                       &mod_env,
                                                       ref_list,
                                                       &size,
                                                       &pass_on,
                                                       NULL 
                                                      ),
                  senderid = mod_env.md_id.objid,
                  targetid = ref_id.objid,
                  targetos = ref_id.osnum
                 );
  _pdm_status("om$send", status);

  return(PDM_S_SUCCESS);
 }

/*
 * This function extracts all PDU parts in active obj space 2.01.
 */
IGRint  PDUlist_all_parts_in_os(
                                flag,
                                parts_bufr
                               )
 IGRshort    flag;
 MEMptr      *parts_bufr;
 {
  IGRlong    msg;
  IGRlong    status = PDM_S_SUCCESS;
  IGRchar    value[MAX_VALUE];
  IGRchar    part_type[MAX_VALUE];
  IGRchar    serial_no[MAX_VALUE];
  IGRchar    *catalog = NULL;
  IGRchar    *number = NULL;
  IGRchar    *revision = NULL;
  IGRchar    *quantity = NULL;
  IGRchar    *usage_id = NULL;
  IGRchar    *row = NULL;
  IGRchar    *attr_name = NULL;
  IGRint     count1 = 0;
  IGRint     count2 = 0;
  IGRint     type;
  IGRint     i;
  IGRchar    **params = NULL;
  IGRchar    **param_vals = NULL;
  struct     GRmd_env  mod_env;
  struct     PDUpart_node      *parametric_ids = NULL;
  struct     PDUpart_node      *parts_ids = NULL;
  struct     PDUpart_node      *head = NULL;
  IGRlong    NumberOfBytes, BytesReceived;
 

  _pdm_debug("In the PDUlist_all_parts_in_os function", 0);

  /* Get active module information */
  NumberOfBytes = sizeof(mod_env);
  status = gr$get_module_env(
                             msg = &msg,
                             sizbuf = &NumberOfBytes,
                             buffer = &mod_env,
                             nret = &BytesReceived
                            );

  /* Get id's of PDU GRparts */
  status = PDUget_all_GRpart_ids(
                                 mod_env.md_id.osnum,
                                 &parts_ids,
                                 &count1
                                );
  _pdm_status("PDUget_all_GRpart_ids", status);

  /* Get id's of PDU parametric parts */
  status = PDUget_all_parametric_ids(
                                     mod_env.md_id.osnum,
                                     &parametric_ids,
                                     &count2
                                    );
  _pdm_status("PDUget_all_parametric_ids", status);

  if (count1 + count2)
     _pdm_debug("total parts found in os = %d", count1 + count2);

  /* Need to load parts to a parts buffer */
  if (count1 + count2 > 0)
     {
      /* Open parts list buffer */
      status = PDUformat_os_parts_bufr(parts_bufr);
      _pdm_status("PDUformat_os_parts_bufr", status);

      switch(flag)
            {
             case 0:
                    /* Return buffer with all parts loaded */
                     row = (IGRchar *)
                           malloc (sizeof(IGRchar) * (*parts_bufr)->row_size);

                     head = parts_ids;

                     while (head) 
                         {
                          memset(row, NULL,
                                 sizeof(IGRchar) * (*parts_bufr)->row_size);

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

                          /* Write row to parts buffer */
                          sprintf(
                                  row,
                                  "%s\1%s\1%s\1%s\1%s\1",
                                  catalog,
                                  number, 
                                  revision,
                                  quantity,
                                  usage_id
                                 );

                          _pdm_debug("row = <%s>", row);

                          MEMwrite(*parts_bufr, row);

                          /* Process next part */
                          head = head->next;

                         } /* end while loop */

                    /* Load parametric parts info, if any */
                    if (count2)
                       {
                        /* Allocate at least 80 chars for attr_name */
                        attr_name = (IGRchar *) malloc(sizeof(IGRchar) * 80);

                        memset(attr_name, NULL, sizeof(IGRchar) * 80);

                        memset(row, NULL,
                                 sizeof(IGRchar) * (*parts_bufr)->row_size);

                        head = parametric_ids;
                        while (head)
                            {
                             _pdm_debug("processing parametric id %d",
                                        head->part_id.objid);

                             /* Extract certain macro part attributes */
                             params = (IGRchar **) malloc(5*sizeof(IGRchar *));
                             memset((IGRchar *)params,NULL,5*sizeof(IGRchar *));
                             
                             PDUfill_in_string(&params[0], "n_catalogname");
                             PDUfill_in_string(&params[1], "n_itemname");
                             PDUfill_in_string(&params[2], "n_itemrev");
                             PDUfill_in_string(&params[3], "p_quantity");
                             PDUfill_in_string(&params[4], "p_usageid");

                             status = get_parameter_values(
                                                           &(head->part_id),
                                                           params,
                                                           5,
                                                           &param_vals
                                                          );

                             if (!status)
                                {
                                 _pdm_debug("get_parameter_values failed", 0);
                                 return(status);
                                }

                             else
                                 {
                                  PDUfill_in_string(&catalog, param_vals[0]);
                                  PDUfill_in_string(&number, param_vals[1]);
                                  PDUfill_in_string(&revision, param_vals[2]);
                                  PDUfill_in_string(&quantity, param_vals[3]);
                                  PDUfill_in_string(&usage_id, param_vals[4]);
                                 }

                             /* Write row to parts buffer */
                             sprintf(
                                     row,
                                     "%s\1%s\1%s\1%s\1%s\1",
                                     catalog,
                                     number,
                                     revision,
                                     quantity,
                                     usage_id
                                    );

                             _pdm_debug("row = <%s>", row);

                             MEMwrite(*parts_bufr, row);

                             head = head->next;

                            } /* end while loop */
                       }

                    status = PDM_S_SUCCESS;

                    break;

             case 1:
                    /* Return buffer with non-attached parts only */
                     row = (IGRchar *)
                           malloc (sizeof(IGRchar) * (*parts_bufr)->row_size);

                     head = parts_ids;

                     while(head) 
                         {
                          memset(row, NULL,
                                 sizeof(IGRchar) * (*parts_bufr)->row_size);

                          /* Extract attach flag */
                          co$part_get_attr (
                                            msg = &msg,
                                            mod_env = &mod_env,
                                            part = &(head->part_id),
                                            attr = "attach_flag",
                                            value = value,
                                            type = &type
                                           );

                          /* Extract part type */
                          co$part_get_attr (
                                            msg = &msg,
                                            mod_env = &mod_env,
                                            part = &(head->part_id),
                                            attr = "part_type",
                                            value = part_type,
                                            type = &type
                                           );

                          /* Extract part serial no */
                          co$part_get_attr (
                                            msg = &msg,
                                            mod_env = &mod_env,
                                            part = &(head->part_id),
                                            attr = "serial",
                                            value = serial_no,
                                            type = &type
                                           );

                          if ( ((strcmp(value, "-1.000000") == 0) ||
                                 (strcmp(value, "-2.000000") == 0)) &&
                               (strcmp(serial_no, "-1.000000") != 0) &&
                               ((strcmp(part_type, "G") == 0) ||
                                (strcmp(part_type, "g") == 0) ||
                                (strcmp(part_type, "D") == 0) ||
                                (strcmp(part_type, "d") == 0)) )
                             {
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

                              /* Write row to parts buffer */
                              sprintf(
                                      row,
                                      "%s\1%s\1%s\1%s\1%s\1",
                                      catalog,
                                      number, 
                                      revision,
                                      quantity,
                                      usage_id
                                     );

                              _pdm_debug("row = <%s>", row);

                              MEMwrite(*parts_bufr, row);
                          }

                          /* Process next part */
                          head = head->next;

                         } /* end while loop */

                    status = PDM_S_SUCCESS;

                    break;

             case 2:
                    /* Return buffer with attached parts only */
                     row = (IGRchar *)
                           malloc (sizeof(IGRchar) * (*parts_bufr)->row_size);

                     head = parts_ids;

                     while(head) 
                         {
                          memset(row, NULL,
                                 sizeof(IGRchar) * (*parts_bufr)->row_size);

                          /* Extract attach flag */
                          co$part_get_attr (
                                            msg = &msg,
                                            mod_env = &mod_env,
                                            part = &(head->part_id),
                                            attr = "attach_flag",
                                            value = value,
                                            type = &type
                                           );

                          if ( (strcmp(value, "-1.000000") != 0) &&
                               (strcmp(value, "-2.000000") != 0) ) 
                             {
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

                              /* Write row to parts buffer */
                              sprintf(
                                      row,
                                      "%s\1%s\1%s\1%s\1%s\1",
                                      catalog,
                                      number, 
                                      revision,
                                      quantity,
                                      usage_id
                                     );

                              _pdm_debug("row = <%s>", row);

                              MEMwrite(*parts_bufr, row);
                          }

                          /* Process next part */
                          head = head->next;

                         } /* end while loop */

                    status = PDM_S_SUCCESS;

                    break;

             case 3:
                    /* Return buffer with positionless parts only */
                     row = (IGRchar *)
                           malloc (sizeof(IGRchar) * (*parts_bufr)->row_size);

                     head = parts_ids;

                     while(head)
                         {
                          memset(row, NULL,
                                 sizeof(IGRchar) * (*parts_bufr)->row_size);
                          
                          /* Extract part type */
                          co$part_get_attr (
                                            msg = &msg,
                                            mod_env = &mod_env,
                                            part = &(head->part_id),
                                            attr = "part_type",
                                            value = part_type,
                                            type = &type
                                           );

                          /* Extract serial no. */
                          co$part_get_attr (
                                            msg = &msg,
                                            mod_env = &mod_env,
                                            part = &(head->part_id),
                                            attr = "serial",
                                            value = value,
                                            type = &type
                                           );

                          if ( (strcmp(value, "-1.000000") == 0) &&
                               (strcmp(part_type, "N") != 0) &&
                               (strcmp(part_type, "n") != 0) &&
                               (strcmp(part_type, "M") != 0) &&
                               (strcmp(part_type, "m") != 0))
                             {
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

                              /* Write row to parts buffer */
                              sprintf(
                                      row,
                                      "%s\1%s\1%s\1%s\1%s\1",
                                      catalog,
                                      number,
                                      revision,
                                      quantity,
                                      usage_id
                                     );

                              _pdm_debug("row = <%s>", row);

                              MEMwrite(*parts_bufr, row);
                          }

                          /* Process next part */
                          head = head->next;

                         } /* end while loop */

                    status = PDM_S_SUCCESS;

                    break;

               
             case 4:
                    /* Return buffer with all PDU GRparts ONLY loaded */
                     row = (IGRchar *)
                           malloc (sizeof(IGRchar) * (*parts_bufr)->row_size);

                     head = parts_ids;

                     while (head) 
                         {
                          memset(row, NULL,
                                 sizeof(IGRchar) * (*parts_bufr)->row_size);

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

                          /* Write row to parts buffer */
                          sprintf(
                                  row,
                                  "%s\1%s\1%s\1%s\1%s\1",
                                  catalog,
                                  number, 
                                  revision,
                                  quantity,
                                  usage_id
                                 );

                          _pdm_debug("row = <%s>", row);

                          MEMwrite(*parts_bufr, row);

                          /* Process next part */
                          head = head->next;

                         } /* end while loop */

                     status = PDM_S_SUCCESS;

                    break;
 
             /* ALR   1/3/93   TR 139306926  */

             case 5:
                 /* Return buffer with all parts loaded */
                     row = (IGRchar *)
                           malloc (sizeof(IGRchar) * (*parts_bufr)->row_size);

                     head = parts_ids;

                     while (head)
                         {
                          memset(row, NULL,
                                 sizeof(IGRchar) * (*parts_bufr)->row_size);

                          /* Extract serial_no */
                          co$part_get_attr (
                                            msg = &msg,
                                            mod_env = &mod_env,
                                            part = &(head->part_id),
                                            attr = "serial",
                                            value = value,
                                            type = &type
                                           );

                          if (strcmp(value, "-1.000000") != 0)
                            {
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

                              /* Write row to parts buffer */
                              sprintf(
                                      row,
                                      "%s\1%s\1%s\1%s\1%s\1",
                                      catalog,
                                      number,
                                      revision,
                                      quantity,
                                      usage_id
                                     );

                              _pdm_debug("row = <%s>", row);

                              MEMwrite(*parts_bufr, row);
                           }
                           /* Process next part */
                          head = head->next;

                         } /* end while loop */

                     /* Load parametric parts info, if any */
                     if (count2)
                       {
                        /* Allocate at least 80 chars for attr_name */
                        attr_name = (IGRchar *) malloc(sizeof(IGRchar) * 80);

                        memset(attr_name, NULL, sizeof(IGRchar) * 80);

                        memset(row, NULL,
                                 sizeof(IGRchar) * (*parts_bufr)->row_size);

                        head = parametric_ids;
                        while (head)
                            {
                             _pdm_debug("processing parametric id %d",
                                        head->part_id.objid);

                             /* Extract certain macro part attributes */
                             params = (IGRchar **) malloc(5*sizeof(IGRchar *));
                             memset((IGRchar *)params,NULL,5*sizeof(IGRchar *));

                             PDUfill_in_string(&params[0], "n_catalogname");
                             PDUfill_in_string(&params[1], "n_itemname");
                             PDUfill_in_string(&params[2], "n_itemrev");
                             PDUfill_in_string(&params[3], "p_quantity");
                             PDUfill_in_string(&params[4], "p_usageid");

                             status = get_parameter_values(
                                                           &(head->part_id),
                                                           params,
                                                           5,
                                                           &param_vals
                                                          );

                             if (!status)
                                {
                                 _pdm_debug("get_parameter_values failed", 0);
                                 return(status);
                                }

                             else
                                 {
                                  PDUfill_in_string(&catalog, param_vals[0]);
                                  PDUfill_in_string(&number, param_vals[1]);
                                  PDUfill_in_string(&revision, param_vals[2]);
                                  PDUfill_in_string(&quantity, param_vals[3]);
                                  PDUfill_in_string(&usage_id, param_vals[4]);
                                 }

                             /* Write row to parts buffer */
                             sprintf(
                                     row,
                                     "%s\1%s\1%s\1%s\1%s\1",
                                     catalog,
                                     number,
                                     revision,
                                     quantity,
                                     usage_id
                                    );

                             _pdm_debug("row = <%s>", row);

                             MEMwrite(*parts_bufr, row);

                             head = head->next;

                            } /* end while loop */
                        }

               status = PDM_S_SUCCESS;

              break;
 
             default:
                     _pdm_debug("Invalid flag type", 0);
                     break;

            } /* end switch */

      /* Need to free variables */
      if (parts_ids)
         {
          head = parts_ids;

          while (parts_ids)
                {
                 parts_ids = parts_ids->next;
                 free(head);
                 head = parts_ids;
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

      if (catalog)
         free(catalog);

      if (number)
         free(number);

      if (revision)
         free(revision);

      if (quantity)
         free(quantity);

      if (usage_id)
         free(usage_id);

      if (row)
         free(row);

      if (attr_name)
         free(attr_name);

      if (params)
         {
          for (i = 0; i < 5; ++i)
              {
               if (params[i])
                  {
                   free(params[i]);
                  }
              }

          free(params);
         }

      if (param_vals)
         {
          for (i = 0; i < 5; ++i)
              {
               if (param_vals[i])
                  {
                   free(param_vals[i]);
                  }
              }

          free(param_vals);
         }
     }

  return(status);
 } 

/*
 * This function extracts all PDU origins in active obj space 2.01.
 */
IGRint  PDUlist_all_origins_in_os(origins_bufr)
 MEMptr      *origins_bufr;
 {
  IGRlong    msg;
  IGRlong    status = PDM_S_SUCCESS;
  struct     GRmd_env  mod_env;
  IGRlong    NumberOfBytes, BytesReceived;

  _pdm_debug("In the PDUlist_all_origins_in_os function", 0);

  /* Get active module information */
  NumberOfBytes = sizeof(mod_env);
  status = gr$get_module_env(
                             msg = &msg,
                             sizbuf = &NumberOfBytes,
                             buffer = &mod_env,
                             nret = &BytesReceived
                            );

  /* Load origins_bufr with list of origins */
  status = PDUload_view_info(
                             mod_env.md_id.objid,
                             mod_env.md_id.osnum,
                             origins_bufr 
                            );
  _pdm_status("PDUload_view_info", status);

  return(status);
 }

/*
 * This function deletes a PDU part.
 */
IGRint PDUdelete_part_placement(
                                msg,
                                part_id
                               )
 IGRlong      *msg;
 struct  GRid part_id;
 {
  IGRlong    status = PDM_S_SUCCESS;
  IGRint     resp;
  IGRint     pos;
  GRobjid    obj;
  IGRdouble  point[3];

  _pdm_debug("In the PDUdelete_part_placement function", 0); 

  /* Set global variable PDU_macro_call to TRUE */
  PDU_macro_call = TRUE;

  /* Put PDU part objid on the queue */
  resp = EX_OBJID;
  obj = part_id.objid;
  pos = FRONT;

  status = PDUput_queue(
                        2,
                        NULL,
                        NULL,
                        NULL,
                        point,
                        &resp,
                        &obj,
                        NULL,
                        NULL,
                        &pos
                       );
  _pdm_status("PDUput_queue (part id)", status);

  /* Put delete part command on the queue */
  resp = EX_CMD_KEY;
  pos = FRONT;

  status = PDUput_queue(
                        1,
                        NULL,
                        "PDDlPrPt",
                        NULL,
                        point,
                        &resp,
                        NULL,
                        NULL,
                        NULL,
                        &pos
                       );
  _pdm_status("PDUput_queue (delete command)", status);

  *msg = PDM_S_SUCCESS;
  return(1);
 }

/*
 * This function extracts a PDU part id.
 */
IGRint  PDUget_PDU_part_id(
                           msg,
                           catalog,
                           number,
                           revision,
                           usage_id,
                           part_id
                          )
 IGRlong             *msg;
 IGRchar             *catalog;
 IGRchar             *number;
 IGRchar             *revision;
 IGRchar             *usage_id;
 struct GRid         *part_id;
 {
  IGRlong            status = PDM_S_SUCCESS;
  IGRint             resp;
  IGRint             pos;
  IGRdouble          point[3];
  IGRint             tmp_command;

  extern  IGRchar    *PDU_assy_catalog;
  extern  IGRchar    *PDU_assy_partid;
  extern  IGRchar    *PDU_assy_revision;
  extern  IGRchar    *PDU_usage_id;
  extern  IGRint     PDU_command;
  extern  IGRint     PDU_level_no;

  _pdm_debug("In the PDUget_PDU_part_id function", 0);

  /* Set global variables */
  PDU_level_no = 1;
  PDUfill_in_string(&PDU_assy_catalog, catalog);
  PDUfill_in_string(&PDU_assy_partid, number);
  PDUfill_in_string(&PDU_assy_revision, revision);
  PDUfill_in_string(&PDU_usage_id, usage_id);
  tmp_command = PDU_command;
  PDU_command = PDC_M_REPLACE_PART;

  /* Put identify part on the queue */
  resp = EX_CMD_KEY;
  pos = FRONT;

  status = PDUput_queue(
                        1,
                        NULL,
                        "PDIdPr",
                        NULL,
                        point,
                        &resp,
                        NULL,
                        NULL,
                        NULL,
                        &pos
                       );
  _pdm_status("PDUput_queue (identify part command)", status);

  part_id->objid = PDU_part_id->objid;
  part_id->osnum = PDU_part_id->osnum;

  /* Restore previous command */
  PDU_command = tmp_command;

  /* Deallocate PDU_part_id */
  if (PDU_part_id)
     {
      free(PDU_part_id);
      PDU_part_id = NULL;
     }

  *msg = PDM_S_SUCCESS;
  status = 1; 

  return(status);
 }


/*
 * This function delete a PDU GRpart.
 */
IGRint  PDUdelete_PDU_GRpart(
                             mod_env,
                             part_id
                            )
 struct GRmd_env  mod_env;
 struct GRid      part_id;
 {
  IGRlong          msg, sts;
  IGRlong          status = PDM_S_SUCCESS;
  IGRchar          part_path[DI_PATH_MAX];
  IGRchar          attr_value[MAX_VALUE];
  IGRchar          *child_no = NULL;
  IGRint           type;

  _pdm_debug("In the PDUdelete_PDU_GRpart function", 0);

  /* Construct path to file directory */
  di$give_pathname(
                   osnum = mod_env.md_id.osnum,
                   pathname = part_path
                  );

  /* Extract part child no from GRpart */
  status = co$part_get_attr (
                             msg = &msg,
                             mod_env = &mod_env,
                             part = &part_id,
                             attr = "child_no",
                             value = attr_value,
                             type = &type
                            );

  /* Load value to child_no */
  PDUunquote(attr_value);
  PDUfill_in_string(&child_no, attr_value);
  _pdm_debug("child no = <%s>", child_no);

  /* Construct path to assembly directory */
  strcat(part_path, ":ASSEMBLY:P");
  strcat(part_path, child_no);
  _pdm_debug("part assy path = <%s>", part_path);

  /* Erase part pointer */
  dp$display(
             msg = &sts,
             oids = &part_id,
             mode = GRbe
            );

  /* Delete GRpart */
  om$send(
          msg = message GRgraphics.GRdelete
                                  (
                                   &sts,
                                   &mod_env
                                  ),
          senderid = mod_env.md_id.objid,
          targetid = part_id.objid,
          targetos = part_id.osnum
         );

  /* Update assembly structure */
  status = PDUremove_assembly(part_path, &mod_env);
  _pdm_status("PDUremove_assembly", status);

  /* Free variables */
  if (child_no)
     free(child_no);

  return(status);
 }

/*
 * This function increments the tag seed and creates an entry under mac_tag_no.
 */
IGRint  PDUupdate_parametric_tag (osnum, tag_value)
 OMuword  osnum;
 IGRchar  *tag_value;
 {
  IGRlong    status = PDM_S_SUCCESS;
  IGRchar    mac_tag_dir[DI_PATH_MAX];
  IGRchar    mac_tag_entry[DI_PATH_MAX];
  IGRint     count = 0;

  _pdm_debug("In the PDUupdate_parametric_tag function", 0);

  /* Construct path to mac_tag_no directory */
  di$give_pathname(
                   osnum = osnum,
                   pathname = mac_tag_dir
                  );

  /* Construct mac tag entry */
  sprintf(
          mac_tag_entry,
          "!%s!%s!%s!%s",
          refresh->rev_catalog,
          refresh->rev_partid,
          refresh->rev_revision,
          tag_value
         );

  _pdm_debug("mac_tag_entry = <%s>", mac_tag_entry);

  strcat(mac_tag_dir, ":");
  strcat(mac_tag_dir, "PDU");
  strcat(mac_tag_dir, ":");
  strcat(mac_tag_dir, "mac_tag_no");
  strcat(mac_tag_dir, ":");
  strcat(mac_tag_dir, mac_tag_entry);

  /* Check to see if mac tag entry already exists */
  di$ls(regexp = mac_tag_dir, ptr = &count);

  if (count > 0)
     {
      _pdm_debug("mac tag entry <%s> already exists", mac_tag_entry);
      return(PDM_S_SUCCESS);
     }

  /* Increment tag seed */
  PDUincrement_tag_no (osnum);

  /* Add mac tag entry */
  strcat(mac_tag_dir, ":");

  _pdm_debug("creating new mac tag entry <%s>", mac_tag_dir);

  status = di$mkpath(pathname = mac_tag_dir);
  _pdm_status("di$mkpath", status);

  return(PDM_S_SUCCESS);
 }

/* 
 * This function checks to see if a GRpart is a PDU part.
 */
IGRint  PDUis_PDU_part (
                        part_id,
                        mod_env
                       )
 struct  GRid      *part_id;
 struct GRmd_env   *mod_env;
 {
  IGRlong    status = PDM_S_SUCCESS;
  IGRlong    msg;
  IGRint     type;
  IGRchar    attr_value[MAX_VALUE];


  _pdm_debug("In the PDUis_PDU_part function", 0);

  /* Validate part pointer identity */
  status = co$part_get_attr (
                             msg = &msg,
                             mod_env = mod_env,
                             part = part_id,
                             attr = "attach_flag",
                             value = attr_value,
                             type = &type
                            );

  if ( (msg != MSSUCC) || (strcmp(attr_value, "") == 0) )
      return(0);

  else
     return(1);
 }

/*
 * This function extracts all info necessary to modify a PDU GRpart.
 */
IGRint  PDUextract_GRpart_modify_info(
                                      part_id,
                                      mod_env,
                                      catalog,
                                      number,
                                      revision,
                                      dyn_attrs,
                                      dyn_syns,
                                      dyn_types,
                                      dyn_values,
                                      num_attrs
                                     )
 struct  GRid *part_id;
 struct  GRmd_env  *mod_env; 
 IGRchar **catalog;
 IGRchar **number;
 IGRchar **revision;
 IGRchar ***dyn_attrs;
 IGRchar ***dyn_syns;
 IGRchar ***dyn_types;
 IGRchar ***dyn_values;
 IGRint  *num_attrs;

 {
  IGRlong    msg;
  IGRlong    status = PDM_S_SUCCESS;
  IGRint     i = 0, j;
  IGRint     type;
  IGRchar    value[MAX_VALUE];
  IGRchar    *quantity = NULL;
  IGRchar    *usage_id = NULL;
  IGRchar    *view_name = NULL;
  IGRchar    *incbom = NULL;
  IGRchar    *incasm = NULL;
  IGRchar    *explode = NULL;
  IGRchar    *alt_tagno = NULL;
  IGRchar    *p_explode = NULL;
  IGRchar    **attrs;
  MEMptr     dyn_attr_bufr = NULL;
  MEMptr     dyn_data_bufr = NULL;
  MEMptr     dyn_value_bufr = NULL;
  MEMptr     placement_attr_bufr = NULL;


  _pdm_debug("In the PDUextract_GRpart_modify_info function", 0);

  /* Extract catalog from GRpart */
  co$part_get_attr (
                    msg = &msg,
                    mod_env = mod_env,
                    part = part_id,
                    attr = "CATALOG",
                    value = value,
                    type = &type
                   );

  /* Load catalog into catalog */
  PDUfill_in_string(catalog, value);

  /* Extract part number from GRpart */
  co$part_get_attr (
                    msg = &msg,
                    mod_env = mod_env,
                    part = part_id,
                    attr = "NUMBER",
                    value = value,
                    type = &type
                   );

  /* Load part number into number */
  PDUfill_in_string(number, value);

  /* Extract part revision from GRpart */
  co$part_get_attr (
                    msg = &msg,
                    mod_env = mod_env,
                    part = part_id,
                    attr = "REVISION",
                    value = value,
                    type = &type
                   );
  /* Load part revision into revision */
  PDUfill_in_string(revision, value);

  /* Extract part quantity from GRpart */
  co$part_get_attr (
                    msg = &msg,
                    mod_env = mod_env,
                    part = part_id,
                    attr = "quantity",
                    value = value,
                    type = &type
                   );
  /* Load part quantity into quantity */
  PDUfill_in_string(&quantity, value);

  /* Extract part usage_id from GRpart */
  co$part_get_attr (
                    msg = &msg,
                    mod_env = mod_env,
                    part = part_id,
                    attr = "usage_id",
                    value = value,
                    type = &type
                   );
  /* Load part usage id into usage_id */
  PDUfill_in_string(&usage_id, value);

  /* Extract part view name from GRpart */
  co$part_get_attr (
                    msg = &msg,
                    mod_env = mod_env,
                    part = part_id,
                    attr = "view_name",
                    value = value,
                    type = &type
                   );
  /* Load part view name into view_name */
  PDUfill_in_string(&view_name, value);

  /* Extract part incl BOM from GRpart */
  co$part_get_attr (
                    msg = &msg,
                    mod_env = mod_env,
                    part = part_id,
                    attr = "incl_BOM",
                    value = value,
                    type = &type
                   );
  /* Load part incl BOM into incbom */
  PDUfill_in_string(&incbom, value);

  /* Extract part incl ASM from GRpart */
  co$part_get_attr (
                    msg = &msg,
                    mod_env = mod_env,
                    part = part_id,
                    attr = "incl_asm",
                    value = value,
                    type = &type
                   );
  /* Load part incl BOM into incbom */
  PDUfill_in_string(&incasm, value);

  /* Extract part explode BOM from GRpart */
  co$part_get_attr (
                    msg = &msg,
                    mod_env = mod_env,
                    part = part_id,
                    attr = "explode_BOM",
                    value = value,
                    type = &type
                   );
  /* Load part explode BOM into explode */
  PDUfill_in_string(&explode, value);

  /* Extract part alt tag from GRpart */
  co$part_get_attr (
                    msg = &msg,
                    mod_env = mod_env,
                    part = part_id,
                    attr = "alt_tag",
                    value = value,
                    type = &type
                   );
  /* Load part alt tag into alt_tagno */
  PDUfill_in_string(&alt_tagno, value);

  /* Get basic placement attributes from PDM */
  status = PDMplacement_attributes(&placement_attr_bufr);
  _pdm_status("PDMplacement_attributes", status);

  if (status != PDM_S_SUCCESS )
     {
      _pdm_debug("SEVERE error: PDMplacement_attributes failed", 0);
      return(status);
     }

  /* Extract dynamic attributes from PDM if any */
  status = PDMquery_dynamic_attrs(
                                  *catalog,
                                  *number,
                                  *revision,
                                  &dyn_attr_bufr,
                                  &dyn_data_bufr,
                                  &dyn_value_bufr,
                                  &p_explode
                                 );
  _pdm_status("PDMquery_dynamic_attrs", status);

  if ( (status != PDM_S_SUCCESS) || (!dyn_attr_bufr) )
     {
      _pdm_debug("No Dynamic Attributes Were Defined For Catalog <%s>",
                 *catalog);
     }

  /* Allocate and initialize attributes, values, synonyms, and types */
  if (dyn_attr_bufr)
     {
      /* JBP don't subtract one because of p_incasm */
      *num_attrs = dyn_attr_bufr->rows + placement_attr_bufr->rows + 1;
      /**num_attrs = (dyn_attr_bufr->rows - 1) + placement_attr_bufr->rows; */
     }

  else
      *num_attrs = placement_attr_bufr->rows + 1; /* add 1 for incasm */

  _pdm_debug("total dyn attribute count = %d", *num_attrs);

  *dyn_attrs = (IGRchar **) malloc ((*num_attrs) * sizeof(IGRchar *));
  memset((char *)*dyn_attrs, NULL, *num_attrs * sizeof(IGRchar *));

  *dyn_values = (IGRchar **) malloc ((*num_attrs) * sizeof(IGRchar *));
  memset((char *)*dyn_values, NULL, *num_attrs * sizeof(IGRchar *));

  *dyn_syns = (IGRchar **) malloc ((*num_attrs) * sizeof(IGRchar *));
  memset((char *)*dyn_syns, NULL, *num_attrs * sizeof(IGRchar *));

  *dyn_types = (IGRchar **) malloc ((*num_attrs) * sizeof(IGRchar *));
  memset((char *)*dyn_types, NULL, *num_attrs * sizeof(IGRchar *));

  /* Load dyn_attrs, dyn_values, dyn_syns, and dyn_types arrays from
   * placement_attr_bufr
   */
  if (placement_attr_bufr)
     {
      MEMbuild_array(placement_attr_bufr);
      status = PDUsetup_buffer(
                               placement_attr_bufr,
                               ROW,
                               &attrs
                              );

      for (i = 0; i < placement_attr_bufr->rows; ++i)
          {
           PDUfill_in_string(&((*dyn_attrs)[i]), 
                             attrs[(placement_attr_bufr->columns * i) + 0]);

           PDUfill_in_string(&((*dyn_syns)[i]),
                             attrs[(placement_attr_bufr->columns * i) + 1]);

           PDUfill_in_string(&((*dyn_types)[i]),
                             attrs[(placement_attr_bufr->columns * i) + 2]);

           if (strcmp((*dyn_attrs)[i], "p_quantity") == 0)
              PDUfill_in_string(&((*dyn_values)[i]), quantity);

           else if (strcmp((*dyn_attrs)[i], "p_usageid") == 0)
                   {
                    PDUunquote(usage_id);
                    PDUfill_in_string(&((*dyn_values)[i]), usage_id);
                   }

           else if (strcmp((*dyn_attrs)[i], "p_viewid") == 0)
                   {
                    if ( (strlen(view_name) <= 0) || 
                         (strcmp(view_name, "") == 0) )
                       {
                        (*dyn_values)[i] = (IGRchar *)malloc(2*sizeof(IGRchar));
                        (*dyn_values)[i][0] = '\0';
                       }

                    else
                        {
                         PDUunquote(view_name);
                         PDUfill_in_string(&((*dyn_values)[i]), view_name);
                        }
                   }

           else if (strcmp((*dyn_attrs)[i], "p_incbom") == 0)
                PDUfill_in_string(&((*dyn_values)[i]), incbom);

           else if (strcmp((*dyn_attrs)[i], "p_explode") == 0)
                PDUfill_in_string(&((*dyn_values)[i]), explode);

           else if (strcmp((*dyn_attrs)[i], "p_alttagno") == 0) 
                   {
                    if ( (strlen(alt_tagno) <= 0) ||
                         (strcmp(alt_tagno, "") == 0) )
                       {
                        (*dyn_values)[i] = (IGRchar *)malloc(2*sizeof(IGRchar));
                        (*dyn_values)[i][0] = '\0';
                       }

                    else
                        {
                         PDUunquote(alt_tagno);
                         PDUfill_in_string(&((*dyn_values)[i]), alt_tagno);
                        }
                   }

          } /* end for i loop */
           PDUfill_in_string(&((*dyn_attrs)[placement_attr_bufr->rows]),
                             "p_incstr");

           PDUfill_in_string(&((*dyn_syns)[placement_attr_bufr->rows]),
                               "Include in Structure");

           PDUfill_in_string(&((*dyn_types)[placement_attr_bufr->rows]),
                             "char(1)");

           PDUfill_in_string(&((*dyn_values)[placement_attr_bufr->rows]),
                             incasm);
            ++i;

     }

  /* Load dyn_attrs, dyn_values, dyn_syns, and dyn_types arrays from
   * dyn_data_bufr
   */
  if ( (dyn_attr_bufr) && (dyn_attr_bufr->rows > 0) )
     {
      MEMbuild_array(dyn_attr_bufr);
      status = PDUsetup_buffer(
                               dyn_attr_bufr,
                               ROW,
                               &attrs
                              );

      for (j = 0; j < dyn_attr_bufr->rows; ++j)
          {
           /* Extract dynamic attr values */
           co$part_get_attr (
                             msg = &msg,
                             mod_env = mod_env,
                             part = part_id,
                             attr = attrs[(dyn_attr_bufr->columns * j) + PDU_DYN_ATTR_COL],
                             value = value,
                             type = &type
                            );

           if (strncmp(attrs[(dyn_attr_bufr->columns * j) + PDU_DYN_DATA_COL],
               "char", 4) == 0)
              {
               if ( (msg != MSSUCC) || (strcmp(value, "") == 0) )
                 {
                  /* Attribute not found, default value */
                  (*dyn_values)[i] = (IGRchar *)malloc(2*sizeof(IGRchar));
                  (*dyn_values)[i][0] = '\0';
                 }

               else
                   {
                    if ((value != NULL) && (strcmp(value, "") != 0))
                       PDUunquote(value);

                    PDUfill_in_string(&((*dyn_values)[i]), value);
                   }
              }

           else
               {
                if ( (msg != MSSUCC) || (strcmp(value, "") == 0) )
                 {
                  /* Attribute not found, default value */
                  PDUfill_in_string(&((*dyn_values)[i]), "0");

                 }

                else
                    {
                     if ((value != NULL) && (strcmp(value, "") != 0))
                        PDUfill_in_string(&((*dyn_values)[i]), value);
                    }
               }

            PDUfill_in_string(&((*dyn_attrs)[i]),
                              attrs[(dyn_attr_bufr->columns * j) +
                              PDU_DYN_ATTR_COL]);

            PDUfill_in_string(&((*dyn_types)[i]),
                              attrs[(dyn_attr_bufr->columns * j) + 
                              PDU_DYN_DATA_COL]);

            PDUfill_in_string(&((*dyn_syns)[i]),
                              attrs[(dyn_attr_bufr->columns * j) + 
                              PDU_DYN_SYN_COL]);

            ++i;

          } /* end for j loop */
     }

  /* Free variables */ 
  if (quantity)
     free(quantity);

  if (usage_id)
     free(usage_id);

  if (view_name)
     free(view_name);

  if (incbom)
     free(incbom);

  if (incasm)
     free(incasm);

  if (explode)
     free(explode);

  if (alt_tagno)
     free(alt_tagno);

  if (p_explode)
     free(p_explode);

  if (dyn_attr_bufr)
     MEMclose(&dyn_attr_bufr);

  if (dyn_data_bufr)
     MEMclose(&dyn_data_bufr);

  if (dyn_value_bufr)
     MEMclose(&dyn_value_bufr);

  if (placement_attr_bufr)
     MEMclose(&placement_attr_bufr);

  return(status);
 }

/*
 * This function returns parametric parts ids.
 */
IGRint  PDUget_all_parametric_ids(
                                  osnum,
                                  parametric_ids,
                                  count
                                 )
 OMuword osnum;                          /* INPUT */
 struct  PDUpart_node **parametric_ids;  /* OUTPUT */
 IGRint  *count;                         /* OUTPUT */
 {
  IGRlong                  status = PDM_S_SUCCESS;
  IGRchar                  macros_dir[DI_PATH_MAX];
  IGRchar                  regexp[DI_PATH_MAX];
  struct GRid              *nci_objects = NULL;
  struct GRid              *ACconst_objects = NULL;
  OM_p_CLASSLIST           classlist;
  OMuword                  classid;
  IGRint                   count1 = 0;
  IGRint                   count2 = 0;
  IGRint                   i;
  struct  PDUpart_node     *temp = NULL;
  struct  PDUpart_node     *tail = NULL;
  extern  OMuword          OPP_nci_macro_class_id;
  extern  OMuword          OPP_ACconst_class_id;


  _pdm_debug("In the PDUget_all_parametric_ids function", 0);

  /* Get path to macro_parts directory */
  di$give_pathname(
                   osnum = osnum,
                   pathname = macros_dir
                  );

  strcat(macros_dir,":PDU:macro_parts");

  /* Set up calss list info */
  /* Malloc classlist */
  classlist = (struct OM_sd_classlist *) malloc (sizeof
                        (struct OM_sd_classlist));

  /* Initialize certain fields in classlist */
  classlist->w_count = 1;
  classlist->w_flags = OM_CLST_internal;
  classlist->p_classes = &classid;

  /* Get all objects of class nci_macro */
  classid = OPP_nci_macro_class_id;

  strcpy(regexp, macros_dir);
  strcat(regexp, ":*");

  status = di$dump(
                   regexp = regexp,
                   p_classes = classlist,
                   grids = (DIgrid **)&nci_objects,
                   ptr = &count1
                  );

  if (!count1)
     {
      _pdm_debug("no nci_macro objects were found", 0);
     }

  /* Get all objects of class ACconst  */
  classid = OPP_ACconst_class_id;

  status = di$dump(
                   regexp = regexp,
                   p_classes = classlist,
                   grids = (DIgrid **)&ACconst_objects,
                   ptr = &count2
                  );

  if (!count2)
     {
      _pdm_debug("no ACconst objects were found", 0);
     }

 status = PDM_S_SUCCESS;

 if (!count1 && !count2)
    {
     _pdm_debug("no macro parts were found", 0);
     return(status);
    }

 if (count1 > 0)
    {
     for (i = 0; i < count1; ++i)
         {
          temp = (struct PDUpart_node *) malloc(sizeof(struct PDUpart_node));

          /* Initialize temp fields */
          temp->part_id.objid = nci_objects[i].objid;
          temp->part_id.osnum = nci_objects[i].osnum;
          temp->next = NULL;
  
          if (*parametric_ids)
             {
              _pdm_debug("adding node to end of list", 0);

              tail = *parametric_ids;
              while (tail->next)
                    {
                     tail = tail->next;
                    }

              tail->next = temp;
             }

          else
             {
              _pdm_debug("adding first node to list", 0);

              *parametric_ids = temp;
             }
         } /* end for loop */
    }

 if (count2 > 0)
    {
     for (i = 0; i < count2; ++i)
         {
          temp = (struct PDUpart_node *) malloc(sizeof(struct PDUpart_node));

          /* Initialize temp fields */
          temp->part_id.objid = ACconst_objects[i].objid;
          temp->part_id.osnum = ACconst_objects[i].osnum;
          temp->next = NULL;

          if (*parametric_ids)
             {
              _pdm_debug("adding node to end of list", 0);

              tail = *parametric_ids;
              while (tail->next)
                    {
                     tail = tail->next;
                    }

              tail->next = temp;
             }

          else
             {
              _pdm_debug("adding first node to list", 0);

              *parametric_ids = temp;
             }
         }
    }

  *count = count1 + count2;

  if (*count)
     _pdm_debug("total parametric parts found = %d", *count); 

  /* Free variables */
  if (nci_objects)
     free(nci_objects);
 
  if (ACconst_objects)
     free(ACconst_objects);
 
  return(status);
 }

/*
 * This function, given a part id, it will find if a part is parametric.
 */
IGRint  PDUis_parametric_part(part_id)

 struct  GRid *part_id;
 {
 IGRlong          status = PDM_S_SUCCESS;
 IGRchar          macro_name[DI_PATH_MAX];
 IGRchar          macros_dir[DI_PATH_MAX];
 IGRchar          *obj_name;
 GRobjid          objid;

 
  _pdm_debug("In the PDUis_parametric_part function", 0);

  /* Construct path to macro_parts */
  di$give_pathname(
                   osnum = part_id->osnum,
                   pathname = macros_dir
                  );

  strcat(macros_dir, ":PDU:macro_parts");

  status = di$untranslate(
                          objname = macro_name,
                          path = macros_dir,
                          objid = part_id->objid,
                          osnum = part_id->osnum
                         );

  if (status == DIR_S_SUCCESS)
     {
      _pdm_debug("macro_name = <%s>", macro_name);

      /* Strip out last ':', if any */
      PDUstrip_dir_entry(macro_name);

      /* Extract object name */
      obj_name = (IGRchar *)strrchr(macro_name, ':');
      ++obj_name;

      /* Translate object under macro_parts directory */
      strcat(macros_dir, ":");
      strcat(macros_dir, obj_name);
      status = di$translate(
                            objname = macros_dir,
                            p_objid = &objid
                           );

      if (status == DIR_S_SUCCESS)
         {
          _pdm_debug("part <%s> is parametric", macro_name);
          return(1);
         }
     }
 
  return(0);
 }

IGRint  PDUupdate_active_object_space(mod_env, catalog, partid, revision)
 struct GRmd_env   *mod_env;
 IGRchar           *catalog;
 IGRchar           *partid;
 IGRchar           *revision;
 {
  IGRlong          status = PDM_S_SUCCESS;
  MEMptr           struct_bufr = NULL;
  IGRlong          NumberOfBytes, BytesReceived;
  IGRlong          msg;
  IGRshort         free_mod = FALSE;

  _pdm_debug("In the PDUupdate_active_object_space function", 0);

  if (mod_env == NULL)
    {
    mod_env = (struct GRmd_env *)malloc(sizeof(struct GRmd_env));
    NumberOfBytes = sizeof(struct GRmd_env);
    status = gr$get_module_env(
                              msg = &msg,
                              sizbuf = &NumberOfBytes,
                              buffer = mod_env,
                              nret = &BytesReceived);
     free_mod = TRUE;
     }
  /* Check OS consistency with database */
  status = PDMget_assembly_structure(
                                     catalog,
                                     partid,
                                     revision,
                                     MAX_LEVEL,
                                     &struct_bufr,
                                     0
                                    );
  _pdm_status("PDMget_assembly_structure", status);

  status = PDM_S_SUCCESS;

  if (struct_bufr == NULL)
     {
      _pdm_debug("SEVERE error: struct_bufr is empty", 0);
      return(status);
     }

  if (PDM_debug_on)
     MEMprint_buffer("struct_bufr", struct_bufr, PDU_DEBUG_FILE);

  status = PDUcheck_assembly_consistency(
                                         struct_bufr,
                                         mod_env
                                        );
  _pdm_status("PDUcheck_assembly_consistency", status);

  if (status != PDM_S_SUCCESS)
     {
      _pdm_debug("PDUcheck_assembly_consistency failed", 0);
      return(status);
     }
  if (free_mod)
    free(mod_env);

  return(status);
 }

/*
 * This function retrieves the placement attrs of a non-positioned part in
 * the active object space.
 */
IGRint  PDUretrieve_placement_attrs(usage_id)
 IGRchar *usage_id;
 {
  IGRlong                 status = PDM_S_SUCCESS;
  struct GRmd_env         mod_env;
  struct PDUpart_node     *parts_ids = NULL;
  struct PDUpart_node     *head = NULL;
  IGRint                  count = 0;
  IGRint                  type;
  IGRchar                 attr_value[MAX_VALUE];
  IGRlong                 msg;

  extern IGRchar          *PDU_incl_BOM;
  extern IGRchar          *PDU_incl_ASM;
  extern IGRchar          *PDU_explode_BOM;
  extern IGRshort         PDU_attach;


  _pdm_debug("In the PDUretrieve_placement_attrs function", 0);

  /* Get active module env. info */
  gr$get_module_env(buffer = &mod_env);

  /* Extract part pointers from object space */
  status = PDUget_all_GRpart_ids(
                                 mod_env.md_id.osnum,
                                 &parts_ids,
                                 &count
                                );
  _pdm_status("PDUget_all_GRpart_ids", status);

  if (!count)
     {
      _pdm_debug("No PDU GRparts found", 0);
      return(PDM_S_SUCCESS);
     }

  head = parts_ids;

  while (head)
        {
         /* Extract part usage id */
         co$part_get_attr (
                           msg = &msg,
                           mod_env = &mod_env,
                           part = &(head->part_id),
                           attr = "usage_id",
                           value = attr_value,
                           type = &type
                          );

         PDUunquote(attr_value);

         if (strcmp(attr_value, usage_id) == 0)
            {
             _pdm_debug("a match was found", 0);

             /* Extract part attach flag */
             co$part_get_attr (
                               msg = &msg,
                               mod_env = &mod_env,
                               part = &(head->part_id),
                               attr = "attach_flag",
                               value = attr_value,
                               type = &type
                              );

             if (strcmp(attr_value, "-2.000000") == 0)
                PDU_attach = TRUE;

             else
                 PDU_attach = FALSE;

             /* Extract part incl_BOM */
             co$part_get_attr (
                               msg = &msg,
                               mod_env = &mod_env,
                               part = &(head->part_id),
                               attr = "incl_BOM",
                               value = attr_value,
                               type = &type
                              );

             PDUfill_in_string(&PDU_incl_BOM, attr_value);

             /* Extract part explode_BOM */
             co$part_get_attr (
                               msg = &msg,
                               mod_env = &mod_env,
                               part = &(head->part_id),
                               attr = "explode_BOM",
                               value = attr_value,
                               type = &type
                              );

             PDUfill_in_string(&PDU_explode_BOM, attr_value);

             /* Extract part incl_asm */
             co$part_get_attr (
                               msg = &msg,
                               mod_env = &mod_env,
                               part = &(head->part_id),
                               attr = "incl_asm",
                               value = attr_value,
                               type = &type
                              );

             PDUfill_in_string(&PDU_incl_ASM, attr_value);

             status = PDM_S_SUCCESS;

             break;
            }

         /* Process next part */
         head = head->next;

        } /* end while loop */

  /* Free variables */
  if (parts_ids)
     {
      head = parts_ids;

      while (parts_ids)
            {
             parts_ids = parts_ids->next;
             free(head);
             head = parts_ids;
            }
     }

  return(status);
 }


/*
 * This function generates a default part usage id.
 */
 IGRint  PDUget_default_usage_id(
                                 catalog,      /* INPUT */
                                 number,       /* INPUT */
                                 revision,     /* INPUT */
                                 usage_id      /* OUTPUT */
                                )
 IGRchar *catalog;
 IGRchar *number;
 IGRchar *revision;
 IGRchar *usage_id;
 {
  IGRint     i = 1;
  IGRchar    *catalog_no = NULL;
  IGRchar    *item_no = NULL;
  IGRchar    *usage_id_seed = NULL;
  IGRchar    str[MAX_VALUE];
  IGRint     status = PDM_S_SUCCESS;


  _pdm_debug("In the PDUget_default_usage_id function", 0);

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
           strcpy(usage_id, "");
           return(PDM_S_SUCCESS);
          }

       sprintf(str, "%s %s", number, revision);
      }

  sprintf(usage_id, "%s #%d", str, i);

  while (!PDUis_usage_unique(usage_id))
        {
         ++i;
         sprintf(usage_id, "%s #%d", str, i);
        }

  /* Check to see if usage id exceeds 25 characters */
  if (strlen(usage_id) > 25)
     {
      /* Use catalog no/part no pairs in the default usage id */
      status = PDMget_catno_partno(
                                   catalog,
                                   number,
                                   revision,
                                   &catalog_no,
                                   &item_no
                                  );
      _pdm_status("PDMget_catno_partno", status);
 
      if (status != PDM_S_SUCCESS)
         {
          _pdm_debug("SEVERE error: PDMget_catno_partno failed", 0);
          return(status);
         }

      i = 1;
      /* Default usage id */
      sprintf(
              usage_id,
              "%s %s #%d",
              catalog_no,
              item_no,
              i
             );
    while (!PDUis_usage_unique(usage_id))
          {
          ++i;
          sprintf(
              usage_id,
              "%s %s #%d",
              catalog_no,
              item_no,
              i
             );
          }
     }

  _pdm_debug("default usage id = <%s>", usage_id);

  /* Free variables */
  if (usage_id_seed)
     free(usage_id_seed);

  if (catalog_no)
     free(catalog_no);

  if (item_no)
     free(item_no);

  return(status);
 }

 /*
 * This function extracts the instance data structure for the given ref objid.
 */
IGRint  PDUget_ref_file_name(ref_id, ref_mod_env, ref_file_name)
 struct  GRid                        ref_id;          /* INPUT */
 struct  GRmd_env                    ref_mod_env;     /* INPUT */
 IGRchar                             *ref_file_name; /* OUTPUT */
 {
  IGRlong                        msg = MSSUCC;
  IGRlong                        status = PDM_S_SUCCESS;
  IGRint                         size;
  struct  GRinquire_list         ref_list[2];
  IGRboolean                     pass_on;


 _pdm_debug("In the PDUget_ref_file_name function", 0);

 /* Set ref. request */
 ref_list[0].var = REFERENCE_FILE_NAME;
 ref_list[0].var_ptr = ref_file_name;
 ref_list[0].num_requested = sizeof(IGRchar) * DI_PATH_MAX;
 ref_list[1].var = END_REPORT_REQUEST;
 pass_on = FALSE;
 size = sizeof(DI_PATH_MAX);

 status = om$send(
                  msg = message GRreffile.GRinquireref(
                                                       &msg,
                                                       &ref_mod_env,
                                                       ref_list,
                                                       &size,
                                                       &pass_on,
                                                       NULL
                                                      ),
                  senderid = ref_mod_env.md_id.objid,
                  targetid = ref_id.objid,
                  targetos = ref_id.osnum
                 );
  _pdm_status2 ("GRreffile.GRinquireref", status, msg);

  if ( (1&status) && (msg == MSSUCC) )
     {
      _pdm_debug("ref file name = <%s>", ref_file_name);
      return(PDM_S_SUCCESS);
     }

  else
      {
       _pdm_debug("GRreffile.GRinquireref failed", 0);
       return(status);
      }

  }

/*
 * This function is used to generate a part instance number.
 */

IGRint PDUgenerate_instance_number_cvt(
                                       catalog,     /* INPUT */
                                       catalogno,   /* INPUT */
                                       number,      /* INPUT */
                                       itemno,      /* INPUT */
                                       revision,    /* INPUT */
                                       instance_no, /* OUTPUT */
                                       mod_env      /* INPUT */
                                      )

 IGRchar         *catalog;
 IGRchar         *catalogno;
 IGRchar         *number;
 IGRchar         *itemno;
 IGRchar         *revision;
 IGRint          *instance_no;
 struct GRmd_env *mod_env;

{
 IGRlong  msg;
 IGRlong  status;
 IGRchar  s[DI_PATH_MAX];
 IGRchar  usage_id[DI_PATH_MAX];
 IGRchar  parts_dir[DI_PATH_MAX];
 IGRchar  attr_value[MAX_VALUE];
 IGRint   count = 0;
 IGRint   type = 0;
 IGRint   i;
 IGRshort unique = FALSE;
 IGRshort found;
 struct GRid      *part_ids = NULL;


 _pdm_debug("In the PDUgenerate_instance_number_cvt function", 0);

 *instance_no = 1;

 /* Get the <:filename:parts:catalog:number!revision> path */
 di$give_pathname(osnum = mod_env->md_id.osnum, pathname = parts_dir);
 _pdm_debug("parts_dir = <%s>", parts_dir);

 sprintf(
         s,
         "%s:parts:%s:%s!%s:",
         parts_dir,
         catalog,
         number,
         revision
        );

 _pdm_debug("part full path = <%s>", s);

 /* Get all part occurences */
 status = PDUget_GRparts_ids(
                             s,
                             &part_ids,
                             &count
                            );

 if (count == 0)
    {
     _pdm_debug("first occurence of part", 0);
     *instance_no = 1;
     return(PDM_S_SUCCESS);
    }

 /* Generate unique instence number */
 while (!unique)
       {
        ++(*instance_no);

        /* Construct usage id */
        sprintf(
                usage_id,
                "%s %s #%d",
                catalogno,
                itemno,
                *instance_no
               );

        found = FALSE;

        /* Loop thru making sure usage id is unique */
        for (i = 0; i < count; ++i)
            {
             co$part_get_attr (
                               msg = &msg,
                               mod_env = mod_env,
                               part = &part_ids[i],
                               attr = "usage_id",
                               value = attr_value,
                               type = &type
                              );

             /* Unquote value */
             PDUunquote(attr_value);

             if (strcmp(attr_value, usage_id) == 0)
                {
                 found = TRUE;
                 break;
                }
            } /* end for loop */

         if (!found)
            unique = TRUE;

       } /* end while loop */

 _pdm_debug("generated instance_no = %d", *instance_no);

 /* Free up part_ids */
 if (part_ids)
    free(part_ids);

 return(PDM_S_SUCCESS);
 }


/*
 * Function to check if ref object is background.
 */
IGRint PDUis_background(ref_id, mod_env)
 struct GRid   *ref_id;                        /* INPUT */
 struct GRmd_env mod_env;                      /* INPUT */
 {
  IGRlong    status = PDM_S_SUCCESS;
  IGRlong    msg = MSSUCC;
  unsigned   short ref_props; 
  struct     GRinquire_list  ref_list[2];
  IGRboolean pass_on;
  IGRint     size;
 
 
  _pdm_debug("In the function PDUis_background", 0);

  /* Set ref. request */
  ref_list[0].var = FILE_PROPERTIES;
  ref_list[0].var_ptr = (IGRchar *) &ref_props;
  ref_list[0].num_requested = sizeof(unsigned short);
  ref_list[1].var = END_REPORT_REQUEST;
  pass_on = FALSE;
  size = sizeof(unsigned short); 

  /* Extract background bit from ref object */
  status = om$send(
                   msg = message GRreffile.GRinquireref
                                          (
                                           &msg,
                                           &mod_env,
                                           ref_list,
                                           &size,
                                           &pass_on,
                                           NULL
                                          ),
                   senderid = mod_env.md_id.objid,
                   targetid = ref_id->objid,
                   targetos = ref_id->osnum
                  );

  if (status & msg & 1)
     {
      if ( (ref_props & GRRF_BACKGROUND) == GRRF_BACKGROUND ) 
         {
          _pdm_debug("ref obj id %d is background", ref_id->objid);
          return(1);
         }

      else
          return(0);
     }

  else
      {
       _pdm_debug("PDUis_background failed", 0);
       return(-1);
      }
 }


/*
 * This function loads local file info for a part into a buffer.
 */
IGRint PDUload_local_file_info(
                               catalog,
                               number,
                               revision,
                               child_no,
                               asm_bufr,
                               file_bufr
                              )
 IGRchar   *catalog;
 IGRchar   *number;
 IGRchar   *revision;
 IGRchar   *child_no;
 MEMptr    asm_bufr;
 MEMptr    *file_bufr;
 { 
  IGRint    status = PDM_S_SUCCESS;
  IGRint    cat_no_col;
  IGRint    item_no_col;
  IGRint    asm_child_col;
  IGRint    asm_level_col;
  IGRint    asm_cat_no_col;
  IGRint    asm_item_no_col;
  IGRint    asm_cat_col;
  IGRint    asm_part_col;
  IGRint    asm_rev_col;
  IGRint    asm_file_col;
  IGRint    i, j;
  IGRchar   *row = NULL;
  IGRchar   **data, **data1;
  IGRshort  part_found;


  _pdm_debug("In the PDUload_local_file_info function", 0);


  /* Setup buffer */
  MEMbuild_array(asm_bufr);
  PDUsetup_buffer(asm_bufr, ROW, &data);

  /* Extract child no column no */
  PDUget_buffer_col(
                    asm_bufr,
                    "p_childno",
                    &asm_child_col
                   );

  /* Extract level no column no */
  PDUget_buffer_col(
                    asm_bufr,
                    "p_level",
                    &asm_level_col
                   );

  /* Extract catalog no column no */
  PDUget_buffer_col(
                    asm_bufr,
                    "n_ccatalogno",
                    &asm_cat_no_col
                   );

  /* Extract item no column no */
  PDUget_buffer_col(
                    asm_bufr,
                    "n_citemno",
                    &asm_item_no_col
                   );

  /* Extract catalog column no */
  PDUget_buffer_col(
                    asm_bufr,
                    "n_catalogname",
                    &asm_cat_col
                   );

  /* Extract part number column no */
  PDUget_buffer_col(
                    asm_bufr,
                    "n_itemname",
                    &asm_part_col
                   );

  /* Extract part revision column no */
  PDUget_buffer_col(
                    asm_bufr,
                    "n_itemrev",
                    &asm_rev_col
                   );

  /* Extract file column no */
  PDUget_buffer_col(
                    asm_bufr,
                    "n_cofilename",
                    &asm_file_col
                   );


  /* Get local file info from  part assembly structure */
  for (i = 1; i < asm_bufr->rows; ++i)
      {
       if ( (strcmp(data[(asm_bufr->columns*i)+asm_child_col], child_no)==0) &&
            (strcmp(data[(asm_bufr->columns*i)+asm_cat_col], catalog)==0) &&
            (strcmp(data[(asm_bufr->columns*i)+asm_part_col], number)==0) &&
            (strcmp(data[(asm_bufr->columns*i)+asm_rev_col], revision)==0) )
          {
           _pdm_debug("part was found", 0);

           if ( (*file_bufr)->rows > 0)
              {
               /* Load part file info, if not included */
               MEMbuild_array(*file_bufr);
               PDUsetup_buffer(*file_bufr, ROW, &data1);

               /* Extract catalog no column no */
               PDUget_buffer_col(
                                 *file_bufr,
                                 "n_catalogno",
                                 &cat_no_col
                                );

               /* Extract item no column no */
               PDUget_buffer_col(
                                 *file_bufr,
                                 "n_itemno",
                                 &item_no_col
                                );
              }

           part_found = FALSE;

           /* Malloc space for row */
           row = (IGRchar *) malloc ((*file_bufr)->row_size);

           for (j = 0; j < (*file_bufr)->rows; ++j)
               {
                if ( (strcmp(data1[((*file_bufr)->columns*j)+cat_no_col],
                      data[(asm_bufr->columns*i)+asm_cat_no_col]) == 0) &&
                     (strcmp(data1[((*file_bufr)->columns*j)+item_no_col],
                      data[(asm_bufr->columns*i)+asm_item_no_col]) == 0) )
                   {
                    _pdm_debug(
                             "part local file info already included", 0);

                    part_found = TRUE;
                    break;
                   }
               }

           if (!part_found)
              {
               /* Initialize row */
               row[0] = '\0';

               /* Load delete local file info to buffer */
               sprintf(
                       row,
                       "%s\1%s\1%s\1%s\1%s\1%s\1\1",
                       data[(asm_bufr->columns * i)+asm_cat_no_col],
                       data[(asm_bufr->columns * i)+asm_item_no_col],
                       data[(asm_bufr->columns * i)+asm_cat_col],
                       data[(asm_bufr->columns * i)+asm_part_col],
                       data[(asm_bufr->columns * i)+asm_rev_col],
                       data[(asm_bufr->columns * i)+asm_file_col]
                      );

               /* Write info to buffer */
               status = MEMwrite (*file_bufr, row);
               if (status != MEM_S_SUCCESS)
                  {
                   _pdm_debug("MEMwrite failed", 0);
                   return(status);
                  }
              }

           /* Load part children's file info, if they exist */
           while( (i < asm_bufr->rows) && ((i+1) < asm_bufr->rows) &&
                 (atoi(data[(asm_bufr->columns*(i+1))+asm_level_col]) > 1) )
                {
                 /* Process child */
                 ++i;

                 if ( (*file_bufr)->rows > 0)
                    {
                     /* Setup buffer */
                     MEMbuild_array(*file_bufr);
                     PDUsetup_buffer(*file_bufr, ROW, &data1);

                     /* Extract catalog no column no */
                     PDUget_buffer_col(
                                       *file_bufr,
                                       "n_catalogno",
                                       &cat_no_col
                                      );

                     /* Extract item no column no */
                     PDUget_buffer_col(
                                       *file_bufr,
                                       "n_itemno",
                                       &item_no_col
                                      );
                    }

                 /* Check to see if part info is already included in
                  * file_bufr
                  */
                 part_found = FALSE;

                 for (j = 0; j < (*file_bufr)->rows; ++j)
                     {
                      if ( (strcmp(data1[((*file_bufr)->columns*j)+cat_no_col],
                            data[(asm_bufr->columns*i)+asm_cat_no_col]) == 0) &&
                           (strcmp(data1[((*file_bufr)->columns*j)+item_no_col],
                            data[(asm_bufr->columns*i)+asm_item_no_col]) == 0) )
                         {
                          _pdm_debug(
                               "part local file info already included", 0);

                          part_found = TRUE;
                          break;
                         }
                     }
                     
                 if (!part_found) 
                    {
                     /* Initialize row */
                     row[0] = '\0';

                     /* Load delete local file info to buffer */
                     sprintf(
                             row,
                             "%s\1%s\1%s\1%s\1%s\1%s\1\1",
                             data[(asm_bufr->columns * i)+asm_cat_no_col],
                             data[(asm_bufr->columns * i)+asm_item_no_col],
                             data[(asm_bufr->columns * i)+asm_cat_col],
                             data[(asm_bufr->columns * i)+asm_part_col],
                             data[(asm_bufr->columns * i)+asm_rev_col],
                             data[(asm_bufr->columns * i)+asm_file_col]
                            );

                     /* Write info to buffer */
                     status = MEMwrite (*file_bufr, row);
                     if (status != MEM_S_SUCCESS)
                        {
                         _pdm_debug("MEMwrite failed", 0);
                         return(status);
                        }
                    }

                } /* End while loop */
          }
      } /* end for i loop */

  /* Free variables */
  if (row)
     free(row);

  return(PDM_S_SUCCESS);
 }


/* 
 * This function displays a part files and views.
 */

IGRint PDUdisplay_files_and_origins(
                                    catalog,
                                    number,
                                    revision,
                                    filename,
                                    viewname
                                   )
 IGRchar            *catalog;
 IGRchar            *number;
 IGRchar            *revision;
 IGRchar            **filename;
 IGRchar            **viewname;
  {
   IGRint            status;
   IGRchar           **data;
   IGRchar           msg[100];
   MEMptr            view_buffer = NULL;
   MEMptr            file_buffer = NULL;

   extern  MEMptr                   PDU_ret_bufr;
   extern  IGRchar                  *PDU_filename;
   extern  IGRchar                  *PDU_viewname;

   char	   stsmsg[256];

   _pdm_debug("In the function PDUdisplay_files_and_origins", 0);

   /* Get list of part files and view names */
   if (PDU_ret_bufr)
      {
       MEMclose(&PDU_ret_bufr);
       PDU_ret_bufr = NULL;
      }

   /* Get attach part info. */
   status = PDMget_part_attach_info(
                                    catalog,
                                    number,
                                    revision,
                                    0,
                                    &view_buffer,
                                    &file_buffer
                                   );
   _pdm_status("PDMget_part_attach_info", status);

   if ( (status != PDM_S_SUCCESS) || (view_buffer == NULL) ||
        (file_buffer == NULL) )
      {
       _pdm_debug("SEVERE error: no attach info found for this part", 0);
       return(status);
      }

   if (PDM_debug_on)
      MEMprint_buffer("part file list",  file_buffer, PDU_DEBUG_FILE);

   MEMsplit_copy_buffer(file_buffer, &PDU_ret_bufr, 0);

   if (PDU_ret_bufr)
      {
       if (PDU_ret_bufr->rows == 1)
          {
           _pdm_debug("one row found in PDU_ret_bufr buffer", 0);

           MEMbuild_array(PDU_ret_bufr);

           PDUsetup_buffer(
                           PDU_ret_bufr,
                           ROW,
                           &data
                          );

           /* Load file name to filename */
           PDUfill_in_string(filename, data[0]);
          }

       else
           {
            /* Display list of files */
            status = PDUdisplay_files();
            _pdm_status("PDUdisplay_files", status); 

            /* Wait on user selection */
            status = WaitForEvent();
            _pdm_status("WaitForEvent", status);

            UI_prompt("                                  ");

            if (!status)
               {
                _pdm_debug("form was cancelled", 0);
                return(0);
               }

            else
               PDUfill_in_string(filename, PDU_filename);

           }
      }

   _pdm_debug("file selected = <%s>", *filename);

   if (PDM_debug_on)
      MEMprint_buffer("part view list",  view_buffer, PDU_DEBUG_FILE);

   if (PDU_ret_bufr)
      {
       MEMclose(&PDU_ret_bufr);
       PDU_ret_bufr = NULL;
      }

   MEMsplit_copy_buffer(view_buffer, &PDU_ret_bufr, 0);


   if (PDU_ret_bufr)
      {
       if (PDU_ret_bufr->rows == 1)
          {
           _pdm_debug("one row found in PDU_ret_bufr buffer", 0);
           MEMbuild_array(PDU_ret_bufr);

           PDUsetup_buffer(
                           PDU_ret_bufr,
                           ROW,
                           &data
                          );

           /* Load view name to viewname */
           PDUfill_in_string(viewname, data[0]);

	   /* show view name in status field.		*/
           sprintf(stsmsg, "Single view '%s' defined", *viewname);
           UI_status(stsmsg);
          }

       else
           {
            /* Display list of part views */
            status = PDUdisplay_views();
            _pdm_status("PDUdisplay_views", status);

            /* Wait on user selection */
            status = WaitForEvent();
            _pdm_status("WaitForEvent", status);

            UI_prompt("                                  ");

            if (!status)
               {
                _pdm_debug("form was cancelled", 0);
                return(0);
               }

            else
                PDUfill_in_string(viewname, PDU_viewname);

           }

      }

   _pdm_debug("view selected = <%s>", *viewname);


   return(PDM_S_SUCCESS);
  }


/*
 * This function checks to see if a file is added to a part.
 */

IGRshort  PDUis_active_file_a_part()
 {
  IGRint              status = PDM_S_SUCCESS;
  IGRint              bufsiz;
  IGRchar             file_path[DI_PATH_MAX];
  IGRchar             *file_name = NULL;
  IGRchar             catalog[40];
  IGRchar             number[40];
  IGRchar             revision[40];
  struct GRmd_env     mod_env;


  _pdm_debug("In the PDUis_active_file_a_part function", 0);

  /* Make sure active refresh structure is populated */
  if ( (refresh->act_catalog) && (strcmp(refresh->act_catalog, "") != 0) &&
       (refresh->act_partid) && (strcmp(refresh->act_partid, "") != 0) &&
       (refresh->act_revision) && (strcmp(refresh->act_revision, "") != 0) )
     {
      _pdm_debug("active file is a part", 0);

      return(1);
     }

  /* Check to see if user is loged in */
  status =  PDUautomatic_login();
  _pdm_status("PDUautomatic_login", status);

  if (status != PDM_S_SUCCESS)
     {
      _pdm_debug("PDUautomatic_login failed", 0);

      return(0);
     }

  /* Get current module info. */
  bufsiz = sizeof(struct GRmd_env);
  gr$get_module_env(sizbuf = &bufsiz, buffer = &mod_env);

  /* Construct path to file name */
  di$give_pathname(
                   osnum = mod_env.md_id.osnum,
                   pathname = file_path
                  );

  file_name = file_path;
  file_name = ++file_name;

  /* Given filename, get part catalog, number, and revision. */
  status = PDMGetPartInfoGivenFileName(
                                       file_name,
                                       catalog,
                                       number,
                                       revision
                                      );
  _pdm_status("PDMGetPartInfoGivenFileName", status);

  if (status == PDM_S_SUCCESS)
     {
      _pdm_debug("active file is a part", 0);
      PDUfill_in_string(&refresh->act_catalog, catalog);
      PDUfill_in_string(&refresh->act_partid, number);
      PDUfill_in_string(&refresh->act_revision, revision);
      PDUfill_in_string(&refresh->act_filename, file_name);
      return(1);
     }

  else
      {
       _pdm_debug("active file is not a part", 0);

       return(0);
      }
 }


/*
 * This function checks to see if a PDU GRpart is positionless.
 */
IGRint  PDUis_part_positionless(
                                mod_env,
                                part_ids,
                                usage_id
                               )
  struct     GRmd_env          *mod_env;
  struct     PDUpart_node      *part_ids;
  IGRchar                      *usage_id;
 {
  IGRlong                    msg;
  IGRchar                    attr_value[MAX_VALUE];
  IGRchar                    part_type[MAX_VALUE];
  IGRint                     type;
  struct     PDUpart_node    *head = NULL;


  _pdm_debug("In the PDUis_part_positionless", 0);

  if (!part_ids)
     {
      _pdm_debug("part list is empty", 0);
      return(0);
     }

  _pdm_debug("usage_id = <%s>", usage_id);
  head = part_ids;

  /* Loop thru parts */
  while (head)
        {
         /* Extract GRpart usage id */
         co$part_get_attr (
                           msg = &msg,
                           mod_env = mod_env,
                           part = &(head->part_id),
                           attr = "usage_id",
                           value = attr_value,
                           type = &type
                          );

         /* Unqoute usage id */
         PDUunquote(attr_value);

         if (strcmp(attr_value, usage_id) == 0)
            {
             /* Extract serial no */
             co$part_get_attr (
                               msg = &msg,
                               mod_env = mod_env,
                               part = &(head->part_id),
                               attr = "serial",
                               value = attr_value,
                               type = &type
                              );
             _pdm_debug("serial = <%s>", attr_value);

             /* Extract part type from GRpart */
             co$part_get_attr (
                               msg = &msg,
                               mod_env = mod_env,
                               part = &(head->part_id),
                               attr = "part_type",
                               value = part_type,
                               type = &type
                              );

             /* Check to see if part is positionless */
             if ( (strcmp(attr_value, "-1.000000") == 0) &&
                  (strcmp(part_type, "n") != 0) &&
                  (strcmp(part_type, "N") != 0) )
                {
                 _pdm_debug("part <%s> is positionless", usage_id);
                 return(1);
                }
            }

         /* Process next part */
         head = head->next;

        } /* end while loop */

  return(0);
 }


/*
IGRint  PDUattach_GRpart(
                         catalog,
                         number,
                         revision,
                         part_id,
                         placement_matrix,
                         mod_env
                        )
 IGRchar *catalog;	
 IGRchar *number;
 IGRchar *revision;		
 struct  GRid part_id;   
 IGRmatrix placement_matrix;
 struct GRmd_env  mod_env; 
 {
  IGRlong    status = PDM_S_SUCCESS;
 
  _pdm_debug("In the PDUattach_GRpart function", 0);

  return(status);
 }
*/

IGRint PDUis_file_open(pathname)
 IGRchar *pathname;
 {
   IGRint  status = 0;

   _pdm_debug("In the function PDUis_file_open", 0);

   status = ex$is_file_open( name = pathname );
   _pdm_status("ex$is_file_open", status);

   return(status);
  }

end implementation COpdu; 
