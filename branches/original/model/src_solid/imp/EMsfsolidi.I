class implementation EMSsfsolid;

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

from EMSpointer import EMget_pointer_info, EMput_pointer_info;
extern GRclassid OPP_GRcompcurve_class_id;
extern unsigned char EMS_locate_features;
method GRgetobjinfo (IGRlong *msg; struct GRobj_info *info)
{
 IGRlong     status;

 *msg = MSSUCC;       


 if (EMS_locate_features)
 {
   OM_S_CHANSELECT to_owners;   

   EMmake_chanselect(GRconnector_to_owners, &to_owners);
   status = om$send(msg = OPPmargs,
                    p_chanselect = &to_owners, from = 0, to = 0);
 }
 else
 {
   struct GRobj_info  temp_info;
   OM_S_CHANSELECT    to_components;


   to_components.type = OM_e_addr;
   to_components.u_sel.addr = &me^^GRcmpowner.to_components;
   
   status = om$send (msg = message GRgraphics.GRgetobjinfo (msg, &temp_info),
                     p_chanselect = &to_components,
                     from = 0,
                     to = 0);
  
   if (!(1&status&*msg)) goto wrapup;
  
   if (ME.GRgraphics->properties & GRIS_ASSOCIATIVE)
    ex$message(msgnumb = EC_I_EMSsfsolid2, buff = info->type)
   else
    ex$message(msgnumb = EC_I_EMSsfsolid1, buff = info->type)
  
   strcat(info->type, " ");
   strcat(info->type, temp_info.type);
 }

wrapup:

 return(status);
}

method EMgive_noncount_based_key(long *EMmsg;
				 int options;
				 OM_S_OBJID *component;
				 int *type;
				 int *out_key_size;
				 char **out_key)
{
/*
  This message will return extra information on dependancy of 
  created surface on the parent profile.
  options : Currently not supported.
  component: surface id
  type : key type created ( ASnoncount_key if some extra information available)
  out_key_size: Size of the special key.
  out_key: if NULL no key is returned , if *out_key is null memory
           is allocated internally. Caller is responsible for returning.

Upon exit:
          OM_S_SUCCESS:if surface ->profile info exists.
	  FALSE: if no extra information or failure

History:
Creation: GVK: 07/15/93
          GVK: 10/27/93  out_key_size argument is initialized correctly.
*/
  IGRint status;
  struct GRmd_env mod_env;
  IGRint sizbuf, nret,info_type;
  struct GRid my_grid,curve_id;
  IGRint key_size,key_count,chan_index,size;
  struct EMSkey *key;
  IGRdouble matrix[16];
  IGRshort matrix_type;
  IGRuint tag_id;
  char *info;
  char outname[DI_PATH_MAX];
  IGRboolean active_state;

  sizbuf = sizeof(struct GRmd_env);
  gr$get_module_env ( msg = EMmsg,
		     sizbuf = &sizbuf,
		     buffer = &mod_env,
		     nret = &nret );
  if (!(1 & *EMmsg)) goto wrapup;

  my_grid.objid = my_id;
  my_grid.osnum = OM_Gw_current_OS;

  status = om$send(msg = message EMSsurface.EMisactive(EMmsg, &active_state,
                        NULL), 
                  targetid = my_id);
  if (!(1&*EMmsg&status)) goto wrapup;

  if(!active_state)
    {
      /* Not active in DPR, so some of the surfaces may have been deleted */
      *EMmsg = FALSE;
      goto wrapup;
    }
  status = EFtranslate_id_key(EMmsg,
			      EMS_OPT_KEY_FROM_ID,
			      &mod_env,
			      component,
			      &my_grid,
			      &key_size,
			      NULL);
  EMerr_hndlr(!(1&status&*EMmsg), *EMmsg, EMS_E_Fail, wrapup);

  key_count = key_size/sizeof(struct EMSkey);
  if( key_count < 2)
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
  
  if( key[0].chan_index != 0)
    {
	/* Key created is for edges of cap surfaces */
      *EMmsg = FALSE;
      goto wrapup;
    }
  chan_index = key[1].chan_index;

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

  status = EMget_component_name_tag(EMmsg, &curve_id, chan_index,
				    &info_type, outname, &tag_id);
  if(!(status &1))
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
     For creator type of EMSsfsolid and EMSslot key size need not
     change
  */

  IGRint status;
  IGRuint info_size,type;
  char *info_key;
  struct EMSkey *o_key;
  char *info = NULL ,*inname = NULL;
  struct GRid curve_id;
  IGRulong tag_id;
  IGRint key_count,chan_index,chan_count;
  IGRdouble matrix[16];
  IGRshort matrix_type;
  IGRint info_type,noncount_size ;

  o_key = (struct EMSkey *) key;
/*
 * Only invoke the special machinery if the associated surface is not
 * a cap.
 * PP 10/18/93
 */

  *EMmsg = EMS_S_Success;

  status = om$send (msg = message EMSassoc.EMget_info(EMmsg,
                        NULL, &type, &info_size, NULL),
                        targetid = my_id,
                        targetos = OM_Gw_current_OS);
 
if(type == 1 || type == 2 || type == 24 || type == 25 ||
  type == 53)
  {
  if (o_key[0].chan_index != 0)
   return (OM_S_SUCCESS);
  }
  else
  {
   *EMmsg = FALSE;
   return (OM_S_SUCCESS);
  }


/* end pp */
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

      status =
      EMget_msc_noncount_key_from_info(type,info_size,info,&info_type,
				   &info_key,&noncount_size);
      if(!(status &1)) goto wrapup;
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

      status =
      EMget_noncount_key_from_info(type,info_size,info,&info_type,
				   &info_key,&noncount_size);
      if(!(status &1)) goto wrapup;
    }


  key_count = (*key_size)/sizeof(struct EMSkey);

  if(key_count < 2) 
    {
	*EMmsg = FALSE;
	goto wrapup;
    }
	
  if( info_type == EMS_SEGMT_TAG)
    {
      memcpy(&tag_id, info_key, sizeof(IGRulong));
    }
  else
    {
      inname = (char *)info_key;
    }
  /* We are implementing non count key for the surface */

  chan_index = o_key[1].chan_index;
  chan_count = o_key[1].chan_count;

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
   if((status &1) && (o_key[1].chan_count != chan_count))
    {
      o_key[1].chan_index = chan_index;
      o_key[1].chan_count = chan_count;
    }
#ifdef DEBUG
  else printf(" tag cannot be translated to key \n");
#endif
 wrapup:
  return(status);
}

EMget_component_name_tag(EMmsg, curve_id, chan_index, info_type, outname, tag_id)
     IGRlong *EMmsg;
     struct GRid *curve_id; 
     OM_S_OBJID *tag_id;
     unsigned char *outname; /* DI_PATH_MAX size array */ 
     IGRint chan_index, *info_type;
{

  IGRint status;
  OM_S_OBJECT_LINKAGE *list;
  int count;
  char name[DI_PATH_MAX], *sname=NULL;

  *EMmsg = TRUE;

  if (!EFisAncestryValid(EMmsg,curve_id->objid,curve_id->osnum,
			 OPP_GRcompcurve_class_id,FALSE))
    {
      /* Not a composite curve  */
      status = FALSE;
      goto wrapup;	
    }

  status = om$get_channel_count( objid = curve_id->objid,
				osnum = curve_id->osnum,
				p_chanselect = &AS_to_comp,
				count = (OMuint *) &count);
  if (!(status & 1) || !count)
    goto wrapup;


  list = (OM_S_OBJECT_LINKAGE *) 
    stackalloc(count *sizeof(OM_S_OBJECT_LINKAGE));
  
  status =
  om$get_channel_objects( objid = curve_id->objid,
			 osnum = curve_id->osnum,
			 p_chanselect = &AS_to_comp,
			 list = list,
			 size = count,
			 count = (OMuint *) &count);
  if (!(status & 1))
    {
      stackfree(listp);
      goto wrapup;
    }

  /* First check for the name of the object */
		
  status = di$untranslate( objname = name,
			  objid = list[chan_index].S_objid,
			  osnum = list[chan_index].osnum);
  if (status == DIR_S_SUCCESS)
    {
      
      sname = &name[strlen(name)-1];
      while ((sname != name) && (*sname != ':'))
	sname--;
      sname++;
      *info_type = EMS_SEGMT_NAME;
      strcpy(outname,sname);
      outname[strlen(outname)] = '\0';
    }
  else
    {
      status =
      om$objid_to_tag(osnum = list[chan_index].osnum,
		      objid = list[chan_index].S_objid,
		      p_tag = (OMuint *)tag_id);

      if(! (status &1))	goto wrapup;
      *info_type = EMS_SEGMT_TAG;
    }
 wrapup:
  if(!(status & *EMmsg & 1))
    {
      *info_type = EMS_SEGMT_NONE;
    }
  return(status);
}

EFtranslate_tag_to_key(EMmsg, curve_id,chan_index, chan_count,
		       tag,inname, info_type)
IGRlong *EMmsg;
struct GRid *curve_id;
IGRuint tag;
int *chan_index ,*chan_count, info_type;
char *inname;
{
  IGRint status;
  IGRint count,i;
  OM_S_OBJECT_LINKAGE *list;
  IGRuint loc_tag;
  char elname[DI_PATH_MAX],*sname;
  
  *EMmsg = TRUE;

  if (!EFisAncestryValid(EMmsg,curve_id->objid,curve_id->osnum,
			 OPP_GRcompcurve_class_id,FALSE))
    {
      status = *EMmsg = FALSE;
      goto wrapup;	
    }

  status = om$get_channel_count(objid = curve_id->objid,
				osnum = curve_id->osnum,
				p_chanselect = &AS_to_comp,
				count = (OMuint *) &count);
  if (!(status & 1) || !count)
    {
      *EMmsg = FALSE;
      goto wrapup;
    }

  list = (OM_S_OBJECT_LINKAGE *) stackalloc(
	    count *sizeof(OM_S_OBJECT_LINKAGE));

  status =
  om$get_channel_objects(objid = curve_id->objid,
			 osnum = curve_id->osnum,
			 p_chanselect = &AS_to_comp,
			 list = list,
			 size = count,
			 count = (OMuint *) &count);
  
  if (!(status & 1))
    {
      if (list) stackfree(list);
      goto wrapup;
    }
  if(info_type == EMS_SEGMT_NAME)
    {
      status = di$untranslate(objname = elname,
			      objid = list[*chan_index].S_objid,
			      osnum = list[*chan_index].osnum);
      if (status == DIR_S_SUCCESS)
	{
	  sname = &elname[strlen(elname)-1];
	  while ((sname != elname) && (*sname != ':'))
	    sname--;
	  sname++;
	}
      else sname = NULL;

      if(!sname || strcmp(sname,inname))
	{
	  /* Names did not match, Need to check other segments*/ 
	  for( i = 0; i < count; i++)
	    {
	      status = 
	      di$untranslate(objname = elname,
			     objid = list[i].S_objid,
			     osnum = list[i].osnum);
	      if(status != DIR_S_SUCCESS)
		continue;
	      sname = &elname[strlen(elname)-1];
	      while ((sname != elname) && (*sname != ':'))
		sname--;
	      sname++;
	      if(strcmp(sname,inname))
		continue;
	      else break;
	    }
	  if ( i == count)
	    {
	      /* Nomatch*/
	      *EMmsg = FALSE;
	      goto wrapup;
	    }	
	  else
	    {
	      *chan_index = i;
	      *chan_count = count;
	    }
	}
      else
	{
	  /* channel index is correct , update channel count */
	  *chan_count = count;
	}
    }
  else
    {
      status =
      om$objid_to_tag(osnum = list[*chan_index].osnum,
		      objid = list[*chan_index].S_objid,
		      p_tag = &loc_tag);
      if(!(status & 1)) goto wrapup;
      if(tag != loc_tag)
	{
	  for( i = 0; i < count; i++)
	    {
	      status =
	      om$objid_to_tag(osnum = list[i].osnum,
			      objid = list[i].S_objid,
			      p_tag = &loc_tag);
	      if(loc_tag == tag)	
		break;
	    }
	  if (i == count)
	    {
	      /* No match , tag is useless */
	      *EMmsg = FALSE;
	    }
	  else
	    {
	      *chan_index = i;
	      *chan_count = count;
	    }
	}
      else *chan_count = count;
    }
 wrapup:
  if(!(status & *EMmsg & 1))
    return(FALSE); 
  else return(TRUE);
}

end implementation EMSsfsolid;

