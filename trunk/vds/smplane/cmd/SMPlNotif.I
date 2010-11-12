/* $Id: SMPlNotif.I,v 1.1.1.1 2001/01/04 21:07:36 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/smplane/cmd / SMPlNotif.I
 *
 * Description:
 *		Methods and functions for SMCmdSglPl 
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: SMPlNotif.I,v $
 *	Revision 1.1.1.1  2001/01/04 21:07:36  cvs
 *	Initial import to CVS
 *	
# Revision 1.2  1998/09/21  16:57:04  pinnacle
# tr179801722
#
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
# Revision 1.1  1997/05/08  13:20:44  pinnacle
# New project VDS 250
#
# Revision 1.1  1996/07/19  20:33:52  pinnacle
# Create VDS 241 project
#
# Revision 1.5  1996/05/07  12:05:08  pinnacle
# Replaced: smplane/cmd/SMPlNotif.I for:  by ksundar for vds.240
#
# Revision 1.4  1995/11/07  22:35:10  pinnacle
# Replaced: ./smplane/cmd/SMPlNotif.I for:  by azuurhou for vds.240
#
# Revision 1.3  1995/10/26  21:45:20  pinnacle
# Replaced: ./smplane/cmd/SMPlNotif.I for:  by azuurhou for vds.240
#
# Revision 1.1  1994/11/14  22:42:32  pinnacle
# Create vds.240 from vds.232
#
# Revision 1.1  1994/11/08  16:07:00  pinnacle
# create vds.232
#
 *
 * History:
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *	06/01/92	jean		Creattion Date
 *	09/09/95	adz		Correction the recompute and units
 *					convertion. TR#179526927
 *	05/07/96	Sundar		Called VDltrim, VDrtrim, VDspace
 *					for TR: 179601863.
 *      09/21/98        ah              TR179801722 Calling debug routine VD_PldumpBuffer
 *                                      under Solaris 2.6 was causing problems for MODIFY
 *                                      Don't understand why yet but commenting out
 *                                      the calls fixed the problem.
 *                                      Turning on debug would also fix it.
 * -------------------------------------------------------------------*/

class implementation SMCmdSglPl;
 
#include <stdio.h>
#include <string.h> 
#include "bsparameters.h"
#include "expression.h"
#include "expmacros.h"
#include "macro.h"
#include "AS_status.h"
#include "grdpbdef.h"
#include "grdpbmacros.h"
#include "DItypedef.h"
#include "DIdef.h"
#include "v_miscmacros.h"
#include "v_dbgmacros.h"

extern GRclassid OPP_EMSplane_class_id;
extern GRclassid OPP_ACcpx_class_id;
extern GRclassid OPP_SMInfPlane_class_id;

from GRvg	import GRgetname,GRputname,GRchgname; 
from GRgencs    import GRget_cs_info;
from NDnode     import NDget_objects,NDgive_structure,
                       NDchange_connect,ASreturn_go,NDs_compute_node,
                       NDdisplay;
from ACncpx  import ACmplace;

from text_exp   import modify;
from expression import NDgive_value;

#define	ORIGINAL_COMP	1

#ifdef	ORIGINAL_COMP

%safe
static int x_form = -1;
static int y_form = -1; 
%endsafe

#else

extern	int	x_form, y_form ;

#endif

/* ------------------ static void VD_PldumpBuffer ----------------------- */

static void VD_PldumpBuffer( info, buf )
char			*info ;
struct	param_buffer	*buf ;
{

     __DBGpr_str("INFO INFO ", info );

     __DBGpr_str(" Name  ", buf->name );
     __DBGpr_str(" Justif", buf->justif );
     __DBGpr_str(" Annot ", buf->annot );
     __DBGpr_int(" Revers", buf->rev );
     __DBGpr_dbl(" Size  ", buf->size );
     __DBGpr_dbl(" Dist  ", buf->dist );

#ifdef	vdsDEBUG
	printf( "\tAxis: %c \n", buf->axis );
#endif
}
  
/* ------------------ static void PlGenerDefName ------------------------ */
/* Given a base name , gener a default name (adding "_" number if needed) */

static void PlGenerDefName(base_name,def_name)
char  *base_name; /* [I] */
char  *def_name;  /* [O]  */
{
  struct GRid tmp_obj;
  char        *pt;
  IGRint      status;
  int         i;

  SetProc( static_PlGenerDefName ); Begin

  strcpy(def_name,base_name);
  status = di$translate(objname =  def_name,
			p_objid = &tmp_obj.objid);
  if(status == DIR_S_SUCCESS)
   {
     pt = strchr(def_name,'_');
     if(pt == NULL)
      {
     	pt = def_name + strlen(base_name);
        *pt = '_';
      }
     pt++;

     for(i=1;i<5000;i++)
      {
	sprintf(pt,"%d",i);
	status = di$translate(objname =  def_name,
			      p_objid = &tmp_obj.objid);
	if(status != DIR_S_SUCCESS) break;
      }
   } 

   End ;
}

/* ------------------ static int SMPlaceSingPlane ------------------ */
/* Create the macro for single(s) plane(s)                           */
/* If more then one cs is given, all the macro are created           */

static int SMPlaceSingPlane(param_buf,cs,nb_cs,mod_env)
struct param_buffer *param_buf;  /* [I]             */
struct GRid         *cs;         /* [I] Array of cs */
IGRint              nb_cs;       /* [I]             */
struct  GRmd_env    *mod_env; 	 /* [I]             */
{
  int         i;
  struct GRid roots[NB_TMP],mac;
  char        def_name[DI_PATH_MAX];
  IGRint      status;
  IGRlong     msg;
  char        tmp[80];

  SetProc( static_SMPlaceSingPlane ); Begin

  for(i = 0; i < nb_cs; i++)
   {
     /* TR179801722 */
     // VD_PldumpBuffer( "Place Single" , param_buf );

     /* Gener a default name if name already exists */
     PlGenerDefName(param_buf->name,def_name);

     /* Cs is template 0 */
     roots[0] = cs[i];

     /* Axis is template 1 */
     roots[1].osnum = mod_env->md_id.osnum;
     tmp[0] = param_buf->axis; tmp[1] = '\0';

     status = EXP_text_exp_build(NULL,tmp,
				 mod_env->md_id.osnum,&(roots[1].objid));
     if(status != DIR_S_SUCCESS)
      {printf("error creating expression for axis\n"); return 0;}

     /* Distance is template 2 */
     roots[2].osnum = mod_env->md_id.osnum;
     sprintf( tmp, "%lf", param_buf->dist );
     status =  exp$create(exp_name  = NULL,
			  exp_syntax = tmp,
			  p_exp_id  = &roots[2].objid,
			  osnum     = roots[2].osnum);
     if(status != DIR_S_SUCCESS)
      {printf("error creating expression for distance on axe\n"); return 0;}

     /* size is template 3 */
     roots[3].osnum = mod_env->md_id.osnum;
     sprintf( tmp, "%lf", param_buf->size );
     status =  exp$create(exp_name  = NULL,
			  exp_syntax = tmp,
			  p_exp_id  = &roots[3].objid,
			  osnum     = roots[3].osnum);
     if(status != DIR_S_SUCCESS)
      {printf("error creating expression for plane size\n"); return 0;}

     /* Annotation is template 4. If annot == "$0" then annot is name */
     roots[4].osnum =  mod_env->md_id.osnum;
     if(strcmp(param_buf->annot,"$0") == 0)
       status = EXP_text_exp_build(NULL,def_name,
				   mod_env->md_id.osnum,&(roots[4].objid));
     else
       status = EXP_text_exp_build(NULL,param_buf->annot,
				   mod_env->md_id.osnum,&(roots[4].objid));
     if(status != DIR_S_SUCCESS)
      {printf("error creating expression for annotation\n"); return 0;}  

     /* Reverse is template 5 */
     roots[5].osnum =  mod_env->md_id.osnum;
     status = exp$create(exp_name  = NULL,
			 exp_value = (double)param_buf->rev,
			 p_exp_id  = &roots[5].objid,
			 osnum     = roots[5].osnum);
     if(status != DIR_S_SUCCESS)
      {printf("error creating expression for reverse\n"); return 0;} 


     /* Justif is template 6 */
     roots[6].osnum = mod_env->md_id.osnum;
     status = EXP_text_exp_build(NULL,param_buf->justif,
				 mod_env->md_id.osnum,&(roots[6].objid));
     if(status != DIR_S_SUCCESS)
      {printf("error creating expression for annotation\n"); return 0;} 
     
     /* Create the plane */
     mac.osnum = mod_env->md_id.osnum;
     status = om$construct(classid = OPP_SMInfPlane_class_id,
			   osnum   = mac.osnum,
			   p_objid = &mac.objid );
     if(!(status & 1))
      {printf("erreur creating macro\n"); return 0;}

     status = om$send(msg = message  ACncpx.ACmplace
		      ((IGRint *)&msg,ACcant_place_sym,0,
		       "SMInfPlane",NB_TMP, roots,mod_env),
		      senderid = NULL_OBJID,
		      targetid = mac.objid,
		      targetos = mac.osnum);
     if(!(status & msg & 1))
      {printf("erreur place macro\n"); return 0;}

     status = om$send(msg = message GRvg.GRputname(&msg,def_name),
		      senderid = NULL_OBJID,
		      targetid = mac.objid,
		      targetos = mac.osnum);
     if(!(status & msg & 1))
      {printf("Erreur put macro name %s\n",def_name);return 0;}
   }

  End ;
  return 1;
}

/* ------------------ static int SMModSingPlane ------------------ */
/* Modify the single plane macro                                   */

static int SMModSingPlane(mac,param_buf,cs,old_param_buf,old_cs,mod_env)
struct GRid          *mac;            /* [I] GRid of the infinite plane macro */
struct param_buffer  *param_buf;      /* [I]                                  */
struct GRid          *cs;             /* [I] The new cs                       */
struct param_buffer  *old_param_buf;  /* [I]                                  */
struct GRid          *old_cs;         /* [I] cs before modif                  */
struct GRmd_env      *mod_env;        /* [I]                                  */
{
		IGRint			status;
		IGRlong			msg;
		IGRshort		rc;
		IGRdouble		tolerance ;
		IGRchar			tmp[80];
		IGRboolean		put_batch = FALSE,
					recompute_node = FALSE;
		IGRint			wait_batch;
		struct GRid		roots[NB_TMP];
		IGRint			count,
					cn_type;

  SetProc( static_SMModSingPlane ); Begin

  /* get the system base tol */
  BSxtractpar( &rc, BSTOLBASIS, &tolerance );
  __DBGpr_dbl(" BSTOLBASIS ", tolerance );
  
  status = om$send(msg = message NDnode.NDget_objects
		   (ND_ROOT,roots,NB_TMP,NULL,0,NB_TMP,&count),
		   senderid = NULL_OBJID,
		   targetid = mac->objid,
		   targetos = mac->osnum );
  if(status != OM_S_SUCCESS || count != NB_TMP)
   {printf("can't retreive plane roots objid = %d\n",mac->objid);}
  
  if( ! IF_EQ_GRID ( *cs, *old_cs )){

     __DBGpr_com(" Change C.S. " );

     status = om$send(msg = message NDnode.NDchange_connect
		      (1,old_cs,cs),
		      senderid = NULL_OBJID,
		      targetid = mac->objid,
		      targetos = mac->osnum);
     if(!(status & 1))
      {printf("Error change cs connect\n");return 0;}
     put_batch = TRUE;
   }

  /* TR179801722 */
  //VD_PldumpBuffer( "Old Single Plane" , old_param_buf );
  //VD_PldumpBuffer( "New Single Plane" , param_buf );

  if( param_buf->axis != old_param_buf->axis ){

     __DBGpr_com(" Modify Axis " );

     tmp[0] = param_buf->axis; tmp[1] = '\0';
     status = om$send(msg = message text_exp.modify
		      (NULL,tmp,&rc),
		      senderid = NULL_OBJID,
		      targetid = roots[1].objid,
		      targetos = roots[1].osnum);
     if(!(status & 1))
      {printf("Can't modify axis for the ci macro\n");return 0;}
     put_batch = TRUE;
  }
  
  if( fabs(param_buf->dist - old_param_buf->dist) > tolerance ){

     __DBGpr_com(" Modify Distance" );
     sprintf(tmp,"%lf",param_buf->dist);

     __DBGpr_str("New Dist ", tmp );

     status = exp$modify(exp_id = roots[2].objid,
		 	 osnum = roots[2].osnum, 
			 exp_syntax = tmp ); 
     if(!(status & 1))
      {printf("Can't modify dist for the ci macro\n");return 0;}
     put_batch = TRUE;
  } 
  
  if( fabs(param_buf->size - old_param_buf->size) > tolerance ){

     __DBGpr_com(" Modify Size" );

     sprintf(tmp,"%lf",param_buf->size);
     status = exp$modify(exp_id = roots[3].objid,
		 	 osnum = roots[3].osnum, 
			 exp_syntax = tmp ); 
     if(!(status & 1))
      {printf("Can't modify size for the ci macro\n");return 0;}
     recompute_node = TRUE;
  } 
  
  if( strcmp( param_buf->annot, old_param_buf->annot )){

     __DBGpr_com(" Modify Annot" );

     if(strcmp(param_buf->annot,"$0") == 0)
       strcpy(param_buf->annot,param_buf->name);
	
     status = om$send(msg = message text_exp.modify
		      (NULL,param_buf->annot,&rc),
		      senderid = NULL_OBJID,
		      targetid = roots[4].objid,
		      targetos = roots[4].osnum);
     if(!(status & 1))
      {printf("Can't modify annot for the ci macro\n");return 0;}
     recompute_node = TRUE;
  }
  
  if( param_buf->rev != old_param_buf->rev ){

     __DBGpr_com(" Modify Reverse" );

     sprintf(tmp,"%lf",(double)param_buf->rev);
     status = exp$modify(exp_id = roots[5].objid,
		 	 osnum = roots[5].osnum, 
			 exp_syntax = tmp); 
     if(!(status & 1))
      {printf("Can't modify size for the ci macro\n");return 0;}
     put_batch = TRUE;
  }
  
  if( strcmp( param_buf->justif, old_param_buf->justif )){

     __DBGpr_com(" Modify Justif" );

     status = om$send(msg = message text_exp.modify
		      (NULL,param_buf->justif,&rc),
		      senderid = NULL_OBJID,  
		      targetid = roots[6].objid,
		      targetos = roots[6].osnum);
     if(!(status & 1))
      {printf("Can't modify annot for the ci macro\n");return 0;}
     recompute_node = TRUE;
  } 

  if( strcmp( old_param_buf->name, param_buf->name )){

     char old_name[DI_PATH_MAX],new_name[DI_PATH_MAX];

     __DBGpr_com(" Modify Name" );

     status = om$send(msg = message GRvg.GRgetname
		      (&msg,old_name),
		       senderid = NULL_OBJID,
		      targetid = mac->objid,
		      targetos = mac->osnum);
     di$split(pathname = old_name,dirname = new_name);
     DIstmcat(new_name,param_buf->name,NULL);

     status = om$send(msg = message GRvg.GRchgname
		      (&msg,mod_env,new_name),
		      senderid = NULL_OBJID,
		      targetid = mac->objid,
		      targetos = mac->osnum);
     if(!(status & msg & 1))
      {printf("Erreur change name of the macro\n"); return 0; }
  }  

  __DBGpr_int(" Batch Flag ", put_batch );
  __DBGpr_int(" Recompute  ", recompute_node );

  /* switch type of change : if recomputation put in batch,
     if display only recompute node */

  if( put_batch ){

     cn_type    = 1; /* recompute the object */
     status = nd$wait_batch(type       = GR_GEOM_POSTED,
			    l_object   = mac,
			    l_obj_info = &cn_type,
			    nb_obj     = 1);

     nd$mod_batch(request    = ND_INQ,p_ret_mode = &wait_batch);
     
     if(wait_batch == ND_DEFER) return 1; /* Nothing to do */
  
     nd$exec_batch(mode = ND_DISP_ROOT|ND_DISP_BODY);
     End ;
     return 1;
  }

  if( recompute_node ){

       status = om$send(msg = message NDnode.NDdisplay(0,GRbe,mod_env),
			senderid = NULL_OBJID,
			targetid = mac->objid,
			targetos = mac->osnum);
       as$status(action = CONTINUE);

       status = om$send(msg = message NDnode.NDs_compute_node(&msg,0,mod_env),
			senderid = NULL_OBJID,
			targetid = mac->objid,
			targetos = mac->osnum);
       if(!(status & msg & 1))
	{ printf("Erreur compute node\n");return 0;}
       
       status = om$send(msg = message NDnode.NDdisplay(0,GRbd,mod_env),
			senderid = NULL_OBJID,
			targetid = mac->objid,
			targetos = mac->osnum);
       as$status(action = CONTINUE);

       End ;
       return 1;
   }

   End ;
   return 1;
}

/* ------------------ static int PlDisplayDoubleField ----------------------- */
/*Display a double field which appeared  when his associate gadget is selected*/ 

static int PlDisplayDoubleField(form,label,default_value)
Form   form;          /* [I] Form pointer where the field must appear      */
int    label;         /* [I] Label of gadget to display		           */
IGRdouble default_value; /* [I] The value to place in the field (or NO_VALUE) */
{
  int    test;
  double ext_value;
  
  SetProc( static_PlDisplayDoubleField ); Begin

  if(form == NULL) return 0;

  
  test = FIg_display(form,label);
  
  if(test != FI_SUCCESS) return 0;
  
  test = FIfld_pos_cursor(form,label,0 ,0,0, 0, 0, 0);
  if(test != FI_SUCCESS) return 0;
  
  if(default_value == NO_VALUE)
    FIg_set_text(form,label,"");
  else
   {
     SMConvDistIntExt(default_value,&ext_value,2);

     __DBGpr_dbl( "Default_value ", default_value );
     __DBGpr_dbl( "External_val  ", ext_value );

     FIg_set_value(form,label,ext_value);
   }

  End ;
  return 1;
}

/* ------------------ static int PlChangeStateGadget ------------------ */
/* Change the gadget state of the main form                             */

static int PlChangeStateGadget(form,change_state,command_type)
Form form;   		 /* [I] Pointer to the main form        */
int  change_state;       /* [I] TRUE = enable FALSE = disable   */
int  command_type;       /* [I]                                 */
{
  static int main_table[] = {
    FI_ACCEPT, FI_RESET,FI_EXECUTE, CS_BUTTON,NAME_FIELD,
    ANNOTATION_FIELD,DIST_FIELD,
    ORIENTATION_TOGGLE,SIZE_LIST,SIZE_FIELD,X_BUTTON,Y_BUTTON,Z_BUTTON,
    NN_BUTTON,NC_BUTTON,NP_BUTTON,CN_BUTTON,CC_BUTTON,CP_BUTTON,
    PN_BUTTON,PC_BUTTON,PP_BUTTON,-1};
    
  int i ;
  
  if(form == NULL) return 0;
  
  /* Particular traitement for LOADC_BUTTON witch is not always enable */
  if(command_type == PLACE)
    if(change_state == TRUE)
      FIg_enable(form,LOADC_BUTTON);
    else 
      FIg_disable(form,LOADC_BUTTON);
  
  i = 0;
  while(main_table[i] != -1)
   {
     if(change_state == FALSE)
       FIg_disable(form,main_table[i]);
     else
       FIg_enable(form,main_table[i]);
     i++;
   }
  return 1;
}


/* ------------------ static int PlGetAxis ------------------ */
/* Get the selected axis                                      */

static int PlGetAxis(form,axis)
Form form;
char *axis;
{
  int state;

  FIg_get_state(form,X_BUTTON,&state);
  if(state) {*axis = 'x'; return 1;}
  FIg_get_state(form,Y_BUTTON,&state);
  if(state) {*axis = 'y' ; return 1;}
  FIg_get_state(form,Z_BUTTON,&state);
  if(state) {*axis = 'z' ; return 1;}

  return 0;
}

/* ------------------ static void PlSetAxis ------------------ */
/* Set the axis                                                */

static void PlSetAxis(form,ax1)
Form form;                   /* [I] a pointer to the main form  */
char ax1;                    /* [I] ax1 is the axe selected     */
{
  char str[4];
  char ax2,ax3;

  ax2 = 'x';
  ax3 = 'y';
  if(ax1 == 'x') { ax2 = 'y'; ax3 = 'z'; }
  if(ax1 == 'y') { ax2 = 'z'; ax3 = 'x'; }
  if(ax1 == 'z') { ax2 = 'x'; ax3 = 'y'; }

  str[0] = ax2; str[1] = '\0';
  FIg_set_text(form,JUSTIF1_FIELD,str);
  str[0] = ax3;
  FIg_set_text(form,JUSTIF2_FIELD,str);

  switch(ax1) 
   {
   case 'x' :
     FIg_set_state_off(form,Y_BUTTON); 
     FIg_set_state_off(form,Z_BUTTON);
     FIg_set_state_on(form,X_BUTTON);
     break;
   case 'y' :
     FIg_set_state_off(form,X_BUTTON); 
     FIg_set_state_off(form,Z_BUTTON);
     FIg_set_state_on(form,Y_BUTTON);
     break;
   case 'z' :
     FIg_set_state_off(form,X_BUTTON); 
     FIg_set_state_off(form,Y_BUTTON);
     FIg_set_state_on(form,Z_BUTTON);
     break;
   } 
}

/* ------------------ static void PlSetDist ------------------ */
/* Set the distance field                                      */

static void PlSetDist(form,dist)
Form      form;          /* [I] pointer to the form */
IGRdouble dist;          /* [I] The value of the distance    */
{
   char      value[40];
   IGRdouble conv_dist;

   SMConvDistIntExt(dist,&conv_dist,2);   

   /*
    * Optimize the output for display (%lf -> %g )
    */
   sprintf(value,"%g",conv_dist);

   __DBGpr_dbl( "Default_value ", dist );
   __DBGpr_dbl( "External_val  ", conv_dist );
   __DBGpr_str( "External_str  ", value );

   FIg_set_text(form,DIST_FIELD,value);
} 

/* ------------------ static int PlGetDist ------------------ */
/* Get the distance in the dist field                         */

static int PlGetDist(form,dist)
Form       form ;           /* [I] pointer to the form */
IGRdouble *dist;            /* [O] The value return    */
{
  char       value[40];
  char       my_msg[80];
  int        sel_flag,r_pos;
  IGRdouble  ext_dist;

  SetProc( static_PlGetDist ); Begin

  value[0] = '\0';
  FIfld_get_text(form,DIST_FIELD,0,0,39,
		 (unsigned char*)value,&sel_flag,&r_pos);
  value[39] = '\0';
  if((value[0] == '\0') || (sscanf(value,"%lf",&ext_dist) != 1))
   {
     ex$message( msgnumb = SM_E_PlBadDist, buff = my_msg);
     FIg_set_text(form,FI_MSG_FIELD,my_msg);
     FIg_set_text(form,DIST_FIELD,"0");
     End ;
     return 0;
   }

  SMConvDistExtInt(ext_dist,dist,2);

  __DBGpr_str( "External_str  ", value );
  __DBGpr_dbl( "External_val  ", ext_dist );
  __DBGpr_dbl( "Default_value ", *dist );

  End ;
  return 1;
}

/* ------------------ static int PlGetPlaneSize ------------------ */
/* Save the value for plane size in fonction of the size           */

static int PlGetPlaneSize(form,size)
Form      form ;       /* [I] pointer to the form */
IGRdouble *size;       /* [O] The value return    */
{
  double value;
  char my_msg[80];
  char type_list[30];

  type_list[0] = '\0';
  FIg_get_text(form,SIZE_LIST,type_list);
  if(strcmp(type_list,"Small") == 0) *size = -1.0;
  else if(strcmp(type_list,"Regular") == 0) *size = 0.0;
  else if(strcmp(type_list,"Large") == 0) *size = -2.0;
  else 
   {
     FIg_get_value(form,SIZE_FIELD,&value);
     if(value <= 0)
      {
	ex$message(msgnumb = SM_I_PlSizePos,buff = my_msg);
	FIg_set_text(form,FI_MSG_FIELD,my_msg);
	return 0;
      }
     else
       SMConvDistExtInt(value,size,2);

   }
  return 1;
}

/* ------------------ static void PlGetJustif ------------------ */
/* Look at form to see what is the seleted justif button         */

static void PlGetJustif(form,justif)
Form form;
char *justif;
{
  int state;
  
  FIg_get_state(form,NN_BUTTON,&state);
  if(state) { strcpy(justif,"NN"); return;}
  FIg_get_state(form,NC_BUTTON,&state);
  if(state) { strcpy(justif,"NC"); return;}
  FIg_get_state(form,NP_BUTTON,&state);
  if(state) { strcpy(justif,"NP"); return;}  
  FIg_get_state(form,CN_BUTTON,&state);
  if(state) { strcpy(justif,"CN"); return;}
  FIg_get_state(form,CC_BUTTON,&state);
  if(state) { strcpy(justif,"CC"); return;}
  FIg_get_state(form,CP_BUTTON,&state);
  if(state) { strcpy(justif,"CP"); return;}
  FIg_get_state(form,PN_BUTTON,&state);
  if(state) { strcpy(justif,"PN"); return;}
  FIg_get_state(form,PC_BUTTON,&state);
  if(state) { strcpy(justif,"PC"); return;}
  FIg_get_state(form,PP_BUTTON,&state);
  if(state) { strcpy(justif,"PP"); return;}
}

/* ------------------ static int PlTestParameter --------------------------- */
/* Test the coherence of the main paramater                                  */
/* Return 1 if OK else 0                                                     */

static int PlTestParameter(form,mac,param_buf,old_param_buf,command_type)
Form                 form;          /*[I] pointer to main form                */
struct GRid         *mac;           /*[I] The plan macro (need only in modify)*/
struct param_buffer *param_buf;     /*[O] param_buffer where info are store  */ 
struct param_buffer *old_param_buf; /*[I] param buffer before save           */
int                  command_type;  /*[I] PLACE or MODIFY                    */
{
  char        my_msg[MY_MSG_LEN];
  struct GRid tmp_obj;
  IGRlong     msg;  
  IGRint      status;  
  int         sel_flag,r_pos;
  int         state;
  
  param_buf->name[0] = '\0';
  FIfld_get_text(form,NAME_FIELD,0,0,39,
		 (unsigned char*)param_buf->name,&sel_flag,&r_pos);
  param_buf->name[39] = '\0';
  VDltrim(param_buf->name);
  VDrtrim(param_buf->name);
  if ( VDspace(param_buf->name) ){
        FIg_set_text(form,FI_MSG_FIELD, "Name should not contain blanks");
                return 0;
  }
  if(param_buf->name[0] == '\0')
   {
     ex$message( msgnumb = SM_E_PlNeedName, buff = my_msg); 
     FIg_set_text(form,FI_MSG_FIELD,my_msg);
     return 0;
   }

  if(command_type == MODIFY)
   {
     if(strcmp(old_param_buf->name,param_buf->name))
      {
	char old_name[DI_PATH_MAX],new_name[DI_PATH_MAX];

	status = om$send(msg = message GRvg.GRgetname
			 (&msg,old_name),
			 senderid = NULL_OBJID,
			 targetid = mac->objid,
			 targetos = mac->osnum);
	di$split(pathname = old_name,dirname = new_name);
	DIstmcat(new_name,param_buf->name,NULL);
	status = di$translate(objname = new_name,
			      p_objid = &tmp_obj.objid);
	if(status == DIR_S_SUCCESS)
	 {
	   ex$message(msgnumb = SM_E_PlSameName,buff = my_msg);
	   FIg_set_text(form,FI_MSG_FIELD,my_msg);
	   return 0;
	 }
      }
   }
  else
   { 
     status =  di$translate(objname = param_buf->name,
			    p_objid = &tmp_obj.objid);
			 
     if(status == DIR_S_SUCCESS)
      {
	ex$message( msgnumb = SM_E_PlSameName, buff = my_msg); 
	FIg_set_text(form,FI_MSG_FIELD,my_msg);
	return 0;
      }
   }

  if(!PlGetPlaneSize(form,&param_buf->size)) return 0;
  if(!PlGetDist(form,&param_buf->dist)) return 0;
  PlGetAxis(form,&param_buf->axis);   
  PlGetJustif(form,param_buf->justif);

  FIg_get_state(form,ORIENTATION_TOGGLE,&state);
  if(state) param_buf->rev = TRUE; else param_buf->rev = FALSE;
 
  param_buf->annot[0] = '\0';
  FIg_get_text(form,ANNOTATION_FIELD,param_buf->annot);
   
  return 1;
}     

/* ------------------ static void PlSetJustif ------------------ */
/* Set justification in the form corresponding to justif string  */

static void PlSetJustif(form,justif)
Form  form;       /* [I] */
char *justif;     /* [I] */
{
  FIg_set_state_off(form,NN_BUTTON);
  FIg_set_state_off(form,NC_BUTTON);
  FIg_set_state_off(form,NP_BUTTON);
  FIg_set_state_off(form,CN_BUTTON);
  FIg_set_state_off(form,CC_BUTTON);
  FIg_set_state_off(form,CP_BUTTON);
  FIg_set_state_off(form,PN_BUTTON);
  FIg_set_state_off(form,PC_BUTTON);
  FIg_set_state_off(form,PP_BUTTON);
  if(justif[0] == 'N' && justif[1] == 'N') FIg_set_state_on(form,NN_BUTTON);
  if(justif[0] == 'N' && justif[1] == 'C') FIg_set_state_on(form,NC_BUTTON);
  if(justif[0] == 'N' && justif[1] == 'P') FIg_set_state_on(form,NP_BUTTON);
  if(justif[0] == 'C' && justif[1] == 'N') FIg_set_state_on(form,CN_BUTTON);
  if(justif[0] == 'C' && justif[1] == 'C') FIg_set_state_on(form,CC_BUTTON);
  if(justif[0] == 'C' && justif[1] == 'P') FIg_set_state_on(form,CP_BUTTON); 
  if(justif[0] == 'P' && justif[1] == 'N') FIg_set_state_on(form,PN_BUTTON);
  if(justif[0] == 'P' && justif[1] == 'C') FIg_set_state_on(form,PC_BUTTON);
  if(justif[0] == 'P' && justif[1] == 'P') FIg_set_state_on(form,PP_BUTTON);
}

/* ------------------ static void PlSetPlaneSize ------------------ */
/* Given a value for plane size display the it in gadget            */

static void PlSetPlaneSize(form,value) 
Form       form;     /* [I]                                    */
IGRdouble  value;    /* [I] The value to put in the size field */
{
  char      list_str[20];
  IGRdouble size;

  switch((int)value)
   {
   case 0 : strcpy(list_str,"Regular");
     size = NO_VALUE;
     break; 
   case -1 : strcpy(list_str,"Small");
     size = NO_VALUE;
     break; 
   case -2 : strcpy(list_str,"Large");
     size = NO_VALUE;
     break; 
   default: strcpy(list_str,"Ems");
     size = value;
   }
  FIg_set_text(form,SIZE_LIST,list_str);
  if(value != 0.0 && value != -1.0 && value != -2.0)
   {
     SMConvDistIntExt(value,&size,2);
     PlDisplayDoubleField(form,SIZE_FIELD,size);
   }
  else
    FIg_erase(form,SIZE_FIELD);
}


/* -------------------- method form_notification  ------------------ */

method form_notification (int form_label; int gadget_label ; double value ;
			    char * form_ptr)
{
  int  status = OM_S_SUCCESS;
  long test;
  char size_string[20];
      
  if ( form_ptr == NULL )
   {
     /*| no form_ptr set */
     return( OM_E_INVARG ); 
   }
  
  FIg_set_text(me->forms[0].form_ptr,FI_MSG_FIELD,"");
  
  switch( gadget_label )
   {
   case FI_ACCEPT:
     status = om$send(msg = message SMCmdSglPl.save_all(&test),
		      targetid = my_id);
     if(!(status & test & 1))
      { 
	FIg_set_state_off(me->forms[0].form_ptr,FI_ACCEPT);
	goto quit;
      }   
     _put_response(resp = TERMINATE);
     break;
      
   case FI_CANCEL: 
     _put_response(resp = TERMINATE);
     break;
     
   case FI_RESET:
     switch(me->mytype)
      {
      case PLACE:
	status = om$send(msg = message SMCmdSglPl.reset_all(&test),
			 targetid = my_id);
	break;
      case MODIFY:
	FIg_disable(me->forms[0].form_ptr,LOADC_BUTTON);
	_put_response(resp = PL_RELOCATE);
	break;
      }
     break;

   case FI_EXECUTE:
     status = om$send(msg = message SMCmdSglPl.save_all(&test),
		      targetid = my_id);
     
     if(!(status & test & 1))
      {
	FIg_set_state_off(me->forms[0].form_ptr,FI_EXECUTE);
	goto quit;
      }
     FIg_set_state_off(me->forms[0].form_ptr,FI_EXECUTE);
     break;
     
   case LOADC_BUTTON: 
     PlChangeStateGadget(me->forms[0].form_ptr,FALSE,me->mytype);
     _put_response( resp = LOADC );
     break;
     
   case NAME_FIELD:
     FIg_get_text(me->forms[0].form_ptr,NAME_FIELD,me->param_buf.name);
     break;
     
   case CS_BUTTON:
      /* Desactivate all the gadget */
      PlChangeStateGadget(me->forms[0].form_ptr,FALSE,me->mytype);
   
      /* Higlight the old(s) choosen coordinate system */   
      status = om$send(msg = message SMCmdSglPl.DisplayCs(&test,GRhd),
		       targetid = my_id);
			         
      _put_response(resp = COORDINATE); 
      break;
     
   case ORIENTATION_TOGGLE:
     FIg_get_state(form_ptr,ORIENTATION_TOGGLE,&me->param_buf.rev);
     break;                    
     
   case SIZE_LIST: 
     FIg_get_text(form_ptr,SIZE_LIST,size_string);
     
     if(strcmp(size_string,EMS_STRING) == 0)
      {
	test = PlDisplayDoubleField(form_ptr,SIZE_FIELD,NO_VALUE);
	
	if(test != SUCC)
	 {
	   printf("error PlDisplayDoubleField in  form\n"); 
	   _put_response(resp = TERMINATE);
	   goto quit;      
	 }
      }
     else 
       FIg_erase(form_ptr,SIZE_FIELD);
     
     break;
     
   case SIZE_FIELD: 
     break; 

   case X_BUTTON:
     FIg_set_text(form_ptr,JUSTIF1_FIELD,"y");
     FIg_set_text(form_ptr,JUSTIF2_FIELD,"z");
     break;
     
   case Y_BUTTON:
     FIg_set_text(form_ptr,JUSTIF1_FIELD,"z");
     FIg_set_text(form_ptr,JUSTIF2_FIELD,"x");
     break;
   
   case Z_BUTTON:
     FIg_set_text(form_ptr,JUSTIF1_FIELD,"x");
     FIg_set_text(form_ptr,JUSTIF2_FIELD,"y");
     break;

   } /* END switch ( gadget_label ) */
  
  
 quit:
  return OM_S_SUCCESS;
}


/* ------------------ method init  --------------------------------- */
/* Init all the parameter for the main form                          */
/* If PLACE command all the default variable are initialized         */
/* If MODIFY the control_plane method will initialise the parameters */

method init (int type; char * str_ptr)
{
  IGRint status = OM_S_SUCCESS;
  char   name[DI_PATH_MAX];
  char   base_name[80];
  int    test;

  status     = om$send(targetid = my_id,
		       mode   = OM_e_wrt_message,
		       msg    = message CEO_LOCATE.init( type, str_ptr ) );
  as$status( action = RET_STATUS );

  if(x_form != -1 && y_form != -1)
    FIf_set_location(me->forms[0].form_ptr,x_form,y_form); 
   
  me->mac.objid = NULL_OBJID;
  me->cs[0].objid = NULL_OBJID;
  FIg_set_state_off(me->forms[0].form_ptr,LOADC_BUTTON);
  switch(me->mytype)
   {
   case PLACE :

     strcpy(base_name,"Plane_0");
     PlGenerDefName(base_name,me->old_param_buf.name);
     FIg_set_text(me->forms[0].form_ptr,NAME_FIELD,me->old_param_buf.name);
    
     me->old_param_buf.axis = 'x';
     PlSetAxis(me->forms[0].form_ptr,'x');

     strcpy(me->old_param_buf.annot,"$0");
     FIg_set_text(me->forms[0].form_ptr,ANNOTATION_FIELD,"$0");

     strcpy(me->old_param_buf.justif,"CC");
     PlSetJustif(me->forms[0].form_ptr,"CC");

     me->old_param_buf.rev = FALSE;
     FIg_set_state_off(me->forms[0].form_ptr,ORIENTATION_TOGGLE);
    
     me->old_param_buf.dist = 0.0;
     FIg_set_text(me->forms[0].form_ptr,DIST_FIELD,"0");
    
     me->old_param_buf.size = 0;
     PlSetPlaneSize(me->forms[0].form_ptr,me->old_param_buf.size);
   
     /* Get current active coordinate system */
     ex$get_cur_mod(osnum = &me->cs[0].osnum);
     status = cs$get_active_info( msg = &test,
				 osnum = me->cs[0].osnum,
				 objid = &me->cs[0].objid);
     as$status(action = RET_STATUS);			
     SMGetSplitName(&me->cs[0],name);
     FIg_set_text(me->forms[0].form_ptr,CS_FIELD,name);
 
     as$make_source(go_grid = me->cs[0],
		    mod_env = &me->ModuleInfo,
		    as_os   = me->ModuleInfo.md_id.osnum,
		    as_grid = &me->cs[0]);

     me->nb_cs = me->old_nb_cs = 1;
     me->old_cs[0] = me->cs[0];
  
     me->cs_env[0] = me->ModuleInfo;
     me->old_cs_env[0] = me->ModuleInfo;
     break;
     
   case MODIFY :
     FIg_set_text(me->forms[0].form_ptr,F_TITLE,"Modify Plane");
     FIg_disable(me->forms[0].form_ptr,LOADC_BUTTON);
     me->old_nb_cs = me->nb_cs = 1;
     break;
   }

  return OM_S_SUCCESS;
}


/* ------------------ method reset_all -------------------------- */
/* Reset the form : call only in the PLACE command                */
/* In the MODIFY we relocate a new single plane                   */

method reset_all( long * sts )
{
  char cs_name[DI_PATH_MAX];
  int  i;

  FIg_set_text(me->forms[0].form_ptr,NAME_FIELD,me->old_param_buf.name);
  FIg_set_state(me->forms[0].form_ptr,ORIENTATION_TOGGLE,me->old_param_buf.rev);
  PlSetPlaneSize(me->forms[0].form_ptr,me->old_param_buf.size);
  PlSetAxis(me->forms[0].form_ptr,me->old_param_buf.axis);
  FIg_set_text(me->forms[0].form_ptr,ANNOTATION_FIELD,me->old_param_buf.annot);
  PlSetDist(me->forms[0].form_ptr,me->old_param_buf.dist);
  PlSetJustif(me->forms[0].form_ptr,me->old_param_buf.justif);

  me->nb_cs = me->old_nb_cs;
  if(me->old_nb_cs > 1)
   {
     FIg_set_text(me->forms[0].form_ptr,CS_FIELD,"defined");
     for(i=0; i<me->old_nb_cs; i++)
      {
	me->cs[i]     = me->old_cs[i];
	me->cs_env[i] = me->old_cs_env[i];
      }
   }
  else
   {
     SMGetSplitName(&me->old_cs[0],cs_name);
     FIg_set_text(me->forms[0].form_ptr,CS_FIELD,cs_name);
     me->cs[0]     = me->old_cs[0];
     me->cs_env[0] = me->old_cs_env[0];
   }

  *sts = MSSUCC;
  return OM_S_SUCCESS;
}


/* ------------------ method control_plane --------------------------------- */
/* Method to control and retrieve information when a single plane is loaded  */
/* It can be loaded with loaded component button so only retreive values and */
/* put them in the form or for modify command and then  put default value    */

method control_plane( long *sts )
{
  int               status;
  int               test;
  IGRlong           msg;
  struct GRid       roots[NB_TMP]; /* roots of a SMInfPlane */
  int               count;
  char              name[DI_PATH_MAX];
  struct ret_struct ret_struct;
  IGRdouble         value;
  struct GRid       go;

  dp$erase_hilite(msg = sts);  
  
  /* Enable all the gadget if form is displayed ( call by LOADC_BUTTON ) */
  FIf_is_displayed(me->forms[0].form_ptr,&test);
  if(test)
   { 
     FIg_set_state_off(me->forms[0].form_ptr,LOADC_BUTTON);
     PlChangeStateGadget(me->forms[0].form_ptr,TRUE,me->mytype);
   }
  
  me->mac = me->event1.located_object[0].located_obj;
  
  status = om$send(msg = message NDnode.NDget_objects
		   (ND_ROOT,roots,NB_TMP,NULL,0,NB_TMP,&count),
		   senderid = NULL_OBJID,
		   targetid = me->mac.objid,
		   targetos = me->mac.osnum );
  if(status != OM_S_SUCCESS || count != NB_TMP){
	if( count != NB_TMP ){
		UI_status( "Exit Command: Infinite Plane has no Parents" );
	}
	*sts = MSFAIL;
	return  OM_S_SUCCESS;
  }
 
  /* The cs is template 0*/
  me->cs[0] = roots[0];
  me->nb_cs = 1;

  /* retrieve module env of the cs or plane */
  status = om$send(msg = message NDnode.ASreturn_go
		   (&go,&me->cs_env[0].md_env.matrix_type,
		    me->cs_env[0].md_env.matrix),
		   targetid = me->cs[0].objid,
		   targetos = me->cs[0].osnum);
  as$status(action = RET_STATUS);

  me->cs_env[0].md_id.osnum = go.osnum;
  status =ex$get_modid(mod_osnum = me->cs_env[0].md_id.osnum,
		       mod_id    = &me->cs_env[0].md_id.objid);
  as$status(action = RET_STATUS);

  SMGetSplitName(&me->cs[0],name);
  FIg_set_text(me->forms[0].form_ptr,CS_FIELD,name);

  /* Remember the cs in case modify */
  if(me->mytype == MODIFY)
   {
     me->old_cs[0] = me->cs[0];
     me->old_nb_cs = me->nb_cs;
     me->old_cs_env[0] = me->cs_env[0];
   }
  
  /* The axis is template 1 */
  status = om$send(msg = message NDnode.NDgive_structure
		   (&msg,&ret_struct,&me->ModuleInfo),
		   targetid = roots[1].objid,
		   targetos = roots[1].osnum);
  as$status(action = RET_STATUS);	   
  if(!(msg & 1)) return status;
  PlSetAxis(me->forms[0].form_ptr,ret_struct.var.text_st.text_string[0]);
  if(me->mytype == MODIFY)
    me->old_param_buf.axis = ret_struct.var.text_st.text_string[0];
  
  /* The dist on axis is template 2 */
  status = om$send(msg = message expression.NDgive_value(&value),
		   targetid = roots[2].objid,
		   targetos = roots[2].osnum);
  as$status(action = RET_STATUS);
  PlSetDist(me->forms[0].form_ptr,value);

  if(me->mytype == MODIFY) me->old_param_buf.dist = value;
  
  /* The plane size is template 3 */
  status = om$send(msg = message expression.NDgive_value(&value),
		   targetid = roots[3].objid,
		   targetos = roots[3].osnum);
  as$status(action = RET_STATUS);
  PlSetPlaneSize(me->forms[0].form_ptr,value);
  if(me->mytype == MODIFY) me->old_param_buf.size = value; 

  /* The annotation is template 4 */
  status = om$send(msg = message NDnode.NDgive_structure
		   (&msg,&ret_struct,&me->ModuleInfo),
		   targetid = roots[4].objid,
		   targetos = roots[4].osnum);
  as$status(action = RET_STATUS);	   
  if(!(msg & 1)) return status;
  FIg_set_text(me->forms[0].form_ptr,ANNOTATION_FIELD,
	       ret_struct.var.text_st.text_string);
  if(me->mytype == MODIFY)
    strcpy(me->old_param_buf.annot,ret_struct.var.text_st.text_string);

  /* The reverse is template 5 */
  status = om$send(msg = message expression.NDgive_value(&value),
		   targetid = roots[5].objid,
		   targetos = roots[5].osnum);
  as$status(action = RET_STATUS);
  FIg_set_state(me->forms[0].form_ptr,ORIENTATION_TOGGLE,(int)value);
  if(me->mytype == MODIFY) me->old_param_buf.rev = (int)value; 

  /* The justification is template 6 */
  status = om$send(msg = message NDnode.NDgive_structure
		   (&msg,&ret_struct,&me->ModuleInfo),
		   targetid = roots[6].objid,
		   targetos = roots[6].osnum);
  as$status(action = RET_STATUS);	   
  if(!(msg & 1)) return status;
  PlSetJustif(me->forms[0].form_ptr,ret_struct.var.text_st.text_string);
  if(me->mytype == MODIFY)
    strcpy(me->old_param_buf.justif,ret_struct.var.text_st.text_string);

  /* Get the name of the occurrence */
  /* Modification of 24/March/93 : Don't load name if load by componant */

  if(me->mytype == MODIFY)
   {
     status = om$send(msg = message GRvg.GRgetname(&msg,name),
		      targetid = me->mac.objid,
		      targetos = me->mac.osnum);
     as$status(action = RET_STATUS);
     if(!(msg & 1)) return status;
     
     di$split(pathname = name, name = me->param_buf.name);

     FIg_set_text(me->forms[0].form_ptr,NAME_FIELD,me->param_buf.name);
     FIfld_set_default_text(me->forms[0].form_ptr,NAME_FIELD,0,0,
			    me->param_buf.name,0);
     strcpy(me->old_param_buf.name,me->param_buf.name);
   }

  *sts = MSSUCC;
  return OM_S_SUCCESS;
}

/* ----------------------- method coord_syst ----------------------- */
/* Find the locate coordinate system and  retrieve his name          */

method coord_syst( long * sts )
{
  IGRint             status = OM_S_SUCCESS;
  struct GRobj_env  *LocatedObjects;
  char               name_cs[DI_PATH_MAX];
  int                nb_obj;
  int                i;

  LocatedObjects = NULL;
  as$start_fence(set= &me->event1.located_object[0].located_obj,
                 set_env = &me->event1.located_object[0].module_info,
                 nb_obj = &nb_obj,
                 p_obj_env = &LocatedObjects, 
                 response = me->response, 
                 response_data = me->response_data);

  if(nb_obj == 0)
   {
     /*"No obj selected\n",nb_obj*/
     *sts = BAD_LOCATED;
     goto quit;
   }

  /* If it's a modify command, only one cs is consider */
  if(nb_obj == 1 || me->mytype == MODIFY)
   {
     SMGetSplitName(&LocatedObjects[0].obj_id,name_cs);  
     FIg_set_text(me->forms[0].form_ptr,CS_FIELD,name_cs);
     nb_obj = 1;
   }
  else
   {
     FIg_set_text(me->forms[0].form_ptr,CS_FIELD,"defined");
     if(nb_obj > om$dimension_of( varray = me->cs))
      {
	om$vla_set_dimension(varray = me->cs,size = nb_obj);
	om$vla_set_dimension(varray = me->cs_env,size = nb_obj);
	me->nb_cs = nb_obj;  
      }
   }

  for(i = 0; i < nb_obj ; i++)
   {
     status = as$make_source(go_grid = LocatedObjects[i].obj_id,
			     mod_env = &LocatedObjects[i].mod_env,
			     as_os   = me->ModuleInfo.md_id.osnum,
			     as_grid = &me->cs[i]);
     as$status(action = RET_STATUS);
     me->cs_env[i] = LocatedObjects[i].mod_env;
   }       

  ASend_fence();  
  /* Return to the normal state */
  om$send(msg = message SMCmdSglPl.make_selectable(sts),
	  targetid = my_id);
  
  *sts = OM_S_SUCCESS;
 quit:
  return OM_S_SUCCESS;
}

/* ------------------ method make_selectable ---------------------------- */
/* When quit the coordinate system research , restablish a "normal" state */  

method make_selectable(long *sts)
{
  IGRlong msg;
  
  dp$erase_hilite(msg = &msg);
  FIg_set_state_off(me->forms[0].form_ptr,CS_BUTTON);
  FIg_set_state_off(me->forms[0].form_ptr,LOADC_BUTTON);
  PlChangeStateGadget(me->forms[0].form_ptr,TRUE,me->mytype);

  *sts = MSSUCC;
  return OM_S_SUCCESS;
}

/* ------------------ method save_all --------------------------------- */
/*        Retrieve parameters in the forms                              */
/*        Call the place or modify function                             */

method save_all(long *sts )
{
  int  i;
  char my_msg[MY_MSG_LEN];

  if(!PlTestParameter(me->forms[0].form_ptr,&me->mac,&me->param_buf,
		      &me->old_param_buf,me->mytype))
   {*sts = MSFAIL; goto quit;}
   
  switch(me->mytype)
   {
   case PLACE:
     if(!SMPlaceSingPlane(&me->param_buf,me->cs,me->nb_cs,&me->ModuleInfo))
      {
        ex$message(msgnumb = SM_E_PlBadPl,buff = my_msg);
	FIg_set_text(me->forms[0].form_ptr,FI_MSG_FIELD,my_msg);
	*sts = MSFAIL; 
	goto quit;
      }
     else
      {
        /* Now save the parameter as old parameter */
       	me->old_param_buf = me->param_buf;
	PlGenerDefName(me->param_buf.name,me->old_param_buf.name);
	FIg_set_text(me->forms[0].form_ptr,NAME_FIELD,me->old_param_buf.name);
	FIfld_set_default_text(me->forms[0].form_ptr,NAME_FIELD,0,0,
			       me->old_param_buf.name,0);
	me->old_nb_cs     = me->nb_cs;
	if(me->nb_cs > om$dimension_of( varray = me->old_cs))
	 {
	   om$vla_set_dimension(varray = me->old_cs,size = me->nb_cs);
	   om$vla_set_dimension(varray = me->old_cs_env,size = me->nb_cs);
	 } 
	for(i=0;i<me->nb_cs;i++)
	 {
	   me->old_cs[i]        = me->cs[i];
	   me->old_cs_env[i]    = me->cs_env[i];
	 } 
      }          
     break;
     
   case MODIFY:
     if(!SMModSingPlane(&me->mac,&me->param_buf,me->cs,
			&me->old_param_buf,me->old_cs,&me->ModuleInfo))
      {
        ex$message( msgnumb = SM_E_PlBadMod, buff = my_msg);
        FIg_set_text(me->forms[0].form_ptr,FI_MSG_FIELD,my_msg);
        *sts = MSFAIL;
        goto quit;
      }
     else 
      {
   	/* Save the parameter as old parameter */
   	me->old_param_buf = me->param_buf;
	me->old_nb_cs     = me->nb_cs;
	me->old_cs[0]     = me->cs[0];
	me->old_cs_env[0] = me->cs_env[0];   
      }
     break; 
   }
  *sts = MSSUCC;
  
 quit:
  return OM_S_SUCCESS;
}

/* ------------------ method form_delete ------------------ */

method form_delete(long *sts) 
{
   FIf_get_location(me->forms[0].form_ptr,&x_form,&y_form);
   dp$erase_hilite(msg = sts);
   *sts = MSSUCC;
   return OM_S_SUCCESS;
}

end implementation SMCmdSglPl;



