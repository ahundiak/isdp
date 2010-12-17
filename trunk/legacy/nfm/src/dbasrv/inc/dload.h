/* $Revision: 1.1 $ */
#ifndef DLOADPVT_H

/**************************/
/* DYNAMIC LOADER OPTIONS */
/**************************/

#define INCRLOAD   0x00001 /* Incremental load - do not perform wrapup step  */
#define SHLIBSYMS  0x00002 /* Read symbol tables of target shared libraries  */
#define NOCOMMON   0x00004 /* Make common symbols initialized global         */
#define HIDEGLOBAL 0x00008 /* Restrict scope of globals to defining file     */
#define WEAKGLOBAL 0x00010 /* Restrict scope of globals to file(s) at wrapup */
#define TEXTREDEF  0x00020 /* Allow redefinition of functions                */
#define DATAREDEF  0x00040 /* Allow redefinition of variables                */
#define TEXTREF    0x00080 /* Allow references to global text symbols        */
#define DATAREF    0x00100 /* Allow references to global data symbols        */
#define ALLOWURES  0x00200 /* Allow unresolved symbols in executable code    */
#define NODANGLING 0x00400 /* Allow loader to assume no dangling references  */
#define PATCH      0x00800 /* Enable patching of text section                */
#define SAFE       0x01000 /* Check stack frame before redefining a function */
#define TEXTWARN   0x02000 /* Emit warnings whenever a function is redefined */
#define DATAWARN   0x04000 /* Emit warnings whenever a variable is redefined */
#define SAFEWARN   0x08000 /* Emit warnings when redefining active function  */
#define RETRODBG   0x10000 /* Do debug processing even if no debugger active */

#endif

/*---------------------------------------------------------------------------*/

#define OPT_RPL  0
#define OPT_ADD  1
#define OPT_DEL  2

typedef struct {
                 long    unresolved;    /* number symbols still unresolved */
                 long    numfuncs;      /* number of functions loaded      */
                 char  **funcnames;     /* ptr to array of function names  */
                 int  (**funcptrs) ();  /* ptr to array of function ptrs   */
                 int  (**oldptrs)  ();  /* ptr to array of old functions   */

               } LOADDESCR;


#ifndef DLOADPVT_H

extern int        btblsz;
extern LOADDESCR *dload ();
extern void      *dload_address_lookup ();
extern int        dload_setopt ();

#endif
