/*
Name
        popen, pclose

Description
        These functions are overrides of the default versions delivered with
        SGI/IRIX.  The default functions use fork/exec, which does not work
        under IRIX with an image the size of Model, since the memory demands
        of duplicating the process are too great.

        This popen function uses the pcreatel function to create the child
        process without incurring any extra virtual space penalty.  See
        pcreate(3C) for more details.

Algorithm        
        The popen call reformats the command to execute so that the command's
        stdin/stdout (depending on whether to popen call is for reading or
        writing) is redirected from/to a file.  If the request is for reading,
        then popen will wait for the process to complete before returning.
        This prevents the caller from reading before the child has written
        anything to the file.  The open file pointer is returned.

        The pclose call closes the file opened in by popen.  If the popen call
        was for writing, then pclose waits for the child to terminate before
        returning.  Pclose also cleans up all temporary files.  The return
        code from pclose is the same as that documented in the pclose man
        page, unless the child exited abnormally.  In that case, a 1 is
        returned.

Notes
        This code is depends on pcreate, which is an IRIX-specific function.
        The popen call seems to work fine on CLIX & Solaris.

        Unlike the default versions, these functions can only handle
        processing one popen/pclose pair at a time.  That should not be a
        problem, since none of the GRNUC/MODEL source code (at the time of the
        writing) uses more than one popen at a time.  If necessary, these
        functions could be extended to support more by using arrays of
        tmpfiles/pids/file pointers.  Popen returns a NULL file pointer if a
        popen/pclose is under way.  Note that things will go south fast if
        someone forgets to pclose after popening.

        Commands which attempt to redirect stdout are not handled, due to the
        algorithm described above.

        Using popen with "w" mode will not usually work, since the child
        process attempts to read the tmp file before the Model process writes
        anything to it.  This version of popen could perhaps be rewritten with
        sproc to look more like a legitimate popen, but EMS does not use popen
        with the "w" at the moment.

History
        mrm     12/29/93        creation
*/

#ifdef IRIX

#include <stdlib.h>
#include <stdio.h>
#include <sys/types.h>
#include <sys/param.h>
#include <sys/stat.h>
#include <sys/wait.h>

#if 0
#define VERBOSE(x) x
#else
#define VERBOSE(x)
#endif

static int pid, exit_status, popen_in_progress;
static char output[MAXPATHLEN], script[MAXPATHLEN];

FILE *popen(const char *command, const char *type)
{
    int sts;
    char *c;
    FILE *fp;
    struct stat statbuf;

    VERBOSE(printf("GRpopen\n"));

    /*
    ** Error checking
    */

    if (popen_in_progress)
        return(NULL);   /* can only handle one popen at a time */

    if (strstr(command, " >"))
        return(NULL);   /* stdout redirection must be controlled here */

    if (strcmp(type, "w") && strcmp(type, "r"))
        return(NULL);   /* only "r" & "w" are supported */

    if (strcmp(type, "w") == 0)
        fprintf(stderr, "\nWarning: popen(cmd, \"w\") is not fully supported by GRNUC.\n");

    /*
    ** Generate filenames to hold a script and process output
    */

    if (!(c = getenv("TMPDIR")) || stat(c, &statbuf) ||
        (strlen(c) > MAXPATHLEN - 12))
        c = "/var/tmp";
    sprintf(output, "%s/popenXXXXXX", c);
    mktemp(output);
    VERBOSE(printf("output = %s\n", output));
    sprintf(script, "%s/popen1XXXXXX", c);
    mktemp(script);
    VERBOSE(printf("script = %s\n", script));

    /*
    ** Format a new command line and dump it into a shell script.  This is
    ** easier then picking the command line apart just to feed to pcreate.
    ** The redirection is done up front in case a "2>&1" is buried in the
    ** command string.  Placing a ">/var/tmp/foo" after the "2>&1" will *not*
    ** redirect stderr into /var/tmp/foo.
    */

    fp = fopen(script, "w");
    fprintf(fp, "#!/bin/ksh\n");
    fprintf(fp, "%c%s %s\n",
            (type[0] == 'r') ? '>' : '<', output, command);
    fclose(fp);
    chmod(script, S_IRWXU | S_IRWXG | S_IRWXO); 
    VERBOSE(pcreatel("/sbin/cat", "cat", script, (char *)0));

    /*
    ** Create the new process
    */

    pid = pcreatel(script, script, (char *)0);
    popen_in_progress = 1;
    VERBOSE(printf("pid = %d\n", pid));

    /*
    ** If reading from the new process, wait on it to complete to make
    ** sure that the caller doesn't get ahead of the new process.
    */

    if (type[0] == 'r')
    {
        waitpid((pid_t)pid, &sts, 0);
        exit_status = (WIFEXITED(sts)) ? WEXITSTATUS(sts) : 1;
        pid = 0;        /* flag pclose that no waiting is necessary there */
    }

    /*
    ** Return a file pointer to the input/output file
    */

    return(fopen(output, type));
}

int pclose(FILE *stream)
{
    int sts;

    /* close the stream */

    fclose(stream);

    if (pid)
    {
        /* wait for the child to complete */
        waitpid((pid_t)pid, &sts, 0);
        exit_status = (WIFEXITED(sts)) ? WEXITSTATUS(sts) : 1;
        pid = 0;
    }

    /* misc cleanup */

    popen_in_progress = 0;
    unlink(output);
    unlink(script);

    /* shift exit code to look like the exit status from pclose */

    VERBOSE(printf("GRpclose: exit_status = %#x\n", exit_status));
    VERBOSE(printf("GRpclose: exit_status << 8 = %d\n", exit_status << 8));
    return(exit_status << 8);
}

#endif
