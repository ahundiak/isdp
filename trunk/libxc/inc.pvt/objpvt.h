/* magic number to verify file descriptor */

#define  FDMAGIC  1677492741

/* Determine if an address is correctly aligned to be a pointer to the
   specified type. */

#define  ALIGNED(a,t) \
\
  (!((unsigned int)(a) % (sizeof (struct {char x; t y;}) - sizeof (t))))


/*****************************************************************************/
/*		  DEFINITIONS FOR CLIPPER IMPLEMENTATION		     */
/*****************************************************************************/

#if CLIX
#include <filehdr.h>
#include <aouthdr.h>
#include <scnhdr.h>
#include <reloc.h>
#include <syms.h>
#include <linenum.h>

/* a.out header magic numbers */

#define  OMAGIC    0407
#define  NMAGIC    0410
#define  ZMAGIC    0413
#define  LIBMAGIC  0443

/* definition for contents of the ".xingr" section which is used in case of
   overflowed s_nreloc and s_nlnno fields in the section header */

struct ingr_sec {
		  char  sname[8];
		  ulong nreloc;
		  ulong nlnno;
		  ulong filler[2];
};

struct ingr_data {
                   ulong           i_numsecs;
		   ulong           i_flags;
		   struct ingr_sec i_data[1];
};

struct objpriv {
    OBJFD                  fd;        /* user's file descriptor              */
    int                    fdmagic;   /* unlikely quantity to test validity  */
    uint                   done;      /* mask of items already processed     */
    uint                   fsize;     /* size of whole file in bytes         */
    uint                   reloc_off; /* file offset to relocation entries   */
    uint                   line_off;  /* file offset to line numbers         */
    uint                   mapoff;    /* file offset of mapping              */
    uint                   mapsize;   /* size of file mapping                */
    char                  *mapaddr;   /* address of file mapping             */
    OBJINFO               *info;      /* info structure returned by OBJread  */
    struct filehdr        *fhead;     /* object file header                  */
    struct aouthdr        *ohead;     /* system header                       */
    struct scnhdr         *shead;     /* section headers                     */
    struct ingr_data      *xingr;     /* .xingr section if present           */
    struct syment         *symtab;    /* symbol table                        */
    STE                  **symmap;    /* symbol map                          */
    char                  *extname;   /* external name cache                 */
};
#endif

/*****************************************************************************/
/*		   DEFINITIONS FOR SPARC IMPLEMENTATION			     */
/*****************************************************************************/

#if SunOS_4x
#include <a.out.h>
#include <stab.h>
#include <link.h>
#include <ar.h>
#include <ranlib.h>


struct objpriv {
    OBJFD                  fd;        /* user's file descriptor              */
    int                    fdmagic;   /* unlikely quantity to test validity  */
    uint                   done;      /* mask of items already processed     */
    uint                   fsize;     /* size of whole file in bytes         */
    uint                   mapoff;    /* file offset of mapping              */
    uint                   mapsize;   /* size of file mapping                */
    char                  *mapaddr;   /* address of file mapping             */
    OBJINFO               *info;      /* info structure returned by OBJread  */
    struct exec           *fhead;     /* object file header                  */
    struct link_dynamic_2 *ldyn;      /* object's link dynamic (if has one)  */
    struct nlist          *symtab;    /* symbol table                        */
    STE                  **symmap;    /* symbol map                          */
    char                  *extname;   /* external name cache                 */
    int                    nsyms;     /* total number of input symbols       */
    int                    nlines;    /* number of line number symbols       */
};
#endif

/*****************************************************************************/
/*		    DEFINITIONS FOR MIPS IMPLEMENTATION			     */
/*****************************************************************************/

#if IRIX_4x
#include <filehdr.h>
#include <aouthdr.h>
#include <scnhdr.h>
#include <reloc.h>
#include <symconst.h>
#include <sym.h>
#include <ar.h>

/* this macro returns the file offset to the raw section data; also the macro
   N_TXTOFF in the "a.out.h" file is wrong */

#define N_TXTOFF(f,a) ( \
          (a).magic == ZMAGIC || (a).magic == LIBMAGIC ? 0 : \
                    (FILHSZ + (f).f_opthdr + (f).f_nscns * SCNHSZ)       )


struct objpriv {
    OBJFD                  fd;        /* user's file descriptor              */
    int                    fdmagic;   /* unlikely quantity to test validity  */
    uint                   done;      /* mask of items already processed     */
    uint                   fsize;     /* size of whole file in bytes         */
    uint                   reloc_off; /* file offset to relocation entries   */
    uint                   gptbl_off; /* file offset to GP table             */
    uint                   mapoff;    /* file offset of mapping              */
    uint                   mapsize;   /* size of file mapping                */
    char                  *mapaddr;   /* address of file mapping             */
    OBJINFO               *info;      /* info structure returned by OBJread  */
    struct filehdr        *fhead;     /* object file header                  */
    struct aouthdr        *ohead;     /* system header                       */
    struct scnhdr         *shead;     /* section headers                     */
    HDRR                  *symhdr;    /* symbolic header                     */
};
#endif

/*****************************************************************************/
/*		   	DEFINITIONS FOR SVR4 IMPLEMENTATION		     */
/*****************************************************************************/

#if SVR4
/*****************************************************************************/
/*		ELF OBJECT FORMAT COMPLIANCE PARAMETERS			     */
/*									     */
/* These parameters determine what assumptions we can make regarding a       */
/* specific implementation of the ELF object file format.  If the parameter  */
/* is non-zero, more efficient code can be used to implement the access      */
/* routines and the assumption is presumed to be valid for that system.      */
/*									     */
/*   NO_VOID_SECTIONS - every section header has a non-empty section         */
/*			associated with it.				     */
/*									     */
/*   SECTIONS_ORDERED - the section headers appear in the same order as the  */
/*			section data does in the object file.		     */
/*									     */
/*   LOCAL_SYMS_FIRST - all symbols with STB_LOCAL binding precede the weak  */
/*			and global symbols; also the "sh_info" field of the  */
/*			symbol table's section header always holds the index */
/*			of the first non-local symbol.			     */
/*									     */
/*   RELOCS_ORDERED   - all of the relocation sections appear in the same    */
/*			order as the sections to which they apply.	     */
/*									     */
/*   RELOCS_GROUPED   - all of the relocation sections appear contiguously   */
/*			in the object file allowing them to be read or       */
/*			mapped with a single system call.		     */
/*									     */
/*   RELOC_ONE_TYPE   - the target system uses the SHT_RELA or SHT_REL       */
/*			relocation types exculsively (this parameter must    */
/*			set to the type used).				     */
/*****************************************************************************/
#if IRIX
#define  NO_VOID_SECTIONS  1
#define  RELOC_ONE_TYPE    SHT_REL
#endif

#if SunOS
#define  SECTIONS_ORDERED  1
#define  LOCAL_SYMS_FIRST  1
#define  RELOCS_GROUPED    1
#if __i386__				/* SOLARIS on Intel PC */
#define  RELOC_ONE_TYPE    SHT_REL
#else
#define  RELOC_ONE_TYPE    SHT_RELA
#endif
#endif

/* default is no assumptions */

#ifndef  NO_VOID_SECTIONS
#define  NO_VOID_SECTIONS  0
#endif
#ifndef  SECTIONS_ORDERED
#define  SECTIONS_ORDERED  0
#endif
#ifndef  LOCAL_SYMS_FIRST
#define  LOCAL_SYMS_FIRST  0
#endif
#ifndef  RELOCS_ORDERED
#define  RELOCS_ORDERED    0
#endif
#ifndef  RELOCS_GROUPED
#define  RELOCS_GROUPED    0
#endif
#ifndef  RELOC_ONE_TYPE
#define  RELOC_ONE_TYPE    0
#endif
/*****************************************************************************/

#include <unistd.h>
#include <elf.h>
#if SunOS
#include <link.h>
#endif

/* additional section flags we use to mark which segment the input section
   belongs to */

#define  SHF_TEXT  0x1000000
#define  SHF_DATA  0x2000000
#define  SHF_BSS   0x4000000


struct objpriv {
    OBJFD                  fd;        /* user's file descriptor              */
    int                    fdmagic;   /* unlikely quantity to test validity  */
    uint                   done;      /* mask of items already processed     */
    uint                   fsize;     /* size of whole file in bytes         */
    OBJINFO               *info;      /* info structure returned by OBJread  */
    Elf32_Ehdr            *fhead;     /* object file header                  */
    Elf32_Phdr            *phead;     /* program headers                     */
    Elf32_Shdr            *shead;     /* section headers                     */
    Elf32_Dyn             *ldyn;      /* dynamic linking information         */
    Elf32_Sym             *symtab;    /* symbol table                        */
#if LOCAL_SYMS_FIRST
    int                    globndx;   /* index of first non-local symbol     */
#else
    STE                  **symmap;    /* symbol index translation vector     */
#endif
    SECTION              **scnmap;    /* section index translation vector    */
    char                  *scnname;   /* string table for section names      */
    char                  *extname;   /* string table for symbol names       */
    int                    ndyn;      /* number of dynamic entries           */
    int                    nsyms;     /* number of symbol table entries      */
};
#endif
