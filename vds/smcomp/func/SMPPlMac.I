/* $Id: SMPPlMac.I,v 1.1.1.1 2001/01/04 21:07:33 cvs Exp $  */
/* -------------------------------------------------------------------------
/* I/VDS
 *
 * File:	SMcomp/SMPPlMac.I
 *
 * Description:	
 *
 *      This file implement functions to help user to set attributes in an
 *	compartment, by using a ppl file.
 *	(The corresponding macros are in the file SMPPlMac.h)
 *	
 * Dependencies:
 *	Root
 *
 * Revision History:
 *	$Log: SMPPlMac.I,v $
 *	Revision 1.1.1.1  2001/01/04 21:07:33  cvs
 *	Initial import to CVS
 *	
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
# Revision 1.1  1997/05/08  13:20:44  pinnacle
# New project VDS 250
#
# Revision 1.1  1996/07/19  20:33:52  pinnacle
# Create VDS 241 project
#
# Revision 1.1  1994/11/14  22:42:32  pinnacle
# Create vds.240 from vds.232
#
# Revision 1.1  1994/11/08  16:07:00  pinnacle
# create vds.232
#
 *
 * History:
 *
 *	07/05/93  Jean Jasinczuk: Creation date.
 *
 * -------------------------------------------------------------------------
 */

class implementation Root;

#include <stdio.h>
#include <string.h>

#include "OMmacros.h"
#include "OMindex.h"
#include "madef.h"
#include "godef.h"
#include "igetypedef.h"
#include "igrtypedef.h"
#include "gr.h"
#include "igr.h"
#include "igrdp.h"
#include "go.h"
#include "msdef.h"
#Include "exdef.h"
#include "exmacros.h"
#include "nddef.h"

#include "SMdef.h"
#include "ACattrib.h"
#include "ACrg_collect.h"

#include "ms.h"
#include "msmacros.h"
#include "vdsmacros.h"

#include "SMmsg.h"

#define SM_TEXT_ATTRIB          1
#define SM_DOUBLE_ATTRIB        2

#define SM_AFT_FRAME           3
#define SM_FORE_FRAME          4

from SMmgr     import SMSetAtt,SMGetAtt,SMGetAttTxt;            
from SMfrm_syst import SMfind_frame_near_pt,SMfind_frame_objid;
from SMframe    import SMgive_rel_position;            
from GRgraphics import GRgetname,GRgetrang;            
from NDnode    import NDget_objects;
from ACdyn_col import ACset_att_prop;            


/*+fe
 * -------------------------------------------------------------------------
  Function SMGetAttribute

  Macro Name
	SM$GetAttribute

  Abstract
         Given an object and a name of an attribute, this macro gets
   the value and type of this attribute for this object


  Arguments
	IGRlong     *msg          [O] Return code OM_S_SUCCESS or OM_E_ABORT

	struct GRid *object       [I] Object to look for attribut

	IGRchar     *name_att     [I] Name of the attribut to retrieve

	IGRshort    *data_type    [O] Type of data return
                          (SM_TEXT_ATTRIB or SM_DOUBLE_ATTRIB)

	IGRchar     *text_value    [O] Data return if AC_ATTRIB_TXT

	IGRdouble   *double_val    [O] Double value return  if AC_ATTRIB_DOUBLE

  Notes/Remarks

 	if data_type of attributes is known , you can give only
  	text_value or double_value else you can give both

  Returns
      OM_S_SUCCESS if success
      OM_E_ABORT   if fails

 * -------------------------------------------------------------------------
-fe*/

SMGetAttribute(IGRlong *msg,  struct GRid *object,IGRchar *name_att,
		IGRshort *data_type,IGRchar *text_value,IGRdouble *double_val)
{
  struct    ACrg_coll att;
  IGRint    status;
  
  if(!msg || !object || !name_att) 
   {
     printf("In SMGetAtt missing some input\n");
     goto wrapup;
   }

  strcpy(att.name,name_att);
  status = om$send(msg = message SMmgr.SMGetAtt
		   (msg,1,&att,NULL),
		   senderid = NULL_OBJID,
		   targetid = object->objid,
		   targetos = object->osnum);
  if(!(status & *msg & 1))
   {ex$message(msgnumb  = SM_E_CmAttNotFound, type="%s",var=`name_att`);
    goto wrapup;
  }

  switch(att.desc.type)
   {
   case AC_ATTRIB_TEXT:
     if(data_type)
       if(*data_type != SM_TEXT_ATTRIB)
	{
	  ex$message(msgnumb = SM_E_CmBadAttType,type="%s",var=`name_att`);
	  goto wrapup;
	}
       else
	 *data_type = SM_TEXT_ATTRIB;

     if(text_value) strcpy(text_value,att.desc.value.att_txt);
     break;

   case AC_ATTRIB_DOUBLE:
     if(data_type)
       if(*data_type != SM_DOUBLE_ATTRIB)
	{
	  ex$message(msgnumb = SM_E_CmBadAttType,type="%s",var=`name_att`);
	  goto wrapup;
	}
       else
	 *data_type = SM_DOUBLE_ATTRIB;
     if(double_val) *double_val = att.desc.value.att_exp;
     break;
   }

  *msg = OM_S_SUCCESS;
  return OM_S_SUCCESS;
  
 wrapup:
  *msg = OM_E_ABORT;
  return OM_E_ABORT;
}

/*+fe
 * -------------------------------------------------------------------------
  Function SMSetAttribute

  Macro Name
	SM$SetAttribute

  Abstract
         Given an object and a name of an attribute, this macro sets
   the value and type of this attribute for this object


  Arguments
	IGRlong     *msg          [O] Return code OM_S_SUCCESS or OM_E_ABORT

	struct GRid *object       [I] Object to look for attribut

	IGRchar     *name_att     [I] Name of the attribut to set

	IGRshort    *data_type    [I] Type of data for this attribute
                          (SM_TEXT_ATTRIB or SM_DOUBLE_ATTRIB)

	IGRchar     *text_value   [I] Data to set if AC_ATTRIB_TXT

	IGRdouble   *double_val   [I] Double value to set  if AC_ATTRIB_DOUBLE


  Returns
      OM_S_SUCCESS if success
      OM_E_ABORT   if fails

 * -------------------------------------------------------------------------
-fe*/

SMSetAttribute(IGRlong *msg, struct GRid *object,IGRchar *name_att,   
		IGRshort data_type, IGRchar *text_value, IGRdouble  double_val)
{
  struct    ACrg_coll att,new_att;
  IGRint              status;
  IGRshort            type_att;
  IGRshort            int_prop,user_props;
  struct GRid         ACdyn;
  int                 nb_roots;

  if(!msg || !object || !name_att) 
   {
     printf("In SMSetAtt missing some input\n");
     goto wrapup;
   }

  switch(data_type)
   {
   case SM_DOUBLE_ATTRIB:
     new_att.desc.type = AC_ATTRIB_DOUBLE;
     new_att.desc.value.att_exp = double_val;
     break;
   case SM_TEXT_ATTRIB:
     new_att.desc.type = AC_ATTRIB_TEXT;
     if(text_value) strcpy(new_att.desc.value.att_txt,text_value);
     else           new_att.desc.value.att_txt[0] = '\0';
     break;
   default:
     new_att.desc.type = AC_ATTRIB_TEXT;
     break;
   } 

  strcpy(new_att.name,name_att);
  
  strcpy(att.name,name_att);
  status = om$send(msg = message SMmgr.SMGetAtt
		   (msg,1,&att,&type_att),
		   senderid = NULL_OBJID,
		   targetid = object->objid,
		   targetos = object->osnum);

  if(status & *msg & 1) /* Attribute already exists */
   {
     if(type_att & SM_STATIC_ATT)
      {
	ex$message(msgnumb = SM_E_CmStatAtt,type="%s",var=`name_att`);
	goto wrapup;
      }

     if(att.desc.type != new_att.desc.type)
      {
	ex$message(msgnumb = SM_E_CmBadAttType,type="%s",var=`name_att`);
	goto wrapup;
      }

     if(type_att & SM_USER_ATT) 
      {
	type_att ^=  SM_USER_ATT; /* Remove user flag */
	type_att |=  SM_OTHER_ATT;
      }
     else
       type_att |= SM_OTHER_ATT;
     
   
     
     /* Due to a bug in SMSetAtt, no possibility  to modify type of attribute */
     /* So do it now                                                          */
     int_prop   = 0;
     user_props = type_att & 0xF000;

     /* Get the ACrg of compartment */
     status = om$send(msg = message NDnode.NDget_objects
		      (ND_ROOT,&ACdyn,1,NULL, 0,0,&nb_roots),
		      senderid = NULL_OBJID,
		      targetid = object->objid,
		      targetos = object->osnum);
     if(status & 1)
      {
	status = om$send(msg = message ACdyn_col.ACset_att_prop
			 (msg, att.name, int_prop,user_props),
			 senderid = NULL_OBJID,
			 targetid = ACdyn.objid,
			 targetos = ACdyn.osnum); 
      }
     else printf("Error NDnode.NDget_objects %d,%d\n",
		 object->objid,object->osnum);
   }
  else
     type_att = SM_DYNAMIC_ATT | SM_OTHER_ATT;
     

  status = om$send(msg = message SMmgr.SMSetAtt
		   (msg,1,&new_att,&type_att),
		   senderid = NULL_OBJID,
		   targetid = object->objid,
		   targetos = object->osnum);
  if(!(status & *msg  & 1))
   {printf("Error SMmgr.SMSetAtt for object %d,%d\n",
	    object->objid,object->osnum);
     goto wrapup;
  }

  *msg = OM_S_SUCCESS;
  return OM_S_SUCCESS;
  
 wrapup:
  *msg = OM_E_ABORT;
  return OM_E_ABORT;
}

/*+fe
 * -------------------------------------------------------------------------
  Function SMAftForeFrame

  Macro Name
	SM$AftForeFrame

  Abstract
	This macro computes the fore or aft frame of the given volume. 
	If volume is just ending on frame, low and high frame number are 
	equal otherwise:

	low_frame is inside the volume for SM_FORE_FRAME, outside for 
	SM_AFT_FRAME.
	
	high_frame is outside the volume for SM_FORE_FRAME, inside for 
	SM_AFT_FRAME.


  Arguments
	IGRlong         *msg          [O] Return code OM_S_SUCCESS or OM_E_ABORT

	struct GRid     *vol_id       [I] volume to look for aft and fore frame

	struct GRmd_env *md_env       [I] env of the volume


	IGRchar         *low_fr_name  [O] Lowest frame name

	IGRdouble       *low_fr_dist  [O] Lowest frame distance 
						(in design file unit)

	IGRint          *high_fr_num  [O] Highest Frame number

	IGRchar         *high_fr_name [O] Highest frame name

	IGRdouble       *high_fr_dist [O] Highest frame distance 
						(in design file unit)

	IGRshort        which_frame   [I] SM_AFT_FRAME or SM_FORE_FRAME

  Returns
      OM_S_SUCCESS if success
      OM_E_ABORT   if fails

 * -------------------------------------------------------------------------
-fe*/

SMAftForeFrame(IGRlong *msg,struct GRid *vol_id,struct GRmd_env *md_env,   
		IGRint *low_fr_num,IGRchar *low_fr_name,IGRdouble *low_fr_dist,
		IGRint *high_fr_num,IGRchar *high_fr_name,
		IGRdouble *high_fr_dist,IGRshort which_frame )
{
  IGRboolean      world; 
  IGRdouble       range[6];
  struct GRmd_env FrmEnv;
  struct GRid     FrmId,low_fr_id,high_fr_id;
  IGRdouble       *point;
  IGRint          status;
  IGRlong         loc_msg;
  struct GRid     global;
  int             cs_side;
  char            text[80];

  IGRint *pt_low_fr_num,tmp_low_fr_num;
  IGRint *pt_high_fr_num,tmp_high_fr_num;


  pt_low_fr_num = low_fr_num ? low_fr_num : &tmp_low_fr_num;
  pt_high_fr_num = high_fr_num ? high_fr_num : &tmp_high_fr_num;
  
  status = om$send(msg = message GRgraphics.GRgetrang
		   (&loc_msg, &md_env->md_env.matrix_type, 
		    md_env->md_env.matrix, &world, range),
		   senderid = NULL_OBJID,
		   targetid = vol_id->objid,
		   targetos = vol_id->osnum);
  if(!(status & loc_msg & 1))
   {printf("Error GRgetrang object %d,%d\n",vol_id->objid,vol_id->osnum);
    goto wrapup;}
    
  /* Get the active frame system */
  if(!(SMGetActFrm(&FrmId, NULL, &FrmEnv) & 1))
   {ex$message(msgnumb = SM_W_CmNoActFrm); goto wrapup;}
 
  if(!SMGetActShipAtt(&global,NULL,NULL) || global.objid == NULL_OBJID){
    ex$message(msgnumb = SM_E_SfNoGlob);
    goto wrapup;
  }

  status = om$send(msg = message SMmgr.SMGetAttTxt
		   (msg, "SIDE", text, (IGRshort *) NULL),
		   senderid = NULL_OBJID,
		   targetid = global.objid,
		   targetos = global.osnum);
  if(!(status & *msg &1) ) cs_side = 1; /* Navy side */
  if (strcmp(text, "starboard") == 0) cs_side = 1;
  else                                cs_side = 2;
  
  /* cs_side == 1 is navy used side for cs */
 
  if((which_frame == SM_AFT_FRAME  && cs_side == 2) ||
     (which_frame == SM_FORE_FRAME && cs_side == 1))
        point = &range[0];
  else  point = &range[3];

  status = om$send(msg = message SMfrm_syst.SMfind_frame_near_pt
		   (&loc_msg,point,pt_low_fr_num,pt_high_fr_num,NULL,NULL,
		    &FrmEnv.md_env.matrix_type,FrmEnv.md_env.matrix),
		   senderid = NULL_OBJID,
		   targetid = FrmId.objid,
		   targetos = FrmId.osnum);
  if(!(status & loc_msg & 1))
   {
     ex$message(msgnumb = SM_W_CmNoAftFrm);goto wrapup;
   }

  /* Have to inverse low_fr_num and high_fr_num because return in inverse order*/
  if(cs_side == 1)
   {
     int temp;

     temp            = *pt_high_fr_num;
     *pt_high_fr_num = *pt_low_fr_num;
     *pt_low_fr_num  =  temp;
   } 

  if(low_fr_name || low_fr_dist)
   {
     status = om$send(msg = message SMfrm_syst.SMfind_frame_objid
		      (&loc_msg,*pt_low_fr_num,&low_fr_id),
		      senderid = NULL_OBJID,
		      targetid = FrmId.objid,
		      targetos = FrmId.osnum);
     if(!(status & loc_msg & 1))
      {
	printf("Can get objid of frame number %d\n",*pt_low_fr_num);
	goto wrapup;
      }
   }

  if(low_fr_name)
   {
     low_fr_name[0] = '\0';
     vd$get_name(name = low_fr_name, obj = &low_fr_id);
   }

  if(low_fr_dist)
   {
     status = om$send(msg = message SMframe.SMgive_rel_position
		      (&loc_msg,low_fr_dist),
		      senderid = NULL_OBJID,
		      targetid = low_fr_id.objid,
		      targetos = low_fr_id.osnum);
     if(!(status & loc_msg & 1))
      {
	printf("Can get distance for frame number %d\n",*pt_low_fr_num);
	goto wrapup;
      }
     SMConvDistIntExt(*low_fr_dist,low_fr_dist,low_fr_id.osnum);
   }
     
  if(high_fr_name || high_fr_dist)
   {
     status = om$send(msg = message SMfrm_syst.SMfind_frame_objid
		      (&loc_msg,*pt_high_fr_num,&high_fr_id),
		      senderid = NULL_OBJID,
		      targetid = FrmId.objid,
		      targetos = FrmId.osnum);
     if(!(status & loc_msg & 1))
      {
	printf("Can get objid of frame number %d\n",*pt_high_fr_num);
	goto wrapup;
      }
	
   }

  if(high_fr_name)
   {
     high_fr_name[0] = '\0';
     vd$get_name(name = high_fr_name, obj = &high_fr_id);
   }    

   if(high_fr_dist)
   {
     status = om$send(msg = message SMframe.SMgive_rel_position
		      (&loc_msg,high_fr_dist),
		      senderid = NULL_OBJID,
		      targetid = high_fr_id.objid,
		      targetos = high_fr_id.osnum);
     if(!(status & loc_msg & 1))
      {
	printf("Can get distance of frame %d\n",*pt_high_fr_num);
	goto wrapup;
      }
     SMConvDistIntExt(*high_fr_dist,high_fr_dist,high_fr_id.osnum);
   }


  *msg = OM_S_SUCCESS;
  return OM_S_SUCCESS;
 
 wrapup:
  *msg = OM_E_ABORT;
  return OM_E_ABORT;

}
/*+fe
 * -------------------------------------------------------------------------
  Function SMCompCmpSide

  Macro Name
	SM$CompCmpSide

  Abstract
	This macro computes on which side of the center line the compartment 
	is located.

		1 = starboard
		2 = portside
		0 = centerline

  Arguments
	IGRlong         *msg          [O] Return code OM_S_SUCCESS or OM_E_ABORT

	struct GRid     *vol_id       [I] volume to look for compartment side

	struct GRmd_env *md_env       [I] env of the volume

	IGRint          *side	      [O] side of the compartment.

  Returns
      OM_S_SUCCESS if success
      OM_E_ABORT   if fails

 * -------------------------------------------------------------------------
-fe*/

SMCompCmpSide(IGRlong *msg,struct GRid *vol_id,struct GRmd_env *md_env,   
	      IGRint *side )
{
  IGRlong status;

  status = SMGetCmptSide(vol_id,md_env,side);
  if (!(status & 1)) 
   {
     ex$message(msgnumb = SM_W_CmNoSide); 
     *msg = OM_E_ABORT;
     return OM_E_ABORT; 
   }
  *msg = OM_S_SUCCESS;
  return OM_S_SUCCESS;
}   


end implementation Root;






