/*
Name
        GUotype27

Description
        This utility function formats an IGDS B-spline curve header element
        according to the defining geometry, symbology and properties.
        It also makes calls to the routines to create B-spline constituent
        entities.

History
        ???     ??/??/??    creation
        mrm     02/08/92    handle user-defined line styles
        mrm     05/11/93    add to words-in-description when attribute
                            linkages are appended to the header
*/

#include "exsysdep.h"
#include "grimport.h"
#include "OMminimum.h"
#include "igrtypedef.h"
#include "igetypedef.h"
#include "gr.h"
#include "igr.h"
#include "msdef.h"
#include "transdef.h"
#include "translate.h"
#include "transerr.h"
#include "transmacros.h"
#include "godef.h"
#include "igrdp.h"
#include "go.h"
#include "bserr.h"
#include "bsparameters.h"
#include "madef.h"
#include "msdef.h"
#include "dpdls.h"

extern void		BSsubdivcv();
extern void		BSarclnparc();
extern IGRboolean	BSfreecv();


int GUotype27(IGRlong			*msg,
              IGRint			*file_des,
              IGRchar			*dgn_buf,
              IGRchar			*igds,
              IGRint			*igds_size,
              IGRchar			class_name[],
              struct IGRbsp_curve	*geometry,
              GRrange			range,
              struct GRsymbology	*symbology,
              struct GRprops		*geometric_props,
              IGRshort			*properties,
              struct IGResbc		*bsc_attr,
              IGRboolean		*has_name,
              IGRchar			*name,
              IGRboolean		*fill_bit)
{
    IGRboolean		found = FALSE;
    IGRboolean		called = FALSE;
    IGRshort		type;           /* igds element type */
    IGRshort		write_mode;     /* mode for writing */
    IGRshort            wtf;
    IGRint		block_ptr;
    IGRint		byte_ptr;
    IGRint		count = 0;
    IGRint		max_poles = 101;
    IGRint		num_subcurves;
    IGRlong		bs_ret;
    IGRlong		name_msg;
    IGRlong		brc = TRUE;     /* return status */
    IGRlong		i;              /* lcv */
    IGRdouble		max_weight;     /* maximum weight value */
    IGRdouble		*weight_ptr;    /* pointer to weight array */
    IGRdouble		knottol = 4.656612875e-10;
    IGRdouble		*knotsptr;
    IGRdouble		*parameters;
    struct IGDS_bscurve	*curve;         /* IGDS curve header */
    struct IGRbsp_curve	**subcv;

    *msg = GUsuccess;

    /*
     *  Check number of poles for IGDS max.
     */
    
    if (geometry->num_poles > 101)
    {
        BSsubdivcv(geometry, max_poles, &num_subcurves, &subcv, 
                   &parameters, &bs_ret);
        
        if (bs_ret != BSSUCC)
        {
            brc = FALSE;
            *msg = MSFAIL;
            goto wrap_up;
        }
        
        for (i = 0; i < num_subcurves; i++)
        {
            MAcubepy(msg, subcv[i], &range[0], &range[3]);
            
            brc = GUotype27(msg, file_des, dgn_buf, igds, igds_size,
                            class_name, subcv[i], range, symbology,
                            geometric_props, properties, bsc_attr,
                            has_name, name, fill_bit);
        }
        
        /*
         *  Deallocate curves and parms here.
         */
        
        for (i = 0; i < num_subcurves; ++i)
        {
            BSfreecv(&bs_ret, subcv[i]);
        }
        
        free(parameters);
        free((IGRchar *)subcv);
        
        goto wrap_up;
        
    }
    
    
    /* 
     *   The values of the knots are checked. If the difference 
     * between them is less than the knottol, then a routine to
     * reorder the knots is called. The values of the knots are 
     * checked again. If they are still lower than the knottol, 
     * the curve is skipped. 
     * 
     */
    
    i = 0;	
    knotsptr = geometry->knots;
    while ((!found) && (i<(geometry->num_knots - 1)))
    {
        if (MAabsolute(knotsptr[i] - knotsptr[i+1]) < knottol)
        {
            count ++;
        }
        else 
        {
            count = 0;
        }
        i ++;
        if (count >= geometry->order)
        {
            if (!called)
            {
                called = TRUE;
                count = 0;
                i = 0;
                BSarclnparc(msg, geometry);
                if (*msg != BSSUCC)
                {
                    brc = FALSE;
                    goto wrap_up;
                }
            }
            else 
            {
                found = TRUE;
                brc = FALSE;
                *msg = MSFAIL;
                goto wrap_up;
            }
        }
    }
    
    
    
    write_mode = GUWRITE;
    
    curve = (struct IGDS_bscurve *) igds;
    
    /*
     * call function to load header data for curve header.
     */
    
    type = GU_BS_CURVE_HEADER;
    
    brc = GUload_IGDSheader(msg, class_name, &type, symbology, properties,
                            range, curve);
    
    if (*msg != GUsuccess)
    {
        goto wrap_up;
    }
    
    /*
     * Make sure the knot values range from 0 to 1.
     */
    
    if (geometry->num_knots == 0)
    {
        geometry->non_uniform = 0;
    }
    
    if (geometry->non_uniform)
    {
        GUnormalize_knots(geometry->knots, geometry->knots,
                          &geometry->num_knots, &geometry->order);
        
        /*
	 * If the curve is non_uniform we have to compress the knots.
	 */
        
        MAbcukunexpand(msg, &geometry->order, &geometry->num_knots,
                       geometry->knots, &geometry->num_knots, geometry->knots);
        
        if (geometry->num_knots == 0)
        {
            geometry->non_uniform = 0;
        }
    }
    
    /*
     * If the curve is periodic we have to compress the poles & weights.
     */
    
    if (geometry->periodic)
    {
        MAbcupunexpand(msg, &geometry->order, &geometry->rational,
                       &geometry->num_poles, geometry->poles, 
                       geometry->weights, &geometry->num_poles,
                       geometry->poles, geometry->weights);
    }
    
    if (geometry->rational)
    {
        IGRboolean b_status;
        
        /*
         * unweight poles for IGDS.
         */
        
        b_status = GUbcunweight(msg,geometry);
        
        /*
         * make sure all weight values are less than 1.
         */
        
        weight_ptr = geometry->weights;
        GUarray_max(weight_ptr,&max_weight,geometry->num_poles);
        
        if (max_weight > 1.0)
        {
            for (i = 0 ; i < geometry->num_poles ; i++)
            {
                geometry->weights[i] = geometry->weights[i] / max_weight;
            }
        }
        
    }
    
    /*
     * load necessary header data such as words in description.
     *
     * for curve->order, here's what happening:
     *
     *	naturally the order is set to curve order - 2	(bits 0-3)
     *	turn the stroked curve on/off			(bit 4)
     *	turn the control polygon on/off			(bit 5)
     *	set to rational if curve is rational		(bit 6)
     *	set to closed if curve is periodic		(bit 7)
     */

    curve->header.words_to_follow	= 21;
    curve->header.index_to_ae	        = 7;
    curve->curve.curve_type		= 0;
    curve->curve.order		        = geometry->order - 2;

    if (bsc_attr->is_curvedis)
    {
        curve->curve.order	       |= 0x10;
    }

    if (bsc_attr->is_polydis)
    {
        curve->curve.order	       |= 0x20;
    }

    if (geometry->rational)
    {
        curve->curve.order	       |= 0x40;
    }

    if (geometry->periodic)
    {
        curve->curve.order	       |= 0x80;
    }

    curve->curve.num_poles		= geometry->num_poles;
    curve->curve.num_knots		= geometry->num_knots;

    *igds_size			        = 46;

    if (!strncmp(class_name,"GR2",3))
    {
        curve->curve.wds_in_descript = 22 + 4 * (geometry->num_poles);
    }
    else
    {
        curve->curve.wds_in_descript = 22 + 6 * (geometry->num_poles);
    }

    if (geometry->rational)
    {
        curve->curve.wds_in_descript += 18 + 2 * geometry->num_poles;
    }

    if (geometry->non_uniform)
    {
        curve->curve.wds_in_descript += 18 + 2 * geometry->num_knots;
    }
    else
    {
        curve->curve.num_knots = 0;
    }

    // Add all the necessary attribute linkages, adding to the
    // words-in-description as appropriate.  TR11911309, mrm 5/11/93

    /* check whether a user-defined linestyle is present */
    if (symbology->display_attr.style >= BUILTIN_STYLES)
    {
        wtf = curve->header.words_to_follow;

        GRaddStyleLinkage(&name_msg, symbology->display_attr.style, igds);

        curve->curve.wds_in_descript += curve->header.words_to_follow - wtf;
    }

    /*  If an element name is present, it will be added to the translated
     *  element's user data linkage in the igds design file.
     */
    wtf = curve->header.words_to_follow;
    GRadd_name_to_buf(&name_msg, has_name, name, igds);
    curve->curve.wds_in_descript += curve->header.words_to_follow - wtf;
#ifdef BIG_ENDIAN
    if (*has_name)
        GRswap_name_linkage(igds);
#endif

    /*  If the polygon fill bit is set, attribute linkage data is added
     *  to the formatted element.
     */
    wtf = curve->header.words_to_follow;
    GRpoly_fill(msg, fill_bit, igds);
    curve->curve.wds_in_descript += curve->header.words_to_follow - wtf;
#ifdef BIG_ENDIAN
    if (*fill_bit)
        GRswap_poly_linkage(igds);
#endif

    // swap the words-in-description to IGDS format
    GUswapint(&curve->curve.wds_in_descript,&curve->curve.wds_in_descript);

    /*
     *  Write the element to the file.
     */

    *igds_size = (curve->header.words_to_follow + 2) * 2;

#ifdef BIG_ENDIAN
    GRswap_type27_ele(curve);
#endif

    brc = GUwrite_element(msg, dgn_buf, curve, &type, igds_size,
                          file_des, &write_mode, &block_ptr, &byte_ptr);
    
    if (*msg != GUsuccess)
    {
        goto wrap_up;
    }
    
    /*
     * if the curve is non-uniform, we have to write out a type 26 knot
     * element.
     */

    if (geometry->non_uniform)
    {

        brc = GUotype26(msg, file_des, dgn_buf, igds, igds_size,
                        class_name, geometry, range, symbology,
                        geometric_props, properties, geometry->knots,
                        &geometry->num_knots);

        if (*msg != GUsuccess)
        {
            goto wrap_up;
        }

    }

    /*
     * write out pole element.
     */
    
    brc = GUotype21(msg, file_des, dgn_buf, igds, igds_size, class_name,
                    geometry, range, symbology, geometric_props, properties,
                    geometry->poles, &geometry->num_poles);
    
    if (*msg != GUsuccess)
    {
        goto wrap_up;
    }
    
    /*
     * if the curve is rational, we have to write out a type 28 weight
     * factor element.
     */

    if (geometry->rational)

        brc = GUotype28(msg, file_des, dgn_buf, igds, igds_size,
                        class_name, geometry, range, symbology,
                        geometric_props, properties, geometry->weights,
                        &geometry->num_poles);

  wrap_up:

    return(brc);

}
