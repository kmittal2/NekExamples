c-----------------------------------------------------------------------
c
c     A short example of Rayleigh-Benard convection:
c
c     Parameters are set in routine rayleigh_const for convenience.
c
c     With this nondimensionalization, set rho==1 (parameter p1 in .rea
c     file) and visocity (p2) to be the desired Prandtl number.
c
c     Rayleigh number is set as Ra = Rc*(1+eps),  Rc=p76, eps=p75.
c
c     The buoyancy is ffy = Ra Pr T, where T is determined by 
c     boundary and initial conditions.
c
c     Critical Rayleigh number is around 1707.762 
c     (Somehow I was recalling 1734, but that appears to be for a 
c     particular geometric configuration considered by Laurette Tuckerman 
c     & Dwight Barkley)
c
c     GEOMETRY:
c
c     There are two primary cases, ray1.box and ray2.box.
c     The former specifies 10 elements in x, the latter only 9,
c     both for a 9x1 domain.
c
c     NOTES:
c
c     A time trace of (u,v)_max vs t is output to the logfile. See userchk.
c
c     Be careful about selecting an even number of elements in x
c     as it appears that the RB system likes to lock onto the grid spacing
c     and give a number of rolls that matches the number of elements, if the
c     elements have order-unity aspect ratio, as in the present case.
c     Thus, in the case, the 9 element mesh is likely to be more faithful
c     to the linear stability theory, at least for modest polynomial orders
c     of lx1=12.
c     
c     It appears that one cannot realize Courant conditions of CFL ~ 0.5
c     with these cases because of the explicit Boussinesq treatment.
c     The given value dt=.02 is stable with lx1=12.
c
c
c-----------------------------------------------------------------------
      subroutine rayleigh_const

      include 'SIZE'
      include 'INPUT'

      common /rayleigh_r/ rapr,ta2pr

      Pr  = param(2)
      eps = param(75)
      Rc  = param(76)
      Ta2 = param(77)
      Ra  = Rc*(1.+eps)

      rapr    = ra*pr
      ta2pr   = ta2*pr

      return
      end
c-----------------------------------------------------------------------
      subroutine uservp (ix,iy,iz,ieg)
      include 'SIZE'
      include 'TOTAL'
      include 'NEKUSE'

      udiff  = 0
      utrans = 0

      return
      end
c-----------------------------------------------------------------------
      subroutine userf  (ix,iy,iz,ieg)
      include 'SIZE'
      include 'TOTAL'
      include 'NEKUSE'

      common /rayleigh_r/ rapr,ta2pr

      buoy = temp*rapr

      if (if3d) then
         ffx  =   uy*Ta2Pr
         ffy  = - ux*Ta2Pr
         ffz  = buoy
      elseif (ifaxis) then
         ffx  = -buoy
         ffy  =  0.
      else
         ffx  = 0.
         ffy  = buoy
      endif
c     write(6,*) ffy,temp,rapr,'ray',ieg

      return
      end
c-----------------------------------------------------------------------
      subroutine userq  (ix,iy,iz,ieg)
      include 'SIZE'
      include 'TOTAL'
      include 'NEKUSE'

      qvol   = 0.0
      source = 0.0
      return
      end
c-----------------------------------------------------------------------
      subroutine userbc (ix,iy,iz,iside,ieg)
      include 'SIZE'
      include 'TSTEP'
      include 'INPUT'
      include 'NEKUSE'
      common /rayleigh_r/ rapr,ta2pr

      ux=0.
      uy=0.
      uz=0.

      temp=0.  !     Temp = 0 on top, 1 on bottom

      if (if3d) then
         temp = 1-z
      elseif (ifaxis) then  !      domain is on interval x in [-1,0]
         temp = 1.+x
      else                  ! 2D:  domain is on interval y in [0,1]
         temp = 1.-y
      endif


      return
      end
c-----------------------------------------------------------------------
      subroutine useric (ix,iy,iz,ieg)
      include 'SIZE'
      include 'TOTAL'
      include 'NEKUSE'
      integer idum
      save    idum
      data    idum /99/

c     ran = ran1(idum)

c     The totally ad-hoc random number generator below is preferable
c     to the above for the simple reason that it gives the same i.c.
c     independent of the number of processors, which is important for
c     code verification.

      ran = 2.e4*(ieg+x*sin(y)) + 1.e3*ix*iy + 1.e5*ix 
      ran = 1.e3*sin(ran)
      ran = 1.e3*sin(ran)
      ran = cos(ran)
      amp = .001

      temp = 1-y + ran*amp*(1-y)*y*x*(9-x)

      ux=0.0
      uy=0.0
      uz=0.0

      return
      end
c-----------------------------------------------------------------------
      subroutine usrdat
      return
      end
c-----------------------------------------------------------------------
      subroutine usrdat3
      return
      end
c-----------------------------------------------------------------------
      subroutine usrdat2
      include 'SIZE'
      include 'TOTAL'

      common /rayleigh_r/ rapr,ta2pr

      call rayleigh_const



      return
      end
c-----------------------------------------------------------------------
      subroutine userchk
      include 'SIZE'
      include 'TOTAL'
      common /scrns/ tz(lx1*ly1*lz1*lelt)

      n = nx1*ny1*nz1*nelv
      umax = glmax(vx,n)
      vmax = glmax(vy,n)

      ifxyo = .true.  ! For VisIt
      if (istep.gt.iostep) ifxyo = .false.
      if (istep.le.1) then
         do i=1,n
            tz(i) = t(i,1,1,1,1)+ym1(i,1,1,1) - 1.
         enddo
         call outpost(vx,vy,vz,pr,tz,'   ')
      endif

      if (nid.eq.0) write(6,1) istep,time,umax,vmax
    1 format(i9,1p3e14.6,' umax')


      return
      end
c-----------------------------------------------------------------------

c automatically added by makenek
      subroutine usrsetvert(glo_num,nel,nx,ny,nz) ! to modify glo_num
      integer*8 glo_num(1)

      return
      end

c automatically added by makenek
      subroutine userqtl

      call userqtl_scig

      return
      end
