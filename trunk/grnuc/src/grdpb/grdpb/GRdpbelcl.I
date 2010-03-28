/*
Name
        GRdpb_elig_class_init

Description
        This function sets up the GRNUC class eligibility information
        in the dpb.

History
        mrm     05/06/91    creation
        dhm     07/09/92    ANSI conversion.
*/

class implementation GRdpb;

#include "dp.h"
#include "dpdef.h"

extern OMuword OPP_GRgraphics_class_id,
               OPP_GRcurve_class_id,
               OPP_GRconic_class_id,
               OPP_GRcircle_class_id,
               OPP_GRcirarc_class_id,
               OPP_GRellipse_class_id,
               OPP_GRellarc_class_id,
               OPP_GRinfline_class_id,
               OPP_GRpoint_class_id, 
               OPP_GRlinear_class_id,
               OPP_GRpolygon_class_id,
               OPP_GRorthpoly_class_id,
               OPP_GRclhdr_class_id,
               OPP_GRgrgrp_class_id,
               OPP_GRclippoly_class_id,
               OPP_GRreffile_class_id,
               OPP_GRsmhdr_class_id,
               OPP_GRcsbase_class_id,
               OPP_GRpllnstr_class_id,
               OPP_GRcoords_class_id,
               OPP_GRlineseg_class_id,
               OPP_GRtext_class_id,
               OPP_GRorthlnst_class_id,
               OPP_GRlinestr_class_id,
               OPP_GRplanar_class_id,
               OPP_GRpart_class_id;

#define NCATEGORIES 27
#define NCLASSLISTS 24

IGRint GRdpb_elig_class_init(msg,objid,osnum)
IGRint *msg;
OM_S_OBJID objid;
OMuword osnum;
{
    IGRint sts, i;
    IGRchar *p_curve = "GRcurve";           /* these strings are referenced */
    IGRchar *p_reffile = "GRreffileown";    /* in several places, so minimize */
    IGRchar *p_shape = "GRshape";           /* the space taken in the image */
    IGRchar *p_coordsys = "GRcoordsys";     /* by declaring them once */
    IGRchar *p_conic = "GRconic";
    IGRchar *p_linear = "GRlinear";
    IGRchar *p_planar = "GRplanar";
    OM_S_CLASSLIST classlist[NCLASSLISTS];
    struct var_list vlist[NCATEGORIES + 1];
    struct GRelclass_a elclass[NCATEGORIES];

    /* set up the class locate eligibility information */

    for (i = 0; i < NCLASSLISTS; i++)
    {
        classlist[i].w_flags = OM_CLST_subclass;
        classlist[i].w_count = 1;
    }

    for (i = 0; i < NCATEGORIES; i++)
    {
        elclass[i].properties = TRUE;
        vlist[i].var = DPB_ADD_CLASSLIST;
        vlist[i].var_ptr = (char *)&elclass[i];
    }

    i = 0;
    elclass[i].ascii_key = p_curve;
    elclass[i].owner_key = NULL;
    elclass[i].classlist = &classlist[0];
    classlist[0].p_classes = &OPP_GRgraphics_class_id;
    classlist[0].w_count = 0;
    i++;
    elclass[i].ascii_key = p_conic;
    elclass[i].owner_key = p_curve;
    elclass[i].classlist = &classlist[20];
    classlist[20].p_classes = &OPP_GRconic_class_id;
    classlist[20].w_count = 1;
    i++;
    elclass[i].ascii_key = "GRcircle";
    elclass[i].owner_key = p_conic;
    elclass[i].classlist = &classlist[10];
    classlist[10].p_classes = &OPP_GRcircle_class_id;
    i++;
    elclass[i].ascii_key = "GRcirarc";
    elclass[i].owner_key = p_conic;
    elclass[i].classlist = &classlist[11];
    classlist[11].p_classes = &OPP_GRcirarc_class_id;
    i++;
    elclass[i].ascii_key = "GRellipse";
    elclass[i].owner_key = p_conic;
    elclass[i].classlist = &classlist[12];
    classlist[12].p_classes = &OPP_GRellipse_class_id;
    i++;
    elclass[i].ascii_key = "GRellarc";
    elclass[i].owner_key = p_conic;
    elclass[i].classlist = &classlist[13];
    classlist[13].p_classes = &OPP_GRellarc_class_id;
    i++;
    elclass[i].ascii_key = p_linear;
    elclass[i].owner_key = p_curve;
    elclass[i].classlist = &classlist[0];
    i++;
    elclass[i].ascii_key = "GRpoint";
    elclass[i].owner_key = p_linear;
    elclass[i].classlist = &classlist[4];
    classlist[4].p_classes = &OPP_GRpoint_class_id;
    i++;
    elclass[i].ascii_key = "GRlineseg";
    elclass[i].owner_key = p_linear;
    elclass[i].classlist = &classlist[16];
    classlist[16].p_classes = &OPP_GRlineseg_class_id;
    i++;
    elclass[i].ascii_key = "GRlinestr";
    elclass[i].owner_key = p_linear;
    elclass[i].classlist = &classlist[15];
    classlist[15].p_classes = &OPP_GRlinestr_class_id;
    i++;
    elclass[i].ascii_key = "GRinfline";
    elclass[i].owner_key = p_linear;
    elclass[i].classlist = &classlist[14];
    classlist[14].p_classes = &OPP_GRinfline_class_id;
    i++;
    elclass[i].ascii_key = p_planar;
    elclass[i].owner_key = p_linear;
    elclass[i].classlist = &classlist[21];
    classlist[21].p_classes = &OPP_GRplanar_class_id;
    i++;
    elclass[i].ascii_key = "GRpllnstr";
    elclass[i].owner_key = p_planar;
    elclass[i].classlist = &classlist[9];
    classlist[9].p_classes = &OPP_GRpllnstr_class_id;
    i++;
    elclass[i].ascii_key = "GRorthlnst";
    elclass[i].owner_key = p_planar;
    elclass[i].classlist = &classlist[22];
    classlist[22].p_classes = &OPP_GRorthlnst_class_id;
    i++;
    elclass[i].ascii_key = p_shape;
    elclass[i].owner_key = p_planar;
    elclass[i].classlist = &classlist[0];
    i++;
    elclass[i].ascii_key = "GRpolygon";
    elclass[i].owner_key = p_shape;
    elclass[i].classlist = &classlist[5];
    classlist[5].p_classes = &OPP_GRpolygon_class_id;
    i++;
    elclass[i].ascii_key = "GRorthpoly";
    elclass[i].owner_key = p_shape;
    elclass[i].classlist = &classlist[6];
    classlist[6].p_classes = &OPP_GRorthpoly_class_id;
    i++;
    elclass[i].ascii_key = p_reffile;
    elclass[i].owner_key = NULL;
    elclass[i].classlist = &classlist[0];
    i++;
    elclass[i].ascii_key = "GRclippoly";
    elclass[i].owner_key = p_reffile;
    elclass[i].classlist = &classlist[7];
    classlist[7].p_classes = &OPP_GRclippoly_class_id;
    i++;
    elclass[i].ascii_key = "GRreffile";
    elclass[i].owner_key = p_reffile;
    elclass[i].classlist = &classlist[8];
    classlist[8].p_classes = &OPP_GRreffile_class_id;
    i++;
    elclass[i].ascii_key = p_coordsys;
    elclass[i].owner_key = NULL;
    elclass[i].classlist = &classlist[18];
    classlist[18].p_classes = &OPP_GRcoords_class_id;
    i++;
    elclass[i].ascii_key = "GRcsbase";
    elclass[i].owner_key = p_coordsys;
    elclass[i].classlist = &classlist[17];
    classlist[17].p_classes = &OPP_GRcsbase_class_id;
    i++;
    elclass[i].ascii_key = "GRtext";
    elclass[i].owner_key = NULL;
    elclass[i].classlist = &classlist[1];
    classlist[1].p_classes = &OPP_GRtext_class_id;
    i++;
    elclass[i].ascii_key = "GRgrgrp";
    elclass[i].owner_key = NULL;
    elclass[i].classlist = &classlist[2];
    classlist[2].p_classes = &OPP_GRgrgrp_class_id;
    i++;
    elclass[i].ascii_key = "GRsmhdr";
    elclass[i].owner_key = NULL;
    elclass[i].classlist = &classlist[19];
    classlist[19].p_classes = &OPP_GRsmhdr_class_id;
    i++;
    elclass[i].ascii_key = "GRclhdr";
    elclass[i].owner_key = NULL;
    elclass[i].classlist = &classlist[3];
    classlist[3].p_classes = &OPP_GRclhdr_class_id;
    i++;
    elclass[i].ascii_key = "GRpart";
    elclass[i].owner_key = NULL;
    elclass[i].classlist = &classlist[23];
    classlist[23].p_classes = &OPP_GRpart_class_id;

    vlist[NCATEGORIES].var = END_PARAM;

    sts = om$send(msg = message GRdpb.GRputname( (IGRlong *) msg, vlist ),
                  senderid = objid,
                  targetos = osnum,
                  targetid = objid);

    return(sts);
}

end implementation GRdpb;

