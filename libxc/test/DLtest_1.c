char Bss[4096];

char Title[] = { "BSS Initialization" };
int main ()
{
  char *xxx = Bss;
  int   cnt = sizeof (Bss);

  for (; cnt--; xxx++)
    if (*xxx) return 0;
  return 1;
}
