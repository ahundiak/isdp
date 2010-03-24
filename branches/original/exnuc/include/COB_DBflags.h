/* This file contains debug flags definitions */
#ifndef COB_DBflagsh
#define COB_DBflagsh

#ifndef	COB_D_DEFINE_DBFLAGS
extern
#endif
int		COBtrace;		/* general trace flag */

#ifndef	COB_D_DEFINE_DBFLAGS
extern
#endif
int		COBdebugindentlvl;	/* format debug output */

#ifndef	COB_D_DEFINE_DBFLAGS
extern
#endif
int		COBdebFlag_debug;	/* debug for COBdebFlag class  */

#ifndef	COB_D_DEFINE_DBFLAGS
extern
#endif
int		actions_debug;		/* debug for actions class  */

#ifndef	COB_D_DEFINE_DBFLAGS
extern
#endif
int		CEO_debug;		/* debug for CEO class  */


#ifndef	COB_D_DEFINE_DBFLAGS
extern
#endif
int		CEO_LOCATE_debug;	/* debug for CEO_LOCATE class  */

#ifndef	COB_D_DEFINE_DBFLAGS
extern
#endif
int		CEO_GSLOCATE_debug;	/* debug for CEO_GSLOCATE class  */

#ifndef	COB_D_DEFINE_DBFLAGS
extern
#endif
int		state_debug;		/* debug for state class  */

#ifndef	COB_D_DEFINE_DBFLAGS
extern
#endif
int		trans_debug;		/* debug for trans class  */

#ifndef	COB_D_DEFINE_DBFLAGS
extern
#endif
int		read_debug;		/* debug for CEO.read_t_file  */

#ifndef	COB_D_DEFINE_DBFLAGS
extern
#endif
int		dump_debug;		/* debug for CEO.dump  */

#endif
