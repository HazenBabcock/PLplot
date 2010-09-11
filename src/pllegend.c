/* pllegend()
 *
 * Author: Hezekiah Carty 2010
 *
 * Copyright (C) 2010  Hezekiah M. Carty
 *
 * This file is part of PLplot.
 *
 * PLplot is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Library Public License as published
 * by the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 *
 * PLplot is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Library General Public License for more details.
 *
 * You should have received a copy of the GNU Library General Public License
 * along with PLplot; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
 */

#include "plplotP.h"

PLFLT get_character_height() {
    // Character height in mm
    PLFLT default_mm, char_height_mm;
    // Normalized viewport limits
    PLFLT vxmin, vxmax, vymin, vymax;
    PLFLT vy;
    // Size of subpage in mm
    PLFLT mxmin, mxmax, mymin, mymax;
    PLFLT mm_y;
    // World height in mm
    PLFLT world_height_mm;
    // Normalized character height
    PLFLT char_height_norm;
    // Window dimensions
    PLFLT wxmin, wxmax, wymin, wymax;
    PLFLT world_y;

    plgchr(&default_mm, &char_height_mm);
    plgvpd(&vxmin, &vxmax, &vymin, &vymax);
    vy = vymax - vymin;

    plgspa(&mxmin, &mxmax, &mymin, &mymax);
    mm_y = mymax - mymin;

    world_height_mm = mm_y * vy;

    // Character height (mm) / World height (mm) = Normalized char height
    char_height_norm = char_height_mm / world_height_mm;

    // Normalized character height * World height (world) =
    // Character height (world)
    plgvpw(&wxmin, &wxmax, &wymin, &wymax);
    world_y = wymax - wymin;

    return(char_height_norm * world_y);
}

#define normalized_to_world_x(nx) ((xmin) + (nx) * ((xmax) - (xmin)))
#define normalized_to_world_y(ny) ((ymin) + (ny) * ((ymax) - (ymin)))

// pllegend - Draw a legend using lines or points
// line_length: How long should the lines be/how far apart are the points
// x, y: Normalized position of the legend in the plot window
// n: Number of legend entries
// text_colors: Color map 0 indices of the colors to use for label text
// names: Name/label for each legend entry
// colors: Line/point color for each legend entry
// symbols: Symbol to draw for each legend entry (NULL for lines)
void c_pllegend(PLFLT line_length, PLFLT x, PLFLT y, PLINT n, PLINT *text_colors, char **names, PLINT *colors, PLINT *symbols) {
    // Active indexed drawing color
    PLINT old_col0;
    // Viewport world-coordinate limits
    PLFLT xmin, xmax, ymin, ymax;
    // Legend position
    PLFLT line_x, line_x_end, line_x_world, line_x_end_world;
    PLFLT line_y, line_y_world;
    PLFLT text_x, text_y, text_x_world, text_y_world;
    // Character height (world coordinates)
    PLFLT character_height;
    // y-position of the current legend entry
    PLFLT ty;
    // Positions of the legend entries
    PLFLT xs[2], ys[2];
    PLINT i;

    old_col0 = plsc->icol0;

    plgvpw(&xmin, &xmax, &ymin, &ymax);

    // World coordinates for legend lines
    line_x = x;
    line_y = y;
    line_x_end = line_x + 0.1;
    line_x_world = normalized_to_world_x(line_x);
    line_y_world = normalized_to_world_y(line_y);
    line_x_end_world = normalized_to_world_x(line_x_end);

    // Get world-coordinate positions of the start of the legend text
    text_x = line_x_end + 0.01;
    text_y = line_y;
    text_x_world = normalized_to_world_x(text_x);
    text_y_world = normalized_to_world_y(text_y);

    character_height = get_character_height();
    // Starting y position for legend entries
    ty = text_y_world - character_height;

    xs[0] = line_x_world;
    xs[1] = line_x_end_world;
    ys[0] = ty;
    ys[1] = ty;

    // Draw each legend entry
    for (i = 0; i < n; i++) {
        // Line for the legend
        plcol0(colors[i]);
        if (symbols == NULL) {
            // Draw lines
            plline(2, xs, ys);
        }
        else {
            // Draw symbols
            plpoin(2, xs, ys, symbols[i]);
        }

        // Label/name for the legend
        plcol0(text_colors[i]);
        plptex(text_x_world, ty, 0.0, 0.0, 0.0, names[i]);
        // Move to the next position
        ty = ty - (1.5 * character_height);
        ys[0] = ty;
        ys[1] = ty;
    }

    // Restore the previously active drawing color
    plcol0(old_col0);

    return;
}

