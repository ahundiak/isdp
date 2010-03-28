/* #######################    APOGEE COMPILED   ######################## */
/*----
%GP% CODE CLASSIFICATION                           
----
%HD%

     CLASS  NAME:   GR3dellarc	
     METHOD NAME:   GRgetarc

     Abstract: 
		This method converts the object's instance
	       data into the equivalent IGRarc data
	       placing it into a provided data structure.

-----
%SC%    

     GRgetarc(msg,mat_type,matrix,arc)

-----
%EN%
     ON ENTRY:

        NAME       DATA TYPE  	            DESCRIPTION
     ----------   ------------   ------------------------------------
     *mat_type	  IGRshort	 environment matrix type
     matrix	  IGRmatrix	 environment transformation matrix

-----
%EX%
     ON EXIT:

        NAME       DATA TYPE  	            DESCRIPTION
     ----------   ------------   -----------------------------------
     *msg	  IGRlong	 completion code
                                     MSSUCC - successful
				     MSFAIL - sine and cosine of 
				 rotation angle could not be calculated
                                     MAIDGENRAT - one axis degenerated
                                     and rotation is aligned with the axis.
                                     MAINOTUNIQUE - both axes degenrated
                                     and unique rotation matrix could not be
                                     determined. Rotation matrix is same as 
 
     arc	  IGRarc	 pointer to storage for an IGRarc data
				 structure

-----
%MD%

     MODULES AND METHODS INVOKED:

     Modules:
		GRsetarc
		MAarxform
     Methods:

-----
%RL%

     RELATIONS REFERENCED:
-----
%NB%

     NOTES:
	   The data structure pointer must point to storage for
	   an IGRarc data structure.

-----
%CH%

     CHANGE HISTORY:
	
	RDH	06/19/86 : Creation date.
-----
%PD%
--------------------------------------------------------------------
                M E T H O D    D E S C R I P T I O N
--------------------------------------------------------------------

	This method converts the 3-D double precision elliptical arc
	into a 	standard IGRarc data structure.

----*/
/*EH*/

class implementation GR3dellarc;

#include "grimport.h"
#include "msdef.h"
#include "madef.h"
#include "godef.h"
#include "gocmacros.h"

extern    IGRboolean    GRsetarc();

method GRgetarc(IGRlong *msg; IGRshort *mat_type; IGRmatrix matrix;
		 struct IGRarc *arc)
{
  IGRshort	dim;
  struct IGRarc	temp_arc;
  IGRlong	OMmsg;

  OMmsg = OM_S_SUCCESS;		/* initialize to success	*/
  *msg = MSSUCC;

  dim = 3;

  if ( GRsetarc(msg,&dim,&me->prim_axis,&me->sec_axis,
	       &me->start_angle,&me->sweep_angle,
	       me->rot_matrix,me->origin,
	       &me->origin[2],&temp_arc) )
  {
      if ( *mat_type != MAIDMX )
      {
          MAarxform(msg,&temp_arc,matrix,arc);
      }
      else
      {
	  *arc = temp_arc;
      }
  }

  
  
  return( 1 & *msg );

}/* This has been an R.D.H. production!!! */

end implementation GR3dellarc;
