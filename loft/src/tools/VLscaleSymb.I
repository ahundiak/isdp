class implementation  VLabstract ;

#include <stdio.h>
#include "vlunfold.h"
#include "griomacros.h"


IGRint	VLscalSymb(
  IGRmatrix		cs_matrix,	/* Coordinate System Matrix 	*/
  struct GRid		*scalObj,	/* Object to be scaled		*/
  struct GRmd_env	*Env,		/* Env of obj to be scaled	*/
  IGRlong		*msg		/* Completion Code 		*/
)
{
 	IGRlong		sts = OM_S_SUCCESS, rc ;
	double		scale ;
	IGRint		db_type, i ;
	struct GRid	cop_obj ;
	IGRmatrix	scale_mat, transMat ;
	short		scale_mattype, matType ;
	
        /* the symbols we will scale in this function were made with a
        constant size in the metric file, now computed to fit well 
	in files using the imperial units */

        /* find which measure system do we use */
        scale = 1.;
        sts = co$unit_database_type( 	osnum   = scalObj->osnum ,
                                       	db_type = &db_type );

	if ( ! (sts & 1 ) ) scale = 1.0;
	else {
		if ( db_type == GRIO_UNITS_ARE_ENGLISH )
			scale = 25.4/(double)VL_ARROW_SIZE;
	}

	if ( scale != 1 ){

		for ( i = 1;i < 16;i = i+1 ) 	scale_mat[i] = 0;

                scale_mat[0] = scale;
		scale_mat[5] = scale;
                scale_mat[10] =scale; 
		scale_mat[15] = 1;
                
		MAtypemx( &sts, scale_mat, &scale_mattype);

	 	sts = om$send ( msg = message   GRgraphics.GRxform (
                	                                msg ,
                        	                        Env,
                                	                &scale_mattype ,
                                        	        scale_mat ,
                                                	&cop_obj.objid ),
	                                senderid = NULL_OBJID ,
        	                        targetid = scalObj->objid ,
                	                targetos = scalObj->osnum  );
                if ( !( sts & 1 ) ) {
                        *msg = MSSUCC ;
                        goto wrapup ;
                }

		MAidmx ( &rc, transMat );
	
		transMat[3]  = cs_matrix[3] * ( 1.0 - scale );
		transMat[7]  = cs_matrix[7] * ( 1.0 - scale );
		transMat[11] = cs_matrix[11]* ( 1.0 - scale );

		MAtypemx ( &rc, transMat, &matType ) ;
		
		sts = om$send ( msg = message   GRgraphics.GRxform (
                                                msg ,
                                                Env,
                                                &matType ,
                                                transMat ,
                                                &cop_obj.objid ),
                                senderid = NULL_OBJID ,
                                targetid = scalObj->objid ,
                                targetos = scalObj->osnum  );
                if ( !( sts & 1 ) ) {
                        *msg = MSSUCC ;
                        goto wrapup ;
                }
	} /*  if ( scale != 1 ) */

wrapup :
	return ( sts ) ;
}

end implementation VLabstract ;
