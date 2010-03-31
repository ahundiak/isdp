/*******************************************************************************
*              			                                               *
* File:   Convert.u              	                                       *
*              			                                               *
* Description:              		                                       *
*                                                                              *
*     This file convert EMS desg. file having attached ref. files to           *
*     assembly part files.                                                     *
*              			                                               *
* History:         19/05/97      Anand, k s   creation date                    *
*                                                                              *
*******************************************************************************/

class implementation ECPlPrt;
#include "stdio.h"
#include "string.h"
#include "OMminimum.h"
#include "OMmacros.h"
#include "OMprimitives.h"
#include "OMindex.h"
#include "igetypedef.h"
#include "igrtypedef.h"
#include "tools.h"
#include "FI.h"
#include <exdef.h>
#include <ex.h>
#include <exmacros.h>
#include <gr.h>
#include <grdpbdef.h>
#include <grdpbmacros.h>
#include "DIdef.h"
#include "dpdef.h"
#include "DItypedef.h"
#include "DIglob.h"
#include "DIprims.h"
#include "dp.h"
#include "dpmacros.h"
#include "griodef.h"
#include "griomacros.h"
#include "refdef.h"
#include "asmprtmac.h"
#include "asmfilemac.h"
#include "assemdef.h"
#include "assem.h"
#include "assemmacros.h"
#include "EC_P.h"
#include "EC_I.h"
#include "EC_M.h"
#include "emsdef.h"

#include "lcdef.h"
#include "lc.h"
#include "lcmacros.h"
#include "grmsg.h"

//Form labels
#define FI_ACCEPT 1
#define FI_CANCEL 4

#define EXTERN extern
#include "asmglobals.h"

#define MAXPATHLEN 256

#include "refmacros.h"
#include "ref.h"



from GRreffile import GRrfgetfilename, GRinquireref, GRgetlbsys;
from GRreffile import GRgetenvironment, GRdelete, GRputscale;
from EMinstance import EMupdatebasis;
from GRgraphics import GRdisplay;

extern int generate_itemno(struct GRid *, char **);
extern GRclassid OPP_EMinstance_class_id;
extern struct EX_invisible_module *invisible_table;


IGRlong Convert_reffiles_to_assemlyfile()
{
    IGRlong msg, ret;
    struct GRid *ref_ids; 
    IGRchar **ref_names ;
    IGRint num_ref,i_ref,i_nobj;
    struct GRmd_env mod_env, mod_env_ref;
    struct GRid pid;
    IGRchar   *file, filepath[OM_K_MAXOSNAME_LEN];
    IGRchar pathname[DI_PATH_MAX];

    gr$get_module_env( buffer = &mod_env );

  ret = asm$get_file_part( msg = &msg,
                           mod_env = &mod_env,
                           part_id = &pid );
  if( !(ret & msg & 1 ))
  {
    EMattr attrs[3];

    /* Create a default file part definition in the master file */
    attrs[0].info.type = EM_PART_ATTR;
    attrs[0].value.type = EM_STRING;
    strcpy(attrs[0].info.name, "description");
    strcpy(attrs[0].info.desc, "Part Description");
    strcpy(attrs[0].value.syntax, "File Part");

    attrs[1].info.type = EM_COMMON_ATTR;
    attrs[1].value.type = EM_STRING;
    strcpy(attrs[1].info.name, "itemno");
    strcpy(attrs[1].info.desc, "Item Number");
    strcpy(attrs[1].value.syntax, "1");

    attrs[2].info.type = EM_INSTANCE_ATTR;
    attrs[2].value.type = EM_INTEGER;
    strcpy(attrs[2].info.name, "quantity");
    strcpy(attrs[2].info.desc, "Quantity");
    strcpy(attrs[2].value.syntax, "1");

    ret = ex$filename( name= filepath,
                       len= OM_K_MAXOSNAME_LEN);

    if((file = strrchr(filepath, '/')) != NULL)
        strcpy(filepath, file+1);

    ret = asm$create_file_part( msg = &msg,
                                number = filepath,
                                revision = "1",
                                mod_env = &mod_env,
                                num_attributes = 3,
                                attributes = attrs );
   if( !(ret & msg & 1) )
    {
      ex$message( msgnumb = EMS_S_NoPrtDef );
      return( OM_E_ABORT );
    }
  }

    gr$review_ref_files(msg = &msg,
                       output_file = NULL,
                       ref_grids = &ref_ids,
                       ref_names = &ref_names,
                       num_found = &num_ref); 

/* */
     for(i_ref=0 ; i_ref < num_ref; i_ref++)
      {
        IGRint          i_nobj,entry_num;
        IGRlong         msg, okl;
        struct GRmd_env mod_env_ref;
        OM_S_CHANSELECT       chan_to_owners;
        OM_S_OBJECT_LINKAGE   own_list[10]; 
        OMuint                count; 
        GRclassid             classid;
        om$send ( msg = message GRreffile.GRgetenvironment (&okl,
                                                              &mod_env,
                                                              &mod_env_ref),
                          senderid =NULL_OBJID,
                          targetid = ref_ids[i_ref].objid,
                          targetos = ref_ids[i_ref].osnum );
          ex$is_invis(mod_osnum = mod_env_ref.md_id.osnum, index = &entry_num);

          if(invisible_table[entry_num].permis_flag == EX_read_only)
          {

           //ex$message(in_buff="File read only", field=ERROR_FIELD);
          }
          else
          {
            struct     GRinquire_list request[3];
            IGRboolean pass_to_other_spaces = FALSE;
            IGRint     ok;
            IGRchar    buffer_name[DI_PATH_MAX];
            IGRchar    buffer_sview[DI_PATH_MAX];


            request[0].var = REFERENCE_NAME;
            request[0].var_ptr = (char *)buffer_name;
            request[0].num_requested = DI_PATH_MAX;
            request[0].num_returned  = DI_PATH_MAX;

            request[1].var = SAVED_VIEW_NAME;
            request[1].var_ptr = (char *)buffer_sview;
            request[1].num_requested = DI_PATH_MAX;
            request[1].num_returned  = DI_PATH_MAX;

            request[2].var = END_REPORT_REQUEST;
            om$send(msg = message GRreffile.GRinquireref(&msg,
                                                     &mod_env,
                                                     request,
                                                     &ok,
                                                     &pass_to_other_spaces,
                                                     NULL),
                                         senderid =NULL_OBJID,
                                         targetid=ref_ids[i_ref].objid,
                                         targetos=ref_ids[i_ref].osnum);
            EMmake_chanselect (GRconnector_to_owners, &chan_to_owners); 
            om$get_channel_objects (objid = ref_ids[i_ref].objid,
              osnum = ref_ids[i_ref].osnum, p_chanselect = &chan_to_owners,
              count = &count, size = 10, list = own_list);

          for(i_nobj=0;i_nobj<count;i_nobj++)
           { 
            om$get_classid (objid = own_list[i_nobj].S_objid,
                       osnum = ref_ids[i_ref].osnum,
                       p_classid = &classid);          
            if(om$is_ancestry_valid (subclassid = classid, 
               superclassid = OPP_EMinstance_class_id) == OM_S_SUCCESS)
                 goto cnt;
           }
            if(strcmp(buffer_sview,""))
                 di$rm_name(regexp = buffer_name);
         }
          cnt:
            continue;
      }
 

// start processing GRreffile 
     for(i_ref=0 ; i_ref < num_ref; i_ref++)
      {
        struct     GRinquire_list request[5];
        IGRboolean pass_to_other_spaces = FALSE;
        IGRint     ok,size,entry_num;
        struct     GRref_instance_data buffer;
        IGRchar    buffer_sview[DI_PATH_MAX],buffer_filename[DI_PATH_MAX]; 
        IGRchar    buffer_name[DI_PATH_MAX];

        IGRint     num_inst_attrs;         /* Number of instance attributes */
        EMattr     *inst_attrs=NULL;      /* instance attributes */
        IGRint     change_itemno;
        IGRchar    *itemno;
        IGRlong    okl;

        OM_S_CHANSELECT       chan_to_owners;
        OM_S_OBJECT_LINKAGE   own_list[10]; 
        OMuint                count; 
        GRclassid             classid;

       // chek for EMinstance on GRreffile for this processor to act smart
       // in case of dual tool run on the same design file having reffiles.

     
       EMmake_chanselect (GRconnector_to_owners, &chan_to_owners); 
       om$get_channel_objects (objid = ref_ids[i_ref].objid,
              osnum = ref_ids[i_ref].osnum, p_chanselect = &chan_to_owners,
              count = &count, size = 10, list = own_list);

     for(i_nobj=0; i_nobj<count; i_nobj++)
     {
       om$get_classid (objid = own_list[i_nobj].S_objid,
                       osnum = ref_ids[i_ref].osnum,
                       p_classid = &classid);          
       if(om$is_ancestry_valid (subclassid = classid, 
            superclassid = OPP_EMinstance_class_id) == OM_S_SUCCESS)
            goto ret_end;
     } 

   // check the module for read_only property and disregard it for conversion

    om$send ( msg = message GRreffile.GRgetenvironment (&okl,
                                                        &mod_env,
                                                        &mod_env_ref),
                      senderid =NULL_OBJID,
                      targetid = ref_ids[i_ref].objid,
                      targetos = ref_ids[i_ref].osnum ); 

     ex$is_invis(mod_osnum = mod_env_ref.md_id.osnum, index = &entry_num);

     if(invisible_table[entry_num].permis_flag == EX_read_only)
     {

      //ex$message(in_buff="File read only", field=ERROR_FIELD);
      goto ret_end;
     }


       // query for ref file props       

        size = sizeof(struct GRref_instance_data); 
        request[0].var = REFERENCE_INSTANCE_DATA;
        request[0].var_ptr = (char *)&buffer;
        request[0].num_requested = size;
        request[0].num_returned  = size;

        // query for saved view name 
        request[1].var = SAVED_VIEW_NAME;
        request[1].var_ptr = (char *)buffer_sview;
        request[1].num_requested = DI_PATH_MAX;
        request[1].num_returned  = DI_PATH_MAX; 

        request[2].var = REFERENCE_FILE_NAME;
        request[2].var_ptr = (char *)buffer_filename;
        request[2].num_requested = DI_PATH_MAX;
        request[2].num_returned  = DI_PATH_MAX; 

        request[3].var = REFERENCE_NAME;
        request[3].var_ptr = (char *)buffer_name;
        request[3].num_requested = DI_PATH_MAX;
        request[3].num_returned  = DI_PATH_MAX; 

        request[4].var = END_REPORT_REQUEST;

        om$send(msg = message GRreffile.GRinquireref(&msg,
                                                     &mod_env,
                                                     request,
                                                     &ok,
                                                     &pass_to_other_spaces,
                                                     NULL),
                                         senderid =NULL_OBJID,
                                         targetid=ref_ids[i_ref].objid,
                                         targetos=ref_ids[i_ref].osnum);


        if(strcmp(buffer_sview,"")==0)
          goto ret_end;
        
    
  // Scaling is not supported

  if(strcmp(buffer.scale,"1")!=0)
    {
       enum GRdpmode disp_mode;
       disp_mode = GRbe;
       om$send(msg = message GRgraphics.GRdisplay(
                                                 &msg,
                                                 &mod_env.md_env.matrix_type,
                                                 mod_env.md_env.matrix,
                                                 &disp_mode,
                                                 &mod_env.md_id),
                                      senderid = NULL_OBJID,
                                      targetid = ref_ids[i_ref].objid,
                                      targetos = ref_ids[i_ref].osnum);
       strcpy(buffer.scale,"1");
       om$send (msg = message GRreffile.GRputscale(&msg,
                                                  buffer.scale),
                                         senderid =NULL_OBJID,
                                         targetid=ref_ids[i_ref].objid,
                                         targetos=ref_ids[i_ref].osnum);      
    } 
 // get default_attributes   

 {
  struct  GRid partid;
  IGRint     sts,i,fileno,flag;
  IGRlong    msg;


  if( !(get_filepart_id( buffer_filename, &partid, &fileno, &flag ) ))
  {
        /* printf("given file is not a filepart\n");*/
                ex$close_module(ftype = EX_invisible, index = fileno);
        return( OM_E_ABORT );
  }

  sts = asm$attribute_count( msg = &msg,
             id = &partid,
             type = EM_INSTANCE_ATTR | EM_COMMON_ATTR,
             count = &num_inst_attrs );
  if( !( sts & msg & 1 ) )
  {
        return( OM_E_ABORT );
  }

        if(inst_attrs)
         free(inst_attrs);
  inst_attrs = ( EMattr * )malloc( sizeof( EMattr ) * num_inst_attrs );

  for( i = 0 ; i < num_inst_attrs; i++ )
  {
        sts = asm$get_attribute (msg = &msg,
                                 id = &partid,
                 type = EM_INSTANCE_ATTR | EM_COMMON_ATTR,
                                 index = i,
                                 attribute = &inst_attrs[i]);
        if( !(sts & msg & 1 ))
        {
#ifdef DEBUG
                printf("Error getting attribute at %d\n",i);
#endif  
          continue;
        }
        if( !strcmp( inst_attrs[i].info.name, "itemno" ) )
        {
          change_itemno = generate_itemno( &partid, &itemno );
                strcpy( inst_attrs[i].value.syntax,itemno );
        }
        if( !strcmp( inst_attrs[i].info.name, "quantity" ) )
        {
         if( !strlen( inst_attrs[i].value.syntax ))
         {
           strcpy( inst_attrs[i].value.syntax,"1" );
           inst_attrs[i].value.data.i = 1;
         }
        }
  }

 }
 // end of getting default attributes

 // create instance     
 {
  IGRint    props, om_msg, sizbuf, i;
  IGRlong   msg;
  struct    GRid inst_id, part_id, cnstid;
  IGRdouble origin_pt[3]; 
  IGRmatrix input_lbsys, win_mat;
  struct IGRlbsys lbsys;

   props = EM_REFERENCE_PART | EM_IN_BOM |
                                EM_DEFAULT_DISPLAY ;  
   props = props & ~EM_REFPLANE_DISPLAYED;
   props = props & ~EM_HANDLE_DISPLAYED;

   if(buffer.ref_properties & GRRF_BACKGROUND)
      props = props | EM_BACKGROUND;

   origin_pt[0] = buffer.ref_to_master_matrix[3];
   origin_pt[1] = buffer.ref_to_master_matrix[7];
   origin_pt[2] = buffer.ref_to_master_matrix[11];

  // get window matrix 

  /* get local boundary system of the ref_file and find 
   * the local_to_world tranformation rotation matrix
   * using the lbsys and the origin of ref_file in wc, 
   * which is needed for creating the instance 
   */ 


  {
        IGRlong     msg_w;        

        om$send (msg = message GRreffile.GRgetlbsys
                                                 (&msg_w,
                                                  &mod_env.md_env.matrix_type,
                                                  mod_env.md_env.matrix,
                                                  &lbsys),
                                         senderid =NULL_OBJID,
                                         targetid=ref_ids[i_ref].objid,
                                         targetos=ref_ids[i_ref].osnum);

        memcpy(input_lbsys, lbsys.matrix, sizeof(IGRmatrix)); 

        MAlswcmx(&msg_w,origin_pt,input_lbsys,win_mat);
  }

  origin_pt[0] = lbsys.matrix[3];
  origin_pt[1] = lbsys.matrix[7];
  origin_pt[2] = lbsys.matrix[11];


  om_msg=asm$create_instance(msg = &msg,
                             mod_env = &mod_env,
                             filename = buffer_filename,
                             type = props & EM_PART_TYPES,
                             display=props & EM_DISPLAY_PROPS,
                             behavior =props&EM_BEHAVIOR_PROPS,
                             view = buffer_sview,
                             origin = origin_pt,
                             matrix = win_mat,
                             num_attributes=num_inst_attrs,
                             attributes = inst_attrs,
                             instance_id = &inst_id);

   if( om_msg & msg & 1 )
     {
 // delete GRreffile(old), erase it and display the new EMinstance 
    enum GRdpmode disp_mode;
    disp_mode = GRbe;

       om$send(msg = message GRgraphics.GRdisplay(
                                        &msg,
                                        &mod_env.md_env.matrix_type,
                                        mod_env.md_env.matrix,
                                        &disp_mode,
                                        &mod_env.md_id),
                                      senderid = NULL_OBJID,
                                      targetid = ref_ids[i_ref].objid,
                                      targetos = ref_ids[i_ref].osnum);

       om$send(msg = message GRgraphics.GRdelete(&msg,
                                        &mod_env),
                                      senderid = NULL_OBJID,
                                      targetid = ref_ids[i_ref].objid,
                                      targetos = ref_ids[i_ref].osnum);
    


       disp_mode = GRbd;
       om$send(msg = message GRgraphics.GRdisplay(
                                        &msg,
                                        &mod_env.md_env.matrix_type,
                                        mod_env.md_env.matrix,
                                        &disp_mode,
                                        &mod_env.md_id),
                                      senderid = NULL_OBJID,
                                      targetid = inst_id.objid,
                                      targetos = inst_id.osnum);

       om_msg = asm$get_instance_part( msg = &msg,
                                       instance_id = &inst_id,
                                       part_id = &part_id );    

                    for(i=0;i<num_inst_attrs;i=i+1)
                    {
                      if( !strcmp(inst_attrs[i].info.name,"itemno"))
                      {
                        om_msg=asm$mod_attribute(msg = &msg,
                                                 id = &part_id,
                                                 name = "itemno",
                                                 attribute=&inst_attrs[i]);
#ifdef DEBUG
                        if( !(om_msg&msg&1) )
                           printf("Modify itemno failed\n");
#endif
                      }
                     }
                    om_msg = asm$instance_count( msg = &msg,
                                                 part_id = &part_id,
                                                 count = &sizbuf );

                    if(om_msg & msg & 1)
                    {
                      if(sizbuf == 1) /* First instance */
                      {
                        /* Check if this is the first part being
                         * placed.
                         */
                        om_msg = asm$part_count( msg = &msg,
                                                 type = EM_CACHED_PART |
                                                        EM_LOCAL_PART,
                                                 count = &sizbuf );

                        if((om_msg & msg & 1) && (sizbuf == 1))
                        {

                                    /* Ground first instance of first part */
                          om_msg = asm$add_constraint(msg = &msg,
                                                      instance2_id = &inst_id,
                                                      constraint_id = &cnstid);

                          if( !( om_msg & msg & 1 ))
                          {
                            ex$message( msgnumb = EMS_S_OpFail );
                          }
                          else
                          {
                            /*
                             * update the basis of the instance
                             */
                om_msg = om$send( msg = message EMinstance.EMupdatebasis(&msg),
                                              senderid = NULL_OBJID,
                                              targetid = inst_id.objid,
                                              targetos = inst_id.osnum );
#ifdef DEBUG
                            if( !(om_msg & msg & 1 ))
                            printf("EMupdatebasis failed\n");
#endif
                          }
    }

                        /* update the part display */
                        om_msg = asm$update_part_display(msg = &msg,
                                                         part_id= &inst_id,
                                                         mod_env=&mod_env);
                      }
                      ex$message(field = ERROR_FIELD,
                                 msgnumb = EMS_I_ClearStatusField);
                    }
                }
                    else
                {
                      ex$message(field = ERROR_FIELD,
                             msgnumb = EMS_E_OperationFailed);

                }


     }

      if(inst_attrs)
        free(inst_attrs);

//      ex$message(field = ERROR_FIELD,
//             msgnumb = EMS_I_ClearStatusField);

ret_end :
 continue; 

}// end for loop

// set directory to usr of master file    

   di$give_pathname(osnum = mod_env.md_id.osnum, pathname = pathname);
   strcat(pathname,":usr");
   di$cd(dirname = pathname);

// cleanup
 
 if (ref_names)
 {
  IGRint ii;
  for(ii=0; ii<num_ref;ii++)
           if (ref_names[ii]) free(ref_names[ii]);
     free(ref_names);
 } 

return(OM_S_SUCCESS);

}

IGRint convert_notify(form_label, gadget_label, value, form_ptr )
IGRint form_label, gadget_label;
IGRdouble value;
Form  form_ptr;
{
  switch(gadget_label)
  {
   case FI_ACCEPT:
    Convert_reffiles_to_assemlyfile();
    FIf_erase(form_ptr);
   break;

   case FI_CANCEL:
    FIf_erase(form_ptr);
    break;
  }
  return(OM_S_SUCCESS);

}

IGRlong convert() 
{
   struct GRid     *ref_ids;
   IGRchar         **ref_names, *fp1;
   IGRint          num_ref, i_ref, rdonly_count=0, entry_num;
   IGRlong         msg, okl;
   struct GRmd_env mod_env, mod_env_ref;
   IGRboolean            aflag = 0;

   if(aflag = pwIsActivationOn())
    {
     ex$message (in_buff="Deactivate the activated part",
                 field=ERROR_FIELD);
     return (OM_S_SUCCESS);
    }


   gr$get_module_env( buffer = &mod_env );
   gr$review_ref_files(msg = &msg,
                       output_file = NULL,
                       ref_grids = &ref_ids,
                       ref_names = &ref_names,
                       num_found = &num_ref);


   for(i_ref=0 ; i_ref < num_ref; i_ref++)
    {
    // check the module for read_only property and disregard it for conversion
          om$send ( msg = message GRreffile.GRgetenvironment (&okl,
                                                              &mod_env,
                                                              &mod_env_ref),
                          senderid =NULL_OBJID,
                          targetid = ref_ids[i_ref].objid,
                          targetos = ref_ids[i_ref].osnum );

           ex$is_invis(mod_osnum = mod_env_ref.md_id.osnum, index = &entry_num);

          if(invisible_table[entry_num].permis_flag == EX_read_only)
          {

           //ex$message(in_buff="File read only", field=ERROR_FIELD);
           rdonly_count++;
          }
    }
    if(rdonly_count != 0)
    {
      FIf_new(100, "CnvtNotifFrm", convert_notify, &fp1);
      FIf_display(fp1);
    }
    else
      Convert_reffiles_to_assemlyfile(); 

 if (ref_names)
 {
  IGRint ii;
  for(ii=0; ii<num_ref;ii++)
           if (ref_names[ii]) free(ref_names[ii]);
     free(ref_names);
 } 
   return(OM_S_SUCCESS);

}

end implementation ECPlPrt;
