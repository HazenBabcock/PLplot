from plplot_py_demos import *

# main
#
# Generates polar plot, with 1-1 scaling.

def main():

    dtr = pi / 180.0
    x0 = cos(dtr*arange(361))
    y0 = sin(dtr*arange(361))

    # Set up viewport and window, but do not draw box

    plenv(-1.3, 1.3, -1.3, 1.3, 1, -2)

    i = 0.1*arange(1,11)
    #outerproduct(i,x0) and outerproduct(i,y0) is what we are 
    #mocking up here since old Numeric version does not have outerproduct.
    i.shape = (-1,1)
    x=i*x0
    y=i*y0
    
    # Draw circles for polar grid
    for i in range(10):
	plline(x[i], y[i])

    plcol0(2)
    for i in range(12):
	theta = 30.0 * i
	dx = cos(dtr * theta)
	dy = sin(dtr * theta)

	# Draw radial spokes for polar grid

	pljoin(0.0, 0.0, dx, dy)

	# Write labels for angle

	text = `int(theta)`
        if theta < 9.99:
            offset = 0.45
        elif theta < 99.9:
            offset = 0.30
        else:
            offset = 0.15
#Slightly off zero to avoid floating point logic flips at 90 and 270 deg.
	if dx >= -0.00001:
	    plptex(dx, dy, dx, dy, -offset, text)
	else:
	    plptex(dx, dy, -dx, -dy, 1.+offset, text)

    # Draw the graph

    r = sin((dtr*5.)*arange(361))
    x = x0*r
    y = y0*r

    plcol0(3)
    plline(x, y)

    plcol0(4)
    plmtex("t", 2.0, 0.5, 0.5, "#frPLplot Example 3 - r(#gh)=sin 5#gh")

    # Restore defaults
    #plcol0(1)

main()
