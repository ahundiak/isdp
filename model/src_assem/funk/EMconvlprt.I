class implementation EMlocalpart;

#include "stdio.h"
#include "stdlib.h"
#include "string.h"
#include "exdef.h"
#include "exmacros.h"
#include "madef.h"
#include "coparamac.h"
#include "godef.h"
#include "gr.h"
#include "igr.h"
#include "igrdp.h"
#include "go.h" 
#include "dpdef.h"
#include "dp.h"
#include "dpmacros.h"
#include "OMprimitives.h"
#include "OMminimum.h"
#include "OMmacros.h"
#include "dpstruct.h"
#include "igewindef.h"
#include "igewinmacros.h"
#include "igetypedef.h"
#include "griodef.h"
#include "grio.h"
#include "griomacros.h"
#include "grdpbdef.h"
#include "grdpbmacros.h"
#include "emsdef.h"
#include "asdef.h"
#include "AS_status.h"
#include "ASmessages.h"
#include "grmsg.h"
#include "refdef.h"
#include "refmacros.h"
#include "msmacros.h"
#include "lcdef.h"
#include "lc.h"
#include "lcmacros.h"
#include "EC_I.h"
#include "EC_M.h"
#include "assemdef.h"
#include "assem.h"
#include "assemmacros.h"


#define Null ((char *)NULL)

#ifdef TRACE
#define trace(x) x
#else
#define trace(x)
#endif

#define OIDS_SIZE  256;

/* global local part objects list */
%safe
struct GRid *obj_list;
IGRint num_obj;
IGRint list_size;
%endsafe

from IGEgadget import add_gadget, activate;
from IGEgragad import gragad_cons;

#argsused
IGRlong EMget_lprt_objects(msg,
			   mod_env,
			   id,
			   info)
IGRlong *msg;
struct GRmd_env *mod_env;
struct GRid *id;
IGRchar *info;
{
   if(list_size <= num_obj)
    {
       list_size = list_size + OIDS_SIZE;
       obj_list = (struct GRid *)realloc(obj_list, 
					 sizeof(struct GRid) * list_size);
    }

   if(obj_list)
    {
      obj_list[num_obj].objid = id->objid;
      obj_list[num_obj].osnum = id->osnum;
      num_obj += 1;
      *msg = MSSUCC;
      return(OM_S_SUCCESS);
    }
   else
    {
      *msg = MSFAIL;
      return(OM_E_ABORT);
    }

}


/*----------------------------------------------------------------------------*
   
  Name

      ASMConvLocPrt

  Description

      This is the main fucntion for Split Local Part or Convert Local
      Part to File Part. This function will save the graphics belong
      to the given local part to the given file. It will modify the
      file part attributes in the new file with the user supplied 
      attributes. Any desired view in the masterfile can be copied to
      the newfile by passing the view_id. If the delete flag is TRUE
      then the local part and its graphics will be deleted. If the 
      place_part flag is TRUE then the new filepart will be instanced
      in the masterfile.

  Notes

      o If the delete option is not set and the given localpart number
	is same as the new filepart number, we can't instanciate that
	part, so tell the user about this and ask him to change the
	number.
       

  History

      Gang    03/08/94    Creation.

*----------------------------------------------------------------------------*/

#argsused
IGRlong ASMConvLocPrt(msg,
		      part_id,
		      filename,
		      seedfile,
		      numattrs,
		      attrs,
		      view_id,
		      delete,
		      place_part)
IGRlong     *msg;                         /* O return status */
struct GRid *part_id;                     /* I local part grid */
IGRchar     *filename;                    /* I filename        */
IGRchar     *seedfile;                    /* I seedfile name   */
IGRint      *numattrs;                    /* I number of attributes */
EMattr      *attrs;                       /* I attributes array */
struct GRid *view_id;                     /* I view id in master file */
IGRboolean  delete;                       /* I delete flag TRUE/FALSE */
IGRboolean  place_part;                   /* I place part flag TRUE/FALSE */
{
  IGRint    sts ,rc;
  IGRint    i,j,file_no;
  struct    GRmd_env md_env;
  struct    GRlc_locate loc_attrs;
  struct    GRid filepart_id;
  struct    GRmd_env new_env;
  IGRlong   layers[32];
  IGRchar   number[MAX_VALUE];
  IGRchar   revision[MAX_VALUE];
  EMattr    *attributes;
  EMattr    attr;
  IGRboolean attr_exist;
  IGRint    number_of_attrs;
  IGRint    count;
  IGRboolean old_mode;
  struct    var_list params[12];
  IGRchar   gragad_name[120];
  struct    GRid ref_view,inst_id;
  IGRint    which_error;
  IGRlong   bytes_ret;
  IGRint    props;
  IGRchar   path[DI_PATH_MAX];
  IGRdouble origin[3];
  struct    gragad_inst gragad_inst;
  IGRboolean create_part;

        /* Initialize the pointers */

	sts = OM_S_SUCCESS;
	rc = OM_S_SUCCESS;
	*msg = ASM_S_SUCCESS;
	obj_list = NULL;
	filepart_id.objid = NULL_OBJID;
	ref_view.objid = NULL_OBJID;
	attr_exist = FALSE;

        /*** get the current module environment */

        sts = gr$get_module_env( buffer = &md_env);

        /* get the localpart layers */

	sts = om$send(msg = message EMlocalpart.EMget_layers(msg,
						             layers,
						             NULL,
						             NULL),
                      senderid = NULL_OBJID,
		      targetid = part_id->objid,
		      targetos = part_id->osnum);

        if(!(sts & *msg & 1))
         {
	    goto quit;
         }
 
	loc_attrs.properties = LC_RW | LC_LC_ONLY | LC_DP_ONLY;
	loc_attrs.owner_action = LC_GEOM_MOD | LC_ASSOCIATIVE |
				 LC_EXTERN_CONSTRAINED | LC_REF_HEADER;

        list_size = OIDS_SIZE;
	num_obj = 0;
	obj_list = NULL;
	obj_list = (struct GRid *)malloc(sizeof(struct GRid) * list_size);
	if(!obj_list)
	 {
	   sts = OM_E_ABORT;
	   *msg = ASM_E_ABORT;
	   goto quit;
         }

        /* get all the graphic objects of the localpart */
        sts = EMlayer_pass(msg,
			   &md_env,
			   layers,
			   &loc_attrs,
			   NULL,
			   EMget_lprt_objects,
			   NULL);
        if(!(sts & *msg & 1))
	 {
	    goto quit;
         }
        
	create_part = TRUE;
	/* copy all the graphic objects of the localpart to the new file. */
        sts = ASMSplitPart(msg,
			   &md_env,
			   obj_list,
			   &num_obj,
			   filename,
			   seedfile,
			   &delete,
			   &create_part);
        if(!(sts & *msg & 1))
         {
	   goto quit;
	 }

        if(delete)
	 {
	    /* delete the local part */

	    sts = om$send(msg = message EMdescribe.EMdelete(msg),
			  senderid = NULL_OBJID,
			  targetid = part_id->objid,
			  targetos = part_id->osnum);
            if(!(sts & *msg))
	     {
	       trace(printf("local part delete failed\n"));  /* replace with error 
							 return */
	     }
	 }


        DIstmocpy(path,"ref",filename,0,md_env.md_id.osnum);

        /* tell the system that the file is opened for reading partdata */

        ASMset_reading_partdata();
       
	sts = ex$retrieve_module( msg = &rc, ftype = EX_invisible,
                           filename = filename,
                           flag = EX_read_write, file_no = &file_no,  
			   mount_name = path,mod_type = 2,
                           type = EX_ref,
                           fstat = EX_old_module );

        /* reset */

        ASMreset_reading_partdata();

	if( sts & 1 )
	 {
		sts = ex$get_invis_info_by_index ( index = file_no,
					  mod_osnum = &new_env.md_id.osnum,	
					  mod_id = &new_env.md_id.objid );
                if(!(sts & 1))
	         {
	            ex$close_module(ftype = EX_invisible, index = file_no);
	            *msg = ASM_E_ABORT;
	            goto quit;
                 }

	        sts =  asm$get_file_part (msg = msg,
		                          mod_env = &new_env,
                		          part_id = &filepart_id);
	 }
	else
	 {
	      *msg = ASM_E_ABORT;
	      goto quit;
	 }

        new_env.md_env.matrix_type = MAIDMX;
        MAidmx(msg,new_env.md_env.matrix);

        strcpy(number,attrs[0].value.syntax);
	strcpy(revision,attrs[1].value.syntax);
	attributes = &attrs[0];
	number_of_attrs = *numattrs;

        if(filepart_id.objid == NULL_OBJID)
	 {
            /* newfile is not a filepart, create filepart. But there is
	       a problem in creating the filepart, display an error
	       message */

            sts = asm$create_file_part(msg = msg,
				       mod_env = &new_env,
				       number = number,
				       revision = revision,
				       num_attributes = number_of_attrs,
				       attributes = attributes);

         }
        else
	 {

	    /* modify the new filepart attributes */
            count = 0;
	    old_mode = EMdesc_set_system_mode(TRUE);
            sts = asm$attribute_count(msg = msg,
				      type = EM_PART_ATTR|EM_INSTANCE_ATTR |
					     EM_COMMON_ATTR,
				      id = &filepart_id,
				      count = &count);
            if(sts & *msg & 1)
	     {
		for(i=0; i < count; i++)
		 {
		     sts = asm$get_attribute(msg = msg,
					     id = &filepart_id,
					     index = i,
                                             attribute = &attr);
                     if(sts & *msg & 1)
		      {
			 for(j=0; j < *numattrs; j++)
			  {
			     if((attrs[j].info.type == attr.info.type) &&
				(!strcmp(attrs[j].info.name, attr.info.name)))
                              {
				 attr_exist = TRUE;
				 break;
			      }
			  }

		      }
                     if(!attr_exist)
		      {
		         sts = asm$rem_attribute(msg  = msg,
					         index = i,
					         id = &filepart_id);
                     
			 attr_exist = FALSE;
		      }
                 }
            
	        for(i=0; i < *numattrs; i++)
	         {
		     for(j=0; j < count; j++)
		      {
		         sts = asm$get_attribute(msg = msg,
					         id = &filepart_id,
					         index = j,
                                                 attribute = &attr);
                         if(sts & *msg & 1)
			   if((attrs[i].info.type == attr.info.type) &&
			      (!strcmp(attrs[i].info.name, attr.info.name)))
                            {
			      attr_exist = TRUE;
			      break;
			    }
		      }

                     if(attr_exist)
		      {
			 sts = asm$mod_attribute(msg = msg,
						 id = &filepart_id,
						 name = attrs[i].info.name,
						 attribute = &attrs[i]);
                         attr_exist = FALSE;
		      }
                     else
		      {
	                 sts = asm$add_attribute(msg = msg,
		  		                 id = &filepart_id,
				                 attribute = &attrs[i]);
		      }
	         }
             }

            EMdesc_set_system_mode(FALSE);
	 }


    	params[0].var			= GRAGAD_INST_STRUCT;
    	params[0].var_ptr		= (IGRchar *) &gragad_inst;
    	params[0].num_bytes		= sizeof(struct gragad_inst);
    	params[0].bytes_returned	= &bytes_ret;

    	params[1].var			= GRAGAD_NAME;
    	params[1].var_ptr		= (IGRchar *) gragad_name;
    	params[1].num_bytes		= 120;
    	params[1].bytes_returned	= &bytes_ret;

    	params[2].var			= END_PARAM;
    	params[2].var_ptr		= NULL;
    	params[2].num_bytes		= 0;
    	params[2].bytes_returned	= NULL;



        sts = dp$inq_set_gragad(msg = msg,
				inq0_set1 = 0,
				osnum = view_id->osnum,
				gragad_objid = view_id->objid,
				which_error = &which_error,
				var_list = params);
        if(sts & *msg & 1)
         {
	     count = 0;
	     params[1].var = END_PARAM;

	     sts = dp$get_gragad_id(msg = msg,
	         		    mod_GRid = &new_env.md_id,
				    name = gragad_name,
				    array_size = 1,
				    total_num = &i,
				    numberofids = &count,
				    found_GRids = &ref_view);
             if(!count)
	      {
		/* construct the saved view in the reference file.*/

		sts = DPsavevw_cons(msg,
				    &new_env.md_id.osnum,
				    gragad_name,
				    NULL,
				    GGI_STRUCT,
				    (IGRchar *)&gragad_inst,
				    NULL,
				    NULL);
                if(sts & *msg & 1)
		 {
		    sts = dp$get_saved_vw_id(msg = msg,
					     osnum = new_env.md_id.osnum,
					     name = gragad_name,
					     array_size = 1,
					     total_num  = &i,
					     numberofids = &count,
					     found_GRids = &ref_view);
		 }

	      }
             else
	      {
    	         params[1].var			= END_PARAM;
    	         params[1].var_ptr		= NULL;
    	         params[1].num_bytes		= 0;
    	         params[1].bytes_returned	= NULL;

                 sts = dp$inq_set_gragad(msg = msg,
				         inq0_set1 = 1,
				         osnum = ref_view.osnum,
				         gragad_objid = ref_view.objid,
				         which_error = &which_error,
				         var_list = params);
	      }


	 }

        sts = ex$close_module(ftype = EX_invisible, 
			     flag = 1, 
			     index = file_no);
        if(!(1&sts))
	 {
	   trace(printf("save module failed\n"));
	   goto quit;
         }

        if(place_part)
	 {
	    origin[0] = gragad_inst.gragad.origin[0];
	    origin[1] = gragad_inst.gragad.origin[1];
	    origin[2] = gragad_inst.gragad.origin[2];
	    props = EM_REFERENCE_PART | EM_IN_BOM | EM_DEFAULT_DISPLAY;
	    props = props & ~EM_HANDLE_DISPLAYED;

	    if(ref_view.objid == NULL_OBJID)
	      gragad_name[0] = NULL;

	    sts = asm$create_instance(msg = msg,
				      filename = filename,
				      type = props & EM_PART_TYPES,
				      display = props & EM_DISPLAY_PROPS,
				      window_id = view_id,
				      origin = origin,
				      view = gragad_name,
				      instance_id = &inst_id);
            if(!(sts & *msg & 1))
	     {
	       trace(printf("place part failed\n"));
	       goto quit;
             }
	 }
quit:
    
   if(obj_list)
     free(obj_list);
   return(sts);       

}


end implementation EMlocalpart;
