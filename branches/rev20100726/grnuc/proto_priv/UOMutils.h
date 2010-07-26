#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/grio/uom/UOMutils.C */
extern int UOM_MulUnit __((char udm1[], char udm2[], char mul[]));
extern int UOM_DivUnit __((char udm1[], char udm2[], char div[]));
extern int UOM_EquUnit __((char udm1[], char udm2[]));
extern int UOM_CpyUnit __((char to_udm[], char fr_udm[]));
extern int UOM_NoUnit __((char udm[]));
extern int UOM_HasUnit __((char udm[]));
extern int UOM_list_append __((UOM_DLIST_POINTER *new_ptr, UOM_DLIST_POINTER **list_ptr));
extern int UOM_list_remove_head __((UOM_DLIST_POINTER **list_ptr, UOM_DLIST_POINTER **ptr_to_head));
extern int UOM_list_remove __((UOM_DLIST_POINTER *ptr_to_remove, UOM_DLIST_POINTER **list_ptr));

#if defined(__cplusplus)
}
#endif


#undef __
