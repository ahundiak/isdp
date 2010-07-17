/* $Id: VLctrLinei.I,v 1.1.1.1 2001/01/04 21:11:28 cvs Exp $  */

/*************************************************************************
 * I/LOFT
 *
 * File:	VLinteg/src/mrkLine / VLctrLinei.I
 *
 * Description:	control line methods.
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VLctrLinei.I,v $
 *	Revision 1.1.1.1  2001/01/04 21:11:28  cvs
 *	Initial import to CVS
 *	
# Revision 1.1  1998/04/30  10:32:50  pinnacle
# LOFT 2.5.1
#
# Revision 1.1  1997/05/08  14:05:56  pinnacle
# Loft 250
#
# Revision 1.5  1997/04/07  13:15:20  pinnacle
# Replaced: src/mrkLine/VLctrLinei.I for: File header added by mfournie for loft
#
 *
 * History:
 *	MM/DD/YY   AUTHOR	DESCRIPTION
 *	04/04/97   mf		call vl$controLine().
 *	04/07/97   mf		header creation.
 *************************************************************************/
class implementation VLctrLine;

#include	"AS_status.h"
#include	"grmacros.h"
#include	"bsparameters.h"
#include	"DIdef.h"
#include	"expression.h"
#include	"vsplatedef.h"
#include	"asmacros.h"
#include 	"ACrg_collect.h"
#include 	"igr.h"
#include 	"ACattrib.h"
#include 	"nddef.h"
#include 	"vds.h"
#include        "vsmiscmacros.h"
#include 	"vlmsg.h"
#include	"vlstructure.h"
#include	"vlcntrline.h"
#include        "vlcontmacros.h"

from ACrg_collect import AClist_attribute;
from ACrg_collect import ACadd_list_attribute;
from ACrg_collect import ACset_list_attribute;
extern GRclassid OPP_GR3dpoint_class_id;
extern GRclassid OPP_VSimgFeature_class_id;
extern GRclassid OPP_ACrg_collect_class_id;
extern struct GRid NULL_GRID;

/* create vector along axis x, y or z */
static void create_vect(axis,cc) 
IGRdouble *axis; /* O : direction vector */
char   cc;       /* I : direction (x, y or z) */
{

  axis[0] = axis[1] = axis[2] = 0;
  switch (cc) {
    case 'y':
    case 'Y':
      axis[1] = 1.0;
      break;

    case 'z':
    case 'Z':
      axis[2] = 1.0;
      break;

    default:        /* X */
      axis[0] = 1.0;
  }
}

/* construct a point object */
IGRint make_vect  (obj,normal,cst,md_env)
struct GRid  		*obj;     /* O : resulting object */
IGRdouble    		*normal;  /* I : geometry of the future object */
struct  GRvg_construct  *cst;     /* I : I construction list */
struct GRmd_env         *md_env;  /* I : current environment */
{
struct IGRpolyline    geom;
IGRlong               sts;

  cst->env_info  = md_env;
  cst->properties        &=  ~(GRIS_DISPLAYABLE | GRIS_LOCATABLE);
  geom.num_points = 1;
  geom.points     = normal;
  cst->geometry = (char *)&geom;

  obj->osnum = md_env->md_id.osnum;
  sts = om$construct( classid = OPP_GR3dpoint_class_id,
                      osnum   = obj->osnum,
                      p_objid = &obj->objid );
  if (!(sts&1)) {
    return 0;
  }
  sts = om$send( msg = message GRgraphics.GRaltconstruct(cst),
                       senderid   = NULL_OBJID,
                       targetid = obj->objid,
                       targetos = obj->osnum);
  if(!(sts & 1)) {
    return 0;
  }
  return 1;
}

method VLcreate (
               		IGRlong 	*msg; 
               		IGRchar 	axis;
               		IGRchar 	*name;
               		IGRint  	flag;
               		IGRint 		count; 
               struct 	GRobj_env 	*list;
	       		IGRdouble	*normal;
               struct 	GRmd_env	*md_env
              )
{
struct GRid temp[100];
IGRlong status,loc_msg;
IGRint  loc_msg1;
struct ACrg_coll ACrg[20];
int i,j;

  *msg = MSFAIL;
  i = 0;
			/* prepare ACrg collection */
  strcpy(ACrg[i].name,N_ATT_VECT);
  ACrg[i].desc.type = AC_ATTRIB_TEXT;
  ACrg[i].desc.value.att_txt[0] = axis;
  ACrg[i].desc.value.att_txt[1] ='\0';
  i++;
  strcpy(ACrg[i].name,N_ATT_ONE_OR_ALL);
  ACrg[i].desc.type = AC_ATTRIB_DOUBLE;
  ACrg[i].desc.value.att_exp = flag;
  i++;
  strcpy(ACrg[i].name,N_ATT_PLATE_SIDE);
  ACrg[i].desc.type = AC_ATTRIB_TEXT; 
  strcpy(ACrg[i].desc.value.att_txt,name);
  i++;

  strcpy(ACrg[i].name,N_ATT_X_NORMAL);
  ACrg[i].desc.type = AC_ATTRIB_DOUBLE; 
  if (normal == NULL)	ACrg[i].desc.value.att_exp = 0.0;
  else			ACrg[i].desc.value.att_exp = normal[0];
  i++;
  
  strcpy(ACrg[i].name,N_ATT_Y_NORMAL);
  ACrg[i].desc.type = AC_ATTRIB_DOUBLE; 
  if (normal == NULL)	ACrg[i].desc.value.att_exp = 0.0;
  else			ACrg[i].desc.value.att_exp = normal[1];
  i++;
  
  strcpy(ACrg[i].name,N_ATT_Z_NORMAL);
  ACrg[i].desc.type = AC_ATTRIB_DOUBLE; 
  if (normal == NULL)	ACrg[i].desc.value.att_exp = 0.0;
  else			ACrg[i].desc.value.att_exp = normal[2];
  i++;

  temp[IDX_CL_BOX].osnum = md_env->md_id.osnum;
  status = om$construct(classid = OPP_ACrg_collect_class_id,
                        osnum   = temp[IDX_CL_BOX].osnum,
                        p_objid = &temp[IDX_CL_BOX].objid);
  om$send( msg = message NDnode.NDchg_state(ND_DEL_NO_CH, ND_DEL_NO_CH ),
           targetid = temp[IDX_CL_BOX].objid,
           targetos = temp[IDX_CL_BOX].osnum );
  status = om$send(msg = message ACrg_collect.ACadd_list_attribute
                   (&loc_msg, i, ACrg),
                   targetid = temp[IDX_CL_BOX].objid,
                   targetos = temp[IDX_CL_BOX].osnum);
  if(!(status & loc_msg & 1)) {
    goto quit;
  }

  for (j=0,i=IDX_CL_PLATES; j<count; j++,i++)
  {
   as$make_source( go_grid = list[j].obj_id,
                    mod_env = &list[j].mod_env,
                    as_os = md_env.md_id.osnum,
                    as_grid = &temp[i]);
  }
  status = om$send(  msg  = message ACncpx.ACmplace(
                                          &loc_msg1,
                                          AChdr_noprotect | AChdr_nodisplay, 0,
                                          MACRO_CL_LINE,
                                          IDX_CL_PLATES + count,
                                          temp,
                                          md_env ),
                          targetid = my_id);
  if (!(status&loc_msg1&1)) {
    goto quit;
  }

  *msg = MSSUCC;
quit :
  return 1;
}

method VLget_attributes(IGRlong *msg; IGRchar *plate_side; 
                      IGRint *one_or_all; IGRchar *axis;
		      struct GRid *box)
{
struct GRid	temp_list[MACRO_CL_FTEMP + MACRO_CL_VTEMP+1];
IGRint		j,nb,nb_temp;
IGRlong 	status,loc_msg;
struct ACrg_coll list_att[20];

  *msg = MSFAIL;
  status = om$send(msg = message NDnode.NDget_objects(
					      ND_ROOT,temp_list,
					      MACRO_CL_FTEMP + MACRO_CL_VTEMP+1,
                                              NULL, NULL,
                                              OM_K_MAXINT, &nb_temp),
                               targetid = my_id);
  if (!(status&1)) {
    goto quit;
  }

  status = om$send(msg = message ACrg_collect.AClist_attribute
                                                 (&loc_msg,20,list_att,&nb),
                       targetid = temp_list[IDX_CL_BOX].objid,
                       targetos = temp_list[IDX_CL_BOX].osnum);
  if (!(status&loc_msg&1)) {
    goto quit;
  }
  if (box != NULL) *box = temp_list[IDX_CL_BOX];

  if (plate_side != NULL) {
    if ((j=VLseekFields(list_att,nb,N_ATT_PLATE_SIDE)) != -1) {
      strcpy(plate_side,list_att[j].desc.value.att_txt);
    }
  }
  if (one_or_all != NULL) {
    if ((j=VLseekFields(list_att,nb,N_ATT_ONE_OR_ALL)) != -1) {
      *one_or_all = list_att[j].desc.value.att_exp;
    }
  }
  if (axis != NULL) {
    if ((j=VLseekFields(list_att,nb,N_ATT_VECT)) != -1) {
      *axis = list_att[j].desc.value.att_txt[0];
    }
  }

*msg = MSSUCC;
quit :
  return 1;
}

method VLget_surf (IGRlong *msg; struct GRobj_env *listobj; IGRint *nbobj)
{
IGRint		i,nb_temp,j;
struct GRid	temp_list[MACRO_CL_FTEMP + MACRO_CL_VTEMP+1];
IGRlong 	status;

  *msg = MSFAIL;
  status = om$send(msg = message NDnode.NDget_objects(
                                              ND_ROOT,temp_list,
                                              MACRO_CL_FTEMP + MACRO_CL_VTEMP+1,
                                              NULL, NULL,
                                              OM_K_MAXINT, &nb_temp),
                               targetid = my_id);
  if (!(status&1)) {
    goto quit;
  }
  if (listobj != NULL) {
    for (i=IDX_CL_PLATES,j=0; i < nb_temp; i++,j++)
    {
      listobj[j].obj_id = temp_list[i];
    }
  }
  *nbobj = nb_temp - IDX_CL_PLATES;
  *msg = MSSUCC;
quit :
  return 1;
}

method VLset_attributes(IGRlong *msg; IGRchar *plate_side;
                      IGRint one_or_all; IGRchar axis; struct GRid *box)
{
int i;
struct ACrg_coll         ACrg[10];
IGRlong			 loc_msg,status;

  *msg = MSFAIL;
  i = 0;
  strcpy(ACrg[i].name,N_ATT_VECT);
  ACrg[i].desc.type = AC_ATTRIB_TEXT;
  ACrg[i].desc.value.att_txt[0] = axis;
  ACrg[i].desc.value.att_txt[1] ='\0';
  i++;
  strcpy(ACrg[i].name,N_ATT_ONE_OR_ALL);
  ACrg[i].desc.type = AC_ATTRIB_DOUBLE;
  ACrg[i].desc.value.att_exp = one_or_all;
  i++;
  strcpy(ACrg[i].name,N_ATT_PLATE_SIDE);
  ACrg[i].desc.type = AC_ATTRIB_TEXT;
  strcpy(ACrg[i].desc.value.att_txt,plate_side);
  i++;

	/* add by MF */
	strcpy(ACrg[i].name,N_ATT_X_NORMAL);
	ACrg[i].desc.type = AC_ATTRIB_DOUBLE; 
	ACrg[i].desc.value.att_exp = 0.0;
	i++;

	strcpy(ACrg[i].name,N_ATT_Y_NORMAL);
	ACrg[i].desc.type = AC_ATTRIB_DOUBLE; 
	ACrg[i].desc.value.att_exp = 0.0;
	i++;

	strcpy(ACrg[i].name,N_ATT_Z_NORMAL);
	ACrg[i].desc.type = AC_ATTRIB_DOUBLE; 
	ACrg[i].desc.value.att_exp = 0.0;
	i++;

  status = om$send(msg = message ACrg_collect.ACset_list_attribute
                                  (&loc_msg,i,ACrg ),
                    targetid = box->objid,
                    targetos = box->osnum);
  if (!(status&loc_msg&1)) {
    goto quit;
  }
  *msg = MSSUCC; 
quit :
  return 1;
}

method VLset_surf (IGRlong *msg; IGRint old_nb; struct GRid *old_list;
                 IGRint nb; struct GRid *list)
{
IGRlong			 status;

  *msg = MSFAIL;
  status = om$send(msg = message NDnode.NDdisconnect
                                              (old_nb,old_list),
                      targetid = my_id);
  if(!(status & 1)) {
    goto quit;
  }
  status = om$send(msg = message NDnode.NDconnect
                                   (nb,list,NULL_GRID,ND_ADD),
                      targetid = my_id);
  if(!(status & 1)) {
    goto quit;
  }
  *msg = MSSUCC;
quit :
  return 1;
}
/* ========================================================================== */
method ACconstruct_feet ( 		IGRlong		*msg;
			 		IGRint		cn_type;
			 		IGRint		count;
			 struct		GRid		list[];
			 struct		GRmd_env	*md_env;
					IGRint		*fcount;
			 struct		GRid		*feet_list )
{
IGRint			i,j,nb,flag,kill = 0;
IGRlong			sts,loc_msg;
struct ACrg_coll        list_att[20];
IGRdouble		ship_axis[3], norm[3];
struct GRvg_construct 	cst;
char		       *name;
struct BendingLineInfo bendingLine;   
struct GRid            temgrid;     
struct GRobj_env       BendLineObj,*BendObj=NULL;        
struct GRobj_env       list_temp[100],cp_obj;        
OMuword                plate_cl,acpretend_cl,img_cl;          
OMuword                TEMP_cl;          
struct GRobj_env       GObj;

	/* Initialize (MF) */
  	*msg = MSFAIL;
  	om$get_classid ( classname = "VSplate",    p_classid = &plate_cl);
  	om$get_classid(  classname = "ACpretend",  p_classid = &acpretend_cl);
  	om$get_classid(  classname = "VSimgFeature",  p_classid = &img_cl);
  	VLinitCnst(&cst);
  	cst.env_info  = md_env;
	norm[0] = norm[1] = norm[2] = 0.0;

  sts = om$send(msg = message ACrg_collect.AClist_attribute
                                                (&loc_msg,20,list_att,&nb),
                       targetid = list[IDX_CL_BOX].objid,
                       targetos = list[IDX_CL_BOX].osnum);
  if (!(sts&loc_msg&1)) {
    goto quit;
  }
  if ((j=VLseekFields(list_att,nb,N_ATT_VECT)) != -1) {
    create_vect(ship_axis,list_att[j].desc.value.att_txt[0]);
  }
  else {
    goto quit;
  }
  if ((j=VLseekFields(list_att,nb,N_ATT_ONE_OR_ALL)) != -1) {
    flag = list_att[j].desc.value.att_exp;
  }
  else {
    goto quit;
  }
  if ((j=VLseekFields(list_att,nb,N_ATT_PLATE_SIDE)) != -1) {
    name = list_att[j].desc.value.att_txt;
  }
  else {
    goto quit;
  }
  if ((j=VLseekFields(list_att,nb,N_ATT_X_NORMAL)) != -1)
    norm[0] = list_att[j].desc.value.att_exp;
  else	goto quit;
  if ((j=VLseekFields(list_att,nb,N_ATT_Y_NORMAL)) != -1)
     norm[1] = list_att[j].desc.value.att_exp;
  else goto quit;
  if ((j=VLseekFields(list_att,nb,N_ATT_Z_NORMAL)) != -1)
    norm[2] = list_att[j].desc.value.att_exp;
  else	goto quit;

    for (i=IDX_CL_PLATES; i<count; i++)
    {
      list_temp[i].obj_id = list[i];
      list_temp[i].mod_env = *md_env;

      om$get_classid(osnum      = list_temp[i].obj_id.osnum,
                     objid      = list_temp[i].obj_id.objid,
                     p_classid  = &TEMP_cl) ;
  
      /* The following 'if' is to support objects in reference files */
  
      if( om$is_ancestry_valid( superclassid  = acpretend_cl,
                                subclassid    = TEMP_cl ) == OM_S_SUCCESS ) {
        GObj.obj_id.objid = NULL_OBJID;
        sts = om$send( msg  = message NDnode.ASreturn_go(
                                      &GObj.obj_id,
                                      &GObj.mod_env.md_env.matrix_type,
                                      GObj.mod_env.md_env.matrix ),
                        targetid = list_temp[i].obj_id.objid,
                        targetos = list_temp[i].obj_id.osnum );
        if( !( 1 & sts ) ){
          goto quit;
        }
        GObj.mod_env.md_id.osnum = GObj.obj_id.osnum;
        om$get_classid( osnum   = GObj.obj_id.osnum  ,
                        objid   = GObj.obj_id.objid  ,
                        p_classid       = &TEMP_cl      ) ;
      }  /* end if its a reference object */
      else GObj = list_temp[i];
  
          /* Now find out what the real object is a sub class of ***/
  
      if(
          (om$is_ancestry_valid(superclassid  = plate_cl,
                              subclassid    = TEMP_cl ) == OM_S_SUCCESS)  ||
          (om$is_ancestry_valid(superclassid  = img_cl,
                              subclassid    = TEMP_cl ) == OM_S_SUCCESS)
        ) {
        if (!flag) {
        /* Get a side of plate.  */
          sts = om$send( msg  = message NDmacro.ACreturn_foot(
                                       &loc_msg,
                                       name,
                                       &list_temp[i].obj_id,
                                       &list_temp[i].mod_env.md_env.matrix_type,
                                       list_temp[i].mod_env.md_env.matrix ),
                               targetid = GObj.obj_id.objid,
                               targetos = GObj.obj_id.osnum ) ;
          if( !( loc_msg & 1 & sts ) ) {
            printf("CONTINUE : to next located object\n");
            continue;       /* to next located object */
          }
          list_temp[i].mod_env.md_id.osnum = list_temp[i].obj_id.osnum;
/*
          if (GObj.mod_env.md_env.matrix_type != MAIDMX) {
            MAmulmx(&loc_msg,&dim,&dim,&dim,GObj.mod_env.md_env.matrix,
                    list_temp[i].mod_env.md_env.matrix,
                    list_temp[i].mod_env.md_env.matrix);
            MAtypemx( &loc_msg, list_temp[i].mod_env.md_env.matrix,
                      &list_temp[i].mod_env.md_env.matrix_type);
          }
*/

          if (vs$is_ancestry_valid( object   = &GObj.obj_id,
                                    classid = OPP_VSimgFeature_class_id )
                    == TRUE) {
            sts = om$send(msg = message GRgraphics.GRcopy(
                                             &loc_msg,
                                             &list_temp[i].mod_env,
                                             md_env,
                                             &cp_obj.obj_id.objid ),
                             senderid = NULL_OBJID,
                             targetid = list_temp[i].obj_id.objid,
                             targetos = list_temp[i].obj_id.osnum );
            cp_obj.obj_id.osnum = md_env->md_id.osnum;
            cp_obj.mod_env = *md_env;
            if( ! (sts&loc_msg&1)){
               printf( "Error in GRgraphics.GRcopy() ...\n");
               goto quit;
            }
        kill = 1;
      }
      else  cp_obj = list_temp[i];
        }
        else list_temp[i] = GObj;
      }
      else {
        temgrid.objid = NULL_OBJID;
        temgrid.osnum = md_env->md_id.osnum;
        sts = om$send( msg      = message NDnode.ASreturn_go(
                                       &temgrid,
                                       &list_temp[i].mod_env.md_env.matrix_type,
                                       list_temp[i].mod_env.md_env.matrix ),
                          targetid = list_temp[i].obj_id.objid,
                          targetos = list_temp[i].obj_id.osnum );
  
        if ( !( 1 & sts ) ) {
          printf("ERROR in Return Go\n");
          list_temp[i].obj_id = list[i];
          list_temp[i].mod_env = *md_env;
        }
        else{
          list_temp[i].obj_id.objid = temgrid.objid;
          list_temp[i].obj_id.osnum = temgrid.osnum;
          list_temp[i].mod_env.md_id.osnum = temgrid.osnum;
        }
      }
    }
  if (!flag) {
    sts = VLsimpleControLine(&cp_obj,
                             &cst,
                             ship_axis,
                             &bendingLine,
                             BendObj,
                             &loc_msg);
     if ( (loc_msg & 1 & sts ) )
      sts = VLdrawBendLine( &cp_obj, &bendingLine,
                            BendObj, &cst, NULL,
                            &feet_list[IDX_CL_CV], &nb, &loc_msg );
     if ( !(loc_msg & 1 & sts ) ) {
       sts = VLfindBendLineAlg2(&cp_obj,
                                &cst,
                                ship_axis,
                                &bendingLine,
                                &BendLineObj,
                                &loc_msg);
       if (!(sts&loc_msg&1)) {
         goto quit;
       }
       BendObj = &BendLineObj;
      sts = VLdrawBendLine( &cp_obj, &bendingLine,
                            BendObj, &cst, NULL,
                            &feet_list[IDX_CL_CV], &nb, &loc_msg );
      if (!(sts&loc_msg&1)){
        goto quit;
      }
     }
     if (!make_vect(&feet_list[IDX_CL_VECT],bendingLine.normal,&cst,md_env)){
       goto quit;
     }
      if (kill) om$send(msg      = message GRgraphics.GRdelete
                                      ( &loc_msg, md_env ),
                           senderid = NULL_OBJID,
                           targetid = cp_obj.obj_id.objid,
                           targetos = cp_obj.obj_id.osnum );
   }
  else { /* modify by MF : 03-APR-1997 */
	sts = vl$controlLine ( msg	= &loc_msg,
			       num	= count-IDX_CL_PLATES,
			       Plat	= &list_temp[IDX_CL_PLATES],
			       side	= name,
			       Env	= md_env,
			       Axis	= &ship_axis,
			       Norm	= &norm,
			       Info	= &bendingLine,
			       Curv	= &BendLineObj );
	as$status ( sts    = sts,
		    msg    = "vl$controlLine()",
		    test   = (!(sts & 0x00000001 & loc_msg)),
		    action = GOTO_VALUE,
		    value  = quit );

      if (!(loc_msg&1)) {
        goto quit;
      }
      feet_list[IDX_CL_CV] = BendLineObj.obj_id;
      if (!make_vect(&feet_list[IDX_CL_VECT],bendingLine.normal,&cst,md_env)) {
        goto quit;
      }
  }
  *fcount = 2;
  *msg = MSSUCC;
quit :
  return 1;
}
method VDgetObjDef( long *msg ; VDobjDef *myDef ) {

        long            sts ;   /* OM return code       */

        /*
         * name.
         */
        myDef->info             = VL_I_ObjControlLine;
        myDef->type             = 0 ;

        sts     = OM_S_SUCCESS ;
        *msg    = MSSUCC ;

        return sts ;
} /* method VDgetObjdDef */
/*----------------------------------------------------------------------------*/

end implementation VLctrLine;
