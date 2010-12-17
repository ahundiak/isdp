#if !defined(_DLOAD_H)
#define _DLOAD_H

/**************************/
/* DYNAMIC LOADER OPTIONS */
/**************************/

#define OVERLOAD   0x00001 /* Load this file even if it is already loaded    */
#define INCRLOAD   0x00002 /* Incremental load - do not perform binding      */
#define UNLOADABLE 0x00004 /* Assert that file is to be unloadable           */
#define NOCOMMON   0x00008 /* Make common symbols initialized global         */
#define HIDEGLOBAL 0x00010 /* Restrict scope of globals to defining file     */
#define WEAKGLOBAL 0x00020 /* Restrict scope of globals to file(s) at wrapup */
#define DATAONLY   0x00040 /* With HIDEGLOBAL/WEAKGLOBAL apply to data only  */
#define ALLOWURES  0x00080 /* Allow unresolved symbols in executable code    */
#define TEXTREF    0x00100 /* Allow text references to another dynamic file  */
#define DATAREF    0x00200 /* Allow data references to another dynamic file  */
#define TEXTREDEF  0x00400 /* Allow redefinition of functions                */
#define DATAREDEF  0x00800 /* Allow redefinition of variables                */
#define DATAMAPNEW 0x01000 /* Map existing data definitions to the new one   */
#define DATAMAPOLD 0x02000 /* Map new data definitions to existing ones      */
#define HIDEDEBUG  0x04000 /* Do not tell symbolic debuggers about this file */

/* global options (set with dload_ctrl or environment variables) */

#define DEBUGMODE  0x0001  /* For debugging the dynamic loader               */
#define VERBOSE1   0x0002  /* Display names of files as they are loaded      */
#define VERBOSE2   0x0004  /* Display lots of stuff for each file loaded     */
#define RETRODBG   0x0008  /* Assume that a debugger will be used            */
#define NOWARNING  0x0010  /* Turn off display of warning messages           */
#define FCNSAFE    0x0020  /* Check stack frame before redefining a function */

/* predefined "handles" for accessing special cases */

#define  DLOAD_MAIN  (void *)1
#define  DLOAD_PEND  (void *)2
#define  DLOAD_GLBL  (void *)3

/* values for "cmd" argument of dload_ctrl */

#define  INITIAL    0	/* initialize without loading any files       */
#define  LOADCMPL   1	/* make incrementally loaded files executable */
#define  UNLOAD     2	/* unload the given file(s)                   */
#define  GETHANDLE  3	/* get the handle associated with a file      */
#define  GETSTATUS  4	/* get status information about a file        */
#define  SETOPTION  5	/* set global options                         */
#define  CLROPTION  6	/* clear global options                       */
#define  ENTERTAG   7	/* enter a reactive load tag                  */

/* status structure returned by dload_ctrl (GETSTATUS) */

#if 0
struct dloadstat {
   char *name;        /* the name of this file                     */
   int   options;     /* the options this file was loaded with     */
   int   unres;       /* the number of unresolved symbols          */
   void *text_addr;   /* address where the text segment was loaded */
   void *data_addr;   /* address where the data segment was loaded */
   uint  textsz;      /* the size in bytes of the text segment     */
   uint  datasz;      /* the size in bytes of the data segment     */
   int   flags;       /* flags (see below)                         */
};
#endif

#define  DL_LOADED  0x01  /* the file is loaded and executable */
#define  DL_PEND    0x02  /* the file is pending a LOADCMPL    */
#define  DL_UNLOAD  0x04  /* the file is unloadable            */

/* symbol definition structure returned by dload_symbol_lookup */

struct symdef {
   char *name;      /* the name of the symbol            */
   void *value;     /* the value (address) of the symbol */
   int   flags;     /* flags (see below)                 */
};

#define  DL_UNDF   0x00  /* undefined                                */
#define  DL_ABS    0x01  /* absolute (nonrelocatable) symbol         */
#define  DL_TEXT   0x02  /* text symbol                              */
#define  DL_DATA   0x04  /* data symbol                              */
#define  DL_BSS    0x08  /* bss (common) symbol                      */
#define  DL_HIDE   0x10  /* hidden symbol (scope restricted to file) */
#define  DL_INACT  0x20  /* inactive (superceeded) definition        */

/************/
/* ROUTINES */
/************/

#if defined(__cplusplus)
extern "C" {
#endif
#if defined (__STDC__)
extern void *dload (char *path, int options);
extern void *dload_ctrl (int cmd, ...);
extern void *dload_address_lookup (char *name);
extern int   dload_symbol_lookup (void *handle, char *name,
							  struct symdef **buf);
#else /* K&R "C" */
extern void *dload ();
extern void *dload_ctrl ();
extern void *dload_address_lookup ();
extern int   dload_symbol_lookup ();
#endif
#if defined(__cplusplus)
}
#endif

#endif
