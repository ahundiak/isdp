/* $Id: VDmisc.I,v 1.1.1.1 2001/01/04 21:08:42 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/vddrawing/imp/VDmisc.I
 *
 * Description: Assorted utility routines
 *
 * Dependencies:
 *
 * Revision History:
 * $Log: VDmisc.I,v $
 * Revision 1.1.1.1  2001/01/04 21:08:42  cvs
 * Initial import to CVS
 *
# Revision 1.1  1999/04/09  17:14:08  pinnacle
# Misc routines
#
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 04/09/99  ah      Created to solve load problems
 * -------------------------------------------------------------------*/


class implementation VDm_drawing;
#include "stdio.h"
#include "ctype.h"
#include "string.h"
#include "OMparameters.h"
#include "OMprimitives.h"
#include "OMmacros.h"
#include "OMindex.h"
#include "OMminimum.h"
#include "OMtypes.h"
#include "AS_status.h"
#include "msmacros.h"
#include "ASmessages.h"
#include "dp.h"
#include "dpdef.h"
#include "dpmacros.h"
#include "acdef.h"
#include "acmacros.h"
#include "coparadef.h"
#include "nddef.h"
#include "asbox.h"
#include "asdef.h"
#include "asmacros.h"
#include "DItypedef.h"
#include "DIdef.h"
#include "DIglob.h"
#include "DIprims.h"
#include "DImacros.h"
#include "coparamac.h"
#include "ACdb_info.h"
#include "macro.h"
#include "nddef.h"
#include "ndmacros.h"
#include "expression.h"
#include "expmacros.h"
#include "madef.h"
#include "go.h"
#include "gomacros.h"
#include "ACcheckin.h"
#include "refdef.h"
#include "ref.h"
#include "exdef.h"
#include "exmacros.h"
#include "lcmacros.h"
#include "ACattrib.h"
#include "ACrg_collect.h"
#include "growner.h"
#include "SMdef.h"
#include "SMmacros.h"
#include "detaildef.h"
#include "VDmsg.h"
#include "v_miscmacros.h"
#include "VDCmdDrwFr.h"
#include "msdef.h"
#include "refdef.h"
#include "nddef.h"
#include "ndmacros.h"
#include "dim.h"
#include "asbox.h"
#include "FI.h"
#include "FEI.h"
#include "grimport.h"
#include "gocmacros.h"
#include "godef.h"

#include "grownmacros.h"
#include "cotxmacros.h"
#include "grownerdef.h"
#include "bsconic.h"
#include "bserr.h"
#include "bsparameters.h"
#include "grdpbmacros.h"
#include "grdpb.h"
#include "grerr.h"
#include "grgsdef.h"
#include "grmacros.h"

#include "v_dbgmacros.h"


#include "asbox.h"
#include "asdef.h"
#include "asmacros.h"

#include "coparamac.h"
#include "ACdb_info.h"
#include "macro.h"
#include "nddef.h"
#include "ndmacros.h"
#include "expression.h"
#include "expmacros.h"
#include "madef.h"
#include "go.h"
#include "ACcheckin.h"
#include "refdef.h"
#include "ref.h"
#include "exdef.h"
#include "exmacros.h"
#include "v_miscmacros.h"

#include "griodef.h"
#include "griomacros.h"
#include "viewdef.h"
#include "v_drwdef.h"
#include "vddrwproto.h"

#include "SMdef.h"
#include "SMmacros.h"
#include "detaildef.h"

from	NDnode		import NDget_objects, NDconnect,NDchange_connect,
				NDs_compute_node, NDgive_structure;
from	ACcpx		import ACload_macro,find_macro,ACfind_temp_obj;
from	ACncpx		import ACchange_feet,ACconstruct_feet;
from	ACcpx_defn	import ACgive_feet_desc,ACgive_name;
from	expression	import NDgive_value;
from	NDmacro		import ACreturn_foot;
from	GRgraphics	import GRdisplay,GRgetrang,GRremwrng,GRaddwrng,GRdelete,GRgetname;
from	GRvg		import GRchgname,GRdetplane;
from	ACdb_info	import ACget_db_info,ACset_db_info,ACput_serial_no,
				ACcheckin_candidate;
from	IGEgragad	import DPinrot,DPinquire;
from	GRreffile	import GRgetlevels, GRinquireref;
from	ci_mac_def	import ACplace;
from	VDcontext	import VDset_level,VDset_lbs,VDset_proj_view,
				VDset_setup_name,VDget_setup_name,
				VDget_setup_name_size;
from  GRcontext         import  GRgetmodule_env;
from  GRcontext         import  GRgetinstance;

from  ASnode            import  ASreturn_go;

extern	GRclassid	OPP_VDcontext_class_id,
			OPP_ci_mac_def_class_id,
			OPP_VDCmdDrwFr_class_id,
			OPP_VDdrawing_class_id;
extern	struct GRid	AC_construct_id;
extern			ACconstruct_wd(), ACconstruct_path();

extern  char * calloc();
extern  char * malloc();
extern  char * realloc();

extern  int UI_status();

extern GRclassid OPP_nci_macro_class_id;
extern GRclassid OPP_GRgencs_class_id;
extern OM_S_CHANSELECT AS_listeners;
extern GRclassid OPP_GRreffile_class_id,
		 OPP_GRdrawview_class_id,
		 OPP_VDdrawing_class_id,
		 OPP_GR3dlineseg_class_id,
		 OPP_GR3dpolygon_class_id,
		 OPP_GRgrset_class_id,
		 OPP_GRgencs_class_id;
extern GRclassid OPP_SMInfPlane_class_id;
extern GRclassid OPP_ACpretendin_class_id;
extern GRclassid OPP_VDcontext_class_id;
extern GRclassid OPP_GRdvattach_class_id;
extern GRclassid OPP_ACpretendin_class_id;
extern GRclassid OPP_GRdrawview_class_id;
          
// Copied from spec file 
struct SMdraxis{
	struct GRid obj;
        double abs;
        char name[20];
};

struct SMdrframe{
	struct SMdraxis *frame;
        int axis;
        int size_frame;
        int nb_frame;
        struct GRmd_env md_env;
};

struct VDfrsys{
	struct GRid 		grid;
	char	 		name[20];
};

#define AS_DEBUG

/* -----------------------------------------------
 * Originally from VDCmdDrwFri.I
 */
/*********************************************************************/
/*
   Search last occurent of a caracter defined by string in the string 
   beginning at start and ending at current 
*/
char *asstrrpbrk(start,current,string)
char *start,*current,*string;
{
 char *pos;
 char *strchr();
  
 SetProc( asstrrpbrk ); Begin
 pos = current;
 for(pos=current;pos>=start;pos--)
  {
   if(strchr(string,*pos)) return pos;
  }
  
 End
 return NULL;
}

/*******************************************************************/
/* Insert prefix at the beginning of string */
/* string is supposed to be long enought    */
asstrinsert(string,prefix)
char *string,*prefix;
{
 int len_prefix,len_string;
 char *c;
 SetProc( asstrinserta ); Begin

 len_prefix = strlen(prefix);
 len_string = strlen(string);

 for( c = string+len_string; c>=string;c--) *(c+len_prefix) = *c;
 OM_BLOCK_MOVE(prefix,string,len_prefix);
 
 End
 return 1;
}
/*------------------------------------------------------------------------*/

VDfind_context(osnum,context,size_context,nb_context)
GRspacenum 	osnum;
struct GRid 	*context;
int 		size_context,*nb_context;
{
long 		status,loc_msg;
IGRchar 	osname[OM_K_MAXOSNAME_LEN];
IGRshort	mx_type, flag;
IGRuint  	count, count_bis;

IGRlong 	i;			/* loop index			*/
GRspacenum	ref_osnum;

OM_S_CHANSELECT super_chan, ref_chan;
struct GRid 	Super, ctx_id;
OM_S_OBJECT_LINKAGE ref;
IGRmatrix	ctx_matrix;

  SetProc( VDfind_context ); Begin
  /* Find all the context associated to an os */

  *nb_context = 0;

  status = om$make_chanselect(channame = "Super_rfmgr.to_context",
			    p_chanselect = &super_chan);
  as$status(action = RET_STATUS);

  status = om$make_chanselect(channame = "GRcontext.to_reffile",
			    p_chanselect = &ref_chan);
  as$status(action = RET_STATUS);

  /* get the context Super	*/
  status = GRgetctxsuper(&loc_msg,&Super);
  if(!(status&loc_msg&1)) return OM_W_ABORT;

  status = om$get_channel_count( osnum = Super.osnum,
			       objid = Super.objid,
			       p_chanselect = &super_chan,
			       count = &count);
  as$status(action = RET_STATUS);

  for (i=0; i<count; ++i) {			
   /* get each context object	*/
   status = om$send( msg = message GRcontext.GRgetinstance
		    (&loc_msg,&mx_type,ctx_matrix,&ref_osnum,
		     &flag,&ctx_id),
		senderid = Super.objid,
		targetos = Super.osnum,
		p_chanselect = &super_chan,
		to = i,
		from = i);
   if(!(status&loc_msg&1)) continue;
	
   /* see if this object space is active before
    * trying to use this context object.
    */

   status = om$os_number_to_name(osnum=ref_osnum,
		     		 osname = osname);
   if(!(status&1)) continue;
   if ( !( flag & GRACTIVATED_CONTEXT)) continue;

   status = om$get_channel_objects(objid = ctx_id.objid, osnum = ctx_id.osnum,
                         p_chanselect = &ref_chan,
                         list = &ref,size = 1, count = &count_bis);
   if(!(status&1) || !count_bis) continue;

   if (osnum != ref_osnum) continue; 
   if(*nb_context < size_context) context[*nb_context] = ctx_id;
   *nb_context = *nb_context + 1;
	
  }
  End
  return( OM_S_SUCCESS );
} /* VDfind_context */

/*------------------------------------------------------------------------*/
SMframe_axis(msg,obj,f_info)
long *msg;
struct GRid *obj;
struct GRfunction_info *f_info;
{
 long status,loc_msg;
 struct SMdrframe *axis;
 char *macro_name,*frame_name,*strrchr(),
       occ_name[DI_PATH_MAX];
       
 struct GRid model_def,cs;
 double point[3],normal[3];
 struct IGRplane def_plane;
 double fabs();
 int count;

 SetProc( SMframe_axis ); Begin

 *msg = MSSUCC;

 /* Control macro name */

 if(SMIsKindOf(obj,OPP_nci_macro_class_id))
  {
    status = om$send(msg = message ACcpx.find_macro(&model_def),
		     senderid = NULL_OBJID,
		     targetid = obj->objid,
		     targetos = obj->osnum);
    if(!(status&1)) return OM_S_SUCCESS;

    status = om$send(msg = message ACcpx_defn.ACgive_name(&macro_name),
		     senderid = NULL_OBJID,
		     targetid = model_def.objid,
		     targetos = model_def.osnum);
    if(!(status&1)) return OM_S_SUCCESS;

   if(strcmp(macro_name,"SMFrPln")    != 0 &&
      strcmp(macro_name,"VDDstPln")   != 0 &&
      strcmp(macro_name,"VDFrPln")    != 0) return OM_S_SUCCESS;
  }


  /* Check first parent is a cs */
 status = om$send(msg = message NDnode.NDget_objects
		  (ND_ROOT,&cs,1,NULL,0,0,&count),
		  senderid = NULL_OBJID,
		  targetid = obj->objid,
		  targetos = obj->osnum );
 if(!(status&1)) return OM_S_SUCCESS;
 
 status = om$send(msg = message ASnode.ASreturn_go
		  (&cs,NULL,NULL),
		  senderid = NULL_OBJID,
		  targetid = cs.objid,
		  targetos = cs.osnum);

 if(!SMIsKindOf(&cs,OPP_GRgencs_class_id)) return OM_S_SUCCESS;

   axis = (struct SMdrframe *) f_info->info;
   def_plane.point = point;
   def_plane.normal = normal;

   status = om$send(msg = message GRvg.GRdetplane(&loc_msg,
                                              &axis->md_env.md_env.matrix_type,
                                               axis->md_env.md_env.matrix,
                                              &def_plane),
                  senderid = NULL_OBJID,
                  targetos = obj->osnum,
                  targetid = obj->objid);

   if(fabs(normal[axis->axis]) < 0.99) return OM_S_SUCCESS;

   if(axis->nb_frame >= axis->size_frame)
    {
     axis->size_frame += 50;
     if(axis->frame == NULL) 
       {
	axis->frame = (struct SMdraxis *) om$malloc
			     (size = axis->size_frame*sizeof(struct SMdraxis));
       }
     else
       {
	/* Jean : 9-30-90 Retablish the original version ! */ 
	axis->frame = (struct SMdraxis *) om$realloc(ptr  = (char *)axis->frame,
       			      size = axis->size_frame*sizeof(struct SMdraxis));
#ifdef YY
	om$realloc(ptr  = (char *) axis->frame,
                   size = axis->size_frame*sizeof(struct SMdraxis));
#endif
       }
     if(!axis->frame ) 
       {axis->nb_frame = axis->size_frame = 0; return OM_S_SUCCESS;}
    }

   axis->frame[axis->nb_frame].obj = *obj;
   axis->frame[axis->nb_frame].abs = point[axis->axis];

   occ_name[0] = '\0';
   frame_name = occ_name;
   status = om$send(msg = message GRvg.GRgetname (&loc_msg,occ_name),
		   senderid = NULL_OBJID,
		    targetid = obj->objid,
		    targetos = obj->osnum);
   if(status & loc_msg & 1)
    { frame_name = strrchr(occ_name,':');
      if(frame_name) frame_name++;
      else	     frame_name = occ_name;
    }

   strncpy(axis->frame[axis->nb_frame].name,frame_name,20);
   axis->frame[axis->nb_frame].name[19] = '\0',
   axis->nb_frame++;
  
   End
   return OM_S_SUCCESS;
}

SMcompar_frame(f1,f2)
struct SMdraxis *f1,*f2;
{
 SetProc( SMcompar_frame ); Begin

 End 
 return (f1->abs - f2->abs);
}

SMframe_order(axis)
struct SMdrframe *axis;
{
 int SMcompar_frame();
 SetProc( SMframe_order ); Begin
 qsort(axis->frame,axis->nb_frame,sizeof(struct SMdraxis),SMcompar_frame);
 End
 return 1;
}

/**********************************************************************/
/* function VDget_drawviewId: get drawing view id from VDdrawing      */ 
/**********************************************************************/
long VDget_drwviewId(msg, obj, drawview)
long                   *msg;
struct  GRid           obj;
struct  GRid           *drawview;
{
IGRint                  status;
OM_S_OBJECT_LINKAGE     *refList = NULL;
OM_S_OBJECT_LINKAGE     fatObj, refObj, lisObj, viewObj, attObj;
char                    classname[80]; /* classname  */
OM_S_CHANSELECT         father_chan, listeners_chan,
                        reffile_chan, owner_chan;
OMuint                  list_count,
                        lst_count;
int                     size_int, i, flag_find;

        SetProc( VDget_drwviewId ); Begin

        status = OM_S_SUCCESS;
        *msg  = MSSUCC;

        /* VDdrawing object */
        __DBGpr_obj("inputwing obj", obj);

        /* set up channel  */
        status = om$make_chanselect ( channame = "NDfather.father",
                               p_chanselect = &father_chan );
        if (!(1 & status)) {
             *msg = MSFAIL;
             status = MSFAIL;
             goto wrapup;
        }

        status = om$make_chanselect ( channame = "ASsource.listeners",
                               p_chanselect = &listeners_chan );
        if (!(1 & status)) {
             *msg = MSFAIL;

             status = MSFAIL;
             goto wrapup;
        }

        status = om$make_chanselect ( channame = "GRcontext.to_reffile",
                               p_chanselect = &reffile_chan );
        if (!(1 & status)) {
             *msg = MSFAIL;
             status = MSFAIL;
             goto wrapup;
        }

        status = om$make_chanselect ( channame = "GRconnector.to_owners",
                               p_chanselect = &owner_chan );
        if (!(1 & status)) {
             *msg = MSFAIL;
             status = MSFAIL;
             goto wrapup;
        }

        /* find ACpretendin object in NDfather.father*/
        flag_find = 0;
        list_count = 0;
        status = om$get_channel_count( objid = obj.objid,
                                osnum = obj.osnum,
                                p_chanselect = &father_chan,
                                count = &list_count);
        __DBGpr_int("for father list_count", list_count);

        if( list_count ) {
          /* get object from the father_chan */
          size_int = (int)list_count;
          refList = _MALLOC( size_int, OM_S_OBJECT_LINKAGE);
          lst_count = 0;
          status = om$get_channel_objects( objid = obj.objid,
                                    osnum = obj.osnum,
                                    p_chanselect = &father_chan,
                                    list = refList,
                                    size = size_int,
                                    count = &lst_count);

          __DBGpr_int( " lst_count", lst_count);

          for ( i = 0; i < lst_count; i++ ) {
            /* goto find the ACpretendin object from list */

            __DBGpr_int("  refList[i].S_objid ",  refList[i].S_objid);
            status = om$get_classname (objid     = refList[i].S_objid,
                                       osnum = refList[i].osnum,
                                       classname = classname);

            status = om$is_ancestry_valid (  subclassname = classname,
                                     superclassid = OPP_ACpretendin_class_id );

            if (status == OM_S_SUCCESS) {
                    fatObj = refList[i]  ;
                    __DBGpr_int(" fatObj.S_objid ",  fatObj.S_objid);
                    flag_find = 1;
                    break;
            }
          }
        }
        if ( !flag_find )  { /* not find ASpretendin */
             *msg = MSFAIL;
             status = MSFAIL;
             goto wrapup;
        }
        _FREE( refList );

        /* find VDcontext object in ASource.listeners */
        flag_find = 0;
        list_count = 0;
        status = om$get_channel_count ( objid = fatObj.S_objid,
                                        osnum = fatObj.osnum,
                                        p_chanselect = &listeners_chan,
                                        count = &list_count);
        __DBGpr_int("for listeners list_count", list_count);

        if( list_count ) {
          /* get object from the father_chan */
          size_int = (int)list_count;
          refList = _MALLOC( size_int, OM_S_OBJECT_LINKAGE);
          lst_count = 0;
          status = om$get_channel_objects( objid = fatObj.S_objid,
                                    osnum = fatObj.osnum,
                                    p_chanselect = &listeners_chan,
                                    list = refList,
                                    size = size_int,
                                    count = &lst_count);
          __DBGpr_int( " lst_count", lst_count);
          for ( i = 0; i < lst_count; i++ ) {
            /* goto find the ACpretendin object from list */
            status = om$get_classname (objid = refList[i].S_objid,
                                       osnum = refList[i].osnum,
                                       classname = classname);

            status = om$is_ancestry_valid (  subclassname = classname,
                                     superclassid = OPP_VDcontext_class_id );

            if (status == OM_S_SUCCESS) {
                     lisObj = refList[i]  ;
                     __DBGpr_int(" lisObj.S_objid ",  lisObj.S_objid);
                     flag_find = 1;
                     break;
            }
          }
        }
        if ( !flag_find )  { /* not find VDcontext */
             *msg = MSFAIL;
             status = MSFAIL;
             goto wrapup;
        }
        _FREE( refList );

        /* find GRreffile object in channel GRcontext.to_reffile */
        flag_find = 0;
        list_count = 0;

        status = om$get_channel_count( objid = lisObj.S_objid,
                                    osnum = lisObj.osnum,
                                p_chanselect = &reffile_chan,
                                count = &list_count);
        __DBGpr_int("for reffile list_count", list_count);

        if( list_count ) {
          /* get object from the father_chan */
          size_int = (int)list_count;
          refList = _MALLOC( size_int, OM_S_OBJECT_LINKAGE);
          lst_count = 0;
          status = om$get_channel_objects( objid = lisObj.S_objid,
                                    osnum = lisObj.osnum,
                                    p_chanselect = &reffile_chan,
                                    list = refList,
                                    size = size_int,
                                    count = &lst_count);
          __DBGpr_int( " lst_count", lst_count);
          for ( i = 0; i < lst_count; i++ ) {
            /* goto find the ACpretendin object from list */
            status = om$get_classname (objid     = refList[i].S_objid,
                                       osnum = refList[i].osnum,
                                       classname = classname);

            status = om$is_ancestry_valid (  subclassname = classname,
                                     superclassid = OPP_GRreffile_class_id );

            if (status == OM_S_SUCCESS) {
                     refObj = refList[i]  ;
                     __DBGpr_int(" refObj.S_objid ",  refObj.S_objid);
                     flag_find = 1;
                     break;
            }
          }
        }
        if ( !flag_find )  { /* not find GRrefile */
             *msg = MSFAIL;
             status = MSFAIL;
             goto wrapup;
        }
        _FREE( refList );

        /* find GRdvattach object in channel GRconnector.to_owner */
        flag_find = 0;
        list_count = 0;
        status = om$get_channel_count( objid = refObj.S_objid,
                                osnum = refObj.osnum,
                                p_chanselect = &owner_chan,
                                count = &list_count);

        __DBGpr_int("for GRdvattach list_count", list_count);

        if( list_count ) {
          size_int = (int)list_count;
          refList = _MALLOC( size_int, OM_S_OBJECT_LINKAGE);
          lst_count = 0;
          status = om$get_channel_objects( objid = refObj.S_objid,
                                    osnum = refObj.osnum,
                                    p_chanselect = &owner_chan,
                                    list = refList,
                                    size = size_int,
                                    count = &lst_count);
          __DBGpr_int( " lst_count", lst_count);
          for ( i = 0; i < lst_count; i++ ) {
            /* goto find the GRdvattach object from list */
            status = om$get_classname (objid     = refList[i].S_objid,
                                       osnum = refList[i].osnum,
                                       classname = classname);

            status = om$is_ancestry_valid (  subclassname = classname,
                                     superclassid = OPP_GRdvattach_class_id );

            if (status == OM_S_SUCCESS) {

                     attObj = refList[i]  ;
                     __DBGpr_int(" attObj.S_objid ",  attObj.S_objid);
                     flag_find = 1;
                     break;
            }
          }
        }
        if ( !flag_find )  { /* not find GRdvattach */
             *msg = MSFAIL;
             status = MSFAIL;
             goto wrapup;
        }

        _FREE( refList );

        /* find GRdrwview object in channel GRconnector.to_owner */
        flag_find = 0;
        list_count = 0;
        status = om$get_channel_count( objid = attObj.S_objid,
                                    osnum = attObj.osnum,
                                p_chanselect = &owner_chan,
                                count = &list_count);
        __DBGpr_int("for GRdrwview list_count", list_count);

        if( list_count ) {

          size_int = (int)list_count;
          refList = _MALLOC( size_int, OM_S_OBJECT_LINKAGE);
          lst_count = 0;
          status = om$get_channel_objects( objid = attObj.S_objid,
                                    osnum = attObj.osnum,
                                    p_chanselect = &owner_chan,
                                    list = refList,
                                    size = size_int,
                                    count = &lst_count);
          __DBGpr_int( " lst_count", lst_count);

          for ( i = 0; i < lst_count; i++ ) {
            /* goto find the GRdrawview object from list */
            status = om$get_classname (objid     = refList[i].S_objid,
                                       osnum = refList[i].osnum,
                                       classname = classname);

            status = om$is_ancestry_valid (  subclassname = classname,
                                     superclassid = OPP_GRdrawview_class_id );

            if (status == OM_S_SUCCESS) {
                     viewObj = refList[i]  ;
                     __DBGpr_int(" viewObj.S_objid ",  viewObj.S_objid);
                     flag_find = 1;
                     break;
            }
          }
        }
        if ( !flag_find )  { /* not find GRdrawview */
             *msg = MSFAIL;
             status = MSFAIL;
             goto wrapup;
        }
        _FREE( refList );

        /* compare input drawing view id with viewObj */
        drawview->objid = viewObj.S_objid; 
        drawview->osnum = viewObj.osnum; 

wrapup:
        _FREE( refList );
        End
        return  status;
}


/**********************************************************************/
/* function VDcomp_drwview:   compare input drawing view with that get*/
/*          from VDdrawing 					      */ 
/**********************************************************************/
long VDcomp_drwview(msg, obj, drawview)
long                   *msg;
struct  GRid           obj;
struct  GRid           drawview;
{
IGRint                  status;
OM_S_OBJECT_LINKAGE     *refList = NULL;
OM_S_OBJECT_LINKAGE     fatObj, refObj, lisObj, viewObj, attObj;
char                    classname[80]; /* classname  */
OM_S_CHANSELECT         father_chan, listeners_chan,
                        reffile_chan, owner_chan;
OMuint                  list_count,
                        lst_count;
int                     size_int, i, flag_find;

        SetProc( VDcomp_drwview ); Begin

        status = OM_S_SUCCESS;
        *msg  = MSSUCC;

        /* VDdrawing object */
        __DBGpr_obj("inputwing obj", obj);

        /* set up channel  */
        status = om$make_chanselect ( channame = "NDfather.father",
                               p_chanselect = &father_chan );
        if (!(1 & status)) {
             *msg = MSFAIL;
             status = MSFAIL;
             goto wrapup;
        }

        status = om$make_chanselect ( channame = "ASsource.listeners",
                               p_chanselect = &listeners_chan );
        if (!(1 & status)) {
             *msg = MSFAIL;

             status = MSFAIL;
             goto wrapup;
        }

        status = om$make_chanselect ( channame = "GRcontext.to_reffile",
                               p_chanselect = &reffile_chan );
        if (!(1 & status)) {
             *msg = MSFAIL;
             status = MSFAIL;
             goto wrapup;
        }

        status = om$make_chanselect ( channame = "GRconnector.to_owners",
                               p_chanselect = &owner_chan );
        if (!(1 & status)) {
             *msg = MSFAIL;
             status = MSFAIL;
             goto wrapup;
        }

        /* find ACpretendt_count object in NDfather.fatherG*/
        flag_find = 0;
        list_count = 0;
        status = om$get_channel_count( objid = obj.objid,
                                osnum = obj.osnum,
                                p_chanselect = &father_chan,
                                count = &list_count);
        __DBGpr_int("for father list_count", list_count);

        if( list_count ) {
          /* get object from the father_chan */
          size_int = (int)list_count;
          refList = _MALLOC( size_int, OM_S_OBJECT_LINKAGE);
          lst_count = 0;
          status = om$get_channel_objects( objid = obj.objid,
                                    osnum = obj.osnum,
                                    p_chanselect = &father_chan,
                                    list = refList,
                                    size = size_int,
                                    count = &lst_count);

          __DBGpr_int( " lst_count", lst_count);

          for ( i = 0; i < lst_count; i++ ) {
            /* goto find the ACpretendin object from list */

            __DBGpr_int("  refList[i].S_objid ",  refList[i].S_objid);
            status = om$get_classname (objid     = refList[i].S_objid,
                                       osnum = refList[i].osnum,
                                       classname = classname);

            status = om$is_ancestry_valid (  subclassname = classname,
                                     superclassid = OPP_ACpretendin_class_id );

            if (status == OM_S_SUCCESS) {
                    fatObj = refList[i]  ;
                    __DBGpr_int(" fatObj.S_objid ",  fatObj.S_objid);
                    flag_find = 1;
                    break;
            }
          }
        }
        if ( !flag_find )  { /* not find ASpretendin */
             *msg = MSFAIL;
             status = MSFAIL;
             goto wrapup;
        }

        _FREE( refList );

        /* find VDcontext object in ASource.listeners */
        flag_find = 0;
        list_count = 0;
        status = om$get_channel_count ( objid = fatObj.S_objid,
                                        osnum = fatObj.osnum,
                                	p_chanselect = &listeners_chan,
                                	count = &list_count);
        __DBGpr_int("for listeners list_count", list_count);

        if( list_count ) {
          /* get object from the father_chan */
          size_int = (int)list_count;
          refList = _MALLOC( size_int, OM_S_OBJECT_LINKAGE);
          lst_count = 0;
          status = om$get_channel_objects( objid = fatObj.S_objid,
                                    osnum = fatObj.osnum,
                                    p_chanselect = &listeners_chan,
                                    list = refList,
                                    size = size_int,
                                    count = &lst_count);
          __DBGpr_int( " lst_count", lst_count);

          for ( i = 0; i < lst_count; i++ ) {
            /* goto find the ACpretendin object from list */
            status = om$get_classname (objid = refList[i].S_objid,
                                       osnum = refList[i].osnum,
                                       classname = classname);

            status = om$is_ancestry_valid (  subclassname = classname,
                                     superclassid = OPP_VDcontext_class_id );

            if (status == OM_S_SUCCESS) {
                     lisObj = refList[i]  ;
                     __DBGpr_int(" lisObj.S_objid ",  lisObj.S_objid);
                     flag_find = 1;
                     break;
            }
          }
        }
        if ( !flag_find )  { /* not find VDcontext */
             *msg = MSFAIL;
             status = MSFAIL;
             goto wrapup;
        }
        _FREE( refList );


        /* find GRreffile object in channel GRcontext.to_reffile */
        flag_find = 0;
        list_count = 0;

        status = om$get_channel_count( objid = lisObj.S_objid,
                                    osnum = lisObj.osnum,
                                p_chanselect = &reffile_chan,
                                count = &list_count);
        __DBGpr_int("for reffile list_count", list_count);

        if( list_count ) {
          /* get object from the father_chan */
          size_int = (int)list_count;
          refList = _MALLOC( size_int, OM_S_OBJECT_LINKAGE);
          lst_count = 0;
          status = om$get_channel_objects( objid = lisObj.S_objid,
                                    osnum = lisObj.osnum,
                                    p_chanselect = &reffile_chan,
                                    list = refList,
                                    size = size_int,
                                    count = &lst_count);
          __DBGpr_int( " lst_count", lst_count);

          for ( i = 0; i < lst_count; i++ ) {
            /* goto find the ACpretendin object from list */
            status = om$get_classname (objid     = refList[i].S_objid,
                                       osnum = refList[i].osnum,
                                       classname = classname);

            status = om$is_ancestry_valid (  subclassname = classname,
                                     superclassid = OPP_GRreffile_class_id );

            if (status == OM_S_SUCCESS) {
                     refObj = refList[i]  ;
                     __DBGpr_int(" refObj.S_objid ",  refObj.S_objid);
                     flag_find = 1;
                     break;
            }
          }
        }
        if ( !flag_find )  { /* not find GRrefile */
             *msg = MSFAIL;
             status = MSFAIL;
             goto wrapup;
        }
        _FREE( refList );

        /* find GRdvattach object in channel GRconnector.to_owner */
        flag_find = 0;
        list_count = 0;
        status = om$get_channel_count( objid = refObj.S_objid,
                                osnum = refObj.osnum,
                                p_chanselect = &owner_chan,
                                count = &list_count);

        __DBGpr_int("for GRdvattach list_count", list_count);

        if( list_count ) {
          /* get object from the father_chan */
          size_int = (int)list_count;
          refList = _MALLOC( size_int, OM_S_OBJECT_LINKAGE);
          lst_count = 0;
          status = om$get_channel_objects( objid = refObj.S_objid,
                                    osnum = refObj.osnum,
                                    p_chanselect = &owner_chan,
                                    list = refList,
                                    size = size_int,
                                    count = &lst_count);
          __DBGpr_int( " lst_count", lst_count);

          for ( i = 0; i < lst_count; i++ ) {
            /* goto find the GRdvattach object from list */
            status = om$get_classname (objid     = refList[i].S_objid,
                                       osnum = refList[i].osnum,
                                       classname = classname);

            status = om$is_ancestry_valid (  subclassname = classname,
                                     superclassid = OPP_GRdvattach_class_id );

            if (status == OM_S_SUCCESS) {

                     attObj = refList[i]  ;
                     __DBGpr_int(" attObj.S_objid ",  attObj.S_objid);
                     flag_find = 1;
                     break;
            }
          }
        }
        if ( !flag_find )  { /* not find GRdvattach */
             *msg = MSFAIL;
             status = MSFAIL;
             goto wrapup;
        }
        _FREE( refList );

        /* find GRdrwview object in channel GRconnector.to_owner */
        flag_find = 0;
        list_count = 0;
        status = om$get_channel_count( objid = attObj.S_objid,
                                    osnum = attObj.osnum,
                                p_chanselect = &owner_chan,
                                count = &list_count);
        __DBGpr_int("for GRdvattach list_count", list_count);

        if( list_count ) {

          size_int = (int)list_count;
          refList = _MALLOC( size_int, OM_S_OBJECT_LINKAGE);
          lst_count = 0;
          status = om$get_channel_objects( objid = attObj.S_objid,
                                    osnum = attObj.osnum,
                                    p_chanselect = &owner_chan,
                                    list = refList,
                                    size = size_int,
                                    count = &lst_count);
          __DBGpr_int( " lst_count", lst_count);

          for ( i = 0; i < lst_count; i++ ) {
            /* goto find the GRdrawview object from list */
            status = om$get_classname (objid     = refList[i].S_objid,
                                       osnum = refList[i].osnum,
                                       classname = classname);

            status = om$is_ancestry_valid (  subclassname = classname,
                                     superclassid = OPP_GRdrawview_class_id );

            if (status == OM_S_SUCCESS) {
                     viewObj = refList[i]  ;
                     __DBGpr_int(" viewObj.S_objid ",  viewObj.S_objid);
                     flag_find = 1;
                     break;
            }
          }
        }
        if ( !flag_find )  { /* not find GRdrwview */
             *msg = MSFAIL;
             status = MSFAIL;
             goto wrapup;
        }
        _FREE( refList );

        /* compare input drawing view id with viewObj */ 
        if(viewObj.S_objid != drawview.objid ||
           viewObj.osnum != drawview.osnum) {
             *msg = MSFAIL;
             status = MSFAIL;
        }
        
wrapup:
        _FREE( refList );
        End
        return  status;
}

/*****************************************************************
This function will return vddrawing object from SMfrme object.
******************************************************************/
long VDframeObjToDrwObj( msg, frame, drawview, drwObj)
long           *msg;          /* return code  */
struct GRid       frame; /* active position  */
struct GRid       drawview; /* drawing view ID  */
struct GRid       *drwObj; /* active position  */
{
long			status;
OM_S_CHANSELECT 	to_prtnd,children_chan;
short                   classid;
int                     NbFound = 0, i = 0;
struct GRid             *FoundId = NULL, Ref, par_obj;
int                     i0;
short                   valid_class = 0;
OMuint                  cnt = 0;
GRclassid               clid;
OM_S_OBJECT_LINKAGE     *lobj = NULL;

    SetProc( VDframeObjToDrwObj ); Begin
    *msg = MSSUCC;
    status = MSSUCC;

    __DBGpr_obj ( " frame object ", frame);

    status = om$make_chanselect(channame = "GRnotify.notification",
                            p_chanselect = &to_prtnd);
    as$status(action = RET_STATUS);
    __DBGpr_com( " ok for notify_chan setup ");

    status = om$make_chanselect(channame = "NDchildren.children",
                            p_chanselect = &children_chan);
    as$status(action = RET_STATUS);
    __DBGpr_com( " ok for children_chan setup ");


    /* get ACpretendin object  */
    status = om$get_channel_count(osnum = frame.osnum, 
				  objid = frame.objid,
                          	  p_chanselect = &to_prtnd,
                          	  count = &cnt);
    if(!(status&1) || !cnt)  
	__DBGpr_com( "Not find object from channel notify_chan");

    __DBGpr_int( "object bumber in the notify_chan", cnt);
 
    if ( cnt > 0 ) {
      lobj = _MALLOC ( cnt, OM_S_OBJECT_LINKAGE );

      if ( lobj == NULL ) { 
        goto wrapup;
      }

      if ( lobj ) {
         status = om$get_channel_objects(
                                osnum           = frame.osnum,
                                objid           = frame.objid,
                                p_chanselect    = &to_prtnd,
                                size            = cnt,
                                list            = lobj,
                                count           = &cnt );
         as$status ();

         if ( ! status ) {
            goto wrapup;
         }

         classid = OPP_ACpretendin_class_id; 

         for ( i0 = 0; i0 < cnt; i0++ ) {
           struct GRid     child_id;

           child_id.objid = lobj[i0].S_objid;
           child_id.osnum = lobj[i0].osnum;

           if ( classid < 0 ) {
             valid_class = DMancestry_valid ( child_id, - classid );
           }
           else if ( classid > 0 ) {
              om$get_classid (objid         = child_id.objid,
                              osnum         = child_id.osnum,
                              p_classid     = &clid );
           }

           if ( (valid_class & 1) || clid == classid ) {
            if ( FoundId == NULL ) {
              FoundId = _MALLOC ( NbFound + 1, struct GRid );
            }
            else {
              FoundId = _REALLOC ( FoundId, NbFound + 1, struct GRid );
            }

            if ( FoundId== NULL ) {
              goto wrapup;
            }

            FoundId[NbFound].objid = child_id.objid;
            FoundId[NbFound].osnum = child_id.osnum;

            __DBGpr_obj( "FoundId", FoundId[NbFound]);
            NbFound++;
           }
         } /* for i0 */

         classid = OPP_VDdrawing_class_id; 

         if ( NbFound ) {

            /* TR 179800742 */
            for ( i = 0; i < NbFound; i++ ) { 
              status =
    	      om$send(msg = message NDmacro.ACreturn_foot(msg,"",
                                        &par_obj, NULL, NULL ),
              senderid = FoundId[i].objid,
              targetid = FoundId[i].objid,
              targetos = FoundId[i].osnum );
              
              __DBGpr_obj(" par_obj ", par_obj);
    	    
	      /* find the VDdrawing object */ 
               status = om$get_objid_at_index(
                                        osnum = FoundId[i].osnum ,
                                        objid = FoundId[i].objid ,
                                        p_chanselect = &children_chan,
                                        index = 0 ,
                                        objidaddr = &Ref.objid,
                                        osnumaddr = &Ref.osnum );
               if( status &1 ) {
                  clid = 0;
                  om$get_classid (objid         = Ref.objid,
                                 osnum         = Ref.osnum,
                                 p_classid     = &clid );
                  if ( clid == classid ) {
                    status = VDcomp_drwview( msg, Ref, drawview);
                    if ( status &*msg&1) {
		      drwObj->objid = Ref.objid;               
		      drwObj->osnum = Ref.osnum;               
                      __DBGpr_obj( " Find VDdrawing object", *drwObj);
                      break;
                    }
                  }
               }
           } /* for i */
         } /* if FoundId */
      }  /* if lobj */ 
   } /* if cnt */

wrapup:
   _FREE( FoundId );
   _FREE( lobj );
   End
   return status;
}

/* -----------------------------------------------------------
 * Originally from VDn_drawingi.I
 */
NDsort_per_OS1(nb_in,list1,nb_out)
int nb_in,*nb_out;
struct GRid *list1;
/*.NDsort_per_OS*/
{
IGRint i,j;
GRspacenum work_os;
struct GRid tmp_list1;

/* make sure that the objects are sorted per osnum */

work_os = list1[0].osnum;


i = 0;
j = nb_in - 1;
do
 {
  while (i<=j)
    { /*"test %d same\n",i*/
      if(list1[i].osnum == work_os) i++; else break;}

  /*| mismatched OS found */

  while (i<=j)
    { /*" test %d different\n",j*/
      if(list1[j].osnum != work_os) j--; else break;}

  if(i<j) 
   {
    /*" permutation  i %d j %d\n",i,j*/
    tmp_list1 = list1[i];
    list1[i]  = list1[j];
    list1[j]  = tmp_list1;
    i++;
    j--;
   }
 } while(i<=j);
 *nb_out = i;
return 1;
}

/* Compare the context of the object with the context passed in arguments */

VDsame_context(obj,first,first_matrix)
struct GRid * obj;
short first;
double *first_matrix;
{
 double matrix[16],fabs();
 short type;
 long status,loc_msg;
 int j;
 struct GRid model;

 status = om$send(msg = message NDmacro.ACreturn_foot(&loc_msg,"",
                                &model,&type,matrix),
		    senderid = NULL_OBJID,
                    targetid = obj->objid,
                    targetos = obj->osnum);
 if(!(status&loc_msg&1)) return FALSE;

 if(type != first) return FALSE;
 for(j=0;j<16;j++)
    {if(fabs(matrix[j]-first_matrix[j]) > 1.e-6) return FALSE;}

 return TRUE;
}

NDsort_per_context(nb_in,list1,nb_out)
int nb_in,*nb_out;
struct GRid *list1;
/*.NDsort_per_context*/
{
IGRint i,j;
struct GRid tmp_list1,model;
double first_matrix[16];
short first;
long loc_msg,status;

/* make sure that the objects are sorted per context, it means they all
   correpond to the same model/ drawing transformation matrix */

   status = om$send(msg = message NDmacro.ACreturn_foot(&loc_msg,"",
                                &model,&first,first_matrix),
		    senderid = NULL_OBJID,
                    targetid = list1[0].objid,
                    targetos = list1[0].osnum);
   if(!(status&loc_msg&1)) {*nb_out =1; return OM_S_SUCCESS;}

i = 0;
j = nb_in - 1;
do
 {
  while (i<=j)
    { /*"test %d same\n",i*/
      if(VDsame_context(list1+i,first,first_matrix)) i++; else break;}

  /*| mismatched context found */

  while (i<=j)
    { /*" test %d different\n",j*/
      if(!VDsame_context(list1+j,first,first_matrix)) j--; else break;}
  if(i<j) 
   {
    /*" permutation  i %d j %d\n",i,j*/
    tmp_list1 = list1[i];
    list1[i]  = list1[j];
    list1[j]  = tmp_list1;
    i++;
    j--;
   }
 } while(i<=j);
 *nb_out = i;
return 1;
}

#argsused
VDchg_scale(obj,new_scale,new_exp,md_env)
struct GRid *obj,*new_exp;
double new_scale;
struct GRmd_env *md_env;
{
 long status,loc_msg,ret_code;
 struct GRid old_exp;
 double old_scale,fabs();
/* 
   It the macro has a template named scale  verify its value and change if
   necessary 
*/

 ret_code = 0;
 status = om$send(msg = message ACcpx.ACfind_temp_obj
					    ((int *)&loc_msg,"scale",&old_exp),
		  senderid = NULL_OBJID,
		  targetid = obj->objid,
		  targetos = obj->osnum);
 if(status&loc_msg&1)
  {
   status = om$send(msg = message expression.NDgive_value(&old_scale),
		    senderid = NULL_OBJID,
		    targetid = old_exp.objid,
		    targetos = old_exp.osnum);
   

   if(fabs(old_scale-new_scale) > 1.e-3)
    {
     status = om$send(msg = message NDnode.NDchange_connect
						       (1,&old_exp,new_exp),
		    senderid = NULL_OBJID,
		    targetid = obj->objid,
		    targetos = obj->osnum);
     ret_code = 1;
    }
  }
 return ret_code;
}

/* 
   Store in the context object info like model file name, displayable
   level and window information by subclassing GRcontext into VDcontext
*/

VDstore_levels_and_vol(source, nb_att, levels, point, vector, md_env)
struct	GRid 	 *source;
int		 nb_att;
int		 *levels;
double		 *point,*vector;
struct	GRmd_env *md_env;
{
IGRlong status,msg,is_VDcontext;
struct GRid context,ref;
short mx_type = MAIDMX;
double matrix[16],origin[3];
GRrange range;
IGRboolean world;
int ref_levels[32],i;
int i_att, nb_context=0;
struct IGRlbsys lbs;
GRclassid context_class;

  IGRchar setupName[128];

 for(i_att=0;i_att<nb_att;i_att++){

  /*
   * Get from source element context and reference file attachement
   */
  status = VDget_ctx_ref2(&source[i_att],&context,&ref);

  if( context.objid == NULL_OBJID ) continue ;

  /*
   * Check if context has already been modified to VDcontext and if
   * reference file is there 
   */

  status = om$get_classid(	objid = context.objid,
				osnum = context.osnum,
				p_classid = &context_class);
  as$status(action = RET_STATUS);

  is_VDcontext = 0;
  is_VDcontext = om$is_ancestry_valid(superclassid = OPP_VDcontext_class_id,
 			 		subclassid = context_class);

  /*
   * To be sure a new context will be calculated, we assume the existing
   * context (GRcontext/VDcontext) will be reclaculated.
   */

  if( is_VDcontext == OM_S_SUCCESS && ref.objid != NULL_OBJID){
    nb_context++;

    /*
    ** TR179801989 by Ming
    */
    VDdrwGetSetupFileName(setupName);

    status =
    om$send(msg = message VDcontext.VDset_setup_name(setupName),
            targetid = context.objid,
            targetos = context.osnum,
            senderid = NULL_OBJID);

    continue;
  }
  else if(ref.objid == NULL_OBJID){
    continue;
  }

  /*
   * get level displayable in view and in reference file attachement
   */
  status =
  om$send(msg = message GRreffile.GRgetlevels(&msg,ref_levels),
	  senderid = NULL_OBJID,
	  targetid = ref.objid,
	  targetos = ref.osnum);
  as$status(action = RET_STATUS);
  for(i=0;i<32;i++) ref_levels[i] = ref_levels[i] & levels[i];

  /*
   *  get lbs definition
   */
  MAidmx(&msg,matrix);

  /*
   * reference file origin
   */

  {
    struct GRref_instance_data rfi;
    struct GRinquire_list inq[2];
    IGRboolean pass = FALSE;
    int msg1;
 
    inq[0].var = REFERENCE_INSTANCE_DATA;
    inq[0].num_requested = sizeof(rfi);
    inq[0].var_ptr = (char *) &rfi;
    inq[1].var = END_REPORT_REQUEST;

    status =
    om$send(msg = message GRreffile.GRinquireref(&msg,md_env,inq,&msg1,
						       &pass,NULL),
	    senderid = NULL_OBJID,
	    targetid = ref.objid,
	    targetos = ref.osnum);

    origin[0] = rfi.ref_to_master_matrix[0] * rfi.vw_origin[0] +
                rfi.ref_to_master_matrix[1] * rfi.vw_origin[1] +
                rfi.ref_to_master_matrix[2] * rfi.vw_origin[2] +
                rfi.ref_to_master_matrix[3] ;

    origin[1] = rfi.ref_to_master_matrix[4] * rfi.vw_origin[0] +
                rfi.ref_to_master_matrix[5] * rfi.vw_origin[1] +
                rfi.ref_to_master_matrix[6] * rfi.vw_origin[2] +
                rfi.ref_to_master_matrix[7] ;

    origin[2] = rfi.ref_to_master_matrix[8]  * rfi.vw_origin[0] +
                rfi.ref_to_master_matrix[9]  * rfi.vw_origin[1] +
                rfi.ref_to_master_matrix[10] * rfi.vw_origin[2] +
                rfi.ref_to_master_matrix[11] ;
  }
		  
  world = FALSE;
  status =
  om$send(msg = message GRgraphics.GRgetrang(&msg,&mx_type,matrix,&world,range),
	  senderid = NULL_OBJID,
	  targetid = ref.objid,
	  targetos = ref.osnum);
  as$status(action = RET_STATUS);

  MAidmx(&msg,lbs.matrix);
  lbs.diag_pt1[0] = range[0] - origin[0];
  lbs.diag_pt1[1] = range[1] - origin[1];
  lbs.diag_pt1[2] = range[2] - origin[2];
  lbs.diag_pt2[0] = range[3] - origin[0];
  lbs.diag_pt2[1] = range[4] - origin[1];
  lbs.diag_pt2[2] = range[5] - origin[2];
  lbs.matrix[3]  = origin[0];
  lbs.matrix[7]  = origin[1];
  lbs.matrix[11] = origin[2];

  /* 
   * Store reference file attachement info in the context itself
   */

  status = 1;
  if( is_VDcontext != OM_S_SUCCESS ){
    if( om$is_ancestry_valid(superclassid = OPP_VDcontext_class_id,
			       subclassid = context_class ) != OM_S_SUCCESS ){
      status =
      om$change_class(	objid = context.objid,
			osnum = context.osnum,
			classname = "VDcontext");

  if(status&1){

    nb_context++;

    status =
    om$send(msg = message VDcontext.VDset_level(ref_levels),
	    targetid = context.objid,
	    targetos = context.osnum,
	    senderid = NULL_OBJID);
    status =
    om$send(msg = message VDcontext.VDset_lbs(&lbs),
	    targetid = context.objid,
	    targetos = context.osnum,
	    senderid = NULL_OBJID);
    status =
    om$send(msg = message VDcontext.VDset_proj_view(point,vector),
	    targetid = context.objid,
	    targetos = context.osnum,
	    senderid = NULL_OBJID);

    VDdrwGetSetupFileName(setupName);

    status =
    om$send(msg = message VDcontext.VDset_setup_name(setupName),
            targetid = context.objid,
            targetos = context.osnum,
            senderid = NULL_OBJID);
    }
   }
  }
 }

 if (! nb_context ) return OM_W_ABORT;

 return OM_S_SUCCESS;
 
}

end implementation VDm_drawing;
