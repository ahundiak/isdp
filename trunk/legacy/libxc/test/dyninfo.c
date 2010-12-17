#include <link.h>

extern Elf32_Dyn _DYNAMIC;

static Elf32_Dyn *find_dynamic (Elf32_Dyn *dyn, int type)
{
  for (; dyn->d_tag; dyn++)
    if (dyn->d_tag == type)
      return dyn;
  return 0;
}


void listdyn (void)
{
  Elf32_Dyn       *dyn = find_dynamic (&_DYNAMIC, DT_DEBUG);
  struct r_debug  *dbg = (struct r_debug *)dyn->d_un.d_ptr;
  struct link_map *lmp = dbg->r_map;

  printf ("\tbrk    - 0x%.8x\n", dbg->r_brk);
  printf ("\tstate  - %d\n",     dbg->r_state);
  printf ("\tldbase - 0x%.8x\n\n", dbg->r_ldbase);
  for (; lmp; lmp = lmp->l_next) {
    printf ("[0x%.8x]  %s\n", lmp->l_addr,
                                       (lmp->l_name ? lmp->l_name : "<MAIN>"));
  }
}
