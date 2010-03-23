#include <stdio.h>

main ()
{
	int	count;
	double	sum, atof ();
	char	string[256];

	sum = 0.0;
	count = 0;
	gets (string);
	while (!feof (stdin))
	{
		sum += atof (string);
		count++;
		gets (string);
	}
	printf ("%f\n", sum / count);
}
