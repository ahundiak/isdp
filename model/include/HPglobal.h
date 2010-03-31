#if defined (CLIX)
#include "odi.h"
#endif
#include "HPstruct.h"

extern struct HPglobal_struct				HPglobal;
extern struct HPcommand_line_info_struct		HPcommand_line;
extern struct HPplotfile_header				HPheader;
extern struct HPdevice_info_struct			HPdevice;
extern struct HPenvironment_variable_info_struct	HPenv_var;

/*
 *  Global variables for plot shading
 */

extern struct HPband_info_struct	HPband_info;

extern FILE				*HPreport_file;

#define DEBUG_PIXEL	 (x == 40 && y == 128)
#define PRECISION_FACTOR 1024.0

extern unsigned char	pattern[4][4];
extern unsigned char	patterns[4][16][4];
extern char		trans_pat6[6][6];

extern char		lock_out;

