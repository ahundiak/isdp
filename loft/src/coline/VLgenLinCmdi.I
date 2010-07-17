class implementation VLgenLinCmd;

#include <stdio.h>
#include "FI.h"
#include "OMmacros.h"
#include "griomacros.h"
#include "dpmacros.h"
#include "asmacros.h"
#include "macro.h"
#include "griodef.h"
#include "growner.h"
#include "vlglinedef.h"
#include "AS_status.h"
#include "ACrg_collect.h"
#include "coparamac.h"
#include "expmacros.h"
#include "expression.h"
#include "exmacros.h"
#include "lcmacros.h"
#include "csmacros.h"
#include "lcdef.h"
#include "ex.h"
#include "grdpbmacros.h"
#include "DItypedef.h"
#include "nddef.h"
#include "ndmacros.h"
#include "vlmsg.h"
#include <math.h>
#include "DIdef.h"
#include "VDSpathdef.h"
#include "VDSudp_mac.h"
#include "vlcogline.h"
#include "vlbutt.h"
#include "vlseam.h"
#define EPS 0.000001

extern GRclassid OPP_VLbutLine_class_id;
extern GRclassid OPP_VLseaLine_class_id;
extern GRclassid OPP_VLwatLine_class_id;
extern GRclassid OPP_GRgencs_class_id;
extern GRclassid OPP_GR3dlineseg_class_id;
extern GRclassid OPP_GR3dpoint_class_id;
extern struct GRid NULL_GRID;
extern VLinitCnst();
extern struct GRid MANwk_hull;

from 	GRvg 		import 	GRcenter;
from 	NDnode 		import 	ASreturn_go,NDget_objects;
from 	GRgraphics 	import 	GRaltconstruct;
from 	NDnode     	import 	NDchg_state;
from 	ACrg_collect	import	AClist_attribute;

static int depcount;
static struct GRid  dep_next[100];

/*************************************************************************/

method VLchaine_locate (int *sts ;long respo ; int gadget1, gadget2, flag)
{
int  status = OM_S_SUCCESS;

long size = sizeof(struct GRevent) - sizeof(long)*2;
long msg;

  if (
      me->event1.subtype == GRst_PREC_WLD ||
      me->event1.subtype == GRst_DELTA_WLD
     ) {
   if (flag) {
     status = om$send(msg = message VLgenLinCmd.VLcontrol_data2((int *)&msg,
							      gadget1,gadget2),
							
                         targetid = my_id);
     if (!(status & msg &1)) {
        ex$message(msgnumb = VL_E_ConsSelPtFail);
        me->ret = *sts = MY_ERROR;
        goto quit;
     }
   }
   else {
     status = om$send(msg = message VLgenLinCmd.VLcontrol_data1((int *)&msg),
                         targetid = my_id);
     if (!(status & msg &1)) {
        ex$message(msgnumb = VL_E_ConsCsFail);
        me->ret = *sts = MY_ERROR;
        goto quit;
      }
   }
   if ( me->event1.subtype == GRst_DELTA_WLD && me->point2 == 1)
     me->ret = *sts =  POINT;
   else
     me->ret = *sts =  MOD;
  }
  else {
    status = ex$putque(msg = &msg,byte=&size,response=(IGRint *)&respo,
                       buffer = (IGRchar *) &me->event1.event);
    if (!(status&msg&1)) {
      ex$message(msgnumb = VL_E_NoEvQue);
      me->ret = *sts = MY_ERROR;
      goto quit;
    }
  }
quit:
  return OM_S_SUCCESS;
}

/*
	Func : VLgetChildren

	Desc :
	       This function returns the list of Next butts/seams which are
	       dependant on the 'object'.
	
	       The childrenList buffer should not be freed by the
	       calling function.
*/

IGRint VLgetChildren (
  struct GRid	*object, 	 // I - Get next butts/seams for this object
  int		*nbChildren,     // O - No. of dependent butts/seams
  struct GRid	**childrenList   // O - List of dependent butts/seams
)

{
  long  sts;

  depcount = 0;

  sts = VLmakeChildrenList ( object );

  *nbChildren = depcount;

  *childrenList = dep_next;

  return sts;

}

IGRint VLmakeChildrenList( struct GRid *object )
{
  struct GRid		list[100],child[100];
  IGRlong		msg,status;
  IGRint		count,cnt,nb,i,j;
  struct ACrg_coll	list_att[20];
  GRclassid		cid;

  status = om$send(msg = message NDnode.NDget_objects(ND_CHILDREN,child,100,
                                                      NULL, NULL,
                                                      OM_K_MAXINT, &count),
				senderid = NULL_OBJID,
                                targetid = object->objid,
                                targetos = object->osnum);
  if (!(status&1)) {
        goto quit;
  }
  om$get_classid( osnum     = object->osnum,
                  objid     = object->objid,
                  p_classid = &cid );

  for(i=0; i<count; ++i)
  {
	GRclassid child_class_id;

        om$get_classid( osnum     = child[i].osnum,
                        objid     = child[i].objid,
                        p_classid = &child_class_id );

        if( om$is_ancestry_valid(subclassid      = child_class_id,
                                 superclassid    = cid             )
                                == OM_S_SUCCESS )
	{
  	   status = om$send(msg = message NDnode.NDget_objects(ND_ROOT,list,
						100, NULL, NULL,
                                                OM_K_MAXINT, &cnt),
				senderid = NULL_OBJID,
                                targetid = child[i].objid,
                                targetos = child[i].osnum);
           if (!(status&1)) {
        	continue;
  	   }

  	   status = om$send(msg = message ACrg_collect.AClist_attribute
                                             (&msg,20,list_att,&nb),
			senderid = NULL_OBJID,
                      	targetid = list[INDEX_ATT_BOX].objid,
                      	targetos = list[INDEX_ATT_BOX].osnum);
  	   if (!(status&1)) {
        	continue;
  	   }
  	   if ((j=VLseekFields(list_att,nb,N_ATT_SELECTOR)) == -1) {
  	        continue;      
	   }

  	   if (    list_att[j].desc.value.att_exp == V_ATT_NEXT
        	|| list_att[j].desc.value.att_exp == V_ATT_DEV  )
	   {
		dep_next[depcount] = child[i];
		++depcount;
		if ( depcount == 100 )
		{
		   printf("VLgetChildren : No. of Next Butts/Seams > 100\n");
		   goto quit;
		}
		status = VLmakeChildrenList(&child[i]);

	   } /* is the dependant butt a next butt */

        } /* if (om$is_ancestry_valid ) */

  } /* for(i=0; i<count; ++i) */

quit: 
	return status;
}

method VLcontrol_obj (int *sts ; int code, gadget1, gadget2)
{
struct GRid		obj;
GRclassid		cid,super;
char			pt_name[250];
int			loc_msg,count,i;
struct GRid		*list,mygrid;
IGRboolean		loop_exists=FALSE;

  obj = me->event1.located_object[0].located_obj;
  FIg_set_text(me->form_ptr,FI_MSG_FIELD,"");

  mygrid.objid = me->to_modify.objid;
  mygrid.osnum = me->to_modify.osnum;

/*
 * Check whether the next butt being selected is not already dependent 
 * on that butt. If so,this will cause a cyclic loop and produces 
 * incorrect results. The below function returns all the next butts which
 * are dependant on the located object.
 */

  VLgetChildren( &mygrid, &count, &list);

  for(i=0; i<count; ++i)
  {
	if(list[i].objid == obj.objid && 
	   list[i].osnum == obj.osnum )
	{
		loop_exists = TRUE;
		break;
	}
  }
	
  if(  loop_exists ||
     ( me->to_modify.objid != NULL_OBJID && 
       me->to_modify.objid == obj.objid && me->to_modify.osnum == obj.osnum ))
  {
  	GRclassid cid;
  	om$get_classid( osnum     = obj.osnum,
                  	objid     = obj.objid,
              	  	p_classid = &cid );
  	if( om$is_ancestry_valid(subclassid      = cid,
	                   	 superclassid    = OPP_VLbutLine_class_id )
				== OM_S_SUCCESS )
  	FIg_set_text(me->form_ptr,FI_MSG_FIELD,"Invalid butt selected");
  	else {
  	if( om$is_ancestry_valid(subclassid      = cid,
                           	 superclassid    = OPP_VLseaLine_class_id )
				== OM_S_SUCCESS )
  	FIg_set_text(me->form_ptr,FI_MSG_FIELD,"Invalid seam selected");    }

  	me->ret = INVALID_BUTT;
  	return OM_S_SUCCESS; 
  }

  /* Verify the located object classe is good to avoid
     errors caused by locating objects by name */

  om$get_classid(osnum = obj.osnum,
		 objid = obj.objid,
		 p_classid = &cid);

  if (!code) super = OPP_VLbutLine_class_id;
   else super = OPP_VLseaLine_class_id;
  if ((om$is_ancestry_valid(subclassid     = cid,
			   superclassid = super)

	     == OM_S_SUCCESS )){
      as$make_source( go_grid = obj,
                      mod_env = &me->event1.located_object[0].module_info,
		      as_os   =me->ModuleInfo.md_id.osnum ,
		      as_grid = &me->previous);
       /*find the object name */
      if(!VLgetName(&obj, pt_name)) strcpy(pt_name,"Defined");
      FIfld_set_text(me->form_ptr,gadget1,0,
		     0, pt_name,FALSE);
  }
  goto quit;
  quit :
    dp$erase_hilite(msg=&loc_msg,
		    objid = me->ModuleInfo.md_id.objid,
		    osnum = me->ModuleInfo.md_id.osnum);
    ASend_fence();
    FIg_set_state_off(me->form_ptr,gadget2);
    me->locate_prev = 0;
    return OM_S_SUCCESS;
}

method VLis_hull_defined (int *sts ; int gadget1)
{
char pt_name[100];
IGRlong status;
struct GRid go_hull;

  if (MANwk_hull.objid != NULL_OBJID) {
    me->hull = MANwk_hull;
    status  = om$send(      msg     = message NDnode.ASreturn_go
                                        ( &go_hull, NULL, NULL ),
                        targetid = me->hull.objid,
                        targetos = me->hull.osnum );
    if( ! (status&1)){
       ex$message(msgnumb = VL_E_BadParent);
       *sts = NO;
       return OM_S_SUCCESS;
    }
    if (!VLgetName(&go_hull, pt_name)) strcpy(pt_name,"Defined");
    FIfld_set_text(me->form_ptr,gadget1,0,
                   0, pt_name,FALSE);
    FIfld_set_default_text(me->form_ptr,gadget1,
                         0,0,pt_name,0,0);
    me->old_hull = me->hull;
    *sts = YES;
  }
  else *sts = NO;
  return OM_S_SUCCESS;
}

method VLcontrol_hull (int *sts ; int gadget1, gadget2, gadget3, code)
{
char			pt_name[250],arr1[100],arr2[100],cur_name[100];
struct GRid		hull;
struct  GRsymbology     symb;
IGRchar                 tar_dir[DI_PATH_MAX];
IGRlong			status;
int 			loc_msg;
IGRlong			msg;

  hull = me->event1.located_object[0].located_obj;

    /* find the object name */
    if (!VLgetName(&hull, pt_name)) strcpy(pt_name,"Defined");

    as$make_source( go_grid = hull,
                    mod_env = &me->event1.located_object[0].module_info,
                    as_os   = me->ModuleInfo.md_id.osnum ,
                    as_grid = &me->hull);
  
    /* put name in the gadget */
    FIfld_set_text(me->form_ptr,gadget1,0,
                   0, pt_name,FALSE);
   FIg_get_text(me->form_ptr,gadget3,pt_name);
   if (pt_name[0] == '\0') {
     switch (code) {
       case 0 :
         strcpy(arr1,"butt");
         strcpy(arr2,"BButt");
         break;
       case 1 :
         strcpy(arr1,"watline");
         strcpy(arr2,"WaterL");
         break;
       case 2 :
         strcpy(arr1,"seam");
         strcpy(arr2,"BSeam");
         break;
       case 3 :
         strcpy(arr1,"butt");
         strcpy(arr2,"CButt");
         break;
       case 4 :
         strcpy(arr1,"seam");
         strcpy(arr2,"CSeam");
         break;
       case 5 :
         strcpy(arr1,"trace");
         strcpy(arr2,"Trace");
         break;
       case 6 :
         strcpy(arr1,"butt");
         strcpy(arr2,"Butt");
         break;
       case 7 :
         strcpy(arr1,"seam");
         strcpy(arr2,"Seam");
         break;
     }

       FIg_get_text(me->form_ptr,gadget3,cur_name);
       if ( cur_name[0] == '\0' ) strcpy( cur_name, arr2 );

       status = om$send(msg = message VLgenLinCmd.VLgetSymbDirName(
                                                          &msg,
                                                          arr1,
                                                          &hull,
                                                          cur_name,
                                                          &symb,
                                                          tar_dir,
                                                          pt_name),
                        targetid = my_id);
      if (!(status&msg&1))
        ex$message(msgnumb = VL_E_BadChgSymb);
      FIfld_set_text(me->form_ptr,gadget3,0,
                     0, pt_name,FALSE);
      FIfld_set_default_text(me->form_ptr,gadget3,0,
                             0, pt_name,FALSE);
   }
  goto quit;
  quit :
    dp$erase_hilite(msg=&loc_msg,
                    objid = me->ModuleInfo.md_id.objid,
                    osnum = me->ModuleInfo.md_id.osnum);
    FIg_set_state_off(me->form_ptr,gadget2);
    me->locate_hull = 0;
    ASend_fence();
    return OM_S_SUCCESS;
}

  /* add one control line in the control lines list */
method VLadd_1_cl_line (int *msg ; struct GRid *obj ; GRclassid super)
{
int 			j;
GRclassid		cid;
struct GRid		tmp;

  *msg = MSFAIL; 
  /* Verify the object is'nt already in the list */ 
  as$make_source( go_grid = *obj,
                  as_os   =me->ModuleInfo.md_id.osnum ,
                  as_grid = &tmp);
  for (j=0; j<me->nb_cl_line;j++)
  {
    if (me->cl_line[j].objid == tmp.objid)
    {
      ex$message(msgnumb = VL_E_ObjInList);
      goto quit;
    }
  }

  if(me->nb_cl_line + 1 > om$dimension_of( varray = me->cl_line))
    om$vla_set_dimension(varray = me->cl_line,size =
                                      me->nb_cl_line + 1);

  om$get_classid(osnum = obj->osnum,
                 objid = obj->objid,
                 p_classid = &cid);

  if ((om$is_ancestry_valid(subclassid     = cid,
                           superclassid = super)
             == OM_S_SUCCESS ) && me->hull.objid != NULL_OBJID){
    as$make_source( go_grid = *obj,
                    as_os   =me->ModuleInfo.md_id.osnum ,
                    as_grid = obj);
    me->cl_line[me->nb_cl_line] = *obj;
  }
  me->nb_cl_line += 1;
   
  *msg = MSSUCC;
  quit :
    return OM_S_SUCCESS;
}

method VLcontrol_cl_line (int *sts ; int code, gadget)
{
struct GRobj_env	*LocatedObjects;
int 			nb_obj,i,j,sel_flag,r_pos;
int			nb_supprim,count,loc_msg;
char			pt_name[100],array[100];
struct GRid		tmp;

  code = code; // to avoid warning messages during compilation 
               // because this argument isn't used
  LocatedObjects = NULL;
  as$start_fence(set= &me->event1.located_object[0].located_obj,
                 set_env = &me->event1.located_object[0].module_info,
                 nb_obj = &nb_obj,
                 p_obj_env = &LocatedObjects,
                 response = me->response,
                 response_data = me->response_data);

  if (nb_obj == 0)
  {
    me->ret = *sts = MY_ERROR;
    ex$message(msgnumb = VL_E_NoObjLoc);
    goto quit;
  }
  /* Verify the located objects aren't already in the list */ 
  nb_supprim = 0;
  for (i=0; i<nb_obj;i++)
  {
    as$make_source( go_grid = LocatedObjects[i].obj_id,
                    mod_env = &LocatedObjects[i].mod_env,
                    as_os   =me->ModuleInfo.md_id.osnum ,
                    as_grid = &tmp);
    for (j=0; j<me->nb_cl_line;j++)
    {
      if (me->cl_line[j].objid == tmp.objid)
      {
        LocatedObjects[i].obj_id.objid = NULL_OBJID;/* it is already here */
        nb_supprim++;
        break;
      }
    }
  }
  if (nb_supprim)
      ex$message(msgnumb = VL_E_ObjSuppr ,type = "%d",var = `nb_supprim`);

  if(nb_obj - nb_supprim + me->nb_cl_line > 
				om$dimension_of( varray = me->cl_line)) {
    om$vla_set_dimension(varray = me->cl_line,size =
                                      nb_obj-nb_supprim+me->nb_cl_line);
  }
  if(nb_obj - nb_supprim + me->nb_cl_line > 
				om$dimension_of( varray = me->num_cl_line)) {
    om$vla_set_dimension(varray = me->num_cl_line,size =
                                      nb_obj-nb_supprim+me->nb_cl_line);
  }

  for (i=0; i<nb_obj; i++) 
  {
    if (LocatedObjects[i].obj_id.objid == NULL_OBJID) continue;
  
      as$make_source( go_grid = LocatedObjects[i].obj_id,
                      mod_env = &LocatedObjects[i].mod_env,
                      as_os   =me->ModuleInfo.md_id.osnum ,
                      as_grid = &LocatedObjects[i].obj_id);
      me->cl_line[i+me->nb_cl_line] = LocatedObjects[i].obj_id;
    /* find the object name */
      if(!VLgetName(&LocatedObjects[i].obj_id,pt_name)) {
        strcpy(pt_name,"Defined");
      }
    /* put name in the gadget */
    FIfld_get_num_rows(me->form_ptr,gadget,&count);
    if (count == 1) {
      FIfld_get_text(me->form_ptr,gadget,0,0,
                     100,array, &sel_flag,&r_pos);
      if (array[0] == '\0') {
        me->num_cl_line[i+me->nb_cl_line] = count-1;
        FIfld_set_text(me->form_ptr,gadget,count-1,
                       0, pt_name,FALSE);
        FIfld_pos_cursor(me->form_ptr,gadget,count-1,0,0,0,0,0);
      }
      else {
        me->num_cl_line[i+me->nb_cl_line] = count;
        FIfld_set_text(me->form_ptr,gadget,count,
                       0, pt_name,FALSE);
        FIfld_pos_cursor(me->form_ptr,gadget,count,0,0,0,0,0);
      }
    }
    else {
      me->num_cl_line[i+me->nb_cl_line] = count;
      FIfld_set_text(me->form_ptr,gadget,count,
                     0, pt_name,FALSE);
      FIfld_pos_cursor(me->form_ptr,gadget,count,0,0,0,0,0);
    }
  }
  me->nb_cl_line += nb_obj - nb_supprim;
   
  quit :
    ASend_fence();
    dp$erase_hilite(msg=&loc_msg,
                    objid = me->ModuleInfo.md_id.objid,
                    osnum = me->ModuleInfo.md_id.osnum);
    return OM_S_SUCCESS;
}

method VLparse_str (int *msg ; char *direction ; struct GRid *obj)
{
IGRdouble	       vect[4],wld[4];
struct GRvg_construct  cst;
struct IGRpolyline    geom;
IGRlong		      status;

  *msg = MSFAIL;
  vect[0] = 0; vect[1] = 0; vect[2] = 0; vect[3] = 0;
  if (direction[0] == '-') {
    if (direction[1] == 'x' || direction[1] == 'X') 
      vect[0] = -1;
    else
      if (direction[1] == 'y' || direction[1] == 'Y') 
          vect[1] = -1;
        else
          if (direction[1] == 'z' || direction[1] == 'Z') 
            vect[2] = -1;
    }
    else {
        if ((direction[0] == 'y' || direction[0] == 'Y') ||
            (direction[0] == '+' &&(direction[1] == 'y' || direction[1] == 'Y'))
           )
           vect[1] = 1;
        else {
        if ((direction[0] == 'x' || direction[0] == 'X') ||
            (direction[0] == '+' &&(direction[1] == 'x' || direction[1] == 'X'))
           )
           vect[0] = 1;
        else {
          if ((direction[0] == 'z' || direction[0] == 'Z') ||
              (direction[0] == '+' &&(direction[1] == 'z' || direction[1] == 'Z'))
             )
             vect[2] = 1;
          else {
            if (!strcmp(direction,"No") || !strcmp(direction,"no")) {
             // we recreate plugs because of problems in ASSOC : the
             // original plug is dead after two disconnect and connect.
                exp$create(exp_name = NULL,
                 	   exp_syntax = "PLUG",
                 	   p_exp_id = &me->al_plug.objid,
                 	   osnum = me->al_plug.osnum,
                 	   type_rq = EXP_TEXT);
  	        om$send( msg  = message NDnode.NDchg_state
                                                 (ND_DEL_NO_CH, ND_DEL_NO_CH),
           			targetid = me->al_plug.objid,
           			targetos = me->al_plug.osnum );
	       *obj = me->al_plug;
            }
            else {
              ex$message(msgnumb = VL_E_BadDir);
              goto quit;
            }
          }
        }
       }
      }
   if (vect[0] != 0 || vect[1] != 0 || vect[2] != 0) {
     if (!VLconvertCoord(&me->ModuleInfo,vect,wld,0)) {
       ex$message(msgnumb = VL_E_BadDir);
       goto quit;
     }
     VLinitCnst(&cst);
     cst.properties &= ~(GRIS_LOCATABLE | GRIS_DISPLAYABLE);
     geom.num_points = 1;
     geom.points = wld;
     cst.geometry = (char *)&geom;
     obj->osnum = me->ModuleInfo.md_id.osnum;
     status = om$construct(classid = OPP_GR3dpoint_class_id,
                           osnum   = obj->osnum,
                           p_objid = &obj->objid );
     if (!(status&1)) {
       ex$message(msgnumb = VL_E_ConsCsFail);
       goto quit;
     }
     status = om$send( msg = message GRgraphics.GRaltconstruct(&cst),
                       targetid = obj->objid,
                       targetos = obj->osnum);
      if(!(status & 1)) {
        ex$message(msgnumb = VL_E_ConsCsFail);
        goto quit;
       }
      as$make_source(go_grid = *obj,
                     as_os   =me->ModuleInfo.md_id.osnum ,
                     as_grid = obj);
      om$send( msg  = message NDnode.NDchg_state(ND_SUP_ONLY, ND_SUP_ONLY),
           targetid = obj->objid,
           targetos = obj->osnum );
   }
      
  *msg = MSSUCC;
quit :
  return OM_S_SUCCESS;
}

 /* when a point is located with a GRst_DELTA_WLD or GRst_PREC_WLD subtype */
method VLcontrol_data1 (int *msg)
{
IGRdouble	wld[4],center[4],vect[3];
struct GRid	tmp;
int		loc_msg;
IGRlong		status;
struct IGRpolyline geom;
struct GRvg_construct  cst;

  *msg = MSFAIL;
  vect[0] = me->event1.event.button.x;
  vect[1] = me->event1.event.button.y;
  vect[2] = me->event1.event.button.z;
  if (me->event1.subtype == GRst_DELTA_WLD) {
    if (me->point2 == 1) { /* if it is the second point for direction vector */
      if (!VLgetVector( me->vect,&tmp,NULL,vect,&me->ModuleInfo,me->vect)) {
        ex$message(msgnumb = VL_E_ConsCsFail);
        goto quit;
      }
      me->point2 = 0;
    }
    else {
      VLinitCnst(&cst);
      geom.num_points = 1;
      geom.points     = vect;
      cst.geometry = (char *)&geom;

      me->vect->osnum= me->ModuleInfo.md_id.osnum;
      status = om$construct( classid = OPP_GR3dpoint_class_id,
                             osnum   = me->vect->osnum,
                             p_objid = &me->vect->objid );
      if (!(status&1)) {
        ex$message(msgnumb = VL_E_ConsCsFail);
        goto quit;
      }
      status = om$send( msg = message GRgraphics.GRaltconstruct(&cst),
                        targetid = me->vect->objid,
                        targetos = me->vect->osnum);
       if(!(status & 1))
        {
         ex$message(msgnumb = VL_E_ConsCsFail);
         goto quit;
        }
       me->point2 = 1;
    }
  }
  else {
    center[0] = 0; center[1] = 0; center[2] = 0; center[3] = 1;
    if (!VLconvertCoord(&me->ModuleInfo,center,wld,0)) {
      ex$message(msgnumb = VL_E_ConsCsFail);
      goto quit;
    }
    if (!VLgetVector( &tmp,&tmp,wld,vect,&me->ModuleInfo,me->vect)) {
      ex$message(msgnumb = VL_E_ConsCsFail);
      goto quit;
    }
  }
  as$make_source( go_grid = *(me->vect),
                  mod_env = &me->event1.located_object[0].module_info,
                  as_os   =me->ModuleInfo.md_id.osnum ,
		  as_grid = me->vect);
  *msg = MSSUCC;
quit :
    dp$erase_hilite(msg=&loc_msg,
                    objid = me->ModuleInfo.md_id.objid,
                    osnum = me->ModuleInfo.md_id.osnum);
  return OM_S_SUCCESS;
}

 /* when the select point is located with a GRst_DELTA_WLD
    or GRst_PREC_WLD subtype */
method VLcontrol_data2 (int *msg; int gadget1, gadget2)
{
IGRdouble	vect[3];
int		loc_msg;
IGRlong		status;
struct IGRpolyline geom;
struct GRvg_construct  cst;

  *msg = MSFAIL;
  vect[0] = me->event1.event.button.x;
  vect[1] = me->event1.event.button.y;
  vect[2] = me->event1.event.button.z;
  VLinitCnst(&cst);
  geom.num_points = 1;
  geom.points     = vect;
  cst.geometry = (char *)&geom;

  me->pt_select.osnum = me->ModuleInfo.md_id.osnum;
  status = om$construct( classid = OPP_GR3dpoint_class_id,
                         osnum   = me->pt_select.osnum,
                         p_objid = &me->pt_select.objid );
  if (!(status&1)) {
    ex$message(msgnumb = VL_E_ConsSelPtFail);
    goto quit;
  }
  status = om$send( msg = message GRgraphics.GRaltconstruct(&cst),
                    targetid = me->pt_select.objid,
                    targetos = me->pt_select.osnum);
   if(!(status & 1))
    {
     ex$message(msgnumb = VL_E_ConsSelPtFail);
     goto quit;
    }
  as$make_source( go_grid = me->pt_select,
              mod_env = &me->event1.located_object[0].module_info,
              as_os   = me->ModuleInfo.md_id.osnum ,
	      as_grid = &me->pt_select);

  FIg_set_text(me->form_ptr,gadget1,"Defined");
  *msg = MSSUCC;
quit:
    dp$erase_hilite(msg=&loc_msg,
                    objid = me->ModuleInfo.md_id.objid,
                    osnum = me->ModuleInfo.md_id.osnum);
  FIg_set_state_off(me->form_ptr,gadget2);
  return OM_S_SUCCESS;
}

method VLcontrol_data (int *sts; int gadget1, gadget2)
{
struct GRobj_env	*LocatedObjects;
GRclassid		cid;
int 			nb_obj;
char			pt_name[100];

  LocatedObjects = NULL;
  as$start_fence(set= &me->event1.located_object[0].located_obj,
                 set_env = &me->event1.located_object[0].module_info,
                 nb_obj = &nb_obj,
                 p_obj_env = &LocatedObjects,
                 response = me->response,
                 response_data = me->response_data);
  if (nb_obj == 0)
  {
    me->ret = *sts = MY_ERROR;
    ex$message(msgnumb = VL_E_NoObjLoc);
    goto quit;
  }
  pt_name[0] = '\0';
  VLgetName(&LocatedObjects[0].obj_id,pt_name);

  om$get_classid(osnum = LocatedObjects[0].obj_id.osnum,
                 objid = LocatedObjects[0].obj_id.objid,
                 p_classid = &cid);
  as$make_source( go_grid = LocatedObjects[0].obj_id,
                  mod_env = &LocatedObjects[0].mod_env,
                  as_os   =me->ModuleInfo.md_id.osnum ,
                  as_grid = &LocatedObjects[0].obj_id);


  if (om$is_ancestry_valid(subclassid     = cid,
                           superclassid = OPP_GRgencs_class_id )
             == OM_S_SUCCESS ) {
    if (pt_name[0] != '\0') {
      if (me->vect == &me->cs)
           FIg_set_text(me->form_ptr,gadget1,pt_name);
      else
           FIg_set_text(me->form_ptr,gadget2,pt_name);
    }
    *me->vect = LocatedObjects[0].obj_id;
    goto quit;
  }
  else {
    if (om$is_ancestry_valid(subclassid     = cid,
                             superclassid = OPP_GR3dlineseg_class_id )
               == OM_S_SUCCESS ) {
    if (pt_name[0] != '\0') {
      if (me->vect == &me->cs)
           FIg_set_text(me->form_ptr,gadget1,pt_name);
      else
           FIg_set_text(me->form_ptr,gadget2,pt_name);
    }
    *me->vect = LocatedObjects[0].obj_id;
    goto quit;
    }
    else {
      if (nb_obj == 1) {
        if (pt_name[0] != '\0') {
          if (me->vect == &me->cs)
               FIg_set_text(me->form_ptr,gadget1,pt_name);
          else
               FIg_set_text(me->form_ptr,gadget2,pt_name);
        }
        *me->vect = LocatedObjects[0].obj_id;
        me->point2 = 1;
        me->ret = *sts =  POINT;
        goto quit;
      }
      else {
        om$get_classid(osnum = LocatedObjects[1].obj_id.osnum,
                       objid = LocatedObjects[1].obj_id.objid,
                       p_classid = &cid);
        if (om$is_ancestry_valid(subclassid     = cid,
                                 superclassid = OPP_GR3dpoint_class_id )
                   == OM_S_SUCCESS ) {
          if (!VLgetVector( &LocatedObjects[0].obj_id,
			   &LocatedObjects[1].obj_id,
			   NULL,NULL,
			   &me->ModuleInfo,me->vect)) {
            ex$message(msgnumb = VL_E_ConsCsFail);
            me->ret = *sts = MY_ERROR;
            goto quit;
          }
          as$make_source( go_grid = *(me->vect),
                          mod_env = &LocatedObjects[0].mod_env,
                          as_os   =me->ModuleInfo.md_id.osnum ,
                          as_grid = me->vect);
        }
        else {
          if (pt_name[0] != '\0') {
            if (me->vect == &me->cs) 
                 FIg_set_text(me->form_ptr,gadget1,pt_name);
            else
                 FIg_set_text(me->form_ptr,gadget2,pt_name);
          }
          *me->vect = LocatedObjects[0].obj_id;
          me->point2 = 1;
          me->ret = *sts =  POINT;
        }
      }
    }
  }

quit :
    dp$erase_hilite(msg=&nb_obj,
                    objid = me->ModuleInfo.md_id.objid,
                    osnum = me->ModuleInfo.md_id.osnum);
    ASend_fence();
    return OM_S_SUCCESS;
}

method VLcontrol_exp2 (int *sts ; int gadget1, gadget2)
{
char		*str;
struct GRid	obj;
int             rep;

  str = me->event1.event.keyin;
  if (!VLtestExp(&obj,str,&me->ModuleInfo))
    goto quit;
  if ((rep = VLname2Test(&obj,me->vect,&me->ModuleInfo,str,
                        me->form_ptr))) {
    if (me->vect == &me->cs)
         FIg_set_text(me->form_ptr,gadget1,str);
    else
         FIg_set_text(me->form_ptr,gadget2,str);
    me->DisplayMode = GRhd;
    VLdispObj(&obj,&me->ModuleInfo,&me->DisplayMode,1);
    as$make_source( go_grid = *(me->vect),
                    as_os   =me->ModuleInfo.md_id.osnum ,
                    as_grid = me->vect);
    me->point2 = 0;
  }
  else {
    ex$message( msgnumb = VL_E_BadObj);
    if (me->vect == &me->cs)
         FIg_set_text(me->form_ptr,gadget1,str);
    else
         FIg_set_text(me->form_ptr,gadget2,str);
    me->ret = *sts = MY_ERROR;
    goto quit;
  }
quit :
    dp$erase_hilite(msg=&rep,
                    objid = me->ModuleInfo.md_id.objid,
                    osnum = me->ModuleInfo.md_id.osnum);
  return OM_S_SUCCESS;
}

method VLcontrol_exp (int *sts ; int gadget1, gadget2)
{
char		*str;
struct GRid	obj;
int 		rep;

  str = me->event1.event.keyin;
  if (!VLtestExp(&obj,str,&me->ModuleInfo))
    goto quit;

    /* test the object class */
  if ((rep = VLnameTest(&obj,str,
		          me->vect,me->form_ptr))) {
    if (me->vect == &me->cs)
         FIg_set_text(me->form_ptr,gadget1,str);
    else
         FIg_set_text(me->form_ptr,gadget2,str);
    me->DisplayMode = GRhd;
    VLdispObj(&obj,&me->ModuleInfo,&me->DisplayMode,1);
    as$make_source(
                   go_grid = *(me->vect),
                   as_os   =me->ModuleInfo.md_id.osnum ,
                   as_grid = me->vect);
    if (rep == 1) { /* it was a point */
      me->ret = *sts =  POINT; /* so, locate the second point */
      me->point2 = 1;
    }
  }
  else {
    ex$message( msgnumb = VL_E_BadObj);
    me->ret = *sts = MY_ERROR;
    goto quit;
  }
quit :
    dp$erase_hilite(msg=&rep,
                    objid = me->ModuleInfo.md_id.objid,
                    osnum = me->ModuleInfo.md_id.osnum);
  return OM_S_SUCCESS;
}

method VLcontrol_exp_sel (int *sts ; int gadget1, gadget2)
{
struct GRid	obj;
GRclassid	cid;
int		loc_msg;

  if (!VLtestExp(&obj,me->event1.event.keyin,&me->ModuleInfo))
    goto quit;

    /* test the object class */
  om$get_classid(osnum = obj.osnum,
                 objid = obj.objid,
                 p_classid = &cid);
  if (
      (om$is_ancestry_valid(subclassid     = cid,
                           superclassid = OPP_GR3dpoint_class_id )
             == OM_S_SUCCESS ) 
     ) {
    me->DisplayMode = GRhd;
    VLdispObj(&obj,&me->ModuleInfo,&me->DisplayMode,1);
    FIg_set_text(me->form_ptr,gadget1,me->event1.event.keyin);
    as$make_source(
                   go_grid = obj,
                   as_os   =me->ModuleInfo.md_id.osnum ,
                   as_grid = &me->pt_select);
  }
  else {
    ex$message( msgnumb = VL_E_BadObj);
    me->ret = *sts = MY_ERROR;
    goto quit;
  }
quit :
    dp$erase_hilite(msg=&loc_msg,
                    objid = me->ModuleInfo.md_id.objid,
                    osnum = me->ModuleInfo.md_id.osnum);
  FIg_set_state_off(me->form_ptr,gadget2);
  return OM_S_SUCCESS;
}

method VLcontrol_pt2 (int *sts ; int gadget1, gadget2)
{
struct GRid	point;
IGRlong		status;
IGRlong		msg;
int		loc_msg;
char		pt_name[100];
struct GRid	graph_obj;
IGRshort	mat_type;
IGRdouble	mat[16];
IGRpoint	pnt;

  point = me->event1.located_object[0].located_obj;
  status = om$send(  msg = message NDnode.ASreturn_go(&graph_obj,&mat_type,mat),
                     targetid = me->vect->objid,
		     targetos = me->vect->osnum);
  if (!(status&1)) {
    ex$message(msgnumb = VL_E_ConsCsFail);
    me->ret = *sts = MY_ERROR;
    goto quit;
  }
  status = om$send(msg = message GRvg.GRcenter( &msg, &mat_type, mat, pnt),
		          targetid = graph_obj.objid,
		          targetos = graph_obj.osnum);
    if (!(status&msg&1)) {
      ex$message(msgnumb = VL_E_ConsCsFail);
      me->ret = *sts = MY_ERROR;
      goto quit;
    }
  if (!VLgetVector( me->vect,&point,pnt,NULL,&me->ModuleInfo,me->vect)) {
    ex$message(msgnumb = VL_E_ConsCsFail);
    me->ret = *sts = MY_ERROR;
    goto quit;
  }
  if(VLgetName(&point,pt_name)) {
    if (me->vect == &me->cs)
         FIg_set_text(me->form_ptr,gadget1,pt_name);
    else
         FIg_set_text(me->form_ptr,gadget2,pt_name);
  }
  as$make_source( go_grid = *(me->vect),
                  mod_env = &me->event1.located_object[0].module_info,
                  as_os   =me->ModuleInfo.md_id.osnum ,
                  as_grid = me->vect);
  me->point2 = 0;

quit :
    dp$erase_hilite(msg=&loc_msg,
                    objid = me->ModuleInfo.md_id.objid,
                    osnum = me->ModuleInfo.md_id.osnum);
    return OM_S_SUCCESS;
}

method VLcontrol_sel_pt (int *sts ; int gadget1, gadget2)
{
struct GRid	point;
char		pt_name[50];
int		loc_msg;

  point = me->event1.located_object[0].located_obj;
  if(!VLgetName(&point,pt_name)) 
    strcpy(pt_name,"Defined");
  FIg_set_text(me->form_ptr,gadget1,pt_name);
  as$make_source( go_grid = point,
                  mod_env = &me->event1.located_object[0].module_info,
                  as_os   =me->ModuleInfo.md_id.osnum ,
                  as_grid = &me->pt_select);

    dp$erase_hilite(msg=&loc_msg,
                    objid = me->ModuleInfo.md_id.objid,
                    osnum = me->ModuleInfo.md_id.osnum);
  FIg_set_state_off(me->form_ptr,gadget2);
  return OM_S_SUCCESS;
}

end implementation VLgenLinCmd;
