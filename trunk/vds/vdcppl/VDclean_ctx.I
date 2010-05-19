/* $Id: VDclean_ctx.I,v 1.1 2001/01/18 19:05:45 hans Exp $  */

/******************************************************************************
 * I/VDS
 *
 * File:        VDclean_ctx.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDclean_ctx.I,v $
 *      Revision 1.1  2001/01/18 19:05:45  hans
 *      Merged SP16 modifications
 *
# Revision 1.1  2000/05/04  19:47:56  pinnacle
# Created: vds/vdcppl/VDclean_ctx.I by jwfrosch for Service Pack
#
 *
 * History:
 *      MM/DD/YY      AUTHOR	DESCRIPTION
 *
 *	05/04/2000	HF	Creation date
 *				Fix for TR 179901364
 *
 ******************************************************************************/

class implementation Root;

#include <stdio.h>
#include <string.h>
#include <stdlib.h>

#include "OMmacros.h"
#include "OMindex.h"
#include "igrtypedef.h"
#include "igetypedef.h"
#include "godef.h"
#include "gr.h"
#include "igr.h"
#include "igrdp.h"
#include "go.h"
#include "grdpbdef.h"
#include "grdpbmacros.h"
#include "madef.h"
#include "growner.h"

#define	VD_DEBUG

#include "VDdebug.h"
#include "VDmem.h"

extern GRclassid        OPP_GRcontext_class_id;
extern IGRdouble        BSdetmat();
extern int              VDGetGridsFromChan_of_Class();

from   GRcontext  import  GRgetmodule_env,
                          GRgetinstance,
                          GRregenerate;

struct obj_dflg
{
  OM_S_OBJID  objid;
  int         index;
  int         dflag;
};

/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~	*/

static int compare_objids
(
  struct obj_dflg	*istr,
  struct obj_dflg	*ostr
)
{
  int sts = 0;

  if      ( istr->objid > ostr->objid )
  {
    sts = 1;
  }
  else if ( istr->objid < ostr->objid )
  {
    sts = -1;
  }

  return ( sts );
}

/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~	*/

static int compare_indice
(
  struct obj_dflg	*istr,
  struct obj_dflg	*ostr
)
{
  int sts = 0;

  if      ( istr->index > ostr->index )
  {
    sts = 1;
  }
  else if ( istr->index < ostr->index )
  {
    sts = -1;
  }

  return ( sts );
}

/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~	*/

int VDRegenerateContext(struct GRid *conID)
{
  IGRint    flag;
  IGRint    sts;
  IGRlong   msg;
  IGRint    i,j, col, rc;
  IGRdouble det;

  struct GRmd_env env;
  struct GRid     ctx;
  struct GRid     conxID;

  env.md_id.osnum = env.md_id.objid = env.md_env.matrix_type = 0;

  sts = om$send(msg = message GRcontext.GRgetmodule_env (&msg, &env),
                senderid = NULL_OBJID,
                targetid = conID->objid,
                targetos = conID->osnum);
  if (!(sts & msg & 1))
  {
    printf ("GRcontext.GRgetmodule_env  : sts = %#x, msg = %#x, conID = [%d,%d]\n", sts, msg, conID->osnum, conID->objid);
    sts = 0;
    goto wrapup;
  }

  sts = om$send(msg = message GRcontext.GRgetinstance ( &msg,
                                                        &env.md_env.matrix_type,
                                                         env.md_env.matrix,
                                                        &env.md_id.osnum,
                                                        (IGRshort *)&flag,
                                                        &conxID),
                senderid = NULL_OBJID,
                targetid = conID->objid,
                targetos = conID->osnum);

  if ( 1 && env.md_env.matrix_type == MAIDMX) goto wrapup;

  //  printf("------------------------------------\n");

  col = 4;
  det = 0.0;
  det = BSdetmat( col, env.md_env.matrix, &rc );
  if ( rc )
  {
    printf("BSdetmat error = %d\n", rc);
  }

  printf("GRcontext = [%d,%d], env.md_id = [%d,%d], matrix_type %d, determinant = %lg\n",
         conID->osnum, conID->objid, env.md_id.osnum, env.md_id.objid, env.md_env.matrix_type, det);
  for(i = 0; i < 4; i = i + 1)
  {
    for(j = 0; j < 4; j = j + 1)
    {
      printf("%22.19f ",env.md_env.matrix[(i*4)+j]);
    }
    printf("\n");
  }

  sts = om$send(msg = message GRcontext.GRregenerate ( &msg, &env.md_env, &flag, &ctx),
                senderid = NULL_OBJID,
                targetid = conID->objid,
                targetos = conID->osnum);
  if (!(sts & msg & 1))
  {
    printf("GRcontext.GRregenerate: sts = %#x, msg = %#x\n", sts, msg);
    sts = 0;
    goto wrapup;
  }
wrapup:
  return sts;
}

/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~	*/

int VDprocess_GRcontext_list ( int cnt, struct obj_dflg *obj_del )
{
  int                   sts, i0, j0, k0, m0, n0;
  long                  msg;
  unsigned int          ref_cnt = 0, chcnt[4];

  struct GRid           obj_id, conID;
  struct GRmd_env       ModuleInfo;

  GRclassid             class_id = OPP_GRcontext_class_id;
  OM_S_CHANSELECT       my_chansel[5];
  OM_S_OBJECT_LINKAGE   objet;

  if ( cnt == 0 || obj_del == NULL ) goto wrapup;

  my_chansel[0].type       = OM_e_name;
  my_chansel[1].type       = OM_e_name;
  my_chansel[2].type       = OM_e_name;
  my_chansel[3].type       = OM_e_name;

  my_chansel[0].u_sel.name = "to_super";
  my_chansel[1].u_sel.name = "to_reffile";
  my_chansel[2].u_sel.name = "to_misc";
  my_chansel[3].u_sel.name = "to_nested_files";

  // First, sort the list of objid's in ascending order...
  qsort ( (char *)obj_del, cnt, sizeof ( struct obj_dflg ), (int (*)(const void *, const void *)) compare_objids);

  sts          = 1;
  m0           = 0;
  obj_id.osnum = 2;
  objet.osnum  = 2;
  conID.osnum  = 2;

  for ( i0=0; i0 < cnt; i0++)
  {
    int              nr_ctx = 0;

    objet.S_objid = obj_del[i0].objid;
    conID.objid   = obj_del[i0].objid;

    for ( k0=0; k0 < 4; k0++)
    {
      sts = om$get_channel_count ( osnum        =  objet.osnum,
                                   objid        =  objet.S_objid,
                                   p_chanselect = &my_chansel[k0],
                                   count        = &chcnt[k0] );
    }

    if ( chcnt[1] == 0 && chcnt[2] == 0 )
    {
      if ( chcnt[3] > 0 )    // to_nested_files channel
      {
        struct GRid     *ctx_id = NULL;

        // Find all GRcontext objects, that are connected to the to_nested_files channel ...
        sts = VDGetGridsFromChan_of_Class ( &msg, conID, &my_chansel[3], class_id, &nr_ctx, &ctx_id );
        if ( (1 & sts & msg) && nr_ctx )
        {
          for ( j0=0; j0 < nr_ctx; j0++)
          {
            objet.S_objid = ctx_id[j0].objid;
            objet.osnum   = ctx_id[j0].osnum;
            ref_cnt       = 0;

            // Check the to_reffile channel of each GRcontext ...
            sts = om$get_channel_count ( osnum        =  objet.osnum,
                                         objid        =  objet.S_objid,
                                         p_chanselect = &my_chansel[1],    // to_reffile
                                         count        = &ref_cnt );
            if ( ! (1 & sts) || ref_cnt > 0 )
            {
              continue;
            }
            else
            {
              // There is no object on the to_reffile channel ...
              // Get the GRcontext objects on the to_nested_files channel,
              // and check if they appear in the list: obj_del[] ...

              int              nm_ctx  = 0;
              struct GRid     *cntx_id = NULL;

              obj_id.objid  = ctx_id[j0].objid;

              sts = VDGetGridsFromChan_of_Class ( &msg, obj_id, &my_chansel[3], class_id, &nm_ctx, &cntx_id );
              if ( (1 & sts & msg) && nm_ctx )
              {
                int del_flag = 1;

                for ( n0=0; n0 < nm_ctx; n0++)
                {
                  struct obj_dflg tmp_del;
                  struct obj_dflg *ptr = NULL;

                  tmp_del.objid = cntx_id[n0].objid;
                  tmp_del.dflag = 0;

                  ptr = (struct obj_dflg *) bsearch( &tmp_del, (char *)obj_del, cnt, sizeof ( struct obj_dflg ),
                                                     (int (*)(const void *, const void *)) compare_objids );
                  if ( ptr == NULL )
                  {
                    del_flag = 0;
                    break;
                  }
                }
                if ( del_flag )
                {
                  obj_del[i0].dflag = 1;
                }
                _FREE ( cntx_id );
              }
              else
              {
                continue;
              }
            }
          }
          if ( ! obj_del[i0].dflag ) printf ( "obj_del[%d].objid = %d, del_flag = %d\n", i0, obj_del[i0].objid, obj_del[i0].dflag );
          _FREE ( ctx_id );
        }
        else
        {
          continue;
        }
      }
      else
      {
        continue;
      }
    }
    else
    {
      continue;
    }
  }

wrapup:

  // Finally, sort the list of obj_del's back to the original order ...
  qsort ( (char *)obj_del, cnt, sizeof ( struct obj_dflg ), (int (*)(const void *, const void *)) compare_indice);

  return sts;
}

end implementation Root;
