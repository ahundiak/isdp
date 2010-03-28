/*

  Name

     GRrevreffiles

  Abstract

     This function is used to review the reference files and send the
     output to the output file and returns the all reference files GRids
     and attachment names in first level.

  Arguments

     IGRlong      *msg          (O) completion code.
     IGRchar      *outfile      (I) output filename.
     GRspacenum   *ref_osnum    (I) reference file osnum.
     IGRint       *num_ref      (O) number of reference files found.
     struct GRid  **ref_grid    (O) list of GRids of the reference files.
                                    This fucntion will allocate the required
                                    memory, the caller should free the pointer.
     IGRchar      ***ref_names  (O) list of attachment names.
                                    This fucntion will allocate the required
                                    memory, the caller should free the pointer.

  Return Values

    -MSSUCC if successful
    -MSFAIL if failure

  History

     Gang     08/12/93    Creation date.

*/

class implementation GRreffile;

#include "stdio.h"
#include "coimport.h"
#include "godef.h"
#include "grmsg.h"
#include "OMerrordef.h"
#include "OMminimum.h"
#include "OMindex.h"
#include "msmacros.h"
#include "exmacros.h"
#include "grmessage.h"
#include "DIdef.h"
#include "DItypedef.h"
#include "DIprims.h"
#include "grimport.h"
#include "igrtypedef.h"
#include "grmessage.h"
#include "grdpbdef.h"
#include "grdpbmacros.h"
#include "dpdef.h"
#include "dp.h"
#include "dpmacros.h"
#include "refdef.h"
#include "ref.h"
#include "refmacros.h"
#include "OMmacros.h"

from Super_rfmgr import GRget_channel_count, GRget_channel_objects;

IGRint GRrevreffiles(msg,
                     outfile,
                     ref_osnum,
                     num_ref,
                     ref_grid,
                     ref_names)
IGRlong *msg;
IGRchar *outfile;
GRspacenum *ref_osnum;
IGRint *num_ref;
struct GRid **ref_grid;
IGRchar ***ref_names;
{
    int		            sts,i,j;
    struct GRmd_env         cur_mod;
    IGRlong                 nbytes_in_buff,nbytes_trans;
    struct GRreport_info    review_info;
    extern int              GRrevref_report_output();
    FILE                    *fp,*fp2;
    struct GRid             refmgr;
    struct GRid             *ref_ptr;
    struct GRid             mod_id;
    OM_S_OBJID              *ref_objids=NULL;
    OMuword                 *ref_osnums=NULL;
    IGRulong                props;
    IGRshort                nest;
    IGRlong                 count,out_count;
    IGRchar                 full_name[DI_PATH_MAX];
    IGRchar                 temp_name[DI_PATH_MAX];
    IGRchar                 **temp_ptr;
    
    sts = OM_S_SUCCESS;
    *msg = MSSUCC;

        /* get the current module environment */

        nbytes_in_buff = sizeof(struct GRmd_env);
        sts = gr$get_module_env(msg = msg,
                                sizbuf = &nbytes_in_buff,
                                buffer = &cur_mod,
                                nret = &nbytes_trans);
        if(!(*msg & sts & 1))
         {
           goto quit;
         }

        if(outfile)
         {
           fp = fopen(outfile,"w");

           review_info.output_func = GRrevref_report_output;
           review_info.info = (IGRchar *) &fp;

           GRreffile_reports ( msg,
                            &cur_mod,
                            GR_reference_file_duposname |
                            GR_reference_file_found |
                            GR_reference_name | GR_reference_file_name |
                            GR_reference_instance_data | GR_saved_view_name |
               GR_reference_type | GR_file_properties | GR_reference_id,
                            &review_info,
                            TRUE );
          fflush(fp);
          fclose(fp);
        }

       if(ref_grid || ref_names || num_ref)
        {
           /* get the reference file manager */
          if(ref_osnum)
           {
             mod_id.osnum = *ref_osnum;
             ex$get_modid(mod_osnum = mod_id.osnum,
                          mod_id = &mod_id.objid);
           }
          else
           {
              mod_id.objid = cur_mod.md_id.objid;
              mod_id.osnum = cur_mod.md_id.osnum;
           } 

          sts = ex$get_super(
                            mod_id = mod_id.objid,
                            mod_osnum = mod_id.osnum,
                            super_name = "Ref Mgr",
                            super_class = "Super_rfmgr",
                            create = 0,
                            super_id = &refmgr.objid,
                            super_osnum = &refmgr.osnum );
          if(!(sts & 1))
          {
            if(num_ref)
              *num_ref = 0;
            goto quit;
          }
          props = 0;
          nest = FALSE;

          sts =  om$send(msg = message Super_rfmgr.GRget_channel_count(
                                                                       msg,
                                                                       &props,
                                                                       &nest,
                                                                       &count),
                         senderid = NULL_OBJID,
                         targetid = refmgr.objid,
                         targetos = refmgr.osnum);

          if (!(sts & *msg & 1) || count == 0)
           {
             if(num_ref)
               *num_ref = 0;
             goto quit;

           }
           

         ref_objids = (OM_S_OBJID *)malloc(sizeof(OM_S_OBJID) * count);
         ref_osnums = (OMuword *)malloc(sizeof(OMuword) * count);

         if(ref_objids == NULL|| ref_osnums == NULL)
          {
            printf("malloc failed\n");
            goto quit;
          }

          sts =  om$send(msg = message Super_rfmgr.GRget_channel_objects(
                                                           msg,
                                                           &props,
                                                           &nest,
                                                           &count,
                                                           ref_objids,
                                                           ref_osnums,
                                                           &out_count),
                        senderid = NULL_OBJID,
                        targetid = refmgr.objid,
                        targetos = refmgr.osnum);
                        
          if (!(sts & *msg & 1) || count != out_count)
           {
              printf("get reference file object ids failed\n");
              free(ref_objids);
              free(ref_osnums);
              goto quit;
           }
           
        
         if(ref_names)
          { 
             *ref_names = (IGRchar **)malloc(sizeof(IGRchar *) * count);
             temp_ptr = *ref_names;
             for(i=0; i < count; i++)
              {
                di$untranslate(objname = full_name,
                               objid = ref_objids[i],
                               osnum = ref_osnums[i]);

                di$split(pathname = full_name,
                         name = temp_name);

                temp_ptr[i] = (char *)malloc(strlen(temp_name) +1);
                strcpy(temp_ptr[i],temp_name);
              }
          }

        if(num_ref)
        {
          *num_ref = count;
         if(outfile!=NULL)
        {
        fp2 = fopen(outfile,"a");
        fprintf(fp2,"-------------------------------------------------\n");
        fprintf(fp2,"\n Number of Reffiles attached at 1st level=%d\n",count);
        fprintf(fp2,"-------------------------------------------------\n");

          fflush(fp2);
          fclose(fp2);
        }
        }

        if(ref_grid)
         {
           *ref_grid = (struct GRid *)malloc(sizeof(struct GRid) * count);
            ref_ptr = *ref_grid;

           for(j=0; j < count; j++)
             {
                 ref_ptr[j].objid = ref_objids[j];
                 ref_ptr[j].osnum = ref_osnums[j];
             }
         }

       }

 
quit:
  return sts;

}


#define ATTACHNAME "Attachment Name: "
#define UPDATE "Update: "
#define NESTING "Nesting: " 
#define CLIPPING "Clipping: "
#define DISPLAY "Display: "
#define FILENAME "File Name: "
#define SAVEVIEW "Saved View : "
#define SCALE "Scale: "
#define LEVEL "Depth: "
#define FILENOTFOUND "This attachment file not found"
#define REFFILEDUPOS "This attachment has invalid internal file identifier "

#define LINE_LEN 255


IGRint GRrevref_report_output ( msg, num, depth, requests, fp )
    IGRlong *msg;
    IGRint num;
    IGRint depth;
    struct GRinquire_list * requests;
    FILE  **fp;
{
    IGRchar  printline[11][LINE_LEN + 1];
    IGRchar  indent[120];
    register FILE * out_fp;
    register IGRint  i, j;
    IGRchar onbuff[DI_PATH_MAX], offbuff[DI_PATH_MAX];
    IGRchar name[DI_PATH_MAX];
    IGRulong *prop_word;
    struct GRid *grid_ptr;
    OM_p_DUPINTOS dup;
    IGRchar internal_name[OM_K_MAXINTOSNAME_LEN];
    IGRshort disp_props;
    IGRlong sts;

    disp_props = 0;
    /* for smooth complilation */
    j = num; 
    ex$message(msgnumb = GR_I_On, buff = onbuff);
    ex$message(msgnumb = GR_I_Off, buff = offbuff);
    for(j=0;j<11;j++)
       printline[j][0] = NULL;

    if (requests)
    {
        if ( fp )
          out_fp = *fp;
        else 
          out_fp = stdout;
        fprintf(out_fp,"-----------------------------------------------------------------\n");
    
        for(i=0; i < depth; i++)
           indent[i] = '>';
        indent[i] = '\0';
        sprintf(printline[8],"%s%d",LEVEL,depth);
 
        for (i=0; requests[i].var != END_REPORT_REQUEST; ++i)
        {

            switch (requests[i].var)
            {
            case REFERENCE_FILE_NAME :
            
                strcpy(printline[5],indent);
                strncat(printline[5],FILENAME,LINE_LEN);
                strncat(printline[5],requests[i].var_ptr,LINE_LEN);
                break;
           
            case SAVED_VIEW_NAME :
        
                strcpy(printline[6],indent);
                strncat(printline[6],SAVEVIEW,LINE_LEN);
                strncat(printline[6],requests[i].var_ptr,LINE_LEN);
                break;
     
            case REFERENCE_INSTANCE_DATA :
  
                strcpy(printline[7],indent);
                strncat(printline[7],SCALE,LINE_LEN);
                strncat(printline[7],((struct GRref_instance_data *)
                                     (requests[i].var_ptr))->scale,LINE_LEN);
                break;

            case FILE_PROPERTIES :

                strcpy(printline[3],indent);
                strncat(printline[3],CLIPPING,LINE_LEN);
                strcpy(printline[2],indent);
                strncat(printline[2],NESTING,LINE_LEN);
                prop_word = (IGRulong *)(requests[i].var_ptr);
                if(*prop_word & GRRF_SHRINK_WRAP)
                 {
                    strncat(printline[3],offbuff,LINE_LEN);
                 }
                else
                 {
                    strncat(printline[3],onbuff,LINE_LEN);
                 }
             
                if(*prop_word & GRRF_BACKGROUND)
                 {
                   strncat(printline[2],offbuff,LINE_LEN);
                 }
                else
                 {
                   strncat(printline[2],onbuff,LINE_LEN);
                 }
            
                break;

            case REFERENCE_ID :

               grid_ptr = (struct GRid *)requests[i].var_ptr;
               sts = om$send(msg = message GRgraphics.GRgetprops(msg,
                                                            &disp_props),
                             senderid = NULL_OBJID,
                             targetid = grid_ptr->objid,
                             targetos = grid_ptr->osnum);
                             

               strcpy(printline[4],indent);
               strncat(printline[4],DISPLAY,LINE_LEN);
               if(disp_props & GRIS_DISPLAYABLE)
                {
                    strncat(printline[4],onbuff,LINE_LEN);
                }
               else
                {
                    strncat(printline[4],offbuff,LINE_LEN);
                }

                break;

            case REFERENCE_NAME :
                di$split ( pathname = requests[i].var_ptr,
                           name = name );

                strcpy(printline[0],indent);
                strncat(printline[0],ATTACHNAME,LINE_LEN);
                strncat(printline[0],name,LINE_LEN);
                break;

            case REFERENCE_TYPE :
                strcpy(printline[1],indent);
                strncat(printline[1],UPDATE,LINE_LEN);
                if(!strcmp(requests[i].var_ptr,"write"))
                 {
                    strncat(printline[1],onbuff,LINE_LEN);
                 }
                else
                 {
                    strncat(printline[1],offbuff,LINE_LEN);
                 }
                break;

            case REFERENCE_FILE_FOUND :
                if(!(*(( IGRboolean *) requests[i].var_ptr)))
                 {
                  strcpy(printline[9],indent);
                  strncat(printline[9],FILENOTFOUND,LINE_LEN);
                 }
                break;

            case REFERENCE_FILE_DUPOSNAME :
            /*
             * If there is a duplicate.
             */
            if ( *(requests[i].var_ptr) )
            {
                dup = *((OM_p_DUPINTOS *)requests[i].var_ptr);

                /*
                 * Get the internal os name.
                 */
                om$os_number_to_internal_name ( osnum = dup->osnum,
                                                osname = internal_name );
                /*
                 * If the internal os name is different from the
                 * original internal osname.
                 */
                if ( strcmp(internal_name, dup->orig_intname) )
                {
                  strcpy(printline[10],indent);
                  strncat(printline[10],REFFILEDUPOS,LINE_LEN);
                }
            }


                break;

            }
        }

       for(j=0;j < 11;j++)
        {
           if(printline[j][0] != NULL)
            fprintf(out_fp,"%s\n",printline[j]);
        }
    }
    else *msg = MSINARG;
    return(1 & *msg);
}

end implementation GRreffile;
