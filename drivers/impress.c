/* $Id$
   $Log$
   Revision 1.13  1993/07/31 07:56:33  mjl
   Several driver functions consolidated, for all drivers.  The width and color
   commands are now part of a more general "state" command.  The text and
   graph commands used for switching between modes is now handled by the
   escape function (very few drivers require it).  The device-specific PLDev
   structure is now malloc'ed for each driver that requires it, and freed when
   the stream is terminated.

 * Revision 1.12  1993/07/28  05:35:50  mjl
 * Fixed a cast in argument to free().
 *
 * Revision 1.11  1993/07/16  22:11:18  mjl
 * Eliminated low-level coordinate scaling; now done by driver interface.
 *
 * Revision 1.10  1993/07/01  21:59:36  mjl
 * Changed all plplot source files to include plplotP.h (private) rather than
 * plplot.h.  Rationalized namespace -- all externally-visible plplot functions
 * now start with "pl"; device driver functions start with "plD_".
*/

/*	impress.c

	PLPLOT ImPress device driver.
*/
#ifdef IMP

#define PL_NEED_MALLOC
#include "plplotP.h"
#include <stdio.h>
#include <stdlib.h>
#include "drivers.h"

/* Function prototypes */

static void flushline(PLStream *);

/* top level declarations */

#define IMPX		2999
#define IMPY		2249

#define BUFFPTS		50
#define BUFFLENG	2*BUFFPTS

/* Graphics control characters. */

#define SET_HV_SYSTEM	0315
#define OPBYTE1		031
#define OPBYTE2		0140
#define SET_ABS_H	0207
#define SET_ABS_V	0211
#define OPWORDH1	0
#define OPWORDH2	150
#define OPWORDV1	0
#define OPWORDV2	150
#define ENDPAGE		0333

#define SET_PEN		0350
#define CREATE_PATH	0346
#define DRAW_PATH	0352
#define OPTYPE		017

static short *LineBuff;
static short FirstLine;
static int penchange = 0, penwidth;
static short count;

/*----------------------------------------------------------------------*\
* plD_init_imp()
*
* Initialize device (terminal).
\*----------------------------------------------------------------------*/

void
plD_init_imp(PLStream *pls)
{
    PLDev *dev;

    pls->termin = 0;		/* not an interactive terminal */
    pls->icol0 = 1;
    pls->color = 0;
    pls->width = 1;
    pls->bytecnt = 0;
    pls->page = 0;

/* Initialize family file info */

    plFamInit(pls);

/* Prompt for a file name if not already set */

    plOpenFile(pls);

/* Allocate and initialize device-specific data */

    dev = plAllocDev(pls);

    dev->xold = UNDEFINED;
    dev->yold = UNDEFINED;
    dev->xmin = 0;
    dev->ymin = 0;
    dev->xmax = IMPX;
    dev->ymax = IMPY;
    dev->xlen = dev->xmax - dev->xmin;
    dev->ylen = dev->ymax - dev->ymin;

    plP_setpxl((PLFLT) 11.81, (PLFLT) 11.81);
    plP_setphy(dev->xmin, dev->xmax, dev->ymin, dev->ymax);

    LineBuff = (short *) malloc(BUFFLENG * sizeof(short));
    if (LineBuff == NULL) {
	plexit("Error in memory alloc in plD_init_imp().");
    }
    fprintf(pls->OutFile, "@Document(Language ImPress, jobheader off)");
    fprintf(pls->OutFile, "%c%c", SET_HV_SYSTEM, OPBYTE1);
    fprintf(pls->OutFile, "%c%c%c", SET_ABS_H, OPWORDH1, OPWORDH2);
    fprintf(pls->OutFile, "%c%c%c", SET_ABS_V, OPWORDV1, OPWORDV2);
    fprintf(pls->OutFile, "%c%c", SET_HV_SYSTEM, OPBYTE2);
}

/*----------------------------------------------------------------------*\
* plD_line_imp()
*
* Draw a line in the current color from (x1,y1) to (x2,y2).
\*----------------------------------------------------------------------*/

void
plD_line_imp(PLStream *pls, short x1a, short y1a, short x2a, short y2a)
{
    PLDev *dev = (PLDev *) pls->dev;
    int x1 = x1a, y1 = y1a, x2 = x2a, y2 = y2a;

    if (FirstLine) {
	if (penchange) {
	    fprintf(pls->OutFile, "%c%c", SET_PEN, (char) penwidth);
	    penchange = 0;
	}
	/* Add both points to path */
	count = 0;
	FirstLine = 0;
	*(LineBuff + count++) = (short) x1;
	*(LineBuff + count++) = (short) y1;
	*(LineBuff + count++) = (short) x2;
	*(LineBuff + count++) = (short) y2;
    }
    else if ((count + 2) < BUFFLENG && x1 == dev->xold && y1 == dev->yold) {
	/* Add new point to path */
	*(LineBuff + count++) = (short) x2;
	*(LineBuff + count++) = (short) y2;
    }
    else {
	/* Write out old path */
	count /= 2;
	fprintf(pls->OutFile, "%c%c%c", CREATE_PATH, (char) count / 256, (char) count % 256);
	fwrite((char *) LineBuff, sizeof(short), 2 * count, pls->OutFile);
	fprintf(pls->OutFile, "%c%c", DRAW_PATH, OPTYPE);

	/* And start a new path */
	if (penchange) {
	    fprintf(pls->OutFile, "%c%c", SET_PEN, (char) penwidth);
	    penchange = 0;
	}
	count = 0;
	*(LineBuff + count++) = (short) x1;
	*(LineBuff + count++) = (short) y1;
	*(LineBuff + count++) = (short) x2;
	*(LineBuff + count++) = (short) y2;
    }
    dev->xold = x2;
    dev->yold = y2;
}

/*----------------------------------------------------------------------*\
* plD_polyline_imp()
*
* Draw a polyline in the current color.
\*----------------------------------------------------------------------*/

void
plD_polyline_imp(PLStream *pls, short *xa, short *ya, PLINT npts)
{
    PLINT i;

    for (i = 0; i < npts - 1; i++)
	plD_line_imp(pls, xa[i], ya[i], xa[i + 1], ya[i + 1]);
}

/*----------------------------------------------------------------------*\
* plD_eop_imp()
*
* End of page.
\*----------------------------------------------------------------------*/

void
plD_eop_imp(PLStream *pls)
{
    flushline(pls);
    fprintf(pls->OutFile, "%c", ENDPAGE);
}

/*----------------------------------------------------------------------*\
* plD_bop_imp()
*
* Set up for the next page.
* Advance to next family file if necessary (file output).
\*----------------------------------------------------------------------*/

void
plD_bop_imp(PLStream *pls)
{
    PLDev *dev = (PLDev *) pls->dev;

    FirstLine = 1;
    dev->xold = UNDEFINED;
    dev->yold = UNDEFINED;

    if (!pls->termin)
	plGetFam(pls);

    pls->page++;
}

/*----------------------------------------------------------------------*\
* plD_tidy_imp()
*
* Close graphics file or otherwise clean up.
\*----------------------------------------------------------------------*/

void
plD_tidy_imp(PLStream *pls)
{
    free((void *) LineBuff);
    fclose(pls->OutFile);
    pls->fileset = 0;
    pls->page = 0;
    pls->OutFile = NULL;
}

/*----------------------------------------------------------------------*\
* plD_state_imp()
*
* Handle change in PLStream state (color, pen width, fill attribute, etc).
\*----------------------------------------------------------------------*/

void 
plD_state_imp(PLStream *pls, PLINT op)
{
    switch (op) {

    case PLSTATE_WIDTH:
	if (pls->width > 0 && pls->width <= 20) {
	    penwidth = pls->width;
	    penchange = 1;
	}
	break;

    case PLSTATE_COLOR0:
	break;

    case PLSTATE_COLOR1:
	break;
    }
}

/*----------------------------------------------------------------------*\
* plD_esc_imp()
*
* Escape function.
\*----------------------------------------------------------------------*/

void
plD_esc_imp(PLStream *pls, PLINT op, void *ptr)
{
}

/*----------------------------------------------------------------------*\
* flushline()
*
* Spits out the line buffer.
\*----------------------------------------------------------------------*/

static void
flushline(PLStream *pls)
{
    count /= 2;
    fprintf(pls->OutFile, "%c%c%c", CREATE_PATH, (char) count / 256, (char) count % 256);
    fwrite((char *) LineBuff, sizeof(short), 2 * count, pls->OutFile);
    fprintf(pls->OutFile, "%c%c", DRAW_PATH, OPTYPE);
    FirstLine = 1;
}

#else
int 
pldummy_impress()
{
    return 0;
}

#endif				/* IMP */
