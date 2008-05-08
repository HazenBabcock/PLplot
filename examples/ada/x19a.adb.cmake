-- $Id$

--	Illustrates backdrop plotting of world, US maps.
--	Contributed by Wesley Ebisuzaki.

-- Copyright (C) 2007 Jerry Bauck

-- This file is part of PLplot.

-- PLplot is free software; you can redistribute it and/or modify
-- it under the terms of the GNU General Library Public License as published
-- by the Free Software Foundation; either version 2 of the License, or
-- (at your option) any later version.

-- PLplot is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU Library General Public License for more details.

-- You should have received a copy of the GNU Library General Public License
-- along with PLplot; if not, write to the Free Software
-- Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA

with
    Ada.Numerics,
    Ada.Numerics.Long_Elementary_Functions,
    PLplot_Traditional,
    PLplot_Auxiliary;
use
    Ada.Numerics,
    Ada.Numerics.Long_Elementary_Functions,
    PLplot_Traditional,
    PLplot_Auxiliary;

-- COMMENT THIS LINE IF YOUR COMPILER DOES NOT INCLUDE THESE 
-- DEFINITIONS, FOR EXAMPLE, IF IT IS NOT ADA 2005 WITH ANNEX G.3 COMPLIANCE.
--with Ada.Numerics.Long_Real_Arrays; use Ada.Numerics.Long_Real_Arrays;
@Ada_Is_2007_With_and_Use_Numerics@

-- Shows two views of the world map.
procedure x19a is
    minx, maxx, miny, maxy : Long_Float;

    -- This spec is necessary in order to enforce C calling conventions, used 
    -- in the callback by intervening C code.
    procedure mapform19(n : Integer; x, y : in out Real_Vector); 
    pragma Convention(C, mapform19);

    -- Defines specific coordinate transformation for example 19.
    -- Not to be confused with mapform in src/plmap.c.
    -- x(), y() are the coordinates to be plotted.

    -- Ada note: Passing the array length as the first argument is the easiest 
    -- way (for the developer of the bindings) and maintain a C-compatible 
    -- argument list. It might be possible to instead pass a pointer to something 
    -- with an argument list (x, y : in out Real_Vector) instead, and write a
    -- wrapper function inside plmap and plmeridians that has the "correct" C 
    -- argument list, and then pass a pointer to _that_ when calling plmap and
    -- plmeridian.
    procedure mapform19(n : Integer; x, y : in out Real_Vector) is 
        xp, yp, radius : Long_Float;
    begin
         -- DO NOT use x'range for this loop because the C function which calls 
         -- this function WILL NOT SEE IT AND YOU WILL GET A SEGFAULT. Simply 
         -- use 0 .. n - 1 explicitly.
        for i in 0 .. n - 1 loop
            radius := 90.0 - y(i);
            xp := radius * cos(x(i) * pi / 180.0);
            yp := radius * sin(x(i) * pi / 180.0);
            x(i) := xp;
            y(i) := yp;
        end loop;
    end mapform19;

begin

    -- Parse and process command line arguments 
    plparseopts(PL_PARSE_FULL);

    plinit;

    -- Longitude (x) and latitude (y) 
    miny := -70.0;
    maxy := 80.0;

    -- Cartesian plots 
    -- Most of world 
    minx := 190.0;
    maxx := 190.0 + 360.0;

    plcol0(1);
    plenv(minx, maxx, miny, maxy, 1, -1);
    plmap(null, USA_States_and_Continents, minx, maxx, miny, maxy);

    -- The Americas 
    minx := 190.0;
    maxx := 340.0;

    plcol0(1);
    plenv(minx, maxx, miny, maxy, 1, -1);
    plmap(null, USA_States_and_Continents, minx, maxx, miny, maxy);

    -- Polar, Northern hemisphere 
    minx := 0.0;
    maxx := 360.0;

    plenv(-75.0, 75.0, -75.0, 75.0, 1, -1);
    plmap(mapform19'Unrestricted_Access, Continents, minx, maxx, miny, maxy);

    pllsty(2);
    plmeridians(mapform19'Unrestricted_Access, 10.0, 10.0, 0.0, 360.0, -10.0, 80.0);
    plend;
end x19a;
