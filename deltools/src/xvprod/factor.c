#include <stdio.h>
#include "infp.h"
#include "main.h"

extern	infp factor();
extern	infp oper();

#define MAX_PRIME	1000
static int *primes = (int *) 0;	/* holds primes between 1 and MAX_PRIME */

char	*factorize(prod)
    infp *prod;
{
    int  prime, count;
    infp infpPrime;
    infp divResult, check, one;
    char pass[MAXLINE], c[2];

    pass[0] = '\0';

    if(!primes)
	getPrimes();

    infpInit(&infpPrime, 0);
    infpInit(&divResult, 0);
    infpInit(&one, 1);
    infpInit(&check, 0);

    for(prime=0; primes[prime]; ++prime) {
	if(infpCmp(prod, &one) == 0)
	    break;

	infpSet(&infpPrime, primes[prime]);
	for(count=0; ; ++count) {
	    if(infpDivFunc(&divResult, prod, &infpPrime))
		break;
	    ++count;
	    if(infpDivFunc(prod, &divResult, &infpPrime)) {
		infpCopy(&divResult, prod);
		break;
	    }
	}
	sprintf(c, "%c", count+ ' ' - 1); 
	strcat(pass, c);
    }

    if(primes[prime] == 0)
	printf("Ran out of primes\n");

    return(pass);
}


/* Use sieve of Erstosthenes to generate first MAX_PRIME primes */

getPrimes()
{
    int i, mult, count;
    char numbers[MAX_PRIME];

    for(i=0; i<MAX_PRIME; ++i)
	numbers[i] = 1;

	/* Remove all numbers which are multiples of other numbers */
    for(i=2; i<MAX_PRIME; ++i) {
	for(mult=i+i; mult<MAX_PRIME; mult+=i)
	    numbers[mult] = 0;
    }

	/* count remaining primes */
    count = 0;
    for(i=2; i<MAX_PRIME; ++i)
	if(numbers[i])
	    ++count;

    primes = (int *) malloc((count + 1) * sizeof(int));

    count = 0;
    for(i=2; i<MAX_PRIME; ++i)
	if(numbers[i])
	    primes[count++] = i;

	/* put a flag of 0 at the end */
    primes[count] = 0;
}
