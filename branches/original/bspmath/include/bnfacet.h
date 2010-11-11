/* Copyright (C) 1996, 1997, Intergraph Corporation. All rights reserved. */

#ifndef bnfacet_include

#define bnfacet_include


struct BNb_loop
{
   IGRboolean   p_loop;
   IGRint       np;
   IGRdouble    *uv;
   IGRdouble    range[4];
};

struct BNsf_data
{
   IGRdouble    stock;
   IGRshort     tool_cnd;
   IGRint	n_pat;
   IGRint	n_sedo;
   IGRint	n_bnd;
   IGRint       *pat_ary;
   IGRint       *sedo_ary;
   IGRint       *bnd_ary;
   IGRint       surf_save;
   IGRint       poly_save;
};

struct BNs_poly
{
   IGRint	u_num_seg;
   IGRint	v_num_seg;
   IGRboolean	rational;
   IGRshort	u_order;
   IGRshort	v_order;
   IGRdouble	*u_knots;
   IGRdouble	*v_knots;
   IGRdouble    **px;
   IGRdouble    **py;
   IGRdouble    **pz;
   IGRdouble    **ph;
};

struct BNc_poly
{
   IGRint	num_seg;
   IGRboolean	rational;
   IGRshort	order;
   IGRdouble	*knots;
   IGRdouble    **px;
   IGRdouble    **py;
   IGRdouble    **pz;
   IGRdouble    **ph;
};

struct BNpatch
{ 
   IGRboolean    plannar;
   IGRboolean    pseudo;
   IGRshort      solid;       /* 1: all solid facet
                                 0: all hole facet
                                -1: partial solid   */
   IGRdouble     us;
   IGRdouble     ud;
   IGRdouble     vs;
   IGRdouble     vd;
   IGRint        nu;
   IGRint        nv;
   IGRint        n_loop;
   IGRshort      *nu_cht;
   IGRshort      *nv_cht;
   IGRshort      *bit_map;
   IGRpoint      *xyz_tp;
   struct Facetloop    *fct_lp;
   IGRshort      level;
   IGRint        ptr_sav[10];
   IGRshort      uvr[4];
};

struct Facetloop
{
   IGRboolean	 p_loop;
   IGRint	 np;
   IGRdouble     *uv;
   IGRdouble     *xyz;
   IGRboolean    *b_bit;
};

#endif /* bnfacet_include */
