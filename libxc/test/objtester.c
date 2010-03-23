#include "objaccess.h"

main (int argc, char **argv)
{
  char file[256];
  OBJFD *fd;
  ARNDX *ndx, *tmp;
  OBJINFO *info;
  SECTION *scn;
  STE *sym;
  RLOCENT *reloc;
  LINENUM *line;
  int    cnt;

  if (!(fd = OBJopen (argv[1], OBJ_ALL))) {
    printf ("Open failed!\n");
    exit (4);
  }

/*  ndx = OBJread_ndx (fd, &cnt);

  for (tmp = ndx; cnt--; tmp++)
    printf ("%d\t%s\n", tmp->offset, tmp->symbol);

  OBJseek_ar (fd, ndx->offset);    */

  info = OBJread (fd, OBJ_SCN | OBJ_GSYM | OBJ_RELOC | OBJ_LINE);

  printf ("\n\nFLAGS:");
  if (info->flags & OBJ_REL)    printf ("  REL");
  if (info->flags & OBJ_EXE)    printf ("  EXE");
  if (info->flags & OBJ_SLIB)   printf ("  SLIB");
  if (info->flags & OBJ_CORE)   printf ("  CORE");
  if (info->flags & OBJ_DYN)    printf ("  DYN");
  if (info->flags & OBJ_DBG)    printf ("  DBG");
  if (info->flags & OBJ_NSYM)   printf ("  NSYM");
  if (info->flags & OBJ_NRELOC) printf ("  NRELOC");
  if (info->flags & OBJ_DEMAND) printf ("  DEMAND");
  if (info->flags & OBJ_IMPURE) printf ("  IMPURE");
  if (info->flags & OBJ_SHARED) printf ("  SHARED");
  if (info->flags & OBJ_ADJSEG) printf ("  ADJSEG");
  if (info->flags & OBJ_PIC)    printf ("  PIC");
  
  printf ("\n\n\nSEGMENTS  -  name/size/faddr/vaddr\n\n");
  if (info->text) printf ("TEXT:\t0x%.8x  0x%.8x  0x%.8x\n", info->text->size,
	info->text->faddr, info->text->vaddr);
  if (info->data) printf ("DATA:\t0x%.8x  0x%.8x  0x%.8x\n", info->data->size,
	info->data->faddr, info->data->vaddr);
  if (info->bss) printf ("BSS:\t0x%.8x  0x%.8x  0x%.8x\n", info->bss->size,
	info->bss->faddr, info->bss->vaddr);

  printf ("\n\nSECTIONS  -  name/size/faddr/vaddr/flags\n");
  for (scn = info->scnptr, cnt = info->nsects; cnt--; scn++) {
    printf ("\n%-15s 0x%.8x  0x%.8x  0x%.8x", scn->name, scn->size, scn->faddr, scn->vaddr);
    if (scn->flags & SCN_TEXT)  printf ("  TEXT");
    if (scn->flags & SCN_DATA)  printf ("  DATA");
    if (scn->flags & SCN_BSS)   printf ("  BSS");
    if (scn->flags & SCN_INFO)  printf ("  INFO");
    if (scn->flags & SCN_READ)  printf ("  READ");
    if (scn->flags & SCN_WRITE) printf ("  WRITE");
    if (scn->flags & SCN_EXE)   printf ("  EXE");
    if (scn->flags & SCN_ABS)   printf ("  ABS");
    if (scn->flags & SCN_NRES)  printf ("  NRES");
  }
  printf ("\n\n\nSYMBOLS  -  value/type/name\n\n");
  for (sym = info->symptr, cnt = info->nsyms; cnt--; sym++) {
    char buff[16];
    printf ("0x%.8x\t", sym->value);
    buff[0] = '\0';
    if (sym->whatis == SYM_NIL) strcat (buff, "NIL  ");
    if (sym->whatis & SYM_EXT)  strcat (buff, "EXT  ");
    if (sym->whatis & SYM_GLOB) strcat (buff, "GLOB ");
    if (sym->whatis & SYM_COMM) strcat (buff, "COMM ");
    if (sym->whatis & SYM_WEAK) strcat (buff, "WEAK ");
    if (sym->whatis & SYM_STAT) strcat (buff, "STAT ");
    if (sym->whatis & SYM_TEXT) strcat (buff, "TEXT ");
    if (sym->whatis & SYM_DATA) strcat (buff, "DATA ");
    if (sym->whatis & SYM_BSS)  strcat (buff, "BSS  ");
    if (sym->whatis & SYM_ABS)  strcat (buff, "ABS  ");
    if (sym->whatis & SYM_FUNC) strcat (buff, "FUNC ");
    if (sym->whatis & SYM_VAR)  strcat (buff, "VAR  ");
    if (sym->whatis & SYM_LAB)  strcat (buff, "LAB  ");
    printf ("%12s\t%s\n", buff, sym->name);
  }
  printf ("\n\nRELOCATION ENTRIES  -  addr/type/addend/symbol\n\n");
  for (reloc = info->relocptr, cnt = info->nrelocs; cnt--; reloc++)
    printf ("0x%.8x\t%d\t%d\t%s\n", reloc->addr, reloc->rtype, reloc->addend, (reloc->symbol ? reloc->symbol->name : ""));
  printf ("\n\nLINE NUMBERS  -  line/addr\n\n");
  for (line = info->lineptr, cnt = info->nlines; cnt--; line++)
    printf ("%d\t0x%.8x\n", line->line, line->addr);
}

