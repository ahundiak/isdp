/* Copyright (C) 1996, 1997, Intergraph Corporation. All rights reserved. */
/*  S.G. Catron : 04/11/97  : Creation date.   */
/*  This files declares our global data and for NT it adds an 
    indirection */

# ifndef bsglobal_include
# define bsglobal_include


struct BSroutine_name
{
  IGRchar name[20];
  BSrc    rc;
};

#ifdef BSDATAIMPORT
#undef BSDATAIMPORT
#endif

#if defined (BSNTDLL)
#define BSDATAIMPORT __declspec(dllimport)
#else
#define BSDATAIMPORT
#endif
#if defined(__cplusplus)
extern "C" {
#endif
extern BSDATAIMPORT IGRint     BSlmemnumb;
extern BSDATAIMPORT IGRchar    *BSlmemptr;
extern BSDATAIMPORT IGRboolean BSalloczero;
extern BSDATAIMPORT IGRboolean BSfreezero;
extern BSDATAIMPORT struct BSlsalloc BSlist_al;
extern BSDATAIMPORT IGRint  BSdbglev;
extern BSDATAIMPORT IGRdouble BScnp[];
extern BSDATAIMPORT IGRdouble BScnpn[];
extern BSDATAIMPORT IGRdouble BSgloballgdcan[];
extern BSDATAIMPORT IGRdouble BSglobalcanlgd[];
extern BSDATAIMPORT IGRdouble BSgloballgdtch[];
extern BSDATAIMPORT IGRdouble BSglobaltchlgd[];
extern BSDATAIMPORT IGRdouble BSglobalcantch[];
extern BSDATAIMPORT IGRdouble BSglobalcstlgdp[];
extern BSDATAIMPORT IGRdouble BSglobalcstlgdm[];
extern BSDATAIMPORT IGRdouble BSglobalrootablgd[];
extern BSDATAIMPORT IGRdouble BSglobalHitablgd[];
extern BSDATAIMPORT IGRdouble BSglobalinttablgd[];
extern BSDATAIMPORT IGRdouble *BSgau_order[][2];
extern BSDATAIMPORT IGRdouble BS1cnp[];
extern BSDATAIMPORT struct BSroutine_name BSfile_name[];
extern BSDATAIMPORT IGRint BSerrcount;
extern BSDATAIMPORT IGRint BSglobalmaxdeginttab;
extern BSDATAIMPORT IGRint BSglobalmaxdegcstlgd;
extern BSDATAIMPORT IGRint BSglobalmaxdegtchlgd;
extern BSDATAIMPORT IGRint BSglobalmaxdeglgdtch;
#if defined(__cplusplus)
}
#endif



# endif /* bsglobal_include */
