#ifndef DUMP_H
#define DUMP_H

/* dump_curve.c */

extern int dump_curve ( FILE *ofp, 
                        struct HPnurb_curve_struct *p_curve, 
                        unsigned short level, 
                        int dimension );

/* dump_elem.c */

extern int dump_element ( FILE *ofp, 
                          IGRchar command[2], 
                          IGRint level, 
                          IGRdouble range[6], 
                          IGRint num, 
                          IGRchar *data_ptr);

/* dump_header.c */

extern int dump_header ( FILE *ofp);

/* dump_soo.c */

extern int dump_curve_soo ( FILE *ofp, struct HPsoo_info *soo, int num_soos);

/* dump_surf.c */

extern int dump_surface ( FILE *ofp, 
                          struct HPnurb_surface_struct *surf_ptr, 
                          int level, 
                          IGRdouble range[6]);

/* scanner.c */

extern int ems_metafile_scanner ( FILE *out_file, int *commands_processed);


/* dump_bytes.c */

extern int dump_bytes ( FILE *ofp, long number, unsigned char *buffer_ptr );

/*  dump_util.c  */ 

extern void WriteDouble ( FILE *ofp, double dd );
extern void WriteDouble2( FILE *ofp, double *dd );
extern void WriteDouble3( FILE *ofp, double *dd );
extern void WriteDouble4( FILE *ofp, double *dd );

#endif
