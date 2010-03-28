/*
Name
	GRreffile.GRxform

Synopsis
        GRxform(msg,md_env,matrix_type,matrix,newobjid)

Description

        This method transforms the geometry of a graphics object by a matrix.

	After calling GRgetlbsys to get the local bounded system definition of
	the reference file attachment, transform the local bounded system.
	Then post the modified geometry back into the object.

	The clip polygon is also transformed if the message is not originating
	from the clipping polygon.

        The transformation matrix is incorporated into the instance data view
        rotation matrix.

	The possible return codes values in the msg field are:

	MSSUCC - successful completion
	MSFAIL - error
	GRSNOINVTRAN  -  in env_info is not invertible
	GRSDGNEXCEED design space limits are exceeded

History
	MAS 	04/05/87	Design date.
        dhm     07/07/92        ANSI conversion.
        mrm     08/03/93        Grind the rotation part of the transformation
                                matrix into the view rotation matrix stored in
                                instance data.  This is neccessary to get the
                                boreline into the correct orientation in
                                GRpassrange for point & boreline locate.
                                TR11924936.
*/

class implementation GRreffile;

#include "grimport.h"
#include "msdef.h"
#include "gocmacros.h"
#include "madef.h"
#include "OMmacros.h"
#include "godef.h"

extern    IGRboolean    MAlbxform();

method GRxform(IGRlong *msg; struct GRmd_env *md_env; 
	       IGRshort *matrix_type; IGRmatrix matrix; GRobjid *newobjid)
{
    IGRshort	xtype;
    IGRshort    mxsize = 4;
    IGRlong     OMmsg,			/* OM return status		*/
		msg1;
    IGRdouble   xmatrix_rot[16], tmx[16];
    IGRmatrix 	xmatrix;
    struct GRmd_env local_env;		/* environment for clip polygon	*/
    OM_S_CHANSELECT poly_chan;		/* channel to clip polygon	*/
    struct IGRlbsys lbsys,		/* local bounded system		*/
		new_lbsys;

    IGRshort  i, rank;
    IGRdouble vectors[9], o_vectors[9];
    IGRmatrix omx;

    

    *msg = MSSUCC;			/* initialize objects		*/
    OMmsg = OM_S_SUCCESS;
    *newobjid = my_id;

    local_env = *md_env;
    local_env.md_id.objid = NULL_OBJID;

    if (!IF_NULL_OBJID(md_env->md_id.objid))
    {					/* remove object from R-tree	*/
        OMmsg = om$send(
	    msg = message GRgraphics.GRremwrng
		(msg,md_env),
	    targetid = my_id);
    }

    if ( 1 & OMmsg & *msg)
    {	
					/* get channel to clip polygon	*/
	poly_chan.type = OM_e_addr;
	poly_chan.u_sel.addr = &me->to_clip;		    

	OMmsg = om$send(
		msg = message GRreffile.GRgetlbsys
		    (msg,&md_env->md_env.matrix_type,
		     md_env->md_env.matrix,&lbsys),
		targetid = my_id);

    if ( 1 & OMmsg & *msg)
    {
      GRfixmatrix(msg,matrix_type,matrix,xmatrix,&xtype);

      if ( 1 & *msg ) 
      {
        if (MAlbxform(msg,&lbsys,xmatrix,&new_lbsys))
        {
            struct GRpost_info	post_info;
            
            post_info.construct_flag = FALSE;
            
            OMmsg = om$send(msg = message GRreffile.GRpostlbsys
                            (msg,&local_env,&post_info,&new_lbsys),
                            targetid = my_id);
            
            /* Grind the rotation part of the transformation matrix into
               the view rotation matrix stored in instance data.  This is
               neccessary to get the boreline into the correct orientation
               in GRpassrange for point & boreline locate.  TR11924936 */
            memcpy((char *)xmatrix_rot, (char *)xmatrix,
                   sizeof(double) * 12);
            xmatrix_rot[3]  = xmatrix_rot[7]  = xmatrix_rot[11] = 0.0;
            xmatrix_rot[12] = xmatrix_rot[13] = xmatrix_rot[14] = 0.0;
            xmatrix_rot[15] = 1.0;
            MAmulmx(msg, &mxsize, &mxsize, &mxsize, 
                    me->vw_rotation, xmatrix_rot, tmx);
            memcpy((char *)me->vw_rotation, (char *)tmx,
                   sizeof(double) * 16);

            /* Remove the scale from the rotation matrix. */
            vectors[0] = me->vw_rotation[0]; 
            vectors[1] = me->vw_rotation[1]; 
            vectors[2] = me->vw_rotation[2];
            vectors[3] = me->vw_rotation[4]; 
            vectors[4] = me->vw_rotation[5]; 
            vectors[5] = me->vw_rotation[6];
            vectors[6] = me->vw_rotation[8]; 
            vectors[7] = me->vw_rotation[9]; 
            vectors[8] = me->vw_rotation[10];
            
            i = 3;
            
            if (!MAgrmscht (msg, &i, &i, vectors, o_vectors, &rank))
            {
#ifdef DEBUG
                printf ("GRgencs.GRxform: MAgrmscht failed\n");
#endif
                goto finish;
            }
                
            omx[0] = o_vectors[0];
            omx[1] = o_vectors[1];
            omx[2] = o_vectors[2];
            omx[3] = me->vw_rotation[3];
            omx[4] = o_vectors[3];
            omx[5] = o_vectors[4];
            omx[6] = o_vectors[5];
            omx[7] = me->vw_rotation[7];
            omx[8] = o_vectors[6];
            omx[9] = o_vectors[7];
            omx[10] = o_vectors[8];
            omx[11] = me->vw_rotation[11];
            omx[12] = me->vw_rotation[12];
            omx[13] = me->vw_rotation[13];
            omx[14] = me->vw_rotation[14];
            omx[15] = me->vw_rotation[15];
                
            for (i=0; i<16; ++i) 
            {
                me->vw_rotation[i] = omx[i];
            }
        }
        else
        {
            OMmsg = OM_E_ABORT;
        }

      } else 
          OMmsg = OM_E_ABORT;
    }

    if ( 1 & OMmsg )
	{
	    IGRchar *ptr;
	    struct IGRcv_prism *prism;

	    GRgetabsg(msg,&md_env->md_env.matrix_type, 
		md_env->md_env.matrix, &ptr, i );

	    if ( 1 & *msg)
	    {
		prism = (struct IGRcv_prism *) ptr;

		GRxformprism (msg, &local_env , prism , xmatrix, &xtype, 
			NULL, &my_id, &poly_chan);

		GRabsg_del_all();

	    }
	}
    }

    if (!(IF_NULL_OBJID( md_env->md_id.objid)))
    {
	om$send(
	     msg = message GRgraphics.GRaddwrng
	    	(&msg1,md_env),
	     targetid = my_id);

	if ( ! (1 & msg1))
	{
	    OMmsg =  OM_E_ABORT;
	    *msg =  MSFAIL;
	}
    }



    GR_NOTIFY_LISTENERS(msg,&OMmsg,GR_GEOM_XFORMED);

 finish:
    
    
    return (OMmsg);

}

/*\
Name
	GRaltscale - this method transforms the geometry of a 
		     graphics object by a matrix and alters the
		     scale string of reffile object.  

Synopsis
     GRaltscale(msg,md_env,matrix_type,matrix,newobjid, scale)

Description

	After calling GRxform, the scale string of the reffile attachment
	is modified.

	The possible return codes values in the msg field are:

	MSSUCC - successful completion
	MSFAIL - error
	GRSNOINVTRAN  -  in env_info is not invertible
	GRSDGNEXCEED design space limits are exceeded

Notes
	None.
History
	BJ 	06/21/90	Design date.

\*/

method GRaltscale(IGRlong *msg; struct GRmd_env *md_env; 
	       IGRshort *mx_type; IGRmatrix matrix; GRobjid *newobjid;
		IGRchar *scale)
{

    IGRlong     OMmsg;			/* OM return status		*/

     
    *msg = MSSUCC;			/* initialize objects		*/
    OMmsg = OM_S_SUCCESS;
 
    OMmsg = om$send(
	    	msg = message GRgraphics.GRxform
			(msg, md_env, mx_type, matrix, newobjid),
	    targetid = my_id);

    if ( 1 & OMmsg & *msg)
    {	
	OMmsg = om$vla_set_dimension(
		varray = me->scale_factor,
		size = (strlen(scale)+1));

	if ( 1 & OMmsg)
	{				/* copy in new scale		*/
	    strcpy(me->scale_factor,scale);
   	}
	else
	{
	    *msg = MSFAIL;
	}
    }

    return (OMmsg);

}
end implementation GRreffile;

