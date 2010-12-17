/* ins_main.c and rem_main.c */
long main (int argc, char **argv);
long options ( int argc, char **argv ) ;
long WriteCFGFile ( void ) ;
void _CLI_str (char *str, ... ) ;
void _CLI_num (char *str, long var) ;

/*  ins_util.c */
long UpdateAutoexec (void) ;
long MakeDir (char *path_name);
long InstallProduct ( void ) ;
long VerifyHost( void ) ;
long GetFreeSpace (unsigned long *free_space) ;
long AddPath (char *newpath) ;
void Mstr_FindEnvironment (char far **Env, unsigned *EnvSize ) ;
char far *Mstr_getenv (char far *Env, char far *name) ;
long SystemCall (char *command) ;
void DeleteFiles ( void ) ;
long RemoveDir_Files (char *dir_name) ;
long DeleteFiles_inPath (char *path) ;
long RemovePath_auto (char *path_name) ;
