c-----------------------------------------------------------------------
      subroutine uservp (ix,iy,iz,ieg)
      include 'SIZE'
      include 'TOTAL'
      include 'NEKUSE'

      udiff  = 0.
      utrans = 0.

      return
      end
c-----------------------------------------------------------------------
      subroutine userf  (ix,iy,iz,ieg)
      include 'SIZE'
      include 'TOTAL'
      include 'NEKUSE'
      
      ffx = 0.
      ffy = 0.
      ffz = 0.

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
      subroutine userchk
      include 'SIZE'
      include 'TOTAL'
      include 'NEKNEK'

      common /ctorq/ dragx(0:maxobj),dragpx(0:maxobj),dragvx(0:maxobj)
     $             , dragy(0:maxobj),dragpy(0:maxobj),dragvy(0:maxobj)
     $             , dragz(0:maxobj),dragpz(0:maxobj),dragvz(0:maxobj)
c
     $             , torqx(0:maxobj),torqpx(0:maxobj),torqvx(0:maxobj)
     $             , torqy(0:maxobj),torqpy(0:maxobj),torqvy(0:maxobj)
     $             , torqz(0:maxobj),torqpz(0:maxobj),torqvz(0:maxobj)
c
     $             , dpdx_mean,dpdy_mean,dpdz_mean
     $             , dgtq(3,4)

      real x0(3)
      save x0
      data x0 /3*0/

      integer icalld
      save    icalld
      data    icalld /0/

      real num,avgdrag,avglift
      save num,avgdrag,avglift
       
c     Define objects (the cylinder) for surface integrals
      if (idsess.eq.0 .AND. istep.eq.0) call set_obj

c     Calculate the average lift and drag coefficents through one
c     oscillation period
      if (idsess.eq.0) THEN
         if (istep.ge.12501) then
            scale = 2.  ! Cd = F/(.5 rho U^2 ) = 2*F
            call torque_calc(scale,x0,.true.,.false.)

            if (icalld.eq.0) then
               num     = 0.0
               avgdrag = 0.0
               avglift = 0.0
               icalld=icalld+1
            endif

            num     = num + 1.
            alpha   = (num-1.)/num
            beta    = 1./num
            avgdrag = avgdrag*alpha + dragx(1)*beta
            avglift = avglift*alpha + dragy(1)*beta
         endif
         if (nid.eq.0.and.istep.eq.15000) 
     $      write(6,10) istep,time,avgdrag,avglift
      endif
      
   10 format(i6,1p3e13.5,' avg drag, avg lift')

c     Prescribe mesh motion 
      if (istep.eq.0) call opzero(wx,wy,wz)

      call my_mesh_velocity
 
      return
      end
c-----------------------------------------------------------------------
      subroutine userbc (ix,iy,iz,iside,ieg)
      include 'SIZE'
      include 'TOTAL'
      include 'NEKUSE'
      include 'NEKNEK'

      integer ie,ieg
      integer icalld
      save    icalld
      data    icalld /0/

      ie = gllel(ieg)

      if (imask(ix,iy,iz,ie).eq.0) then
         if (IFMVBD) then !Moving
            frequency = param(33)
            amplitude = param(34)
            call u_meshv(x,y,z,ux,uy,uz,time,frequency,amplitude)
         else                                   
           ux=1.
           uy=0.
           uz=0.
         endif
         temp=0.0
      else
         if (igeom.le.2) then
            ux = ubc(ix,iy,iz,ie,1)
            uy = ubc(ix,iy,iz,ie,2)
            uz = ubc(ix,iy,iz,ie,3)
            if (nfld.gt.3) temp = ubc(ix,iy,iz,ie,4)
         else
            ux = valint(ix,iy,iz,ie,1)
            uy = valint(ix,iy,iz,ie,2)
            uz = valint(ix,iy,iz,ie,3)
            if (nfld.gt.3) temp = valint(ix,iy,iz,ie,4)
         endif
      endif
         

      return
      end
c-----------------------------------------------------------------------
      subroutine useric (ix,iy,iz,ieg)
      include 'SIZE'
      include 'TOTAL'
      include 'NEKUSE'

      ux=1.0
      uy=0.0
      uz=0.0
      temp=0.0

      return
      end
c-----------------------------------------------------------------------
      subroutine usrdat
      include 'SIZE'
      include 'TOTAL'
      include 'NEKNEK'

c     ngeom - parameter controlling the number of iterations,
c     set to ngeom=2 by default (no iterations) 
c     One could change the number of iterations as
cccc      ngeom = 3

c     ninter - parameter controlling the order of interface extrapolation 
c     for neknek,
c     set to ninter=1 by default
c     One could change it as
cccc      ninter = 2
c     Caution: if ninter greater than 1 is chosen, ngeom greater than 2 
c     should be used for stability


c     Set number of fields to interpolate
c     nfld = 3 - u,v,w velocitites  
c     nfld = 4 - u,v,w velocitites + temperature 

      nfld_neknek=3
c      ifplan5 = .true.

      if (param(33) .eq. 0.0) param(33) = 1.0    !Default Frequency
      if (param(34) .eq. 0.0) param(34) = 1.0e-2 !Default Amplitude

      return
      end
c-----------------------------------------------------------------------
      subroutine usrdat2
      include 'SIZE'
      include 'TOTAL'
      include 'NEKUSE'

      param(59) = 1         ! all elements deformed
      param(66) = 4
      param(67) = 4
      ifxyo    = .true.     ! ensure output of geometry
      ifusermv = .true.     ! define our own mesh velocity
      call multimesh_create ! initialization for multimesh 

      return
      end
c-----------------------------------------------------------------------
      subroutine usrdat3
      return
      end
c-----------------------------------------------------------------------
      subroutine my_mesh_velocity
      include 'SIZE'
      include 'TOTAL'
      include 'NEKUSE'

      if (IFMVBD) then                        !Moving mesh
         frequency = param(33)
         amplitude = param(34)

         n=nx1*ny1*nz1*nelv
         do i=1,n
            x = xm1(i,1,1,1)
            y = ym1(i,1,1,1)
            z = zm1(i,1,1,1)
            call u_meshv(x,y,z,ux,uy,uz,time,frequency,amplitude)
            wx(i,1,1,1) = ux
            wy(i,1,1,1) = uy
            wz(i,1,1,1) = uz
         enddo
      endif

      return
      end
c-----------------------------------------------------------------------
      subroutine u_meshv(x,y,z,wx,wy,wz,time,frequency,amplitude)
      

         one          = 1.0
         pi           = 4.0*atan(one)
         omega        = frequency*2*pi
     
         wx = 0.0
         wy = amplitude * omega * cos(omega*time)
         wz = 0.0

      return
      end
c-----------------------------------------------------------------------
      subroutine set_obj  ! define objects for surface integrals
c
      include 'SIZE'
      include 'TOTAL'

      integer e,f,eg

      nobj = 1
      iobj = 0
      do ii=nhis+1,nhis+nobj
         iobj = iobj+1
         hcode(10,ii) = 'I'
         hcode( 1,ii) = 'F'
         hcode( 2,ii) = 'F'
         hcode( 3,ii) = 'F'
         lochis(1,ii) = iobj
      enddo
      nhis = nhis + nobj

      if (maxobj.lt.nobj) call exitti('increase maxobj in SIZE$',nobj)

      nxyz  = nx1*ny1*nz1
      nface = 2*ndim

      do e=1,nelv
      do f=1,nface
         if (cbc(f,e,1).eq.'mv ') then
            iobj  = 1
            if (iobj.gt.0) then
               nmember(iobj) = nmember(iobj) + 1
               mem = nmember(iobj)
               eg  = lglel(e)
               object(iobj,mem,1) = eg
               object(iobj,mem,2) = f
c              write(6,1) iobj,mem,f,eg,e,nid,' OBJ'
c   1          format(6i9,a4)

            endif
         endif
      enddo
      enddo

c     write(6,*) 'number',(nmember(k),k=1,4)
c
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
