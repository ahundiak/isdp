#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* VEact_list.c */
extern void VEinsert_into_active_list __((struct VEelement_header *new_elem, IGRdouble sort_xmin, struct VEelement_header **active_list));
extern void VEremove_finished_elements __((struct VEelement_header **active_list));

/* VEactivate.c */
extern void VEdelete_element_due_to_abort __((struct VEelement_header *element));
extern void VEactivate_element __((struct VEsort_record *sort_rec, struct VEelement_header **active_elems));

/* VEcollect.C */
extern void VEcollect_elements __((struct GRid *co_grid, OM_S_CHANSELECT *gschansel, struct GRmd_env *batch_env, IGRboolean batch_copy));

/* VEmain.c */
extern void VEprocess_elements __((void));

/* VEsort.C */
extern void VEfree_sort_record_tree __((struct VEsort_record **tree));
extern IGRboolean VEsort_by_min_x __((struct VEsort_record *sort_rec));
extern IGRboolean VEsort_by_objid __((struct VEsort_record *sort_rec));
extern void VEinit_sort __((IGRboolean batch_copy));

#if defined(__cplusplus)
}
#endif


#undef __

