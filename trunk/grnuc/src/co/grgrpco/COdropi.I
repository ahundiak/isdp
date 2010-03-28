/*
Name
   COdrop

Description
   This method implements the drop command.

Notes                
   This command will drop the following groupings.
      1)    graphic groups
      2)    symbols
      3)    cells

History
   HGW  07/18/86   Creation.
   HGW  08/02/86   Changed the terminology.
   mrm  10/01/86   OM 4.0 conversion
   HGW  03/23/87   changed erase element to erase highlight plane
   HGW  03/23/87   changed locate attributes
   HGW  12/17/87   Changes for version 1.1
   HGW  07/22/88   Generalized to work for any subclass of GRowner
   dhm  07/21/93   TR 11913761 - locate group by name.
   MNT  08/04/97   CR 11893319 - locate cells by fence.
*/

class implementation COdrop;
#include <alloca.h>
#include "coimport.h"
#include "msdef.h"
#include "msmacros.h"
#include "grmessage.h"
#include "OMerrordef.h"
#include "grdpbdef.h"
#include "grdpbmacros.h"
#include "exmacros.h"
#include "grgsmacros.h"
#include "codef.h"
#include "dpmacros.h"

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "OMindex.h"
#include "OMlimits.h"
#include "OMminimum.h"
#include "OMprimitives.h"
#include "igrtypedef.h"
#include "igetypedef.h"
#include "grgsmacros.h"
#include "lcmacros.h"
#include "griomacros.h"
#include "grerr.h"
#include "OMmacros.h"
#include "grmsg.h"
#include "grownerdef.h"

#include "godef.h"

/* def for function's(Please see below this comments	)      		 */
/*   purpose	     -- to get all the ids of a given class and given OS */
/* refer $MODEL/src_path/   .. few pathway functions   */
/* ALL THE VARIABLES AND FUNCTIONS THAT STARTS WITH "GPW.." are used     */
/* TO CHANGE THE LOCATE_OWNER_PROPERTIES OF GRgrgrp class		 */
/* Here we are changing the locate props so that the old GRgrgrp class   */
/* can be locateble using fence and after the processing over we are     */
/* restoring the original properties					 */

typedef unsigned int GPWresult;
typedef unsigned long GPWobjid;
typedef unsigned short GPWosnum;
typedef unsigned short int GPWclassid;
typedef short  GPWboolean;

int Gmax_space_map_entries
(
  GPWosnum os
);

extern GPWresult GomGetObjsOfClass 
(
  GPWclassid *eligclass,
  GPWosnum os,
  int *num_objids,
  GPWobjid **objids
);

extern GPWresult GomEligObjs 
(
  int num_inobjs,
  GPWosnum os,
  GPWclassid *eligclass,
  int *num_outobjs,
  GPWobjid **outobjs
);

/*    def for additional functions end here		*/

from GRowner   import  GRdrop;
from GRowner   import  GRget_owner_properties;
from GRowner   import  GRchg_owner_properties;

extern OMuword OPP_GRsvset_class_id;
extern OMuword OPP_GRgrset_class_id;
extern OMuword OPP_GRfcset_class_id;
/* 
 *  Control looping conditions
 */

#define SUCCESS     1     /* Continue looping                     */
#define FUNC_ERROR  0     /* Error has occured cleanup            */
#define RETCONTROL  2     /* Exit command and return(OM_S_SUCCESS */

#define GPW_K_Success      0x00000001
#define MALLOC_CHUNKS  50

/****************************************************************/
/*                       E X E C U T E                          */
/****************************************************************/

method execute ( IGRint *response; IGRchar *response_data; IGRint pos )
{
OMuint 		num_chans, num_dchans, num_fchans, num_dchans0, num_dchans1;
IGRint          om_msg, wp;        /* OM return status       */
IGRint 		status, k,i,j, kk, pw, ii;
OMuword		classid ;
IGRlong 	size1;
IGRlong         ret_msg, msg;       /* Function return code   */
IGRlong         exit_code;     /* Loop control variable  */
IGRlong         size;
OM_S_OBJECT_LINKAGE *c_id =NULL, *d_id = NULL, *f_id = NULL ;
OM_S_OBJECT_LINKAGE *d_id0 = NULL, *d_id1 = NULL ;
IGRuint 	 num_cobjs, num_dobjs, num_fobjs, num_dobjs1;
IGRchar  	 gslocate_spec_prompt[52];
struct GRevent   locate_event,loc_pt;
IGRint		 st=0;
OM_S_CHANSELECT  p_ch_sel, to_f;
OM_S_CHANSELECT  to_con, to_con1;
IGRint           cont_flag = 0; 
IGRlong          om_ms;
IGRshort         prop;


GPWclassid refFileClassid;
IGRint     refCount = 0, rCount = 0;
GPWresult  result=1;
GPWobjid   *refObjs = NULL;
GPWobjid   *rObjs = NULL;
GPWosnum   osnum;
	
    msg = 1;
    osnum = me->ModuleInfo.md_id.osnum ;  
    status = om$make_chanselect( channame = "COdrop.to_cell_ch",
					p_chanselect = &p_ch_sel);   

/*   set the locate properties of all the GRgrgrp class ids		*/
	prop =  GR_LC_CMP_READ |
		GR_LC_CMP_WRITE |
		GR_LC_OWN_READ |
		GR_LC_OWN_WRITE |
		GR_LC_OWN_PRM_READ |
		GR_LC_OWN_PRM_WRITE |
		GR_LC_RIGID |
		GR_LC_NO_PRM_COMP ;
	 
	 om$get_classid ( classname = "GRgrgrp",
		           p_classid = &refFileClassid );

/*  Get all the ids with classname GRgrgrp 		*/
    
    result = GomGetObjsOfClass ( &refFileClassid,
		 		 osnum, &refCount, &refObjs);
	for( pw = 0; pw < refCount; pw++)
       	{
	/* change the properties of ids with class GRgrgrp  */
	om_ms = om$send( msg = message GRowner.GRchg_owner_properties(&msg, 2 ,
								&prop),
			targetid = refObjs[pw],
			targetos = osnum );          
	}
       
   ex$message(msgnumb = GRC_M_Drop);

   if (me->init_success)
   {
      exit_code = SUCCESS;
      me->eligible_classes.p_classes =  &me->classid;
   }
   else
   {
      ex$message(msgnumb = GR_E_ErrEncCmdTrm);
      *response = TERMINATE;
      exit_code = RETCONTROL;
   }
   strcpy(gslocate_spec_prompt,"Accept(identify element to drop)/Reject");	

 while ( exit_code== SUCCESS)
 {
      /*
       *  Call the locate filter to locate an object.
       */
      size1= sizeof(struct GRevent);	
      om_msg = gr$gslocate (msg = &ret_msg,
                  event1 = &me->locate_point,
                  event2 = &loc_pt,       
                  locate_event = &locate_event,
   		  eventsize = &size1,
                  mask1 = GRm_DATA |  GRm_SPECIFIED_OBJ |  GRm_TEXT_VALUE,
	       	  mask2 = GRm_DATA |  GRm_SPECIFIED_OBJ | GRm_TEXT_VALUE,
  		  input1_mask =  GRm_DATA |  GRm_SPECIFIED_OBJ |
				 GRm_TEXT_VALUE,
		  display_flag = ALL_WINDOWS | ELEM_HILIGHT |
                                 LC_ACCEPT_CURSOR,
 		  response = response,
 		  response_data = response_data,
                  locate_key = GR_P_IdEleDrp,
                  acc_key = GR_P_AccEleDrp,
		  input1_prompt = gslocate_spec_prompt,
                  relocate_key = GR_E_NoEleFnd,
                  attributes = &me->attr,
		  num_inputs = 1,
		  locate_state = &st,
                  stack = &me->locate_stack,
                  eligible_classes = &me->eligible_classes,
		  senderid =  my_id,
		  senderos = OM_Gw_current_OS,
                  p_chanselect = &p_ch_sel);   
      me->event_on_q = FALSE;
      if (! (om_msg & 1 ))
      {
         ex$message(msgnumb = GR_E_ErrEncCmdRst);
         continue;
      }   
      else if ((ret_msg & 1)  && ((me->locate_point.response == EX_DATA) ||
                                 (me->locate_point.response == EX_STRING)||
				 (me->locate_point.response == EX_OBJID)))
   
{ 
         /*
          *  Erase the highlight plane.
          */
        
         om_msg = dp$erase_hilite (msg = &ret_msg,
                  objid = me->ModuleInfo.md_id.objid,
                  osnum = me->ModuleInfo.md_id.osnum);

         if (COERROR (om_msg & ret_msg))
         {
            ex$message(msgnumb = GR_E_ErrEncCmdRst);
            continue;
         }
           status = om$get_channel_count( objid = my_id,
					osnum =OM_Gw_current_OS ,
					p_chanselect = &p_ch_sel,
					count = &num_chans);
	  c_id = (OM_S_OBJECT_LINKAGE *)alloca (sizeof(OM_S_OBJECT_LINKAGE) *
						num_chans);
	  status = om$get_channel_objects(objid = my_id,
					osnum =OM_Gw_current_OS ,
					p_chanselect = &p_ch_sel,
					list = c_id,
					size = num_chans,
					count = &num_cobjs);
 for(j=0; j<num_chans;j++)
 {
	  status = om$get_classid(osnum = c_id[j].osnum,
				  objid = c_id[j].S_objid,
				  p_classid = &classid);
	  status = om$make_chanselect( channame = "GRgrset.to_sets",
					p_chanselect = &to_con);
	  status = om$make_chanselect( channame = "GRfcset.clip_overlap",
					p_chanselect = &to_con1);
	num_dchans = num_dchans0 = num_dchans1 = 0;
	/* if using fence for locating	*/
       if((classid == OPP_GRgrset_class_id ) 
				|| (classid == OPP_GRfcset_class_id))
    {
        status = om$get_channel_count( objid = c_id[j].S_objid,
				       	osnum = c_id[j].osnum,
					 p_chanselect = &to_con,
					 count = &num_dchans0);
	status = om$get_channel_count( objid = c_id[j].S_objid,
					osnum = c_id[j].osnum,
					p_chanselect = &to_con1,
					count = &num_dchans1);
	d_id0 = (OM_S_OBJECT_LINKAGE *)alloca (sizeof(OM_S_OBJECT_LINKAGE) *
						num_dchans0);
	d_id1 = (OM_S_OBJECT_LINKAGE *)alloca (sizeof(OM_S_OBJECT_LINKAGE) *
						num_dchans1);
	status = om$get_channel_objects(objid = c_id[j].S_objid,
					osnum = c_id[j].osnum,
					p_chanselect = &to_con,
					list = d_id0,
					size = num_dchans0,
					count = &num_dobjs);
	status = om$get_channel_objects(objid = c_id[j].S_objid,
					osnum = c_id[j].osnum,
					p_chanselect = &to_con1,
					list = d_id1,
					size = num_dchans1,
					count = &num_dobjs1);
	d_id = (OM_S_OBJECT_LINKAGE *)alloca (sizeof(OM_S_OBJECT_LINKAGE) *
				(num_dchans = (num_dchans0 + num_dchans1)));
	for(ii=0;ii<num_dchans0;ii++)
	{
	 d_id[ii] = d_id0[ii];
	}
	for(ii=num_dchans0;ii<num_dchans;ii++)
	{
	d_id[ii] = d_id1[ii-num_dchans0];
	}


      for(i=0;i<num_dchans;i++)
      {
	status = om$get_classid(osnum = d_id[i].osnum,
				objid = d_id[i].S_objid,
				p_classid = &classid);
       if(classid == OPP_GRsvset_class_id)
       {
	status = om$make_chanselect(channame = "GRcmpowner.to_components",
					p_chanselect = &to_f);
	status = om$get_channel_count( objid = d_id[i].S_objid,
					osnum = d_id[i].osnum,
					p_chanselect = &to_f,
					count = &num_fchans);
	f_id = (OM_S_OBJECT_LINKAGE *)alloca (sizeof(OM_S_OBJECT_LINKAGE) *
				num_fchans);

	status = om$get_channel_objects(objid = d_id[i].S_objid,
					osnum = d_id[i].osnum,
					p_chanselect = &to_f,
					list = f_id,
					size = num_fchans,
					count = &num_fobjs);
         /*
          *  Drop the element.
          */
	 kk=0;
	 for( k = 0; k < num_fobjs; k++)
	 {
	 status = om$get_classid(osnum = f_id[k].osnum,
				 objid = f_id[k].S_objid,
				 p_classid = &classid);
	  if((om$is_ancestry_valid(subclassid = classid,
		superclassname = "GRowner") == OM_S_SUCCESS))
	  {
                  om_msg = om$send(
                  msg = message GRowner.GRdrop
                  (&ret_msg, &me->ModuleInfo),
		    targetid = f_id[k].S_objid,
		    targetos = f_id[k].osnum);
	
            if (COERROR(om_msg & ret_msg))
           {
            ex$message(msgnumb = GR_E_ErrEncCmdRst);
	    cont_flag = 1;
            goto NXT_CONT;
           }
	  
         /*
          *  Use the accept point to locate the next graphics
          *  object.  This is done by pushing the datapoint onto
          *  the event queue.
          */
	 kk++;
	 if( kk == 1)
	 {
         size = sizeof(struct GRevent) - (sizeof(IGRlong) * 2);
         om_msg = ex$putque ( msg = &ret_msg, response = response,
              byte = &size, buffer = (IGRchar *)&loc_pt.event);

          if (COERROR (om_msg))
          {
            ex$message(msgnumb = GR_E_ErrEncCmdRst);
	    cont_flag = 1;
            goto NXT_CONT;
          }
          else     
          {
            me->event_on_q = TRUE;
          }

     	 }   // if k== 1 
        }  //  if class id
       }  // for k++
      }  // if classid
     }  // for i++
   }
   
   /* if locate using clicking the object	*/
   else if(classid == OPP_GRsvset_class_id)
   {
        status = om$make_chanselect(channame = "GRcmpowner.to_components",
				p_chanselect = &to_f);
	status = om$get_channel_count( objid = c_id[j].S_objid,
					osnum = c_id[j].osnum,
					 p_chanselect = &to_f,
					 count = &num_fchans);
	f_id = (OM_S_OBJECT_LINKAGE *)alloca (sizeof(OM_S_OBJECT_LINKAGE) *
				num_fchans);
	status = om$get_channel_objects(objid = c_id[j].S_objid,
					osnum = c_id[j].osnum,
					p_chanselect = &to_f,
					list = f_id,
					size = num_fchans,
					count = &num_fobjs);
	for( k = 0; k < num_fobjs; k++)
	{
	status = om$get_classid(osnum = f_id[k].osnum,
				objid = f_id[k].S_objid,
				 p_classid = &classid);
	  if((om$is_ancestry_valid(subclassid = classid,
		superclassname = "GRowner") == OM_S_SUCCESS))	
	 {

	          om_msg = om$send(
			msg = message GRowner.GRdrop
			(&ret_msg, &me->ModuleInfo),
			targetid = f_id[k].S_objid,
			targetos = f_id[k].osnum);
	    if (COERROR(om_msg & ret_msg))
	    {
	    ex$message(msgnumb = GR_E_ErrEncCmdRst);
	    cont_flag = 1;
	    goto NXT_CONT;
	    }

	   size = sizeof(struct GRevent) - (sizeof(IGRlong) * 2);
	   om_msg = ex$putque ( msg = &ret_msg, response = response,
		byte = &size, buffer = (IGRchar *)&loc_pt.event);
	   if (COERROR (om_msg))
	   {
	    ex$message(msgnumb = GR_E_ErrEncCmdRst);
	    cont_flag = 1;
	    goto NXT_CONT;
	   }
	   else
	   {
	    me->event_on_q = TRUE;
	   }
	 }
	}
     }
  } 
}
      	
  else if (me->locate_point.response == EX_RESTART)
   {
         /* 
          *  Continue to identify elements to drop.
          */
   }
  else if (me->locate_point.response == GR_UNKNOWN_TYPE)
   {
         /*
          *  Unknown event, return control to super_cmd
          */

         exit_code = RETCONTROL;
   }
  if( cont_flag == 1)
  {
  cont_flag = 0;
  NXT_CONT: continue;
  } 
 }  /* end while        */

/*	Restore the locate properties of GRgrgrp 	*/
	result = GomGetObjsOfClass ( &refFileClassid,
				 osnum, &rCount, &rObjs);
	prop = GR_LC_CMP_READ ;


      if( rCount > 1)
      {
	for(wp = 0; wp < rCount ; wp++)
	{
	om_ms = om$send( msg = message GRowner.GRchg_owner_properties(&msg, 2 ,
							&prop),
			targetid = rObjs[pw],
			targetos = 2);
	}
      }
       if (refObjs) {  free(refObjs); refObjs = NULL; }
       if (rObjs) {  free(refObjs); rObjs = NULL; }
	
   return (OM_S_SUCCESS);
}   /* end execute method */

/****************************************************************/
/*                      I N I T                                 */
/****************************************************************/

method init ( int type; char *string_ptr )
{
IGRlong     om_msg;        /* OM return status              */
IGRlong     ret_msg;       /* Msg return code               */
IGRint      size;          /* size of DPB structure         */
IGRint      ret_size;      /* size of DPB structure returned*/

   me->event_on_q = FALSE;
   me->attr.properties = LC_LC_ONLY |
                         LC_WRITE_ONLY |
                         LC_DP_ONLY ;
   me->attr.owner_action = LC_FLEX_OWNER | LC_RIGID_OWNER ;

   strcpy (me->attr.classes, "GRgraphics");
   me->eligible_classes.w_count = 1;
   me->eligible_classes.w_flags = OM_CLST_subclass;
   om_msg = om$get_classid ( classname = "GRowner",
                             p_classid = &me->classid);

   size = sizeof (struct GRmd_env);
   if (gr$get_module_env (msg = &ret_msg, sizbuf = &size, 
       			  buffer = &me->ModuleInfo, nret = &ret_size))
   {
      me->init_success = TRUE;
   }
   else
   {
      me->init_success = FALSE;
   }
   return ( OM_S_SUCCESS );
}

/*    NEW functions added for locate thro fence utilities	*/

/***************************************************************/
/*		GomGetObjsOfClass			       */
/*			-Get all the obj_is's of given class   */
/***************************************************************/
GPWresult GomGetObjsOfClass
(
    GPWclassid *eligclass,
    GPWosnum os,
    int *num_objids,
    GPWobjid **objids
 )
{
    int max_s = Gmax_space_map_entries (os);
    if (objids)
    *objids = NULL;
    *num_objids = 0;
    
    
    return (GomEligObjs ( max_s, 
	               os, 
		      eligclass, 
		      num_objids, objids));
}
/*****************************************************************/
/*  GomEligObjs	-- Get all the eligible obj_ids of given class   */
/*****************************************************************/

GPWresult GomEligObjs
(
  int num_inobjs,
  GPWosnum os,
 GPWclassid *eligclass,
 int *num_outobjs,
  GPWobjid **outobjs
)
{
    GPWboolean pass_elig, outmem_input;
    int objid, inx, i;
    GPWclassid classid;
    GPWresult result = GPW_K_Success;

    *num_outobjs = 0;
    if (outobjs && *outobjs)
	outmem_input = TRUE;
    else
          outmem_input = FALSE;
    for (inx=0; inx<num_inobjs; inx++)
    {
         objid = inx;
	 om$get_classid ( osnum = os ,
			objid = objid ,
		   	p_classid = &classid );	
    pass_elig=FALSE;

    for (i=0; i<1; i++)
	{
	 if((om$is_ancestry_valid(subclassid = classid,
			 superclassid = eligclass[i] ) == OM_S_SUCCESS))
	{
	    pass_elig = TRUE;
	    break;
	    }
	 }

       if (pass_elig )
	{
	  if (outobjs)
	    {
	      if (!outmem_input)
	      { int curr_num_objs;
	      int chunk_size;
	      chunk_size = MALLOC_CHUNKS ;
		if(*num_outobjs+1)
		{
		 curr_num_objs = *num_outobjs;
		 if (! (curr_num_objs % chunk_size))
		  {
		   if (!curr_num_objs)
		   {
		   *outobjs = (void *) malloc (sizeof (GPWobjid) *
				MALLOC_CHUNKS);
		   }
		   else
		   {
		   *outobjs = (void *) realloc (*outobjs, sizeof (GPWobjid) *
				(curr_num_objs + MALLOC_CHUNKS));
		   }
		  }
		 }
                }
	      (*outobjs)[*num_outobjs] = objid;
	      }
	      (*num_outobjs)++;
	}
  }
    return (result);
}

/*********************************************************************/
/* Gmax_space_map_entries - Get the number of valid ids in given OS  */
/*********************************************************************/

int Gmax_space_map_entries
(
  GPWosnum os
)
  {
    int i, max=0;
    OM_p_OSD p_OSD;
    OM_p_SPAMAPENT p_entry;

  p_OSD = OM_GA_OSDs[os];
  if (p_OSD && p_OSD->CurSpaceMapSize)
  {
   for (i = p_OSD->CurSpaceMapSize-1, p_entry = p_OSD->Spacemap+i;
	       i >= 0;
	       i--, p_entry--)
     {
	  if (! (OM_OBJ_INVALID (p_entry->flags)))
		{
			max = i+1;
			break;
                }
     }

 }

  return (max);
}


end implementation COdrop;
