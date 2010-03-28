/* -- Indexes of the environment pointer ( third argument od the main() )
      function.
      If main() is declared as:

		main( argc, argv, envp )
		int	argc	;
		char	**argv	;
		void	**envp	;

      then :
      (char *)		  envp[PPL_CMD] points to the command name
      (char *)		  envp[PPL_KEY] points to the command key
      (char *)		  envp[PPL_DGN] points to the design name
      (struct GRmd_env *) envp[PPL_MOD] points to the current module environment
			  envp[PPL_END] is NULL

      Alternatively, to access the data above, one may declare main() as:

		main( argc, argv, envp )
		int	argc	;
		char	**argv	;
		pplenv	*envp	;

      then
      envp->cmd		points to the command name
      envp->key		points to the command key
      envp->dgn		points to the design name
      envp->mod		points to the current module environment
      envp->end		is NULL

      File dependency: "ciminimum.h" ( for "struct GRmd_env" ).
   -- */
#ifndef cigetargs_include
#	define cigetargs_include

#	define PPL_CMD 0
#	define PPL_KEY 1
#	define PPL_DGN 2
#	define PPL_MOD 3
#	define PPL_END 4

typedef struct {
		char		*cmd,
				*key,
				*dgn ;
		struct GRmd_env *mod ;
		void		*end ;
} pplargs ;
#endif      
