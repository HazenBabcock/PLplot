/* $Id$
   $Log$
   Revision 1.17  1993/07/31 07:56:43  mjl
   Several driver functions consolidated, for all drivers.  The width and color
   commands are now part of a more general "state" command.  The text and
   graph commands used for switching between modes is now handled by the
   escape function (very few drivers require it).  The device-specific PLDev
   structure is now malloc'ed for each driver that requires it, and freed when
   the stream is terminated.

 * Revision 1.16  1993/07/16  22:14:18  mjl
 * Simplified and fixed dpi settings.
 *
 * Revision 1.15  1993/07/01  21:59:43  mjl
 * Changed all plplot source files to include plplotP.h (private) rather than
 * plplot.h.  Rationalized namespace -- all externally-visible plplot functions
 * now start with "pl"; device driver functions start with "plD_".
 *
 * Revision 1.14  1993/04/26  20:01:59  mjl
 * Changed time type from long to time_t.
*/

/*	ps.c

	PLPLOT PostScript device driver.
*/
#ifdef PS

#include "plplotP.h"
#include <stdio.h>
#include <string.h>
#include <time.h>

#include "drivers.h"

/* Prototypes for functions in this file. */

static char *ps_getdate	(void);
static void ps_init	(PLStream *);

/* top level declarations */

#define LINELENGTH      70
#define COPIES          1
#define XSIZE           540	/* 7.5" x 10"  (72 points equal 1 inch) */
#define YSIZE           720
#define ENLARGE         5
#define XPSSIZE         ENLARGE*XSIZE
#define YPSSIZE         ENLARGE*YSIZE
#define XOFFSET         36	/* Offsets are .5" each */
#define YOFFSET         36
#define PSX             XPSSIZE-1
#define PSY             YPSSIZE-1

#define OF		pls->OutFile

static char outbuf[128];
static int llx = XPSSIZE, lly = YPSSIZE, urx = 0, ury = 0, ptcnt;

/*----------------------------------------------------------------------*\
* plD_init_ps()
*
* Initialize device.
\*----------------------------------------------------------------------*/

void
plD_init_psm(PLStream *pls)
{
    if (!pls->colorset)
	pls->color = 0;		/* no color by default: user can override */
    ps_init(pls);
}

void
plD_init_psc(PLStream *pls)
{
    pls->color = 1;		/* always color */
    ps_init(pls);
}

static void
ps_init(PLStream *pls)
{
    PLDev *dev;
    float r, g, b;
    float pxlx = YPSSIZE/LPAGE_X;
    float pxly = XPSSIZE/LPAGE_Y;

    pls->termin = 0;		/* not an interactive terminal */
    pls->icol0 = 1;
    pls->bytecnt = 0;
    pls->page = 0;
    pls->family = 0;		/* I don't want to support familying here */

    if (pls->widthset) {
	if (pls->width < 1 || pls->width > 10) {
	    fprintf(stderr, "\nInvalid pen width selection.");
	    pls->width = 1;
	}
	pls->widthset = 0;
    }
    else
	pls->width = 1;

/* Prompt for a file name if not already set */

    plOpenFile(pls);

/* Allocate and initialize device-specific data */

    dev = plAllocDev(pls);

    dev->xold = UNDEFINED;
    dev->yold = UNDEFINED;

    plP_setpxl(pxlx, pxly);

/* Rotate by 90 degrees since portrait mode addressing is used */

    dev->xmin = 0;
    dev->ymin = 0;
    dev->xmax = PSY;
    dev->ymax = PSX;
    dev->xlen = dev->xmax - dev->xmin;
    dev->ylen = dev->ymax - dev->ymin;

    plP_setphy(dev->xmin, dev->xmax, dev->ymin, dev->ymax);

/* Header comments into PostScript file */

    fprintf(OF, "%%!PS-Adobe-2.0 EPSF-2.0\n");
    fprintf(OF, "%%%%BoundingBox:         \n");
    fprintf(OF, "%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%\n");

    fprintf(OF, "%%%%Title: PLPLOT Graph\n");
    fprintf(OF, "%%%%Creator: PLPLOT Version 4.0\n");
    fprintf(OF, "%%%%CreationDate: %s\n", ps_getdate());
    fprintf(OF, "%%%%Pages: (atend)\n");
    fprintf(OF, "%%%%EndComments\n\n");

/* Definitions */
/* Save VM state */

    fprintf(OF, "/PSSave save def\n");

/* Define a dictionary and start using it */

    fprintf(OF, "/PSDict 200 dict def\n");
    fprintf(OF, "PSDict begin\n");

    fprintf(OF, "/@restore /restore load def\n");
    fprintf(OF, "/restore\n");
    fprintf(OF, "   {vmstatus pop\n");
    fprintf(OF, "    dup @VMused lt {pop @VMused} if\n");
    fprintf(OF, "    exch pop exch @restore /@VMused exch def\n");
    fprintf(OF, "   } def\n");
    fprintf(OF, "/@pri\n");
    fprintf(OF, "   {\n");
    fprintf(OF, "    ( ) print\n");
    fprintf(OF, "    (                                       ) cvs print\n");
    fprintf(OF, "   } def\n");
    fprintf(OF, "/@copies\n");	/* n @copies - */
    fprintf(OF, "   {\n");
    fprintf(OF, "    /#copies exch def\n");
    fprintf(OF, "   } def\n");

/* - @start -  -- start everything */

    fprintf(OF, "/@start\n");
    fprintf(OF, "   {\n");
    fprintf(OF, "    vmstatus pop /@VMused exch def pop\n");
    fprintf(OF, "   } def\n");

/* - @end -  -- finished */

    fprintf(OF, "/@end\n");
    fprintf(OF, "   {flush\n");
    fprintf(OF, "    end\n");
    fprintf(OF, "    PSSave restore\n");
    fprintf(OF, "   } def\n");

/* bop -  -- begin a new page */

    fprintf(OF, "/bop\n");
    fprintf(OF, "   {\n");
    fprintf(OF, "    /SaveImage save def\n");
    if (pls->color) {
	fprintf(OF, "    Z %d %d M %d %d D %d %d D %d %d D %d %d",
		0, 0, 0, PSY, PSX, PSY, PSX, 0, 0, 0);
	r = ((float) pls->bgcolor.r) / 255.;
	g = ((float) pls->bgcolor.g) / 255.;
	b = ((float) pls->bgcolor.b) / 255.;
	fprintf(OF, "    closepath %f %f %f setrgbcolor fill\n",
		r, g, b);
    }
    fprintf(OF, "   } def\n");

/* - eop -  -- end a page */

    fprintf(OF, "/eop\n");
    fprintf(OF, "   {\n");
    fprintf(OF, "    showpage\n");
    fprintf(OF, "    SaveImage restore\n");
    fprintf(OF, "   } def\n");

/* Set line parameters */

    fprintf(OF, "/@line\n");
    fprintf(OF, "   {0 setlinecap\n");
    fprintf(OF, "    0 setlinejoin\n");
    fprintf(OF, "    1 setmiterlimit\n");
    fprintf(OF, "   } def\n");

/* d @hsize -  horizontal clipping dimension */

    fprintf(OF, "/@hsize   {/hs exch def} def\n");
    fprintf(OF, "/@vsize   {/vs exch def} def\n");

/* d @hoffset - shift for the plots */

    fprintf(OF, "/@hoffset {/ho exch def} def\n");
    fprintf(OF, "/@voffset {/vo exch def} def\n");

/* Default line width */

    fprintf(OF, "/lw %d def\n", pls->width);
    fprintf(OF, "/@lwidth  {lw setlinewidth} def\n");

/* Setup user specified offsets, scales, sizes for clipping */

    fprintf(OF, "/@SetPlot\n");
    fprintf(OF, "   {\n");
    fprintf(OF, "    ho vo translate\n");
    fprintf(OF, "    XScale YScale scale\n");
    fprintf(OF, "    lw setlinewidth\n");
    fprintf(OF, "   } def\n");

/* Setup x & y scales */

    fprintf(OF, "/XScale\n");
    fprintf(OF, "   {hs %d div} def\n", YPSSIZE);
    fprintf(OF, "/YScale\n");
    fprintf(OF, "   {vs %d div} def\n", XPSSIZE);

/* Stroke definitions, to keep output file as small as possible */

    fprintf(OF, "/M {moveto} def\n");
    fprintf(OF, "/D {lineto} def\n");
    fprintf(OF, "/S {stroke} def\n");
    fprintf(OF, "/Z {stroke newpath} def\n");

/* End of dictionary definition */

    fprintf(OF, "end\n\n");

/* Set up the plots */

    fprintf(OF, "PSDict begin\n");
    fprintf(OF, "@start\n");
    fprintf(OF, "%d @copies\n", COPIES);
    fprintf(OF, "@line\n");
    fprintf(OF, "%d @hsize\n", YSIZE);
    fprintf(OF, "%d @vsize\n", XSIZE);
    fprintf(OF, "%d @hoffset\n", YOFFSET);
    fprintf(OF, "%d @voffset\n", XOFFSET);

    fprintf(OF, "@SetPlot\n\n");
}

/*----------------------------------------------------------------------*\
* plD_line_ps()
*
* Draw a line in the current color from (x1,y1) to (x2,y2).
\*----------------------------------------------------------------------*/

void
plD_line_ps(PLStream *pls, short x1a, short y1a, short x2a, short y2a)
{
    PLDev *dev = (PLDev *) pls->dev;
    int x1 = x1a, y1 = y1a, x2 = x2a, y2 = y2a;

    if (pls->linepos + 21 > LINELENGTH) {
	putc('\n', OF);
	pls->linepos = 0;
    }
    else
	putc(' ', OF);

    pls->bytecnt++;

/* Rotate by 90 degrees */

    plRotPhy(1, dev, &x1, &y1, &x2, &y2);

    if (x1 == dev->xold && y1 == dev->yold && ptcnt < 40) {
	sprintf(outbuf, "%d %d D", x2, y2);
	ptcnt++;
    }
    else {
	sprintf(outbuf, "Z %d %d M %d %d D", x1, y1, x2, y2);
	llx = MIN(llx, x1);
	lly = MIN(lly, y1);
	urx = MAX(urx, x1);
	ury = MAX(ury, y1);
	ptcnt = 1;
    }
    llx = MIN(llx, x2);
    lly = MIN(lly, y2);
    urx = MAX(urx, x2);
    ury = MAX(ury, y2);

    fprintf(OF, "%s", outbuf);
    pls->bytecnt += strlen(outbuf);
    dev->xold = x2;
    dev->yold = y2;
    pls->linepos += 21;
}

/*----------------------------------------------------------------------*\
* plD_polyline_ps()
*
* Draw a polyline in the current color.
\*----------------------------------------------------------------------*/

void
plD_polyline_ps(PLStream *pls, short *xa, short *ya, PLINT npts)
{
    PLINT i;

    for (i = 0; i < npts - 1; i++)
	plD_line_ps(pls, xa[i], ya[i], xa[i + 1], ya[i + 1]);
}

/*----------------------------------------------------------------------*\
* plD_eop_ps()
*
* End of page.
\*----------------------------------------------------------------------*/

void
plD_eop_ps(PLStream *pls)
{
    fprintf(OF, " S\neop\n");
}

/*----------------------------------------------------------------------*\
* plD_bop_ps()
*
* Set up for the next page.
\*----------------------------------------------------------------------*/

void
plD_bop_ps(PLStream *pls)
{
    PLDev *dev = (PLDev *) pls->dev;

    dev->xold = UNDEFINED;
    dev->yold = UNDEFINED;

    pls->page++;
    fprintf(OF, " bop\n");
    fprintf(OF, "%%%%Page: %d %d\n", pls->page, pls->page);
    pls->linepos = 0;
}

/*----------------------------------------------------------------------*\
* plD_tidy_ps()
*
* Close graphics file or otherwise clean up.
\*----------------------------------------------------------------------*/

void
plD_tidy_ps(PLStream *pls)
{
    fprintf(OF, "@end\n\n");
    fprintf(OF, "%%%%Trailer\n");

    llx /= ENLARGE;
    lly /= ENLARGE;
    urx /= ENLARGE;
    ury /= ENLARGE;
    llx += XOFFSET;
    lly += YOFFSET;
    urx += XOFFSET;
    ury += YOFFSET;
    fprintf(OF, "%%%%Pages: %d\n", pls->page);

/* Backtrack to write the BoundingBox at the beginning */
/* Some applications don't like it atend */

    rewind(OF);
    fprintf(OF, "%%!PS-Adobe-2.0 EPSF-2.0\n");
    fprintf(OF, "%%%%BoundingBox: %d %d %d %d\n", llx, lly, urx, ury);
    fclose(OF);
    pls->fileset = 0;
    pls->page = 0;
    pls->linepos = 0;
    OF = NULL;
}

/*----------------------------------------------------------------------*\
* plD_state_ps()
*
* Handle change in PLStream state (color, pen width, fill attribute, etc).
\*----------------------------------------------------------------------*/

void 
plD_state_ps(PLStream *pls, PLINT op)
{
    PLDev *dev = (PLDev *) pls->dev;

    switch (op) {

    case PLSTATE_WIDTH:
	if (pls->width < 1 || pls->width > 10)
	    fprintf(stderr, "\nInvalid pen width selection.");
	else 
	    fprintf(OF, " S\n/lw %d def\n@lwidth\n", pls->width);

	dev->xold = UNDEFINED;
	dev->yold = UNDEFINED;
	break;

    case PLSTATE_COLOR0:
	if (pls->color) {
	    float r = ((float) pls->curcolor.r) / 255.0;
	    float g = ((float) pls->curcolor.g) / 255.0;
	    float b = ((float) pls->curcolor.b) / 255.0;

	    fprintf(OF, " S %f %f %f setrgbcolor\n", r, g, b);
	}
	break;

    case PLSTATE_COLOR1:
	break;
    }
}

/*----------------------------------------------------------------------*\
* plD_esc_ps()
*
* Escape function.
\*----------------------------------------------------------------------*/

void
plD_esc_ps(PLStream *pls, PLINT op, void *ptr)
{
}

/*----------------------------------------------------------------------*\
* ps_getdate()
*
* Get the date and time
\*----------------------------------------------------------------------*/

static char *
ps_getdate(void)
{
    int len;
    time_t t;
    char *p;

    t = time((time_t *) 0);
    p = ctime(&t);
    len = strlen(p);
    *(p + len - 1) = '\0';	/* zap the newline character */
    return p;
}

#else
int 
pldummy_ps()
{
    return 0;
}

#endif				/* PS */
