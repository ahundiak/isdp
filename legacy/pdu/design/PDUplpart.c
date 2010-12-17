#include	<PDUerror.h>
#include        <string.h>
#include        <PDUextdef.h>
#include        <PDMtypes.h>
#include        <MEMerrordef.h>
#include        <PDUstr.h>
#include        <PDUintdef.h>
#include        <PDUproto.h>

int PDUconvert_dir_to_exp() 
    {
     long    status;
     char    **entries;
     char    **attr_data;
     char    *entry = NULL;
     char    *catpartrev = NULL;
     char    *catalog = NULL;
     char    *partid = NULL;
     char    *revision = NULL;
     char    *dyn_name = NULL;
     char    *p_explode = NULL;
     char    *s;
     MEMptr  dynamic_attr_buffr = NULL;
     MEMptr  dynamic_data_buffr = NULL;
     MEMptr  dynamic_list_buffr = NULL;
     int     entry_count = 0;
     int     dyn_type;
     int     i,j;
     
     

     _pdm_debug("In the function PDUconvert_dir_to_exp",0);
     
     /* check to see if object space needs conversion */
     status = PDUcheck_if_need_conversion();
     _pdm_status("PDUcheck_if_need_conversion",status);

     if (status == PDM_S_SUCCESS)
        {
         _pdm_debug("object space needs to be converted",0);
         
         /* extract all cat!part!rev directories from object space */
         status = PDUextract_catpartrev_entries(&entries, &entry_count);
         _pdm_status("PDUextract_catpartrev_entries",status);

         if (status == PDM_S_SUCCESS)
            {
             _pdm_debug("catpartrev entries were found",0);
             _pdm_debug("entry count = %d",(char *)entry_count);

  	     if (PDM_debug_on)
                {
                 for (i = 0; i < entry_count; ++i)
                     {
                      _pdm_debug("i = %d",(char *)i);
                      _pdm_debug("ith entry = <%s>",entries[i]);
                     }
                }

             /* for each entry, check to see if dynamic attributes exist, 
                and if so, converted to expression representation */
             for (i = 0; i < entry_count; ++i)
                 {
                  _pdm_debug("entry = <%s>",entries[i]);
                  
                  /* extract catalog, partid, and revision from entry */
                  PDUfill_in_string(&entry,entries[i]);
                  s = strtok(entry,":");
                  while(s)
                         {
                          _pdm_debug("token = <%s>",s);
                          if (strcmp(PDU_PARTS_DIR,s) == 0)
                             {
                              s = strtok(0,":");
                              PDUfill_in_string(&catpartrev,s);
                              _pdm_debug("extracted cat!part!rev = <%s>",
                                          catpartrev);
                              break;           
                             }
                          s = strtok(0,":"); 
                         }

                  if (s)
                       {
                        /* extract catalog */
                        s = strtok(catpartrev,"!");
                        PDUfill_in_string(&catalog,s);
                        _pdm_debug("extracted catalog = <%s>",catalog);

                        /* extract partid */
                        s = strtok(0,"!");
                        PDUfill_in_string(&partid,s);
                        _pdm_debug("extracted partid = <%s>",partid);

                        /* extract revision */
                        s = strtok(0,"!");
                        PDUfill_in_string(&revision,s);
                        _pdm_debug("extracted revision = <%s>",revision);

                        /* get dynamic attributes from PDM server */
                        status = PDMquery_dynamic_attrs(
                                                        catalog, 
                                                        partid,
                                                        revision,
					                &dynamic_attr_buffr,
					                &dynamic_data_buffr,
					                &dynamic_list_buffr,
                                                        &p_explode 
                                                       );
                        _pdm_status("PDMquery_dynamic_attrs", status);

                        if ((status != PDM_S_SUCCESS)||(!(dynamic_attr_buffr))) 
                           {
                            _pdm_debug("No dynamic attrs found for entry",0);
                            MEMclose(&dynamic_attr_buffr);
                            continue;
                           }

                        else
                           {
                            _pdm_debug("Dynamic attrs were found for entry",0);
                            
                            /* extract dynamic attrs and their types */ 
                            if (dynamic_attr_buffr)
                               {
                                 status = MEMbuild_array(dynamic_attr_buffr);
                                 _pdm_status("MEMbuild_array", status);

                                 if (status != MEM_S_SUCCESS)
                                 return(PDM_E_BUILD_BUFFER_ARRAY);
                               }

                            attr_data = (char **)dynamic_attr_buffr->data_ptr;
                            for (j = 1; j < dynamic_attr_buffr->rows; ++j)
                                {
                                 /* copy dyn name to dyn_name */
                                 PDUfill_in_string(&dyn_name,
                                    attr_data[(dynamic_attr_buffr->columns * j)+
                                          PDU_NFM_ATTR_COL]);

                                 if ((strncmp(attr_data[(dynamic_attr_buffr->
                                              columns * j)+PDU_NFM_DATA_COL],
                                              "char",4) == 0))
                                    {
                                     _pdm_debug("set type to TEXT",0);
                                     dyn_type = TEXT;
                                    }

                                 else
                                    {
                                     _pdm_debug("set type to NUMERIC",0);
                                     dyn_type = NUMERIC;
                                    }

                                 /* start conversion */
                                 status = PDUconvert_dyn_attrs(
                                                               catalog,
                                                               partid,
                                                               revision,
                                                               dyn_name,
                                                               dyn_type
                                                              );
                                 _pdm_status("PDUconvert_dyn_attrs",status);

                                 if (status != PDM_S_SUCCESS)
                                    {
                                     _pdm_debug("PDUconvert_dyn_attrs failed",
                                                0); 
                                     return(status);
                                    }
                                }
                           }

                       }
                 }

                 /* need to flag object space for successful completion of 
                    conversion */
                 /*
                 status = PDUflag_object_space();
                 _pdm_status("PDUflag_object_space",status);
                 */
            }

         else
            {
             _pdm_debug("catpartrev entries were not found",0);
             _pdm_debug("conversion is not needed",0);
             status = PDM_S_SUCCESS;
            }
        }

     return(status);
    }


















