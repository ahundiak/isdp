#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/grio/uom/UOMinit.C */
static int compare_keywords __((UOM_DIMKEYWORD *keyword1, UOM_DIMKEYWORD *keyword2));
static int compare_keyword_types __((UOM_DIMKEYWORD *keyword1, UOM_DIMKEYWORD *keyword2));
static int compare_dims __((struct da_dims *dim1, struct da_dims *dim2));
static void stripit __((char *line));
static char *getline __((char *line, int sz, char *fp));
static void UOM_lookup_dimensions __((char *unit_type, UOMdimensions dims));
extern int UOM_lookup_dimension_keyword __((char *keyword, int *keyword_type));
extern int UOM_lookup_dimension_keyword_type __((int keyword_type, char *keyword));
static int UOM_parse_type __((char *line, UOM_TYPE **type));
static int UOM_parse_default __((char *line, UOM_TYPE *type));
static int UOM_parse_variant __((char *line, UOM_VARIANT **variant));
static int UOM_verify_scale_units __((UOM_TYPE *type));
extern int UOM_verify_type __((UOM_TYPE *type));
static int UOM_read_table __((char *uom_table, UOM_TYPE **uom_types));
static UOM_unchain_scales __((UOM_TYPE *uom_types));
extern int UOM_merge_uom_types __((OMuword osnum, UOM_TYPE **prod_uom_types, UOM_TYPE **uom_types));
extern int UOM_init __((OMuword osnum, UOM_TYPE **uom_types));
extern int UOM_dump_variant __((UOM_VARIANT *variants));
extern int UOM_dump_readout __((char *str, UOM_READOUT *ro));
extern int UOM_dump_type __((UOM_TYPE *types));

#if defined(__cplusplus)
}
#endif


#undef __
