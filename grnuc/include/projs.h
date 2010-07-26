#ifndef projs_include
#define projs_include


struct DPprojs_info
{
	IGRint		flag;
	OM_S_OBJID	winid;
	uword		osnum;
       	IGRdouble	origin[3];
        IGRdouble	Xproj;
        IGRdouble	Yproj;
        IGRdouble	Zproj;

struct 	DPele_header   *bufrs_ptr;
};

struct DPvwinfo
{

struct  DPprojs_info	vw_info; 
        IGRint		g_flags;

};


struct DPelem_proj
{
	IGRint		flag;
	OM_S_OBJID	winid;
	uword		osnum;
        IGRdouble	origin[3];
        IGRdouble	pt_tng[3];
        IGRdouble	Xsave;
        IGRdouble	Ysave;
        IGRdouble	Zsave;
  struct IGRbsp_curve    *tng_ln;
  struct DPele_header	*bufrs_ptr;
};

#endif
