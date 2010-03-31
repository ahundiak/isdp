/*
 * This file provides a non_count_based key support  for feature
 *
 * History:
 * gvk/rust : ??????? : Creation
 */

class implementation EMSslfeature;

#include "msdef.h"
#include "msmacros.h"
#include "emsclasses.h"
#include "asbox.h"
#include "EMSkey.h"
#include "grdpbdef.h"
#include "grdpbmacros.h"
#include "REpointer.h"
#include "REcurve.h"
#include "DIdef.h"
#include "DItypedef.h"
#include "DIprims.h"

/*  Implementation of these messages for this class and EMSsfsolid are
    same except that the indices of which key needs to be changed.
    Need to update soon.
 */
from EMSpointer import EMget_pointer_info, EMput_pointer_info;

method EMgive_noncount_based_key(long *EMmsg;
				 int options;
				 OM_S_OBJID *component;
				 int *type;
				 int *out_key_size;
				 char **out_key)
{
  IGRint status;
  struct GRmd_env mod_env;
  IGRint sizbuf, nret,info_type;
  struct GRid my_grid,curve_id;
  IGRint key_size,key_count,chan_index,size;
  struct EMSkey *key;
  IGRdouble matrix[16];
  IGRshort matrix_type;
  IGRuint tag_id;
  OMuint count;
  char *info = NULL;
  char outname[DI_PATH_MAX];

  sizbuf = sizeof(struct GRmd_env);
  gr$get_module_env ( msg = EMmsg,
		     sizbuf = &sizbuf,
		     buffer = &mod_env,
		     nret = &nret );
  if (!(1 & *EMmsg)) goto wrapup;

  my_grid.objid = my_id;
  my_grid.osnum = OM_Gw_current_OS;

  status = EFtranslate_id_key(EMmsg,
			      EMS_OPT_KEY_FROM_ID,
			      &mod_env,
			      component,
			      &my_grid,
			      &key_size,
			      NULL);
  EMerr_hndlr(!(1&status&*EMmsg), *EMmsg, EMS_E_Fail, wrapup);

  key_count = key_size/sizeof(struct EMSkey);
  if( key_count < 3)
    {
      /* component surface is  one of the cap surfaces  , no additional info */
      *EMmsg = FALSE;
      goto wrapup;
    }
  key = (struct EMSkey *) stackalloc(key_size);

  status = EFtranslate_id_key(EMmsg,
			      EMS_OPT_KEY_FROM_ID,
			      &mod_env,
			      component,
			      &my_grid,
			      &key_size,
			      &key);
  
  if( key[2].sub_item_type != EMSkey_CONNECTOR)
    {
      /* Key generated is for edges of cap surfaces, Control should 
         never come here */
      *EMmsg = FALSE;
      goto wrapup;
    }
  chan_index = key[2].chan_index;

  /* We are implementing non count key for the surface */

  status = om$get_objid_at_index(object = me,
				 p_chanselect = &ND_father,
				 index = 0,
				 objidaddr = &curve_id.objid,
				 osnumaddr = &curve_id.osnum);
  EMerr_hndlr(!(1&status&*EMmsg), *EMmsg, EMS_E_Fail, wrapup);


  status = 
  om$send (msg = message NDnode.ASreturn_go(&curve_id,
			         &matrix_type,
                                 matrix),
	   targetid = curve_id.objid,
	   targetos = curve_id.osnum);
  EMerr_hndlr(!(1&status), *EMmsg, EMS_E_Fail,wrapup);

  status = om$get_channel_count( objid = curve_id.objid,
				osnum = curve_id.osnum,
				p_chanselect = &AS_to_comp,
				count = (OMuint *) &count);
  if (!(status & 1) || !count)
    {
      *EMmsg = FALSE;
      goto wrapup;
    }

  if( count ! = key[2].chan_count)
    {
      *EMmsg = FALSE;
      goto wrapup;
    }
      

  status = EMget_component_name_tag(EMmsg, &curve_id, chan_index,
				    &info_type, outname, &tag_id);
  if(!(status &1) || info_type == EMS_SEGMT_NONE)
    {
      *EMmsg = FALSE;
      goto wrapup;
    }

  if(info_type == EMS_SEGMT_NAME)
    {
      info = outname;
      size = strlen(outname)+1;
    }
  else if(info_type == EMS_SEGMT_TAG)
    {
      info  = (char *)&tag_id;
      size = sizeof(IGRulong);
    }

  if(options & EMS_CREATE_MSCS)
    *type = EMSmsc_noncount_key;
  else
    *type = EMS_ASnoncount_key;

  if(out_key)
    {
      EFput_noncount_info(out_key,out_key_size,*component,info, 
			  &size, info_type, 1);
    }
  else
    *out_key_size = sizeof(struct EMSnoncountkey) + size;
 wrapup:
  return(OM_S_SUCCESS);

}

method EMgive_count_based_key(long *EMmsg;
			      int options;
			      struct GRid *pointer_id;
			      int *key_size;
			      char *key)
{
  /* if the  size of the given count based key is sufficient then
     the same key will be updated and sent, else  newsize would be
     sent out
  */

  IGRint status;
  IGRuint info_size,type;
  char *info_key;
  struct EMSkey *o_key;
  char *info = NULL,*inname=NULL;
  struct GRid curve_id;
  struct GRid rib_id,compsurf_id;
  IGRulong tag_id;
  IGRint key_count,chan_index,chan_count;
  IGRdouble matrix[16];
  IGRshort matrix_type;
  IGRint info_type,noncount_size;
  OM_S_CHANSELECT   to_components;
  IGRint  numsf=0,ii;
  union EMSssi_table *org_ssi = NULL;

  o_key = (struct EMSkey *) key;

  if(options & EMS_CREATE_MSCS)
    {
      status = om$send (msg = message EMSassoc.EMget_info(EMmsg,
                         NULL, &type, &info_size, NULL),
		    targetid = pointer_id->objid,
		    targetos = pointer_id->osnum);
      EMerr_hndlr (!(1&status&*EMmsg), *EMmsg, EMS_E_Fail, wrapup);

      if( type != EMSmsc_noncount_key && type != EMSmsc_long_key )
	{
	  *EMmsg = FALSE;
	  goto wrapup;
	}
 
      info = stackalloc(info_size);
      status = om$send (msg = message EMSassoc.EMget_info(EMmsg,
                         NULL, &type, &info_size, &info),
			targetid = pointer_id->objid,
			targetos = pointer_id->osnum);
      EMerr_hndlr (!(1&status&*EMmsg), *EMmsg, EMS_E_Fail, wrapup);

      EMget_msc_noncount_key_from_info(type,info_size,info,&info_type,
				   &info_key,&noncount_size);
    }
  else
    {
      status = om$send (msg = message EMSpointer.EMget_pointer_info(EMmsg,
                         NULL, &type, &info_size, NULL),
		    targetid = pointer_id->objid,
		    targetos = pointer_id->osnum);
      EMerr_hndlr (!(1&status&*EMmsg), *EMmsg, EMS_E_Fail, wrapup);

      if( type != EMS_ASnoncount_key && type != EMS_ASlong_key )
	{
	  *EMmsg = FALSE;
	  goto wrapup;
	}
 
      info = stackalloc(info_size);
      status = om$send (msg = message EMSpointer.EMget_pointer_info(EMmsg,
                         NULL, &type, &info_size, &info),
			targetid = pointer_id->objid,
			targetos = pointer_id->osnum);
      EMerr_hndlr (!(1&status&*EMmsg), *EMmsg, EMS_E_Fail, wrapup);

      EMget_noncount_key_from_info(type,info_size,info,&info_type,
				   &info_key,&noncount_size);
    }
  key_count = (*key_size)/sizeof(struct EMSkey);

  if(key_count < 3 || (o_key[2].sub_item_type != EMSkey_CONNECTOR)  )
    {
      /* No refinements */
	*EMmsg = FALSE;
	goto wrapup;
    }
	
  if( info_type == EMS_SEGMT_TAG)
    {
      memcpy(&tag_id, info_key, noncount_size);
    }
  else
    {
      inname = (char *)info_key;
    }
  /* We are implementing non count key for the surface */

  chan_index = o_key[2].chan_index;
  status = om$get_objid_at_index(object = me,
				 p_chanselect = &ND_father,
				 index = 0,
				 objidaddr = &curve_id.objid,
				 osnumaddr = &curve_id.osnum);
  EMerr_hndlr(!(1&status&*EMmsg), *EMmsg, EMS_E_Fail, wrapup);

  status = 
  om$send (msg = message NDnode.ASreturn_go(&curve_id,
			         &matrix_type,
                                 matrix),
	   targetid = curve_id.objid,
	   targetos = curve_id.osnum);
  EMerr_hndlr(!(1&status), *EMmsg, EMS_E_Fail,wrapup);

  status = 
  EFtranslate_tag_to_key(EMmsg, &curve_id, &chan_index, &chan_count, tag_id, 
			 inname,info_type);
  if(!(status &1)) goto wrapup;

  /*
   * if chan count is differs from input, checkout SSI for actuals
   */
  if ( o_key[2].chan_count != chan_count )
  {
    EMmake_chanselect(GRcmpowner_to_components, &to_components);

    status = om$get_objid_at_index(object = me,
                                 p_chanselect = &to_components,
                                 index = o_key[0].chan_index,
                                 objidaddr = &rib_id.objid,
                                 osnumaddr = &rib_id.osnum);
    EMerr_hndlr(!(1&status), *EMmsg, EMS_E_Fail, wrapup);

    status = om$get_objid_at_index(objid = rib_id.objid,
                                 p_chanselect = &to_components,
                                 index = o_key[1].chan_index,
                                 objidaddr = &compsurf_id.objid,
                                 osnumaddr = &compsurf_id.osnum);
    EMerr_hndlr(!(1&status), *EMmsg, EMS_E_Fail, wrapup);

    /* get save state information */
    status = om$send(msg = message EMSdpr.EMgetSSI(EMmsg, &org_ssi),
                                senderid = NULL_OBJID,
                                targetid = my_id );
    EMerr_hndlr(! (1 & status & *EMmsg), *EMmsg, EMS_E_Fail, wrapup);

    for ( ii=0; ii < org_ssi->bool_info.num_composites; ii++)
    {
       numsf = org_ssi->bool_info.num_surfaces_out[ii];
       if ( org_ssi->bool_info.composite_ids[ii] == compsurf_id.objid )
         break;
    }

    if ( o_key[2].chan_count != (chan_count - numsf) )
    {
      o_key[2].chan_index = chan_index;
      o_key[2].chan_count = chan_count - numsf;
    }
  }

 wrapup:
  return(status);
}
end implementation EMSslfeature;
