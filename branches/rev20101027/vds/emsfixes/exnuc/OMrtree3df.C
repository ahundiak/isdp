/* $Id: OMrtree3df.C,v 1.4 2001/03/23 21:43:51 ramarao Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:        vds/emsfixes/exnuc/OMrtree3df..C
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: OMrtree3df.C,v $
 *	Revision 1.4  2001/03/23 21:43:51  ramarao
 *	Fixed a crash.
 *	
 *	Revision 1.3  2001/02/19 22:55:02  ramarao
 *	Fixed ETL# 6641 and 6231.
 *	
 *	Revision 1.2  2001/01/13 00:42:05  hans
 *	SP16 modifications
 *	
 *	Revision 1.1  2001/01/12 23:20:24  hans
 *	SP16 modifications
 *
 *
 * History:
 * MM/DD/YY   AUTHOR  	DESCRIPTION
 * 04/08/00   Rama Rao   Fixed the memory related crashes.
 *			TR#179900594, 595, 717 and 1281.
 * 10/06/00   Rama Rao	Fixed the crash problem while bringing up a file.
 *		        TR#179902077.
 * 10/17/00   Rama Rao	Fixed Range Tree Problems. TR#179901860.
 * 11/15/2000 HF	No TR/CR - More Range Tree Problems
 *                      Added function DB_rtree_deltree_3d_flt()
 * -------------------------------------------------------------------*/

#include "stdio.h"
#include "OMminimum.h"
#include "OMDB.h"
#include "OMindex.h"
#include "OMrtreedef.h"
#include <math.h>
#include "OMspecify.h"
#include "OMrelation.h"
#include "OMintprims.h"
#include "stdio.h"
#include "VDobj.h"

#define	VD_DEBUG
#include	<VDdebug.h>

static	VD_OMrtree_delete1;

void VDsetOMrtree_delete1()        { VD_OMrtree_delete1 = 1 ; }
void VDresetOMrtree_delete1()      { VD_OMrtree_delete1 = 0 ; }
int  VDgetOMrtree_delete1()        { return VD_OMrtree_delete1 ; }

/********************** DB_rtree_page_skewsrch_3d_flt ******************/
/* this routine is responsible for searching an rtree node
   and invoking the appropiate routine. */

int DB_rtree_page_search_3d_flt ( root_page_p, range1, range2, vector, local_context_p, classStatMap, inside_flag)

  R_PAGE_3D_FLT              *root_page_p;
  DB_3D_FLT_BOX              *range1;
  DB_3D_FLT_BOX              *range2;
  DB_vector                  *vector;
  RTREE_LOCAL_CONTEXT_3D_FLT *local_context_p;
  OMbyte                     *classStatMap;
  int                         inside_flag;
{
  R_PAGE_3D_FLT            *cur_page_p, *next_page_p;
  R_PACKED_KEYENTRY_3D_FLT  packed_keyentry;
  DB_3D_FLT_BOX            *key_p;
  OM_p_OBJID                objid_p;
  OM_S_RTREESTAT            rtree_info ;
  OM_S_RIP                  rip;
  int                       return_code, loc_inside_flag;
  unsigned short            i;

  loc_inside_flag = inside_flag;
  cur_page_p      = root_page_p;
  key_p           = cur_page_p->Key;
  objid_p         = cur_page_p->Objid;
  if ( NOT_R_LEAF(cur_page_p->Header.Page_type) )
  {
    if ( loc_inside_flag )
    {
      for (i = 0; i < cur_page_p->Header.Key_count; i++)
      {
        next_page_p = DEREF(R_PAGE_3D_FLT, (*objid_p), rip);
        if (next_page_p == NULL)
        {
          return(DB_E_NULLDEREF);
        }
        if ( (return_code = DB_rtree_page_search_3d_flt(next_page_p,
                                                        range1, range2, vector,
                                                        local_context_p,
                                                        classStatMap,
                                                        loc_inside_flag)) != DB_CONTINUE )
        {
          return(return_code);
        }
        key_p   += 1;
        objid_p += 1;
      }/*end for */
    }/*end if inside_flag set*/
    else
    {
      /* process non-leaf page */

      /* START VDS CORRECTION - RAMA RAO 10/17/2000 */

      if( key_p && cur_page_p->Header.Key_count )
      {
        rtree_info.request_type                  = RTREE_PAGE_STATUS ;
        rtree_info.rtree_status.page.level_no    = 0 ;

        DB_rtree_get_status_3d_flt( cur_page_p, &rtree_info );

        key_p->xmin = rtree_info.rtree_status.page.page_range.r3ddkey.xmin;
        key_p->ymin = rtree_info.rtree_status.page.page_range.r3ddkey.ymin;
        key_p->zmin = rtree_info.rtree_status.page.page_range.r3ddkey.zmin;
        key_p->xmax = rtree_info.rtree_status.page.page_range.r3ddkey.xmax;
        key_p->ymax = rtree_info.rtree_status.page.page_range.r3ddkey.ymax;
        key_p->zmax = rtree_info.rtree_status.page.page_range.r3ddkey.zmax;
      }

      /* END VDS CORRECTION - RAMA RAO 10/17/2000 */

      for (i = 0; i < cur_page_p->Header.Key_count; i++)
      {
        if ( DB_lr_intersect_3d_flt(range1, range2, vector, key_p) )
        {
          if ( !range2 )            /*this test only valid for non skew*/
          {
            if (( key_p->xmin >= range1->xmin) &&
                ( key_p->ymin >= range1->ymin) &&
                ( key_p->zmin >= range1->zmin) &&
                ( key_p->xmax <= range1->xmax) &&
                ( key_p->zmax <= range1->zmax) &&
                ( key_p->ymax <= range1->ymax))
            {
              loc_inside_flag = TRUE;
            }
          }
          next_page_p = (R_PAGE_3D_FLT *) DEREF(char, *objid_p, rip);
          if (next_page_p == NULL)
          {
            return(DB_E_NULLDEREF);
          }

          if ( (return_code = DB_rtree_page_search_3d_flt(next_page_p,
                                                          range1, range2, vector,
                                                          local_context_p,
                                                          classStatMap,
                                                          loc_inside_flag)) != DB_CONTINUE )
          {
            return(return_code);
          }
        }
        loc_inside_flag = FALSE;
        key_p   += 1;
        objid_p += 1;
      }
    }/*end if not inside flag*/
  }/*end if non leaf page*/
  else
  {
    /* process leaf page */

    for (i = 0; i < cur_page_p->Header.Key_count; i++)
    {
      if ( loc_inside_flag || DB_lr_intersect_3d_flt( range1, range2, vector, key_p) )
      {
        if (
/* START VDS CORRECTION - RAMA RAO 10/06/2000 */

          ((*objid_p)<OM_Gp_CurOSD->CurSpaceMapSize) &&

/* END VDS CORRECTION - RAMA RAO 10/06/2000 */

          (!(OM_Gp_CurSpaceMap[*objid_p].flags & OM_SM_unknown_obj)) &&
          (!classStatMap ||

/* START VDS CORRECTION - RAMA RAO 04/08/2000 */

           ((OM_Gp_CurSpaceMap[*objid_p].p_acld) &&

/* END VDS CORRECTION - RAMA RAO 04/08/2000 */

            classStatMap[OM_GA_active_to_filed[OM_Gp_CurSpaceMap[*objid_p].p_acld->w_classid]])))
        {
	  OMuword 	clsId;

          /* invoke user supplied action routine. */
          packed_keyentry.Coordinates = *key_p;
          packed_keyentry.Objid = *objid_p;

          /*
           * Check if we are working with an valid object in the RTREE.
           */
          om$get_classid( osnum = OM_Gw_current_OS, objid = *objid_p,
                          p_classid  = &clsId ) ;

          if((om$is_ancestry_valid(
                         superclassname = "GRgraphics",
                         subclassid    = clsId ) == OM_S_SUCCESS ) ||
	     (om$is_ancestry_valid(
                         superclassname = "OMrtree",
                         subclassid    = clsId ) == OM_S_SUCCESS ) ){

		if( OM_Gf_verbose_warning &&
		    (om$is_ancestry_valid(
                         superclassname = "ACrg_collect",
                         subclassid    = clsId ) == OM_S_SUCCESS ) )
		{
                     struct GRid     object;

                     object.objid = *objid_p; object.osnum = OM_Gw_current_OS;

                     vdobj$Print( objID = &object );
		}
             if ((return_code = (*local_context_p->user_action_routine_p)
                 (&packed_keyentry, local_context_p->user_context_p))
                != DB_CONTINUE)
             {
                 return(return_code);
             }
	  }
	  else  if( OM_Gf_verbose_warning )
  	  { 
		struct GRid 	object;

		object.objid = *objid_p; object.osnum = OM_Gw_current_OS;

		vdobj$Print( objID = &object );
	  }
        }    /* if user specified class */
      }      /* if intersect */
      key_p   += 1;
      objid_p += 1;
    }
  }

  return(DB_CONTINUE);
}

/************************ DB_rtree_deltree_3d_flt ************************/
DB_rtree_deltree_3d_flt( my_id, page_p )

  OM_S_OBJID my_id;
  R_PAGE_3D_FLT *page_p;

{
  unsigned short i;
  OM_S_OBJID     tobj;
  R_PAGE_3D_FLT *nl_page_p;
  OM_S_RIP       rip;
  OM_p_OBJECTHDR p_object;
  int            sts;

  __enterFunction ( name   = "DB_rtree_deltree_3d_flt", argfmt = "my_id = %d, page_p = %#x",
                    args = `my_id, page_p` );

  if ( NOT_R_LEAF(page_p->Header.Page_type) )
  {
    for ( i = 0; i < page_p->Header.Key_count; i++ )
    {
      nl_page_p = DEREF(R_PAGE_3D_FLT, page_p->Objid[i], rip);
      if (nl_page_p == NULL)
      {
        __exitFunction ( name   = "DB_rtree_deltree_3d_flt", argfmt = "sts = %d", args = `DB_E_NULLDEREF` );
        return(DB_E_NULLDEREF);
      }

      DB_rtree_deltree_3d_flt( my_id, nl_page_p);
    }

    tobj = REF( OM_S_OBJID, page_p );
    if ( IF_EQ_OBJID(tobj, NULL_OBJID) )
    {
      __exitFunction ( name   = "DB_rtree_deltree_3d_flt", argfmt = "sts = %d", args = `DB_E_NULLIDREF` );
      return(DB_E_NULLIDREF);
    }

    if ( ! IF_EQ_OBJID( my_id, tobj ) )
    {
      p_object = (OM_p_OBJECTHDR)((int)page_p - (int)sizeof(OM_S_OBJID) - (int)sizeof(int) - (int)sizeof(OM_S_OBJECTHDR));

      __printf(">>>>> om$delete_object() 111 objid = [%d,%d], p_object = %#x",`OM_Gw_current_OS, tobj, p_object`);

      sts = om$delete_object(osnum=OM_Gw_current_OS, object=p_object, objid=tobj);

      __printf("<<<<< om$delete_object() 111 objid = [%d,%d], p_object = %#x, sts = %d",`OM_Gw_current_OS, tobj, p_object, sts`);

      if (!(sts&1))
      {
        om$report_error(sts=sts);
        exit(1);
      }
    }
  }
  else			/* leaf page */
  {
    tobj = REF( OM_S_OBJID, page_p );
    if ( IF_EQ_OBJID(tobj, NULL_OBJID) )
    {
      __exitFunction ( name   = "DB_rtree_deltree_3d_flt", argfmt = "sts = %d", args = `DB_E_NULLIDREF` );
      return(DB_E_NULLIDREF);
    }

    if ( ! IF_EQ_OBJID( my_id, tobj ) )
    {
      p_object = (OM_p_OBJECTHDR)((int)page_p - (int)sizeof(OM_S_OBJID) - (int)sizeof(int) - (int)sizeof(OM_S_OBJECTHDR));

      __printf(">>>>> om$delete_object() 222 objid = [%d,%d], p_object = %#x, VD_OMrtree_delete1 = %d",
               `OM_Gw_current_OS, tobj, p_object, VD_OMrtree_delete1`);
      if (om$is_objid_valid(objid=tobj, osnum=OM_Gw_current_OS))
      {
        // HF: 11/15/2000 - In one particular case, objects with these weird id's show up and still cause a crash...
        if ( VD_OMrtree_delete1 && tobj > OM_Gp_CurOSD->CurSpaceMapSize )
        {
          // DO NOTHING !!!
        }
        else
        {
          sts = om$delete_object( osnum=OM_Gw_current_OS, object=p_object, objid=tobj );

          __printf("<<<<< om$delete_object() 222 objid = [%d,%d], p_object = %#x, sts = %d, VD_OMrtree_delete1 = %d",
                   `OM_Gw_current_OS, tobj, p_object, sts, VD_OMrtree_delete1`);
          if (!(sts&1))
          {
            om$report_error(sts=sts);
            if ( ! VD_OMrtree_delete1 )
              exit(1);
          }
        }
      }
    }
  }
  __exitFunction ( name   = "DB_rtree_deltree_3d_flt", argfmt = "sts = %d", args = `DB_SUCCESS` );
  return(DB_SUCCESS);
}
