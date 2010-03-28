/*
Name
        GRgencsi.I

Description
        This file contains methods on the GRgencs class.
*/

class implementation GRgencs;

#include "grimport.h"
#include "msdef.h"
#include "godef.h"
#include "gocmacros.h"
#include "DIdef.h"
#include "DItypedef.h"
#include "DIprims.h"
#include "csdef.h"



/*
Name
        GRgencs.GRinitialize

Description
        This method sends the GRconstruct message to self to initialize
        the newly constructed coordinate system object and add it to
        the rtree.  New code should send the GRconstruct message rather
        than the GRinitialize message.  This method is retained only
        to support existing code, and may be removed eventually.

Notes
        Because of changes in the system, there are two places where
        both the coordinate system's name and the description may be
        specified, namely in the method arguments and in the construction
        argument list (the description is specified in the class_attr
        field of the construction args).  If both fields are specified
        for a single parameter, this method gives priority to the fields
        in the method argument list.

History
        Kumar Talluri   10/15/86    design and implementation.
        mrm             03/03/88    moved most of the functionality
                                    to GRgencs.GRconstruct
*/

#ifndef IDRAW
method GRinitialize (IGRlong *msg;
                     IGRchar *csname;
                     IGRchar *csdesc;
                     struct GRvg_construct *p_arglist)
{
    IGRlong                 sts;            /* return code */
    struct GRvg_construct   local_args;     /* to construct method */

    sts = OM_S_SUCCESS;
    *p_arglist->msg = MSSUCC;

    /*
     *  set up construct args
     */

    local_args = *p_arglist;

    if (csname) local_args.name = csname;
    if (csdesc) local_args.class_attr = csdesc;

    /*
     *  send the GRconstruct message to self accomplish initialization
     */

    sts = om$send (msg = message GRgraphics.GRconstruct (&local_args),
                   targetid = my_id);


#ifdef DEBUG
    if (!(sts & *msg & 1)) printf ("GRgencs.GRinitialize failed\n");
    if (!(*msg & 1)) printf ("p_arglist->msg = 0x%x\n", *p_arglist->msg);
    if (!(sts & 1)) om$report_error (sts = sts);
#endif

    GR_NOTIFY_LISTENERS (msg, &sts, GR_GEOM_POSTED);

    return (sts);
}
#endif IDRAW



/*
Name
        GRgencs.GRget_matrix

Description
        This method returns the coordinate system's local-to-world
        transformation matrix.

History
        Kumar Talluri   10/15/86    design and implementation.
        mrm             08/02/88    copy matrix to buffer rather than
                                    returning pointer to instance data
*/

method GRgetmatrix (IGRlong *msg; IGRdouble *matrixptr)
{
    IGRint      i;          /* index */
    IGRlong     sts;        /* return code */

    sts = OM_S_SUCCESS;
    *msg = MSSUCC;

    for (i = 0; i < 16; i++)
    {
        matrixptr[i] = me->matrix[i];
    }

    return (sts); 
}



/*
Name
        GRget_oid_from_name

Description
        This method returns its objid if the specified name matches its
        own.  Since all cs objects are on one channel, once one cs is found,
        there is no need to send this msg to other objects on the channel, so
        OM_I_STOP_SENDING is returned.

History
        Kumar Talluri   10/15/86    design and implementation.
        mrm             03/10/88    use directory subsystem to retrieve name
        dhm             07/15/92    ansi conversion.
*/

#ifndef IDRAW

method GRget_oid_from_name (IGRlong *msg;
                            IGRchar *csname; 
                            GRobjid *csobjid)
{
    IGRchar     pathname[DI_PATH_MAX];     /* cs directory & name */
    IGRchar     objname[DI_PATH_MAX];      /* cs name */
    IGRchar    *name;                   /* name to compare with input */
    IGRlong     sts;                    /* return code */

    sts = OM_S_SUCCESS;
    *msg = MSFAIL;

    sts = di$untranslate (objid = my_id,
                          osnum = OM_Gw_current_OS,
                          objname = pathname);
    if (sts & 1)
    {
        if (strchr (csname, ':'))
        {
            name = pathname;
        }
        else
        {
            di$split (pathname = pathname, name = objname);
            name = objname;
        }
 
        if (!strncmp (csname, name, strlen(csname)))
        {
            *csobjid = my_id;
            *msg = MSSUCC;
            sts = OM_I_STOP_SENDING;
        }
    }
    else
    {
        sts = OM_S_SUCCESS;     /* cs has no name */
    }

    return (sts);
}

#endif IDRAW



/*
Name
        GRgencs.GRcsgetscale

Description
        This method returns the scale vector of the coordinate system.

Return Codes
        IGRlong ()      OM_S_SUCCESS - always succeeds
        IGRlong *msg    MSSUCC - always succeeds

History
        mrm     08/01/88    creation
*/

method GRcsgetscale (IGRlong *msg; IGRdouble *scale)
{
    IGRlong sts;

    *msg = MSSUCC;
    sts = OM_S_SUCCESS;

    scale[0] = me->scale[0];
    scale[1] = me->scale[1];
    scale[2] = me->scale[2];

    return (sts); 
}



/*
Name
        GRgencs.GRcssetscale

Description
        This method sets the scale of the coordinate system.  According to
        the abs_rel flag, the me->scale vector is either replaced with the
        input scale vector (absolute scale setting) or combined with the
        input scale vector (relative scale setting).  The file csdef.h
        contains #defines for the proper flag settings.

Return Codes
        IGRlong ()      OM_S_SUCCESS
        IGRlong *msg    MSSUCC on successful completion
                        MSFAIL on error
                        MSINARG if abs_rel not set properly

History
        mrm     08/01/88    creation
*/

method GRcssetscale (IGRlong *msg; IGRint abs_rel; IGRdouble *scale)
{
/*    IGRshort    i; */
    IGRlong     sts;
    IGRdouble   sc[3];

    sts = OM_S_SUCCESS;

    sc[0] = (scale[0]) ? scale[0] : 1.0;
    sc[1] = (scale[1]) ? scale[1] : 1.0;
    sc[2] = (scale[2]) ? scale[2] : 1.0;

    if (abs_rel == CS_ABSOLUTE)
    {
        me->scale[0] = sc[0];
        me->scale[1] = sc[1];
        me->scale[2] = sc[2];
        *msg = MSSUCC;
    }
    else if (abs_rel == CS_RELATIVE)
    {
        me->scale[0] *= sc[0];
        me->scale[1] *= sc[1];
        me->scale[2] *= sc[2];
        *msg = MSSUCC;
    }
    else
    {
        *msg = MSINARG;
    }

    GR_NOTIFY_LISTENERS (msg, &sts, GR_ATTR_MODIFIED);

    return (sts);
}

/*
 Name
	GRgencs.GRchange_type

 Description
	This method changes the type of the coordinate system.  The type can
	be specified by a short or a character string.  The defines for the
	coordinate system types are in csdef.h.  A NULL should be passed in 
	for type if not specified and the same goes for type_string.

 Return Codes
	*msg	MSSUCC		okay
	*msg	MSINARG		invalid type or type_string specified

 History
	dhm	08/12/91	creation date 
*/
 
method GRchange_type(IGRlong *msg; IGRshort *type; IGRchar *type_string)
{
  IGRlong  status;

  status = OM_S_SUCCESS;
  *msg = MSSUCC;

  if (type)
  {
    if ( ((*type) >= 0) && ((*type) < 3) )
      me->type = *type;
    else
      *msg = MSINARG;
  }
  else if (type_string)
  {
    if (! strcmp(Rectangular, type_string) )
    {
      me->type = RECTANGULAR;
    }
    else if (! strcmp(Spherical, type_string) )
    {
      me->type = SPHERICAL;
    }
    else if (! strcmp(Cylindrical, type_string) )
    {
      me->type = CYLINDRICAL;
    }
    else
    {
      *msg = MSINARG;
    }

  }
  else
  {
    *msg = MSINARG;
  }

  GR_NOTIFY_LISTENERS (msg, &status, GR_ATTR_MODIFIED);

  return(status);

}

end implementation GRgencs;
