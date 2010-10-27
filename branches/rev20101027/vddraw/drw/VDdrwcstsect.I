/* $Id: VDdrwcstsect.I,v 1.1.1.1 2001/01/04 21:08:37 cvs Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        vddraw/drw/VDdrwcstsect.I
 *
 * Description:
 *              Support functions for volume-cut process.
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDdrwcstsect.I,v $
 *      Revision 1.1.1.1  2001/01/04 21:08:37  cvs
 *      Initial import to CVS
 *
# Revision 1.2  1998/06/03  17:57:40  pinnacle
# Replaced: vddraw/drw/VDdrwcstsect.I for:  by mdong for vds
#
 *
 * History:
 *      MM/DD/YY        AUTHOR          DESCRIPTION
 *      ??/??/??        ??              Creation.
 *      06/03/98        Ming            TR179800595. Add new functions for
 *					extracting members of a macro:
 *                                      VD_drwCstConstVolMems().
 ***************************************************************************/
class implementation VDSroot ;

#include <stdlib.h>
#include "OMmacros.h"
#include "asbox.h"
#include "EMSmsgdef.h"
#include "v_drw.h"
#include "v_vedef.h"
#include "v_datamacros.h"
#include "v_geommacros.h"
#include "v_miscmacros.h"
#include "v_dbgmacros.h"
/*
 * Includes of function prototypes.
 */
#include "v_drwproto.h"
#include "v_fndslsinmc.h"
#include "v_vecmxproto.h"
#include "v_virtualinf.h"
#include "v_visedproto.h"

extern void	VD_setGRids() ;

extern  IGRboolean      ASbroadcast_in_progress ;

#define FOOT_UNKNOWN	0
#define FOOT_CURVE	1
#define FOOT_SURFACE	2
#define FOOT_SOLID	3

extern long VD_findMatchFtNameSlSfInMacro();

/*----------------------------------------------------------------------------*/
long VD_drwCstConstVolCuts( msg, inp, xData, outp )

long			*msg ;
VD_drwInputData		*inp ;
VD_drwExecData		*xData ;
VD_drwGraphicGroup	*outp ; {

	long			sts ;	    /* OM completion code.	      */
	int			rsCount;    /* Count of members of object     */
	struct GRid		*rsList;    /* List of object members         */
	struct GRobj_env	volObj,     /* Volume object to intersect with*/
				elmObj ;    /* Input element.                 */
	struct GRvg_construct	cst ;	    /* Construction list for	      */
					    /* projected wireframes.	      */

	SetProc( VD_drwCstConstVolCuts ); Begin

	sts  = OM_S_SUCCESS ;
	*msg = MSSUCC ;

	rsCount  = 0 ;
	rsList   = NULL ;

	__DBGpr_obj( "Construction to draw", *(inp->elmId) ) ;

	/*
	 * Fill construction list for projected wireframes.
	 */
	vd_$fill_cnst_list(
			   Msg		= msg,
			   Env_info	= inp->drwInfo.drwEnv,
			   Level	= xData->overrides.elmLevel,
			   Display	= &xData->overrides.elmDisplay,
			   Cnst_list	= cst ) ;

	/* 
	 * toBeDrawn.elmCount is not equal to 1 the reference list is wrong.
	 * we leave the function.
	 */
	if( inp->toBeDrawn.elmCount != 1 ){
		*msg = MSFAIL ;
		goto wrapup ;
	}

	/*
	 * The list of reference objects is used to give the solid volume
	 * object to intersect with. This object is get from the parent
	 * object (VDdrwModel).
	 */
	volObj.obj_id	= inp->toBeDrawn.elmList[0] ;
	volObj.mod_env	= *inp->drwInfo.drwEnv ;

	elmObj.obj_id	= *inp->elmId ;
	elmObj.mod_env	= *inp->elmEnv ;

	sts = 
	vd_$get_volume_intersect(	msg		= msg,
					optrCount	= 1,
					optrList	= &elmObj,
					operand		= &volObj,
					resCst		= &cst,
					resCount	= &rsCount,
					result		= &rsList );
	__CheckRC( sts, *msg, "vd_$get_volume_intersect", wrapup );

	/*
	 * give the resulting object back to the parser.
	 */
	outp->count	= rsCount ;
	outp->list	= rsList  ;

        __DBGpr_objlist( "Drawing of part", outp->count, outp->list ) ;

	sts  = OM_S_SUCCESS ;
	*msg = MSSUCC ;

	wrapup :
		if( ! ( sts & 1 & *msg ) ) {
			_FREE( rsList );
			outp->list  = NULL ;
			outp->count = 0 ;
		}

		End
		return sts ;

} /* VD_drwCstConstVolCuts */

/*----------------------------------------------------------------------------*/

long VD_drwCstConstVolMems( msg, inp, xData, member, outp )

long                    *msg;
VD_drwInputData         *inp;
VD_drwExecData          *xData;
VD_tktxt                member;
VD_drwGraphicGroup      *outp;
{
        long                    sts ;       /* OM completion code.            */
        int                     rsCount;    /* Count of solids / surfaces     */
        struct GRid             footId;     /* Foot identifier                */
        struct GRmd_env         footEnv;    /* Foot environment               */
        struct GRvg_construct   cst;        /* Construction list for          */
                                            /* projected wireframes.          */
	struct GRid             *rsList;    /* List of object members         */
        struct GRobj_env        volObj,     /* Volume object to intersect with*/
                                elmObj;     /* Input element.                 */
        double                  *sts_dbl = NULL;
	char			*chpos;
	struct GRobj_env        *ssList;
        int                     ssCount, doFreeList;
        int			i;
        struct GRid		*TotList;
        int                     TotCount, OldCount;


        SetProc( VD_drwCstConstVolMems ); Begin

        sts        = OM_S_SUCCESS;
        *msg       = MSSUCC;
	ssList     = NULL;
        ssCount    = 0;
        doFreeList = FALSE;

        __DBGpr_obj( "Construction to draw", *(inp->elmId) ) ;

        rsCount  = 0;
        rsList   = NULL;
        TotList  = NULL;
        TotCount = 0;

        if( !*member ) 
	{
          if( xData->verbose )
            VD_drwPrintf( "!!! Member not specified for const '%s'\n",
                          inp->constDefName ) ;
            *msg = MSFAIL ;
            goto wrapup ;

        }
        __DBGpr_str( "member", (char *)member );

        /*
        ** If nesting, find the nested collection footId.
        */
        if( chpos = strrchr((char *)member, ':') )
        {
          *chpos = '\0';
          sts = 
	  om$send( msg      = message NDmacro.ACreturn_foot(
                                                   msg,
                                                   (char *) member,
                                                   &footId,
                                                   &footEnv._MATRIX_TYPE,
                                                   footEnv._MATRIX),
                   senderid = inp->elmId->objid,
                   targetid = inp->elmId->objid,
                   targetos = inp->elmId->osnum ) ;
          if( !( sts & 1 & *msg ) ) 
	  {
            if( xData->verbose )
              VD_drwPrintf( "!!! Cannot find '%s' in const '%s'\n",
                            member, inp->constDefName ) ;
            goto wrapup ;
          }
          __DBGpr_obj( "footId", footId ) ;

          sts_dbl = 
	  VD_mulmx( inp->elmEnv->_MATRIX, 
		    footEnv._MATRIX,
		    footEnv._MATRIX,
                    &footEnv._MATRIX_TYPE ) ;

          footEnv.md_id = inp->elmEnv->md_id ;

        }

        /*
        ** Retrieve the matching foot list.
        */
        doFreeList = TRUE;
        sts =
        VD_findMatchFtNameSlSfInMacro( msg,
				       &footId,
				       &footEnv,
				       chpos+1,
				       TRUE,
				       &ssList,
				       &ssCount );
	if( !(sts&*msg&1) )
        {
          __DBGpr_com( "Invalid Process VD_findMatchFtNameSlSfInMacro" );

          goto wrapup ;
        }
        __DBGpr_int( "ssCount", ssCount );
	#ifdef vdsDEBUG
        for( i = 0 ; i < ssCount ; i++ )
        {
          __DBGpr_obj( "ssList", ssList[i].obj_id );
        }
	#endif

	/*
        ** Fill construction list for projected wireframes.
        */
        vd_$fill_cnst_list( Msg          = msg,
                            Env_info     = inp->drwInfo.drwEnv,
                            Level        = xData->overrides.elmLevel,
                            Display      = &xData->overrides.elmDisplay,
                            Cnst_list    = cst ) ;

        /*
        ** toBeDrawn.elmCount is not equal to 1 the reference list is wrong.
        ** we leave the function.
        */
        if( inp->toBeDrawn.elmCount != 1 )
        {
          *msg = MSFAIL;
          goto wrapup;
        }

        /*
        ** The list of reference objects is used to give the solid volume
        ** object to intersect with. This object is get from the parent
        ** object (VDdrwModel).
        */
        volObj.obj_id  = inp->toBeDrawn.elmList[0];
        volObj.mod_env = *inp->drwInfo.drwEnv;

        for( i = 0 ; i < ssCount ; i++ )
        {
          elmObj = ssList[i];

          sts =
          vd_$get_volume_intersect( msg             = msg,
                                    optrCount       = 1,
                                    optrList        = &elmObj,
                                    operand         = &volObj,
                                    resCst          = &cst,
                                    resCount        = &rsCount,
                                    result          = &rsList );
          __CheckRC( sts, *msg, "vd_$get_volume_intersect", wrapup );
 
          __DBGpr_int( "rsCount", rsCount );
          if( !rsCount ) continue;

          OldCount = TotCount;
          TotCount += rsCount;
          __DBGpr_int( "TotCount", TotCount );
          if( i == 0 )
          {
            TotList  = _MALLOC( TotCount, struct GRid );
            if( !TotList )
            {
              printf( "Memory allocation error!\n" );
              *msg = MSFAIL;
              goto wrapup;
            }

            memcpy( &TotList[0], rsList, sizeof(struct GRid)*rsCount );
            rsList   = NULL;
            rsCount  = 0;
          }
          else
          {
            TotList = _REALLOC( TotList, TotCount, struct GRid );
            if( !TotList ) 
            {
              printf( "Memory re-allocation error!\n" );
              *msg = MSFAIL;
              goto wrapup;
            }

            memcpy( &TotList[OldCount], rsList, sizeof(struct GRid)*rsCount );
            rsList   = NULL;
            rsCount  = 0;
          }
        }
        __DBGpr_int( "TotCount", TotCount );

        /*
        ** give the resulting object back to the parser.
        */
        outp->count     = TotCount ;
        outp->list      = TotList  ;

        __DBGpr_objlist( "Drawing of part", outp->count, outp->list ) ;

        sts  = OM_S_SUCCESS;
        *msg = MSSUCC;


        wrapup:
                if( !(sts&1&*msg) )
                {
                  _FREE( rsList );
                  outp->list  = NULL;
                  outp->count = 0;
                }

                if( doFreeList ) _FREE( ssList );
		_FREE( TotList );
        End
        return sts;

} /* VD_drwCstConstVolMems */

/*----------------------------------------------------------------------------*/

end implementation VDSroot ;
