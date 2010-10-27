/* $Id: GRctxregener.I,v 1.2 2002/06/07 18:35:40 hans Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/emsfixes/grnuc/GRctxregener.I
 *
 * Description:
 *		Change the check for identical matrix and verify if the
 *		GRcontext has a relation with the GRreffile object.
 *		When relation is not there, an invalid matrix is stored in
 *		the GRcontext "matrix" and "matrix_type" structure.
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: GRctxregener.I,v $
 *	Revision 1.2  2002/06/07 18:35:40  hans
 *	Fix for TR# MP6386
 *	
 *	Revision 1.1.1.1  2001/01/04 21:07:28  cvs
 *	Initial import to CVS
 *
# Revision 1.3  2000/03/03  21:03:20  pinnacle
# Replaced: emsfixes/grnuc/GRctxregener.I for:  by impd252 for vds
#
# Revision 1.2  2000/03/01  14:17:00  pinnacle
# Replaced: emsfixes/grnuc/GRctx*.I for:  by impd252 for vds
#
# Revision 1.1  2000/02/20  19:34:38  pinnacle
# Created: emsfixes/grnuc/GRctxregener.I by impd252 for vds
#
 *
 * History:
 *	MM/DD/YYYY	AUTHOR		DESCRIPTION
 *      02/20/2000	adz		First integration
 *	06/06/2002	HF		Fix for TR# MP6386
 * -------------------------------------------------------------------*/

/* #######################    APOGEE COMPILED   ######################## */


class implementation GRcontext;

#include "grimport.h"
#include "msdef.h"
#include "madef.h"
#include "ref.h"
#include "refdef.h"

extern IGRdouble BSdetmat();
extern unsigned int OM_Gf_verbose_warning;

from GRreffile import GRinquireref;
from GRgraphics import GRxform;


method GRregenerate(IGRlong *msg; struct GRmdenv_info *env_info;
		    IGRint *change_flag; struct GRid *context_id)
{
    IGRboolean 	pass_on;		/* pass to nested spaces flag	*/
    IGRint  i;				/* loop index			*/
    IGRlong OMmsg,			/* local return codes		*/
	    msg1;

    IGRdouble		myMtx[16];
    IGRint		myMtxType ;

    IGRint m,n, col = 4, rc;
    IGRdouble det = 0.0;

    struct GRmd_env env,
		    new_env;		/* reference file info		*/

    struct GRinquire_list inquire_requests[2];

    OM_S_CHANSELECT 	reffile_chan;

#ifdef	DEBUG
    printf(" GRregenerate : ENTER %d,%d \n", my_id, OM_Gw_current_OS );
#endif

    OMmsg = OM_S_SUCCESS;		/* initialize return values	*/
    *msg = MSSUCC;
    *change_flag = FALSE;
    context_id->objid = my_id;
    context_id->osnum = OM_Gw_current_OS;

    if ( me->flags & GRMASTER_CONTEXT)
    {
      goto wrapup;
    }

    OMmsg = om$make_chanselect(channame = "GRcontext.to_reffile",
                               p_chanselect = &reffile_chan);

    if ( 1 & OMmsg)		/* get matrix for transformation	*/
    {
      inquire_requests[0].var           = ENVIRONMENT_INFO;
      inquire_requests[0].var_ptr       = (IGRchar *) &new_env;
      inquire_requests[0].num_requested = sizeof(struct GRmd_env);
      inquire_requests[1].var           = END_REPORT_REQUEST;

      env.md_env                        = *env_info;
      env.md_id.objid                   = NULL_OBJID;
      pass_on                           = FALSE;

      /* NOTE: there is only one reference file attachment object
       * on the channel.
       */

      OMmsg = om$send( msg = message GRreffile.GRinquireref
                       (&msg1,&env,inquire_requests,&i,&pass_on,NULL),
                       p_chanselect = &reffile_chan);

#ifdef	DEBUG
      printf(" OMmsg: %d-%x \n", OMmsg, OMmsg );
      printf(" msg1 : %d-%x \n", msg1, msg1 );
      printf(" whichERROR : %d \n", i );
#endif
      for(i=0; i<16; i++ ) myMtx[i] = me->matrix [i];
      myMtxType = me->mx_type ;

      if ( 1 & OMmsg & msg1 )		/* Add checking for msg1 */
      {
        if (me->mx_type != new_env.md_env.matrix_type)
        {
          *change_flag = TRUE;
          me->mx_type = new_env.md_env.matrix_type;
        }

        if ( !(*change_flag))
        {
#ifdef	DEBUG
          printf(" -- (2) ----- INVALID CHECK ------\n");
#endif
          for (i=0; i<16; ++i)
          {
            if (me->matrix[i] != new_env.md_env.matrix[i])
            {
              *change_flag = TRUE;
              me->matrix[i] = new_env.md_env.matrix[i];
            }
          }
        }
        else
        {
          for (i=0; i<16; ++i)
          {
            me->matrix[i] = new_env.md_env.matrix[i];
          }
        }
        if( *change_flag )
        {
#ifdef	DEBUG
          pr_mat(" INSTMTX ", 4, 4, myMtx );
          printf(" INSTMTXTYPE : %d\n", myMtxType );
          pr_mat(" New MTX ", 4, 4, new_env.md_env.matrix );
          printf(" New MTXTYPE : %d\n", new_env.md_env.matrix_type );
#endif

//        if( new_env.md_env.matrix_type == 0 )	// THIS SHOULD NEVER HAPPEN !!!
          {
            if (OM_Gf_verbose_warning)
              printf(" RESET INFORMATION of GRcontext [%d,%d]  (change_flag = %d) !!! \n", OM_Gw_current_OS, my_id, *change_flag);

            if ( 1 )
            {
              det = BSdetmat( col, new_env.md_env.matrix, &rc );
              if ( rc )
              {
                if (OM_Gf_verbose_warning)
                  printf("new_env.md_env.matrix[] : BSdetmat error = %d\n", rc);
              }
              if (OM_Gf_verbose_warning)
                printf(" new_env.md_env.matrix : matrix_type %d, determinant = %lg\n", new_env.md_env.matrix_type, det);
              for(m = 0; m < 4; m++)
              {
                for(n = 0; n < 4; n++)
                {
                  if (OM_Gf_verbose_warning)
                    printf("%22.19f ",new_env.md_env.matrix[(m*4)+n]);
                }
                if (OM_Gf_verbose_warning)
                  printf("\n");
              }

              det = BSdetmat( col, myMtx, &rc );
              if ( rc )
              {
                if (OM_Gf_verbose_warning)
                  printf("me->matrix[] : BSdetmat error = %d\n", rc);
              }
              if (OM_Gf_verbose_warning)
                printf(" me->matrix : determinant = %lg\n", det);
              for(m = 0; m < 4; m++)
              {
                for(n = 0; n < 4; n++)
                {
                  if (OM_Gf_verbose_warning)
                    printf("%22.19f ",myMtx[(m*4)+n]);
                }
                if (OM_Gf_verbose_warning)
                  printf("\n");
              }
            }
            else
            {
              pr_mat(" New MTX ", 4, 4, new_env.md_env.matrix );
              pr_mat(" INSTMTX ", 4, 4, myMtx );
            }
            // Restore instance matrix[] from saved myMtx[]
            for (i=0; i<16; ++i) me->matrix[i] = myMtx[i];
            me->mx_type = myMtxType ;
          }
        }
      }
      else
      {
        *msg = MSFAIL;
      }
    }
    else
    {
      *msg = MSFAIL;
    }

wrapup:

#ifdef	DEBUG
    printf(" GRregenerate : EXIT %d,%d \n", my_id, OM_Gw_current_OS );
#endif

    return( OMmsg );
}

end implementation GRcontext;
