/* #######################    APOGEE COMPILED   ######################## */
/*----
%GP% CODE CLASSIFICATION                           
----
%HD%

     CLASS  NAME:	GRbspline
     METHOD NAME:	GRgetrang

     Abstract: This routine retrieves the range of the object.

-----
%SC%    
	GRgetrang(msg,matrix_type,matrix,world,range)

-----
%EN%
     ON ENTRY:

        NAME       DATA TYPE  	            DESCRIPTION
     ----------   ------------   ------------------------------------
     *matrix_type  IGRshort	 type of environment matrix
     matrix	   IGRmatrix	 environment matrix
     *world	   IGRboolean    indicator of whether the range should
			 	 be computed in world or local coordinates
				  1 : apply the environment matrix
				  0 : do not apply the environment matrix
-----
%EX%
     ON EXIT:

        NAME       DATA TYPE  	            DESCRIPTION
     ----------   ------------   -----------------------------------
      *msg	   IGRlong	 completion code
				    MSSUCC - successful completion
      range	   GRrange	 range of the object

-----
%MD%

     MODULES AND METHODS INVOKED:
     Modules:
	none.

     Methods:
	none.
-----
%RL%

     RELATIONS REFERENCED:
	none.
-----
%NB%

     NOTES:
	none.
-----
%CH%

     CHANGE HISTORY:
         dhm     12/02/91    Fixed a null pointer reference problem with the
                             matrix and matrix_type.
-----
%PD%
--------------------------------------------------------------------
                M E T H O D    D E S C R I P T I O N
--------------------------------------------------------------------
----*/
/*EH*/

class implementation GRbspline;

#include "grimport.h"
#include "msdef.h"
#include "madef.h"
#include "godef.h"
#include "gocmacros.h"

method GRgetrang(IGRlong *msg; IGRshort *matrix_type;
		 IGRmatrix matrix; IGRboolean *world;GRrange range)
{
	IGRlong i;
	char *ptr;
	struct IGRbsp_curve *curve;
	IGRlong OMreturn;
	IGRlong msg2;
	IGRshort mat_type;
	IGRshort *type;

	IGRdouble matrix2[16];
	IGRdouble *mx;
	IGRdouble buffer[1000];

	struct IGRbsp_curve *old_curve;
	IGRchar *old_ptr;
	IGRlong old_size;
	IGRchar *old_scratch;
	int  in_buffer;
	IGRlong msg1;

	GRspacenum osnum = OM_Gw_current_OS;

	*msg = MSSUCC;
	OMreturn = OM_S_SUCCESS;

	if (*world)
	{
	    mx = &matrix[0];
	    type = matrix_type;
	}
	else
	{
	    MAidmx(&msg2,matrix2);
	    mat_type = MAIDMX;
	    mx = &matrix2[0];
	    type = &mat_type;
	}

    /*
     * Changed from matrix_type and matrix to type and mx.
     *  dhm  12/2/91.
     */
	    
	in_buffer = GRabsg_test(&msg1,type,mx,&osnum,&my_id,&old_ptr);

	if (in_buffer)
	{
	  old_curve = (struct IGRbsp_curve *) old_ptr;
	  GRbc_size(old_curve->order,old_curve->num_poles,old_curve->rational,
		    old_curve->num_boundaries,old_size);
	  if (old_size > sizeof(buffer))
	  {
	      old_scratch = om$malloc(size = old_size);
	  }
	  else
	  {
	      old_scratch = (char *)buffer;
          }
	  if (old_scratch == 0)
	  {
	    *msg = MSFAIL;
	    OMreturn = OM_E_ABORT;
	    goto wrapup;
	  }

	  for (i = 0; i < old_size; i++)
	  {
	    old_scratch[i] = old_ptr[i];
	  }

	  GRabsg_del(old_ptr);
	}

	OMreturn = om$send(mode = OM_e_wrt_object,
                           msg = message GRvg.GRgenabsg(msg,type,mx,&ptr),
                           senderid = my_id,
                           targetid = my_id);

	if (! (1 & OMreturn))
	{
	  *msg = MSFAIL;
	  goto wrapup;
	}

	curve = (struct IGRbsp_curve *) ptr;

	MAcubepy(&msg2,curve,&range[0],&range[3]);

	if (! (1 & msg2))
	{
	  *msg = MSFAIL;
	  OMreturn = OM_E_ABORT;
	}

	if (in_buffer)
	{
	  for (i = 0; i < old_size; i++)
	  {
	    old_ptr[i] = old_scratch[i];
	  }
	  if (old_size > sizeof(buffer))
	  {
	      om$dealloc(ptr = old_scratch);
	  }
	}

wrapup:
	return(OMreturn);
}

end implementation GRbspline;

