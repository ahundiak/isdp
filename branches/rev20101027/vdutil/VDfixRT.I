/* $Id: VDfixRT.I,v 1.1 2001/01/10 18:12:25 art Exp $  */
/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:        vdutil/VDfixRT.I
 *
 * Description: Functions to fix Rtree.
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDfixRT.I,v $
 *      Revision 1.1  2001/01/10 18:12:25  art
 *      sp merge
 *
# Revision 1.2  2000/11/13  14:08:58  pinnacle
# Replaced: vds/vdutil/VDfixRT.I for:  by jwfrosch for Service Pack
#
 *
 * History:
 *      MM/DD/YY        AUTHOR          DESCRIPTION
 *      10/25/00        Rama Rao        File Creation.
 * -------------------------------------------------------------------*/

class implementation VDSroot;

#include "VDobj.h"
#include "OMspecify.h"
#include "OMrelation.h"
#include "OMDB.h"
#include "OMindex.h"
#include "OMrtreedef.h"
#include "OMintprims.h"
#include "VDmem.h"

#define	VD_DEBUG
#include	<VDdebug.h>

extern GRclassid	OPP_GRrtree_class_id;

from GRrtree	import	remove;

void VDrtUpdateNonLeavesRecurse( R_PAGE_3D_FLT *root_page )
{
  IGRint                 i;
  R_PAGE_3D_FLT         *cur_page_p;
  OM_S_RTREESTAT         rtree_info;
  DB_3D_FLT_BOX         *key_p;
  OM_S_RIP               rip;

  if( root_page == NULL ) return;

  if( NOT_R_LEAF( root_page->Header.Page_type ) )
  {
    if( root_page->Key )
    {
      rtree_info.request_type                  = RTREE_PAGE_STATUS ;
      rtree_info.rtree_status.page.level_no    = 0 ;

      DB_rtree_get_status_3d_flt( root_page, &rtree_info );

      key_p = root_page->Key ;
      key_p->xmin = rtree_info.rtree_status.page.page_range.r3ddkey.xmin;
      key_p->ymin = rtree_info.rtree_status.page.page_range.r3ddkey.ymin;
      key_p->zmin = rtree_info.rtree_status.page.page_range.r3ddkey.zmin;
      key_p->xmax = rtree_info.rtree_status.page.page_range.r3ddkey.xmax;
      key_p->ymax = rtree_info.rtree_status.page.page_range.r3ddkey.ymax;
      key_p->zmax = rtree_info.rtree_status.page.page_range.r3ddkey.zmax;
    }
  }

  for ( i=0; i<root_page->Header.Key_count; i++ )
  {
    cur_page_p = NULL;
    cur_page_p = DEREF(R_PAGE_3D_FLT, root_page->Objid[i], rip);
    if( cur_page_p && NOT_R_LEAF( cur_page_p->Header.Page_type ) )
      VDrtUpdateNonLeavesRecurse( cur_page_p );
  }
}

void VDrtDelKeysInRTreeRecurse( R_PAGE_3D_FLT *root_page, struct GRid rtree_id )
{
  IGRlong                       sts, msg;
  IGRint                        i, objid_p, ret;
  IGRdouble                     range[6];
  R_PAGE_3D_FLT                *cur_page_p;
  DB_3D_FLT_BOX                 key_p;
  OM_S_RIP                      rip;
  OM_S_KEY_DESC                 keyentry;

  __enterFunction ( name = "VDrtDelKeysInRTreeRecurse", argfmt = "root_page = %#x, rtree_id = [%d,%d]",
                    args = `root_page, rtree_id.osnum, rtree_id.objid`);

  if( NOT_R_LEAF( root_page->Header.Page_type ) )
  {
    __printf("NOT_R_LEAF root_page->Header.Key_count = %d", `root_page->Header.Key_count`);

    for ( i=0; i<root_page->Header.Key_count; i++ )
    {
      key_p = root_page->Key[i];
      objid_p = (int)  root_page->Objid[i];

      cur_page_p = DEREF(R_PAGE_3D_FLT, objid_p, rip);
      if( cur_page_p )  VDrtDelKeysInRTreeRecurse( cur_page_p, rtree_id );
    }
  }
  else
  {
    __printf("    R_LEAF root_page->Header.Key_count = %d", `root_page->Header.Key_count`);

    for ( i=0; i<root_page->Header.Key_count; i++ )
    {
      key_p = root_page->Key[i];
      objid_p = (int)  root_page->Objid[i];

      cur_page_p = NULL;
      cur_page_p = DEREF(R_PAGE_3D_FLT, objid_p, rip);
      if( cur_page_p && NOT_R_LEAF( cur_page_p->Header.Page_type ) )
        VDrtDelKeysInRTreeRecurse( cur_page_p, rtree_id );

      keyentry.type = KEY_3D_DBL ;
      range[0] = key_p.xmin; range[1] = key_p.ymin; range[2] = key_p.zmin;
      range[3] = key_p.xmax; range[4] = key_p.ymax; range[5] = key_p.zmax;

      keyentry.key.p_3ddbl = (DB_3D_DBL_BOX *) range;

      sts = om$send( msg = message GRrtree.remove( &keyentry,
                                                   (IGRulong *)&objid_p,
                                                   0,
                                                   &ret ),
                     senderid = rtree_id.objid,
                     targetid = rtree_id.objid,
                     targetos = rtree_id.osnum );
    }
  }

  __exitFunction ( name = "VDrtDelKeysInRTreeRecurse", argfmt = "root_page = %#x, rtree_id = [%d,%d]",
                    args = `root_page, rtree_id.osnum, rtree_id.objid`);
}

IGRlong         VDrtDelKeysInRTree()
{
  IGRint                  i, j, cnt, *objid_p;
  IGRlong                 msg;
  OMuword                 savedOS;
  struct GRid             obj_chk;
  struct GRmd_env         md_env;
  OM_S_OBJID             *list;
  R_PAGE_3D_FLT          *root_page;
  OM_S_RIP                rip;

  __enterFunction ( name = "VDrtDelKeysInRTree" );

  gr$get_module_env( buffer = &md_env );

  list = NULL;
  VDpms_find_objects( md_env.md_id.osnum, OPP_GRrtree_class_id, &cnt, list );

  __printf("# of GRrtree = %d", `cnt`);

  if( !( list = _MALLOC( cnt, OM_S_OBJID ) ) ) return 1;

  VDpms_find_objects( md_env.md_id.osnum, OPP_GRrtree_class_id, &cnt, list );

  savedOS = OM_Gw_current_OS ;

  om$make_current_os( osnum = md_env.md_id.osnum );

  for( i=0; i<cnt; i=i+1 )
  {
    obj_chk.objid = list[i];
    obj_chk.osnum = md_env.md_id.osnum;

    root_page = NULL;

    root_page = DEREF(R_PAGE_3D_FLT, list[i], rip);

/*
    om$send( msg = message GRrtree.debug(),
             senderid = NULL_OBJID,
             targetid = list[i],
             targetos = md_env.md_id.osnum );
    VDrtGetRTPage( &root_page );

    DB_rtree_deltree( list[i], root_page );

    sts =
    om$send( mode     = OM_e_wrt_message,
             msg      = message OMindex.delete(0),
             senderid = list[i],
             targetid = list[i]  );
    om$report_error( sts = sts );
*/
    if( root_page == NULL ) continue;
    VDrtDelKeysInRTreeRecurse( root_page, obj_chk );
  }

  om$make_current_os( osnum = savedOS );
  _FREE( list );

  __exitFunction ( name = "VDrtDelKeysInRTree" );
  return 1;
}

IGRlong	VDrtUpdateNonLeaves()
{
  IGRint                  i, j, cnt, *objid_p;
  IGRlong                 msg;
  OMuword                 savedOS;
  struct GRid             obj_chk;
  struct GRmd_env         md_env;
  OM_S_OBJID            *list;
  R_PAGE_3D_FLT                 *root_page;
  OM_S_RIP                rip;

  gr$get_module_env( buffer = &md_env );

  list = NULL;
  VDpms_find_objects( md_env.md_id.osnum, OPP_GRrtree_class_id, &cnt, list );

  if( !( list = _MALLOC( cnt, OM_S_OBJID ) ) ) return 1;

  VDpms_find_objects( md_env.md_id.osnum, OPP_GRrtree_class_id, &cnt, list );

  savedOS = OM_Gw_current_OS ;

  om$make_current_os( osnum = md_env.md_id.osnum );

  for( i=0; i<cnt; i=i+1 )
  {
    obj_chk.objid = list[i];
    obj_chk.osnum = md_env.md_id.osnum;

    root_page = NULL;
    root_page = DEREF(R_PAGE_3D_FLT, list[i], rip);
/*
    om$send( msg = message GRrtree.debug(),
             senderid = NULL_OBJID,
             targetid = list[i],
             targetos = md_env.md_id.osnum );
    VDrtGetRTPage( &root_page );
*/
    if( root_page == NULL ) continue;
    VDrtUpdateNonLeavesRecurse( root_page );
  }

  om$make_current_os( osnum = savedOS );
  _FREE( list );
  return 1;
}

/******************* DB_rtree_deltree *******************************/

//  DB_rtree_deltree( OM_S_OBJID my_id, R_PAGE_3D_FLT *root_page_p )
//  {
//     int   rtn;
//     if (root_page_p->Header.Key_count == 0)
//     {
//        rtn = ( DB_KEYNOTFOUND );
//     }
//     rtn = DB_rtree_deltree_3d_flt(my_id, root_page_p);
//     return( rtn );
//  }

/******************* DB_rtree_deltree *******************************/

IGRlong VDrtree_DelRTree()
{
  IGRint                  cnt;
  IGRlong                 msg;
  OMuword                 savedOS;
  struct GRmd_env         md_env;
  OM_S_OBJID              list;
  R_PAGE_3D_FLT          *root_page;
  OM_S_RIP                rip;

  __enterFunction ( name = "VDrtree_DelRTree" );

  gr$get_module_env( buffer = &md_env );

  VDpms_find_objects( md_env.md_id.osnum, OPP_GRrtree_class_id, &cnt, &list );

  __printf("# of GRrtree = %d, list = %d, md_id = [%d,%d]",
           `cnt, list, md_env.md_id.osnum, md_env.md_id.objid`);

  savedOS = OM_Gw_current_OS ;

  om$make_current_os( osnum = md_env.md_id.osnum );

  root_page = NULL;

  root_page = DEREF(R_PAGE_3D_FLT, list, rip);
  __printf("root_page = %#x, root_page->Header.Key_count = %d",
           `root_page, root_page->Header.Key_count`);

  if( root_page == NULL )
    goto wrapup;

  DB_rtree_deltree( list, root_page );

wrapup:

  om$make_current_os( osnum = savedOS );

  __exitFunction ( name = "VDrtree_DelRTree" );
  return 1;
}

end implementation VDSroot;
