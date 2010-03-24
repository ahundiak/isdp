#include <stdio.h>
#include <errno.h>
#include <sys/types.h>
#ifndef NT
#include <sys/ipc.h>
#include <sys/sem.h>
#endif
#include <signal.h>
#include <fcntl.h>
#include <stdlib.h>
#include "exsysdep.h"

#ifdef SUNOS
#include "OMminimum.h"
#endif
#include <exproto.h>

extern int EX_same_file;
extern int EX_help_proc_exist;
#ifndef NT
extern uint OM_Gf_mailbox;
#else
extern unsigned int OM_Gf_mailbox;
#endif

extern int EX_rm_msgque();

/* kernel has problem with signal handler in shared libraries */
/* so we created all the functions */

static int   (*oldhup)();
static int   (*oldint)();
static int   (*oldquit)();
static int   (*oldill)();
static int   (*oldiot)();
static int   (*oldemt)();
static int   (*oldfpe)();
static int   (*oldbus)();
static int   (*oldsegv)();
static int   (*oldsys)();
static int   (*oldpipe)();
static int   (*oldterm)();

static void reset_signal( int, int, void (*)(int) );
static void abort_process( int, int, int (*)() );

int EX_set_interrupt()
{
  void EX_interrupt_int();
  void EX_interrupt_ill();
  void EX_interrupt_fpe();
  void EX_interrupt_term();          
  void EX_interrupt_segv();      

#ifndef NT
  void EX_interrupt_pipe();          
  void EX_interrupt_sys();      
  void EX_interrupt_bus();
  void EX_interrupt_emt();  
  void EX_interrupt_iot();
  void EX_interrupt_quit();            
#endif
  void EX_interrupt_hup();      

  oldint = (int (*)()) signal(SIGINT,EX_interrupt_int);
  oldill = (int (*)()) signal(SIGILL,EX_interrupt_ill);
  oldfpe = (int (*)()) signal(SIGFPE,EX_interrupt_fpe);
  oldterm= (int (*)()) signal(SIGTERM,EX_interrupt_term);
  oldsegv= (int (*)()) signal(SIGSEGV,EX_interrupt_segv);
#ifndef NT
  oldpipe= (int (*)()) signal(SIGPIPE,EX_interrupt_pipe);
  oldsys = (int (*)()) signal(SIGSYS,EX_interrupt_sys);	
  oldbus = (int (*)()) signal(SIGBUS,EX_interrupt_bus);
  oldemt = (int (*)()) signal(SIGEMT,EX_interrupt_emt);
  oldiot = (int (*)()) signal(SIGIOT,EX_interrupt_iot);
  oldquit= (int (*)()) signal(SIGQUIT,EX_interrupt_quit);      
#else
  oldpipe= (int (*)()) SIG_IGN;
  oldsys = (int (*)()) SIG_IGN;
  oldbus = (int (*)()) SIG_IGN;
  oldemt = (int (*)()) SIG_IGN;
  oldiot = (int (*)()) SIG_IGN;
  oldquit= (int (*)()) SIG_IGN;
#endif

  return(1);
}

void EX_interrupt_hup(signo)
int signo;
{
   printf("--Hangup\n");
   fflush(stdout);

   abort_process( 1, signo, oldhup );
}

void EX_interrupt_int(signo)
int signo;
{
   printf("--Control C Interrupt\n");
   fflush(stdout);

   abort_process( 0, signo, oldint );
}

void EX_interrupt_quit(signo)
int signo;
{
   printf("--Quit\n");
   fflush(stdout);

   abort_process( 0, signo, oldquit );
}

#ifndef NT
void EX_interrupt_sys(signo)
int signo;
{
   printf("--Bad Argument to System Call.\n");
   fflush(stdout);

   if ( EX_is_auto_jump() )
   {
       reset_signal( signo, SIGSYS, EX_interrupt_sys );
   } 
   else
   {
       abort_process( 1, signo, oldsys );
   }
}

void EX_interrupt_pipe(signo)
int signo;
{
   printf("--SIGPIPE.\n");
   fflush(stdout);

   if ( EX_is_auto_jump() )
   {
       reset_signal( signo, SIGPIPE, EX_interrupt_pipe );
   } 
   else
   {
       EX_close_rec_echo(0);
       printf("--Write on a pipe with no one to read it\n");
       if ( (oldpipe != (int (*)())SIG_IGN) &&
            (oldpipe != (int (*)())SIG_DFL) )
         oldpipe(signo);
   }
}

void EX_interrupt_bus(signo)
int signo;
{
   printf("--Bus Error\n");
   fflush(stdout);

   if ( EX_is_auto_jump() )
   {
       reset_signal( signo, SIGBUS, EX_interrupt_bus );
   } 
   else
   {
       abort_process( 1, signo, oldbus );
   }
}

void EX_interrupt_iot(signo)
int signo;
{
   printf("--I/O Trap Instruction\n");
   fflush(stdout);

   if ( EX_is_auto_jump() )
   {
       reset_signal( signo, SIGIOT, EX_interrupt_iot );
   } 
   else
   {
       abort_process( 1, signo, oldiot );
   }
}

void EX_interrupt_emt(signo)
int signo;
{
   printf("--Emulator Trap Instruction. Implementation-dep hardware fault.\n");
   fflush(stdout);

   if ( EX_is_auto_jump() )
   {
       reset_signal( signo, SIGEMT, EX_interrupt_emt );
   } 
   else
   {
       abort_process( 1, signo, oldemt );
   }
}
#endif

void EX_interrupt_fpe(signo)
int signo;
{
   printf("--Floating Point Exception\n");
   fflush(stdout);

   if ( EX_is_auto_jump() )
   {
       reset_signal( signo, SIGFPE, EX_interrupt_fpe );
   } 
   else
   {
       abort_process( 1, signo, oldfpe );
   }
}

void EX_interrupt_ill(signo)
int signo;
{
   printf("--Illegal Instruction\n");
   fflush(stdout);

   if ( EX_is_auto_jump() )
   {
       reset_signal( signo, SIGILL, EX_interrupt_ill );
   } 
   else
   {
       abort_process( 1, signo, oldill );
   }
}

void EX_interrupt_segv(signo)
int signo;
{
   printf("--Memory Fault. Segmentation Violation.\n");
   fflush(stdout);

   if ( EX_is_auto_jump() )
   {
       reset_signal( signo, SIGSEGV, EX_interrupt_segv );
   } 
   else
   {
       abort_process( 1, signo, oldsegv );
   }
}


void EX_interrupt_term(signo)
int signo;
{
   printf("--Software Termination.\n");
   fflush(stdout);

   abort_process( 1, signo, oldterm );
}

static void reset_signal( int oldsig, int newsig, void (*newhandler)(int) )
{
  signal( newsig, newhandler );
  EX_auto_test_print_err( oldsig ); 
#ifndef NT
  sigrelse( oldsig );
#endif
  EX_jump();

  return;
}

static void abort_process( int closerc, int signo, int (*oldhandler)() )
{
  if ( closerc )
    EX_close_rec_echo( 0 );

  if ( OM_Gf_mailbox )
    EX_rm_msgque();

  if ( (oldhandler != (int (*)())SIG_IGN) &&
       (oldhandler != (int (*)())SIG_DFL) )
    oldhandler( signo );

#ifndef NT
  if ( EX_help_proc_exist == 1 )
    Help_kill();
#endif

  exit( signo );
}
