/* $Id: DrwFrame.I,v 1.4 2002/05/17 20:32:58 ramarao Exp $  */
 
/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:        vds/smframe/drw / DrwFrame.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: DrwFrame.I,v $
 *      Revision 1.4  2002/05/17 20:32:58  ramarao
 *      Fixed TR# 6308.
 *
 *      Revision 1.3  2001/06/24 18:13:13  jayadev
 *      changes for modify iso frame command
 *
 *      Revision 1.2  2001/05/24 20:33:44  jayadev
 *      TR# MP5230
 *
 *      Revision 1.1.1.1  2001/01/04 21:07:34  cvs
 *      Initial import to CVS
 *
# Revision 1.9  2000/01/27  16:55:24  pinnacle
# ylong
#
# Revision 1.8  1999/12/10  23:20:14  pinnacle
# CR179900942
#
# Revision 1.7  1999/12/10  15:34:24  pinnacle
# CR179900941
#
# Revision 1.6  1999/04/09  19:50:54  pinnacle
# Replaced: smframe/drw/DrwFrame.I for:  by mdong for vds
#
# Revision 1.5  1999/02/12  19:12:56  pinnacle
# Replaced: smframe/drw/DrwFrame.I for:  by mdong for vds
#
# Revision 1.4  1998/12/03  14:23:30  pinnacle
# Replaced: smframe/drw/DrwFrame.I for:  by mdong for vds
#
# Revision 1.3  1998/10/28  22:06:20  pinnacle
# Replaced: smframe/drw/DrwFrame.I for:  by mdong for vds
#
# Revision 1.2  1998/10/23  13:31:42  pinnacle
# Replaced: smframe/drw/DrwFrame.I for:  by mdong for vds
#
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
# Revision 1.9  1998/03/05  22:45:32  pinnacle
# Replaced: smframe/drw/DrwFrame.I for:  by yzhu for vds
#
# Revision 1.7  1998/02/19  22:11:42  pinnacle
# Replaced: smframe/drw/DrwFrame.I for:  by yzhu for vds
#
# Revision 1.6  1998/01/15  14:24:06  pinnacle
# Replaced: smframe/drw/DrwFrame.I for:  by yzhu for vds
#
# Revision 1.5  1998/01/05  18:44:14  pinnacle
# Replaced: smframe/drw/DrwFrame.I for:  by yzhu for vds
#
# Revision 1.4  1997/12/17  14:37:42  pinnacle
# Replaced: smframe/drw/DrwFrame.I for:  by yzhu for vds
#
# Revision 1.3  1997/10/31  22:20:40  pinnacle
# UnInit warning
#
# Revision 1.2  1997/10/07  14:53:50  pinnacle
# Replaced: smframe/drw/DrwFrame.I for:  by yzhu for vds
#
# Revision 1.1  1997/05/08  13:20:44  pinnacle
# New project VDS 250
#
# Revision 1.1  1996/07/19  20:33:52  pinnacle
# Create VDS 241 project
#
# Revision 1.3  1996/04/19  12:54:50  pinnacle
# Replaced: smframe/drw/DrwFrame.I for:  by azuurhou for vds.240
#
# Revision 1.2  1996/04/17  14:29:28  pinnacle
# Replaced: smframe/cmd/SMModNotif.I for:  by ksundar for vds.240
#
# Revision 1.1  1994/11/14  22:42:32  pinnacle
# Create vds.240 from vds.232
#
# Revision 1.1  1994/11/08  16:07:00  pinnacle
# create vds.232
 *
 * History:
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *	10/31/97	ah		UnInit warning
 *	09/25/98	Ming		TR179801648
 *	11/02/98	Ming		TR179801745
 *	11/02/98	Ming		TR179801899
 *	12/10/99	ylong		TR179900941
 *	12/10/99	ylong		TR179900942
 *	01/27/00	ylong		Fixed to be compatible with CLIX
 *      05/24/01        Jayadev         TR5230 
 *      06/23/01        Jayadev         CRXXXX -  modify iso frames 
 * -------------------------------------------------------------------*/

class implementation VDdrawing;

%safe
#include <math.h>
%endsafe

#include <stdio.h>
#include <string.h>
#include "msdef.h"
#include "refdef.h"
#include "madef.h"

#include "asbox.h"
#include "AS_status.h"
#include "AS_debug.h"
#include "grerr.h"
#include "grgsdef.h"

#include "grmacros.h"

#include "DItypedef.h"
#include "DIdef.h"
#include "DIglob.h"
#include "DIprims.h"
#include "gotextdef.h"
#include "grdpb.h"
#include "nddef.h"
#include "exmacros.h"

//#define  vdsDEBUG
#include "VDmem.h"
#include "VDobj.h"
#include "VDchn.h"
#include "v_dbgmacros.h"
#include "vddlodef.h"
#include "vddlomacros.h"

#include "bsconic.h"
#include "bserr.h"
#include "bsparameters.h"
#include "bsdistptpt.h"
#include "grdpbmacros.h"

from GRreffile	import GRinquireref;
from ACcpx_defn import ACgive_name,ACgive_feet_desc;
from GRcontext  import GRgetmodule_env, GRgetinstance;
from VDcontext  import VDget_extract_info;
from expression import modify;
from GRcurve    import GRendpts;
from GRcompcurve import EMmakecomp;
from GRlinear	import GRputpolyline, GRgetpolyline;
from GRtext	import GRchgtextattr;
from GRtext	import GRgettxattr;
from GRtext	import GRreplace_text;
from SMframe    import SMgive_rel_position;
from SMInfPlane import SMgive_rel_position;
from GRdrawview import GRget_model_matrix;

extern GRclassid OPP_Gexp_class_id, OPP_Gtext_exp_class_id,
		 OPP_VDgeom_class_id, OPP_GRcompcurve_class_id;

#define GEOM_PART  "constructs:VDgeomdef"
#define PREDEFINED_FEET 4

extern int SMGetFrmPosTxt();
extern double fabs();
/*
	#define PREDEF0 "macro"
	#define PREDEF1 "occurence"
	#define PREDEF2 "design"
	#define PREDEF3 "quantity"
 */

/*
   Clip curve inside right prism
*/

#define  OUTSIDE  0
#define  INSIDE   1
#define  OVERLAP  2

extern    OMuword    OPP_GRdrawview_class_id;
extern    OMuword    OPP_GRreffile_class_id;
extern    OMuword    OPP_VDcontext_class_id;
extern    OMuword    OPP_GRcontext_class_id;
extern    OMuword    OPP_ACpretendin_class_id;
extern    OMuword    OPP_GRdvattach_class_id;
extern	GRclassid		OPP_SMInfPlane_class_id,
				OPP_SMframe_class_id ;

#define drw_clear_state         65535   /* 1111 1111 xxxx xxxx */
#define drw_scale_incr          32768   /* 1000 0000 xxxx xxxx */

#define drw_scale_two           512     /* 0000 0010 xxxx xxxx */
#define drw_scale_three         1024    /* 0000 0100 xxxx xxxx */
#define drw_scale_four          2048    /* 0000 1000 xxxx xxxx */
#define drw_without_text        4096    /* 0001 0000 xxxx xxxx */
#define drw_just_top            8192    /* 0010 0000 xxxx xxxx */


/**********************************************************************/
/* function VDget_drwViewRange know frame object                      */
/**********************************************************************/
long VDget_drwViewRange(msg, obj, range)
long                   *msg;
struct  GRid           obj;
GRrange		       range;
{
IGRint                  status;
IGRboolean		world;
struct GRmd_env         mod_env;
OM_S_OBJECT_LINKAGE     *refList = NULL;
OM_S_OBJECT_LINKAGE     fatObj, refObj, lisObj, viewObj, attObj;
char                    classname[80]; /* classname  */
OM_S_CHANSELECT         father_chan, listeners_chan,
                        reffile_chan, owner_chan;
OMuint                  list_count,
                        lst_count;
int                     size_int, i, flag_find;

 
 SetProc( VDget_drwViewRange ); Begin
				  
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
 __DBGpr_com("----111");
 
 status = om$make_chanselect ( channame = "ASsource.listeners",
                               p_chanselect = &listeners_chan );
 if (!(1 & status)) {
   *msg = MSFAIL;
   status = MSFAIL;
   goto wrapup;
 }
 
 __DBGpr_com("----222");
 status = om$make_chanselect ( channame = "GRcontext.to_reffile",
                               p_chanselect = &reffile_chan );
 if (!(1 & status)) {
   *msg = MSFAIL;
   status = MSFAIL;
   goto wrapup;
 }
 __DBGpr_com("----333");
 
 status = om$make_chanselect ( channame = "GRconnector.to_owners",
                               p_chanselect = &owner_chan );
 if (!(1 & status)) {
   *msg = MSFAIL;
   status = MSFAIL;
   goto wrapup;
 }
 __DBGpr_com("----444");
 
 /* find ACpretendin object in NDfather.fatherG*/
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
 status = om$get_channel_count( objid = fatObj.S_objid,
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
     status = om$get_classname (objid     = refList[i].S_objid,
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
     /* goto find the ACpretendin object from list */
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
   /* get object from the father_chan */
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
     /* goto find the ACpretendin object from list */
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
 if ( !flag_find )  { /* not find GRdvattach */
   *msg = MSFAIL;
   status = MSFAIL;
   goto wrapup;
 }
 _FREE( refList ); 
 
 /* get range */
 world = FALSE;
 status =
   om$send(msg = message GRgraphics.GRgetrang(msg,
					      &mod_env.md_env.matrix_type,
					      mod_env.md_env.matrix,
					      &world,
					      range),
	   senderid = viewObj.S_objid,
	   targetid = viewObj.S_objid,
	   targetos = viewObj.osnum);
 CheckRC( status, *msg );
 
 wrapup:
 _FREE( refList ); 
 End
   return  status;
}

/**********************************************************************/
/* modified SMframe_drw_layout function 			      */
/**********************************************************************/
SMframe_drw_layout1( obj, md_env, geom, nb_geom)
  struct  GRid            *obj;
struct  GRmd_env        *md_env;
struct  GRid            **geom;
IGRint                  *nb_geom;
{
IGRlong                 msg, size, ret_size;
IGRint                  status, rc1,
                        incr;
IGRint                  action = 1;
IGRint                  i, Lnb_geom;
struct  GRid            Lgeom[4];
GRclassid               classid;
struct IGRpolyline      polyline;
IGRdouble               points[6];
GRrange                 range;
GRrange                 range1;
GRobjid                 new_objid = NULL_OBJID ;
IGRdouble               vector[3], // p3[15],
                        *p1,  *p2;
IGRpoint		pd1,  pd2, pd3, pd4, pt1, pt2, tmp_p1, tmp_p2;
IGRdouble               Fact = 1.0 ;
IGRboolean              world = 1;
struct GRpost_info      post_info;
int                     text_index = -1;
int                     attr, off_dir;
IGRdouble       	vheight, vwidth; //  p2p1;

struct IGRlbsys         *absgptr = NULL ;
struct GRdpb_text_symb  text_symb;
struct VDdrwFrmPar 	drwFrmPar;
VD_drwLoInfo            drwInfo;
double			frmHeight = 0;
short			frmColor = 0;
int			frmStyle = 0,frmWeight = 0 , char_num = 0, kk;
double                  lef_x, low_y, rig_x, hig_y, text_range_height = 0;
IGRpoint		p_elem1, p_elem2;
IGRdouble		frame_pos;
IGRint			frame_label, count, i_index, flag;
IGRshort		syntax_length;
struct GRid		model_obj, source, pretendID;
IGRchar			occurance_name[DI_PATH_MAX];
IGRchar			pos_txt[80];
struct GRid		frame_def, refLine;
IGRpoint		intx_point;
IGRint			direction0, direction1, j, range_index;
long          		bs_rc;
IGRdouble		shift_nor[3];
struct GRmd_env		model_env;
struct GRid		plane;
struct IGRplane		def_plane;
IGRdouble		point[3], normal[3], frame_normal[3], point_p[3];
IGRdouble               inter_p[3], interval;
IGRdouble		text_norm[3], text_orie[3], text_perp[3], text_orig[3];
IGRdouble		trvec[3];
IGRdouble		p_min, p_max;
struct IGRpolyline      polyline_elem;
IGRdouble		points_elem[6], active_angle;
IGRmatrix               matrix;
IGRdouble		y_dir[4], y_normal[4];
IGRdouble		centerline_p0[3], centerline_p1[3];
struct ret_struct       temp1_rts;

//struct GRsymbology      symb;
//long			nbytex_transferred, nbiytes_in_buffer;
 
 SetProc( SMframe_drw_layout1 ); Begin
				   
 p1 = p2 = NULL;
 off_dir = 0;
 model_obj.objid = NULL_OBJID;
 pretendID.objid = NULL_OBJID;
 refLine.objid   = NULL_OBJID;
 direction0 = direction1 = 0;
 
 __DBGpr_int ( "nb_geom", *nb_geom);
 __DBGpr_obj ( "obj", *obj);               /* VDdrawing object */
 
 post_info.construct_flag = TRUE ;
 
 vdchn$Get2(objID  = obj,
	    chnIDx = VDCHN_IDX_PARENT,
	    nth    = 1,
	    outID  = &pretendID );
 if(pretendID.objid != NULL_OBJID)
 {
   status =
     om$send( msg      = message NDmacro.ACreturn_foot(&msg,
				 "",
				 &refLine,
				 &model_env.md_env.matrix_type,
				 model_env.md_env.matrix),
	      senderid = NULL_OBJID,
	      targetid = pretendID.objid,
	      targetos = pretendID.osnum );
   __DBGpr_obj("refLine ",refLine);
 }
 
 /* get drawing frame parameters */ 
 status = 
   om$send(msg = message VDdrawing.VDget_DrwFrParaIns( &msg, &drwFrmPar),
	   senderid = NULL_OBJID,
	   targetid = obj->objid,
	   targetos = obj->osnum );
 if(refLine.objid != NULL_OBJID)
 {
   model_env.md_id.osnum = refLine.osnum;
   status =
     ex$get_modid( mod_osnum = model_env.md_id.osnum,
		   mod_id    = &model_env.md_id.objid );
   if(drwFrmPar.elementobj.objid != refLine.objid)
   {
     drwFrmPar.elementobj = refLine;
     drwFrmPar.element_env= model_env;
   }
   status =
     om$send(msg = message VDdrawing.VDset_DrwFrParaIns(
                                     &msg, drwFrmPar),
	     senderid = NULL_OBJID,
	     targetid = obj->objid,
	     targetos = obj->osnum );
 }
 __DBGpr_obj("ELEMENT ",drwFrmPar.elementobj);
 __DBGpr_int( "prfact", drwFrmPar.prfact);
 __DBGpr_int( "ISOFLAG", drwFrmPar.iso_flag);
 __DBGpr_int( "tx_flag", drwFrmPar.tx_flag);
 __DBGpr_int( "pr_flag", drwFrmPar.pr_flag);
 __DBGpr_int( "md_flag", drwFrmPar.md_flag);
 __DBGpr_int( "symb_flag", drwFrmPar.symb_flag);
 __DBGpr_dbl( "frpos ", drwFrmPar.frpos);
 __DBGpr_int( "txpos ", drwFrmPar.txpos);
 __DBGpr_vec( "range_p1", drwFrmPar.range_p1);
 __DBGpr_vec( "range_p2", drwFrmPar.range_p2);
 __DBGpr_str( "act_frname", drwFrmPar.frname);
 __DBGpr_str( "act_frsys", drwFrmPar.frsys);
 __DBGpr_int( "iso_flag", drwFrmPar.iso_flag);
 /* TR179801899 by Ming
 ** Receive the model objects of the drawing objects (obj)
 */
 
 /*
   if( drwFrmPar.centerline_flag )
      {
      flag = FALSE;
      status =
      om$send( msg      = message GRdrawview.GRget_model_matrix(&msg,
                                             md_env,
                                             flag,
                                             matrix),
                         senderid = NULL_OBJID,
                         targetid = drwFrmPar.drawingview.objid,
                         targetos = drwFrmPar.drawingview.osnum );
      if( !(status&msg&1) )
      {
      printf("GRget_model_matrix is failed!\n");
      return OM_S_SUCCESS;
      }
      
      y_dir[0] = 0.0;
      y_dir[1] = 100.0;
      y_dir[2] = 0.0;
      y_dir[3] = 1.0;
      
      BSmult_mats( 4, 4, matrix, FALSE, 4, 1,
                   y_dir, FALSE, y_normal, &bs_rc );
      if( (fabs(y_normal[0]-matrix[3]) < 0.0000001) &&
      (fabs(y_normal[2]-matrix[7]) < 0.0000001) )
      {
      return OM_S_SUCCESS;
      }
      
      centerline_p0[0] = matrix[3];
      centerline_p0[1] = matrix[7];
      centerline_p0[2] = 0.0;
      centerline_p1[0] = y_normal[0];
      centerline_p1[1] = y_normal[1];
      centerline_p1[2] = 0.0;
      }
 */
 
      status =
      om$send( msg      = message NDnode.NDget_objects(ND_ROOT,
                                                       &source,
                                                       1,
                                                       NULL,
                                                       0,
                                                       OM_K_MAXINT,
                                                       &count),
               senderid = NULL_OBJID,
               targetid = obj->objid,
               targetos = obj->osnum );
      if( !(status&1) ) return OM_S_SUCCESS;

      status =
      om$send( msg      = message NDmacro.ACreturn_foot(
					&msg,
                                        "",
                                        &model_obj,
					&model_env.md_env.matrix_type,
                                        model_env.md_env.matrix),
               senderid = NULL_OBJID,
               targetid = source.objid,
               targetos = source.osnum );
      if( !(status&msg&1) ) return OM_S_SUCCESS;
      
      model_env.md_id.osnum = model_obj.osnum;
      model_env.md_id.objid = NULL_OBJID;
      
      status =
	ex$get_modid( mod_osnum = model_env.md_id.osnum,
		      mod_id    = &model_env.md_id.objid );
      
      if( !drwFrmPar.iso_flag )
      {
        /* get drwing view  range 2/19/98 */
        status = VDget_drwViewRange(&msg, *obj, range1);
        if ( 1 & status ) {
	  drwFrmPar.range_p1[0] = range1[0];
	  drwFrmPar.range_p1[1] = range1[1];
	  drwFrmPar.range_p1[2] = range1[2];
	  drwFrmPar.range_p2[0] = range1[3];
	  drwFrmPar.range_p2[1] = range1[4];
	  drwFrmPar.range_p2[2] = range1[5];
	  __DBGpr_vec( "new range_p1", drwFrmPar.range_p1);
	  __DBGpr_vec( "new range_p2", drwFrmPar.range_p2);
	  /* used for ACconstruct_feet */
	  status =
	    om$send(msg = message VDdrawing.VDset_DrwFrParaIns(
	                                       &msg, drwFrmPar),
		    senderid = NULL_OBJID,
		    targetid = obj->objid,
		    targetos = obj->osnum );
	  
        }
        /* get char number of frame name */
        char_num = strlen (drwFrmPar.frname);
	
        low_y = drwFrmPar.range_p1[1];
        hig_y = drwFrmPar.range_p2[1];
        lef_x = drwFrmPar.range_p1[0];
        rig_x = drwFrmPar.range_p2[0];
	
        __DBGpr_dbl( "width", rig_x - lef_x);
        __DBGpr_dbl( "height", hig_y - low_y);
	
        /* default text symb */
        status =
	  gr$get_text_symb(buffer = &text_symb);
        frmHeight = text_symb.Active_height;
        __DBGpr_dbl( "frmHeight0", frmHeight);
	
	
        /* get frame height/color/style/weight from layout para form */
        if ( drwFrmPar.symb_flag ) { /* using symb from layout form */
          for ( i = VD_K_drwLO_frmHeight; i <= VD_K_drwLO_frmWeight; i++) {
	    status = vd$drw_layout_info ( msg = &msg,
					  type = i,
					  info    = &drwInfo );
	    if (i == VD_K_drwLO_frmHeight )
	      frmHeight = drwInfo.val.dValue;
	    else if (i == VD_K_drwLO_frmColor )
	      frmColor = drwInfo.val.sValue;
	    else if (i == VD_K_drwLO_frmStyle )
	      frmStyle = drwInfo.val.iValue;
           else if (i == VD_K_drwLO_frmWeight )
	     frmWeight = drwInfo.val.iValue;
          }
        }
        else {
	  frmColor = -1;
	  frmStyle = -1;
	  frmWeight = -1;
        }
	
        __DBGpr_dbl ("frmHeight", frmHeight);
        __DBGpr_int ("frmColor", frmColor);
        __DBGpr_int ("frmStyle", frmStyle);
        __DBGpr_int ("frmWeight", frmWeight);
	
	
        /*  find object.  */
        Lnb_geom = *nb_geom ;
        for( i=0 ; i<Lnb_geom && i<4 ; i++ ){
	  Lgeom[i] = (*geom)[i] ;
        }
	
        if( drwFrmPar.md_flag != 1) goto wrapup;
	
        /* get point from real view range */
        pd1[0] = drwFrmPar.range_p1[0];
        pd1[1] = drwFrmPar.range_p1[1];
        pd1[2] = 0;

        pd2[0] = drwFrmPar.range_p2[0];
        pd2[1] = drwFrmPar.range_p1[1];
        pd2[2] = 0;
	
        pd3[0] = drwFrmPar.range_p2[0];
        pd3[1] = drwFrmPar.range_p2[1];
        pd3[2] = 0;
	
        pd4[0] = drwFrmPar.range_p1[0];
        pd4[1] = drwFrmPar.range_p2[1];
        pd4[2] = 0;
	
        vheight = pd3[1] - pd1[1];
        vwidth  = pd3[0] - pd1[0];
	
        __DBGpr_vec(" point pd1", pd1 );
        __DBGpr_vec(" point pd3", pd3 );
        __DBGpr_dbl( "vheight", vheight);
        __DBGpr_dbl( "vwidth", vwidth);
	
        polyline.points         = points;
        polyline.num_points     = 2 ;
	
        /*
         * find if it is  text object first.
         */
        for( i=0 ; i<Lnb_geom && i<4 ; i++ ){
	  status =
	    om$get_classid( osnum   = Lgeom[i].osnum,
			    objid   = Lgeom[i].objid,
			    p_classid = &classid );

	  if( om$is_ancestry_valid(
	    subclassid      = classid,
	    superclassname  = "GRtext" ) == OM_S_SUCCESS ){
	    
	    __DBGpr_int ( "text object for i = ", i);
	    __DBGpr_obj ( "text object ", Lgeom[i]);
	    
	    /* TR179801648 by Ming */
	    if( drwFrmPar.labelText&1 )
	    {
	      syntax_length = 0;
	      
	      /*
	      ** Erase the original text objects on screen
	      */
	      gr$display_object( object_id = &Lgeom[i],
				 mode      = GRbeheo );
	      
	      /*
	      ** Find the ACrg containing glob info of this frame
	      */
	      status =
		om$send( msg = message NDnode.NDget_objects(ND_ROOT,
					      &frame_def,
					      1,
					      NULL,
					      2,
					      2,
					      &count),
			 senderid = NULL_OBJID,
			 targetid = model_obj.objid,
			 targetos = model_obj.osnum );
	      if( !(status&1) ) return OM_S_SUCCESS;
	      
	      /*
	      ** Find the real position of each text (label)
	      */
	      status =
		om$send( msg      = message SMframe.SMgive_rel_position(&msg,
									&frame_pos),
                   senderid = NULL_OBJID,
                   targetid = model_obj.objid,
                   targetos = model_obj.osnum );

	      if( !(status&msg&1) ) return OM_S_SUCCESS;
	      
	      /*
	      ** Fill pos_txt value only if frame system is in NAME_BY_DIST
	      */
	      if( SMGetFrmPosTxt(&frame_def, frame_pos, pos_txt) )
	      {
		sprintf( occurance_name, "%s%s", drwFrmPar.prefix, pos_txt );
	      }
	      else
	      {
		frame_label = floor( frame_pos );
		sprintf( occurance_name, "%s%d", drwFrmPar.prefix, frame_label );
	      }
	      syntax_length = strlen( occurance_name );
	      for( i_index = 0 ; i_index < syntax_length ; ++i_index )
		occurance_name[i_index] = toupper(occurance_name[i_index]);
	      
	      if( syntax_length )
	      {
		/*
		** Replace the original text by the real position
		*/
		status =
		  om$send( msg      = message GRtext.GRreplace_text(
                                        &msg,
                                        md_env,
                                        syntax_length,
                                        (unsigned char *)occurance_name),
                     senderid = NULL_OBJID,
                     targetid = Lgeom[i].objid,
                     targetos = Lgeom[i].osnum );
		if( !(status&msg&1) ) return OM_S_SUCCESS;
	      }
	    }
	    
	    /* CR179900941 by ylong */
	    else if( drwFrmPar.nameCase )
	    {
	      IGRshort		text_length ;
	      IGRuchar		*text_string ;
	      
	      text_length = 0;
	      text_string = NULL ;
	      
	      /*
	      ** Erase the original text objects on screen
	      */
	      gr$display_object( object_id = &Lgeom[i],
				 mode      = GRbeheo );
	      status =
		om$send(msg    = message GRtext.GRgettxattr(
		                        &msg,
					NULL,
					&text_length, 
					&text_string) ,
		  senderid = NULL_OBJID,
                  targetid = Lgeom[i].objid, 
                  targetos = Lgeom[i].osnum ) ;

	      if( !(status&msg&1) )  goto get_out ;
	      
	      DMget_exact_str (	text_string, 
				text_length, 
				occurance_name, 
				&text_length);
	      
	      syntax_length = strlen( occurance_name );
	      __DBGpr_int("text_length", text_length );
	      __DBGpr_str("occurance_name", occurance_name );
	      
	      for( i_index = 0 ; i_index < text_length ; ++i_index ) {
		occurance_name[i_index] = toupper(occurance_name[i_index]);
	      }
	      
	      if( text_length )
	      {
		/*
		** Replace the original text by the real position
		*/
		status =
		  om$send( msg      = message GRtext.GRreplace_text(
		                              &msg,
		                              md_env,
		                              text_length,
		                              (unsigned char *)occurance_name),
			   senderid = NULL_OBJID,
			   targetid = Lgeom[i].objid,
			   targetos = Lgeom[i].osnum );
		if( !(status&msg&1) ) {
		  __DBGpr_com("GRtext.GRreplace_text failed");
		  //return OM_S_SUCCESS;
		}
	      }
	      
	    get_out:
	      _FREE( text_string );
	    }
	    
	    /*
	     * object is text object.
	     */
	    status =
	      om$send(msg = message GRgraphics.GRgetrang(
		                                &msg,
                                                &md_env->md_env.matrix_type,
                                                md_env->md_env.matrix,
                                                &world,
                                                range ),
                                targetid = Lgeom[i].objid,
                                targetos = Lgeom[i].osnum,
                                senderid = NULL_OBJID );

	    vector[0] = (range[3] + range[0]) * 0.5 ;
	    vector[1] = (range[4] + range[1]) * 0.5 ;
	    vector[2] = (range[5] + range[2]) * 0.5 ;
	    
	    text_range_height = fabs( range[4] - range[1]);
	    __DBGpr_dbl( " text range0 ", range[0]);
	    __DBGpr_dbl( " text range1 ", range[1]);
	    __DBGpr_dbl( " text range2 ", range[2]);
	    __DBGpr_dbl( " text range3 ", range[3]);
	    __DBGpr_dbl( " text range4 ", range[4]);
	    __DBGpr_dbl( " text range5 ", range[5]);
	    __DBGpr_dbl( " text range heigh ", text_range_height);
	    
	    text_index = i ;
	    __DBGpr_int( " text_index ", text_index);
	    
	    if( !drwFrmPar.tx_flag ){ /* not display text */
	      gr$display_object(
		object_id = &Lgeom[i],
		mode = GRbeheo );
	      status =
		om$send(msg = message Root.delete( 1 ),
			targetid = Lgeom[i].objid,
			targetos = Lgeom[i].osnum,
			senderid = NULL_OBJID );
	      Lgeom[i].objid = NULL_OBJID ;
	    }
	    if ( frmHeight > 0 )  { /* change text size */
	      text_symb.Active_height = frmHeight;
	      text_symb.Active_width  = frmHeight;
	    }
	  }
        }
	
        /* for GR3dlineseg object */
        for( i=0 ; i<Lnb_geom && i<4 ; i++ ){
	  
	  status =
	    om$get_classid( osnum   = Lgeom[i].osnum,
			    objid   = Lgeom[i].objid,
			    p_classid = &classid );
	  
	  if( om$is_ancestry_valid(
	    subclassid      = classid,
	    superclassname  = "GR3dlineseg" ) == OM_S_SUCCESS ){
	    
	    __DBGpr_int ( "line object for i = ", i);
	    __DBGpr_obj ( "line object ", Lgeom[i]);
	    
	    /*  object is line string.  */
	    
	    status =
	      om$send(msg = message GRlinear.GRgetpolyline(
		                                &msg,
                                                &md_env->md_env.matrix_type,
                                                md_env->md_env.matrix,
                                                &action,
                                                &polyline ),
                                targetid = Lgeom[i].objid,
                                targetos = Lgeom[i].osnum,
                                senderid = NULL_OBJID );
	    
	    if( ! (status&msg&1))   continue;
	    
	    p1 = &(points[0]) ;
	    p2 = &(points[3]) ;
	    
	    if( BSdistptpt( &msg, vector, &(points[3]) ) <
		BSdistptpt( &msg, vector, &(points[0]) )){
	      
	      p1 = &(points[3]);
	      p2 = &(points[0]);
	    }
	    
	    __DBGpr_vec(" point p1", p1 );
	    __DBGpr_vec(" point p2", p2 );
	    
	    
	    /* check direction using p1, p2, pd1, pd2 */
	    pt1[0] = p1[0]; pt1[1] = p1[1]; pt1[2] = p1[2];
	    pt2[0] = p2[0]; pt2[1] = p2[1]; pt2[2] = p2[2];
	    
	    status = BSrelplnln (&msg, pt1, pt2, pd1, pd2);
	    if( status == BSCPARALLEL ) {
	      off_dir = 0; /* move along x direction*/
	      /* set line = 2 text height
		 p2[0] = p1[0] + 2*frmHeight; */
	      p2[0] = p1[0] + frmHeight;
	    }
	    else  {
	      off_dir = 1; /* move along y direction*/
	      /* set line = 2 text height
		 p2[1] = p1[1] + 2*frmHeight; */
	      p2[1] = p1[1] + frmHeight;
	    }
	    __DBGpr_vec("  -- point p1", p1 );
	    __DBGpr_vec("  -- point p2", p2 );
	    
	    /* for frame position */
	    /* Commented by Ming for TR179801745
	       if( drwFrmPar.frpos > 1.00 )
	       drwFrmPar.frpos = 1.00;
	       else if (drwFrmPar.frpos < 0.0 )
	       drwFrmPar.frpos = 0;
	    */
	    
	    /* let text_range_height = frmHeight * 1.619 */
	    
	    text_range_height = frmHeight * 1.619 ;
	    if( off_dir == 1) { /* in y direction */
	      __DBGpr_com(  "off_dir == 1" );
	      p2[1] = pd1[1] + p2[1] - p1[1] + vheight*drwFrmPar.frpos;
	      p1[1] = pd1[1] + vheight*drwFrmPar.frpos;
	    }
	    else { /* for x direction */
	      p2[0] = pd1[0] + p2[0] - p1[0]  + vwidth*drwFrmPar.frpos;
	      p1[0] = pd1[0] + vwidth*drwFrmPar.frpos;
	    }
	    
	    __DBGpr_vec(" after point p1", p1 );
	    __DBGpr_vec(" after point p2", p2 );
	    
	    /* change line by factor */
	    if(  drwFrmPar.prfact > 0 ) { /* =  1, 2, 3*/
	      if ( drwFrmPar.pr_flag )  /* extend */
		Fact = ((double) drwFrmPar.prfact + 1.0) ;
	      else    /* reduce */
		//                      Fact = 1.0/((double)drwFrmPar.prfact+ 1.0) ;
		Fact = 1.0 ;
	      
	      __DBGpr_dbl(" Fact", Fact );
	      
	      p2[0] = p1[0] + ((double)Fact * ( p2[0] - p1[0] ));
	      p2[1] = p1[1] + ((double)Fact * ( p2[1] - p1[1] ));
	      p2[2] = p1[2] + ((double)Fact * ( p2[2] - p1[2] ));
	      
	      __DBGpr_vec(" modify point p1", p1 );
	      __DBGpr_vec(" modify point p2", p2 );
	    }
	    else if ( drwFrmPar.prfact < 0 ) { /* for cross */
	      
	      if ( off_dir == 0) {
		p1[0] = pd1[0];
		p2[0] = pd3[0];
	      }
	      else {
		p1[1] = pd1[1];
		p2[1] = pd3[1];
	      }
	      tmp_p1[0] = p1[0];
	      tmp_p1[1] = p1[1];
	      tmp_p1[2] = p1[2];
	      tmp_p2[0] = p2[0];
	      tmp_p2[1] = p2[1];
	      tmp_p2[2] = p2[2];
	    }
	    
	    new_objid = NULL_OBJID ;
	    
	    status =
	      om$send(msg = message GRlinear.GRputpolyline(
                                                &msg,
                                                md_env,
                                                &post_info,
                                                &polyline,
                                                &new_objid ),
                                targetid = Lgeom[i].objid,
                                targetos = Lgeom[i].osnum,
                                senderid = NULL_OBJID );

	    if( !( status&msg&1)) continue;
	    
	    __DBGpr_int(" new_objid", new_objid );
	    Lgeom[i].objid = new_objid ;
	    
          }  /* if */
        } /*for */
	
        /*  refill the list of text.  */
	
        if(     text_index != -1        &&
                p2 != NULL              &&
                Lgeom[text_index].objid != NULL_OBJID ){
	  
          __DBGpr_com(" change text position ");
	  
          /* erase the object.  */
	  /* Commented by Ming for TR179801648
	     gr$display_object(      object_id = &Lgeom[text_index],
	     mode = GRbeheo );
	  */
	  
          /* get the text matrix.  */
          status =
          om$send(msg = message GRvg.GRgenabsg(
                                               &msg,
                                               &md_env->md_env.matrix_type,
                                               md_env->md_env.matrix,
                                               (IGRchar **)&absgptr ),
                        senderid = NULL_OBJID,
                        targetid = Lgeom[text_index].objid,
                        targetos = Lgeom[text_index].osnum );
          if( !( status&msg&1 )){
                        printf(" GRvg.GRgenabsg failed \n");
                        goto wrapup;
          }

          new_objid = NULL_OBJID ;
	  
          text_symb.Active_just = CENTER_BOTTOM ;
	  
     	  /* for frame position */
	  if ( drwFrmPar.txpos == 0 ){ /* bottom/left */
	    if ( drwFrmPar.prfact>= 0) { /* not cross */
	      __DBGpr_com( "Bottom/Left");
	      absgptr->matrix [3] = p1[0];
	      absgptr->matrix [7] = p1[1];
	      absgptr->matrix[11] = p1[2];
	      if ( !off_dir )
		//   text_symb.Active_just = RIGHT_CENTER;
		text_symb.Active_just = LEFT_CENTER;
	      else 
		text_symb.Active_just = CENTER_TOP ;
	    }
	    else {
	      __DBGpr_com( "Cross Bottom/Left");
	      absgptr->matrix [3] = tmp_p1[0];
	      absgptr->matrix [7] = tmp_p1[1];
	      absgptr->matrix[11] = tmp_p1[2];
	      if ( !off_dir )
		//  text_symb.Active_just = RIGHT_CENTER;
		text_symb.Active_just = LEFT_CENTER;
	      else 
		text_symb.Active_just = CENTER_TOP ;
	    }
          }
	  else if ( drwFrmPar.txpos == 1 ){ /* top/right */
	    if ( drwFrmPar.prfact >= 0) { /* not cross */
	      __DBGpr_com( " Top/Right");
	      absgptr->matrix [3] = p2[0];
	      absgptr->matrix [7] = p2[1];
	      if( off_dir ) {  
		absgptr->matrix [7] = p2[1] + text_range_height;
		text_symb.Active_just = CENTER_BASE ;
	      }
	      else  {
		absgptr->matrix [3] = p2[0] + text_range_height;
		//  text_symb.Active_just = LEFT_CENTER;
		text_symb.Active_just = RIGHT_CENTER;
	      } 
	      absgptr->matrix[11] = p2[2];
	    }
	    else {
	      __DBGpr_com( "Cross Top/Right");
	      absgptr->matrix [3] = tmp_p2[0];
	      absgptr->matrix [7] = tmp_p2[1];
	      absgptr->matrix[11] = tmp_p2[2];
	      
	      if( off_dir ) {
		absgptr->matrix [7] = tmp_p2[1] + text_range_height;
		text_symb.Active_just = CENTER_BASE ;
	      }
	      else {
		absgptr->matrix [3] = tmp_p2[0] + text_range_height;
		// text_symb.Active_just = LEFT_CENTER;
		text_symb.Active_just = RIGHT_CENTER;
	      }
	    }
	  }
	  
	  size = sizeof( IGRdouble );
	  status = gr$get_active_angle( msg    = &msg,
					sizbuf = &size,
					buffer = &active_angle,
					nret   = &ret_size );
          if( !(msg&1) ) goto wrapup;
	  
	  if( fabs(active_angle) > 3.14/4.0 ) 
	    text_symb.Active_just = CENTER_CENTER;
	  
	  __DBGpr_vec("tmp_p1", tmp_p1);
	  __DBGpr_vec("tmp_p2", tmp_p2);
	  __DBGpr_vec(" final point p1", p1 );
	  __DBGpr_vec(" final point p2", p2 );
	  
          __DBGpr_int( "text_symb.Active_just", text_symb.Active_just);
          __DBGpr_mat( "MATRIX", absgptr->matrix );
	  
	  
          /* put the new text matrix.  */
          __DBGpr_obj("before post Lgeom[text_index]",Lgeom[text_index]);
	  
          /* change GRTEXT_JUST */
          status =
	    om$send(msg = message GRvg.GRpostabsg(
	                                          &msg,
	                                          md_env,
	                                          &post_info,
	                                          (IGRchar *) absgptr,
	                                          &new_objid ),
                        senderid = NULL_OBJID,
                        targetid = Lgeom[text_index].objid,
                        targetos = Lgeom[text_index].osnum);

          if( !( status&msg&1 )){
	    printf(" GRvg.GRpostabsg failed \n");
	    goto wrapup;
          }
	  
          Lgeom[text_index].objid = new_objid ;
	  
          /* change GRTEXT_HEIGHT */
          attr = GRTEXT_HEIGHT | GRTEXT_WIDTH | GRTEXT_JUST;
	  /*
	    attr = GRTEXT_JUST ;
	  */
	  
          __DBGpr_obj("after post Lgeom[text_index]",Lgeom[text_index]);
          status =
          om$send(msg = message GRtext.GRchgtextattr(
                                               &msg,
                                               md_env,
                                               attr,
                                               &text_symb ),
                        senderid = NULL_OBJID,
                        targetid = Lgeom[text_index].objid,
                        targetos = Lgeom[text_index].osnum);

          if( !( status&msg&1 )){
	    //printf(" GRtext.GRchgtextattr failed \n");
	    goto wrapup;
          }
	  
          Lgeom[text_index].objid = new_objid ;
	  
        } /* if */
      }
      /*
      ** TR179801899 by Ming
      */
      else
      {
        /*
	** default text symb
	*/
        status = gr$get_text_symb( buffer = &text_symb );
        frmHeight = text_symb.Active_height;
  	__DBGpr_dbl( "frmHeight0", frmHeight);
	
	frmColor = -1;
	frmStyle = -1;
	frmWeight = -1;
	
        __DBGpr_dbl ("frmHeight", frmHeight);
        __DBGpr_int ("frmColor", frmColor);
        __DBGpr_int ("frmStyle", frmStyle);
        __DBGpr_int ("frmWeight", frmWeight);
	
        status =
	  om$send( msg      = message NDmacro.ACreturn_foot(&msg,
                                     "plane",&plane,NULL,NULL),
                 senderid = NULL_OBJID,
                 targetos = model_obj.osnum,
                 targetid = model_obj.objid);
        if( !(status&msg&1) )
        {
	  __DBGpr_obj(" NDmacro.ACreturn_foot failed ",model_obj);
	  return OM_S_SUCCESS;
        }
	
        def_plane.point  = point;
        def_plane.normal = normal;
        status =
        om$send( msg = message GRvg.GRdetplane(
                                        &msg,
                                        &model_env.md_env.matrix_type,
                                        model_env.md_env.matrix,
                                        &def_plane),
                 senderid = NULL_OBJID,
                 targetos = plane.osnum,
                 targetid = plane.objid);
        if( !(status&msg&1) ) 
        {
	  __DBGpr_obj(" GRvg.GRdetplane failed ",plane);
	  return OM_S_SUCCESS;
        }
	
	frame_normal[0] = normal[0];
	frame_normal[1] = normal[1];
	frame_normal[2] = 0.0;
	
        polyline_elem.points     = points_elem;
        polyline_elem.num_points = 2 ;
	
        status =
        om$send( msg      = message GRlinear.GRgetpolyline(
                                      &msg,
                                      &drwFrmPar.element_env.md_env.matrix_type,
                                      drwFrmPar.element_env.md_env.matrix,
                                      &action,
                                      &polyline_elem),
                 senderid = NULL_OBJID,
                 targetid = drwFrmPar.elementobj.objid,
                 targetos = drwFrmPar.elementobj.osnum );
        if( !(status&msg&1) )
        {
          __DBGpr_obj("Get element object failed!",drwFrmPar.elementobj);
    	  return OM_S_SUCCESS;
        }
        /*
	** find object.
	*/
        Lnb_geom = *nb_geom ;
        for( i = 0 ; i<Lnb_geom && i<4 ; i++ )
        {
          Lgeom[i] = (*geom)[i];
        }
	
        if( drwFrmPar.md_flag != 1 ) goto wrapup;    
	
        polyline.points          = points;
        polyline.num_points      = 2 ;
	
        /*
        ** find if it is  text object first.
        */
        for( i = 0 ; i<Lnb_geom && i<4 ; i++ )
	{
          status = om$get_classid( osnum     = Lgeom[i].osnum,
                                   objid     = Lgeom[i].objid,
                                   p_classid = &classid );
	  
          if( om$is_ancestry_valid(subclassid     = classid,
                       	           superclassname = "GRtext")
	      == OM_S_SUCCESS )
	  {
            __DBGpr_int ( "text object for i = ", i );
            __DBGpr_obj ( "text object ", Lgeom[i] );
	    
	    
	    /*
	    ** Erase the original text objects on screen
	    */
	    gr$display_object( object_id = &Lgeom[i],
                               mode      = GRbeheo );
	    
	    if( !(drwFrmPar.labelText) ) 
            {
	      
	      syntax_length = 0;
              __DBGpr_com("label with name ");
	      /* 
	      ** Find the ACrg containing glob info of this frame
	      */
	      status =
	      om$send( msg      = message NDnode.NDget_objects(ND_ROOT,
	       						       &frame_def,
							       1,
							       NULL,
							       2,
							       2,
							       &count),
                       senderid = NULL_OBJID,
                       targetid = model_obj.objid,
                       targetos = model_obj.osnum );
              if( !(status&1) )
	      {
		__DBGpr_obj("NDnode.NDget_objects failed ",model_obj);
		return OM_S_SUCCESS;
	      }
	      
	      /*
              ** Find the real position of each text (label)
              */
	      if( !(drwFrmPar.single_flag) )
	      {
                status =
		  om$send( msg      = message SMframe.SMgive_rel_position(
		                                      &msg,
		                                      &frame_pos),
			   senderid = NULL_OBJID,
			   targetid = model_obj.objid,
			   targetos = model_obj.osnum );
                if( !(status&msg&1) )
		{
		  __DBGpr_obj("SMframe.SMgive_rel_position failed",model_obj);
		  return OM_S_SUCCESS;
		}
	      }
	      else
	      {
	  	status =
                om$send( msg      = message SMInfPlane.SMgive_rel_position(
                                                        &msg,
                                                        &frame_pos),
                         senderid = NULL_OBJID,
                         targetid = model_obj.objid,
                         targetos = model_obj.osnum );
/*
	  	status =
                om$send( msg      = message ACcpx.ACfind_temp_struct(
                                                        &rc1,
							"dist_on_axe",
							&temp1_rts,
                                                        &model_env),
                         senderid = NULL_OBJID,
                         targetid = model_obj.objid,
                         targetos = model_obj.osnum );
		frame_pos = temp1_rts.var.root_pm_st.value;
*/
                if( !(status&msg&1) ) 
		{
		  __DBGpr_obj("SMframe.SMgive_rel_position failed",model_obj);
		  return OM_S_SUCCESS;
		}
	      }
	      
  	      /* 
	      ** Fill pos_txt value only if frame system is in NAME_BY_DIST
	      */
  	      if( SMGetFrmPosTxt(&frame_def, frame_pos, pos_txt) )
	      {
	        sprintf( occurance_name, "%s%s", drwFrmPar.prefix, pos_txt );
	      }
	      else
	      {
                frame_label = floor( frame_pos );
                sprintf( occurance_name, "%s%d",
			 drwFrmPar.prefix, frame_label );
	      }
	      
	      syntax_length = strlen( occurance_name );
	      for( i_index = 0 ; i_index < syntax_length ; ++i_index ) 
		occurance_name[i_index] = toupper(occurance_name[i_index]);
	      
	      if( syntax_length )
              {
	        /*
	        ** Replace the original text by the real position
	        */
	        status =
                om$send( msg      = message GRtext.GRreplace_text(
                                        &msg,
					md_env,
                                        syntax_length,
                                        (unsigned char *)occurance_name),
                         senderid = NULL_OBJID,
                         targetid = Lgeom[i].objid,
                         targetos = Lgeom[i].osnum );
   	        if( !(status&msg&1) ) 
		{
		  __DBGpr_obj("GRtext.GRreplace_text",Lgeom[i]);
		  return OM_S_SUCCESS;
		}
              }
            }
            /* CR179900942 by ylong */
            else if( drwFrmPar.nameCase )
            {
	      IGRshort		text_length ;
	      IGRuchar		*text_string ;
	      
	      text_length = 0;
	      text_string = NULL ;
	      
              __DBGpr_com("label with distance");
	      /*
	      ** Erase the original text objects on screen
	      */
	      gr$display_object( object_id = &Lgeom[i],
				 mode      = GRbeheo );
	      status =
        	  om$send(msg    = message GRtext.GRgettxattr(
        					&msg,
        					NULL,
        					&text_length, 
        					&text_string) ,
        		  senderid = NULL_OBJID,
                          targetid = Lgeom[i].objid, 
                          targetos = Lgeom[i].osnum ) ;
        
	      if( !(status&msg&1) )
	      {
		__DBGpr_obj("GRtext.GRgettxattr failed",Lgeom[i]);  
		goto get_out1 ;
	      }
	      
	      DMget_exact_str (	text_string, 
				text_length, 
				occurance_name, 
				&text_length);
	      syntax_length = strlen( occurance_name );
	      __DBGpr_int("text_length", text_length );
	      __DBGpr_str("occurance_name", occurance_name );
	      
	      for( i_index = 0 ; i_index < text_length ; ++i_index ) {
		occurance_name[i_index] = toupper(occurance_name[i_index]);
	      }
	      
	      if( text_length )
	      {
		/*
		** Replace the original text by the real position
		*/
		status =
                    om$send( msg      = message GRtext.GRreplace_text(
                                                &msg,
                                                md_env,
                                                text_length,
                                                (unsigned char *)occurance_name),
                             senderid = NULL_OBJID,
                             targetid = Lgeom[i].objid,
                             targetos = Lgeom[i].osnum );
		if( !(status&msg&1) ) {
		  __DBGpr_obj("GRtext.GRreplace_text failed",Lgeom[i]);
		  //return OM_S_SUCCESS;
		}
	      }
	      
	    get_out1:
	      _FREE( text_string );
            }
	    
	    
            /*
            ** object is text object.
            */
            status =
            om$send( msg      = message GRgraphics.GRgetrang(
						&msg,
                                                &md_env->md_env.matrix_type,
                                                md_env->md_env.matrix,
                                                &world,
                                                range),
                     targetid = Lgeom[i].objid,
                     targetos = Lgeom[i].osnum,
                     senderid = NULL_OBJID );

            vector[0] = (range[3] + range[0]) * 0.5 ;
            vector[1] = (range[4] + range[1]) * 0.5 ;
            vector[2] = (range[5] + range[2]) * 0.5 ;
	    
            text_range_height = fabs( range[4] - range[1]); 
            __DBGpr_dbl( " text range0 ", range[0] );
            __DBGpr_dbl( " text range1 ", range[1] );
            __DBGpr_dbl( " text range2 ", range[2] );
            __DBGpr_dbl( " text range3 ", range[3] );
            __DBGpr_dbl( " text range4 ", range[4] );
            __DBGpr_dbl( " text range5 ", range[5] );
            __DBGpr_dbl( " text range heigh ", text_range_height );
	    
            text_index = i;
            __DBGpr_int( " text_index ", text_index );
	    
            if( !drwFrmPar.tx_flag )	/* not display text */
	    {
              gr$display_object( object_id = &Lgeom[i],
                                 mode      = GRbeheo );
              status =
		om$send( msg      = message Root.delete(1),
			 targetid = Lgeom[i].objid,
			 targetos = Lgeom[i].osnum,
			 senderid = NULL_OBJID );
	      Lgeom[i].objid = NULL_OBJID ;
            }
	    
            if( frmHeight > 0 )  	 /* change text size */
            {
              text_symb.Active_height = frmHeight;
              text_symb.Active_width  = frmHeight;
            } 
          }
        }
	
        /*
	** for GR3dlineseg object
	*/
        for( i = 0 ; i<Lnb_geom && i<4 ; i++ )
	{
          status =
	    om$get_classid( osnum     = Lgeom[i].osnum,
			    objid     = Lgeom[i].objid,
			    p_classid = &classid );
	  
          if( om$is_ancestry_valid(subclassid     = classid,
                                   superclassname = "GR3dlineseg")
	      == OM_S_SUCCESS )
          {
            __DBGpr_int ( "line object for i = ", i);
            __DBGpr_obj ( "line object ", Lgeom[i]);
	    
	    /*
	    ** object is line string.
	    */
            status =
            om$send( msg      = message GRlinear.GRgetpolyline(
                                                &msg,
                                                &md_env->md_env.matrix_type,
                                                md_env->md_env.matrix,
                                                &action,
                                                &polyline ),
                     targetid = Lgeom[i].objid,
                     targetos = Lgeom[i].osnum,
                     senderid = NULL_OBJID );
            if( !(status&msg&1) )
            {
	      __DBGpr_obj("GRlinear.GRgetpolyline failed",Lgeom[i]); 
	      continue;
            }
            p1 = &(points[0]) ;
            p2 = &(points[3]) ;
	    
	    /*
	      if( BSdistptpt(&msg, vector, &(points[3])) <
	      BSdistptpt(&msg, vector, &(points[0])) )
	      {
              p1 = &(points[3]);
              p2 = &(points[0]);
	      }
	    */
	    if( drwFrmPar.centerline_flag )
	    {
	      p_elem1[0] = centerline_p0[0];
	      p_elem1[1] = centerline_p0[1];
	      p_elem1[2] = 0.0;
	      p_elem2[0] = centerline_p1[0];
	      p_elem2[1] = centerline_p1[1];
	      p_elem2[2] = 0.0;
	    }
	    else
	    {
	      p_elem1[0] = points_elem[0];
	      p_elem1[1] = points_elem[1];
	      p_elem1[2] = points_elem[2];
	      p_elem2[0] = points_elem[3];
	      p_elem2[1] = points_elem[4];
	      p_elem2[2] = points_elem[5];
	    }
	    
 	    if( fabs(p_elem1[0]-p_elem2[0]) > fabs(p_elem1[1]-p_elem2[1]) )
	      range_index = 0;
 	    else
	      range_index = 1;
	    
	    p_max = p_elem1[range_index];
	    p_min = p_elem1[range_index];
	    if( p_elem2[range_index] < p_min ) p_min = p_elem2[range_index]; 
	    if( p_elem2[range_index] > p_max ) p_max = p_elem2[range_index]; 
	    
	    BSxlnpl( &bs_rc, normal, point, p_elem1, p_elem2, intx_point );
	    
	    intx_point[2] = 0.0;
	    
	    if( bs_rc == BSSUCC )
	    {
              if( BSdistptpt(&msg, intx_point, &(points[3])) > 
                  BSdistptpt(&msg, intx_point, &(points[0])) )
	      {
                p1 = &(points[3]);
                p2 = &(points[0]);
              }
	      if( !(drwFrmPar.centerline_flag) )
	      {
	        if( (intx_point[range_index] > p_max) ||
		    (intx_point[range_index] < p_min) )
		{
		  gr$display_object( object_id = &Lgeom[text_index],
                                     mode = GRbeheo );
                  __DBGpr_obj("deleting object",Lgeom[text_index]);
                  status =
		    om$send( msg      = message Root.delete(1),
			     targetid = Lgeom[text_index].objid,
			     targetos = Lgeom[text_index].osnum,
			     senderid = NULL_OBJID );
                  Lgeom[text_index].objid = NULL_OBJID ;
		  
		  gr$display_object( object_id = &Lgeom[i],
                                     mode = GRbeheo );
                  __DBGpr_obj("deleting object",Lgeom[i]);
                  status =
		    om$send( msg      = message Root.delete(1),
			     targetid = Lgeom[i].objid,
			     targetos = Lgeom[i].osnum,
			     senderid = NULL_OBJID );
                  Lgeom[i].objid = NULL_OBJID ;
		  
      		  break;; 
		}
	      }
	    }
	    else
	    {
              __DBGpr_com(" deleting all the objects !!!! ");
	      for( j = 0 ; j < Lnb_geom && j < 4 ; j++ )
              {
                gr$display_object( object_id = &Lgeom[j],
                                   mode = GRbeheo );
                status =
		  om$send( msg      = message Root.delete(1),
			   targetid = Lgeom[j].objid,
			   targetos = Lgeom[j].osnum,
			   senderid = NULL_OBJID );
                Lgeom[j].objid = NULL_OBJID ;
              }
	      break;
	    }
	    
            /*
	    ** change line by factor
	    */ 
	    __DBGpr_int("change line by factor prfact ",drwFrmPar.prfact);
	    __DBGpr_int("pr_flag ",drwFrmPar.pr_flag);
	    __DBGpr_dbl("offset ",drwFrmPar.offset);
            if( drwFrmPar.prfact > 0 )		 /* =  1, 2, 3*/
	    {
	      if( drwFrmPar.pr_flag )  		 /* extend */ 
                Fact = ((double) drwFrmPar.prfact + 1.0) ;
              else   				 /* reduce */
                Fact = 1.0 ;
	      
              __DBGpr_dbl(" Fact", Fact );
	      
              p2[0] = p1[0] + ((double)Fact * ( p2[0] - p1[0] ));
              p2[1] = p1[1] + ((double)Fact * ( p2[1] - p1[1] ));
              p2[2] = p1[2] + ((double)Fact * ( p2[2] - p1[2] ));
	      
              __DBGpr_vec(" modify point p1", p1 );
              __DBGpr_vec(" modify point p2", p2 );
            }
	    
	    p1[0] = p1[0] + (intx_point[0] - p2[0]);
            p1[1] = p1[1] + (intx_point[1] - p2[1]);
            p1[2] = p1[2] + (intx_point[2] - p2[2]);;
            p2[0] = intx_point[0];
            p2[1] = intx_point[1];
            p2[2] = intx_point[2];
            __DBGpr_vec("  -- point p1", p1 );
            __DBGpr_vec("  -- point p2", p2 );
	    
	    if( drwFrmPar.frmp_flag )
	    {
	      p1[0] = p2[0] + ( p2[0] - p1[0] );
	      p1[1] = p2[1] + ( p2[1] - p1[1] );
	    }
	    
	    normal[0] = p1[0] - p2[0];
	    normal[1] = p1[1] - p2[1];
	    normal[2] = 0.0;
	    
	    BSnorvec( &bs_rc, normal );
	    
	    p1[0] += drwFrmPar.offset * normal[0] * text_symb.Active_height;
	    p1[1] += drwFrmPar.offset * normal[1] * text_symb.Active_height;
	    p2[0] += drwFrmPar.offset * normal[0] * text_symb.Active_height;
	    p2[1] += drwFrmPar.offset * normal[1] * text_symb.Active_height;
	    
            new_objid = NULL_OBJID ;
	    
            status =
	      om$send( msg      = message GRlinear.GRputpolyline(
		&msg,
		md_env,
		&post_info,
		&polyline,
		&new_objid),
		       targetid = Lgeom[i].objid,
		       targetos = Lgeom[i].osnum,
		       senderid = NULL_OBJID );
	    
            if( !( status&msg&1) ) continue;
	    
            __DBGpr_int(" new_objid", new_objid );
	    
            Lgeom[i].objid = new_objid ;
          }  /* if */
        } /*for */
	
        /*
	** refill the list of text
	*/
        if( text_index != -1        &&
            p2 != NULL              &&
            Lgeom[text_index].objid != NULL_OBJID )
	{
          __DBGpr_com(" change text position ");
	  
          /*
	  ** get the text matrix
	  */
          status =
	    om$send( msg = message GRvg.GRgenabsg(&msg,
						  &md_env->md_env.matrix_type,
						  md_env->md_env.matrix,
						  (IGRchar **)&absgptr),
                   senderid = NULL_OBJID,
                   targetid = Lgeom[text_index].objid,
                   targetos = Lgeom[text_index].osnum );
          if( !(status&msg&1) )
	  {
            printf(" GRvg.GRgenabsg failed \n");
            goto wrapup;
          }
	  
          new_objid = NULL_OBJID ;
	  
     	  /*
	  ** for frame position
	  */
	  shift_nor[0] = p1[0] - p2[0];
	  shift_nor[1] = p1[1] - p2[1];
	  shift_nor[2] = p1[2] - p2[2];
	  BSnorvec( &bs_rc, shift_nor );
	  
	  absgptr->matrix[3] = p1[0] + 
	    (1.0+drwFrmPar.text_off)*text_symb.Active_height*shift_nor[0];
          absgptr->matrix[7] = p1[1] + 
	    (1.0+drwFrmPar.text_off)*text_symb.Active_height*shift_nor[1];
	  absgptr->matrix[11] = p1[2];
	  
          __DBGpr_int( "text_symb.Active_just", text_symb.Active_just);
          __DBGpr_mat( "MATRIX", absgptr->matrix );
          __DBGpr_obj("before post Lgeom[text_index]",Lgeom[text_index]);
	  
	  if( !(drwFrmPar.ori_flag) )
          {
	    if( p2[0] > p1[0] )
	    {
	      trvec[0] = p2[0] - p1[0];
              trvec[1] = p2[1] - p1[1];
              trvec[2] = 0.0;
	    }
	    else
	    {
	      trvec[0] = p1[0] - p2[0];
              trvec[1] = p1[1] - p2[1];
              trvec[2] = 0.0;
	    }
	    BSnorvec( &bs_rc, trvec );
	    
	    for( i = 0 ; i < 3 ; i++ )
	    {
	      text_orie[i] = absgptr->matrix[i*4];
	      text_perp[i] = absgptr->matrix[i*4+1];
	      text_norm[i] = absgptr->matrix[i*4+2];
	      text_orig[i] = absgptr->matrix[i*4+3];
	    }

            for( i = 0 ; i < 3 ; ++i )
            {
              text_orie[0] = trvec[0];
              text_orie[1] = trvec[1];
              text_orie[2] = trvec[2];
            }
	    
	    BSnorvec( &bs_rc, text_orie );
            BSnorvec( &bs_rc, text_norm );
            BScrossp( &bs_rc, text_norm, text_orie, text_perp );
            if( bs_rc != BSSUCC )
            {
              goto wrapup;
            }
            BSnorvec( &bs_rc, text_perp );
	    
            for( i = 0 ; i < 3 ; i++ )
            {
              absgptr->matrix[i*4]   = text_orie[i];
              absgptr->matrix[i*4+1] = text_perp[i];
              absgptr->matrix[i*4+2] = text_norm[i];
            }
          }
	  else
	  {
 	    if( frame_normal[0] < 0.0 )
	    {
	      trvec[0] = -frame_normal[0];
              trvec[1] = -frame_normal[1];
              trvec[2] = 0.0;
	    }
	    else
	    {
	      trvec[0] = frame_normal[0];
              trvec[1] = frame_normal[1];
              trvec[2] = 0.0;
	    }
	    
	    BSnorvec( &bs_rc, trvec );
	    
	    for( i = 0 ; i < 3 ; i++ )
	    {
	      text_orie[i] = absgptr->matrix[i*4];
	      text_perp[i] = absgptr->matrix[i*4+1];
	      text_norm[i] = absgptr->matrix[i*4+2];
	      text_orig[i] = absgptr->matrix[i*4+3];
	    }
	    
            for( i = 0 ; i < 3 ; ++i )
            {
              text_orie[0] = trvec[0];
              text_orie[1] = trvec[1];
              text_orie[2] = trvec[2];
            }
	    
	    BSnorvec( &bs_rc, text_orie );
            BSnorvec( &bs_rc, text_norm );
            BScrossp( &bs_rc, text_norm, text_orie, text_perp );
            if( bs_rc != BSSUCC )
            {
              goto wrapup;
            }
            BSnorvec( &bs_rc, text_perp );
	    
            for( i = 0 ; i < 3 ; i++ )
            {
              absgptr->matrix[i*4]   = text_orie[i];
              absgptr->matrix[i*4+1] = text_perp[i];
              absgptr->matrix[i*4+2] = text_norm[i];
            }
	  }
	  __DBGpr_vec("text_orie",text_orie); 
	  __DBGpr_vec("text_perp",text_perp); 
	  __DBGpr_vec("text_norm",text_norm); 
	  
          /*
	  ** change GRTEXT_JUST
	  */
          status =
	    om$send( msg      = message GRvg.GRpostabsg(&msg,
                                                      md_env,
                                                      &post_info,
                                                      (IGRchar *) absgptr,
                                                      &new_objid),
                   senderid = NULL_OBJID,
                   targetid = Lgeom[text_index].objid,
                   targetos = Lgeom[text_index].osnum );

          if( !(status&msg&1) )
	  {
            printf(" GRvg.GRpostabsg failed111 \n");
            goto wrapup;
          }
	  
          Lgeom[text_index].objid = new_objid ;
	  
          /*
	  ** change GRTEXT_HEIGHT
	  */
          text_symb.Active_just = CENTER_CENTER ;
          attr = GRTEXT_JUST ;
          __DBGpr_obj("after post Lgeom[text_index]",Lgeom[text_index]);
	  
          status =
	    om$send( msg      = message GRtext.GRchgtextattr(&msg,
                                               		   md_env,
                                               		   attr,
                                               		   &text_symb),
                   senderid = NULL_OBJID,
                   targetid = Lgeom[text_index].objid,
                   targetos = Lgeom[text_index].osnum );

          if( !(status&msg&1) )
	  {
            //printf( "GRtext.GRchgtextattr failed\n" );
            goto wrapup;
          }
	  
          Lgeom[text_index].objid = new_objid ;
        } /* if */
      }
      
 wrapup:
      incr = 0;
      for( i=0 ; i<Lnb_geom && i<4 ; i++ ){
	if( Lgeom[i].objid != NULL_OBJID ){
	  (*geom)[incr++] = Lgeom[i] ;
	  __DBGpr_obj("Final Geometry",Lgeom[i]);
	}
	else
	{ __DBGpr_com(" Lgeom is NULL_OBJID ");}
        }
      *nb_geom = incr ;
      
      if( absgptr )   _FREE( absgptr );
      
      End
        return  TRUE ;
} /*SMframe_drw_layout1*/
/***************************************************************************/
SMframe_drw_layout( obj, md_env, geom, nb_geom )
struct	GRid		*obj;
struct	GRmd_env	*md_env;
struct	GRid		**geom;
IGRint			*nb_geom;
{
IGRlong			msg;
IGRint			status,
			no_text, state,
			incr,
			factor;
IGRint			action = 1;
IGRint			i, Lnb_geom;
struct	GRid		Lgeom[4];			
GRclassid		classid;
struct IGRpolyline	polyline;
IGRdouble		points[6];
GRrange			range;
GRobjid			new_objid = NULL_OBJID ;
IGRdouble		vector[3],
			*p1,  *p2;
IGRdouble		Fact = 1.0 ;
IGRboolean		world = 1;
struct GRpost_info	post_info; 
int			top;
int			text_index = -1;
int                     attr ;

struct IGRlbsys         *absgptr = NULL ;
struct GRdpb_text_symb  text_symb;


	SetProc( SMframe_drw_layout ); Begin

	p1 = p2 = NULL;

	status =
	om$send(msg = message ACncpx.ACget_STATE( &state ),
		targetid = obj->objid,
		targetos = obj->osnum,
		senderid = NULL_OBJID );
	if( ! (status &1 )){
		return TRUE ;
	}

        __DBGpr_int ( "nb_geom", *nb_geom);
        __DBGpr_obj ( "obj", *obj);
        __DBGpr_int ( "STATE", state);

	post_info.construct_flag = TRUE ;

	incr = ( state & drw_scale_incr ) ? 1 : 0 ;

        __DBGpr_int ( "incr", incr);

	factor = 0;
	factor = ( state & drw_scale_two )   ? 2 : factor ;
	factor = ( state & drw_scale_three ) ? 3 : factor ;
	factor = ( state & drw_scale_four )  ? 4 : factor ;

        __DBGpr_int ( "factor", factor);
	no_text = ( state & drw_without_text ) ? 1 : 0 ;
        __DBGpr_int ( "no_text", no_text);

	top = ( state & drw_just_top ) ? 1 : 0 ;
        __DBGpr_int ( "top", top);

#ifdef	vdsDEBUG
	printf(" factor: %d, no_text: %d, top : %d \n", factor, no_text, top );
#endif

	/*
	 * find object.
	 */
	Lnb_geom = *nb_geom ;	
	for( i=0 ; i<Lnb_geom && i<4 ; i++ ){
		Lgeom[i] = (*geom)[i] ;
	}

	polyline.points		= points;
	polyline.num_points	= 2 ;

	/*
	 * find the text object first.
	 */

	for( i=0 ; i<Lnb_geom && i<4 ; i++ ){
                
        	__DBGpr_int ( "text object for i = ", i);
        	__DBGpr_obj ( "text object ", Lgeom[i]);
		status =
		om$get_classid(	osnum	= Lgeom[i].osnum,
				objid	= Lgeom[i].objid,
				p_classid = &classid );

		if( om$is_ancestry_valid(
			subclassid	= classid,
			superclassname	= "GRtext" ) == OM_S_SUCCESS ){

			/*
			 * object is text object.
			 */
			status =
			om$send(msg = message GRgraphics.GRgetrang(
						&msg,
						&md_env->md_env.matrix_type,
						md_env->md_env.matrix,
						&world,
						range ),
				targetid = Lgeom[i].objid,
				targetos = Lgeom[i].osnum,
				senderid = NULL_OBJID );

			vector[0] = (range[3] + range[0]) * 0.5 ;
			vector[1] = (range[4] + range[1]) * 0.5 ;
			vector[2] = (range[5] + range[2]) * 0.5 ;

			text_index = i ;
                        __DBGpr_int( " text_index ", text_index);
	
			if( no_text ){

				gr$display_object(
					object_id = &Lgeom[i],
					mode = GRbeheo );

				status =
				om$send(msg = message Root.delete( 1 ),
					targetid = Lgeom[i].objid,
					targetos = Lgeom[i].osnum,
					senderid = NULL_OBJID );
				Lgeom[i].objid = NULL_OBJID ;
			}
		}
	}

	for( i=0 ; i<Lnb_geom && i<4 ; i++ ){
        	__DBGpr_int ( "line object for i = ", i);
        	__DBGpr_obj ( "line object ", Lgeom[i]);

		status =
		om$get_classid(	osnum	= Lgeom[i].osnum,
				objid	= Lgeom[i].objid,
				p_classid = &classid );

		if( om$is_ancestry_valid(
			subclassid	= classid,
			superclassname	= "GR3dlineseg" ) == OM_S_SUCCESS ){

			/*
			 * object is line string.
			 */
			if( ! factor ) continue;

			status =
			om$send(msg = message GRlinear.GRgetpolyline(
						&msg,
						&md_env->md_env.matrix_type,
						md_env->md_env.matrix,
						&action,
						&polyline ),
				targetid = Lgeom[i].objid,
				targetos = Lgeom[i].osnum,
				senderid = NULL_OBJID );

			if( ! (status&msg&1))	continue;


			p1 = &(points[0]) ;
			p2 = &(points[3]) ;

			if( BSdistptpt( &msg, vector, &(points[3]) ) <
			    BSdistptpt( &msg, vector, &(points[0]) )){
		
				p1 = &(points[3]);
				p2 = &(points[0]);
			}

			__DBGpr_vec(" point p1", p1 );
			__DBGpr_vec(" point p2", p2 );

			if( ! incr )	Fact = 1.0 / (double) factor ; 
			else		Fact = (double) factor ;
			__DBGpr_dbl(" Fact", Fact );

			p2[0] = p1[0] + ((double)Fact * ( p2[0] - p1[0] ));
			p2[1] = p1[1] + ((double)Fact * ( p2[1] - p1[1] ));
			p2[2] = p1[2] + ((double)Fact * ( p2[2] - p1[2] ));

			__DBGpr_vec(" modify point p1", p1 );
			__DBGpr_vec(" modify point p2", p2 );

			new_objid = NULL_OBJID ;

			status =
			om$send(msg = message GRlinear.GRputpolyline(
						&msg,
						md_env,
						&post_info,
						&polyline,
						&new_objid ),
				targetid = Lgeom[i].objid,
				targetos = Lgeom[i].osnum,
				senderid = NULL_OBJID );

			if( !( status&msg&1)) continue;
			__DBGpr_int(" new_objid", new_objid );

			Lgeom[i].objid = new_objid ;
		}
	}

	/*
	 * refill the list.
	 */

	if( 	top			&&
		text_index != -1	&& 
		p2 != NULL		&& 
		Lgeom[text_index].objid != NULL_OBJID ){

                __DBGpr_com(" put the text on the top ");
		/*
		 *  erase the object.
		 */
                gr$display_object(	object_id = &Lgeom[text_index],
                                        mode = GRbeheo );

		/*
		 * put the text on the top of the line string.
		 */
		status =
		om$send(msg = message GRvg.GRgenabsg(
                                               &msg,
                                               &md_env->md_env.matrix_type,
                                               md_env->md_env.matrix,
                                               (IGRchar **)&absgptr ),
			senderid = NULL_OBJID,
                        targetid = Lgeom[text_index].objid,
                        targetos = Lgeom[text_index].osnum );

		if( !( status&msg&1 )){
			printf(" GRvg.GRgenabsg failed \n");
			goto wrapup;
		}

		new_objid = NULL_OBJID ;

		absgptr->matrix [3] = p2[0];
		absgptr->matrix [7] = p2[1];
		absgptr->matrix[11] = p2[2];

#ifdef	vdsDEBUG
		pr_mat( "MATRIX", 4,4, absgptr->matrix );
#endif
		status =
                om$send(msg = message GRvg.GRpostabsg(
                                               &msg,
                                               md_env,
                                               &post_info,
                                               (IGRchar *) absgptr,
                                               &new_objid ),
			senderid = NULL_OBJID,
                        targetid = Lgeom[text_index].objid,
                        targetos = Lgeom[text_index].osnum);

		if( !( status&msg&1 )){
			printf(" GRvg.GRpostabsg failed2222 \n");
			goto wrapup;
		}


		attr = GRTEXT_JUST ;
		text_symb.Active_just = CENTER_BOTTOM ;

		Lgeom[text_index].objid = new_objid ;

		status =
		om$send(msg = message GRtext.GRchgtextattr(
                                               &msg,
                                               md_env,
                                               attr,
                                               &text_symb ),
			senderid = NULL_OBJID,
                        targetid = Lgeom[text_index].objid,
                        targetos = Lgeom[text_index].osnum);

		if( !( status&msg&1 )){
	         	//printf(" GRtext.GRchgtextattr failed \n");
			goto wrapup;
		}
	}

wrapup:

	incr = 0;
	for( i=0 ; i<Lnb_geom && i<4 ; i++ ){
		if( Lgeom[i].objid != NULL_OBJID ){
			(*geom)[incr++] = Lgeom[i] ;
		}
	}
	*nb_geom = incr ;

	if( absgptr )	_FREE( absgptr );

	End
	return	TRUE ;
}

/***************************************************************************/

#ifdef	NO_DYNAMIC_LOAD

method ACconstruct_feet( IGRlong *msg; IGRint cn_type;
                           IGRint count; struct GRid list [];
                           struct GRmd_env *md_env;
                           int *fcount; struct GRid  *feet_list)
{
 long  status,loc_msg;
 short rc;
 struct GRid model_obj,model_def,drawing_obj,drawing_def,geom,geom_def,
	     context,component;
 int nb_geom,nb_feet,nb_obj;
 int obj_level[32];
 int i;
 struct IGRlbsys obj_lbs;
 double point[3],vector[3],p1[15];
 struct IGRrt_prism prism;

 char *syntax, *macro_name,
      design_name[DI_PATH_MAX], occurance_name[DI_PATH_MAX];
 
 struct GRmd_env model_env;
 struct GRid *copied_geom = NULL,
	     *obj_list = NULL;

 struct myfeet *feet_desc;
 int predef, predef_index;
 GRclassid obj_class;

  SetProc( DrwFrame.ACconstruct_feet ); Begin
 
   *msg = MSFAIL;
   drawing_obj.objid = my_id;
   drawing_obj.osnum = OM_Gw_current_OS;
   *fcount = 0;

   /* find object in model and its macro definition */

   status = om$send(msg = message NDmacro.ACreturn_foot(&loc_msg,"",
                                &model_obj,&model_env.md_env.matrix_type,
                                model_env.md_env.matrix),
                    targetid = list[0].objid,
                    targetos = list[0].osnum);
   model_env.md_id.osnum = model_obj.osnum;
   model_env.md_id.objid = NULL_OBJID;
   if(!(status&loc_msg&1)) return OM_S_SUCCESS;

   status = om$send(msg = message ACcpx.find_macro(&model_def),
                    targetid = model_obj.objid,
                    targetos = model_obj.osnum);
   if(!(status&1)) return OM_S_SUCCESS;

   status = om$send(msg = message ACcpx_defn.ACgive_name(&macro_name),
                    targetid = model_def.objid,
                    targetos = model_def.osnum);
   if(!(status&1)) return OM_S_SUCCESS;

   /* find drawing macro definition */

   status = om$send(msg = message ACcpx.find_macro(&drawing_def),
                    targetid = my_id);
   if(!(status&1)) return OM_S_SUCCESS;

   status=om$send(msg = message ACcpx_defn.ACgive_feet_desc
                                                          (&nb_feet,&feet_desc),
                     targetid = drawing_def.objid,
                     targetos = drawing_def.osnum);
   if(!(status&1)) return OM_S_SUCCESS;
   if(nb_feet < 1) return OM_S_SUCCESS; /* facking macro for leader line */
   if(!ASmatchRE(feet_desc[nb_feet-1].name,macro_name)) return OM_S_SUCCESS;

   /* find reference file attachment info */
   status = VDget_ctx_ref2( list, &context, (struct GRid *)NULL );
   as$status(action = RET_STATUS);

   status = om$send(msg = message VDcontext.VDget_extract_info
			(&obj_list,&nb_obj,vector,point,obj_level,&obj_lbs),
		    targetid = context.objid,
		    targetos = context.osnum);
   as$status(action = RET_STATUS);

   /* copy geometry of model */
   status = om$send(msg = message NDnode.NDdrawing_copy_geom(obj_list,
                                        nb_obj,
                                        &copied_geom,
                                        &nb_geom,
                                        vector,point,
                                        obj_level,
                                        &obj_lbs,
                                        &model_env,
                                        md_env),
                    targetid = model_obj.objid,
                    targetos = model_obj.osnum);

   status =
   om$get_classid(	osnum	= model_obj.osnum,
			objid	= model_obj.objid,
			p_classid = &obj_class );

   if(( om$is_ancestry_valid(	subclassid	= obj_class,
			superclassname	= "SMframe" ) == OM_S_SUCCESS ) ||
      ( om$is_ancestry_valid(	subclassid	= obj_class,
			superclassname	= "SMInfPlane" ) == OM_S_SUCCESS )){

	SMframe_drw_layout( &drawing_obj, md_env, &copied_geom, &nb_geom );
   }
   
   status = om$send(msg = message NDmacro.ACreturn_foot(&loc_msg,"geom",
                                &geom,NULL,NULL),
                    targetid = my_id);
   if(!(status&loc_msg&1))
   { 
        status = di$translate(	objname = GEOM_PART,
				osnum = OM_Gw_current_OS,
				p_objid = &geom_def.objid,
				p_osnum = &geom_def.osnum);

        status = om$construct(classid = OPP_VDgeom_class_id,
                         osnum   = md_env->md_id.osnum,
                         p_objid = &geom.objid,
                         msg = message ACcpx.ACload_macro(geom_def));
        geom.osnum = md_env->md_id.osnum;
	status = om$send(msg = message NDnode.NDmove_to_root
						        (&loc_msg,&geom,md_env),
			 targetid = geom.objid,
			 targetos = geom.osnum);
	
   }
   else{
	status = om$send(msg = message ACncpx.ACcontext_compute_feet
				(nb_geom,geom,copied_geom,md_env),
			 targetid = geom.objid);
   }

   /* Clip geometry with respect to clipping polygon and change feet */ 

   status = om$send (msg = message GRgraphics.GRdelete ( &loc_msg, md_env ),
			senderid = geom.objid,
                        p_chanselect = &AC_mto_graf_chns );
   as$status (  );

   /* 
    * Modif to make it working when the drawing plane in not on z = 0.
    * Just set the height of the prism to the correct value.
    * 04/27/93, AD, CH.
    * prism.height = 2;
    */

  /*
   *  Jean 10/14/93 : We look if the object is in a prism of height 2 (here
   *  I take the first hard code value of jla but I'm not sure it's really
   *  good to hard code this value.). The z value of this prism is object -1
   *  In any case the z coordinate of the prism has not to be at z = -1
   *  which exclude case where drawing view is not at z = 0.
   *  The solution in 2.1 which was prism_height was z = -1 
   *  obj_lbs.matrix[11] + 2 was not good. What if z < 0 ?
   */    

   /*Jean 10/14/93*/ 
   prism.height = 2;  /* 04/27/93 was obj_lbs.matrix[11] + 2; */

   /*Jean 10/14/93*/
   obj_lbs.matrix[11] -= 1;  /* 04/27/93 was obj_lbs.matrix[11] = -1; */

   for(i=0;i<16;i++) prism.matrix[i] = obj_lbs.matrix[i];

   p1[0] = obj_lbs.diag_pt1[0];
   p1[1] = obj_lbs.diag_pt1[1];
   p1[2] = 0;

   p1[3] = obj_lbs.diag_pt2[0];
   p1[4] = obj_lbs.diag_pt1[1];
   p1[5] = 0;
 
   p1[6] = obj_lbs.diag_pt2[0];
   p1[7] = obj_lbs.diag_pt2[1];
   p1[8] = 0;

   p1[9] = obj_lbs.diag_pt1[0];
   p1[10]= obj_lbs.diag_pt2[1];
   p1[11]= 0;

   p1[12]= obj_lbs.diag_pt1[0];
   p1[13]= obj_lbs.diag_pt1[1];
   p1[14]= 0;

   prism.polygon.num_points = 5;
   prism.polygon.points = p1;
  
   /*prism.height = 2;  Was reset here in 2.2.1.04 version. Jean 10/14/85*/

   for(i=0;i<nb_geom;i++){

     VDclipping(copied_geom+i,&geom,(char *)&prism,md_env);
   }

   /* Now change GRcompcurve to AScompcurve to support indexing */

   for(i=0;i<OM_K_MAXINT;i++)
   {
        status = om$get_objid_at_index(objid = geom.objid,
				       osnum = geom.osnum,
				       p_chanselect = &AS_to_comp,
				       index = i,
				       osnumaddr = &component.osnum,
				       objidaddr = &component.objid);
	if(!(status&1)) break;
	status = om$get_classid(objid = component.objid,
			        osnum = component.osnum,
				p_classid = &obj_class);
        if(!(status&1) || obj_class != OPP_GRcompcurve_class_id) continue;

        om$change_class( osnum     = component.osnum,
                         objid     = component.objid,
                         classname = "AScompcurve" ) ;

        om$send( msg      = message NDnode.NDmove_to_root( &loc_msg,
                                                           &component,
                                                           md_env),
		       targetos = component.osnum,
                       targetid = component.objid);
   }

   /*
    * status =
    * om$send(msg = message ACncpx.ACchange_feet(
    *				nb_geom,copied_geom,md_env),
    *         targetid = geom.objid,
    *         targetos = geom.osnum);
    */

   if(nb_geom && copied_geom) _FREE(copied_geom);

   status = om$send(msg = message NDnode.NDmove_to_root(&loc_msg,&geom,
							 md_env),
                    targetid = geom.objid,
                    targetos = geom.osnum);

   /* Now copy attribute from model */

   status = om$send(msg = message NDnode.NDdrawing_copy_attr(feet_desc,
                                        nb_feet-PREDEFINED_FEET-2,
                                        feet_list,
                                        &model_env,
                                        md_env),
                    targetid = model_obj.objid,
                    targetos = model_obj.osnum);

   /* For not found attributs, copied them from DB NOT DONE */

   /* initialize predefined attributes like macro name, occurence name,
      design file name */

   for(predef=0, predef_index = nb_feet - PREDEFINED_FEET-2;
       predef< PREDEFINED_FEET;
       predef++,predef_index++)
   {
     syntax = NULL;
     feet_list[predef_index].objid = NULL_OBJID;
     switch (predef)
      {
       case 0 : /* macro name */
        syntax = macro_name; break;

       case 1 : /* occurance name */
        status = om$send(msg = message GRvg.GRgetname(&loc_msg,occurance_name),
                    targetid = model_obj.objid,
                    targetos = model_obj.osnum);

        if((status&loc_msg&1) && occurance_name[0] != '\0')
        {
         syntax = strrchr(occurance_name,':');
         if(syntax) syntax++;
         else syntax = occurance_name;
        }
        break;

       case 2 : /* model file name */
        VDget_design_name(model_obj.osnum,design_name,md_env);
        syntax = design_name;
        break;

       case 3 : /* quantity */
        /* take quantity as it was define earlier or set it to 1 */
        status = om$send(msg = message NDmacro.ACreturn_foot(&loc_msg,"quantity",
                                feet_list+predef_index,NULL,NULL),
                    targetid = drawing_obj.objid,
                    targetos = drawing_obj.osnum);
        if(status&loc_msg&1)
         {
          status = om$send(msg = message GRconnector.GRdisconn
                                                (&loc_msg,&drawing_obj),
                           targetid = feet_list[predef_index].objid,
                           targetos = feet_list[predef_index].osnum);
         }
        else
         {
          status = om$construct(classid = OPP_Gexp_class_id,
			     osnum   = md_env->md_id.osnum,
			     p_objid = &feet_list[predef_index].objid,
			     msg = message expression.modify(NULL,"1",&rc));
          feet_list[predef_index].osnum = md_env->md_id.osnum;
         }
        break;
      }

     if(syntax && syntax[0] != '\0')
      {
       status = om$construct(classid = OPP_Gtext_exp_class_id,
                             osnum   = md_env->md_id.osnum,
                             p_objid = &feet_list[predef_index].objid,
                             msg = message expression.modify(NULL,syntax,&rc));
       feet_list[predef_index].osnum = md_env->md_id.osnum;
     }
   }

   /* component with geometry */
   feet_list[nb_feet-2] = geom;

   /* create the drawing part */

   status = om$send(msg = message GRconnector.GRdisconn
                                                (&loc_msg,&drawing_obj),
                           targetid = geom.objid,
                           targetos = geom.osnum);

   *fcount = nb_feet -1;

   *msg = MSSUCC;
   End
   return OM_S_SUCCESS;
}

#endif


end implementation VDdrawing;
