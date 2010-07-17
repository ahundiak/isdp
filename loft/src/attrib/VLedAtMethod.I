class implementation VLplEdAtCmd;

#include "OMminimum.h"
#include "OMprimitives.h"
#include "OMerrordef.h"
#include <stdio.h>
#include "FI.h"
#include "EMSstruct.h"
#include "bserr.h"
#include "msdef.h"
#include "grdpbdef.h"
#include "grdpb.h"
#include "grdpbmacros.h"
#include "AS_status.h"
#include "exmacros.h"
#include "grmacros.h"
#include "dpmacros.h"
#include "growner.h"
#include "nddef.h"
#include "macro.h"
#include "asmacros.h"
#include "asbox.h"
#include "graph.h"
#include "ndmacros.h"
#include "vsplatedef.h"
#include "vsbmaxisdef.h"
#include "expmacros.h"
#include "expression.h"
#include "vsgeommacros.h"
#include "vsmiscmacros.h"
#include "EMSssprops.h"
#include "vlstructure.h"
#include "vlmark.h"
#include "vlmsg.h"
#include "vluserkey.h"
#include "ACrg_collect.h"
#include "ACattrib.h"
#include "vledgeattr.h"
#include "vldbgmacros.h"

/*c  External Methods ****/

from  NDmacro		import	ACreturn_foot;
from  NDnode		import	ASreturn_go,
				NDget_objects;
from  ci_macro 		import  init;
from  NDnode 		import	NDchg_state;
from  GRgraphics 	import	GRchgprops;
from  VLmrkLine		import	WhichSide;
from  NDnode		import	NDchange_connect;
from  GRgraphics	import	GRdisplay;
from ACrg_collect import AClist_attribute;
from ACrg_collect import ACadd_list_attribute;
from  ACcpx             import  find_macro;
from  ACcpx_defn        import  ACgive_name;

/*c	Extern variables ***/

/*c	threexternal vars.. ***/
extern GRclassid	OPP_nci_macro_class_id,
                        OPP_VSplate_class_id,
                        OPP_VLmrkLine_class_id,
                        OPP_ACrg_collect_class_id,
                        OPP_ACpretend_class_id;

extern OM_S_CHANSELECT	AS_to_comp;

#define MY_ERROR    530
#define LOCATE_EDGE 531


/*-----       functions ------*/

long VLfillACrg(ACrg,list_att,list_att_txt)
struct ACrg_coll        *ACrg;
double 			*list_att;
char  			**list_att_txt;
{
        strcpy(ACrg[ATT_IDX_L].name,ATT_L);
        ACrg[ATT_IDX_L].desc.type = AC_ATTRIB_DOUBLE;
        ACrg[ATT_IDX_L].desc.value.att_exp = list_att[ATT_IDX_L];

        strcpy(ACrg[ATT_IDX_S].name,ATT_S);
        ACrg[ATT_IDX_S].desc.type = AC_ATTRIB_DOUBLE;
        ACrg[ATT_IDX_S].desc.value.att_exp = list_att[ATT_IDX_S];

        strcpy(ACrg[ATT_IDX_A].name,ATT_A);
        ACrg[ATT_IDX_A].desc.type = AC_ATTRIB_DOUBLE;
        ACrg[ATT_IDX_A].desc.value.att_exp = list_att[ATT_IDX_A];

        strcpy(ACrg[ATT_IDX_TYPE_ANGLE].name,ATT_TYPE_ANGLE);
        ACrg[ATT_IDX_TYPE_ANGLE].desc.type = AC_ATTRIB_TEXT;
        strcpy(ACrg[ATT_IDX_TYPE_ANGLE].desc.value.att_txt,
                                   list_att_txt[ATT_IDX_TYPE_ANGLE]);

        strcpy(ACrg[ATT_IDX_TYPE_CHAMF].name,ATT_TYPE_CHAMF);
        ACrg[ATT_IDX_TYPE_CHAMF].desc.type = AC_ATTRIB_DOUBLE;
        ACrg[ATT_IDX_TYPE_CHAMF].desc.value.att_exp = 
                                            list_att[ATT_IDX_TYPE_CHAMF];
       
        strcpy(ACrg[ATT_IDX_B].name,ATT_B);
        ACrg[ATT_IDX_B].desc.type = AC_ATTRIB_DOUBLE;
        ACrg[ATT_IDX_B].desc.value.att_exp = list_att[ATT_IDX_B];
      
        strcpy(ACrg[ATT_IDX_V].name,ATT_V);
        ACrg[ATT_IDX_V].desc.type = AC_ATTRIB_DOUBLE;
        ACrg[ATT_IDX_V].desc.value.att_exp = list_att[ATT_IDX_V];
     
        strcpy(ACrg[ATT_IDX_Y].name,ATT_Y);
        ACrg[ATT_IDX_Y].desc.type = AC_ATTRIB_DOUBLE;
        ACrg[ATT_IDX_Y].desc.value.att_exp = list_att[ATT_IDX_Y];
    
        strcpy(ACrg[ATT_IDX_X].name,ATT_X);
        ACrg[ATT_IDX_X].desc.type = AC_ATTRIB_DOUBLE;
        ACrg[ATT_IDX_X].desc.value.att_exp = list_att[ATT_IDX_X];

        strcpy(ACrg[ATT_IDX_H].name,ATT_H);
        ACrg[ATT_IDX_H].desc.type = AC_ATTRIB_DOUBLE;
        ACrg[ATT_IDX_H].desc.value.att_exp = list_att[ATT_IDX_H];
  
        strcpy(ACrg[ATT_IDX_C].name,ATT_C);
        ACrg[ATT_IDX_C].desc.type = AC_ATTRIB_DOUBLE;
        ACrg[ATT_IDX_C].desc.value.att_exp = list_att[ATT_IDX_C];
 
        strcpy(ACrg[ATT_IDX_N].name,ATT_N);
        ACrg[ATT_IDX_N].desc.type = AC_ATTRIB_DOUBLE;
        ACrg[ATT_IDX_N].desc.value.att_exp = list_att[ATT_IDX_N];

        strcpy(ACrg[ATT_IDX_T].name,ATT_T);
        ACrg[ATT_IDX_T].desc.type = AC_ATTRIB_DOUBLE;
        ACrg[ATT_IDX_T].desc.value.att_exp = list_att[ATT_IDX_T];

        strcpy(ACrg[ATT_IDX_ALLOWANCE].name,ATT_ALLOWANCE);
        ACrg[ATT_IDX_ALLOWANCE].desc.type = AC_ATTRIB_DOUBLE;
        ACrg[ATT_IDX_ALLOWANCE].desc.value.att_exp = 
                                              list_att[ATT_IDX_ALLOWANCE];

        strcpy(ACrg[ATT_IDX_PROCESS].name,ATT_PROCESS);
        ACrg[ATT_IDX_PROCESS].desc.type = AC_ATTRIB_TEXT;
        strcpy(ACrg[ATT_IDX_PROCESS].desc.value.att_txt,
                                   list_att_txt[ATT_IDX_PROCESS]);

        strcpy(ACrg[ATT_IDX_SPEC_NB].name,ATT_SPEC_NB);
        ACrg[ATT_IDX_SPEC_NB].desc.type = AC_ATTRIB_TEXT;
        strcpy(ACrg[ATT_IDX_SPEC_NB].desc.value.att_txt, 
                                   list_att_txt[ATT_IDX_SPEC_NB]);
        
        return 1;
}

long VLgetProcSpec (name,form_ptr,gadget1,gadget2)
char	*name;
char	*form_ptr;
int	gadget1;
int	gadget2;
{
FILE	*ptfile;
char	word[50],cc;
int     iproc=0,ispec=0;
  
  VLopen_setup_file (name, &ptfile);
  if (ptfile == NULL) goto quit;
  
  while (EOF != fscanf(ptfile,"%s",word)) {
    cc = word[0];
    if (cc == '%' || cc == '#') {
      if (word[1] == '\0') fscanf(ptfile,"%s",word);
      else strcpy(word,&word[1]);
      if (cc == '%') {
        if (iproc == 0)
          FIfld_set_list_text(form_ptr,gadget1,iproc, 0,word,TRUE);
        else
          FIfld_set_list_text(form_ptr,gadget1,iproc, 0,word,FALSE);
        iproc++;
      }
      else {
        if (ispec == 0)
          FIfld_set_list_text(form_ptr,gadget2,ispec, 0,word,TRUE);
        else
          FIfld_set_list_text(form_ptr,gadget2,ispec, 0,word,FALSE);
        ispec++;
      }
    }
  }

  fclose(ptfile); 
 quit :
 return 1;
}

method control_edge (long *sts)
{
struct GRid 		*lchild=NULL;
int         		j,i,num=0;
long			l_msg;
struct ACrg_coll        ACrg[ATT_NB_ATT];
char                    tmp[50];
long 			status;

      me->edge_attr.obj_id = me->event1.located_object[0].located_obj;
      me->edge_attr.mod_env = me->event1.located_object[0].module_info;
      memcpy((IGRchar *) me->edge_attr.mod_env.md_env.matrix,
             (IGRchar *) me->event1.located_object[0].module_info.md_env.matrix,
             (IGRint) (16 * sizeof(IGRdouble)) );
      status = om$send ( msg =  message NDnode.NDget_objects(
                                                ND_IN_BUF | ND_ROOT,
                                                (struct GRid *)NULL,
                                                0,
                                                &lchild,
                                                0,
                                                OM_K_MAXINT,
                                                &num ),
		    targetid  =me->edge_attr.obj_id.objid,
                    targetos  = me->edge_attr.obj_id.osnum);
      if (!(status&1)) {
        *sts = MY_ERROR;
        goto quit;
      }
    if (num >= ATT_T_IDX_BOX) {
     me->old_box = lchild[ATT_T_IDX_BOX];
     status = om$send(msg = message ACrg_collect.AClist_attribute
                                        (&l_msg,ATT_NB_ATT,ACrg,&num),
                       targetid = lchild[ATT_T_IDX_BOX].objid,
                       targetos = lchild[ATT_T_IDX_BOX].osnum);
     if (!(status&l_msg&1)) {
       *sts = MY_ERROR;
       goto quit;
     }
   }
   else {
        *sts = MY_ERROR;
        goto quit;
   }
   for (i=0;i<num;i++)
   {
     if (
         i == ATT_IDX_TYPE_ANGLE ||
         i == ATT_IDX_PROCESS ||
         i == ATT_IDX_SPEC_NB 
        ) {
       strcpy(me->list_att_txt[i],ACrg[i].desc.value.att_txt);
       strcpy(me->old_list_att_txt[i],ACrg[i].desc.value.att_txt);
     }
     else 
     me->list_att[i] = me->old_list_att[i]=ACrg[i].desc.value.att_exp;
   }


   if ((j=VLseekFields(ACrg,num,ATT_L)) != -1) {
     sprintf(tmp,"%.2lf",ACrg[j].desc.value.att_exp);
     FIfld_set_text(me->forms[0].form_ptr,G_L,0,
                    0, tmp,FALSE);
     FIfld_set_default_text(me->forms[0].form_ptr,G_L,
                            0,0,tmp,0,0);
  }
   if ((j=VLseekFields(ACrg,num,ATT_S)) != -1) {
     sprintf(tmp,"%.2lf",ACrg[j].desc.value.att_exp);
     FIfld_set_text(me->forms[0].form_ptr,G_S,0,
                    0, tmp,FALSE);
     FIfld_set_default_text(me->forms[0].form_ptr,G_S,
                            0,0,tmp,0,0);
  }
   if ((j=VLseekFields(ACrg,num,ATT_A)) != -1) {
     sprintf(tmp,"%.2lf",ACrg[j].desc.value.att_exp);
     FIfld_set_text(me->forms[0].form_ptr,G_A,0,
                    0, tmp,FALSE);
     FIfld_set_default_text(me->forms[0].form_ptr,G_A,
                            0,0,tmp,0,0);
  }
   if ((j=VLseekFields(ACrg,num,ATT_TYPE_ANGLE)) != -1) {
     FIfld_set_text(me->forms[0].form_ptr,G_TYPE_ANGLE,0,
                    0, ACrg[j].desc.value.att_txt, FALSE);
     FIfld_set_default_text(me->forms[0].form_ptr,G_TYPE_ANGLE,
                            0,0,ACrg[j].desc.value.att_txt,0,0);
  }
   if ((j=VLseekFields(ACrg,num,ATT_TYPE_CHAMF)) != -1) {
    FIg_set_state(me->forms[0].form_ptr,G_TYPE_CHAMF,
                  (int) ACrg[j].desc.value.att_exp);
    FIg_set_default_value(me->forms[0].form_ptr,G_TYPE_CHAMF,
                          ACrg[j].desc.value.att_exp);
  }
   if ((j=VLseekFields(ACrg,num,ATT_B)) != -1) {
     sprintf(tmp,"%.2lf",ACrg[j].desc.value.att_exp);
     FIfld_set_text(me->forms[0].form_ptr,G_B,0,
                    0, tmp,FALSE);
     FIfld_set_default_text(me->forms[0].form_ptr,G_B,
                            0,0,tmp,0,0);
  }
   if ((j=VLseekFields(ACrg,num,ATT_V)) != -1) {
     sprintf(tmp,"%.2lf",ACrg[j].desc.value.att_exp);
     FIfld_set_text(me->forms[0].form_ptr,G_V,0,
                    0, tmp,FALSE);
     FIfld_set_default_text(me->forms[0].form_ptr,G_V,
                            0,0,tmp,0,0);
  }
   if ((j=VLseekFields(ACrg,num,ATT_Y)) != -1) {
     sprintf(tmp,"%.2lf",ACrg[j].desc.value.att_exp);
     FIfld_set_text(me->forms[0].form_ptr,G_Y,0,
                    0, tmp,FALSE);
     FIfld_set_default_text(me->forms[0].form_ptr,G_Y,
                            0,0,tmp,0,0);
  }
   if ((j=VLseekFields(ACrg,num,ATT_X)) != -1) {
     sprintf(tmp,"%.2lf",ACrg[j].desc.value.att_exp);
     FIfld_set_text(me->forms[0].form_ptr,G_X,0,
                    0, tmp,FALSE);
     FIfld_set_default_text(me->forms[0].form_ptr,G_X,
                            0,0,tmp,0,0);
  }
   if ((j=VLseekFields(ACrg,num,ATT_H)) != -1) {
     sprintf(tmp,"%.2lf",ACrg[j].desc.value.att_exp);
     FIfld_set_text(me->forms[0].form_ptr,G_H,0,
                    0, tmp,FALSE);
     FIfld_set_default_text(me->forms[0].form_ptr,G_H,
                            0,0,tmp,0,0);
  }
   if ((j=VLseekFields(ACrg,num,ATT_C)) != -1) {
     sprintf(tmp,"%.2lf",ACrg[j].desc.value.att_exp);
     FIfld_set_text(me->forms[0].form_ptr,G_C,0,
                    0, tmp,FALSE);
     FIfld_set_default_text(me->forms[0].form_ptr,G_C,
                            0,0,tmp,0,0);
  }
   if ((j=VLseekFields(ACrg,num,ATT_N)) != -1) {
     sprintf(tmp,"%.2lf",ACrg[j].desc.value.att_exp);
     FIfld_set_text(me->forms[0].form_ptr,G_N,0,
                    0, tmp,FALSE);
     FIfld_set_default_text(me->forms[0].form_ptr,G_N,
                            0,0,tmp,0,0);
  }
   if ((j=VLseekFields(ACrg,num,ATT_T)) != -1) {
     sprintf(tmp,"%.2lf",ACrg[j].desc.value.att_exp);
     FIfld_set_text(me->forms[0].form_ptr,G_T,0,
                    0, tmp,FALSE);
     FIfld_set_default_text(me->forms[0].form_ptr,G_T,
                            0,0,tmp,0,0);
  }
   if ((j=VLseekFields(ACrg,num,ATT_ALLOWANCE)) != -1) {
     sprintf(tmp,"%.2lf",ACrg[j].desc.value.att_exp);
     FIfld_set_text(me->forms[0].form_ptr,G_ALLOWANCE,0,
                    0, tmp,FALSE);
     FIfld_set_default_text(me->forms[0].form_ptr,G_ALLOWANCE,
                            0,0,tmp,0,0);
  }
   if ((j=VLseekFields(ACrg,num,ATT_PROCESS)) != -1) {
     FIfld_set_text(me->forms[0].form_ptr,G_PROCESS,0,
                    0, ACrg[j].desc.value.att_txt,FALSE);
     FIfld_set_default_text(me->forms[0].form_ptr,G_PROCESS,
                            0,0,ACrg[j].desc.value.att_txt,0,0);
  }
   if ((j=VLseekFields(ACrg,num,ATT_SPEC_NB)) != -1) {
     FIfld_set_text(me->forms[0].form_ptr,G_SPEC_NB,0,
                    0, ACrg[j].desc.value.att_txt,FALSE);
     FIfld_set_default_text(me->forms[0].form_ptr,G_SPEC_NB,
                            0,0,ACrg[j].desc.value.att_txt,0,0);
  }
quit : 
  FIg_enable(me->forms[0].form_ptr,FI_EXECUTE);
  FIg_enable(me->forms[0].form_ptr,FI_RESET);
  return OM_S_SUCCESS;
}

method modify_mac (long *sts)
{
struct GRid 		my_grid;
int	    		i,b_mod,cn_type;
struct GRid 		box;
long        		status,loc_msg;
struct ACrg_coll 	ACrg[ATT_NB_ATT];
  
  for (i=0;i<ATT_NB_ATT;i++)
  {
    if (
         i == ATT_IDX_TYPE_ANGLE ||
         i == ATT_IDX_PROCESS ||
         i == ATT_IDX_SPEC_NB 
        ) {
      if (strcmp(me->list_att_txt[i],me->old_list_att_txt[i]))
        break;
    }
    else
      if (me->list_att[i] != me->old_list_att[i]) break;
  }

  if (i < ATT_NB_ATT) {
    box.objid = NULL_OBJID;
    box.osnum = me->ModuleInfo.md_id.osnum;
    status = om$construct(classid = OPP_ACrg_collect_class_id,
                              osnum   = box.osnum,
                              p_objid = &box.objid);
    if (!(status&1)) {
      *sts = MY_ERROR;
      goto quit;
    }

    om$send( msg = message NDnode.NDchg_state(ND_DEL_NO_CH, ND_DEL_NO_CH ),
                 targetid = box.objid,
                 targetos = box.osnum );
    
             /* prepare ACrg collection */
    VLfillACrg(ACrg,me->list_att,me->list_att_txt);

    strcpy(ACrg[ATT_IDX_TYPE].name,ATT_TYPE);
    ACrg[ATT_IDX_TYPE].desc.type = AC_ATTRIB_DOUBLE;
    ACrg[ATT_IDX_TYPE].desc.value.att_exp = 1;

    status = om$send(msg = message ACrg_collect.ACadd_list_attribute
                         (&loc_msg, ATT_NB_ATT, ACrg),
                         targetid = box.objid,
                         targetos = box.osnum);
     if(!(status & loc_msg & 1)) {
       *sts = MY_ERROR;
       goto quit;
     }
    status = om$send(msg = message NDnode.NDchange_connect
                      (1,&me->old_box,&box),
                      targetid = me->edge_attr.obj_id.objid,
                      targetos = me->edge_attr.obj_id.osnum);
    if (!(status&1)) {
      *sts = MY_ERROR;
      goto quit;
    }
      my_grid = me->edge_attr.obj_id;
      cn_type    = ND_COMP; /* recompute the object */
      status = nd$wait_batch(type        = GR_GEOM_POSTED,
                             nb_obj      = 1,
                             l_object    = &my_grid,
                             l_obj_info  = &cn_type );

       nd$mod_batch(request     = ND_INQ,
                    p_ret_mode  = &b_mod );   
        if( b_mod != ND_DEFER ){
              nd$exec_batch();
        }
    for (i=0;i<ATT_NB_ATT;i++)
    {
      if (
           i == ATT_IDX_TYPE_ANGLE ||
           i == ATT_IDX_PROCESS ||
           i == ATT_IDX_SPEC_NB 
          ) {
        strcpy(me->old_list_att_txt[i],me->list_att_txt[i]);
      }
      else
        me->old_list_att[i] = me->list_att[i];
    }
  }
quit : 
  return OM_S_SUCCESS;
}

method save_all  (long *sts)
{
char  tmp[50];
int   i;
long	status;

  *sts = MY_ERROR;
  
  dp$erase_hilite( msg = &status ) ;

  FIg_get_text(me->forms[0].form_ptr,G_L,tmp);
  sscanf(tmp,"%lf",&me->list_att[ATT_IDX_L]);
  FIg_set_default_value(me->forms[0].form_ptr,G_L,me->list_att[ATT_IDX_L]);

  FIg_get_text(me->forms[0].form_ptr,G_S,tmp);
  sscanf(tmp,"%lf",&me->list_att[ATT_IDX_S]);
  FIg_set_default_value(me->forms[0].form_ptr,G_S,me->list_att[ATT_IDX_S]);

  FIg_get_text(me->forms[0].form_ptr,G_A,tmp);
  sscanf(tmp,"%lf",&me->list_att[ATT_IDX_A]);
  FIg_set_default_value(me->forms[0].form_ptr,G_A,me->list_att[ATT_IDX_A]);

  FIg_get_text(me->forms[0].form_ptr,G_TYPE_ANGLE,
                                    me->list_att_txt[ATT_IDX_TYPE_ANGLE]);
  FIfld_set_default_text(me->forms[0].form_ptr,G_TYPE_ANGLE,
                         0,0,me->list_att_txt[ATT_IDX_TYPE_ANGLE],0,0);

  FIg_get_text(me->forms[0].form_ptr,G_B,tmp);
  sscanf(tmp,"%lf",&me->list_att[ATT_IDX_B]);
  FIg_set_default_value(me->forms[0].form_ptr,G_B,me->list_att[ATT_IDX_B]);

  FIg_get_text(me->forms[0].form_ptr,G_V,tmp);
  sscanf(tmp,"%lf",&me->list_att[ATT_IDX_V]);
  FIg_set_default_value(me->forms[0].form_ptr,G_V,me->list_att[ATT_IDX_V]);

  FIg_get_text(me->forms[0].form_ptr,G_Y,tmp);
  sscanf(tmp,"%lf",&me->list_att[ATT_IDX_Y]);
  FIg_set_default_value(me->forms[0].form_ptr,G_Y,me->list_att[ATT_IDX_Y]);

  FIg_get_text(me->forms[0].form_ptr,G_X,tmp);
  sscanf(tmp,"%lf",&me->list_att[ATT_IDX_X]);
  FIg_set_default_value(me->forms[0].form_ptr,G_X,me->list_att[ATT_IDX_X]);

  FIg_get_text(me->forms[0].form_ptr,G_H,tmp);
  sscanf(tmp,"%lf",&me->list_att[ATT_IDX_H]);
  FIg_set_default_value(me->forms[0].form_ptr,G_H,me->list_att[ATT_IDX_H]);

  FIg_get_text(me->forms[0].form_ptr,G_C,tmp);
  sscanf(tmp,"%lf",&me->list_att[ATT_IDX_C]);
  FIg_set_default_value(me->forms[0].form_ptr,G_C,me->list_att[ATT_IDX_C]);

  FIg_get_text(me->forms[0].form_ptr,G_N,tmp);
  sscanf(tmp,"%lf",&me->list_att[ATT_IDX_N]);
  FIg_set_default_value(me->forms[0].form_ptr,G_N,me->list_att[ATT_IDX_N]);

  FIg_get_text(me->forms[0].form_ptr,G_T,tmp);
  sscanf(tmp,"%lf",&me->list_att[ATT_IDX_T]);
  FIg_set_default_value(me->forms[0].form_ptr,G_T,me->list_att[ATT_IDX_T]);

  FIg_get_text(me->forms[0].form_ptr,G_ALLOWANCE,tmp);
  sscanf(tmp,"%lf",&me->list_att[ATT_IDX_ALLOWANCE]);
  FIg_set_default_value(me->forms[0].form_ptr,G_ALLOWANCE,
                        me->list_att[ATT_IDX_ALLOWANCE]);

  FIg_get_state(me->forms[0].form_ptr,G_TYPE_CHAMF, &i);
  me->list_att[ATT_IDX_TYPE_CHAMF] = i;
  FIg_set_default_value(me->forms[0].form_ptr,G_TYPE_CHAMF,
                                            me->list_att[ATT_IDX_TYPE_CHAMF]);

  FIg_get_text(me->forms[0].form_ptr,G_PROCESS,
                                     me->list_att_txt[ATT_IDX_PROCESS]);
  FIfld_set_default_text(me->forms[0].form_ptr,G_PROCESS,
                         0,0,me->list_att_txt[ATT_IDX_PROCESS],0,0);

  FIg_get_text(me->forms[0].form_ptr,G_SPEC_NB,
                                  me->list_att_txt[ATT_IDX_SPEC_NB]);
  FIfld_set_default_text(me->forms[0].form_ptr,G_SPEC_NB,
                         0,0,me->list_att_txt[ATT_IDX_SPEC_NB],0,0);

  if( me->list_att[ATT_IDX_ALLOWANCE]  < 0.0 )
  {
     FIg_set_text(me->forms[0].form_ptr,G_FI_MSG_FIELD,"Allowance should not be negative");
     *sts = MSFAIL;
     return OM_S_SUCCESS;
  }

  if( me->list_att[ATT_IDX_ALLOWANCE]  < 0.5*me->list_att[ATT_IDX_V] )
  {
     FIg_set_text(me->forms[0].form_ptr,G_FI_MSG_FIELD,"Check: Allowance >= 0.5*V");
     *sts = MSFAIL;
     return OM_S_SUCCESS;
  }

  *sts = MSSUCC;
  return OM_S_SUCCESS;
}


end implementation VLplEdAtCmd;
