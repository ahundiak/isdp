/* $Id: VDatparmacros.h,v 1.1.1.1 2001/01/04 21:07:30 cvs Exp $  */

/* I/VDS
 *
 * File:        $VDS/include/VDatparmacros.h
 *
 * Description:
 *      This include file provides functionalities
 *      to review specific attributes of an object,
 *
 * Dependencies:
 *      vdparmacros.h
 * Revision History:
 * 	$Log: VDatparmacros.h,v $
 * 	Revision 1.1.1.1  2001/01/04 21:07:30  cvs
 * 	Initial import to CVS
 * 	
 * Revision 1.1  1999/01/25  21:01:54  pinnacle
 * initial revision
 *
 *
 * History:
 *	
 * Date 	Author			Description
 * 01/25/99 	vinit			Creation
 *********************************************************************/


#define VDAT_REVIEW_ATTRIBUTES 1
#define VDAT_EXTR_FOR_REVIEW 2
/*   	Functions defined in $VDS/vdat/set/VDatAttr.I
 */
extern IGRint VDatget_Params __((  IGRlong     		*sts,
                                  TGRid       		*object,
				  IGRint      		*count,
                                  struct ACrg_coll 	**plist, 
				  IGRint      		type      ));

extern IGRint VDatGetParameters __((  IGRlong     		*sts,
				      IGRint      		*count,
				      IGRchar     		*i_setType,
				      IGRint      		type      ));

/*+Me
  External Macro vdat$get_params

  Abstract

  Arguments
      IGRlong            *sts              (O)    return code
      struct TGRid        *object          (I)    id of the object
      IGRint              *count           (O)    number of parameters
      struct  ACrg_coll   **plist          (O)    pointer to the list array
      IGRint  		  type		   (I)    parameter type desired
      						  i.e., Staging Tree,
						  DENEB, Extract for Review.


  Status/Return Code
      OM_S_SUCCESS    : if success
      OM_W_ABORT      : some error

  Remarks

-Me*/

#omdef vdat$get_params(   sts,
                        object,
			count,
			plist,
			 type  )
     VDatget_Params( (sts), (object), (count), (plist), (type) );
#endomdef

/*+Me
  External Macro vdat$get_parameters

  Abstract

  Arguments
      IGRlong            *sts              (O)    return code
      IGRint              *count           (O)    number of attributes 
      IGRchar             *i_setType	   (I)    setType (also name of ppl)
      IGRint  		  type		   (I)    parameter type desired
      						  i.e., Staging Tree,
						  DENEB, Extract for Review.


  Status/Return Code
      OM_S_SUCCESS    : if success
      OM_W_ABORT      : some error

  Remarks

-Me*/
#omdef vdat$get_parameters(   sts,
			    count,
		        i_setType,
		  	      type  )
     VDatGetParameters( (sts), (count), (i_setType), (type) );
#endomdef



