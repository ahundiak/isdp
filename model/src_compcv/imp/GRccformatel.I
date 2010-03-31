/* ###################   APOGEE COMPILED   ################## */
/*----
%GP% CODE CLASSIFICATION                           
----
%HD%

     CLASS  NAME: GRcompcurve
     METHOD NAME: GRformatele

     Abstract:
		This method gets the geometry, properties, symbologies,
		etc. of the object, creates an IGDS formatted element
		and writes it to the specified file.

-----
%SC%    

    GRformatele ( msg, md_env, dgn_buf, bs_buf, ele_buf, ele_size,
		  file_des, max_overflow, scale_factor )

-----
%EN%
     ON ENTRY:

        NAME       DATA TYPE  	            DESCRIPTION
     ----------   ------------   ------------------------------------
     *md_env      GRmd_env       structure containing context info
     *dgn_buf     IGRchar        buffer for output to IGDS design file
     *bs_buf      IGRchar        buffer to contain abstract geometry
     *ele_buf     IGRchar        buffer to contain IGDS formatted element
     *ele_size    IGRint	 # bytes in IGDS element
     *file_des    IGRint         pointer to IGDS design file created
     *max_overflow IGRdouble     max. abs. value of an overflow
     *scale_factor IGRdouble	 scale factor extracted from the type 9

-----
%EX%

     ON EXIT:

        NAME       DATA TYPE  	            DESCRIPTION
     ----------   ------------   -----------------------------------
     msg	  IGRlong	 completion code
				    - OM_S_SUCCESS

-----
%MD%

     MODULES AND METHODS INVOKED:
     Modules:
     Methods:
-----
%RL%

     RELATIONS REFERENCED:
-----
%NB%

     NOTES:
		This is not a stand alone routine. It should be executed
		only from the COtransigds command object.
-----
%CH%

     CHANGE HISTORY:
	
	sb/gfs     10/20/86 : Design date.
        Sudha   06/21/93        modified for BSprototype ansification
-----
%PD%
--------------------------------------------------------------------
                M E T H O D    D E S C R I P T I O N
--------------------------------------------------------------------

----*/
/*EH*/

class implementation GRcompcurve;

/* #include "grimport.h" */
#include "OMmacros.h"
#include "transdef.h"
#include "translate.h"
#include "transerr.h"
#include "transmacros.h"
#include "madef.h"
#include "godef.h"
#include "gocmacros.h"
#include "msdef.h"
#include "grsymdef.h"
#include "vardef.h"
#include "var.h"
#include "mapriv.h"
#include "matypemx.h"
#include "mamulmx.h"

extern    IGRboolean    GUcpxhandler();
extern    IGRint	GUget_symb_level();

static struct GRmd_env new_env;
static IGRmatrix scale_matrix;

%safe
static int old_scale=0;
static IGRshort	old_type=-1;
%endsafe

method GRformatele ( IGRlong *msg; struct GRmd_env *md_env; 
		     IGRchar *dgn_buf; IGRchar *bs_buf;
		     IGRchar *ele_buf; IGRint *ele_size; IGRint *file_des;
		     IGRdouble *max_overflow; IGRdouble *scale_factor )
{
    IGRchar	class_name[OM_K_MAXCLASS_LEN];
    IGRboolean	world = TRUE;
    IGRboolean  has_name = FALSE;
    GRname	name;
    IGRboolean  fill_bit = FALSE;
    IGRlong	status;
    IGRlong	num_values = 6;
    GRrange	range;
    struct GRsymbology	symbology;
    struct GRprops	geo_props;
    IGRboolean	        overflow_stat;
    IGRshort		num_rc = 4;
    IGRlong		i;
    IGRlong		OMmsg;

    IGRchar		IGDSclass = 0;
    struct		GRid id;
    IGRboolean		format;
    IGRboolean		mark_as_cpx;
    IGRboolean		cpx_calling = FALSE;

     /*
     *  Initialization.
     */

    OMmsg = OM_S_SUCCESS; 
 
    if (*scale_factor ==  1)
    {
	new_env = *md_env;
	old_scale = *scale_factor;
	old_type = md_env->md_env.matrix_type;
    }
    else
    {
        new_env.md_id = md_env->md_id;

        if (! ((*scale_factor == old_scale) &&
           (old_type == MAIDMX)  && 
	   (new_env.md_env.matrix_type == MAIDMX)))
        {
            if (*scale_factor != old_scale)
            {
            	/*
             	 *  set-up scale matrix for IGE to IGDS working units
              	 */

	    	scale_matrix[0] = scale_matrix[5] = scale_matrix[10] = 
			*scale_factor;
	    	scale_matrix[1] = scale_matrix[2] = scale_matrix[3] = 0.0;
	    	scale_matrix[4] = scale_matrix[6] = scale_matrix[7] = 0.0;
	    	scale_matrix[8] = scale_matrix[9] = scale_matrix[11] = 0.0;
	    	scale_matrix[12]= scale_matrix[13] = scale_matrix[14] = 0.0;
	    	scale_matrix[15] = 1.0;

	    	old_scale = *scale_factor;
	    }
            if (new_env.md_env.matrix_type == MAIDMX)
	    {
	    	for (i=0; i<16; ++i)
	    	{
		    new_env.md_env.matrix[i] = scale_matrix[i];
	    	}
	    }
	    else
	    {
	        MAmulmx ( msg, &num_rc, &num_rc, &num_rc, scale_matrix,
		  md_env->md_env.matrix, new_env.md_env.matrix );
	    }

            MAtypemx(msg,new_env.md_env.matrix,
		    &new_env.md_env.matrix_type);

   	    old_type = md_env->md_env.matrix_type;/* use input value	*/
	}
    }

    /*
     *  Get the symbology, range, and geometric properties
     *	of the object.
     */

    status = om$send ( 	mode = OM_e_wrt_object, 
			msg = message GRvg.GRgetrang ( msg, 
				&new_env.md_env.matrix_type, 
				new_env.md_env.matrix, &world, range ), 
			senderid = my_id, 
			targetid = my_id );

    /*
     *  Check to see if this element will cause integer overflow.
     */

    overflow_stat = GUcheck_overflow ( msg, &num_values, range,
				       max_overflow );
    if ( !overflow_stat )
    {
	/*
  	 *  This object will cause integer overflow, skip it.
	 */

	goto wrap_up;
    }
 	
    status = om$send(mode = OM_e_wrt_object,
                     msg = message GRvg.GRgetsymb ( msg, &symbology ),
                     senderid = my_id,
                     targetid = my_id );

    GUget_symb_level ( msg, &symbology );

    /*
     *  Call the complex handler to determine whether or not to continue
     *  the formatting of this object.
     */

    id.osnum = OM_Gw_current_OS;
    id.objid = my_id;

    cpx_calling = TRUE;

    if (! GUcpxhandler( msg, &cpx_calling, md_env, dgn_buf, bs_buf, 
			ele_buf, ele_size, file_des, max_overflow, 
			scale_factor, &IGDSclass, &me->properties, 
			&symbology.level, &id, &format, &mark_as_cpx ) )
    {
	*msg = MSSUCC;
	goto wrap_up;
    }

    if (! format)
    {
	goto wrap_up;
    }

    status = om$get_classname(classname = class_name,
                              object = me );
    if ( !(1 & status) )
    {
	goto wrap_up;
    }

    status = om$send(mode = OM_e_wrt_object,
     	             msg = message GRvg.GRgeomprops (
			        msg, &new_env.md_env.matrix_type,
				new_env.md_env.matrix, &geo_props ),
  	             senderid = my_id,
    	             targetid = my_id );
    if ( !(1 & status) )
    {
	goto wrap_up;
    }

    om$send(mode = OM_e_wrt_object,
                             msg = message GRvg.GRgetname (
				msg, name ),
                             senderid = my_id,
                             targetid = my_id );

    has_name = 1 & *msg;	

    /*
     *  For each element type supported, get the object's
     *  geometry and format an element buffer.
     */

    GUotype1214(msg, file_des, dgn_buf, ele_buf, ele_size,
		   class_name, range, &symbology, &geo_props,
		   &me->properties, &id, &new_env, bs_buf,
		   &has_name, name);

    wrap_up:


    return ( OM_S_SUCCESS );

}

end implementation GRcompcurve;
