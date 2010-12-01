#include <stdio.h>
#include "bs.h"
#include "mastruct.h"

int out(char *name, int size)
{
  printf("%-20s %3u\n",name,size);
}
int main(int argc, char *argv)
{

  //out("",sizeof(struct ));

  // igrtypedef.h
  // no differences
  out("IGRboolean",sizeof(IGRboolean));
  out("IGRshort",  sizeof(IGRshort));
  out("IGRlong",   sizeof(IGRlong));
  out("IGRint",    sizeof(IGRint));
  out("IGRdouble", sizeof(IGRdouble));
  out("IGRchar",   sizeof(IGRchar));
  out("IGRuchar",  sizeof(IGRuchar));
  out("IGRushort", sizeof(IGRushort));
  out("IGRuint",   sizeof(IGRuint));
  out("IGRulong",  sizeof(IGRulong));
  out("IGRvector", sizeof(IGRvector));
  out("IGRmatrix", sizeof(IGRmatrix));
  out("IGRpoint",  sizeof(IGRpoint));

  // igr.h
  // Only IGRcv_prisim is different
  out("IGRline",        sizeof(struct IGRline));
  out("IGRline_seg",    sizeof(struct IGRline_seg));
  out("IGRpolyline",    sizeof(struct IGRpolyline));
  out("IGRset_polyline",sizeof(struct IGRset_polyline));
  out("IGRarc",         sizeof(struct IGRarc));
  out("IGRellipse",     sizeof(struct IGRellipse));
  out("IGRcone",        sizeof(struct IGRcone));
  out("IGRptstring",    sizeof(struct IGRptstring));
  out("IGRlbsys",       sizeof(struct IGRlbsys));
  out("IGRsymboldef",   sizeof(struct IGRsymboldef));
  out("IGRsymbol",      sizeof(struct IGRsymbol));
  out("IGRbsp_curve",   sizeof(struct IGRbsp_curve));
  out("IGRbc_bdrys",    sizeof(struct IGRbc_bdrys));
  out("IGRbsp_bdry_pts",sizeof(struct IGRbsp_bdry_pts));
  out("IGRbsp_surface", sizeof(struct IGRbsp_surface));
  out("IGRrt_prism",    sizeof(struct IGRrt_prism));
  out("IGRcv_prism",    sizeof(struct IGRcv_prism));     // 180 vs 184
  out("IGRpolygon",     sizeof(struct IGRpolygon));
  out("IGRplane",       sizeof(struct IGRplane));
  out("IGRpointset",    sizeof(struct IGRpointset));

  // bstypes.h
  // No differences
  out("BSpoly",  sizeof(BSpoly));
  out("BSmatrix",sizeof(BSmatrix));
  out("BSmat",   sizeof(BSmat));
  out("BSmat2",  sizeof(BSmat2));
  out("BSrc",    sizeof(BSrc));
  out("BSaddr",  sizeof(BSaddr));
  out("BSpair",  sizeof(BSpair));

  // mastruct.h
  out("MAcoef",            sizeof(struct MAcoef));
  out("MAinformation_coef",sizeof(struct MAinformation_coef));
  out("MAinformation",     sizeof(struct MAinformation));     // 48 vs 56
  out("MAinfo_struct",     sizeof(struct MAinfo_struct));
  out("MAinfo_struct_ln",  sizeof(struct MAinfo_struct_ln));
  out("MAinfo_struct_pt",  sizeof(struct MAinfo_struct_pt));
  out("MAinfo",            sizeof(struct MAinfo));            // 68 vs 72
#if 0
  out("",sizeof(struct ));
  out("",sizeof(struct ));
  out("",sizeof(struct ));
  out("",sizeof(struct ));
  out("",sizeof(struct ));
  out("",sizeof(struct ));
#endif
  // bsdefs.h
  // a number are different, most seem to end in a pointer
  out("BSlsfamily_elt",    sizeof(struct BSlsfamily_elt));
  out("BSlsfamily",        sizeof(struct BSlsfamily));
  out("BSintersection",    sizeof(struct BSintersection));
  out("BSpar_slis",        sizeof(struct BSpar_slis));
  out("BSpt_slis",         sizeof(struct BSpt_slis));
  out("BSpt_dlis",         sizeof(struct BSpt_dlis));
  out("BSintpt_slis",      sizeof(struct BSintpt_slis));
  out("BScurve_slis",      sizeof(struct BScurve_slis));
  out("BScv_slis",         sizeof(struct BScv_slis));
  out("BSmem_slis",        sizeof(struct BSmem_slis));
  out("BSpt_par_elem",     sizeof(struct BSpt_par_elem));
  out("BSpt_par_ptr_elem", sizeof(struct BSpt_par_ptr_elem));
  out("BSmin_max_box",     sizeof(struct BSmin_max_box));
  out("BScv_endpts",       sizeof(struct BScv_endpts));
  out("BSvda_cv_seg",      sizeof(struct BSvda_cv_seg));
  out("BSvda_sf_pch",      sizeof(struct BSvda_sf_pch));
  out("BSstf_surface",     sizeof(struct BSstf_surface));
  out("BSpolylgd",         sizeof(struct BSpolylgd));
  out("BSlgd_srs_prp",     sizeof(struct BSlgd_srs_prp));
  out("BSpolcv",           sizeof(struct BSpolcv));
  out("BSpolsf",           sizeof(struct BSpolsf));
  out("BSwrkcv",           sizeof(struct BSwrkcv));
  out("BSwrksf",           sizeof(struct BSwrksf));
  out("BSsurfa",           sizeof(struct BSsurfa));
  out("BSbspcv",           sizeof(struct BSbspcv));
  out("BSbspsf",           sizeof(struct BSbspsf));
  out("BSpcscv",           sizeof(struct BSpcscv));
  out("BStype_curve",      sizeof(union  BStype_curve));
  out("BStype_surfa",      sizeof(union  BStype_surfa));
  out("BScurve",           sizeof(struct BScurve));
  out("BSsurfa",           sizeof(struct BSsurfa));
  out("BSres_cv",          sizeof(struct BSres_cv));
  out("BScirc_arc",        sizeof(struct BScirc_arc));


}
