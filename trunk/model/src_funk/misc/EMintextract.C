/* ###################   APOGEE COMPILED   ################## */
/* ###################   ANSI COMPILED     ################## */
#include "EMS.h"
/*
        void EMintextract(msg, inters, get_xyz,
                          num_pnts, pnt_ids, num_crvs, crv_ids)
Abstract
        This function extracts appropriate object ids (GRids) from
        EMSinters structure list.

Arguments
        Input:  inters          pointer to EMSinters
                get_xyz         if true retrieves displayable xyz objects
                                else retrieves non displayable uv objects

				* currently only xyz objects are being
				  retrieved
				*

        Output: msg             pointer to message
                num_pnts        pointer to number of point objects
                pnt_ids         pointer to array of GRids of point objects
                                 if NULL on entry, memory is allocated by
                                 the function.
                num_crvs        pointer to number of curve objects
                crv_ids         pointer to array of GRids of curve objects
                                 if NULL on entry, memory is allocated by
                                 the function.
                                
History
        gk      12/24/86:       creation date
	gk	5/25/87		modified to recognize EMSinters
				get_xyz is dummy variable now
*/
  
# ifndef OMminimum_include
# include "OMminimum.h"
# endif

# ifndef igrtypedef_include
# include "igrtypedef.h"
# endif

# ifndef igetypedef_include
# include "igetypedef.h"
# endif

# ifndef gr_include
# include "gr.h"
# endif

# ifndef igr_include
# include "igr.h"
# endif

#include "emsdattyp.h"
#include "emsinter.h"
#include "EMSerrordef.h"


void EMintextract(msg, inters, get_xyz, num_pnts, pnt_ids, num_crvs, crv_ids)

IGRlong                 *msg;
struct EMSinters        *inters;
IGRboolean               get_xyz;
IGRlong                 *num_pnts;
struct GRid             **pnt_ids;
IGRlong                 *num_crvs;
struct GRid             **crv_ids;

{
  struct EMSinters       *local_inters;
  struct EMSintobj       *local_intobj;
  IGRlong                 pnt_cnt, crv_cnt;

  if( ! get_xyz)
   {
	*msg = EMS_F_InvalidArg;
	return;
   }

  *msg = EMS_S_Success;

/* Count the number of points, curves */

  local_inters = inters;
  *num_pnts = 0;
  *num_crvs = 0;
  do
   {
     *num_pnts += local_inters->num_pts;
     *num_crvs += local_inters->num_cvs;

     local_inters = local_inters->next;

   }while(local_inters);        /* non NULL local_inters */


/* Do I need to allocate memory to output ids? */

  if( NOT *pnt_ids AND *num_pnts )
   {
     *pnt_ids = (struct GRid *)malloc(sizeof(struct GRid)*(*num_pnts) );
     if( NOT pnt_ids )
      {
        *msg = EMS_E_NoDynamicMemory;
        goto wrapup;
      }
   }

  if( NOT *crv_ids AND *num_crvs)
   {
     *crv_ids = (struct GRid *)malloc(sizeof(struct GRid)*(*num_crvs) );
     if( NOT crv_ids )
      {
        *msg = EMS_E_NoDynamicMemory;
        goto wrapup;
      }
   }


/* Adequate memory has been allocated */
/* Now start traversing the generalizedlist */

  pnt_cnt = 0;
  crv_cnt = 0;
  local_inters = inters;
  do
   {
     struct GRid	*object_info;

/*   Choose the appropriate EMSintobj string */
        
     local_intobj = (struct EMSintobj *)local_inters->pts;
     
     while( local_intobj )
      {
	object_info = (struct GRid *)local_intobj->this_xyzintobj.data.object;

        (*pnt_ids)[pnt_cnt].osnum = object_info->osnum;
        (*pnt_ids)[pnt_cnt].objid = object_info->objid;

        local_intobj = local_intobj->next;
        pnt_cnt++;
      }

     local_intobj = (struct EMSintobj *)local_inters->cvs;

     while( local_intobj )
      {
	object_info = (struct GRid *)local_intobj->this_xyzintobj.data.object;

        (*crv_ids)[crv_cnt].osnum = object_info->osnum;
        (*crv_ids)[crv_cnt].objid = object_info->objid;

        local_intobj = local_intobj->next;
        crv_cnt++;
      }

     local_inters = local_inters->next;

   }while(local_inters);

wrapup:
  return;
}


