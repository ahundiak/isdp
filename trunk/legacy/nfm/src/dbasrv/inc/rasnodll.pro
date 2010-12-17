#ifndef rasnodll_pro
#define rasnodll_pro

/* From c_raster.c */
extern int dba_check_raster (
);

/* From e_raster.c */
extern int dba_exit_raster (
);

/* From i_raster.c */
extern int dba_init_raster (
);

/* From s_disgra.c */
extern long dba_s_display_graphics (
  functiontype  *bfunc,
  functiontype  *function,
  long  opnum);

/* From s_raster.c */
extern void dba_setup_raster (
);

#endif
