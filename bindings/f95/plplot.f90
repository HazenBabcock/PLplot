!***********************************************************************
!  plplot_binding.f90
!
!  Copyright (C) 2005-2016  Arjen Markus
!  Copyright (C) 2006-2016 Alan W. Irwin
!
!  This file is part of PLplot.
!
!  PLplot is free software; you can redistribute it and/or modify
!  it under the terms of the GNU Library General Public License as published
!  by the Free Software Foundation; either version 2 of the License, or
!  (at your option) any later version.
!
!  PLplot is distributed in the hope that it will be useful,
!  but WITHOUT ANY WARRANTY; without even the implied warranty of
!  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
!  GNU Library General Public License for more details.
!
!  You should have received a copy of the GNU Library General Public License
!  along with PLplot; if not, write to the Free Software
!  Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
!
!
!***********************************************************************

module plplot
    use plplot_single
    use plplot_double
    use plplot_types, only: private_plflt, private_plint, private_plbool, private_plunicode, private_single, private_double
    use plplot_graphics
    use iso_c_binding, only: c_ptr, c_char, c_loc, c_funloc, c_funptr, c_null_char, c_null_ptr, c_null_funptr
    use iso_fortran_env, only: error_unit
    use plplot_private_utilities, only: character_array_to_c
    implicit none
    ! For backwards compatibility define plflt, but use of this
    ! parameter is deprecated since any real precision should work
    ! for users so long as the precision of the real arguments
    ! of a given call to a PLplot routine are identical.
    integer, parameter :: plflt = private_plflt
    integer(kind=private_plint), parameter :: maxlen = 320
    character(len=1), parameter :: PL_END_OF_STRING = achar(0)
    include 'included_plplot_parameters.f90'
    private :: private_plflt, private_plint, private_plbool, private_plunicode, private_single, private_double
    private :: c_ptr, c_char, c_loc, c_funloc, c_funptr, c_null_char, c_null_ptr, c_null_funptr
    private :: copystring2f, maxlen
    private :: pltransform_single
    private :: pltransform_double
    private :: error_unit
    private :: character_array_to_c
!
    ! Interfaces that do not depend on the real kind or which
    ! generate an ambiguous interface (e.g., plslabelfunc, plstransform) if
    ! implemented with plplot_single and plplot_double.
!
    interface pl_setcontlabelformat
        module procedure pl_setcontlabelformat_impl
    end interface pl_setcontlabelformat
    private :: pl_setcontlabelformat_impl

    interface pladv
       module procedure pladv_impl
    end interface pladv
    private :: pladv_impl

    interface plbop
       module procedure plbop_impl
    end interface plbop
    private :: plbop_impl

    interface plclear
       module procedure plclear_impl
    end interface plclear
    private :: plclear_impl

    interface plcol0
       module procedure plcol0_impl
    end interface plcol0
    private :: plcol0_impl

    interface plcpstrm
       module procedure plcpstrm_impl
    end interface plcpstrm
    private :: plcpstrm_impl

    interface plend1
       module procedure plend1_impl
    end interface plend1
    private :: plend1_impl

    interface plend
       module procedure plend_impl
    end interface plend
    private :: plend_impl

    interface pleop
       module procedure pleop_impl
    end interface pleop
    private :: pleop_impl

    interface plfamadv
       module procedure plfamadv_impl
    end interface plfamadv
    private :: plfamadv_impl

    interface plflush
       module procedure plflush_impl
    end interface plflush
    private :: plflush_impl

    interface plfont
       module procedure plfont_impl
    end interface plfont
    private :: plfont_impl

    interface plfontld
       module procedure plfontld_impl
    end interface plfontld
    private :: plfontld_impl

    interface plgcol0
       module procedure plgcol0_impl
    end interface plgcol0
    private :: plgcol0_impl

    interface plgcolbg
       module procedure plgcolbg_impl
    end interface plgcolbg
    private :: plgcolbg_impl

    interface plgcompression
       module procedure plgcompression_impl
    end interface plgcompression
    private :: plgcompression_impl

    interface plgdev
       module procedure plgdev_impl
    end interface plgdev
    private :: plgdev_impl

    interface plgdrawmode
       module procedure plgdrawmode_impl
    end interface plgdrawmode
    private :: plgdrawmode_impl

    interface plgfam
       module procedure plgfam_impl
    end interface plgfam
    private :: plgfam_impl

    interface plgfci
        module procedure plgfci_impl
    end interface plgfci
    private :: plgfci_impl

    interface plgfnam
       module procedure plgfnam_impl
    end interface plgfnam
    private :: plgfnam_impl

    interface plgfont
       module procedure plgfont_impl
    end interface plgfont
    private :: plgfont_impl

    interface plglevel
       module procedure plglevel_impl
    end interface plglevel
    private :: plglevel_impl

    interface plgra
       module procedure plgra_impl
    end interface plgra
    private :: plgra_impl

    interface plgstrm
       module procedure plgstrm_impl
    end interface plgstrm
    private :: plgstrm_impl

    interface plgver
       module procedure plgver_impl
    end interface plgver
    private :: plgver_impl

    interface plgxax
       module procedure plgxax_impl
    end interface plgxax
    private :: plgxax_impl

    interface plgyax
       module procedure plgyax_impl
    end interface plgyax
    private :: plgyax_impl

    interface plgzax
       module procedure plgzax_impl
    end interface plgzax
    private :: plgzax_impl

    interface plinit
       module procedure plinit_impl
    end interface plinit
    private :: plinit_impl

    interface pllab
       module procedure pllab_impl
    end interface pllab
    private :: pllab_impl

    interface pllsty
       module procedure pllsty_impl
    end interface pllsty
    private :: pllsty_impl

    interface plmap
        module procedure plmap_double
        module procedure plmap_double_null
        module procedure plmap_single
        module procedure plmap_single_null
    end interface plmap
    private :: plmap_double
    private :: plmap_double_null
    private :: plmap_single
    private :: plmap_single_null

    interface plmapfill
        module procedure plmapfill_double
        module procedure plmapfill_double_null
        module procedure plmapfill_single
        module procedure plmapfill_single_null
    end interface plmapfill
    private :: plmapfill_double
    private :: plmapfill_double_null
    private :: plmapfill_single
    private :: plmapfill_single_null

    interface plmapline
        module procedure plmapline_double
        module procedure plmapline_double_null
        module procedure plmapline_single
        module procedure plmapline_single_null
    end interface plmapline
    private :: plmapline_double
    private :: plmapline_double_null
    private :: plmapline_single
    private :: plmapline_single_null

    interface plmapstring
        module procedure plmapstring_double
        module procedure plmapstring_double_null
        module procedure plmapstring_single
        module procedure plmapstring_single_null
    end interface plmapstring
    private :: plmapstring_double
    private :: plmapstring_double_null
    private :: plmapstring_single
    private :: plmapstring_single_null

    interface plmeridians
        module procedure plmeridians_double
        module procedure plmeridians_double_null
        module procedure plmeridians_single
        module procedure plmeridians_single_null
    end interface plmeridians
    private :: plmeridians_double
    private :: plmeridians_double_null
    private :: plmeridians_single
    private :: plmeridians_single_null

    interface plmkstrm
       module procedure plmkstrm_impl
    end interface plmkstrm
    private :: plmkstrm_impl

    interface plparseopts
       module procedure plparseopts_impl
    end interface plparseopts
    private :: plparseopts_impl

    interface plpat
       module procedure plpat_impl
    end interface plpat
    private :: plpat_impl

    interface plprec
       module procedure plprec_impl
    end interface plprec
    private :: plprec_impl

    interface plpsty
       module procedure plpsty_impl
    end interface plpsty
    private :: plpsty_impl

    interface plrandd
       module procedure plrandd_impl
    end interface plrandd
    private :: plrandd_impl

    interface plreplot
       module procedure plreplot_impl
    end interface plreplot
    private :: plreplot_impl

    interface plscmap0
       module procedure plscmap0_impl
    end interface plscmap0
    private :: plscmap0_impl

    interface plscmap0n
       module procedure plscmap0n_impl
    end interface plscmap0n
    private :: plscmap0n_impl

    interface plscmap1
       module procedure plscmap1_impl
    end interface plscmap1
    private :: plscmap1_impl

    interface plscmap1n
       module procedure plscmap1n_impl
    end interface plscmap1n
    private :: plscmap1n_impl

    interface plscol0
       module procedure plscol0_impl
    end interface plscol0
    private :: plscol0_impl

    interface plscolbg
       module procedure plscolbg_impl
    end interface plscolbg
    private :: plscolbg_impl

    interface plscolor
       module procedure plscolor_impl
    end interface plscolor
    private :: plscolor_impl

    interface plscompression
       module procedure plscompression_impl
    end interface plscompression
    private :: plscompression_impl

    interface plsdev
       module procedure plsdev_impl
    end interface plsdev
    private :: plsdev_impl

    interface plsdrawmode
       module procedure plsdrawmode_impl
    end interface plsdrawmode
    private :: plsdrawmode_impl

    interface plseed
       module procedure plseed_impl
    end interface plseed
    private :: plseed_impl

    interface plsesc
       module procedure plsesc_impl
    end interface plsesc
    private :: plsesc_impl

    interface plsetopt
        module procedure plsetopt_impl
    end interface plsetopt
    private :: plsetopt_impl

    interface plsfam
       module procedure plsfam_impl
    end interface plsfam
    private :: plsfam_impl

    interface plsfci
        module procedure plsfci_impl
    end interface plsfci
    private :: plsfci_impl

    interface plsfnam
       module procedure plsfnam_impl
    end interface plsfnam
    private :: plsfnam_impl

    interface plsfont
       module procedure plsfont_impl
    end interface plsfont
    private :: plsfont_impl

    interface plslabelfunc
        ! Only provide double-precison versions because of
        ! disambiguation problems with the corresponding
        ! single-precision versions.
        module procedure plslabelfunc_data_double
        module procedure plslabelfunc_double
        module procedure plslabelfunc_null
    end interface plslabelfunc
    private :: plslabelfunc_data_double
    private :: plslabelfunc_double
    private :: plslabelfunc_null

    interface plsmem
       module procedure plsmem_impl
    end interface plsmem
    private :: plsmem_impl

    interface plsmema
       module procedure plsmema_impl
    end interface plsmema
    private :: plsmema_impl

    interface plsori
       module procedure plsori_impl
    end interface plsori
    private :: plsori_impl

    interface plspal0
       module procedure plspal0_impl
    end interface plspal0
    private :: plspal0_impl

    interface plspal1
       module procedure plspal1_impl
    end interface plspal1
    private :: plspal1_impl

    interface plspause
       module procedure plspause_impl
    end interface plspause
    private :: plspause_impl

    interface plsstrm
       module procedure plsstrm_impl
    end interface plsstrm
    private :: plsstrm_impl

    interface plssub
       module procedure plssub_impl
    end interface plssub
    private :: plssub_impl

    interface plstar
       module procedure plstar_impl
    end interface plstar
    private :: plstar_impl

    interface plstart
       module procedure plstart_impl
    end interface plstart
    private :: plstart_impl

    interface plstransform
        ! Only provide double-precison versions because of
        ! disambiguation problems with the corresponding
        ! single-precision versions.
        module procedure plstransform_data_double
        module procedure plstransform_double
        module procedure plstransform_null
    end interface plstransform
    private :: plstransform_data_double
    private :: plstransform_double
    private :: plstransform_null

    interface plstripd
       module procedure plstripd_impl
    end interface plstripd
    private :: plstripd_impl

    interface plstyl
        module procedure plstyl_array
        module procedure plstyl_n_array
        module procedure plstyl_scalar
    end interface plstyl
    private :: plstyl_array
    private :: plstyl_n_array
    private :: plstyl_scalar

    interface plsvect
       module procedure plsvect_double
       module procedure plsvect_none
       module procedure plsvect_single
    end interface plsvect
    private :: plsvect_double, plsvect_none, plsvect_single

    interface plsxax
       module procedure plsxax_impl
    end interface plsxax
    private :: plsxax_impl

    interface plsyax
       module procedure plsyax_impl
    end interface plsyax
    private :: plsyax_impl

    interface plszax
       module procedure plszax_impl
    end interface plszax
    private :: plszax_impl

    interface pltext
       module procedure pltext_impl
    end interface pltext
    private :: pltext_impl

    interface pltimefmt
        module procedure pltimefmt_impl
    end interface pltimefmt
    private :: pltimefmt_impl

    interface plvsta
       module procedure plvsta_impl
    end interface plvsta
    private :: plvsta_impl

    interface plxormod
        module procedure plxormod_impl
    end interface plxormod
    private :: plxormod_impl

contains

!
! Private utilities
!
subroutine copystring2f( fstring, cstring )
    character(len=*), intent(out) :: fstring
    character(len=1), dimension(:), intent(in) :: cstring

    integer :: i_local

    fstring = ' '
    do i_local = 1,min(len(fstring),size(cstring))
        if ( cstring(i_local) /= c_null_char ) then
            fstring(i_local:i_local) = cstring(i_local)
        else
            exit
        endif
    enddo

end subroutine copystring2f

!
! Interface routines
!
subroutine pl_setcontlabelformat_impl( lexp, sigdig )
   integer, intent(in) :: lexp, sigdig

   interface
       subroutine interface_pl_setcontlabelformat( lexp, sigdig ) bind(c,name='c_pl_setcontlabelformat')
           import :: private_plint
           implicit none
           integer(kind=private_plint), value, intent(in) :: lexp, sigdig
       end subroutine interface_pl_setcontlabelformat
   end interface

   call interface_pl_setcontlabelformat( int(lexp,kind=private_plint), int(sigdig,kind=private_plint) )
end subroutine pl_setcontlabelformat_impl

subroutine pladv_impl( sub )
    integer, intent(in) :: sub
    interface
        subroutine interface_pladv( sub ) bind( c, name = 'c_pladv' )
            import :: private_plint
            implicit none
            integer(kind=private_plint), value, intent(in) :: sub
        end subroutine interface_pladv
    end interface

    call interface_pladv( int(sub,kind=private_plint) )
  end subroutine pladv_impl

subroutine plbop_impl()
    interface
        subroutine interface_plbop() bind(c,name='c_plbop')
        end subroutine interface_plbop
     end interface
     call interface_plbop()
   end subroutine plbop_impl

subroutine plclear_impl()
    interface
        subroutine interface_plclear() bind(c,name='c_plclear')
        end subroutine interface_plclear
     end interface
     call interface_plclear()
   end subroutine plclear_impl

subroutine plcol0_impl( icol )
    integer, intent(in) :: icol
    interface
        subroutine interface_plcol0( icol ) bind(c, name = 'c_plcol0' )
            import :: private_plint
            implicit none
            integer(kind=private_plint), value, intent(in) :: icol
        end subroutine interface_plcol0
    end interface

    call interface_plcol0( int(icol,kind=private_plint) )
  end subroutine plcol0_impl

subroutine plcpstrm_impl( iplsr, flags )
  integer, intent(in) :: iplsr
  logical, intent(in) :: flags
    interface
        subroutine interface_plcpstrm( iplsr, flags ) bind(c, name = 'c_plcpstrm' )
            import :: private_plint, private_plbool
            implicit none
            integer(kind=private_plint), value, intent(in) :: iplsr
            integer(kind=private_plbool), value, intent(in) :: flags
        end subroutine interface_plcpstrm
    end interface

    call interface_plcpstrm( int(iplsr,kind=private_plint), int(merge(1,0,flags),kind=private_plbool) )
  end subroutine plcpstrm_impl

subroutine plend1_impl()
    interface
        subroutine interface_plend1() bind( c, name = 'c_plend1' )
        end subroutine interface_plend1
     end interface
     call interface_plend1()
   end subroutine plend1_impl

subroutine plend_impl()
    interface
        subroutine interface_plend() bind( c, name = 'c_plend' )
        end subroutine interface_plend
     end interface
     call interface_plend()
   end subroutine plend_impl

subroutine pleop_impl()
    interface
        subroutine interface_pleop() bind( c, name = 'c_pleop' )
        end subroutine interface_pleop
     end interface
     call interface_pleop()
   end subroutine pleop_impl

subroutine plfamadv_impl()
    interface
        subroutine interface_plfamadv() bind( c, name = 'c_plfamadv' )
        end subroutine interface_plfamadv
     end interface
     call interface_plfamadv()
   end subroutine plfamadv_impl

subroutine plflush_impl()
    interface
        subroutine interface_plflush() bind( c, name = 'c_plflush' )
        end subroutine interface_plflush
     end interface
     call interface_plflush()
   end subroutine plflush_impl

subroutine plfont_impl( font )
    integer, intent(in) :: font
    interface
        subroutine interface_plfont( font ) bind( c, name = 'c_plfont' )
            import :: private_plint
            implicit none
            integer(kind=private_plint), value, intent(in) :: font
        end subroutine interface_plfont
    end interface

    call interface_plfont( int(font,kind=private_plint) )
  end subroutine plfont_impl

subroutine plfontld_impl( charset )
    integer, intent(in) :: charset
    interface
        subroutine interface_plfontld( charset ) bind( c, name = 'c_plfontld' )
            import :: private_plint
            implicit none
            integer(kind=private_plint), value, intent(in) :: charset
        end subroutine interface_plfontld
    end interface

    call interface_plfontld( int(charset,kind=private_plint) )
  end subroutine plfontld_impl

subroutine plgcol0_impl( icol, r, g, b )
    integer, intent(in) :: icol
    integer, intent(out) :: r, g, b

    integer(kind=private_plint) :: r_out, g_out, b_out

    interface
        subroutine interface_plgcol0( icol, r, g, b ) bind( c, name = 'c_plgcol0' )
            import :: private_plint
            implicit none
            integer(kind=private_plint), value, intent(in) :: icol
            integer(kind=private_plint), intent(out) :: r, g, b
        end subroutine interface_plgcol0
    end interface

    call interface_plgcol0( int(icol,kind=private_plint), r_out, g_out, b_out )
    r = int(r_out)
    g = int(g_out)
    b = int(b_out)
  end subroutine plgcol0_impl

subroutine plgcolbg_impl( r, g, b )
    integer, intent(out) :: r, g, b

    integer(kind=private_plint) :: r_out, g_out, b_out

    interface
        subroutine interface_plgcolbg( r, g, b ) bind( c, name = 'c_plgcolbg' )
            import :: private_plint
            implicit none
            integer(kind=private_plint), intent(out) :: r, g, b
        end subroutine interface_plgcolbg
    end interface

    call interface_plgcolbg( r_out, g_out, b_out )
    r = int(r_out)
    g = int(g_out)
    b = int(b_out)
  end subroutine plgcolbg_impl

subroutine plgcompression_impl( compression )
    integer, intent(out) :: compression

    integer(kind=private_plint) :: compression_out

    interface
        subroutine interface_plgcompression( compression ) bind( c, name = 'c_plgcompression' )
            import :: private_plint
            implicit none
            integer(kind=private_plint), intent(out) :: compression
        end subroutine interface_plgcompression
    end interface

    call interface_plgcompression( compression_out )
    compression = int(compression_out)
  end subroutine plgcompression_impl

subroutine plgdev_impl(dev)
    character*(*), intent(out) :: dev

    character(len=1), dimension(100) :: dev_out

    interface
        subroutine interface_plgdev( dev ) bind(c,name='c_plgdev')
            implicit none
            character(len=1), dimension(*), intent(out) :: dev
        end subroutine interface_plgdev
    end interface

    call interface_plgdev( dev_out )
    call copystring2f( dev, dev_out )
  end subroutine plgdev_impl

function plgdrawmode_impl()

    integer :: plgdrawmode_impl !function type

    interface
        function interface_plgdrawmode() bind(c,name='c_plgdrawmode')
            import :: private_plint
            implicit none
            integer(kind=private_plint) :: interface_plgdrawmode !function type
        end function interface_plgdrawmode
    end interface

    plgdrawmode_impl = int(interface_plgdrawmode())
end function plgdrawmode_impl

subroutine plgfam_impl( fam, num, bmax )
    integer, intent(out) :: fam, num, bmax

    integer(kind=private_plint) :: fam_out, num_out, bmax_out

    interface
        subroutine interface_plgfam( fam, num, bmax ) bind( c, name = 'c_plgfam' )
            import :: private_plint
            implicit none
            integer(kind=private_plint), intent(out) :: fam, num, bmax
        end subroutine interface_plgfam
    end interface

    call interface_plgfam( fam_out, num_out, bmax_out )
    fam  = int(fam_out)
    num  = int(num_out)
    bmax = int(bmax_out)
  end subroutine plgfam_impl

subroutine plgfci_impl( fci )
    integer, intent(out) :: fci

    integer(kind=private_plunicode) :: fci_out

    interface
        subroutine interface_plgfci( fci ) bind( c, name = 'c_plgfci' )
            import :: private_plunicode
            implicit none
            integer(kind=private_plunicode), intent(out) :: fci
        end subroutine interface_plgfci
    end interface

    call interface_plgfci( fci_out )
    fci  = int(fci_out)
  end subroutine plgfci_impl

subroutine plgfnam_impl( fnam )
    character*(*), intent(out) :: fnam

    character(len=1), dimension(100) :: fnam_out

    interface
        subroutine interface_plgfnam( fnam ) bind(c,name='c_plgfnam')
            implicit none
            character(len=1), dimension(*), intent(out) :: fnam
        end subroutine interface_plgfnam
    end interface

    call interface_plgfnam( fnam_out )
    call copystring2f( fnam, fnam_out )
  end subroutine plgfnam_impl

subroutine plgfont_impl( family, style, weight )
    integer, intent(out) :: family, style, weight

    integer(kind=private_plint) :: family_out, style_out, weight_out

    interface
        subroutine interface_plgfont( family, style, weight ) bind( c, name = 'c_plgfont' )
            import :: private_plint
            implicit none
            integer(kind=private_plint), intent(out) :: family, style, weight
        end subroutine interface_plgfont
    end interface

    call interface_plgfont( family_out, style_out, weight_out )
    family = int(family_out)
    style  = int(style_out)
    weight = int(weight_out)
  end subroutine plgfont_impl

subroutine plglevel_impl( level )
    integer, intent(out) :: level

    integer(kind=private_plint) :: level_out

    interface
        subroutine interface_plglevel( level ) bind( c, name = 'c_plglevel' )
            import :: private_plint
            implicit none
            integer(kind=private_plint), intent(out) :: level
        end subroutine interface_plglevel
    end interface

    call interface_plglevel( level_out )
    level = int(level_out)
  end subroutine plglevel_impl

subroutine plgra_impl()
    interface
        subroutine interface_plgra() bind( c, name = 'c_plgra' )
        end subroutine interface_plgra
     end interface
     call interface_plgra()
   end subroutine plgra_impl

subroutine plgstrm_impl( strm )
    integer, intent(out) :: strm

    integer(kind=private_plint) :: strm_out

    interface
        subroutine interface_plgstrm( strm ) bind( c, name = 'c_plgstrm' )
            import :: private_plint
            implicit none
            integer(kind=private_plint), intent(out) :: strm
        end subroutine interface_plgstrm
    end interface

    call interface_plgstrm( strm_out )
    strm = int(strm_out)
  end subroutine plgstrm_impl

subroutine plgver_impl(ver)
    character*(*), intent(out) :: ver

    character(len=1), dimension(100) :: ver_out

    interface
        subroutine interface_plgver( ver ) bind(c,name='c_plgver')
            implicit none
            character(len=1), dimension(*), intent(out) :: ver
        end subroutine interface_plgver
    end interface

    call interface_plgver( ver_out )
    call copystring2f( ver, ver_out )
  end subroutine plgver_impl

subroutine plgxax_impl( digmax, digits )
    integer, intent(out) :: digmax, digits

    integer(kind=private_plint) :: digmax_out, digits_out

    interface
        subroutine interface_plgxax( digmax, digits ) bind( c, name = 'c_plgxax' )
            import :: private_plint
            implicit none
            integer(kind=private_plint), intent(out) :: digmax, digits
        end subroutine interface_plgxax
    end interface

    call interface_plgxax( digmax_out, digits_out )
    digmax = int(digmax_out)
    digits = int(digits_out)
  end subroutine plgxax_impl

subroutine plgyax_impl( digmax, digits )
    integer, intent(out) :: digmax, digits

    integer(kind=private_plint) :: digmax_out, digits_out

    interface
        subroutine interface_plgyax( digmax, digits ) bind( c, name = 'c_plgyax' )
            import :: private_plint
            implicit none
            integer(kind=private_plint), intent(out) :: digmax, digits
        end subroutine interface_plgyax
    end interface

    call interface_plgyax( digmax_out, digits_out )
    digmax = int(digmax_out)
    digits = int(digits_out)
  end subroutine plgyax_impl

subroutine plgzax_impl( digmax, digits )
    integer, intent(out) :: digmax, digits

    integer(kind=private_plint) :: digmax_out, digits_out

    interface
        subroutine interface_plgzax( digmax, digits ) bind( c, name = 'c_plgzax' )
            import :: private_plint
            implicit none
            integer(kind=private_plint), intent(out) :: digmax, digits
        end subroutine interface_plgzax
    end interface

    call interface_plgzax( digmax_out, digits_out )
    digmax = int(digmax_out)
    digits = int(digits_out)
  end subroutine plgzax_impl

subroutine plinit_impl()
    interface
        subroutine interface_plinit() bind( c, name = 'c_plinit' )
        end subroutine interface_plinit
     end interface
     call interface_plinit()
   end subroutine plinit_impl

subroutine pllab_impl( xlab, ylab, title )
   character(len=*), intent(in) :: xlab, ylab, title

   interface
       subroutine interface_pllab( xlab, ylab, title ) bind(c,name='c_pllab')
           implicit none
           character(len=1), dimension(*), intent(in) :: xlab, ylab, title
       end subroutine interface_pllab
   end interface

   call interface_pllab( trim(xlab)//c_null_char, trim(ylab)//c_null_char, trim(title)//c_null_char )

 end subroutine pllab_impl

subroutine pllsty_impl( lin )
    integer, intent(in) :: lin
    interface
        subroutine interface_pllsty( lin ) bind( c, name = 'c_pllsty' )
            import :: private_plint
            implicit none
            integer(kind=private_plint), value, intent(in) :: lin
        end subroutine interface_pllsty
    end interface

    call interface_pllsty( int(lin,kind=private_plint) )
  end subroutine pllsty_impl

subroutine plmap_double( proc, name, minx, maxx, miny, maxy )
  procedure(plmapform_proc_double) :: proc
  character*(*), intent(in) :: name
  real(kind=private_double), intent(in) :: minx, maxx, miny, maxy
  
  interface
     subroutine interface_plmap( proc, name, minx, maxx, miny, maxy ) &
          bind(c, name = 'c_plmap' )
       import :: c_funptr, private_plflt
       implicit none
       type(c_funptr), value, intent(in) :: proc
       character(len=1), dimension(*), intent(in) :: name
       real(kind=private_plflt), value, intent(in) :: minx, maxx, miny, maxy
     end subroutine interface_plmap
  end interface

  plmapform_double => proc

  call interface_plmap( c_funloc(plmapformf2c_double), trim(name)//c_null_char, &
       real(minx, kind=private_plflt), real(maxx, kind=private_plflt), &
       real(miny, kind=private_plflt), real(maxy, kind=private_plflt) )
end subroutine plmap_double

subroutine plmap_double_null( name, minx, maxx, miny, maxy )
  character*(*), intent(in) :: name
  real(kind=private_double), intent(in) :: minx, maxx, miny, maxy

  interface
     subroutine interface_plmap( proc, name, minx, maxx, miny, maxy ) &
          bind(c, name = 'c_plmap' )
       import :: c_funptr, private_plflt
       implicit none
       type(c_funptr), value, intent(in) :: proc
       character(len=1), dimension(*), intent(in) :: name
       real(kind=private_plflt), value, intent(in) :: minx, maxx, miny, maxy
     end subroutine interface_plmap
  end interface
  
  call interface_plmap( c_null_funptr, trim(name)//c_null_char, &
       real(minx, kind=private_plflt), real(maxx, kind=private_plflt), &
       real(miny, kind=private_plflt), real(maxy, kind=private_plflt) )
end subroutine plmap_double_null

subroutine plmap_single( proc, name, minx, maxx, miny, maxy )
  procedure(plmapform_proc_single) :: proc
  character*(*), intent(in) :: name
  real(kind=private_single), intent(in) :: minx, maxx, miny, maxy
  
  interface
     subroutine interface_plmap( proc, name, minx, maxx, miny, maxy ) &
          bind(c, name = 'c_plmap' )
       import :: c_funptr, private_plflt
       implicit none
       type(c_funptr), value, intent(in) :: proc
       character(len=1), dimension(*), intent(in) :: name
       real(kind=private_plflt), value, intent(in) :: minx, maxx, miny, maxy
     end subroutine interface_plmap
  end interface

  plmapform_single => proc

  call interface_plmap( c_funloc(plmapformf2c_single), trim(name)//c_null_char, &
       real(minx, kind=private_plflt), real(maxx, kind=private_plflt), &
       real(miny, kind=private_plflt), real(maxy, kind=private_plflt) )
end subroutine plmap_single

subroutine plmap_single_null( name, minx, maxx, miny, maxy )
  character*(*), intent(in) :: name
  real(kind=private_single), intent(in) :: minx, maxx, miny, maxy

  interface
     subroutine interface_plmap( proc, name, minx, maxx, miny, maxy ) &
          bind(c, name = 'c_plmap' )
       import :: c_funptr, private_plflt
       implicit none
       type(c_funptr), value, intent(in) :: proc
       character(len=1), dimension(*), intent(in) :: name
       real(kind=private_plflt), value, intent(in) :: minx, maxx, miny, maxy
     end subroutine interface_plmap
  end interface
  
  call interface_plmap( c_null_funptr, trim(name)//c_null_char, &
       real(minx, kind=private_plflt), real(maxx, kind=private_plflt), &
       real(miny, kind=private_plflt), real(maxy, kind=private_plflt) )
end subroutine plmap_single_null

subroutine plmapfill_double( proc, name, minx, maxx, miny, maxy, plotentries )
  procedure(plmapform_proc_double) :: proc
  character*(*), intent(in) :: name
  real(kind=private_double), intent(in) :: minx, maxx, miny, maxy
  integer, dimension(:), optional, target, intent(in) :: plotentries

  interface
     subroutine interface_plmapfill( proc, name, minx, maxx, miny, maxy, plotentries, nplotentries ) &
          bind(c, name = 'c_plmapfill' )
       import :: c_funptr, private_plflt, c_ptr, private_plint
       implicit none
       type(c_funptr), value, intent(in) :: proc
       character(len=1), dimension(*), intent(in) :: name
       real(kind=private_plflt), value, intent(in) :: minx, maxx, miny, maxy
       type(c_ptr), value, intent(in) :: plotentries
       integer(kind=private_plint), value, intent(in) :: nplotentries
     end subroutine interface_plmapfill
  end interface

  plmapform_double => proc

  if ( present(plotentries) ) then
     call interface_plmapfill( c_funloc(plmapformf2c_double), trim(name)//c_null_char, &
          real(minx, kind=private_plflt), real(maxx, kind=private_plflt), &
          real(miny, kind=private_plflt), real(maxy, kind=private_plflt), &
          c_loc(plotentries), size(plotentries, kind=private_plint) )
  else
     call interface_plmapfill( c_funloc(plmapformf2c_double), trim(name)//c_null_char, &
          real(minx, kind=private_plflt), real(maxx, kind=private_plflt), &
          real(miny, kind=private_plflt), real(maxy, kind=private_plflt), &
          c_null_ptr, 0_private_plint )
  endif
end subroutine plmapfill_double

subroutine plmapfill_double_null( name, minx, maxx, miny, maxy, plotentries )
  character*(*), intent(in) :: name
  real(kind=private_double), intent(in) :: minx, maxx, miny, maxy
  integer, dimension(:), optional, target, intent(in) :: plotentries

  interface
     subroutine interface_plmapfill( proc, name, minx, maxx, miny, maxy, plotentries, nplotentries ) &
          bind(c, name = 'c_plmapfill' )
       import :: c_funptr, private_plflt, c_ptr, private_plint
       implicit none
       type(c_funptr), value, intent(in) :: proc
       character(len=1), dimension(*), intent(in) :: name
       real(kind=private_plflt), value, intent(in) :: minx, maxx, miny, maxy
       type(c_ptr), value, intent(in) :: plotentries
       integer(kind=private_plint), value, intent(in) :: nplotentries
     end subroutine interface_plmapfill
  end interface
  
  if ( present(plotentries) ) then
     call interface_plmapfill( c_null_funptr, trim(name)//c_null_char, &
          real(minx, kind=private_plflt), real(maxx, kind=private_plflt), &
          real(miny, kind=private_plflt), real(maxy, kind=private_plflt), &
          c_loc(plotentries), size(plotentries, kind=private_plint) )
  else
     call interface_plmapfill( c_null_funptr, trim(name)//c_null_char, &
          real(minx, kind=private_plflt), real(maxx, kind=private_plflt), &
          real(miny, kind=private_plflt), real(maxy, kind=private_plflt), &
          c_null_ptr, 0_private_plint )
  endif
end subroutine plmapfill_double_null

subroutine plmapfill_single( proc, name, minx, maxx, miny, maxy, plotentries )
  procedure(plmapform_proc_single) :: proc
  character*(*), intent(in) :: name
  real(kind=private_single), intent(in) :: minx, maxx, miny, maxy
  integer, dimension(:), optional, target, intent(in) :: plotentries
  
  interface
     subroutine interface_plmapfill( proc, name, minx, maxx, miny, maxy, plotentries, nplotentries ) &
          bind(c, name = 'c_plmapfill' )
       import :: c_funptr, private_plflt, c_ptr, private_plint
       implicit none
       type(c_funptr), value, intent(in) :: proc
       character(len=1), dimension(*), intent(in) :: name
       real(kind=private_plflt), value, intent(in) :: minx, maxx, miny, maxy
       type(c_ptr), value, intent(in) :: plotentries
       integer(kind=private_plint), value, intent(in) :: nplotentries
     end subroutine interface_plmapfill
  end interface

  plmapform_single => proc

  if ( present(plotentries) ) then
     call interface_plmapfill( c_funloc(plmapformf2c_single), trim(name)//c_null_char, &
          real(minx, kind=private_plflt), real(maxx, kind=private_plflt), &
          real(miny, kind=private_plflt), real(maxy, kind=private_plflt), &
          c_loc(plotentries), size(plotentries, kind=private_plint) )
  else
     call interface_plmapfill( c_funloc(plmapformf2c_single), trim(name)//c_null_char, &
          real(minx, kind=private_plflt), real(maxx, kind=private_plflt), &
          real(miny, kind=private_plflt), real(maxy, kind=private_plflt), &
          c_null_ptr, 0_private_plint )
  endif
end subroutine plmapfill_single

subroutine plmapfill_single_null( name, minx, maxx, miny, maxy, plotentries )
  character*(*), intent(in) :: name
  real(kind=private_single), intent(in) :: minx, maxx, miny, maxy
  integer, dimension(:), optional, target, intent(in) :: plotentries

  interface
     subroutine interface_plmapfill( proc, name, minx, maxx, miny, maxy, plotentries, nplotentries ) &
          bind(c, name = 'c_plmapfill' )
       import :: c_funptr, private_plflt, c_ptr, private_plint
       implicit none
       type(c_funptr), value, intent(in) :: proc
       character(len=1), dimension(*), intent(in) :: name
       real(kind=private_plflt), value, intent(in) :: minx, maxx, miny, maxy
       type(c_ptr), value, intent(in) :: plotentries
       integer(kind=private_plint), value, intent(in) :: nplotentries
     end subroutine interface_plmapfill
  end interface
  
  if ( present(plotentries) ) then
     call interface_plmapfill( c_null_funptr, trim(name)//c_null_char, &
          real(minx, kind=private_plflt), real(maxx, kind=private_plflt), &
          real(miny, kind=private_plflt), real(maxy, kind=private_plflt), &
          c_loc(plotentries), size(plotentries, kind=private_plint) )
  else
     call interface_plmapfill( c_null_funptr, trim(name)//c_null_char, &
          real(minx, kind=private_plflt), real(maxx, kind=private_plflt), &
          real(miny, kind=private_plflt), real(maxy, kind=private_plflt), &
          c_null_ptr, 0_private_plint )
  endif
end subroutine plmapfill_single_null

subroutine plmapline_double( proc, name, minx, maxx, miny, maxy, plotentries )
  procedure(plmapform_proc_double) :: proc
  character*(*), intent(in) :: name
  real(kind=private_double), intent(in) :: minx, maxx, miny, maxy
  integer, dimension(:), optional, target, intent(in) :: plotentries
  
  interface
     subroutine interface_plmapline( proc, name, minx, maxx, miny, maxy, plotentries, nplotentries ) &
          bind(c, name = 'c_plmapline' )
       import :: c_funptr, private_plflt, c_ptr, private_plint
       implicit none
       type(c_funptr), value, intent(in) :: proc
       character(len=1), dimension(*), intent(in) :: name
       real(kind=private_plflt), value, intent(in) :: minx, maxx, miny, maxy
       type(c_ptr), value, intent(in) :: plotentries
       integer(kind=private_plint), value, intent(in) :: nplotentries
     end subroutine interface_plmapline
  end interface

  plmapform_double => proc

  if ( present(plotentries) ) then
     call interface_plmapline( c_funloc(plmapformf2c_double), trim(name)//c_null_char, &
          real(minx, kind=private_plflt), real(maxx, kind=private_plflt), &
          real(miny, kind=private_plflt), real(maxy, kind=private_plflt), &
          c_loc(plotentries), size(plotentries, kind=private_plint) )
  else
     call interface_plmapline( c_funloc(plmapformf2c_double), trim(name)//c_null_char, &
          real(minx, kind=private_plflt), real(maxx, kind=private_plflt), &
          real(miny, kind=private_plflt), real(maxy, kind=private_plflt), &
          c_null_ptr, 0_private_plint )
  endif
end subroutine plmapline_double

subroutine plmapline_double_null( name, minx, maxx, miny, maxy, plotentries )
  character*(*), intent(in) :: name
  real(kind=private_double), intent(in) :: minx, maxx, miny, maxy
  integer, dimension(:), optional, target, intent(in) :: plotentries

  interface
     subroutine interface_plmapline( proc, name, minx, maxx, miny, maxy, plotentries, nplotentries ) &
          bind(c, name = 'c_plmapline' )
       import :: c_funptr, private_plflt, c_ptr, private_plint
       implicit none
       type(c_funptr), value, intent(in) :: proc
       character(len=1), dimension(*), intent(in) :: name
       real(kind=private_plflt), value, intent(in) :: minx, maxx, miny, maxy
       type(c_ptr), value, intent(in) :: plotentries
       integer(kind=private_plint), value, intent(in) :: nplotentries
     end subroutine interface_plmapline
  end interface
  
  if ( present(plotentries) ) then
     call interface_plmapline( c_null_funptr, trim(name)//c_null_char, &
          real(minx, kind=private_plflt), real(maxx, kind=private_plflt), &
          real(miny, kind=private_plflt), real(maxy, kind=private_plflt), &
          c_loc(plotentries), size(plotentries, kind=private_plint) )
  else
     call interface_plmapline( c_null_funptr, trim(name)//c_null_char, &
          real(minx, kind=private_plflt), real(maxx, kind=private_plflt), &
          real(miny, kind=private_plflt), real(maxy, kind=private_plflt), &
          c_null_ptr, 0_private_plint )
  endif
end subroutine plmapline_double_null

subroutine plmapline_single( proc, name, minx, maxx, miny, maxy, plotentries )
  procedure(plmapform_proc_single) :: proc
  character*(*), intent(in) :: name
  real(kind=private_single), intent(in) :: minx, maxx, miny, maxy
  integer, dimension(:), optional, target, intent(in) :: plotentries
  
  interface
     subroutine interface_plmapline( proc, name, minx, maxx, miny, maxy, plotentries, nplotentries ) &
          bind(c, name = 'c_plmapline' )
       import :: c_funptr, private_plflt, c_ptr, private_plint
       implicit none
       type(c_funptr), value, intent(in) :: proc
       character(len=1), dimension(*), intent(in) :: name
       real(kind=private_plflt), value, intent(in) :: minx, maxx, miny, maxy
       type(c_ptr), value, intent(in) :: plotentries
       integer(kind=private_plint), value, intent(in) :: nplotentries
     end subroutine interface_plmapline
  end interface

  plmapform_single => proc

  if ( present(plotentries) ) then
     call interface_plmapline( c_funloc(plmapformf2c_single), trim(name)//c_null_char, &
          real(minx, kind=private_plflt), real(maxx, kind=private_plflt), &
          real(miny, kind=private_plflt), real(maxy, kind=private_plflt), &
          c_loc(plotentries), size(plotentries, kind=private_plint) )
  else
     call interface_plmapline( c_funloc(plmapformf2c_single), trim(name)//c_null_char, &
          real(minx, kind=private_plflt), real(maxx, kind=private_plflt), &
          real(miny, kind=private_plflt), real(maxy, kind=private_plflt), &
          c_null_ptr, 0_private_plint )
  endif
end subroutine plmapline_single

subroutine plmapline_single_null( name, minx, maxx, miny, maxy, plotentries )
  character*(*), intent(in) :: name
  real(kind=private_single), intent(in) :: minx, maxx, miny, maxy
  integer, dimension(:), optional, target, intent(in) :: plotentries

  interface
     subroutine interface_plmapline( proc, name, minx, maxx, miny, maxy, plotentries, nplotentries ) &
          bind(c, name = 'c_plmapline' )
       import :: c_funptr, private_plflt, c_ptr, private_plint
       implicit none
       type(c_funptr), value, intent(in) :: proc
       character(len=1), dimension(*), intent(in) :: name
       real(kind=private_plflt), value, intent(in) :: minx, maxx, miny, maxy
       type(c_ptr), value, intent(in) :: plotentries
       integer(kind=private_plint), value, intent(in) :: nplotentries
     end subroutine interface_plmapline
  end interface
  
  if ( present(plotentries) ) then
     call interface_plmapline( c_null_funptr, trim(name)//c_null_char, &
          real(minx, kind=private_plflt), real(maxx, kind=private_plflt), &
          real(miny, kind=private_plflt), real(maxy, kind=private_plflt), &
          c_loc(plotentries), size(plotentries, kind=private_plint) )
  else
     call interface_plmapline( c_null_funptr, trim(name)//c_null_char, &
          real(minx, kind=private_plflt), real(maxx, kind=private_plflt), &
          real(miny, kind=private_plflt), real(maxy, kind=private_plflt), &
          c_null_ptr, 0_private_plint )
  endif
end subroutine plmapline_single_null

subroutine plmapstring_double( proc, name, string, minx, maxx, miny, maxy, plotentries )
  procedure(plmapform_proc_double) :: proc
  character*(*), intent(in) :: name, string
  real(kind=private_double), intent(in) :: minx, maxx, miny, maxy
  integer, dimension(:), optional, target, intent(in) :: plotentries
  
  interface
     subroutine interface_plmapstring( proc, name, string, minx, maxx, miny, maxy, plotentries, nplotentries ) &
          bind(c, name = 'c_plmapstring' )
       import :: c_funptr, private_plflt, c_ptr, private_plint
       implicit none
       type(c_funptr), value, intent(in) :: proc
       character(len=1), dimension(*), intent(in) :: name, string
       real(kind=private_plflt), value, intent(in) :: minx, maxx, miny, maxy
       type(c_ptr), value, intent(in) :: plotentries
       integer(kind=private_plint), value, intent(in) :: nplotentries
     end subroutine interface_plmapstring
  end interface

  plmapform_double => proc

  if ( present(plotentries) ) then
     call interface_plmapstring( c_funloc(plmapformf2c_double), &
          trim(name)//c_null_char, trim(string)//c_null_char, &
          real(minx, kind=private_plflt), real(maxx, kind=private_plflt), &
          real(miny, kind=private_plflt), real(maxy, kind=private_plflt), &
          c_loc(plotentries), size(plotentries, kind=private_plint) )
  else
     call interface_plmapstring( c_funloc(plmapformf2c_double), &
          trim(name)//c_null_char, trim(string)//c_null_char, &
          real(minx, kind=private_plflt), real(maxx, kind=private_plflt), &
          real(miny, kind=private_plflt), real(maxy, kind=private_plflt), &
          c_null_ptr, 0_private_plint )
  endif
end subroutine plmapstring_double

subroutine plmapstring_double_null( name, string, minx, maxx, miny, maxy, plotentries )
  character*(*), intent(in) :: name, string
  real(kind=private_double), intent(in) :: minx, maxx, miny, maxy
  integer, dimension(:), optional, target, intent(in) :: plotentries

  interface
     subroutine interface_plmapstring( proc, name, string, minx, maxx, miny, maxy, plotentries, nplotentries ) &
          bind(c, name = 'c_plmapstring' )
       import :: c_funptr, private_plflt, c_ptr, private_plint
       implicit none
       type(c_funptr), value, intent(in) :: proc
       character(len=1), dimension(*), intent(in) :: name, string
       real(kind=private_plflt), value, intent(in) :: minx, maxx, miny, maxy
       type(c_ptr), value, intent(in) :: plotentries
       integer(kind=private_plint), value, intent(in) :: nplotentries
     end subroutine interface_plmapstring
  end interface
  
  if ( present(plotentries) ) then
     call interface_plmapstring( c_null_funptr, &
          trim(name)//c_null_char, trim(string)//c_null_char, &
          real(minx, kind=private_plflt), real(maxx, kind=private_plflt), &
          real(miny, kind=private_plflt), real(maxy, kind=private_plflt), &
          c_loc(plotentries), size(plotentries, kind=private_plint) )
  else
     call interface_plmapstring( c_null_funptr, &
          trim(name)//c_null_char, trim(string)//c_null_char, &
          real(minx, kind=private_plflt), real(maxx, kind=private_plflt), &
          real(miny, kind=private_plflt), real(maxy, kind=private_plflt), &
          c_null_ptr, 0_private_plint )
  endif
end subroutine plmapstring_double_null

subroutine plmapstring_single( proc, name, string, minx, maxx, miny, maxy, plotentries )
  procedure(plmapform_proc_single) :: proc
  character*(*), intent(in) :: name, string
  real(kind=private_single), intent(in) :: minx, maxx, miny, maxy
  integer, dimension(:), optional, target, intent(in) :: plotentries
  
  interface
     subroutine interface_plmapstring( proc, name, string, minx, maxx, miny, maxy, plotentries, nplotentries ) &
          bind(c, name = 'c_plmapstring' )
       import :: c_funptr, private_plflt, c_ptr, private_plint
       implicit none
       type(c_funptr), value, intent(in) :: proc
       character(len=1), dimension(*), intent(in) :: name, string
       real(kind=private_plflt), value, intent(in) :: minx, maxx, miny, maxy
       type(c_ptr), value, intent(in) :: plotentries
       integer(kind=private_plint), value, intent(in) :: nplotentries
     end subroutine interface_plmapstring
  end interface

  plmapform_single => proc

  if ( present(plotentries) ) then
     call interface_plmapstring( c_funloc(plmapformf2c_single), &
          trim(name)//c_null_char, trim(string)//c_null_char, &
          real(minx, kind=private_plflt), real(maxx, kind=private_plflt), &
          real(miny, kind=private_plflt), real(maxy, kind=private_plflt), &
          c_loc(plotentries), size(plotentries, kind=private_plint) )
  else
     call interface_plmapstring( c_funloc(plmapformf2c_single), &
          trim(name)//c_null_char, trim(string)//c_null_char, &
          real(minx, kind=private_plflt), real(maxx, kind=private_plflt), &
          real(miny, kind=private_plflt), real(maxy, kind=private_plflt), &
          c_null_ptr, 0_private_plint )
  endif
end subroutine plmapstring_single

subroutine plmapstring_single_null( name, string, minx, maxx, miny, maxy, plotentries )
  character*(*), intent(in) :: name, string
  real(kind=private_single), intent(in) :: minx, maxx, miny, maxy
  integer, dimension(:), optional, target, intent(in) :: plotentries

  interface
     subroutine interface_plmapstring( proc, name, string, minx, maxx, miny, maxy, plotentries, nplotentries ) &
          bind(c, name = 'c_plmapstring' )
       import :: c_funptr, private_plflt, c_ptr, private_plint
       implicit none
       type(c_funptr), value, intent(in) :: proc
       character(len=1), dimension(*), intent(in) :: name, string
       real(kind=private_plflt), value, intent(in) :: minx, maxx, miny, maxy
       type(c_ptr), value, intent(in) :: plotentries
       integer(kind=private_plint), value, intent(in) :: nplotentries
     end subroutine interface_plmapstring
  end interface
  
  if ( present(plotentries) ) then
     call interface_plmapstring( c_null_funptr, &
          trim(name)//c_null_char, trim(string)//c_null_char, &
          real(minx, kind=private_plflt), real(maxx, kind=private_plflt), &
          real(miny, kind=private_plflt), real(maxy, kind=private_plflt), &
          c_loc(plotentries), size(plotentries, kind=private_plint) )
  else
     call interface_plmapstring( c_null_funptr, &
          trim(name)//c_null_char, trim(string)//c_null_char, &
          real(minx, kind=private_plflt), real(maxx, kind=private_plflt), &
          real(miny, kind=private_plflt), real(maxy, kind=private_plflt), &
          c_null_ptr, 0_private_plint )
  endif
end subroutine plmapstring_single_null

subroutine plmeridians_double( proc, dlong, dlat, minlong, maxlong, minlat, maxlat )
  procedure(plmapform_proc_double) :: proc
  real(kind=private_double), intent(in) :: dlong, dlat, minlong, maxlong, minlat, maxlat
  
  interface
     subroutine interface_plmeridians( proc, dlong, dlat, minlong, maxlong, minlat, maxlat ) &
          bind(c, name = 'c_plmeridians' )
       import :: c_funptr, private_plflt
       implicit none
       type(c_funptr), value, intent(in) :: proc
       real(kind=private_plflt), value, intent(in) :: dlong, dlat, minlong, maxlong, minlat, maxlat
     end subroutine interface_plmeridians
  end interface

  plmapform_double => proc

  call interface_plmeridians( c_funloc(plmapformf2c_double), &
       real(dlong, kind=private_plflt), real(dlat, kind=private_plflt), &
       real(minlong, kind=private_plflt), real(maxlong, kind=private_plflt), &
       real(minlat, kind=private_plflt), real(maxlat, kind=private_plflt) )
end subroutine plmeridians_double

subroutine plmeridians_double_null( dlong, dlat, minlong, maxlong, minlat, maxlat )
  real(kind=private_double), intent(in) :: dlong, dlat, minlong, maxlong, minlat, maxlat

  interface
     subroutine interface_plmeridians( proc, dlong, dlat, minlong, maxlong, minlat, maxlat ) &
          bind(c, name = 'c_plmeridians' )
       import :: c_funptr, private_plflt
       implicit none
       type(c_funptr), value, intent(in) :: proc
       real(kind=private_plflt), value, intent(in) :: dlong, dlat, minlong, maxlong, minlat, maxlat
     end subroutine interface_plmeridians
  end interface
  
  call interface_plmeridians( c_null_funptr, &
       real(dlong, kind=private_plflt), real(dlat, kind=private_plflt), &
       real(minlong, kind=private_plflt), real(maxlong, kind=private_plflt), &
       real(minlat, kind=private_plflt), real(maxlat, kind=private_plflt) )
end subroutine plmeridians_double_null

subroutine plmeridians_single( proc, dlong, dlat, minlong, maxlong, minlat, maxlat )
  procedure(plmapform_proc_single) :: proc
  real(kind=private_single), intent(in) :: dlong, dlat, minlong, maxlong, minlat, maxlat
  
  interface
     subroutine interface_plmeridians( proc, dlong, dlat, minlong, maxlong, minlat, maxlat ) &
          bind(c, name = 'c_plmeridians' )
       import :: c_funptr, private_plflt
       implicit none
       type(c_funptr), value, intent(in) :: proc
       real(kind=private_plflt), value, intent(in) :: dlong, dlat, minlong, maxlong, minlat, maxlat
     end subroutine interface_plmeridians
  end interface

  plmapform_single => proc

  call interface_plmeridians( c_funloc(plmapformf2c_single), &
       real(dlong, kind=private_plflt), real(dlat, kind=private_plflt), &
       real(minlong, kind=private_plflt), real(maxlong, kind=private_plflt), &
       real(minlat, kind=private_plflt), real(maxlat, kind=private_plflt) )
end subroutine plmeridians_single

subroutine plmeridians_single_null( dlong, dlat, minlong, maxlong, minlat, maxlat )
  real(kind=private_single), intent(in) :: dlong, dlat, minlong, maxlong, minlat, maxlat

  interface
     subroutine interface_plmeridians( proc, dlong, dlat, minlong, maxlong, minlat, maxlat ) &
          bind(c, name = 'c_plmeridians' )
       import :: c_funptr, private_plflt
       implicit none
       type(c_funptr), value, intent(in) :: proc
       real(kind=private_plflt), value, intent(in) :: dlong, dlat, minlong, maxlong, minlat, maxlat
     end subroutine interface_plmeridians
  end interface
  
  call interface_plmeridians( c_null_funptr, &
       real(dlong, kind=private_plflt), real(dlat, kind=private_plflt), &
       real(minlong, kind=private_plflt), real(maxlong, kind=private_plflt), &
       real(minlat, kind=private_plflt), real(maxlat, kind=private_plflt) )
end subroutine plmeridians_single_null

subroutine plmkstrm_impl( strm )
    integer, intent(in) :: strm
    interface
        subroutine interface_plmkstrm( strm ) bind( c, name = 'c_plmkstrm' )
            import :: private_plint
            implicit none
            integer(kind=private_plint), value, intent(in) :: strm
        end subroutine interface_plmkstrm
    end interface

    call interface_plmkstrm( int(strm,kind=private_plint) )
  end subroutine plmkstrm_impl

function plparseopts_impl(mode)
  integer :: plparseopts_impl !function type
  integer, intent(in) :: mode

  integer :: iargs_local, numargs_local
  integer(kind=private_plint) :: numargsp1_inout

  integer, parameter :: maxargs_local = 100
  character (len=maxlen), dimension(0:maxargs_local) :: arg_local
  character(len=1), dimension(:,:), allocatable :: cstring_arg_local
  type(c_ptr), dimension(:), allocatable :: cstring_address_arg_inout

  interface
     function interface_plparseopts( argc, argv, mode ) bind(c,name='c_plparseopts')
       import :: c_ptr
       import :: private_plint
       implicit none
       integer(kind=private_plint) :: interface_plparseopts !function type
       integer(kind=private_plint), value, intent(in) :: mode
       ! The C routine changes both argc and argv
       integer(kind=private_plint), intent(inout) :: argc
       type(c_ptr), dimension(*), intent(inout) :: argv
     end function  interface_plparseopts
  end interface

  numargs_local = command_argument_count()
  if (numargs_local < 0) then
     !       This actually happened historically on a badly linked Cygwin platform.
     write(error_unit,'(a)') 'f95 plparseopts ERROR: negative number of arguments'
     plparseopts_impl = 1
     return
  endif
  if(numargs_local > maxargs_local) then
     write(error_unit,'(a)') 'f95 plparseopts ERROR: too many arguments'
     plparseopts_impl = 1
     return
  endif
  do iargs_local = 0, numargs_local
     call get_command_argument(iargs_local, arg_local(iargs_local))
  enddo

  call character_array_to_c( cstring_arg_local, cstring_address_arg_inout, arg_local(0:numargs_local) )

  ! The inout suffix is to remind us that the c_plparseopt routine changes the
  ! value of numargsp1_inout and the values of the vector elements of cstring_address_arg_inout.
  ! (and maybe even the elements of cstring_arg_local).  However, these changes in
  ! contents of vector and possibly array should not affect the deallocation of
  ! this vector and the array, and I have checked with valgrind that there are
  ! no memory management issues with this approach.
  numargsp1_inout = int(numargs_local+1, kind=private_plint)
  plparseopts_impl = int(interface_plparseopts( numargsp1_inout, &
       cstring_address_arg_inout, int(mode, kind=private_plint)))
end function plparseopts_impl

subroutine plpat_impl( inc, del )
    integer, dimension(:), intent(in) :: inc, del

    integer(kind=private_plint) :: nlin_local

    interface
        subroutine interface_plpat( nlin, inc, del ) bind( c, name = 'c_plpat' )
            import :: private_plint
            implicit none
            integer(kind=private_plint), value, intent(in) :: nlin
            integer(kind=private_plint), dimension(*), intent(in) :: inc, del
        end subroutine interface_plpat
     end interface

     nlin_local = size(inc, kind=private_plint)
     if(nlin_local /= size(del, kind=private_plint) ) then
        write(0,*) "f95 plpat ERROR: sizes of inc and del are not consistent"
        return
     endif

    call interface_plpat( nlin_local, int(inc,kind=private_plint), int(del,kind=private_plint) )

  end subroutine plpat_impl

subroutine plprec_impl( setp, prec )
    integer, intent(in) :: setp, prec
    interface
        subroutine interface_plprec( setp, prec ) bind( c, name = 'c_plprec' )
            import :: private_plint
            implicit none
            integer(kind=private_plint), value, intent(in) :: setp, prec
        end subroutine interface_plprec
    end interface

    call interface_plprec( int(setp,kind=private_plint), int(prec,kind=private_plint) )
  end subroutine plprec_impl

subroutine plpsty_impl( patt )
    integer, intent(in) :: patt
    interface
        subroutine interface_plpsty( patt ) bind( c, name = 'c_plpsty' )
            import :: private_plint
            implicit none
            integer(kind=private_plint), value, intent(in) :: patt
        end subroutine interface_plpsty
    end interface

    call interface_plpsty( int(patt,kind=private_plint) )
  end subroutine plpsty_impl

! Return type is not part of the disambiguation so we provide
! one explicit double-precision version rather than both types.
function plrandd_impl()

  real(kind=private_double) :: plrandd_impl !function type

    interface
        function interface_plrandd() bind(c,name='c_plrandd')
            import :: private_plflt
            implicit none
            real(kind=private_plflt) :: interface_plrandd !function type
        end function interface_plrandd
    end interface

    plrandd_impl = real(interface_plrandd(), kind=private_double)
end function plrandd_impl

subroutine plreplot_impl()
    interface
        subroutine interface_plreplot() bind(c,name='c_plreplot')
        end subroutine interface_plreplot
     end interface
     call interface_plreplot()
   end subroutine plreplot_impl

subroutine plscmap0_impl( r, g, b )
    integer, dimension(:), intent(in) :: r, g, b

    interface
        subroutine interface_plscmap0( r, g, b, n ) bind(c,name='c_plscmap0')
            import :: private_plint
            implicit none
            integer(kind=private_plint), dimension(*), intent(in) :: r, g, b
            integer(kind=private_plint), value, intent(in) :: n
        end subroutine interface_plscmap0
    end interface

    call interface_plscmap0( int(r,kind=private_plint), int(g,kind=private_plint), int(b,kind=private_plint), &
                     size(r,kind=private_plint) )
  end subroutine plscmap0_impl

subroutine plscmap0n_impl( n )
    integer, intent(in) :: n
    interface
        subroutine interface_plscmap0n( n ) bind( c, name = 'c_plscmap0n' )
            import :: private_plint
            implicit none
            integer(kind=private_plint), value, intent(in) :: n
        end subroutine interface_plscmap0n
    end interface

    call interface_plscmap0n( int(n,kind=private_plint) )
  end subroutine plscmap0n_impl

subroutine plscmap1_impl( r, g, b )
    integer, dimension(:), intent(in) :: r, g, b

    interface
        subroutine interface_plscmap1( r, g, b,  n ) bind(c,name='c_plscmap1')
            import :: private_plint
            implicit none
            integer(kind=private_plint), dimension(*), intent(in) :: r, g, b
            integer(kind=private_plint), value, intent(in) :: n
        end subroutine interface_plscmap1
    end interface

    call interface_plscmap1( int(r,kind=private_plint), int(g,kind=private_plint), int(b,kind=private_plint), &
         size(r,kind=private_plint) )
end subroutine plscmap1_impl

subroutine plscmap1n_impl( n )
    integer, intent(in) :: n
    interface
        subroutine interface_plscmap1n( n ) bind( c, name = 'c_plscmap1n' )
            import :: private_plint
            implicit none
            integer(kind=private_plint), value, intent(in) :: n
        end subroutine interface_plscmap1n
    end interface

    call interface_plscmap1n( int(n,kind=private_plint) )
  end subroutine plscmap1n_impl

subroutine plscol0_impl( icol, r, g, b )
    integer, intent(in) :: icol, r, g, b
    interface
        subroutine interface_plscol0( icol, r, g, b ) bind( c, name = 'c_plscol0' )
            import :: private_plint
            implicit none
            integer(kind=private_plint), value, intent(in) :: icol, r, g, b
        end subroutine interface_plscol0
    end interface

    call interface_plscol0( int(icol,kind=private_plint), &
                    int(r,kind=private_plint), int(g,kind=private_plint), int(b,kind=private_plint) )
  end subroutine plscol0_impl

subroutine plscolbg_impl( r, g, b )
    integer, intent(in) :: r, g, b
    interface
        subroutine interface_plscolbg( r, g, b ) bind( c, name = 'c_plscolbg' )
            import :: private_plint
            implicit none
            integer(kind=private_plint), value, intent(in) :: r, g, b
        end subroutine interface_plscolbg
    end interface

    call interface_plscolbg( int(r,kind=private_plint), int(g,kind=private_plint), int(b,kind=private_plint) )
  end subroutine plscolbg_impl


subroutine plscolor_impl( color )
    integer, intent(in) :: color
    interface
        subroutine interface_plscolor( color ) bind( c, name = 'c_plscolor' )
            import :: private_plint
            implicit none
            integer(kind=private_plint), value, intent(in) :: color
        end subroutine interface_plscolor
    end interface

    call interface_plscolor( int(color,kind=private_plint) )
  end subroutine plscolor_impl

subroutine plscompression_impl( compression )
    integer, intent(in) :: compression
    interface
        subroutine interface_plscompression( compression ) bind( c, name = 'c_plscompression' )
            import :: private_plint
            implicit none
            integer(kind=private_plint), value, intent(in) :: compression
        end subroutine interface_plscompression
    end interface

    call interface_plscompression( int(compression,kind=private_plint) )
  end subroutine plscompression_impl

subroutine plsdev_impl( devname )
   character(len=*), intent(in) :: devname

   interface
       subroutine interface_plsdev( devname ) bind(c,name='c_plsdev')
           implicit none
           character(len=1), dimension(*), intent(in) :: devname
       end subroutine interface_plsdev
   end interface

   call interface_plsdev( trim(devname)//c_null_char )

 end subroutine plsdev_impl

subroutine plsdrawmode_impl( mode )
    integer, intent(in) :: mode
    interface
        subroutine interface_plsdrawmode( mode ) bind( c, name = 'c_plsdrawmode' )
            import :: private_plint
            implicit none
            integer(kind=private_plint), value, intent(in) :: mode
        end subroutine interface_plsdrawmode
    end interface

    call interface_plsdrawmode( int(mode,kind=private_plint) )
  end subroutine plsdrawmode_impl

subroutine plseed_impl( s )
    integer, intent(in) :: s
    interface
        subroutine interface_plseed( s ) bind( c, name = 'c_plseed' )
            import :: private_plint
            implicit none
            integer(kind=private_plint), value, intent(in) :: s
        end subroutine interface_plseed
    end interface

    call interface_plseed( int(s,kind=private_plint) )
  end subroutine plseed_impl

! TODO: character-version
subroutine plsesc_impl( esc )
    integer, intent(in) :: esc
    interface
        subroutine interface_plsesc( esc ) bind( c, name = 'c_plsesc' )
            import :: private_plint
            implicit none
            integer(kind=private_plint), value, intent(in) :: esc
        end subroutine interface_plsesc
    end interface

    call interface_plsesc( int(esc,kind=private_plint) )
  end subroutine plsesc_impl

function plsetopt_impl( opt, optarg )
  integer :: plsetopt_impl !function type
  character(len=*), intent(in) :: opt, optarg
  

   interface
       function interface_plsetopt( opt, optarg ) bind(c,name='c_plsetopt')
           import :: private_plint 
           implicit none
           integer(kind=private_plint) :: interface_plsetopt !function type
           character(len=1), dimension(*), intent(in) :: opt, optarg
       end function interface_plsetopt
   end interface

   plsetopt_impl = int(interface_plsetopt( trim(opt)//c_null_char, trim(optarg)//c_null_char ))

end function plsetopt_impl

subroutine plsfam_impl( fam, num, bmax )
    integer, intent(in) :: fam, num, bmax
    interface
        subroutine interface_plsfam( fam, num, bmax ) bind( c, name = 'c_plsfam' )
            import :: private_plint
            implicit none
            integer(kind=private_plint), value, intent(in) :: fam, num, bmax
        end subroutine interface_plsfam
    end interface

    call interface_plsfam( int(fam,kind=private_plint), int(num,kind=private_plint), int(bmax,kind=private_plint) )
  end subroutine plsfam_impl

subroutine plsfci_impl( fci )
    integer, intent(in) :: fci

    interface
        subroutine interface_plsfci( fci ) bind( c, name = 'c_plsfci' )
            import :: private_plunicode
            implicit none
            integer(kind=private_plunicode), value, intent(in) :: fci
        end subroutine interface_plsfci
    end interface

    call interface_plsfci( int(fci,kind=private_plunicode) )

end subroutine plsfci_impl

subroutine plsfnam_impl( fnam )
   character(len=*), intent(in) :: fnam

   interface
       subroutine interface_plsfnam( fnam ) bind(c,name='c_plsfnam')
           implicit none
           character(len=1), dimension(*), intent(in) :: fnam
       end subroutine interface_plsfnam
   end interface

   call interface_plsfnam( trim(fnam)//c_null_char )

 end subroutine plsfnam_impl

subroutine plsfont_impl( family, style, weight )
    integer, intent(in) :: family, style, weight
    interface
        subroutine interface_plsfont( family, style, weight ) bind( c, name = 'c_plsfont' )
            import :: private_plint
            implicit none
            integer(kind=private_plint), value, intent(in) :: family, style, weight
        end subroutine interface_plsfont
    end interface

    call interface_plsfont( int(family,kind=private_plint), int(style,kind=private_plint), int(weight,kind=private_plint) )
  end subroutine plsfont_impl

! Only provide double-precison version because of disambiguation
! problems with the corresponding single-precision version.
subroutine plslabelfunc_data_double( proc, data )
    procedure(pllabeler_proc_data_double) :: proc
    type(c_ptr), intent(in) :: data
    interface
        subroutine interface_plslabelfunc( proc, data ) bind(c, name = 'c_plslabelfunc' )
            import :: c_funptr, c_ptr
            type(c_funptr), value, intent(in) :: proc
            type(c_ptr), value, intent(in) :: data
        end subroutine interface_plslabelfunc
    end interface

    pllabeler_data_double => proc
    call interface_plslabelfunc( c_funloc(pllabelerf2c_data_double), data )
end subroutine plslabelfunc_data_double

! Only provide double-precison version because of disambiguation
! problems with the corresponding single-precision version.
subroutine plslabelfunc_double( proc )
    procedure(pllabeler_proc_double) :: proc
    interface
        subroutine interface_plslabelfunc( proc, data ) bind(c, name = 'c_plslabelfunc' )
            import :: c_funptr, c_ptr
            type(c_funptr), value, intent(in) :: proc
            type(c_ptr), value, intent(in) :: data
        end subroutine interface_plslabelfunc
    end interface

    pllabeler_double => proc
    call interface_plslabelfunc( c_funloc(pllabelerf2c_double), c_null_ptr )
end subroutine plslabelfunc_double

subroutine plslabelfunc_null

    interface
        subroutine interface_plslabelfunc( proc, data ) bind(c, name = 'c_plslabelfunc' )
            import :: c_funptr, c_ptr
            type(c_funptr), value, intent(in) :: proc
            type(c_ptr), value, intent(in) :: data
        end subroutine interface_plslabelfunc
    end interface

    call interface_plslabelfunc( c_null_funptr, c_null_ptr )
end subroutine plslabelfunc_null

! Probably would be better to define this in redacted form, but it is not documented that
! way, and the python interface also does not use redacted form.  So leave it for now.
! I (AWI) followed advice in <http://stackoverflow.com/questions/10755896/fortran-how-to-store-value-255-into-one-byte>
! for the type statement for plotmem
subroutine plsmem_impl( maxx, maxy, plotmem )
    integer, intent(in) :: maxx, maxy
    character(kind=c_char), dimension(:, :, :), target, intent(in) :: plotmem
    interface
        subroutine interface_plsmem( maxx, maxy, plotmem ) bind( c, name = 'c_plsmem' )
            import :: c_ptr
            import :: private_plint
            implicit none
            integer(kind=private_plint), value, intent(in) :: maxx, maxy
            type(c_ptr), value, intent(in) :: plotmem
        end subroutine interface_plsmem
     end interface

     ! We need a first dimension of 3 to have space for RGB
     if( 3 /= size(plotmem,1) ) then
        write(0,*) "f95 plsmem ERROR: first dimension of plotmem is not 3"
        return
     endif

     ! Since not defined in redacted form, we at least check that
     ! maxx, and maxy are consistent with the second and third dimensions of plotmem.
     if( maxx /= size(plotmem,2) .or. maxy /= size(plotmem,3) ) then
        write(0,*) "f95 plsmem ERROR: maxx and/or maxy not consistent with second and third plotmem dimensions"
        return
     endif
    call interface_plsmem( int(maxx,kind=private_plint), int(maxy,kind=private_plint),  c_loc(plotmem))
  end subroutine plsmem_impl

! Probably would be better to define this in redacted form, but it is not documented that
! way, and the python interface also does not use redacted form.  So leave it for now.
! I (AWI) followed advice in <http://stackoverflow.com/questions/10755896/fortran-how-to-store-value-255-into-one-byte>
! for the type statement for plotmem
subroutine plsmema_impl( maxx, maxy, plotmem )
    integer, intent(in) :: maxx, maxy
    character(kind=c_char), dimension(:, :, :), target, intent(in) :: plotmem
    interface
        subroutine interface_plsmema( maxx, maxy, plotmem ) bind( c, name = 'c_plsmema' )
            import :: c_ptr
            import :: private_plint
            implicit none
            integer(kind=private_plint), value, intent(in) :: maxx, maxy
            type(c_ptr), value, intent(in) :: plotmem
        end subroutine interface_plsmema
     end interface

     ! We need a first dimension of 4 to have space for RGBa
     if( 4 /= size(plotmem,1) ) then
        write(0,*) "f95 plsmema ERROR: first dimension of plotmem is not 4"
        return
     endif

     ! Since not defined in redacted form, we at least check that
     ! maxx, and maxy are consistent with the second and third dimensions of plotmem.
     if( maxx /= size(plotmem,2) .or. maxy /= size(plotmem,3) ) then
        write(0,*) "f95 plsmema ERROR: maxx and/or maxy not consistent with second and third plotmem dimensions"
        return
     endif
    call interface_plsmema( int(maxx,kind=private_plint), int(maxy,kind=private_plint),  c_loc(plotmem))
  end subroutine plsmema_impl

subroutine plsori_impl( rot )
    integer, intent(in) :: rot
    interface
        subroutine interface_plsori( rot ) bind( c, name = 'c_plsori' )
            import :: private_plint
            implicit none
            integer(kind=private_plint), value, intent(in) :: rot
        end subroutine interface_plsori
    end interface

    call interface_plsori( int(rot,kind=private_plint) )
  end subroutine plsori_impl

subroutine plspal0_impl( filename )
  character(len=*), intent(in) :: filename

   interface
       subroutine interface_plspal0( filename ) bind(c,name='c_plspal0')
           implicit none
           character(len=1), dimension(*), intent(in) :: filename
       end subroutine interface_plspal0
   end interface

   call interface_plspal0( trim(filename)//c_null_char )

 end subroutine plspal0_impl

subroutine plspal1_impl( filename, interpolate )
  character(len=*), intent(in) :: filename
  logical, intent(in) :: interpolate

   interface
       subroutine interface_plspal1( filename, interpolate ) bind(c,name='c_plspal1')
           import :: private_plbool
           implicit none
           integer(kind=private_plbool), value, intent(in) :: interpolate
           character(len=1), dimension(*), intent(in) :: filename
       end subroutine interface_plspal1
   end interface

   call interface_plspal1( trim(filename)//c_null_char, int( merge(1,0,interpolate),kind=private_plbool) )

 end subroutine plspal1_impl

subroutine plspause_impl( pause )
    logical, intent(in) :: pause

    interface
        subroutine interface_plspause( pause ) bind(c,name='c_plspause')
            import :: private_plbool
            implicit none
            integer(kind=private_plbool), value, intent(in) :: pause
        end subroutine interface_plspause
    end interface

   call interface_plspause( int( merge(1,0,pause),kind=private_plbool) )
 end subroutine plspause_impl

subroutine plsstrm_impl( strm )
    integer, intent(in) :: strm
    interface
        subroutine interface_plsstrm( strm ) bind( c, name = 'c_plsstrm' )
            import :: private_plint
            implicit none
            integer(kind=private_plint), value, intent(in) :: strm
        end subroutine interface_plsstrm
    end interface

    call interface_plsstrm( int(strm,kind=private_plint) )
  end subroutine plsstrm_impl

subroutine plssub_impl( nx, ny )
    integer, intent(in) :: nx, ny
    interface
        subroutine interface_plssub( nx, ny ) bind( c, name = 'c_plssub' )
            import :: private_plint
            implicit none
            integer(kind=private_plint), value, intent(in) :: nx, ny
        end subroutine interface_plssub
    end interface

    call interface_plssub( int(nx,kind=private_plint), int(ny,kind=private_plint) )
  end subroutine plssub_impl

subroutine plstar_impl( nx, ny )
    integer, intent(in) :: nx, ny
    interface
        subroutine interface_plstar( nx, ny ) bind( c, name = 'c_plstar' )
            import :: private_plint
            implicit none
            integer(kind=private_plint), value, intent(in) :: nx, ny
        end subroutine interface_plstar
    end interface

    call interface_plstar( int(nx,kind=private_plint), int(ny,kind=private_plint) )
  end subroutine plstar_impl

subroutine plstart_impl( devname, nx, ny )
    integer, intent(in) :: nx, ny
    character(len=*), intent(in) :: devname
    interface
        subroutine interface_plstart( devname, nx, ny ) bind( c, name = 'c_plstart' )
            import :: private_plint
            implicit none
            integer(kind=private_plint), value, intent(in) :: nx, ny
            character(len=1), dimension(*), intent(in) :: devname
        end subroutine interface_plstart
    end interface

    call interface_plstart( trim(devname)//c_null_char, int(nx,kind=private_plint), int(ny,kind=private_plint) )
  end subroutine plstart_impl

! Only provide double-precison version because of disambiguation
! problems with the corresponding single-precision version.
subroutine plstransform_data_double( proc, data )
    procedure(pltransform_proc_data_double) :: proc
    type(c_ptr), intent(in) :: data
    interface
        subroutine interface_plstransform( proc, data ) bind(c, name = 'c_plstransform' )
            import :: c_funptr, c_ptr
            type(c_funptr), value, intent(in) :: proc
            type(c_ptr), value, intent(in) :: data
        end subroutine interface_plstransform
    end interface

    pltransform_data_double => proc
    call interface_plstransform( c_funloc(pltransformf2c_data_double), data )
end subroutine plstransform_data_double

! Only provide double-precison version because of disambiguation
! problems with the corresponding single-precision version.
subroutine plstransform_double( proc )
    procedure(pltransform_proc_double) :: proc
    interface
        subroutine interface_plstransform( proc, data ) bind(c, name = 'c_plstransform' )
            import :: c_funptr, c_ptr
            type(c_funptr), value, intent(in) :: proc
            type(c_ptr), value, intent(in) :: data
        end subroutine interface_plstransform
    end interface

    pltransform_double => proc
    call interface_plstransform( c_funloc(pltransformf2c_double), c_null_ptr )
end subroutine plstransform_double

subroutine plstransform_null
    interface
        subroutine interface_plstransform( proc, data ) bind(c, name = 'c_plstransform' )
            import :: c_funptr, c_ptr
            type(c_funptr), value, intent(in) :: proc
            type(c_ptr), value, intent(in) :: data
        end subroutine interface_plstransform
    end interface

    call interface_plstransform( c_null_funptr, c_null_ptr )
end subroutine plstransform_null

subroutine plstripd_impl( id )
    integer, intent(in) :: id
    interface
        subroutine interface_plstripd( id ) bind( c, name = 'c_plstripd' )
            import :: private_plint
            implicit none
            integer(kind=private_plint), value, intent(in) :: id
        end subroutine interface_plstripd
    end interface

    call interface_plstripd( int(id,kind=private_plint) )
  end subroutine plstripd_impl

subroutine plstyl_array( mark, space )
    integer, dimension(:), intent(in) :: mark, space

    call plstyl_n_array( size(mark), mark, space )
end subroutine plstyl_array

subroutine plstyl_n_array( n, mark, space )
    integer, intent(in) :: n
    integer, dimension(:), intent(in) :: mark, space
    interface
        subroutine interface_plstyl( n, mark, space ) bind( c, name = 'c_plstyl' )
            import :: private_plint
            implicit none
            integer(kind=private_plint), value, intent(in) :: n
            integer(kind=private_plint), dimension(*), intent(in) :: mark, space
        end subroutine interface_plstyl
    end interface

    call interface_plstyl( int(n,kind=private_plint), int(mark,kind=private_plint), int(space,kind=private_plint) )
end subroutine plstyl_n_array

subroutine plstyl_scalar( n, mark, space )
    integer, intent(in) :: n, mark, space

    call plstyl_n_array( n, (/ mark /), (/ space /) )
end subroutine plstyl_scalar

subroutine plsvect_double( arrowx, arrowy, fill )
  logical, intent(in) :: fill
  real(kind=private_double), dimension(:), intent(in) :: arrowx, arrowy

  integer(kind=private_plint) :: npts_local

    interface
        subroutine interface_plsvect( arrowx, arrowy, npts,  fill ) bind(c,name='c_plsvect')
            import :: private_plint, private_plbool, private_plflt
            implicit none
            integer(kind=private_plint), value, intent(in) :: npts
            integer(kind=private_plbool), value, intent(in) :: fill
            real(kind=private_plflt), dimension(*), intent(in) :: arrowx, arrowy
        end subroutine interface_plsvect
     end interface

     npts_local = size(arrowx, kind=private_plint)
     if(npts_local /= size(arrowy, kind=private_plint) ) then
        write(0,*) "f95 plsvect ERROR: sizes of arrowx and arrowy are not consistent"
        return
     end if

     call interface_plsvect( real(arrowx, kind=private_plflt), real(arrowy, kind=private_plflt),  &
          npts_local, int(merge(1,0,fill), kind=private_plbool) )
end subroutine plsvect_double

subroutine plsvect_none( fill )
  logical, optional, intent(in) :: fill

    interface
        subroutine interface_plsvect( arrowx, arrowy, npts,  fill ) bind(c,name='c_plsvect')
            import :: c_ptr
            import :: private_plint, private_plbool
            implicit none
            integer(kind=private_plint), value, intent(in) :: npts
            integer(kind=private_plbool), value, intent(in) :: fill
            type(c_ptr), value, intent(in) :: arrowx, arrowy
        end subroutine interface_plsvect
     end interface

     call interface_plsvect( c_null_ptr, c_null_ptr, 0_private_plint, 0_private_plbool )
end subroutine plsvect_none

subroutine plsvect_single( arrowx, arrowy, fill )
  logical, intent(in) :: fill
  real(kind=private_single), dimension(:), intent(in) :: arrowx, arrowy

  integer(kind=private_plint) :: npts_local

    interface
        subroutine interface_plsvect( arrowx, arrowy, npts,  fill ) bind(c,name='c_plsvect')
            import :: private_plint, private_plbool, private_plflt
            implicit none
            integer(kind=private_plint), value, intent(in) :: npts
            integer(kind=private_plbool), value, intent(in) :: fill
            real(kind=private_plflt), dimension(*), intent(in) :: arrowx, arrowy
        end subroutine interface_plsvect
     end interface

     npts_local = size(arrowx, kind=private_plint)
     if(npts_local /= size(arrowy, kind=private_plint) ) then
        write(0,*) "f95 plsvect ERROR: sizes of arrowx and arrowy are not consistent"
        return
     end if

     call interface_plsvect( real(arrowx, kind=private_plflt), real(arrowy, kind=private_plflt),  &
          npts_local, int(merge(1,0,fill), kind=private_plbool) )
end subroutine plsvect_single

subroutine plsxax_impl( digmax, digits )
    integer, intent(in) :: digmax, digits
    interface
        subroutine interface_plsxax( digmax, digits ) bind( c, name = 'c_plsxax' )
            import :: private_plint
            implicit none
            integer(kind=private_plint), value, intent(in) :: digmax, digits
        end subroutine interface_plsxax
    end interface

    call interface_plsxax( int(digmax,kind=private_plint), int(digits,kind=private_plint) )
  end subroutine plsxax_impl

subroutine plsyax_impl( digmax, digits )
    integer, intent(in) :: digmax, digits
    interface
        subroutine interface_plsyax( digmax, digits ) bind( c, name = 'c_plsyax' )
            import :: private_plint
            implicit none
            integer(kind=private_plint), value, intent(in) :: digmax, digits
        end subroutine interface_plsyax
    end interface

    call interface_plsyax( int(digmax,kind=private_plint), int(digits,kind=private_plint) )
  end subroutine plsyax_impl

subroutine plszax_impl( digmax, digits )
    integer, intent(in) :: digmax, digits
    interface
        subroutine interface_plszax( digmax, digits ) bind( c, name = 'c_plszax' )
            import :: private_plint
            implicit none
            integer(kind=private_plint), value, intent(in) :: digmax, digits
        end subroutine interface_plszax
    end interface

    call interface_plszax( int(digmax,kind=private_plint), int(digits,kind=private_plint) )
  end subroutine plszax_impl

subroutine pltext_impl()
    interface
        subroutine interface_pltext() bind(c,name='c_pltext')
        end subroutine interface_pltext
     end interface
     call interface_pltext()
   end subroutine pltext_impl

subroutine pltimefmt_impl( fmt )
   character(len=*), intent(in) :: fmt

   interface
       subroutine interface_pltimefmt( fmt ) bind(c,name='c_pltimefmt')
           implicit none
           character(len=1), dimension(*), intent(in) :: fmt
       end subroutine interface_pltimefmt
   end interface

   call interface_pltimefmt( trim(fmt)//c_null_char )

end subroutine pltimefmt_impl

subroutine plvsta_impl()
    interface
        subroutine interface_plvsta() bind(c,name='c_plvsta')
        end subroutine interface_plvsta
     end interface
     call interface_plvsta()
   end subroutine plvsta_impl

subroutine plxormod_impl( mode, status )
  logical, intent(in) :: mode
  logical, intent(out) :: status

  integer(kind=private_plbool) :: status_out

  interface
     subroutine interface_plxormod( mode, status ) bind(c,name='c_plxormod')
       import :: private_plbool
       implicit none
       integer(kind=private_plbool), value, intent(in) :: mode
       integer(kind=private_plbool), intent(out) :: status
     end subroutine interface_plxormod
  end interface

  call interface_plxormod( int( merge(1,0,mode),kind=private_plbool), status_out )
  status = status_out /= 0_private_plbool

end subroutine plxormod_impl

end module plplot