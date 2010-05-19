#include <stdio.h>
#include "lib.h"

extern FILE                      *outfp;
extern struct source_group_node  *srcfiles;
extern struct dtree_node	 *ccfilter;
extern char			 whyFlag;

char	*ccdef = "$(CC) $(COPT) $(IPATH) $(IPATH1) $(IPATH2) $(MOPT) $(DOPT) $(DOPT1) $(DOPT2)";
char	*oppdef = "$(opp) $(OPPOPT) $(OPPFLAGS) $(DOPT) $(DOPT1) $(DOPT2)";
char	*omcppdef = "$(omcpp) $(OMCPPOPT) $(OPPFLAGS) $(DOPT) $(DOPT1) $(DOPT2)";

#if defined(CLIX) || defined(SUNOS) || defined(IRIX)
#define cNameFromObjName	"$(SRC)/$(@:.o=.c)"
#define cToObjActionFormat	"%s -c $(SRC)/$(@:.o=.c)%s"

#define asmNameFromObjName	"$(SRC)/$(@:.o=.s)"
#if defined(CLIX)
#define asmToObjActionFormat	"as $(ASOPT) $(SRC)/$(@:.o=.s)"
#elif defined(SUNOS) || defined(IRIX)
#define asmToObjActionFormat	"as $(ASOPT) -o $(@F) $(SRC)/$(@:.o=.s)"
#endif

#define SNameFromObjName	"$(@:.o=.S)"
#define INameFromObjName	"$(@:.o=.I)"
#define CNameFromObjName	"$(SRC)/$(@:.o=.C)"
#define OmcppOutFileName	"$(@:.o=.c)"
#define OmcppOutExtension	".c"

#define IToObjTransition	".I.o"
#define SToObjTransition	".S.o"

#elif defined(NT)
#define cNameFromObjName	"$(SRC)\\$(@:.obj=.c)"
#define cToObjActionFormat	"%s -c $(SRC)\\$(@:.obj=.c)%s"

#define asmNameFromObjName	"$(SRC)\\$(@:.obj=.s)"
#define asmToObjActionFormat	"$(CC) $(ASOPT) -c $(SRC)\\$(@:.obj=.asm)"

#define SNameFromObjName	"$(@:.obj=.S)"
#define INameFromObjName	"$(@:.obj=.I)"
#define CNameFromObjName	"$(SRC)\\$(@:.obj=.C)"
#define OmcppOutFileName	"$(@:.obj=.i)"
#define OmcppOutExtension	".i"

#define IToObjTransition	".I.obj"
#define SToObjTransition	".S.obj"

#else
#error Unknown OS
#endif

static void	write_why(char *who)
{
      if (!whyFlag)
         return;      /* Users can turn off this feature altogether */
#if defined(SYSV) || defined(BSD)
	fprintf(outfp, "\t@if [ \"$(WHY)\" ]; then echo \"\\t%s: $?\"; fi\n", who);
#elif defined(NT)
	fprintf(outfp, "\t@if not \"$(WHY)\" == \"\" $(ECHO) \"\\\\t%s: $?\"\n", who);
#else
#error Unknown OS
#endif
}

static void	write_transition(char *from, char *to)
{
#if defined(CLIX) || defined(SUNOS) || defined(IRIX)
	fprintf(outfp, "\t@if [ -z \"$(VERBOSE_RULES)\" ]; \\\n");
	fprintf(outfp, "\t then \\\n");
	fprintf(outfp, "\t     echo \"\\t%s -> %s\"; \\\n", from, to);
	fprintf(outfp, "\t fi\n");
#elif defined(NT)
	fprintf(outfp, "\t@if \"$(VERBOSE_RULES)\" == \"\" $(ECHO) \"\\\\t%s -> %s\"\n", from, to);
#else
#error Unknown OS
#endif
}

static void	write_change_dir(void)
{
#if defined(CLIX) || defined(SUNOS) || defined(IRIX)
      fprintf(outfp, "\t@if [ -n \"$(@D)\" -a \"$(@D)\" != \".\" ]; \\\n");
      fprintf(outfp, "\t then \\\n");
      fprintf(outfp, "\t     if [ -n \"$(VERBOSE_RULES)\" ]; \\\n");
      fprintf(outfp, "\t     then \\\n");
      fprintf(outfp, "\t         echo \"\\tcd $(@D)\"; \\\n");
      fprintf(outfp, "\t     fi; \\\n");
      fprintf(outfp, "\t     cd $(@D); \\\n");
      fprintf(outfp, "\t fi; \\\n");
#elif defined(NT)
      fprintf(outfp, "\t@if not \"$(@D)\" == \"\" if not \"$(@D)\" == \".\" if not \"$(VERBOSE_RULES)\" == \"\" $(ECHO) \"\\\\tcd $(@D)\"\n");
      fprintf(outfp, "\t@if not \"$(@D)\" == \"\" if not \"$(@D)\" == \".\" cd $(@D)\n");
#else
#error Unknown OS
#endif
}

static void	write_dependency_action(char *action_format, char *arg1, char *arg2)
{
#if defined(CLIX) || defined(SUNOS) || defined(IRIX)
      fprintf(outfp, "\t if [ -n \"$(VERBOSE_RULES)\" ]; \\\n");
      fprintf(outfp, "\t then \\\n");
      fprintf(outfp, "\t     echo \"\\t");
      fprintf(outfp, action_format, arg1, arg2);
      fprintf(outfp, "\"; \\\n");
      fprintf(outfp, "\t fi; \\\n");
      fprintf(outfp, "\t ");
      fprintf(outfp, action_format, arg1, arg2);
      fprintf(outfp, "\n");
      fprintf(outfp, "\t@echo \n\n");
#elif defined(NT)
      fprintf(outfp, "\t@if not \"$(VERBOSE_RULES)\" == \"\" $(ECHO) \"\\\\t");
      fprintf(outfp, action_format, arg1, arg2);
      fprintf(outfp, "\"\n");
      fprintf(outfp, "\t@");
      fprintf(outfp, action_format, arg1, arg2);
      fprintf(outfp, "\n");
      fprintf(outfp, "\t@$(ECHO) \n\n");
#else
#error Unknown OS
#endif
}

static void	write_dependency_file_cleanup(char *extension)
{
#if defined(CLIX) || defined(SUNOS) || defined(IRIX)
      fprintf(outfp, "\t     if [ \"$(COPT)\" != \"-g\" -a \"$(DEBUG)\" != \"yes\" ]; \\\n");
      fprintf(outfp, "\t     then \\\n");
      fprintf(outfp, "\t         if [ -z \"$(VERBOSE_RULES)\" ]; \\\n");
      fprintf(outfp, "\t         then \\\n");
      fprintf(outfp, "\t             echo \"\\tremoving $(@:.o=%s)\"; \\\n", extension);
      fprintf(outfp, "\t         else \\\n");
      fprintf(outfp, "\t             echo \"\\trm $(@F:.o=%s)\"; \\\n", extension);
      fprintf(outfp, "\t         fi; \\\n");
      fprintf(outfp, "\t         rm $(@F:.o=%s); \\\n", extension);
      fprintf(outfp, "\t     else \\\n");
      fprintf(outfp, "\t         if [ -z \"$(VERBOSE_RULES)\" ]; \\\n");
      fprintf(outfp, "\t         then \\\n");
      fprintf(outfp, "\t             echo \"\\tleaving $(@:.o=%s)\"; \\\n", extension);
      fprintf(outfp, "\t         fi; \\\n");
      fprintf(outfp, "\t     fi; \\\n");
#elif defined(NT)
      fprintf(outfp, "\t@if \"$(DEBUGAMOUNT)\" == \"\" if \"$(VERBOSE_RULES)\" == \"\" $(ECHO) \"\\\\tremoving $(@:.obj=%s)\"\n", extension);
      fprintf(outfp, "\t@if \"$(DEBUGAMOUNT)\" == \"\" if not \"$(VERBOSE_RULES)\" == \"\" $(ECHO) \"\\\\tdel/q $(@F:.obj=%s)\"\n", extension);
      fprintf(outfp, "\t@if \"$(DEBUGAMOUNT)\" == \"\" del/q $(@F:.obj=%s)\n", extension);
      fprintf(outfp, "\t@if not \"$(DEBUGAMOUNT)\" == \"\" if \"$(VERBOSE_RULES)\" == \"\" $(ECHO) \"\\\\tleaving $(@:.obj=%s)\"\n", extension);
#else
#error Unknown OS
#endif
}

static void	write_opp_dependency_action(char *from, char *filter)
{
#if defined(CLIX) || defined(SUNOS) || defined(IRIX)
      fprintf(outfp, "\t if [ \"$(FAST)\" ]; \\\n");
      fprintf(outfp, "\t then \\\n");
      fprintf(outfp, "\t     if [ -f $(@) ]; then rm $(@); fi; \\\n");
      fprintf(outfp, "\t     echo \"\\t%s -> opp.list\\c\"; \\\n", from);
      fprintf(outfp, "\t     echo \"%s\" >>opp.list; \\\n", from);
      fprintf(outfp, "\t else \\\n");
      fprintf(outfp, "\t     if [ -z \"$(VERBOSE_RULES)\" ]; \\\n");
      fprintf(outfp, "\t     then \\\n");
      fprintf(outfp, "\t         echo \"\\t$(SRC)/%s -> $(@:.o=.c)\"; \\\n", from);
      fprintf(outfp, "\t     fi; \\\n");
      fprintf(outfp, "\t     if [ -n \"$(VERBOSE_RULES)\" ]; \\\n");
      fprintf(outfp, "\t     then \\\n");
      fprintf(outfp, "\t         echo \"\\t%s %s\"; \\\n", oppdef, from);
      fprintf(outfp, "\t     fi; \\\n");
      fprintf(outfp, "\t     %s %s; \\\n", oppdef, from);
      fprintf(outfp, "\t     if [ -z \"$(VERBOSE_RULES)\" ]; \\\n");
      fprintf(outfp, "\t     then \\\n");
      fprintf(outfp, "\t         echo \"\\t$(@:.o=.c) -> $(@)\"; \\\n");
      fprintf(outfp, "\t     else \\\n");
      fprintf(outfp, "\t         echo \"\\t%s -c $(@F:.o=.c)%s\"; \\\n", ccdef, filter);
      fprintf(outfp, "\t     fi; \\\n");
      fprintf(outfp, "\t     %s -c $(@F:.o=.c)%s; \\\n", ccdef, filter);
      write_dependency_file_cleanup(".c");
      fprintf(outfp, "\t fi\n");
      fprintf(outfp, "\t@echo \n\n");
#elif defined(NT)
      fprintf(outfp, "\t@if \"$(VERBOSE_RULES)\" == \"\" $(ECHO) \"\\\\t$(SRC)\\%s -> $(@:.obj=.c)\"\n", from);
      fprintf(outfp, "\t@if not \"$(VERBOSE_RULES)\" == \"\" $(ECHO) \"\\\\t%s %s\"\n", oppdef, from);
      fprintf(outfp, "\t@%s %s\n", oppdef, from);
      fprintf(outfp, "\t@if \"$(VERBOSE_RULES)\" == \"\" $(ECHO) \"\\\\t$(@:.obj=.c) -> $(@)\"\n");
      fprintf(outfp, "\t@if not \"$(VERBOSE_RULES)\" == \"\" $(ECHO) \"\\\\t%s -c $(@F:.obj=.c)%s\"\n", ccdef, filter);
      fprintf(outfp, "\t@%s -c $(@F:.obj=.c)%s\n", ccdef, filter);
      write_dependency_file_cleanup(".c");
      fprintf(outfp, "\t@$(ECHO) \n\n");
#else
#error Unknown OS
#endif
}

static void	write_inference_rule_file_cleanup(char *extension)
{
#if defined(CLIX) || defined(SUNOS) || defined(IRIX)
      fprintf(outfp, "\t     if [ \"$(COPT)\" != \"-g\" -a \"$(DEBUG)\" != \"yes\" ]; \\\n");
      fprintf(outfp, "\t     then \\\n");
      fprintf(outfp, "\t        if [ -z \"$(VERBOSE_RULES)\" ]; \\\n");
      fprintf(outfp, "\t        then \\\n");
      fprintf(outfp, "\t            echo \"\\tremoving $*%s\"; \\\n", extension);
      fprintf(outfp, "\t        else \\\n");
      fprintf(outfp, "\t            echo \"\\trm $*%s\"; \\\n", extension);
      fprintf(outfp, "\t        fi; \\\n");
      fprintf(outfp, "\t        rm $*%s; \\\n", extension);
      fprintf(outfp, "\t     else \\\n");
      fprintf(outfp, "\t        if [ -z \"$(VERBOSE_RULES)\" ]; \\\n");
      fprintf(outfp, "\t        then \\\n");
      fprintf(outfp, "\t            echo \"\\tleaving $*%s\"; \\\n", extension);
      fprintf(outfp, "\t        fi; \\\n");
      fprintf(outfp, "\t     fi; \\\n");
#elif defined(NT)
      fprintf(outfp, "\t@if \"$(DEBUGAMOUNT)\" == \"\" if \"$(VERBOSE_RULES)\" == \"\" $(ECHO) \"\\\\tremoving $*%s\"\n", extension);
      fprintf(outfp, "\t@if \"$(DEBUGAMOUNT)\" == \"\" if not \"$(VERBOSE_RULES)\" == \"\" $(ECHO) \"\\\\tdel/q $*%s\"\n", extension);
      fprintf(outfp, "\t@if \"$(DEBUGAMOUNT)\" == \"\" del/q $*%s\n", extension);
      fprintf(outfp, "\t@if not \"$(DEBUGAMOUNT)\" == \"\" if \"$(VERBOSE_RULES)\" == \"\" $(ECHO) \"\\\\tleaving $*%s\"\n", extension);
#else
#error Unknown OS
#endif
}

void write_opp_inference_rule(char *transition, char *filter)
{
      fprintf(outfp, "%s:\n", transition);
      write_why("$<");
#if defined(CLIX) || defined(SUNOS) || defined(IRIX)
      fprintf(outfp, "\t@if [ \"$(FAST)\" ]; \\\n");
      fprintf(outfp, "\t then \\\n");
      fprintf(outfp, "\t     if [ -f $(@) ]; then rm $(@); fi; \\\n");
      fprintf(outfp, "\t     echo \"\\t$< -> opp.list\\c\"; \\\n");
      fprintf(outfp, "\t     echo \"$<\" >>opp.list; \\\n");
      fprintf(outfp, "\t else \\\n");
      fprintf(outfp, "\t     if [ -z \"$(VERBOSE_RULES)\" ]; \\\n");
      fprintf(outfp, "\t     then \\\n");
      fprintf(outfp, "\t         echo \"\\t$< -> $*.c\"; \\\n");
      fprintf(outfp, "\t     else \\\n");
      fprintf(outfp, "\t         echo \"\\t%s $<\"; \\\n", oppdef);
      fprintf(outfp, "\t     fi; \\\n");
      fprintf(outfp, "\t     %s $<; \\\n", oppdef);
      fprintf(outfp, "\t     if [ -z \"$(VERBOSE_RULES)\" ]; \\\n");
      fprintf(outfp, "\t     then \\\n");
      fprintf(outfp, "\t         echo \"\\t$*.c -> $*.o\"; \\\n");
      fprintf(outfp, "\t     else \\\n");
      fprintf(outfp, "\t         echo \"\\t%s -c $*.c%s\"; \\\n", ccdef, filter);
      fprintf(outfp, "\t     fi; \\\n");
      fprintf(outfp, "\t     %s -c $*.c%s;  \\\n", ccdef, filter);
      write_inference_rule_file_cleanup(".c");
      fprintf(outfp, "\t fi\n");
      fprintf(outfp, "\t@echo \n\n");
#elif defined(NT)
      fprintf(outfp, "\t@if \"$(VERBOSE_RULES)\" == \"\" $(ECHO) \"\\\\t$< -> $*.c\"\n");
      fprintf(outfp, "\t@if not \"$(VERBOSE_RULES)\" == \"\" $(ECHO) \"\\\\t%s $<\"\n", oppdef);
      fprintf(outfp, "\t@%s $<\n", oppdef);
      fprintf(outfp, "\t@if \"$(VERBOSE_RULES)\" == \"\" $(ECHO) \"\\\\t$*.c -> $*.o\"\n");
      fprintf(outfp, "\t@if \"$(VERBOSE_RULES)\" == \"\" $(ECHO) \"\\\\t%s -c $*.c%s\"\n", ccdef, filter);
      fprintf(outfp, "\t@%s -c $*.c%s\n", ccdef, filter);
      write_inference_rule_file_cleanup(".c");
      fprintf(outfp, "\t@$(ECHO) \n\n");
#else
#error Unknown OS
#endif
}

void write_rules ()
{
   struct source_group_node   *s;
   char                       *filter = ccfilter ? " $(CCFILTER)" : "";

	/*
	*	Write dependencies with actions for all source groups.
	*	These are used instead of the transition rules when the
	*	source file and object file are in different directories.
	*	A separate dependency action is generated for each source group
	*	to prevent a "too many lefts" error from make(1).
	*/

   if ( src_flags.c )
   {
      s = srcfiles;
      while (s)
      {
         if( s->c_list )
         {
            fprintf(outfp, "$(c_%s):\n", s->sgrp_name);
            write_why("$(@)");
            write_transition(cNameFromObjName, "$(@)");
            write_change_dir();
            write_dependency_action(cToObjActionFormat, ccdef, filter);
         }
         s = s->next;
      }
   }

   if ( src_flags.assm )
   {
      s = srcfiles;
      while (s)
      {
         if( s->assm_list )
         {
            fprintf(outfp, "$(assm_%s):\n", s->sgrp_name);
            write_why("$(@)");
            write_transition(asmNameFromObjName, "$(@)");
            write_change_dir();
            write_dependency_action(asmToObjActionFormat, 0, 0);
         }
         s = s->next;
      }
   }

   if ( src_flags.spec )
   {
      s = srcfiles;
      while (s)
      {
         if( s->spec_list )
         {
            fprintf(outfp, "$(spec_%s):\n", s->sgrp_name);
            write_why("$(@)");
            write_change_dir();
            write_opp_dependency_action(SNameFromObjName, filter);
         }
         s = s->next;
      }
   }

   if ( src_flags.imp )
   {
      s = srcfiles;
      while (s)
      {
         if( s->imp_list )
         {
            fprintf(outfp, "$(imp_%s):\n", s->sgrp_name);
            write_why("$(@)");
            write_change_dir();
            write_opp_dependency_action(INameFromObjName, filter);
         }
         s = s->next;
      }
   }

   if ( src_flags.C )
   {
      s = srcfiles;
      while (s)
      {
 	 if( s->C_list )
         {
            fprintf(outfp, "$(C_%s):\n", s->sgrp_name);
            write_why("$(@)");
            write_transition(CNameFromObjName, OmcppOutFileName);
            write_change_dir();
#if defined(CLIX) || defined(SUNOS) || defined(IRIX)
            fprintf(outfp, "\t if [ -n \"$(VERBOSE_RULES)\" ]; \\\n");
            fprintf(outfp, "\t then \\\n");
            fprintf(outfp, "\t      echo \"\\t%s $(SRC)/$(@:.o=.C) $(@F:.o=.c)\"; \\\n", omcppdef);
            fprintf(outfp, "\t fi; \\\n");
            fprintf(outfp, "\t %s \\\n\t\t$(SRC)/$(@:.o=.C) $(@F:.o=.c); \\\n", omcppdef);
            fprintf(outfp, "\t if [ \"$(FAST)\" ]; \\\n");
            fprintf(outfp, "\t then \\\n");
            fprintf(outfp, "\t     if [ -f $(@) ]; then rm $(@); fi; \\\n");
            fprintf(outfp, "\t     if [ -z \"$(VERBOSE_RULES)\" ]; \\\n");
            fprintf(outfp, "\t     then \\\n");
            fprintf(outfp, "\t        echo \"\\t$(@:.o=.c) -> cc.list\\c\"; \\\n");
            fprintf(outfp, "\t     else \\\n");
            fprintf(outfp, "\t        echo \"\\techo \\\"$(@:.o=.c)\\\" >>cc.list\"; \\\n");
            fprintf(outfp, "\t     fi; \\\n");
            fprintf(outfp, "\t     echo \"$(@:.o=.c)\" >>cc.list; \\\n");
            fprintf(outfp, "\t else \\\n");
            fprintf(outfp, "\t     if [ -z \"$(VERBOSE_RULES)\" ]; \\\n");
            fprintf(outfp, "\t     then \\\n");
            fprintf(outfp, "\t         echo \"\\t$(@:.o=.c) -> $(@)\"; \\\n");
            fprintf(outfp, "\t     else \\\n");
            fprintf(outfp, "\t         echo \"\\t%s -c $(@F:.o=.c)%s\"; \\\n", ccdef, filter);
            fprintf(outfp, "\t     fi; \\\n");
            fprintf(outfp, "\t     %s -c $(@F:.o=.c)%s; \\\n", ccdef, filter);
            write_dependency_file_cleanup(OmcppOutExtension);
            fprintf(outfp, "\t fi\n");
            fprintf(outfp, "\t@echo \n\n");
#elif defined(NT)
            fprintf(outfp, "\t@if not \"$(VERBOSE_RULES)\" == \"\" $(ECHO) \"\\\\t%s $(SRC)\\$(@:.obj=.C) $(@F:.obj=.i)\"\n", omcppdef);
            fprintf(outfp, "\t@%s \\\n\t\t$(SRC)\\$(@:.obj=.C) $(@F:.obj=.i)\n", omcppdef);
            fprintf(outfp, "\t@if \"$(VERBOSE_RULES)\" == \"\" $(ECHO) \"\\\\t$(@:.obj=.i) -> $(@)\"\n");
            fprintf(outfp, "\t@if not \"$(VERBOSE_RULES)\" == \"\" $(ECHO) \"\\\\t%s -c -Tc $(@F:.obj=.i)%s\"\n", ccdef, filter);
            fprintf(outfp, "\t@%s -c -Tc $(@F:.obj=.i)%s\n", ccdef, filter);
            write_dependency_file_cleanup(OmcppOutExtension);
            fprintf(outfp, "\t@$(ECHO) \n\n");
#else
#error Unknown OS
#endif
         }
         s = s->next;
      }
   }

	/*
	*	These are the inference rules.  They are used when source
	*	and object file are in the same directory.
	*/

   if ( src_flags.imp )
      write_opp_inference_rule(IToObjTransition, filter);

   if ( src_flags.C )
   {
#if defined(CLIX) || defined(SUNOS) || defined(IRIX)
      fprintf(outfp, ".C.o:\n");
      write_why("$<");
      fprintf(outfp, "\t@if [ -z \"$(VERBOSE_RULES)\" ]; \\\n");
      fprintf(outfp, "\t then \\\n");
      fprintf(outfp, "\t     echo \"\\t$< -> $*.c\"; \\\n");
      fprintf(outfp, "\t else \\\n");
      fprintf(outfp, "\t     echo \"\\t%s $< $*.c\"; \\\n", omcppdef);
      fprintf(outfp, "\t fi\n");
      fprintf(outfp, "\t@%s $< $*.c\n", omcppdef);
      fprintf(outfp, "\t@if [ \"$(FAST)\" ]; \\\n");
      fprintf(outfp, "\t then \\\n");
      fprintf(outfp, "\t     if [ -f $(@) ]; then rm $(@); fi; \\\n");
      fprintf(outfp, "\t     if [ -z \"$(VERBOSE_RULES)\" ]; \\\n");
      fprintf(outfp, "\t     then \\\n");
      fprintf(outfp, "\t         echo \"\\t$*.c -> cc.list\\c\"; \\\n");
      fprintf(outfp, "\t     else \\\n");
      fprintf(outfp, "\t         echo \"\\techo \\\"$*.c\\\" >>cc.list\"; \\\n");
      fprintf(outfp, "\t     fi; \\\n");
      fprintf(outfp, "\t     echo \"$*.c\" >>cc.list; \\\n");
      fprintf(outfp, "\t else \\\n");
      fprintf(outfp, "\t     if [ -z \"$(VERBOSE_RULES)\" ]; \\\n");
      fprintf(outfp, "\t     then \\\n");
      fprintf(outfp, "\t         echo \"\\t$*.c -> $*.o\"; \\\n");
      fprintf(outfp, "\t     else \\\n");
      fprintf(outfp, "\t         echo \"\\t%s -c $*.c%s\"; \\\n", ccdef, filter);
      fprintf(outfp, "\t     fi; \\\n");
      fprintf(outfp, "\t     %s -c $*.c%s; \\\n", ccdef, filter);
      write_inference_rule_file_cleanup(OmcppOutExtension);
      fprintf(outfp, "\t fi\n");
      fprintf(outfp, "\t@echo \n\n");
#elif defined(NT)
      fprintf(outfp, ".C.obj:\n");
      write_why("$<");
      fprintf(outfp, "\t@if \"$(VERBOSE_RULES)\" == \"\" $(ECHO) \"\\\\t$< -> $*.c\"\n");
      fprintf(outfp, "\t@if not \"$(VERBOSE_RULES)\" == \"\" $(ECHO) \"\\\\t%s $< $*.c\"\n", omcppdef);
      fprintf(outfp, "\t@%s $< $*.c\n", omcppdef);
      fprintf(outfp, "\t@if \"$(VERBOSE_RULES)\" == \"\" $(ECHO) \"\\\\t$*.c -> $*.o\"\n");
      fprintf(outfp, "\t@if not \"$(VERBOSE_RULES)\" == \"\" $(ECHO) \"\\\\t%s -c $*.c%s\"\n", ccdef, filter);
      fprintf(outfp, "\t@%s -c $*.c%s\n", ccdef, filter);
      write_inference_rule_file_cleanup(OmcppOutExtension);
      fprintf(outfp, "\t@$(ECHO) \n\n");
#else
#error Unknown OS
#endif
   }

   if ( src_flags.spec )
      write_opp_inference_rule(SToObjTransition, filter);

#if defined(CLIX) || defined(SUNOS) || defined(IRIX)
   fprintf(outfp, ".c.o:\n");
   write_why("$<");
   fprintf(outfp, "\t@if [ -z \"$(VERBOSE_RULES)\" ]; \\\n");
   fprintf(outfp, "\t then \\\n");
   fprintf(outfp, "\t     echo \"\\t$< -> $*.o\"; \\\n");
   fprintf(outfp, "\t else \\\n");
   fprintf(outfp, "\t     echo \"\\t%s -c $*.c%s\"; \\\n", ccdef, filter);
   fprintf(outfp, "\t fi\n");
   fprintf(outfp, "\t@%s -c $*.c%s\n", ccdef, filter);
   fprintf(outfp, "\t@echo \n\n");
#elif defined(NT)
   fprintf(outfp, ".c.obj:\n");
   write_why("$<");
   fprintf(outfp, "\t@if \"$(VERBOSE_RULES)\" == \"\" $(ECHO) \"\\\\t$< -> $*.obj\"\n");
   fprintf(outfp, "\t@if not \"$(VERBOSE_RULES)\" == \"\" $(ECHO) \"\\\\t%s -c $*.c%s\"\n", ccdef, filter);
   fprintf(outfp, "\t@%s -c $*.c%s\n", ccdef, filter);
   fprintf(outfp, "\t@$(ECHO) \n\n");
#else
#error Unknown OS
#endif
}
