/* $Revision: 1.1 $ */
#ifndef DBA_PROTO_H
#define DBA_PROTO_H

#ifdef src_risdvw
#define DBA_PROTO
#endif

#ifndef DBA_PROTO
#define DBA_PROTO

#include "dbadev.h"

#include "dbforms.pro"
#include "dbformsc.pro"
#include "dbnuc.pro"
#include "dload.pro"
#include "gui.pro"
#include "mb.pro"
#include "nfm.pro"
#include "nucleus.pro"
#include "private.pro"
#include "rb.pro"
#include "rbc.pro"
#include "report.pro"
#include "script.pro"
#include "ustn.pro"
#include "debug.pro"

#ifdef src_sce
#include "cretab.def"
#include "sce.pro"
#endif

#if defined src_x || defined src_xras || defined src_xdv || defined __SUN__ \
    || defined __hpux || defined sco || defined sol || defined isl

#include <X11/Xlib.h>

#if !defined __hpux
#include "FS.h"
#endif

#include "XFIproto_pub.h"
/*
#include "dba_g.ext"
*/
#include "x.pro"
#include "xdv.pro"
/*
#include "xras.pro"
*/

#else

#if !defined (__WIN16__)  && !defined (__WIN32__) && !defined (_MAC_)
#include "clipper.pro"
#endif

#if defined (__WIN32__)
#if defined src_wforms
#define WINAPI ""
#include "fiw.h"
#include "wforms.pro"
#else
#include "shampub.h"
#endif
#include "v_gui.pro"
#include "v_pub.pro"
#include "n_dba.pro"
#include "dde.pro"
#elif defined (__WIN16__)
#include "fiw.h"
#include "wforms.pro"
#elif defined (_MAC_)
#include "bedpub.h"
#include "v_gui.pro"
#include "v_pub.pro"
#else
#include "FIproto_pub.h"
#endif

#if defined (_MAC_)
#include "n_dba.pro"
#endif

#if !defined (__WIN16__)

#if !defined (src_ustn)
/*
#include "dba_g.ext"
*/
#if defined src_raster || defined src_rasnodll
#include "raster.pro"
#include "rasnodll.pro"
#include "dba_dmc.pro"
#include "dba_red.pro"
#if !defined (__WIN32__) 
/*
#include "evras.pro"
*/
#endif
#endif
#endif
#endif

#if defined __WIN16__ 
#include "windows.pro"
#include "win16.pro"
#endif
#if defined __WIN32__
#include "windows.pro"
#include "win32.pro"
#endif
#if defined _MAC_
#include "mac.pro"
#endif

#endif

#if !defined (__WIN16__)  && !defined (__WIN32__) && !defined (_MAC_)
#include "unix.pro"
#endif

#else

/*
#include "debug.proto"
*/
char *dba_get_msg ();
char *dba_open_msg ();
char *dba_parse_tics ();
int dba_get_fldtrm ();
unsigned char dba_map_character ();
struct dba_library *dba_lib_open ();
struct dba_user *dba_check_user_var ();
struct dba_user *dba_process_user_var ();
char *build_user_text ();
char *dba_field_att_spec ();
char *dba_line_ent_spec ();
struct dba_formula *dba_parse_formula ();
char *dba_date_time ();
struct dba_group *dba_parse_user ();
char *dba_expand_shell_vars ();
char *build_user_text ();
void dba_exit ();
char *dba_strchr();
/*
void *dba_dmalloc ();
void *dba_dcalloc ();
*/
void *dba_drealloc ();
/*
char *dba_dstrdup ();
*/

#endif

#endif
