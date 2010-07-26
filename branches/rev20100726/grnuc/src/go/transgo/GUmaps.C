/* #######################    APOGEE COMPILED   ######################## */
/*
Name
        GUmapclass_to_igds

Description
        This function maps an EMS class to an IGDS element type.

History
        ???     ??/??/??    creation
        mrm     09/17/91    speed enhancements to minimize
                            classname-to-classid traffic
                02/13/92    added check for reference files
*/

/*
#include "grimport.h"
*/
#include "igrtypedef.h"
#include "igr.h"
#include "transdef.h"
#include "OMerrordef.h"
#include "OMminimum.h"
#include "OMprimitives.h"

extern OMuword OPP_GRsmhdr_class_id, OPP_GRclhdr_class_id,
               OPP_GRpoint_class_id, OPP_GRlineseg_class_id,
               OPP_GRinfline_class_id, OPP_GRlinestr_class_id,
               OPP_GRpllnstr_class_id, OPP_GRorthlnst_class_id,
               OPP_GRpolygon_class_id, OPP_GRorthpoly_class_id,
               OPP_GRcircle_class_id, OPP_GRellipse_class_id,
               OPP_GRcirarc_class_id, OPP_GRellarc_class_id,
               OPP_GRtext_class_id, OPP_GRreffile_class_id;

IGRlong GUmapclass_to_igds(classname, ele_type)
IGRchar		*classname;
IGRint		*ele_type;
{
    OMuword     classid;
    IGRlong	status;

    status = om$get_classid(classname = classname, p_classid = &classid);
    if (!(status & 1)) goto wrapup;

    status = om$is_ancestry_valid(subclassid = classid,
			          superclassid = OPP_GRsmhdr_class_id);
    if (status == OM_S_SUCCESS)
    {
        *ele_type = GU_SYMBOL;
	goto wrapup;
    }

    status = om$is_ancestry_valid(subclassid = classid,
			          superclassid = OPP_GRclhdr_class_id);
    if (status == OM_S_SUCCESS)
    {
        *ele_type = GU_CELL;
	goto wrapup;
    }

    status = om$is_ancestry_valid(subclassid = classid,
			          superclassid = OPP_GRpoint_class_id);
    if (status == OM_S_SUCCESS)
    {
	*ele_type = GU_LINE;
	goto wrapup;
    }

    status = om$is_ancestry_valid(subclassid = classid,
			          superclassid = OPP_GRlineseg_class_id);
    if (status == OM_S_SUCCESS)
    {
	*ele_type = GU_LINE;
	goto wrapup;
    }

    status = om$is_ancestry_valid(subclassid = classid,
			          superclassid = OPP_GRinfline_class_id);
    if (status == OM_S_SUCCESS)
    {
	*ele_type = GU_LINE;
	goto wrapup;
    }

    status = om$is_ancestry_valid(subclassid = classid,
			          superclassid = OPP_GRlinestr_class_id);
    if (status == OM_S_SUCCESS)
    {
	*ele_type = GU_LINE_STRING;
	goto wrapup;
    }

    status = om$is_ancestry_valid(subclassid = classid,
			          superclassid = OPP_GRpllnstr_class_id);
    if (status == OM_S_SUCCESS)
    {
	*ele_type = GU_LINE_STRING;
	goto wrapup;
    }

    status = om$is_ancestry_valid(subclassid = classid,
			          superclassid = OPP_GRorthlnst_class_id);
    if (status == OM_S_SUCCESS)
    {
	*ele_type = GU_LINE_STRING;
	goto wrapup;
    }

    status = om$is_ancestry_valid(subclassid = classid,
			          superclassid = OPP_GRpolygon_class_id);
    if (status == OM_S_SUCCESS)
    {
	*ele_type = GU_SHAPE;
	goto wrapup;
    }

    status = om$is_ancestry_valid(subclassid = classid,
			          superclassid = OPP_GRorthpoly_class_id);
    if (status == OM_S_SUCCESS)
    {
	*ele_type = GU_SHAPE;
	goto wrapup;
    }

    status = om$is_ancestry_valid(subclassid = classid,
			          superclassid = OPP_GRcircle_class_id);
    if (status == OM_S_SUCCESS)
    {
	*ele_type = GU_ELLIPSE;
	goto wrapup;
    }

    status = om$is_ancestry_valid(subclassid = classid,
			          superclassid = OPP_GRellipse_class_id);
    if (status == OM_S_SUCCESS)
    {
	*ele_type = GU_ELLIPSE;
	goto wrapup;
    }

    status = om$is_ancestry_valid(subclassid = classid,
			          superclassid = OPP_GRcirarc_class_id);
    if (status == OM_S_SUCCESS)
    {
	*ele_type = GU_ARC;
	goto wrapup;
    }

    status = om$is_ancestry_valid(subclassid = classid,
			          superclassid = OPP_GRellarc_class_id);
    if (status == OM_S_SUCCESS)
    {
	*ele_type = GU_ARC;
	goto wrapup;
    }

    status = om$is_ancestry_valid(subclassid = classid,
			          superclassid = OPP_GRtext_class_id);
    if (status == OM_S_SUCCESS)
    {
	*ele_type = GU_TEXT_NODE;
	goto wrapup;
    }

    status = om$is_ancestry_valid(subclassid = classid,
			          superclassid = OPP_GRreffile_class_id);
    if (status == OM_S_SUCCESS)
    {
	*ele_type = GU_REFERENCE_FILE;
	goto wrapup;
    }

    /*
       These are EMS classes and may not be present in GRNUC, so their
       classids cannot be externed.
    */

    status = om$is_ancestry_valid(subclassid = classid,
			          superclassname = "GRsubbc");
    if (status == OM_S_SUCCESS)
    {
	*ele_type = GU_BS_CURVE_HEADER;
	goto wrapup;
    }

    status = om$is_ancestry_valid(subclassid = classid,
			          superclassname = "EMSsubbs");
    if (status == OM_S_SUCCESS)
    {
	*ele_type = GU_BS_SURF_HEADER;
    }

    status = om$is_ancestry_valid(subclassid = classid,
			          superclassname = "GRcompcurve");
    if (status == OM_S_SUCCESS)
    {
	*ele_type = GU_CPX_STRING;
    }

wrapup:

    return (status);

}
