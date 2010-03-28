/*
Name
        GUotype2

Description
        This utility function formats an IGDS type 2 cell element according to
        the defining geometry, symbology and properties.

History
        ???     ??/??/??    creation
        mrm     02/08/92    handle user-defined line styles
        mrm     02/26/92    set attribute data bit here rather than
                            in GUload_IGDSheader
        mrm     11/06/92    fixed arg declarations for has_name and ele_name;
                            the types were reversed, which prevented the call
                            to GRswap_name_linkage by dereferencing a char
                            rather than a boolean (TR119221277, TR92n3929)
*/

class implementation GRvg;

#include "exsysdep.h"
#include "grimport.h"
#include "OMminimum.h"
#include "igrtypedef.h"
#include "igetypedef.h"
#include "gr.h"
#include "igr.h"
#include "transdef.h"
#include "translate.h"
#include "transerr.h"
#include "transmacros.h"
#include "godef.h"
#include "igrdp.h"
#include "go.h"
#include "msdef.h"
#include "dpdls.h"

from GRsmhdr import GRget_components;

#define MATRIX_SCALE 214748.3647

struct	cell
{
	struct GUcommon_header_info	header;
	short unsigned			wds_in_descript;
	IGRuchar  			name[4];
	IGRuchar  			class_map[2];
	IGRuchar  			level_map[8];
};

struct	cell_2d
{
	struct GUcommon_header_info	header;
	short unsigned			wds_in_descript;
	IGRuchar  			name[4];
	IGRuchar  			class_map[2];
	IGRuchar  			level_map[8];
	IGRlong				range[4];
	IGRlong				matrix[4];
	IGRlong				origin[2];
};

struct	cell_3d
{
	struct GUcommon_header_info	header;
	short unsigned			wds_in_descript;
	IGRuchar  			name[4];
	IGRuchar  			class_map[2];
	IGRuchar  			level_map[8];
	IGRlong				range[6];
	IGRlong				matrix[9];
	IGRlong				origin[3];
};

%safe
static int ELECTRONICS_COMMAND=0;
%endsafe

#argsused
GUotype2( msg, file_des, dgn_buf, igds, igds_size, class_name,
	  lbsys, range, symbology, geometric_props, properties,
	  cell, flag, env, bs_buf, name, has_name, ele_name)

	IGRlong			*msg;
	IGRint			*file_des;
	IGRchar			*dgn_buf;
	struct cell		*igds;
	IGRint			*igds_size;
	IGRchar			class_name[];
	struct IGRlbsys		*lbsys;
	GRrange			range;
	struct GRsymbology	*symbology;
	struct GRprops		*geometric_props;
	IGRshort		*properties;
	struct GRid		*cell;
	IGRboolean		*flag;
	struct GRmd_env		*env;
	IGRchar			*bs_buf;
	IGRchar			*name;
	IGRboolean		*has_name;
	IGRchar 		*ele_name;

{ /* begin GUotype2 */

    IGRint		i;			/* lcv			*/
    IGRint		number_components;	/* number of components	*/
    IGRshort		type = 2;		/* igds element type	*/
    IGRshort		write_mode;		/* mode for writing	*/

    IGRlong		brc = TRUE;		/* return status	*/
    IGRlong		status;			/* return status	*/

    IGRint		block_ptr;
    IGRint		byte_ptr;

    OM_S_CHANSELECT	chandef;		/* channel to get count	*/

    struct cell		*cell_hdr;
    struct cell_2d	*cell_2d;
    struct cell_3d	*cell_3d;

    IGRdouble		scale_factor = 1;

    IGRboolean		twrite;
    IGRint		num_chars = 6;
    IGRint		length;
    IGRint		previous_state,
		   	previous_offset;

    IGRdouble		chk_array[9];
    IGRboolean		chk_status = TRUE;
    IGRlong		num_vals;
    IGRdouble		my_max;
    IGRdouble		local_diag[6];

    IGRlong		name_msg;
    IGRmatrix		tmp_env_matrix;
    struct IGRlbsys	local_lbsys;
    
    extern IGRboolean   GUcheck_overflow();
    IGRshort		ndices;


    *msg = GUsuccess;

    GUcpxwritehdr ( msg, &twrite );

    if ( twrite )			/* need to write header		*/
    {
	short	four = 4;

	for (i=0; i<16; ++i)
	{
	   tmp_env_matrix[i] = env->md_env.matrix[i];
	}
	tmp_env_matrix[3] = 0;
	tmp_env_matrix[7] = 0;
	tmp_env_matrix[11] = 0;

	for (i=0; i<3 ; ++i)
	{
	    local_diag[i] = lbsys->diag_pt1[i];
	    local_diag[i+3] = lbsys->diag_pt2[i];
 	}
	i = 2;
	MAptsxform(msg,&i,tmp_env_matrix,local_diag,local_diag);

	cell_hdr = ( struct cell * ) igds;

  	MAinvmx(msg,&four,tmp_env_matrix,tmp_env_matrix);

	MAmulmx(msg,&four,&four,&four,tmp_env_matrix,lbsys->matrix,
		local_lbsys.matrix);

	if ( ! strncmp("GRclhdr",class_name,7) ) /* 3-d cell		*/
	{
	    cell_3d = (struct cell_3d *) igds;
	    cell_hdr->header.words_to_follow = 60;
	    cell_hdr->header.index_to_ae = 46;
	    *igds_size = 124;
	    cell_3d->origin[0] = GUnint(lbsys->matrix[3]);
	    cell_3d->origin[1] = GUnint(lbsys->matrix[7]);
	    cell_3d->origin[2] = GUnint(lbsys->matrix[11]);

	    for (i = 0; i < 3; i++)
	    {
	        GUswapint(&cell_3d->origin[i],&cell_3d->origin[i]);
	    }
	   
	    for (i = 0; i < 6; i++)
	    {
	    	cell_3d->range[i] = GUnint(local_diag[i]);
	        GUswapint(&cell_3d->range[i],&cell_3d->range[i]);
	    }

	    chk_array[0] = local_lbsys.matrix[0] * MATRIX_SCALE;
	    chk_array[1] = local_lbsys.matrix[1] * MATRIX_SCALE;
	    chk_array[2] = local_lbsys.matrix[2] * MATRIX_SCALE;
	    chk_array[3] = local_lbsys.matrix[4] * MATRIX_SCALE;
	    chk_array[4] = local_lbsys.matrix[5] * MATRIX_SCALE;
	    chk_array[5] = local_lbsys.matrix[6] * MATRIX_SCALE;
	    chk_array[6] = local_lbsys.matrix[8] * MATRIX_SCALE;
	    chk_array[7] = local_lbsys.matrix[9] * MATRIX_SCALE;
	    chk_array[8] = local_lbsys.matrix[10] * MATRIX_SCALE;
	    num_vals = 9;

	    cell_3d->matrix[0] = chk_array[0];
	    cell_3d->matrix[1] = chk_array[1];
	    cell_3d->matrix[2] = chk_array[2];
	    cell_3d->matrix[3] = chk_array[3];
	    cell_3d->matrix[4] = chk_array[4];
	    cell_3d->matrix[5] = chk_array[5];
	    cell_3d->matrix[6] = chk_array[6];
	    cell_3d->matrix[7] = chk_array[7];
	    cell_3d->matrix[8] = chk_array[8];

	    for (i = 0; i < 9; i++)
	    {
	        GUswapint(&cell_3d->matrix[i],&cell_3d->matrix[i]);
	    }
	    ndices = 18;   
	}
	else
	{
	    cell_2d = (struct cell_2d *) igds;
	    cell_hdr->header.words_to_follow = 44;
	    cell_hdr->header.index_to_ae = 30;
	    *igds_size = 92;
	    cell_2d->origin[0] = GUnint(lbsys->matrix[3]);
	    cell_2d->origin[1] = GUnint(lbsys->matrix[7]);

	    for (i = 0; i < 2; i++)
	    {
	        GUswapint(&cell_2d->origin[i],&cell_2d->origin[i]);
	    }
	   
	    for (i = 0; i < 4; i++)
	    {
	    	cell_2d->range[i] = GUnint(local_diag[i]);
	        GUswapint(&cell_2d->range[i],&cell_2d->range[i]);
	    }
	   
	    chk_array[0] = local_lbsys.matrix[0] * MATRIX_SCALE;
	    chk_array[1] = local_lbsys.matrix[1] * MATRIX_SCALE;
	    chk_array[2] = local_lbsys.matrix[4] * MATRIX_SCALE;
	    chk_array[3] = local_lbsys.matrix[5] * MATRIX_SCALE;
	    num_vals = 4;

	    cell_2d->matrix[0] = chk_array[0];
	    cell_2d->matrix[1] = chk_array[1];
	    cell_2d->matrix[2] = chk_array[2];
	    cell_2d->matrix[3] = chk_array[3];

	    for (i = 0; i < 4; i++)
	    {
	        GUswapint(&cell_2d->matrix[i],&cell_2d->matrix[i]);
	    }
	    ndices = 10;   
	}

	for (i = 0; i < 8; i++)
	{
	    cell_hdr->level_map[i] = 0;
	}

	for (i = 0; i < 4; i++)
	{
	    cell_hdr->name[i] = 0;
	}

        /* check whether a user-defined linestyle is present */
        if (symbology->display_attr.style >= BUILTIN_STYLES)
            GRaddStyleLinkage(&name_msg, symbology->display_attr.style, igds);

	GRadd_name_to_buf( &name_msg, has_name, ele_name, igds);
#ifdef BIG_ENDIAN
	if(*has_name)
            GRswap_name_linkage(igds);
#endif
	cell_hdr->wds_in_descript = cell_hdr->header.words_to_follow - 17;
	cell_hdr->class_map[0] = 0x1;
	cell_hdr->class_map[1] = 0;

	length = strlen(name);
	for (i = length; i < 6; i++)
	{
            name[i] = '\0';
	}

	
	GUascii_to_rad50 ( &num_chars, name, &cell_hdr->name[0] );


	cell_hdr->header.level = 0;

	/*
	 *  call function to load header data.
	 */

	GUload_IGDSheader( msg, class_name, &type, symbology, properties,
			   range, igds );

        /* set the attribute data bit in the element header */
        IGDSSetProperty(cell_hdr->header.properties, IGDSAttributeData);

	/*
	 *  IGDS type 2's have to be on level 0.
	 */

	cell_hdr->header.level = 0;
	cell_hdr->header.level &= 0x7f;

	chk_status = GUcheck_overflow( msg, &num_vals, chk_array,
				       &my_max );
	
	if ( chk_status )
	{
	    GUcpxopen ( msg, dgn_buf, igds, igds_size, file_des,
		&previous_state,&previous_offset);

	    *igds_size = (igds->header.words_to_follow + 2) * 2;
#ifdef BIG_ENDIAN
	    GRswap_type2_ele(igds,ndices);
#endif
	    write_mode = GUWRITE;
	    brc = GUwrite_element(  msg, dgn_buf, igds, &type, igds_size,
				    file_des, &write_mode, &block_ptr,
				    &byte_ptr );
	}
    } 					/* end if (twrite)		*/

    if (! ELECTRONICS_COMMAND)
    {
        chandef.type = OM_e_name;
        chandef.u_sel.name = "to_components";

        status = om$get_channel_count ( osnum = cell->osnum,
				    objid = cell->objid,
 				    p_chanselect = &chandef,
				    count = (OMuint *)&number_components );

        if ( ! (1 & status) )
        {
	    goto wrap_up;
    	}

    	for ( i = 0 ; i < number_components ; i++ )
    	{

	    status = om$send ( msg = message
				GRgraphics.GRformatele
				  ( msg, env, dgn_buf, bs_buf, 
				    (IGRchar *) igds,
				    igds_size, file_des, range,
				    &scale_factor),
			    senderid = cell->objid,
			    p_chanselect = &chandef,
			    targetos = cell->osnum,
				from = i,
				to = i );

	    if ( !(1 & status) )
	    {
	    	goto wrap_up;
	    }
        }				/* end for i			*/
    }

    if ( twrite )
    {
	GUcpxclose ( msg, dgn_buf, igds, igds_size, file_des );

    }

wrap_up:

    if (! chk_status )
    {
#ifdef DEBUG
	printf("GUotype2 : Cell overflowed\n");
#endif
    }

    return(brc);

} /* end GUotype2 */


void  Set_Electronics_flag(action)
int	action;
{
   ELECTRONICS_COMMAND=action;
}

end implementation GRvg;
