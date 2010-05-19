/* $Id: VDFindObjs.I,v 1.2 2002/03/18 16:48:34 ramarao Exp $ */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/vdutil/VDFindObjs.I
 *
 * Description:
 *	Get all the objects in reference files within the given range.
 *
 * Dependencies:
 *
 * Revision History:
 *
 * History:
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *      02/10/00	Rama Rao	File Creation
 * -------------------------------------------------------------------*/

class implementation Root;

#include "OMerrordef.h"
#include "OMmacros.h"
#include "igetypedef.h"
#include "igrtypedef.h"
#include "gr.h"
#include "igr.h"
#include "igrdp.h"
#include "go.h"
#include "growner.h"
#include "bserr.h"
#include "bsbxint.h"
#include "EMSmsgdef.h"
#include "VDmem.h"
#include "v_datamacros.h"
#include "vdrefmacros.h"

static  char            OMPMS_pgHdr[512];

#define DEBUG 0

from GRgraphics import GRgetrang;


IGRboolean VDis_Superclass( nb_class, classids, subclassid )
  int            nb_class;                      /* Number of Classes      */
  uword         *classids;                      /* Classes to find        */
  uword		 subclassid;			/* class to check against */
{
  int i;
  for(i=0; i<nb_class; ++i ) 
     if( ( om$is_ancestry_valid( subclassid   = subclassid,
                                 superclassid = classids[i] ) == OM_S_SUCCESS ))  return TRUE;
  return FALSE;
}

int VDpms_findall_ancestryobjects ( OSnum, nb_class, classids, cnt, list)
  uword          OSnum;                         /* Object space number    */
  int            nb_class;                      /* Number of Classes      */
  uword         *classids;                      /* Classes to find        */
  int           *cnt;                           /* Number found           */
  OM_S_OBJID    *list;                          /* Optional list of OID's */
{
  char		  classname[132];
  uword		  filedid;
  int		  max_entry;	        /* Last object space map entry	 */
  OMuint	  flags;		/* Space map entry flags	 */
  OM_p_OSD	  p_OSD;		/* Ptr to object space descriptor */
  OM_p_SPAMAPENT  spamapent_p;	        /* Ptr to space map entry	 */
  OM_S_OBJID	  oid;		        /* Object id (of space map entry) */
  int		  obj_count;	        /* Number of objects in object space
					   & number of objs being displayed */

  *cnt = 0;

  obj_count = 0; // Bad class would be bad without this

  //if ( 1 & ( om$get_classname (classname = classname, classid = classid ) ) ) 
  {
    obj_count = 0;
    p_OSD = OM_GA_OSDs[OSnum];				/* Ptr to our obj space entry in
  							   obj space descr table */
    if (p_OSD->CurSpaceMapSize) 
    {
      for (max_entry = p_OSD->CurSpaceMapSize-1,	/* Start at end of map */
           spamapent_p = &p_OSD->Spacemap[max_entry];
           max_entry >= 0; max_entry--, spamapent_p-- )
      {
        if ( ! OM_OBJ_INVALID(spamapent_p->flags)) break; /* Find last entry */
      }

//      PMSPRNT(("Locating objects of class %s in OS #%d, %s\n", 
//        OM_GA_active_classes[classid]->s_name, 
//        OMPMS_current_OS_number,
//        OMPMS_current_OS_name));

      for (oid=0, spamapent_p = p_OSD->Spacemap;	/* For each valid   */
           (int) oid <= max_entry;  oid++, spamapent_p++) 
      {							/* entry...         */
        if ( (spamapent_p->flags  != 0) &&		/* If object shows  */
             (spamapent_p->p_acld != NULL) ) 
        {						/*  signs of life   */
          flags = spamapent_p->flags;

          if ( !(spamapent_p->flags & OM_SM_unknown_obj) &&
		VDis_Superclass( nb_class, classids, spamapent_p->p_acld->w_classid ) )
          {						/* Obj in our class? */

	    if ( list ) list[obj_count] = oid;
	    
            obj_count++;				/* Displayed count   */
          }
          if (OMpms_pause() == -1) break;		/* End loop if user sez quit */
        }
      }							/* End of for loop */
      OMPMS_pgHdr[0] = 0;
    } 
  }							 /* if given a valid class */

  *cnt = obj_count;

  return (1);
}

long VD_findall_objects_in_range( range, nb_class, classids, look_ref, cur_env, cnt, list )
GRrange            range;                        /* I - Input Range */
int                nb_class;                     /* I - Number of Classes      */
uword             *classids;                     /* I - Classes to find        */
IGRboolean         look_ref;                     /* I - Look in reference files? */
struct GRmd_env    cur_env;                      /* I - Active Module Env */
int               *cnt;                          /* O - Object Count */
struct GRobj_env **list;                         /* O - Output Object List */
{
  long                  msg, sts;
  BSrc			rc;
  int                   i, j, NbRefOs=0;
  GRspacenum            *RefOsList=NULL;
  struct GRmd_env       *RefEnvList=NULL;
  struct GRid           obj_chk;
  GRrange               elmRng;
  short                 world ; /* Compute range in world coordinate. */

   // Validate the Input Arguments
   if( !classids || !cnt || !list )	return ( OM_E_INVARG );

   // Initialization
   *cnt  = 0;
   *list = NULL;

   #if DEBUG
	printf("Input Range = %g, %g, %g, %g, %g, %g\n", range[0], range[1], range[2], range[3], range[4], range[5] );
   #endif

   if( look_ref )
   {
      #if DEBUG
	printf("Looking for reference os list");
      #endif

      sts = vd$get_ref_os_list( msg           =  &msg,
                                main_os       =  NULL,
                                num_ref_os    =  &NbRefOs,
                                ref_os_list   =  &RefOsList,
                                ref_env_list  =  &RefEnvList );
      #if DEBUG
        printf(" --- Got %d\n", NbRefOs);
      #endif
      if( NbRefOs )
      {
         if( !( RefOsList = _REALLOC(  RefOsList, NbRefOs+1, GRspacenum ) ) )  vd_$mem_fail(msg=&msg);
         RefOsList[NbRefOs] = cur_env.md_id.osnum;

         if( !( RefEnvList = _REALLOC( RefEnvList, NbRefOs+1, struct GRmd_env ) ) )  vd_$mem_fail(msg=&msg);
         RefEnvList[NbRefOs] = cur_env;

         NbRefOs++;
      }
   }

   if( !NbRefOs )
   {
      #if DEBUG
	printf(" Looking only in active os\n");
      #endif
      if( !( RefOsList = _MALLOC( 1, GRspacenum ) ) ) vd_$mem_fail(msg=&msg);
      RefOsList[0] = cur_env.md_id.osnum;

      if( !( RefEnvList = _MALLOC( 1, struct GRmd_env ) ) )  vd_$mem_fail(msg=&msg);
      RefEnvList[0] = cur_env;

      NbRefOs = 1;
   }

   for( i=0; i<NbRefOs; ++i )
   {
        int             loc_cnt = 0, cnt_range=0;
        OM_S_OBJID      *loc_list = NULL;

	#if DEBUG
          printf("Osnum[ %d ] = %d, *cnt=%d", i, RefOsList[i], *cnt );
	#endif

        VDpms_findall_ancestryobjects( RefOsList[i], nb_class, classids, &loc_cnt, NULL );

	#if DEBUG
           printf("\t loc_cnt = %d\n", loc_cnt );
	#endif

        if( !loc_cnt ) {  _FREE( loc_list );   continue; }

        if( !( loc_list = _MALLOC( loc_cnt, OM_S_OBJID ) ) )  vd_$mem_fail(msg=&msg);
        if ( loc_list )  VDpms_findall_ancestryobjects ( RefOsList[i], nb_class, classids, &loc_cnt, loc_list );
        for( j=0; j<loc_cnt; j++ )
        {
           obj_chk.objid = loc_list[j];
           obj_chk.osnum = RefOsList[i];

           world = TRUE ;

           sts = om$send( msg  = message GRgraphics.GRgetrang(
                               &msg,
                               &cur_env.md_env.matrix_type,
                               cur_env.md_env.matrix,
                               &world,
                               elmRng ),
			senderid = NULL_OBJID,
                        targetid = loc_list[j],
                        targetos = RefOsList[i] ) ;
           if( !(sts&msg&1) ) continue;

	   if( BSbxint( &rc, &range[0], &range[3], &elmRng[0], &elmRng[3] ) ) cnt_range++;
        }

	#if DEBUG
           printf("Actual number of Object we needed = %d\n", cnt_range );
	#endif

        if( !cnt_range ) {  _FREE( loc_list );  continue; }

        if( *cnt )
        {
            if( !( (*list) = _REALLOC( (*list), (*cnt)+cnt_range, struct GRobj_env ) ) ) vd_$mem_fail(msg=&msg);
        }
        else
        {
            if( !( (*list) = _MALLOC( cnt_range, struct GRobj_env ) ) )  vd_$mem_fail(msg=&msg);
        }
        for( j=0; j<loc_cnt; j++ )
        {
           obj_chk.objid = loc_list[j];
           obj_chk.osnum = RefOsList[i];

           world = TRUE ;

           sts = om$send( msg  = message GRgraphics.GRgetrang(
                               &msg,
                               &cur_env.md_env.matrix_type,
                               cur_env.md_env.matrix,
                               &world,
                               elmRng ),
			senderid = NULL_OBJID,
                        targetid = loc_list[j],
                        targetos = RefOsList[i] ) ;
           if( !(sts&msg&1) ) continue;

	   if( BSbxint( &rc, &range[0], &range[3], &elmRng[0], &elmRng[3] ) )
           {
                (*list)[*cnt].obj_id  = obj_chk;
                (*list)[*cnt].mod_env = RefEnvList[i];
		#if DEBUG
                    printf("list[%d] = %d, %d", *cnt, (*list)[*cnt].obj_id.objid, (*list)[*cnt].obj_id.osnum );
		    printf(" Range = %g, %g, %g, %g, %g, %g\n", elmRng[0], elmRng[1], elmRng[2], elmRng[3], elmRng[4], elmRng[5] );
		#endif
                (*cnt)++;
           }
        }
        _FREE( loc_list );
   }

wrapup:
   _FREE( RefOsList );
   _FREE( RefEnvList );
   return MSSUCC;
}
end implementation Root;
