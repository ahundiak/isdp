/* $Id: VDdrwfrm_iso.I,v 1.9 2002/02/01 16:49:23 jayadev Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:        vddrawing/imp/VDdrwfrm_iso.I
 *
 * Description:
 *	All necessary functions for command Extract frame systems and 
 *      single frame
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDdrwfrm_iso.I,v $
 *      Revision 1.9  2002/02/01 16:49:23  jayadev
 *      fix for TR#MP5836
 *
 *      Revision 1.8  2001/06/27 20:55:45  jayadev
 *      *** empty log message ***
 *
 *      Revision 1.7  2001/06/24 18:09:25  jayadev
 *      changes for modify iso frames command
 *
 *      Revision 1.6  2001/05/25 20:32:40  jayadev
 *      *** empty log message ***
 *
 *      Revision 1.5  2001/05/25 16:49:13  jayadev
 *      changes for TR# MP5112
 *
 *      Revision 1.4  2001/05/24 20:25:30  jayadev
 *      TR# MP5112
 *
 *      Revision 1.3  2001/02/14 17:42:47  ramarao
 *      *** empty log message ***
 *
 *      Revision 1.2  2001/02/14 17:21:42  ramarao
 *      *** empty log message ***
 *
 *      Revision 1.1.1.1  2001/01/04 21:08:42  cvs
 *      Initial import to CVS
 *
# Revision 1.3  1999/12/10  23:19:06  pinnacle
# CR179900942
#
# Revision 1.2  1999/04/09  20:06:02  pinnacle
# Replaced: vddrawing/imp/VDdrwfrm_iso.I for:  by mdong for vds
#
# Revision 1.1  1999/02/12  19:05:50  pinnacle
# Created: vddrawing/imp/VDdrwfrm_iso.I by mdong for vds
#
 *
 * History:
 *      MM/DD/YY        AUTHOR          DESCRIPTION
 *	01/31/99	Ming		Created
 *	12/10/99	ylong		CR179900941
 *      05/24/01        Jayadev         TR5112
 *      06/23/01        Jayadev         CRXXXX -  modify iso frames
 *      02/01/02        Jayadev         TR5836 - Max. No. of reffiles
 *                                      can be more than 100 --> 500 
 * -------------------------------------------------------------------*/

class implementation Root;

#include <stdio.h>
#include <string.h>
/*
#include "OMMinimum.h"
*/
#include "OMparameters.h"
#include "OMprimitives.h"
#include "OMmacros.h"
#include "OMindex.h"

#include "msdef.h"
#include "refdef.h"
#include "madef.h"
#include "igrtypedef.h"
#include "GRtypedef.h"

#include "asbox.h"
#include "AS_status.h"
#include "AS_debug.h"
#include "grerr.h"
#include "grgsdef.h"
#include "gr.h"
#include "detaildef.h"
#include "ACrg_collect.h"

#include "DItypedef.h"
#include "DIdef.h"
#include "DIglob.h"
#include "DIprims.h"

#include "bserr.h"
#include "bsparameters.h"
#include "exmacros.h"
#include "grgsdef.h"
#include "grmacros.h"
#include "grdpbdef.h"
#include "grdpbmacros.h"
#include "macro.h"
#include "coparamac.h"
#include "acdef.h"
#include "acmacros.h"
#include "nddef.h"
#include "ACcheckin.h"
#include "dpdef.h"
#include "asmacros.h"
#include "ndmacros.h"

#include "grerr.h"
#include "vds.h"
#include "SMdef.h"
#include "SMmacros.h"
#include "v_miscmacros.h"
#include "v_dbgmacros.h"
#include "VDmsg.h"
#include "VDobj.h"
#include "VDchn.h"
#include "VDCmdDrwFr.h" 
#include "vddlodef.h"
#include "vddlomacros.h"
#include "vdAPImacros.h"

extern GRclassid OPP_VDdrawing_class_id,
                 OPP_SMframe_class_id,
                 OPP_SMInfPlane_class_id,
                 OPP_ci_mac_def_class_id;

from ci_mac_def		import ACplace;
from GRvg		import GRgetname;
from SMfrm_syst		import SMfind_all_frame;
from GRdrawview		import GRget_component_id;
from GRreffile		import GRgetenvironment;
from IGEgragad		import DPinquire;
from IGEgragad		import DPinrot;
from NDmacro		import ACreturn_foot;
from ACcpx		import find_macro;
from ACcpx		import ACload_macro;
from ACcpx_defn		import ACgive_name;
from ACcpx_defn		import ACgive_feet_desc;
from ACdb_info		import ACcheckin_candidate;
from ACdb_info		import ACget_db_info;
from ACdb_info		import ACset_db_info;
from ACdb_info		import ACput_serial_no;
from NDnode		import NDconnect, NDchange_connect,
                               NDs_compute_node;
from NDnode		import NDget_objects;
from ACncpx		import ACconstruct_feet;
from ACncpx		import ACchange_feet;
from GRgraphics		import GRdisplay;
from GRgraphics		import GRdelete;
from SMframe		import SMfind_frame_num;
from VDdrawing		import VDset_DrwFrParaIns, VDget_DrwFrParaIns;
from OMObjSpace		import pass;


int main_function( framesys,
		   frmsys_vdfrsys,
		   frmsys_vdsingleframe,
		   mod_env,
		   md_env )
struct VDfrsys_oniso *framesys;
struct VDfrsys       *frmsys_vdfrsys;
struct VDfrsys       *frmsys_vdsingleframe;
struct GRmd_env      *mod_env;
struct GRmd_env      *md_env;
{
  int           	ret_status;
  long                  loc_msg;
  int			status, i;
  int			count;
  struct GRobj_env	*drwlist;
  struct GRid           *frmsys_frame;
  struct GRid           *frmsys_Obj_List;
  struct GRobj_env      *frmsys_drwlist_0;
  struct GRobj_env      *frmsys_drwlist_1;
  struct GRobj_env      *frmsys_drwlist_2;


      SetProc( main_function ); Begin

      ret_status = 0;

      frmsys_frame     = NULL;
      frmsys_Obj_List  = NULL;
      frmsys_drwlist_0 = NULL;
      frmsys_drwlist_1 = NULL;
      frmsys_drwlist_2 = NULL;
      drwlist          = NULL;

      count = 0;
      as$start_fence( set       = &framesys->drawingview,
                      set_env   = mod_env,
                      nb_obj    = &count,
                      p_obj_env = &drwlist );

      if( count )
      {
        frmsys_drwlist_0 =_MALLOC(count, struct GRobj_env);
      }

      for( i = 0 ; i < count; i = i + 1 )
      {
        frmsys_drwlist_0[i] = drwlist[i];
        __DBGpr_obj("frmsys_drwlist_0", frmsys_drwlist_0[i].obj_id);
      }

      ASend_fence();

      status = 
      store_frsys_by_name( framesys, frmsys_vdfrsys, frmsys_vdsingleframe );
      if( !(status&1) )
      {
        printf("store_frsys_by_name is failed!\n");
        goto wrapup;
      }

      status = store_frame_by_all( framesys,
				   &frmsys_frame,
				   frmsys_drwlist_0,
				   &frmsys_drwlist_1 );
      if( !(status&1) )
      {
        printf("store_frame_by_all is failed!\n");
        goto wrapup;
      }

      status = store_drawing_objects( framesys );
      if( !(status&1) )
      {
        printf("store_drawing_objects is failed!\n");
        goto wrapup;
      }

      status = extract_framesys( framesys,
				 frmsys_frame,
				 &frmsys_Obj_List,
				 &frmsys_drwlist_2 );
      if( !(status&1) )
      {
        printf("extract_framesys is failed!\n");
        goto wrapup;
      }

      if( framesys->md_flag )
      {
        status = process_object( framesys, frmsys_drwlist_2 );
        if( !(status&1) )
        {
          printf("process_object is failed!\n");
          goto wrapup;
        }
      }

      ret_status = 1;


      wrapup:
      if( frmsys_frame     != NULL ) _FREE( frmsys_frame );
      if( frmsys_Obj_List  != NULL ) _FREE( frmsys_Obj_List );
      if( frmsys_drwlist_0 != NULL ) _FREE( frmsys_drwlist_0 );
      if( frmsys_drwlist_1 != NULL ) _FREE( frmsys_drwlist_1 );
      if( frmsys_drwlist_2 != NULL ) _FREE( frmsys_drwlist_2 );
      End
      return ret_status;
} /* main_function */

/*------------------------------------------------------------------*/
int read_drawing_macro( framesys )
struct VDfrsys_oniso *framesys;
/*
** This function initializes the drawing macro and the name of locatable parts.
** The macro definitions are created in the default working directory "."
*/
{
  int		ret_status;
  long    	status,loc_msg;
  int 		temp_type;
  int     	nb_feet;
  char		tpname0[macro_MAX_CHAR],tpname1[macro_MAX_CHAR];
  char		*temp_name[2], *feet_names[MAX_FEET];
  char		ftname[MAX_FEET*macro_MAX_CHAR];
  char		full_path[200], full_macro_name[80];
  char		cur_mac_lib[macro_MAX_CHAR+1];
  int		cur_mac_len;
  OM_S_OBJID	drawing_macro;
  struct GRid   mac_lib_id;


  SetProc( read_drawing_macro ); Begin

  ret_status = 0;

  /*
  ** Template name and type init
  */
  status    = OM_S_SUCCESS;
  temp_type = 0;
  temp_name[0] = tpname0;
  temp_name[1] = tpname1;
  strcpy( tpname0, "model" );
  strcpy( tpname1, "iso_ref" );

  /*
  ** initialisation of the feet name table
  */
  VDinit_feet_name( ftname, feet_names, MAX_FEET );

  /*
  ** test if a macro library is active
  */
  cur_mac_lib[0] = '\0';
  cur_mac_len    = 0;

  status = ac$construct_wd( mode         = AC_INQ,
                            name         = cur_mac_lib,
                            name_size    = macro_MAX_CHAR,
                            name_len     = &cur_mac_len );
  if( !(status&1) ) goto wrapup;

  /*
  ** create the default path for the macro library
  */
  status = di$give_pathname( osnum    =  framesys->ModuleInfo.md_id.osnum,
                             pathname = full_path );
  strcat( full_path, ":constructs" );

  status = di$translate( objname = full_path,
                         p_objid = &mac_lib_id.objid,
                         p_osnum = &mac_lib_id.osnum );
  if( !(status&1) )
  {
    status = ac$construct_path( mode    = AC_ADD_PATH,
                                name    = "." );
    if( !(status&1) )
    {
      printf( "Can't get construct path directory: %s\n", full_path );
      goto wrapup;
    }

    status = ac$construct_wd( mode    = AC_SET,
                              name    = ".",
                              dir     = &mac_lib_id );
    if( !(status&1) )
    {
      printf( "Can't get construct working directory: %s\n", full_path );
      goto wrapup;
    }
  }

  /*
  ** search or initialize macro definition for geometry
  */
  sprintf( full_macro_name, "%s:VDgeomdef", full_path );
  status = di$translate( objname = full_macro_name,
                         osnum   = mac_lib_id.osnum,
                         p_objid = &framesys->geom_macro.objid,
                         p_osnum = &framesys->geom_macro.osnum );
  if( !(status&1) )
  {
    status =
    om$construct( classid = OPP_ci_mac_def_class_id,
                  osnum   = mac_lib_id.osnum,
                  p_objid = &framesys->geom_macro.objid );
    framesys->geom_macro.osnum = mac_lib_id.osnum;
    if( !(status&1) ) goto wrapup;

    status =
    om$send( msg      = message ci_mac_def.ACplace((int *)&loc_msg,
                                                   0,
                                                   "VDgeomdef",
                                                   "",
                                                   0,
                                                   1,
                                                   &temp_name[0],
                                                   &temp_type,
                                                   0,
                                                   NULL,
                                                   NULL,
                                                   0,
                                                   NULL,
                                                   NULL,
                                                   MAX_FEET,
                                                   feet_names,
                                                   NULL,
                                                   NULL),
	     senderid = NULL_OBJID,
             targetid = framesys->geom_macro.objid,
             targetos = framesys->geom_macro.osnum );
    if( !(status&loc_msg&1) ) goto wrapup;
  }

  /*
  ** search or initialize macro definition for frame extraction
  */

  sprintf( full_macro_name, "%s:drawing_frame", full_path );
  status = di$translate( objname = full_macro_name,
                         osnum   = mac_lib_id.osnum,
                         p_objid = &framesys->geom_macro.objid,
                         p_osnum = &framesys->geom_macro.osnum);
  if( !(status&1) )
  {
    nb_feet = 0;
    VDadd_predef_feet( &nb_feet,feet_names );
    strcpy( feet_names[nb_feet], "VD*Pl*|SM*Pl*" );
    nb_feet = nb_feet + 1;

    /*
    ** construct the macro definition
    */
    status =
    om$construct( classid = OPP_ci_mac_def_class_id,
                  osnum   = mac_lib_id.osnum,
                  p_objid = &drawing_macro );
    if( !(status&1) ) goto wrapup;

    status =
    om$send( msg      = message ci_mac_def.ACplace((int *)&loc_msg,
                                                   0,
                                                   "drawing_frame",
                                                   "",
                                                   0,
                                                   2,
                                                   temp_name,
                                                   &temp_type,
                                                   0,
                                                   NULL,
                                                   NULL,
                                                   0,
                                                   NULL,
                                                   NULL,
                                                   nb_feet,
                                                   feet_names,
                                                   NULL,
                                                   NULL),
	     senderid = NULL_OBJID,
	     targetid = drawing_macro,
             targetos = mac_lib_id.osnum );
    if( !(status&loc_msg&1) ) goto wrapup;
  }

  ret_status = 1;


  wrapup:
  End
  return ret_status;
}/* read_drawing_macro */

/*---------------------------------------------------------------------*/
int get_frsys_list( framesys, vdfrsys )
struct VDfrsys_oniso *framesys;
struct VDfrsys       **vdfrsys;
{
   struct SMObjList        list;
   IGRchar                 name_fr_syst[DI_PATH_MAX],
			   s_name[DI_PATH_MAX];
   long                    status, msg;
   int			   ret_status;
   int                     i;


   SetProc( get_frsys_list ); Begin

   /* Select all frame system */
   ret_status = 0;
   list.nb_objects = 0;
   list.list = NULL;
   status = SM$CritSel( msg     = &msg,
                        type    = SM_FRM,
                        options = SM_REF_FILE,
                        list    = &list );

   if( status&msg&1 )
   {
     __DBGpr_int( "list.nb_objects", list.nb_objects);
     
     framesys->nb_framesys = list.nb_objects;
     if( list.nb_objects && vdfrsys )
     {
       (*vdfrsys) = 
       _MALLOC(list.nb_objects, struct VDfrsys);
     }

     for( i = 0 ; i < list.nb_objects ; i = i + 1 )
     {
       status =
       om$send( msg      = message GRvg.GRgetname(&msg, name_fr_syst),
		senderid = NULL_OBJID,
                targetid = list.list[i].obj_id.objid,
                targetos = list.list[i].obj_id.osnum);
       if( status&msg&1 )
       {
         di$split( pathname = name_fr_syst, name = s_name );
         strcpy( (*vdfrsys)[i].name, s_name );
         (*vdfrsys)[i].grid = list.list[i].obj_id;
         __DBGpr_str("frame system name", (*vdfrsys)[i].name);
         __DBGpr_obj("frame system obj", (*vdfrsys)[i].grid);
       }
       else
         goto wrapup;
     }
   }
   else
     goto wrapup; 

   ret_status = 1;

   wrapup:
   if( list.nb_objects > 0 && list.list != NULL ) free( list.list );

   End

   return ret_status;
} /* get_frsys_list */

/*---------------------------------------------------------------------*/
int get_singleframe_list( framesys, vdsingleframe)
struct VDfrsys_oniso *framesys;
struct VDfrsys       **vdsingleframe;
{
   struct SMObjList     list;
   IGRchar              name_fr_syst[DI_PATH_MAX],
			s_name[DI_PATH_MAX];
   long                 status, msg;
   int			ret_status;
   struct GRid          mod_id;
   int                  i;
   GRspacenum   	ref_os[500]; // ref_os[100];
   IGRint       	nb_ref;
   struct GRid		ref_object;
   IGRint		max, j;
   GRclassid            cid;
   struct VDfrsys	*tmp;
   IGRint		nb_found;


   SetProc( get_singleframe_list ); Begin

   /* Select all frame system */
   ret_status = 0;
   tmp = NULL;
   nb_ref = 0;
   list.nb_objects = 0;
   list.nb_alloc = 0;
   list.list = NULL;
   nb_found = 0;

   ex$get_cur_mod( id = &mod_id.objid, osnum = &mod_id.osnum );

   /*
    * Fix for TR5836 - No. of reffiles made 500 from 100 
    */

   status = VDfind_ref_files( ref_os, 500, &nb_ref );

   for( i = 0 ;i < nb_ref ; i++ )
   {
     if( ref_os[i] == mod_id.osnum ) continue;

     ref_object.osnum = ref_os[i];

     max = OM_GA_OSDs[ref_object.osnum]->CurSpaceMapSize;

     for( j = 0 ; j < max ; ++j )
     {
       ref_object.objid = j;

       status = 
       om$get_classid( osnum     = ref_object.osnum,
                       objid     = ref_object.objid,
                       p_classid = &cid );
       
       if( om$is_ancestry_valid(subclassid   = cid,
                                superclassid = OPP_SMInfPlane_class_id )
                != OM_S_SUCCESS )
       {
         continue;
       }

       if( list.nb_alloc == 0 )
       {
         list.list = _MALLOC( 1, struct GRobj_env );
         list.nb_alloc = 1;
       }
       else
       {
         list.list = _REALLOC( list.list,
                               (1+list.nb_alloc),
                               struct GRobj_env );
         list.nb_alloc += 1;
       }

       if( list.list == NULL )
       {
          printf("Bad dynamic allocation space\n");
          list.nb_alloc -= 1;
	  goto wrapup;
       }

       list.list[list.nb_objects].obj_id.objid = ref_object.objid;
       list.list[list.nb_objects].obj_id.osnum = ref_object.osnum;
       list.nb_objects++;
     }
   }

   __DBGpr_int( "list.nb_objects", list.nb_objects);
     
   if( list.nb_objects )
   {
     tmp = 
     _MALLOC(list.nb_objects, struct VDfrsys);
   }

   for( i = 0 ; i < list.nb_objects ; i = i + 1 )
   {
     status =
     om$send( msg      = message GRvg.GRgetname(&msg, name_fr_syst),
 	      senderid = NULL_OBJID,
              targetid = list.list[i].obj_id.objid,
              targetos = list.list[i].obj_id.osnum);
     if( status&msg&1 )
     {
       di$split( pathname = name_fr_syst, name = s_name );
       strcpy( tmp[nb_found].name, s_name );
       tmp[nb_found].grid = list.list[i].obj_id;
       nb_found++;
     }
     else
       continue;
   }

   framesys->nb_singleframe = nb_found;
   if( nb_found && vdsingleframe )
   {
     (*vdsingleframe) = 
     _MALLOC(nb_found, struct VDfrsys);
   }

   for( i = 0 ; i < nb_found ; i++ )
   {
     strcpy( (*vdsingleframe)[i].name, tmp[i].name );
     (*vdsingleframe)[i].grid = tmp[i].grid;
   }

   ret_status = 1;

   wrapup:
   if( list.nb_objects > 0 && list.list != NULL ) free( list.list );
   if( tmp != NULL ) free( tmp );

   End

   return ret_status;
} /* get_frsys_list */

/*-------------------------------------------------------------------*/
/* A sort function for single frame name comparison on ascending     */
/*-------------------------------------------------------------------*/
int VDFrName_cmp( elm1, elm2 )
struct VDfrsys *elm1;
struct VDfrsys *elm2;
{
     return strcmp( elm1->name, elm2->name);
}/* VDFrName_cmp */

/*---------------------------------------------------------------------*/
int sort_single_frame( framesys, vdsingleframe )
struct VDfrsys_oniso *framesys;
struct VDfrsys       *vdsingleframe;
{
   int ret_status;


   SetProc( get_frsys_list ); Begin
  
   ret_status = 0;

   qsort( vdsingleframe,
          framesys->nb_singleframe,
          sizeof(struct VDfrsys),
          (int (*)())VDFrName_cmp );

   ret_status = 1;

   wrapup:
   End

   return ret_status;
} /* get_frsys_list */

/*----------------------------------------------------------------*/
int store_frsys_by_name( framesys, frmsys_vdfrsys, frmsys_vdsingleframe )
struct VDfrsys_oniso *framesys;
struct VDfrsys       *frmsys_vdfrsys;
struct VDfrsys       *frmsys_vdsingleframe;
{
  int	ret_status;
  int	i_obj, nb_frsys;

  SetProc( store_frsys_by_name ); Begin

  ret_status = 0;
  i_obj      = 0;
  nb_frsys   = 0;

  __DBGpr_str( "framesys->frsys", framesys->frsys );

  if( framesys->singleframe_flag )
  {
    nb_frsys = framesys->nb_singleframe;

    for( i_obj = 0 ; i_obj < nb_frsys ; i_obj = i_obj + 1 )
    {
      if( strcmp(frmsys_vdsingleframe[i_obj].name, framesys->frname) == 0)
      {
        framesys->fr_system.objid = frmsys_vdsingleframe[i_obj].grid.objid;
        framesys->fr_system.osnum = frmsys_vdsingleframe[i_obj].grid.osnum;
        break;
      }
    }
  }
  else
  {
    nb_frsys = framesys->nb_framesys;

    for( i_obj = 0 ; i_obj < nb_frsys ; i_obj = i_obj + 1 )
    {
      if( strcmp(frmsys_vdfrsys[i_obj].name, framesys->frsys) == 0)
      {
        framesys->fr_system.objid = frmsys_vdfrsys[i_obj].grid.objid;
        framesys->fr_system.osnum = frmsys_vdfrsys[i_obj].grid.osnum;
        break;
      }
    }
  }
    
  if( i_obj >= nb_frsys )
  {
    UI_status( "Frame system not found" );
    goto wrapup;
  }
  else
    __DBGpr_obj( "framesys->fr_system", framesys->fr_system);

  ret_status = 1;


  wrapup:
  End
  return ret_status;
} /* store_frsys_by_name */

/*------------------------------------------------------------------*/
int store_frame_by_all( framesys,
			frmsys_frame,
			frmsys_drwlist_0,
			frmsys_drwlist_1 )
struct VDfrsys_oniso *framesys;
struct GRid          **frmsys_frame;
struct GRobj_env     *frmsys_drwlist_0;
struct GRobj_env     **frmsys_drwlist_1;
{
  struct GRid 		*frame, drwObj, tmp1, drawview;
  IGRint          	lowest, highest, nb_elem, i;
  long            	loc_msg, status0;
  int			status, ret_status;
  struct GRobj_env	tmp_drwlist;


  SetProc( store_frame_by_all ); Begin
  __DBGpr_int( "framesys->Nb_Max_Fra", framesys->Nb_Max_Fra );

  ret_status = 0;
  frame = NULL;

  if( !framesys->Nb_Max_Fra )
  {
    if( framesys->fr_system.objid != NULL_OBJID )
    {
      if( !(framesys->singleframe_flag) )
      {
        status =
        om$send( msg      = message SMfrm_syst.SMfind_all_frame(&loc_msg,
  							        &frame,
							        NULL,
							        &nb_elem,
							        &lowest,
							        &highest),
	         senderid = NULL_OBJID,
                 targetid = framesys->fr_system.objid,
                 targetos = framesys->fr_system.osnum );
        if( !(status&loc_msg&1) ) goto wrapup;
      }
      else
      {
	nb_elem = 1;
        frame =_MALLOC(1, struct GRid);
	frame[0] = framesys->fr_system; 
      }

      framesys->Nb_Max_Fra = nb_elem;

      if( nb_elem && frmsys_frame )
      {
        (*frmsys_frame) =_MALLOC((nb_elem+20), struct GRid);
      }

      if( frmsys_drwlist_0 != NULL ) 
      {
        tmp_drwlist = frmsys_drwlist_0[0];
      }

      if( nb_elem && frmsys_drwlist_1 )
      {
        (*frmsys_drwlist_1) =_MALLOC((nb_elem+20), struct GRobj_env);
      }

      drawview = framesys->drawingview;

      for( i = 0 ; i < nb_elem ; i = i + 1 )
      {
        (*frmsys_frame)[i] = frame[i];
        tmp1 = frame[i];
	
	__DBGpr_obj( "tmp1", tmp1 );
	__DBGpr_obj( "drawview", drawview );

        status0 = VDframeObjToDrwObj( &loc_msg, tmp1, drawview, &drwObj );
        if( status0&loc_msg&1 )
	{
          (*frmsys_drwlist_1)[i] = tmp_drwlist;
          (*frmsys_drwlist_1)[i].obj_id = drwObj;
          __DBGpr_obj( "(*frmsys_drwlist_1)[i].obj_id",
			(*frmsys_drwlist_1)[i].obj_id );
        }
      }

      framesys->Nb_Max_Fra = nb_elem;
    }
  }

  ret_status = 1;

  __DBGpr_int("after framesys->Nb_Max_Fra", framesys->Nb_Max_Fra );

  wrapup:
  if( frame != NULL ) free( frame );
  End
  return ret_status;
} /* store_frame_by_all */

/*------------------------------------------------------------------*/
int store_drawing_objects( framesys )
struct VDfrsys_oniso *framesys;
{
  struct GRid 		located_obj;
  long            	status, loc_msg;
  int			dummy, ret_status;
  struct GRmd_env       ref_env;


  SetProc( store_drawing_objects ); Begin

  ret_status = 0;

  status =
  om$send( msg      =message GRdrawview.GRget_component_id(&loc_msg,
							   GR_DV_REFFILE,
                                                 	   1,
							   &located_obj,
							   &dummy),
	   senderid = NULL_OBJID,
           targetid = framesys->drawingview.objid,
           targetos = framesys->drawingview.osnum );
  if( !(status&loc_msg&1) ) goto wrapup;
  __DBGpr_obj( "located_obj", located_obj);

  /*
  ** Find matrix corresponding to the attachment
  */

  status =
  om$send( msg      = message GRreffile.GRgetenvironment(&loc_msg,
                                                         &framesys->ModuleInfo,
							 &ref_env),
	   senderid = NULL_OBJID,
           targetid = located_obj.objid,
           targetos = located_obj.osnum );
  if( !(status&loc_msg&1) ) goto wrapup;

  /*
  ** Get corresponding context
  */

  if( status&loc_msg&1 )
  {
    status = GRfindcontext( &loc_msg,
			    &ref_env.md_env.matrix_type,
                            ref_env.md_env.matrix,
			    &ref_env.md_id.osnum,
                            framesys->ref );
    if( status&loc_msg&1 )
    {
      framesys->Nb_Max_Ref = 1;
    }
    else framesys->Nb_Max_Ref = 0;
  }

  ret_status = 1;


  wrapup:
  End
  return ret_status;
}/* store_drawing_objects */

/*------------------------------------------------------------------*/
int extract_framesys( framesys,
		      frmsys_frame,
		      frmsys_Obj_List,
		      frmsys_drwlist_2 )
struct VDfrsys_oniso *framesys;
struct GRid          *frmsys_frame;
struct GRid          **frmsys_Obj_List;
struct GRobj_env     **frmsys_drwlist_2;
{
  int status, ret_status;
  int i_ref, i_fra, i;


  SetProc( extract_framesys ); Begin
  
  ret_status = 0;

  UI_status( "Extraction in progress ..." );

  if( framesys->Nb_Max_Fra && frmsys_Obj_List )
  {
    (*frmsys_Obj_List) =_MALLOC((framesys->Nb_Max_Fra+20), struct GRid);
  }

  for( i_ref = 0 ; i_ref < framesys->Nb_Max_Ref ; i_ref = i_ref + 1 )
  {
    framesys->Nb_Max_Obj = 0 ;
    for( i_fra = 0 ; i_fra < framesys->Nb_Max_Fra ; i_fra = i_fra + 1 )
    {
      status =
      as$make_source( go_grid      = frmsys_frame[i_fra],
                      context_grid = framesys->ref[i_ref],
                      as_os        = framesys->ModuleInfo.md_id.osnum,
                      as_grid      = (*frmsys_Obj_List)+framesys->Nb_Max_Obj );
      if( status&1 )
      {
        __DBGpr_obj( "framesys->ref[i_ref]", framesys->ref[i_ref] );
        __DBGpr_obj( "frmsys_frame[i_fra]", frmsys_frame[i_fra] );
        __DBGpr_obj( "(*frmsys_Obj_List)",
	              (*frmsys_Obj_List)[framesys->Nb_Max_Obj] );
        framesys->Nb_Max_Obj = framesys->Nb_Max_Obj + 1;
      }
    }
              
    status = extract( framesys, (*frmsys_Obj_List) );
    if( !(status&1) ) goto wrapup; 
  }

  /* 
  ** Find frmsys_drwlist_2 from frmsys_Obj_List
  */
  if( framesys->Nb_Max_Obj && frmsys_drwlist_2 )
  {
    (*frmsys_drwlist_2) =_MALLOC((framesys->Nb_Max_Obj+20), struct GRobj_env);
  }

  for( i = 0 ; i < framesys->Nb_Max_Obj ; i = i + 1)
  {
    (*frmsys_drwlist_2)[i].mod_env = framesys->ModuleInfo;
    (*frmsys_drwlist_2)[i].obj_id = (*frmsys_Obj_List)[i];
    __DBGpr_obj("(*frmsys_drwlist_2)", (*frmsys_drwlist_2)[i].obj_id);
  }

  UI_status( "Done" );

  ret_status = 1;


  wrapup:
  End
  return ret_status;
}/* extract_framesys */

/*------------------------------------------------------------------*/
int extract( framesys, frmsys_Obj_List )
struct VDfrsys_oniso *framesys;
struct GRid          *frmsys_Obj_List;
{
  int			ret_status;
  long			loc_msg, status, error;
  int			i_obj, i, count;
  char			*model_def_name;
  struct GRid		model_obj, model_def, drawing_def;
  struct GRid		drawing_obj, source, drawingObj;
  struct GRobj_env	pretOE;
  int			i_macro, nb_drawing_macros;
  char			**drawing_macros;
  char			dir_name[DI_PATH_MAX];
  int			nb_feet, feet_size;
  struct myfeet		*feet_desc;
  struct GRmd_env	model_env;
  enum GRdpmode 	dp_mode;
  struct ACdb_info	db_info;
  int			level[32];
  struct var_list	w_info[2];
  long			bytes_returned;
  double		vector[3], point[3];
  int			nb_total, nb_attachement, nb_created;
  IGRchar		classname[100];
  struct GRid           line_asgrid;

  SetProc( extract ); Begin
  
  ret_status        = 0;
  nb_drawing_macros = 0;
  feet_size         = 0;
  drawing_macros    = NULL;
  model_def_name    = NULL;
  feet_desc         = NULL;
  dp_mode           = GRbd;
  line_asgrid.objid = NULL_OBJID; 

  status = di$give_pathname( osnum    = framesys->ModuleInfo.md_id.osnum,
                             pathname = dir_name );
  if( !(status&1) ) goto wrapup;

  strcat( dir_name, ":constructs:*" );

  di$ls( regexp  = dir_name,
         lines   = &drawing_macros,
         ptr     = &nb_drawing_macros,
         options = 0);

  /*
  ** Get displayable level and view definition
  */

  vector[0] = 0;
  vector[1] = 0;
  vector[2] = 1;
  point[0]  = 0;
  point[1]  = 0;
  point[2]  = 0;

  if( framesys->display_window.objid != NULL_OBJID )
  {
    w_info[0].var = LEVELS;
    w_info[0].num_bytes = 32*sizeof(int);
    w_info[0].bytes_returned = &bytes_returned;
    w_info[0].var_ptr = (char *)level;
    w_info[1].var = END_PARAM;

    status =
    om$send( msg      = message IGEgragad.DPinquire(&loc_msg, &error, w_info),
	     senderid = NULL_OBJID,
             targetid = framesys->display_window.objid,
             targetos = framesys->display_window.osnum );
    if( !(status&loc_msg&1) ) goto wrapup;
  }
  else
  {
   for( i = 0 ; i < 32 ; i = i + 1) level[i] = ~0;
  }

  as$make_source( go_grid         = framesys->elementobj,
                  mod_env         = &framesys->element_env,
                  as_grid         = &line_asgrid ) ;
  if(line_asgrid.objid == NULL_OBJID)
  {
    __DBGpr_obj("make source failed for ",framesys->elementobj);
  }

  model_env.md_id.objid = NULL_OBJID;

  nb_total = framesys->Nb_Max_Obj;
  while( 1 )
  {
    /*
    ** Works one reference file attachement at the time
    */

    NDsort_per_context( nb_total, frmsys_Obj_List, &nb_attachement );

    if( !(nb_attachement) ) break;

    /*
    ** Add in the context object info like model file name, displayable level
    ** and view definition by changing its class to VDcontext
    */

    status = VDstore_levels_and_vol( frmsys_Obj_List,
				     nb_attachement,
                        	     level,
				     point,
				     vector,
				     &framesys->ModuleInfo );
    if( !(status&1) ) goto wrapup;


    nb_created = 0;
    for( i_obj = 0 ; i_obj < nb_attachement ; i_obj = i_obj + 1)
    {
      /*
      ** Get macro definition of the selected object and search if there is a
      ** drawing macro definition valid for this type of macro to know which
      ** attributes should be extracted
      */
      status =
      om$send( msg      = message NDmacro.ACreturn_foot(&loc_msg,"",
                                &model_obj,&model_env.md_env.matrix_type,
                                model_env.md_env.matrix),
	       senderid = NULL_OBJID,
               targetid = frmsys_Obj_List[i_obj].objid,
               targetos = frmsys_Obj_List[i_obj].osnum );
      model_env.md_id.osnum = model_obj.osnum;
      if( !(status&loc_msg&1) ) continue;

      status = om$send( msg      = message ACcpx.find_macro(&model_def),
			senderid = NULL_OBJID,
                        targetid = model_obj.objid,
                        targetos = model_obj.osnum);
      if( !(status&1) ) continue;

      status =
      om$send( msg      = message ACcpx_defn.ACgive_name(&model_def_name),
	       senderid = NULL_OBJID,
               targetid = model_def.objid,
               targetos = model_def.osnum);
      if( !(status&1) ) continue;


      for( i_macro = 0 ; i_macro < nb_drawing_macros ; i_macro = i_macro + 1 )
      {
        status = di$translate( objname = drawing_macros[i_macro],
                               p_objid = &drawing_def.objid,
                               p_osnum = &drawing_def.osnum );

        if( !(status&1) ) continue;

        status =
        om$send( msg      = message ACcpx_defn.ACgive_feet_desc(&nb_feet,
								&feet_desc),
		 senderid = NULL_OBJID,
                 targetid = drawing_def.objid,
                 targetos = drawing_def.osnum);
        if( !(status&1) ) continue;
 
        if( nb_feet < 1 ) continue; /* facking macro for leader line */
        if( ASmatchRE(feet_desc[nb_feet-1].name, model_def_name) ) break;
      }

      if( i_macro >= nb_drawing_macros ) continue;

      /*
      ** Check if occurence already exist of input object.
       * This check has to be made redundant for TR5112
      */
      drawing_obj.objid = NULL_OBJID ;
      status = VDchk_child_on_class( &loc_msg,
                                     &model_obj,
                                     &(frmsys_Obj_List[i_obj]),
                                     "VDdrawing",
                                     &drawing_obj );
      /*
       * change for TR5112 - delete the already existing drawing
       */
      if( drawing_obj.objid != NULL_OBJID )
      {
        __DBGpr_obj("VDdrawing already exists ",drawing_obj);
        __DBGpr_obj("New VDdrawing for pretend ->",frmsys_Obj_List[i_obj]);

        pretOE.obj_id.objid = NULL_OBJID;
        VDGetContext(&drawing_obj,NULL,&pretOE.obj_id,1,0);
        if(pretOE.obj_id.objid == NULL_OBJID)
        {
          __DBGpr_obj("Failed to find pretend for", drawing_obj);
          continue;
        }
        vd_$return_foot ( msg     = &loc_msg,
                          objId   = &pretOE.obj_id,
                          footId  = &drawingObj,
                          footEnv = &pretOE.mod_env
                        );
        if(!(loc_msg&1))
        {
          __DBGpr_obj("vd_$return_foot failed for ",pretOE.obj_id);
          continue;
        }
        gr$display_object( object_id = &drawing_obj,
                           mode      = GRbeheo );
        vd_$bulk_delete( count   = 1,
                         grids   = &drawing_obj,
                         theEnv  = &pretOE.mod_env
                       ); 
        drawing_obj.objid = NULL_OBJID;
      }
 
      if( drawing_obj.objid == NULL_OBJID )
      {
        __DBGpr_com("Construct New Macro" );

        /*
        ** initialize the drawing macro with this
        */
        status =
        om$construct( classname = "VDdrawing",
                      osnum   = framesys->ModuleInfo.md_id.osnum,
                      p_objid = &drawing_obj.objid );
        if( !(status&1) ) continue;

        drawing_obj.osnum = framesys->ModuleInfo.md_id.osnum;

        status =
	om$send( msg      = message NDnode.NDconnect(1,
						     frmsys_Obj_List+i_obj,
						     NULL_GRID,
						     ND_NEW),
		 senderid = NULL_OBJID,
                 targetid = drawing_obj.objid,
                 targetos = drawing_obj.osnum );
        if( !(status&1) ) continue;

        status =
        om$send( msg      = message NDnode.NDconnect(1,
                                                     &line_asgrid,
                                                     NULL_GRID,
                                                     ND_NEW),
                 senderid = NULL_OBJID,
                 targetid = drawing_obj.objid,
                 targetos = drawing_obj.osnum );
        if( !(status&1) ) continue;

        status =
        om$send( msg      = message ACcpx.ACload_macro(drawing_def),
		 senderid = NULL_OBJID,
                 targetid = drawing_obj.objid,
                 targetos = drawing_obj.osnum );
        frmsys_Obj_List[nb_created] = drawing_obj;
        nb_created = nb_created + 1;
      }
      else 
      {
        /*
        ** Check if object is already in list.
        */
        __DBGpr_com(" Check in existing list " );

        for( i = 0 ; i <nb_created ; i = i + 1)
          if( (drawing_obj.objid == frmsys_Obj_List[i].objid) &&
  	      (drawing_obj.osnum == frmsys_Obj_List[i].osnum) ) break ;
        if( i >= nb_created )
        {
          frmsys_Obj_List[nb_created]= drawing_obj;
  	  nb_created = nb_created + 1;
        }
      }

      /*
      ** Initialize db_info for the drawing part
      */
      status =
      om$send( msg      = message ACdb_info.ACcheckin_candidate
                                (VDS_NORMAL_CHECKIN,(int *)&loc_msg),
	       senderid = NULL_OBJID,
               targetid = model_obj.objid,
               targetos = model_obj.osnum );
      if( !(status&loc_msg&1) )
        status =
        om$send( msg      = message ACdb_info.ACcheckin_candidate
                                (VDS_FAST_CHECKIN,(int *)&loc_msg),
	         senderid = NULL_OBJID,
                 targetid = model_obj.objid,
                 targetos = model_obj.osnum );

      if( status&loc_msg&1 )
      {
        status =
        om$send( msg      = message ACdb_info.ACget_db_info(&loc_msg,&db_info),
		 senderid = NULL_OBJID,
                 targetid = model_obj.objid,
                 targetos = model_obj.osnum );
        if( !(status&loc_msg&1) )
        {
          /*
          ** Instead of stopping the drawing extraction, give warning
          ** for current object without database information and
          ** continue with drawing extraction.
          */
          om$get_classname( objid     = model_obj.objid,
                            osnum     = model_obj.osnum,
                            classname = classname );

          printf( "WARNING: %s [%d,%d] no db_info found.\n",
                  classname, model_obj.objid, model_obj.osnum );

          continue;
        }

        status =
        om$send( msg      = message ACdb_info.ACset_db_info(&loc_msg,&db_info),
		 senderid = NULL_OBJID,
                 targetid = drawing_obj.objid,
                 targetos = drawing_obj.osnum );

        status =
        om$send( msg      = message ACdb_info.ACput_serial_no(db_info.serial_no),
		 senderid = NULL_OBJID,
                 targetid = drawing_obj.objid,
                 targetos = drawing_obj.osnum );
      }
    } /* for ... */

    /*
    ** Prepare extraction of following elements
    */

    OM_BLOCK_MOVE( frmsys_Obj_List + nb_attachement,
		   frmsys_Obj_List,
                   (nb_total-nb_attachement)*sizeof(struct GRid) );
    nb_total = nb_total - nb_attachement;
  }

  ret_status = 1;


  wrapup:
  if( drawing_macros && nb_drawing_macros )
    di$free( lines = drawing_macros,
             count = nb_drawing_macros );
  End
  return ret_status;
} /* extract */

/*------------------------------------------------------------------*/
int process_object( framesys, frmsys_drwlist )
struct VDfrsys_oniso *framesys;
struct GRobj_env     *frmsys_drwlist;
{
  int                     ind, ret_status;
  struct GRid             par_obj;
  GRclassid               cid;
  int                     chan_size;
  OMuint                  nblist;
  OM_S_OBJECT_LINKAGE     slist[10];
  long                    msg;
  int                     sts, count;
  int                     fr_number;
  struct VDdrwFrmPar      drwFrmPar;
  GRname                  buffer;


  SetProc( process_object ); Begin

  ret_status = 0;

  count = framesys->Nb_Max_Obj;
  __DBGpr_int( "count", count );

  for ( ind = 0; ind < count; ind = ind + 1 )
  {
    __DBGpr_obj( "frmsys_drwlist[ind].obj_id", frmsys_drwlist[ind].obj_id);
    sts = om$get_classid(osnum     = frmsys_drwlist[ind].obj_id.osnum,
                         objid     = frmsys_drwlist[ind].obj_id.objid,
                         p_classid = &cid );

    if( om$is_ancestry_valid(subclassid   = cid,
                             superclassid = OPP_VDdrawing_class_id )
                != OM_S_SUCCESS )
    {
       frmsys_drwlist[ind].obj_id.objid = NULL_OBJID ;
       continue;
    }

    __DBGpr_obj( "frmsys_drwlist[ind].obj_id", frmsys_drwlist[ind].obj_id);

    chan_size = 10;

    sts =
    om$get_channel_objects(
                objid           = frmsys_drwlist[ind].obj_id.objid,
                osnum           = frmsys_drwlist[ind].obj_id.osnum,
                p_chanselect    = &ND_father,
                list            = slist,
                size            = chan_size ,
                count           = &nblist );
    if( (!(sts&1)) || ( nblist == 0 ) )
    {
        frmsys_drwlist[ind].obj_id.objid = NULL_OBJID ;
        continue;
    }

    __DBGpr_int(" slist[0].S_objid ", slist[0].S_objid);
    __DBGpr_int(" slist[0].osnum ", slist[0].osnum);

    sts =
    om$send( msg      = message NDmacro.ACreturn_foot(&msg,
						      "",
						      &par_obj,
						      NULL,
						      NULL),
 	     senderid = NULL_OBJID,
             targetid = slist[0].S_objid,
             targetos = slist[0].osnum );

    __DBGpr_obj(" par_obj ", par_obj);

    sts =
    om$get_classid( osnum     = par_obj.osnum,
                    objid     = par_obj.objid,
                    p_classid = &cid );

    if( !(framesys->singleframe_flag) )
    {
      if( om$is_ancestry_valid(subclassid   = cid,
                               superclassid = OPP_SMframe_class_id)
                != OM_S_SUCCESS) 
      {
        frmsys_drwlist[ind].obj_id.objid = NULL_OBJID ;
        continue;
      }

      sts =
      om$send( msg      = message SMframe.SMfind_frame_num(&msg, &fr_number),
	       senderid = NULL_OBJID,
               targetid = par_obj.objid,
               targetos = par_obj.osnum );

      if( !(sts&msg&1) )
      {
        frmsys_drwlist[ind].obj_id.objid = NULL_OBJID ;
        continue ;
      }

      sprintf( buffer, "Processing Drawing Frame : %d\n", fr_number );
      UI_status( buffer );

      __DBGpr_int("Processing Drawing Frame Number", fr_number );
   }
   else
   {
      if( om$is_ancestry_valid(subclassid   = cid,
                               superclassid = OPP_SMInfPlane_class_id)
                != OM_S_SUCCESS) 
      {
        frmsys_drwlist[ind].obj_id.objid = NULL_OBJID ;
        continue;
      }

      sprintf( buffer, "Processing Single Frame : %s\n", framesys->frname );
      UI_status( buffer );

      fr_number = 0;
   }

    /*
    ** set drawing frame parameters
    */
    sts = set_drwFramePara( fr_number, &drwFrmPar, framesys );
    if( !(sts&1) ) continue;

    sts = 
    om$send( msg      = message VDdrawing.VDset_DrwFrParaIns(&msg, drwFrmPar),
	     senderid = NULL_OBJID,
             targetid = frmsys_drwlist[ind].obj_id.objid,
             targetos = frmsys_drwlist[ind].obj_id.osnum );
    if( !(sts&msg&1) ) continue;

    /* recomputer */
    sts = recompute_object( ind, frmsys_drwlist );
    if( !(sts&1) ) continue;
  } /* for */

  ret_status = 1;


  End
  return ret_status;
}/* process_object */

/*------------------------------------------------------------------*/
int recompute_object( index, frmsys_drwlist )
int index;
struct GRobj_env     *frmsys_drwlist;
{
  int	ret_status;
  int	cn_type, wait_batch;


  SetProc( recompute_object ); Begin

  ret_status = 0;

  /*
  ** recompute the object.
  */
  __DBGpr_int( "index", index);

  cn_type = ND_COMP;            /* recompute the object */

  /*
  ** set NDmodif_flag and NDmodif
  */
  nd$wait_batch( type       = GR_GEOM_POSTED,
                 l_object   = &frmsys_drwlist[index].obj_id,
                 l_obj_info = &cn_type,
                 nb_obj     = 1 );
  __DBGpr_com( "after wait_batch");

  /*
  ** get active mode
  */
  nd$mod_batch( request    = ND_INQ,
                p_ret_mode = &wait_batch );
  __DBGpr_int( "after mod_batch : wait_batch", wait_batch);

  nd$exec_batch( mode            = ND_DISP_ROOT|ND_DISP_BODY,
                 defer_flag      = ND_IMMEDIATE );
  __DBGpr_com( "after exec_batch");

  ret_status = 1;


  End
  return ret_status;
}/* recompute_object */

/*------------------------------------------------------------------*/
int set_drwFramePara( fr_number, drwFrmPar, framesys )
int 		     fr_number;
struct VDdrwFrmPar   *drwFrmPar;
struct VDfrsys_oniso *framesys;
{
  int		ret_status;
  int 		i;


  SetProc( set_drwFramePara ); Begin

  ret_status = 0;
  drwFrmPar->tx_flag = 1; /* init with text */
  drwFrmPar->pr_flag = 1; /* init as primary line */

  if( (framesys->act_printe != 0) &&
        ((fr_number % framesys->act_printe) != 0) )
  {
    drwFrmPar->tx_flag = 0; /* without text */
    drwFrmPar->pr_flag = 0; /* init as primary line */
  }

  if( (framesys->act_txinte != 0) &&
      ((fr_number % framesys->act_txinte) != 0) )
  {
    drwFrmPar->tx_flag = 0; /* without text */
    __DBGpr_com( "Not integel times of act_txinte");
  }

  drwFrmPar->prfact = framesys->act_prfact;     /* primary factor */
  drwFrmPar->ori_flag  = framesys->orientation_flag; /* Orientation flag */
  drwFrmPar->single_flag = framesys->singleframe_flag; /* Single frame flag */
  drwFrmPar->centerline_flag = framesys->centerline_flag;/* Centerliner flag */
  drwFrmPar->frmp_flag = framesys->frmposition_flag; /* frame position flag */

  strcpy ( drwFrmPar->frsys, framesys->frsys );
  strcpy ( drwFrmPar->frname, framesys->frname );

  drwFrmPar->md_flag = framesys->md_flag;

  __DBGpr_int( "fr_number", fr_number);
  __DBGpr_int( "prfact", drwFrmPar->prfact);
  __DBGpr_int( "md_flag", drwFrmPar->md_flag);
  __DBGpr_str( "act_frsys", drwFrmPar->frsys);

  drwFrmPar->labelText  = framesys->labeltype;
  drwFrmPar->nameCase  = framesys->nameCase;   // CR179900942 by ylong
  strcpy( drwFrmPar->prefix, framesys->labelprefix );
  drwFrmPar->iso_flag = framesys->iso_flag;
  drwFrmPar->elementobj = framesys->elementobj;
  drwFrmPar->element_env = framesys->element_env;
  drwFrmPar->drawingview = framesys->drawingview;
  drwFrmPar->offset = framesys->offset;
  drwFrmPar->text_off = framesys->text_offset;

  __DBGpr_int( "labelText", drwFrmPar->labelText);
  __DBGpr_str( "prefix", drwFrmPar->prefix);
  __DBGpr_int( "iso_flag", drwFrmPar->iso_flag);
  __DBGpr_obj( "elementobj", drwFrmPar->elementobj);

  ret_status = 1;


  End
  return ret_status;
}/* set_drwFramePara */

/*
 * This function is written for the modify iso frame command
 * This returns all the iso_frames in the view which are in 
 * the same direction(x,y or z) as the reference frame
 */
IGRint VDfilterIsoFrames(
                         struct GRid          *refFrame,
                         struct GRid          **frmList,
                         IGRint               *frmCount,
                         IGRint               **frm_number,
                         struct GRobj_env     *refLine,
                         struct VDdrwFrmPar   *refPar 
                        )
{
  IGRint             ii, retFlag = 0, drwCount = 0;
  IGRint             sts = 0, iso_frm_count = 0, frame_num;
  IGRlong            msg;
  struct GRid        *drwObjs = NULL, par_frame;
  struct VDdrwFrmPar refFrmPar, drwFrmPar;
  IGRboolean         isoFlag = FALSE;
 
  if(refFrame->objid == NULL_OBJID) goto wrapup;
  if(!frmList) goto wrapup;
  
  frame_num = 0;
  sts =
    om$send(msg = message VDdrawing.VDget_DrwFrParaIns( &msg, &drwFrmPar),
	                            senderid = NULL_OBJID,
	                            targetid = refFrame->objid,
	                            targetos = refFrame->osnum );   
  if(!(sts&msg&1))
  {
    __DBGpr_obj("Failed to get frame parameters for ",*refFrame);
    goto wrapup;
  }
  *refPar = drwFrmPar;
  refLine->obj_id  = drwFrmPar.elementobj;
  refLine->mod_env = drwFrmPar.element_env;
  
  if(*frmCount == 1)
  {
    *frm_number = _MALLOC(1, IGRint);
    (*frm_number)[0] = 0;
    vdobj$GetParent( objID      = refFrame,
		     idx        = 0,
		     parentID   = &par_frame );
    if( vd_$is_ancestry_valid( object  = &par_frame,
			       classid = OPP_SMframe_class_id ) )
    { 
      sts =
	om$send( msg      = message SMframe.SMfind_frame_num(&msg, &frame_num),
		 senderid = NULL_OBJID,
		 targetid = par_frame.objid,
		 targetos = par_frame.osnum );
      
      if( sts&msg&1 )
      {
	(*frm_number)[0] = frame_num;
      }
      
    }
    retFlag = 1; 
    goto wrapup;
    
  }
  sts = VDgetDrawingObjects(refFrame, &drwCount, &drwObjs);
  if(!(sts&1) || !(drwObjs) || (drwCount == 0))
  {
    __DBGpr_obj("Failed to get drawings in view for ",*refFrame);
    goto wrapup;
  }
  *frmList = _MALLOC(drwCount, struct GRid);
  *frm_number = _MALLOC(drwCount, IGRint);
  __DBGpr_com(" multiple frames case "); 
  /*
   * Now get the iso_frames from the list of drawings in the view
   * along the same direction as the reference frame
   * criterion - macName[drawing_frame] , no. of parents[2] and
   * frame direction same as the reference
   */
  /* 
   * get reference frame parameters 
   */
  sts =
    om$send(msg = message VDdrawing.VDget_DrwFrParaIns( &msg, &refFrmPar),
	                            senderid = NULL_OBJID,
	                            targetid = refFrame->objid,
	                            targetos = refFrame->osnum );   
  if(!(sts&1))
  {
    __DBGpr_obj("Failed to get frame parameters for ",*refFrame);
    goto wrapup;
  }
  
  for(ii=0; ii<drwCount; ii++)
  {
    sts = VDcheckIsoFrame(&drwObjs[ii], &isoFlag);
    if(!(sts&1)) continue;
    if(!isoFlag) continue;
    
    sts =
    om$send(msg = message VDdrawing.VDget_DrwFrParaIns( &msg, &drwFrmPar),
                                     senderid = NULL_OBJID,
                                     targetid = drwObjs[ii].objid,
                                     targetos = drwObjs[ii].osnum );  
    
    if(strcmp(refFrmPar.frsys,drwFrmPar.frsys)) continue; 
    
    (*frm_number)[iso_frm_count] = 0;
    (*frmList)[iso_frm_count] = drwObjs[ii];
    
    vdobj$GetParent( objID      = &drwObjs[ii],
		     idx        = 0,
		     parentID   = &par_frame );
    if( vd_$is_ancestry_valid( object  = &par_frame,
			       classid = OPP_SMframe_class_id ) )
    {
      sts =
	om$send( msg      = message SMframe.SMfind_frame_num(&msg, &frame_num),
	                                    senderid = NULL_OBJID,
		                            targetid = par_frame.objid,
		                            targetos = par_frame.osnum );
      
      if( (sts&msg&1) )
      {
	__DBGpr_obj("frame object",par_frame);
	__DBGpr_int("frame number",frame_num);
	(*frm_number)[iso_frm_count] = frame_num;
      }
      
    }
    iso_frm_count ++;
  }
  
  *frmCount = iso_frm_count;     
  
  __DBGpr_int("No. of iso_frames ",iso_frm_count);
  __DBGpr_com("LIST OF ISO_FRAMES IN THE VIEW ");
  __DBGpr_objlist("iso_frame ",iso_frm_count,*frmList);
  __DBGpr_int(" frmCount ",*frmCount);
  //Done
  retFlag = 1;
 wrapup:
  return retFlag;
}

/* This function attaches the new reference line for the iso frame
 * This is done for the modify iso frames command
 */
IGRint VDisoChangeParent(
                         struct GRid        *as_grid,
                         struct GRmd_env    *md_env,
                         IGRint             isoCount,
                         struct GRid        *isoList,
                         struct VDdrwFrmPar *frmPars 
                        )
{
  IGRint       retFlag = 0;
  IGRint       ii, sts; 
  IGRlong      msg;
  struct GRid  pretendID;
  int          cn_type = ND_COMP ;
  IGRboolean   isoFlag = FALSE;
  
  if(isoCount == 0) goto wrapup;
  if(!isoList)      goto wrapup;
  if(!frmPars)      goto wrapup;
  if( !as_grid )    goto wrapup;
  
  for(ii=0; ii<isoCount; ii = ii+1)
  {
    sts =
      om$send( msg = message VDdrawing.VDset_DrwFrParaIns(&msg,frmPars[ii]),
	                                    senderid = NULL_OBJID,
	                                    targetid = isoList[ii].objid,
	                                    targetos = isoList[ii].osnum );
    if( !(sts&msg&1) )
    {
      __DBGpr_obj("VDdrawing.VDset_DrwFrParaIns failed",isoList[ii]);
      continue;
    }
    if(as_grid->objid != NULL_OBJID)
    {
      pretendID.objid = NULL_OBJID;
      
      vdchn$Get2(objID  = &isoList[ii],
		 chnIDx = VDCHN_IDX_PARENT,
		 nth    = 1,
		 outID  = &pretendID );
      if(pretendID.objid == NULL_OBJID) continue;
      
      sts = om$send(  msg     = message NDnode.NDchange_connect(1, &pretendID,
							      as_grid ),
		                             senderid= NULL_OBJID,
		                             targetid= isoList[ii].objid,
		                             targetos= isoList[ii].osnum ) ;
      if(!(sts&1))
      {
	__DBGpr_obj("NDnode.NDchange_connect failed",isoList[ii]);
	continue;
      }
    } 
    nd$wait_batch(      type            = GR_GEOM_POSTED,
                        l_object        = &isoList[ii],
                        l_obj_info      = &cn_type,
                        nb_obj          = 1 );
  }
  nd$exec_batch();
  
  //Done
  retFlag = 1;
 wrapup:
  return retFlag;
}
/* This function checks if a drawing is an iso_frame or not
 * based on the second parent which is a reference line
 */

IGRint VDcheckIsoFrame(
                       struct GRid *drawing,
                       IGRboolean  *isoFlag
                      )
{
  IGRint        retFlag = 0;
  GRname        macName;
  struct GRid   pretendID;  

  if(!drawing) goto wrapup;

  macName[0]      = '\0';
  pretendID.objid = NULL_OBJID;
  
  *isoFlag = FALSE;
  
  vdobj$Get(objID = drawing, macName = macName);
  __DBGpr_obj("drawing_obj ",*drawing);
  __DBGpr_str(" MACRONAME for drawing_obj ",macName);
  
  if(strcmp(macName,"drawing_frame")) goto wrapup;
  
  vdchn$Get2(objID  = drawing,
             chnIDx = VDCHN_IDX_PARENT,
             nth    = 1,
             outID  = &pretendID );
  if(pretendID.objid != NULL_OBJID) *isoFlag = TRUE;
  else *isoFlag = FALSE; 
  
  //Done
  retFlag = 1;
 wrapup:
  return retFlag;
}
end implementation Root;
