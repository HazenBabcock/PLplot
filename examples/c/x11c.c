/* Demonstration of mesh plotting (just like example08 but mesh) */
/* $Id$
   $Log$
   Revision 1.2  1992/09/29 04:45:19  furnish
   Massive clean up effort to remove support for garbage compilers (K&R).

 * Revision 1.1  1992/05/20  21:33:00  furnish
 * Initial checkin of the whole PLPLOT project.
 *
*/

/* Note the compiler should automatically convert all non-pointer arguments
   to satisfy the prototype, but some have problems with constants. */

#include "plplot.h"
#include <math.h>

#define   XPTS   35
#define   YPTS   46

static int opt[] = {1, 2, 3, 3};

static FLOAT alt[] = {60.0, 20.0, 60.0, 60.0};

static FLOAT az[] = {30.0, 60.0, 120.0, 160.0};

static char *title[4] = {
    "#frPLPLOT Example 11 - Alt=60, Az=30, Opt=1",
    "#frPLPLOT Example 11 - Alt=20, Az=60, Opt=2",
    "#frPLPLOT Example 11 - Alt=60, Az=120, Opt=3",
    "#frPLPLOT Example 11 - Alt=60, Az=160, Opt=3"
};

int 
main (void)
{
    int i, j, k;
    FLOAT *x, *y, **z;
    FLOAT xx, yy, r;
    char *malloc();

    x = (FLOAT *) malloc(XPTS * sizeof(FLOAT));
    y = (FLOAT *) malloc(YPTS * sizeof(FLOAT));
    z = (FLOAT **) malloc(XPTS * sizeof(FLOAT *));
    for (i = 0; i < XPTS; i++) {
	z[i] = (FLOAT *) malloc(YPTS * sizeof(FLOAT));
	x[i] = (double) (i - (XPTS / 2)) / (double) (XPTS / 2);
    }

    for (i = 0; i < YPTS; i++)
	y[i] = (double) (i - (YPTS / 2)) / (double) (YPTS / 2);

    for (i = 0; i < XPTS; i++) {
	xx = x[i];
	for (j = 0; j < YPTS; j++) {
	    yy = y[j];
	    z[i][j] = cos(2.0 * 3.141592654 *xx) * sin(2.0 * 3.141592654 *yy);
	}
    }

    plstar(1, 1);

    for (k = 0; k < 4; k++) {
	pladv(0);
	plcol(1);
	plvpor((PLFLT) 0.0, (PLFLT) 1.0, (PLFLT) 0.0, (PLFLT) 0.8);
	plwind(-1.0, 1.0, -1.0, 1.5);

	plw3d((PLFLT) 1.0, (PLFLT) 1.0, (PLFLT) 1.2, (PLFLT) -1.0, (PLFLT) 1.0, 
	      (PLFLT) -1.0, (PLFLT) 1.0, (PLFLT) -1.5, (PLFLT) 1.5, 
	      alt[k], az[k]);
	plbox3("bnstu", "x axis", (PLFLT) 0.0, 0, "bnstu", 
			"y axis", (PLFLT) 0.0, 0, "bcdmnstuv", 
			"z axis", (PLFLT) 0.0, 4);
	plcol(2);
	plmesh(x, y, z, XPTS, YPTS, opt[k]);
	plcol(3);
	plmtex("t", (PLFLT) 1.0, (PLFLT) 0.5, (PLFLT) 0.5, title[k]);
    }

    pltext();
    plend();
}
