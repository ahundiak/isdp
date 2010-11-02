/* ----------------------------------------------------
 * The existing opl proved to be frustratng to use
 *
 * This version will read one of more .o files for OPP names
 * and generate the necessary OMclassinit files.
 *
 * elfdump -s objects.o
 */
#include <fcntl.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include <libelf.h>

#include <dlfcn.h>
#include <link.h>

#define CLASS_NAMES_MAX 2000
int   classNamesCnt = 0;
char *classNames[CLASS_NAMES_MAX];

#define METHOD_NAMES_MAX 20000
int   methodNamesCnt = 0;
char *methodNames[METHOD_NAMES_MAX];

int compareNames(const void *p1, const void *p2)
{
    char *name1 = *(char **)p1;
    char *name2 = *(char **)p2;
    
  //printf("Compare %s %s\n",name1,name2);
    return strcmp(name1,name2);
}
void genClassInit()
{
    int i;
    FILE *file;

    // Sort em
    qsort(classNames, classNamesCnt, sizeof(char *),compareNames);
    qsort(methodNames,methodNamesCnt,sizeof(char *),compareNames);

    // Header stuff
    file = fopen("OMclassinit.c","wt");
    fprintf(file,"#define NULL 0\n");
    fprintf(file,"typedef unsigned short int OMuword;\n");
    fprintf(file,"typedef int              (*OM_p_FUNCPTR) (); /* function pointer */\n");
    fprintf(file,"\n");

    // Class init functions
    for(i = 0; i < classNamesCnt; i++)
    {
        fprintf(file,"int %s_OM_class_init();\n",classNames[i]);
    }
    fprintf(file,"\n");

    // Init list
    fprintf(file,"OM_p_FUNCPTR OM_GA_class_definitions[]=\n{\n");
    for(i = 0; i < classNamesCnt; i++)
    {
        fprintf(file,"  %s_OM_class_init,\n",classNames[i]);
    }
    fprintf(file,"};\n");
    fprintf(file,"int OM_Gi_number_of_defns = %d;\n\n",classNamesCnt);

    // Class ids
    // OMuword OPP_EX_bckup_class_id = 65535;
    for(i = 0; i < classNamesCnt; i++)
    {
        fprintf(file,"OMuword OPP_%s_class_id = 65535;\n",classNames[i]);
    }
    fprintf(file,"\n");

    // Method indexes
    // OMuword cmdserver_OPP_clear_stack_method_index = 65535;
    for(i = 0; i < methodNamesCnt; i++)
    {
        fprintf(file,"OMuword %s_method_index = 65535;\n",methodNames[i]);
    }
    fprintf(file,"\n");

    // Done
    fclose(file);

  //system("cat   OMclassinit.c");
    system("cc -c OMclassinit.o OMclassinit.c");
}
void addClassName(char *name)
{
    int i;

    if (!*name) return;

    for(i = 0; i < classNamesCnt; i++)
    {
        if (!strcmp(name,classNames[i])) return;
    }
    if (i >= CLASS_NAMES_MAX)
    {
        printf("*** Class Names Limit Reached: %d\n",CLASS_NAMES_MAX);
        exit(1);
    }
    classNames[i] = strdup(name);
    classNamesCnt++;
    return;
}
void addMethodName(char *name)
{
    int i;

    if (!*name) return;

    for(i = 0; i < methodNamesCnt; i++)
    {
        if (!strcmp(name,methodNames[i])) return;
    }
    if (i >= METHOD_NAMES_MAX)
    {
        printf("*** Method Names Limit Reached: %d\n",METHOD_NAMES_MAX);
        exit(1);
    }
    methodNames[i] = strdup(name);
    methodNamesCnt++;
    return;
}
void processClassName(char *bufx)
{
    char buf[256];
    char name[64];
    char *p,*p2;
    
    strcpy(buf,bufx);
    
    p = strstr(buf,"FUNC GLOB");
    if (!p) return;

    p = strstr(buf,".text");
    if (!p) return;

    p = strstr(buf,"_OM_class_init");
    if (!p) return;

    for(p2 = p; *p2 != ' '; p2--);

    *p = 0;
    strcpy(name,p2+1);

    addClassName(name);

    // printf("%s\n",name);
}
void processMethodName(char *bufx)
{
    char buf[256];
    char name[64];
    char *p,*p2;

    strcpy(buf,bufx);

    p = strstr(buf,"OPP");
    if (!p) return;

    p = strstr(buf,"NOTY GLOB");
    if (!p) return;

    p = strstr(buf,"_method_index");
    if (!p) return;

    for(p2 = p; *p2 != ' '; p2--);

    *p = 0;
    strcpy(name,p2+1);

    addMethodName(name);

    // printf("%s\n",name);
}
int processFile(char *fileName)
{
    FILE *file;
    char buf[256];

    sprintf(buf,"elfdump -s %s 2>&1 > /tmp/oplx.txt",fileName);
    system(buf);

    file = fopen("/tmp/oplx.txt","rt");
    if (!file) return 1;

    while(fgets(buf,256,file))
    {
        processClassName (buf);
        processMethodName(buf);
    }
    fclose(file);
    return 0;
}
int main(int argc, char **argv)
{
    int i;

    for(i = 1; i < argc; i++)
    {
        processFile(argv[i]);
    }
    genClassInit();
    return 0;
}
static void failure(void);

int main2(int argc, char ** argv)
{
  Elf32_Shdr *shdr;
  Elf32_Ehdr *ehdr;
  Elf        *elf;
  Elf_Scn    *scn;
  Elf_Data   *data;
  int          fd;
  unsigned int cnt;

  /* Open the input file */
  if ((fd = open(argv[1], O_RDONLY)) == -1) exit(1);

  /* Obtain the ELF descriptor */
  (void) elf_version(EV_CURRENT);
  if ((elf = elf_begin(fd, ELF_C_READ, NULL)) == NULL) failure();

  /* Obtain the .shstrtab data buffer */
  if (((ehdr = elf32_getehdr(elf)) == NULL) ||
      ((scn  = elf_getscn(elf, ehdr->e_shstrndx)) == NULL) ||
      ((data = elf_getdata(scn, NULL)) == NULL))
    failure();

  /* Traverse input filename, printing each section */
  for (cnt = 1, scn = NULL; scn = elf_nextscn(elf, scn); cnt++)
  {
    if ((shdr = elf32_getshdr(scn)) == NULL) failure();

    (void) printf("[%3d] %s\n", cnt, (char *)data->d_buf + shdr->sh_name);
  }
  //fclose(fd);
  return 0;
} /* end main */

static void failure()
{
  (void) fprintf(stderr, "%s\n", elf_errmsg(elf_errno()));
  exit(1);
}



int mainx(int argc, char **argv)
{
    void *handle;

    printf("Hello from oplx\n");

    handle = dlopen("objects.o",RTLD_NOW | RTLD_LOCAL);

    dlclose(handle);

    return 0;
}