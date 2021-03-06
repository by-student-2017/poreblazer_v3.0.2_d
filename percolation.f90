!----------------------------------------------------------
! This module performs percolation analisys of lattice: returns number and sizes of lattice clusters
! and wheather the system is percolated
!----------------------------------------------------------

Module percolation

    Implicit None
    Save

    Private
    Public :: percolation_calc, percolation_calc_simple


Contains

!-----------------------------------------------------------------------------------------------
!!subroutine that initiates percolation analysis
!-----------------------------------------------------------------------------------------------

    Subroutine percolation_calc(lattice_in, n_sites, nn_sites, cl_summary)

        Integer*2, Dimension(:,:,:), Intent(InOut)                                     :: lattice_in
        Integer, Dimension(:), Intent(InOut)                                         :: n_sites
        Integer, Intent(InOut)                                                       :: nn_sites
        Integer, Dimension(:,:), Intent(InOut)                                       :: cl_summary
        Integer, Dimension(:,:,:), allocatable                                       :: cluster
        Integer, Dimension(:), allocatable                                           :: cl
        Integer, Dimension(:), allocatable                                           :: trcl
        Integer                                                                      :: nc

        allocate(cluster(size(lattice_in, 1), size(lattice_in, 2), size(lattice_in, 3)))
        allocate(cl(10000),trcl(10000))
        nc = 0
        cluster = 0
        cl = 0
        trcl = 0

        Call clusteranalysis(lattice_in,cluster,cl,trcl,nc)
        Call span(lattice_in, n_sites, nn_sites, cluster, cl, nc, cl_summary)
        deallocate(cluster)
        deallocate(cl)
        deallocate(trcl)
    End Subroutine percolation_calc

!-----------------------------------------------------------------------------------------------
!!subroutine that initiates percolation analysis
!-----------------------------------------------------------------------------------------------

    Subroutine percolation_calc_simple(lattice_in, cl_summary, spanning)

        Integer*2, Dimension(:,:,:), Intent(InOut)                                       :: lattice_in
        Integer, Dimension(:,:), Intent(InOut)                                         :: cl_summary
        Integer, Dimension(:,:,:), allocatable                                         :: cluster
        Integer, Dimension(:), allocatable                                             :: cl,trcl
        Integer, Intent(InOut)                                                         :: spanning
        Integer                                                                        :: nc

        allocate(cluster(size(lattice_in, 1), size(lattice_in, 2), size(lattice_in, 3)))
        allocate(cl(10000),trcl(10000))
        nc = 0
        cluster = 0
        cl = 0
        trcl = 0
        spanning = 0

        Call clusteranalysis(lattice_in,cluster,cl,trcl,nc)

        Call span_simple(lattice_in, cluster, cl, nc, cl_summary, spanning)
        deallocate(cluster, cl, trcl)
    End Subroutine percolation_calc_simple



!---------------------------------------------------------------------
! Subroutine that takes a 3D grid of sites (0 or 1) and performs cluster
! analysis
!---------------------------------------------------------------------

    Subroutine clusteranalysis(ngrid,cluster,cl,trcl,nc)

        Integer*2, Dimension(:,:,:), Intent(InOut)     :: ngrid
        Integer, Dimension(:,:,:), Intent(InOut)  :: cluster
        Integer, Dimension(:), Intent(InOut)      :: cl,trcl
        Integer, Intent(InOut)                       :: nc
        Integer, Dimension(26)                       :: local
        Integer                                      :: i, j, k, l, LX, LY, LZ, scenario, ncold, trcli, icount, i1
        Logical :: loop
        Real :: xr, yr, zr
        Integer, Dimension(:), allocatable                                             :: clink


        allocate(clink(10000))
        clink = 0

        LX = size(ngrid,1)
        LY = size(ngrid,2)
        LZ = size(ngrid,3)

        do k=1, LZ
            do j=1, LY
                do i=1, LX
                   If(ngrid(i,j,k) == 1) Then
                       If(cluster(i,j,k) /= 0) cycle

                       Call reveal_local(i,j,k,cluster,ngrid,local, scenario)

                       If(scenario == 1) Then
                           Call scenario_1(i,j,k, cluster, ngrid, cl, trcl, nc)
                       Else
                           Call scenario_2(i,j,k, cluster, ngrid, cl, trcl, nc)
                       End If

                    End If

                end do
            end do
        end do
     
        icount = 0 
        nc = 0

        do k=1, LZ
            do j=1, LY
                do i=1, LX

                        If(ngrid(i,j,k) == 0) cycle
                        icount =  icount + 1
                        trcli = trcl(cluster(i, j, k))
                        loop = .false.

                        do i1=1, nc
                        if(clink(i1) == trcli) then
                        cluster(i, j, k) = i1
                        cl(i1) = cl(i1) + 1
                        loop = .true.
                        exit
                        end if
                        end do

                        if(loop) cycle
                        nc = nc + 1
                        cluster(i, j, k) = nc
                        cl(nc) = cl(nc) + 1
                        clink(nc) = trcli
                end do
            end do
        end do
    
     do i=1, nc
     end do

    ! Several additional loops may be required to reconnect the neighbouring clusters

!        do l=1,100
!            ncold=nc
!            do k=1, LZ
!                do j=1, LY
!                    do i=1, LX
!                     If(ngrid(i,j,k) == 0) cycle
!                     write(20,*) i, j, k, cluster(i,j,k), cl(cluster(i,j,k)), nc
!
!                        If(ngrid(i,j,k) == 0) cycle
!                        Call update(i,j,k,cluster,ngrid,cl,nc)
!
!                    end do
!                end do
!            end do
!
!            If(nc==ncold) exit
!         end do
!     print*, "hello2"
     deallocate(clink)
     End Subroutine clusteranalysis

!---------------------------------------------------------------------
! Subroutine which reveals status of the neighbouring sites
!---------------------------------------------------------------------

    Subroutine reveal_local(i0,j0,k0,cluster,ngrid,local, scenario)
        Integer, Intent(In)                      :: i0,j0,k0
        Integer, Dimension(:,:,:), Intent(In)     :: cluster
        Integer*2, Dimension(:,:,:), Intent(In)     ::ngrid
        Integer, Dimension(:), Intent(InOut)        :: local
        Integer, Intent(InOut)                     :: scenario
        Integer                                  :: i1, j1, k1, i, j, k, ic

    ! Default scenario 1: neighbouring sites are not occupied
    ! or occupied but not assigned to any clusters

     scenario = 1
     ic = 1

    ! Six neighbouring sites

     k1=k0-1; j1=j0; i1=i0    
     If(k1<1) k1=size(cluster,3)
        If(ngrid(i1,j1,k1)==1) Then
           If(cluster(i1,j1,k1)/=0) Then
           local(ic) = cluster(i1,j1,k1)

           ! Scenario 2 where some of the sites are occupied and
           ! assigned to some clusters

           scenario = 2
           Return
           End If
        End If

     k1=k0+1; j1=j0; i1=i0
     If(k1>size(cluster,3)) k1= 1
        If(ngrid(i1,j1,k1)==1) Then                 
           If(cluster(i1,j1,k1)/=0) Then             
           local(ic) = cluster(i1,j1,k1)                 

           ! Scenario 2 where some of the sites are occupied and                 
           ! assigned to some clusters                 

           scenario = 2                 
           Return                 
           End If             
        End If

     k1=k0; j1=j0-1; i1=i0
     If(j1<1) j1=size(cluster,2)
        If(ngrid(i1,j1,k1)==1) Then
           If(cluster(i1,j1,k1)/=0) Then                 
           local(ic) = cluster(i1,j1,k1)                 

           ! Scenario 2 where some of the sites are occupied and
           ! assigned to some clusters

           scenario = 2
           Return
           End If
        End If
      
     k1=k0; j1=j0+1; i1=i0
     If(j1>size(cluster,2)) j1= 1
        If(ngrid(i1,j1,k1)==1) Then
           If(cluster(i1,j1,k1)/=0) Then                 
           local(ic) = cluster(i1,j1,k1)                 

           ! Scenario 2 where some of the sites are occupied and
           ! assigned to some clusters

           scenario = 2
           Return
           End If
        End If

     k1=k0; j1=j0; i1=i0-1
     If(i1<1) i1=size(cluster,1)
        If(ngrid(i1,j1,k1)==1) Then
           If(cluster(i1,j1,k1)/=0) Then
           local(ic) = cluster(i1,j1,k1)

           ! Scenario 2 where some of the sites are occupied and
           ! assigned to some clusters  

           scenario = 2
           Return
           End If
        End If

     k1=k0; j1=j0; i1=i0+1
     If(i1>size(cluster,1)) i1 = 1
        If(ngrid(i1,j1,k1)==1) Then
           If(cluster(i1,j1,k1)/=0) Then
           local(ic) = cluster(i1,j1,k1)

           ! Scenario 2 where some of the sites are occupied and
           ! assigned to some clusters

           scenario = 2
           Return
           End If
       End If

     Return

    End Subroutine reveal_local

!---------------------------------------------------------------------
! Subroutine which considers scenario 1 where neighbouring sites are not occupied
! or occupied but not assigned to any clusters
!---------------------------------------------------------------------

    Subroutine scenario_1(i0,j0,k0, cluster,ngrid, cl, trcl, nc)
        Integer, Intent(In)                         :: i0,j0,k0
        Integer, Dimension(:,:,:), Intent(InOut) :: cluster
        Integer*2, Dimension(:,:,:), Intent(InOut) :: ngrid
        Integer, Dimension(:), Intent(InOut)      :: cl, trcl
        Integer, Intent(InOut)                      :: nc

        nc = nc + 1
        trcl(nc) = nc
        cluster(i0,j0,k0) = nc
    End Subroutine scenario_1

!---------------------------------------------------------------------
! Subroutine which considers scenario 2 where some of the sites areoccupied and
! assigned to some clusters
!---------------------------------------------------------------------

    Subroutine scenario_2(i0,j0,k0, cluster,ngrid, cl, trcl, nc)
        Integer, Intent(In)                         :: i0,j0,k0
        Integer, Dimension(:,:,:), Intent(InOut) :: cluster
        Integer*2, Dimension(:,:,:), Intent(InOut) :: ngrid
        Integer, Dimension(:), Intent(InOut)      :: cl, trcl
        Integer, Intent(InOut)                      :: nc
        Integer                                     :: i,j,k,i1,j1,k1, lowest, current, trlowest

        lowest = huge(0); trlowest = huge(0)
        ! Six neighbouring sites

        k1=k0-1; j1=j0; i1=i0            
        If(k1<1) k1=size(cluster,3)
        If(ngrid(i1,j1,k1)==1) Then
           If(cluster(i1,j1,k1)/=0) Then

            If(lowest>cluster(i1,j1,k1))  lowest = cluster(i1,j1,k1)
            If(trlowest>trcl(cluster(i1,j1,k1))) trlowest = trcl(cluster(i1,j1,k1))

           End If
        End If

        k1=k0+1; j1=j0; i1=i0            
        If(k1>size(cluster,3)) k1= 1
        If(ngrid(i1,j1,k1)==1) Then
           If(cluster(i1,j1,k1)/=0) Then

            If(lowest>cluster(i1,j1,k1))  lowest = cluster(i1,j1,k1)               
            If(trlowest>trcl(cluster(i1,j1,k1))) trlowest = trcl(cluster(i1,j1,k1))

           End If
        End If

        k1=k0; j1=j0-1; i1=i0
        If(j1<1) j1=size(cluster,2)
        If(ngrid(i1,j1,k1)==1) Then
           If(cluster(i1,j1,k1)/=0) Then

            If(lowest>cluster(i1,j1,k1))  lowest = cluster(i1,j1,k1)               
            If(trlowest>trcl(cluster(i1,j1,k1))) trlowest = trcl(cluster(i1,j1,k1))           

           End If
        End If

        k1=k0; j1=j0+1; i1=i0
        If(j1>size(cluster,2)) j1= 1
        If(ngrid(i1,j1,k1)==1) Then
           If(cluster(i1,j1,k1)/=0) Then

            If(lowest>cluster(i1,j1,k1))  lowest = cluster(i1,j1,k1)
            If(trlowest>trcl(cluster(i1,j1,k1))) trlowest = trcl(cluster(i1,j1,k1))

           End If
        End If

        k1=k0; j1=j0; i1=i0-1
        If(i1<1) i1=size(cluster,1)
        If(ngrid(i1,j1,k1)==1) Then
           If(cluster(i1,j1,k1)/=0) Then

            If(lowest>cluster(i1,j1,k1))  lowest = cluster(i1,j1,k1)               
            If(trlowest>trcl(cluster(i1,j1,k1))) trlowest = trcl(cluster(i1,j1,k1))           

           End If
        End If

        k1=k0; j1=j0; i1=i0+1
        If(i1>size(cluster,1)) i1 = 1
        If(ngrid(i1,j1,k1)==1) Then
           If(cluster(i1,j1,k1)/=0) Then

            If(lowest>cluster(i1,j1,k1))  lowest = cluster(i1,j1,k1)
            If(trlowest>trcl(cluster(i1,j1,k1))) trlowest = trcl(cluster(i1,j1,k1))

           End If
        End If

        If(lowest< huge(0)) then
        cluster(i0, j0, k0) = lowest
        trcl(lowest) = trlowest
        else
        nc = nc + 1
        trcl(nc) = nc
        cluster(i0,j0,k0) = nc
        return
        end if

        k1=k0-1; j1=j0; i1=i0
        If(k1<1) k1=size(cluster,3)
        If(cluster(i1,j1,k1)/=0) Then
        trcl(cluster(i1,j1,k1)) = trlowest
        End If         

        k1=k0+1; j1=j0; i1=i0 
        If(k1>size(cluster,3)) k1 = 1
        If(cluster(i1,j1,k1)/=0) Then
        trcl(cluster(i1,j1,k1)) = trlowest 
        End If

        k1=k0; j1=j0-1; i1=i0 
        If(j1<1) j1=size(cluster,2)
        If(cluster(i1,j1,k1)/=0) Then
        trcl(cluster(i1,j1,k1)) = trlowest
        End If

        k1=k0; j1=j0+1; i1=i0        
        If(j1>size(cluster,2)) j1 = 1
        If(cluster(i1,j1,k1)/=0) Then
        trcl(cluster(i1,j1,k1)) = trlowest
        End IF


        k1=k0; j1=j0; i1=i0-1           
        If(i1<1) i1=size(cluster,1)
        If(cluster(i1,j1,k1)/=0) Then
        trcl(cluster(i1,j1,k1)) = trlowest
        End If  

        k1=k0; j1=j0; i1=i0+1           
        If(i1>size(cluster,1)) i1 = 1
        If(cluster(i1,j1,k1)/=0) Then
        trcl(cluster(i1,j1,k1)) = trlowest
        End If

        Return


    End Subroutine scenario_2

!---------------------------------------------------------------------
! Subroutine to update the cluster structure
!---------------------------------------------------------------------

    subroutine permutate(lowest, current, cluster, nc, cl)
        Integer, Intent(In)                         :: lowest, current
        Integer, Dimension(:,:,:), Intent(InOut) :: cluster
        Integer, Dimension(:), Intent(InOut)      :: cl
        Integer, Intent(InOut)                      :: nc
        Integer                                     :: i,j,k, LX, LY, LZ

        LX = size(cluster,1)
        LY = size(cluster,2)
        LZ = size(cluster,3)

        do k=1, LZ
            do j=1, LY
                do i=1, LX

                    If(cluster(i,j,k)==current) Then
                        cl(lowest) = cl(lowest) + 1
                        cluster(i,j,k) = lowest
                    End If

                end do
            end do
        end do

        ! Eliminate current cluster by copying last cluster (nc) into it

        cl(current) = cl(nc)

        do k=1, LZ
            do j=1, LY
                do i=1, LX

                    If(cluster(i,j,k)==nc) Then
                        cluster(i,j,k) = current
                    End If

                end do
            end do
        end do
        cl(nc) = 0
        nc = nc - 1
    End Subroutine permutate

!----------------------------------------------------------------------------
!Subroutine to determine if a percolating cluster exists in x y or z-direction
!----------------------------------------------------------------------------

!There could be more than one spanning cluster in each direction
!Useful output: if there exists a spanning cluster

!Look at cluster information and find out if any one of the clusters has an available site in every x y or z-axis position.

    subroutine span(lattice_in, n_sites, nn_sites, cluster, cl, nc, cl_summary)

        Integer*2, Dimension(:,:,:), Intent(InOut) :: lattice_in
        Integer, Dimension(:), Intent(InOut)      :: n_sites
        Integer, Intent(InOut)                    :: nn_sites
        Integer, Dimension(:,:,:), Intent(In)     :: cluster
        Integer, Dimension(:), Intent(In)         :: cl
        Integer, Intent(In)                       :: nc
        Integer, Dimension(:,:), Intent(Out)      :: cl_summary
        Integer                                   :: x_span, y_span, z_span,potentialspan !x_span=0 if there is no spanning cluster
        Integer                                   :: n,i,j,k, LX, LY, LZ, ic, icount, spanning, i1
        Integer, Dimension(:), allocatable :: x_array, y_array, z_array
        Logical :: attempt

        LX = size(cluster,1)
        LY = size(cluster,2)
        LZ = size(cluster,3)
        allocate(x_array(LX), y_array(LY), z_array(LZ))
        attempt = .False.
        ic = 0
        cl_summary = 0

        ! Search for cluster sizes that are greater than LX/LY/LZ (any cluster smaller than this, won't be a spanning cluster)
        do n=1, nc
            x_span=1
            y_span=1
            z_span=1

            x_array=0
            y_array=0
            z_array=0
            potentialspan = 0

            if (cl(n)>=LX.or.cl(n)>=LY.or.cl(n)>=LZ) then
                !print*, " "
                !print*, "Probing cluster ", n, " size ", cl(n)
                attempt = .True.

                potentialspan=n

                ! When a cluster that is larger than LX is found, the cluster label matrix is investigated
                ! Check z direction

                do k=1, LZ
                    do j=1, LY
                        do i=1, LX
                            if (cluster(i,j,k)==potentialspan) then
                                z_array(k)=1
                                ! If any position belongs to cluster in question, then exit looking at plane k and move on to next k
                                go to 40
                            end if
                        end do
                    end do

        40      end do

                do k=1, LZ
                    if (z_array(k)==0) then
                        z_span=0
                        exit
                    end if
                end do


                do j=1, LY

                    ! Look at x-z plane
                    do k=1, LZ
                        do i=1, LX
                            if (cluster(i,j,k)==potentialspan) then
                                y_array(j)=1
                                ! If any position belongs to cluster in question, then exit looking at plane j and move on to next j
                                go to 60
                            end if
                        end do
                    end do

          60    end do

                do j=1, LY
                    if (y_array(j)==0) then
                        y_span=0
                        exit
                    end if
                end do

                ! Repeat for x-direction

                do i=1, LX

                    ! Look at y-z plane
                        do k=1, LZ
                            do j=1, LY
                                if (cluster(i,j,k)==potentialspan) then
                                    x_array(i)=1
                                    ! If any position belongs to cluster in question, then exit looking at plane i and move on to next i
                                    go to 80
                                end if
                            end do
                        end do

          80    end do

                do i=1, LX
                    if (x_array(i)==0) then
                        x_span=0
                        exit
                    end if
                end do

            ! If any of x, y or z_span =1, then cluster is percolated


                spanning = 0
                if(x_span==1) then
                    spanning = spanning + 1
                end if
                if(y_span==1) then
                    spanning = spanning + 1
                end if

                if(z_span==1) then
                    spanning = spanning + 1
                end if

                if(spanning>0) then
                    ic = ic + 1
                    cl_summary(1, 1)      = ic
                    cl_summary(ic+1, 1)   = potentialspan
                    cl_summary(ic+1, 2)   = spanning
                end if
            end if

        end do

        if(attempt.eqv..False.) then
            write(*,*) " The system is NOT percolated in ANY direction "
            spanning = 0

            deallocate(x_array, y_array, z_array)
            return
        end if

        lattice_in = 0
        nn_sites = 0
        n_sites = 0
        icount = 0

        do k=1, LZ
            do j=1, LY
                do i=1, LX
                    icount = icount + 1

                    do i1=1, ic
                        if(cluster(i,j,k) ==  cl_summary(i1+1, 1)) then
                            lattice_in(i,j,k) = 1
                            nn_sites = nn_sites + 1
                            n_sites(nn_sites) = icount
                        end if

                    end do
                end do
            end do
        end do

        deallocate(x_array, y_array, z_array)
        
    end subroutine span

!----------------------------------------------------------------------------
!Subroutine to determine if a percolating cluster exists in x y or z-direction
!----------------------------------------------------------------------------

!There could be more than one spanning cluster in each direction
!Useful output: if there exists a spanning cluster

!Look at cluster information and find out if any one of the clusters has an available site in every x y or z-axis position.

    subroutine span_simple(lattice_in, cluster, cl, nc, cl_summary, spanning)

        Integer*2, Dimension(:,:,:), Intent(InOut)  :: lattice_in
        Integer, Dimension(:,:,:), Intent(InOut)  :: cluster(:,:,:)
        Integer, Dimension(:), Intent(In)         :: cl
        Integer, Intent(In)                       :: nc
        Integer, Dimension(:,:), Intent(Out)      :: cl_summary
        Integer, Intent(InOut)                    :: spanning
        Integer                                   :: x_span, y_span, z_span,potentialspan !x_span=0 if there is no spanning cluster
        Integer                                   :: n,i,j,k, LX, LY, LZ, ic
        Integer, Dimension(:), allocatable  :: x_array, y_array, z_array
        Logical :: attempt

        LX = size(cluster,1)
        LY = size(cluster,2)
        LZ = size(cluster,3)
        allocate(x_array(LX), y_array(LY), z_array(LZ))
        attempt = .False.
        ic = 0
        cl_summary = 0

        ! Search for cluster sizes that are greater than LX/LY/LZ (any cluster smaller than this, won't be a spanning cluster)
        do n=1, nc
            x_span=1
            y_span=1
            z_span=1

            x_array=0
            y_array=0
            z_array=0
            potentialspan = 0

            if (cl(n)>=LX.or.cl(n)>=LY.or.cl(n)>=LZ) then
            !    print*, " "
            !    print*, "Probing cluster ", n, " size ", cl(n)
                attempt = .True.

                potentialspan=n

                ! When a cluster that is larger than LX is found, the cluster label matrix is investigated
                ! Check z direction

                do k=1, LZ

                    !look at entire x-y plane
                    do j=1, LY
                        do i=1, LX
                            if (cluster(i,j,k)==potentialspan) then
                                z_array(k)=1
                                ! If any position belongs to cluster in question, then exit looking at plane k and move on to next k
                                go to 40
                            end if
                        end do
                    end do

            40  end do

                do k=1, LZ
                    if (z_array(k)==0) then
                        z_span=0
                        exit
                    end if
                end do


                do j=1, LY

                    ! Look at x-z plane
                    do k=1, LZ
                        do i=1, LX
                            if (cluster(i,j,k)==potentialspan) then
                                y_array(j)=1
                                ! If any position belongs to cluster in question, then exit looking at plane j and move on to next j
                                go to 60
                            end if
                        end do
                    end do

            60  end do

                do j=1, LY
                    if (y_array(j)==0) then
                        y_span=0
                        exit
                    end if
                end do

                ! Repeat for x-direction

                do i=1, LX

                ! Look at y-z plane
                    do k=1, LZ
                        do j=1, LY
                            if (cluster(i,j,k)==potentialspan) then
                                x_array(i)=1
                                ! If any position belongs to cluster in question, then exit looking at plane i and move on to next i
                                go to 80
                            end if
                        end do
                    end do

            80  end do

                do i=1, LX
                    if (x_array(i)==0) then
                        x_span=0
                        exit
                    end if
                end do

            ! If any of x, y or z_span =1, then cluster is percolated


                spanning = 0
                if(x_span==1) then
                    spanning = spanning + 1
                end if

                if(y_span==1) then
                    spanning = spanning + 1
                end if

                if(z_span==1) then
                    spanning = spanning + 1
                end if

                if(spanning>0) then
                    ic = ic + 1
                    cl_summary(1, 1)      = ic
                    cl_summary(ic+1, 1)   = potentialspan
                    cl_summary(ic+1, 2)   = spanning

                    deallocate(x_array, y_array, z_array)
                    return
                end if
            end if

        end do

        if(attempt.eqv..False.) then
        !    write(*,*) " The system is NOT percolated in ANY direction "
            spanning = 0
        end if

        deallocate(x_array, y_array, z_array)

    end subroutine span_simple


!---------------------------------------------------------------------
! Subroutine which searches for two clusters sharing a site and
! reconnects them into one large cluster
!---------------------------------------------------------------------

    subroutine update(i0,j0,k0, cluster,ngrid, cl, nc)
        Integer, Intent(In)                         :: i0,j0,k0
        Integer, Dimension(:,:,:), Intent(InOut) :: cluster
        Integer*2, Dimension(:,:,:), Intent(InOut) :: ngrid
        Integer, Dimension(:), Intent(InOut)      :: cl
        Integer, Intent(InOut)                      :: nc
        Integer                                     :: i,j,k,i1,j1,k1, lowest

        lowest = huge(0)
        !First we find the lowest cluster observed among the neighbours
        do k=k0-1, k0+1, 1
            do j=j0-1, j0+1, 1
                do i=i0-1, i0+1, 1

                    if (k/=k0.and.(i/=i0.or.j/=j0)) cycle
                    if (j/=j0.and.(k/=k0.or.i/=i0)) cycle
                    if (i/=i0.and.(j/=j0.or.k/=k0)) cycle

                    i1 = i
                    j1 = j
                    k1 = k

                    If(i1<1) i1=size(cluster,1)
                    If(i1>size(cluster,1)) i1= 1
                    If(j1<1) j1=size(cluster,2)
                    If(j1>size(cluster,2)) j1= 1
                    If(k1<1) k1=size(cluster,3)
                    If(k1>size(cluster,3)) k1= 1

                    If(ngrid(i1,j1,k1)==1) Then
                        If(cluster(i1,j1,k1)/=0) Then
                            If(lowest>cluster(i1,j1,k1)) Then
                                lowest = cluster(i1,j1,k1)
                            End If
                        End If
                    End If

                end do
            end do
        end do

        If(lowest==0) Then
            print*, 'something is wrong, it is not scenario 2'
            stop
        End If

        do k=k0-1, k0+1, 1
            do j=j0-1, j0+1, 1
                do i=i0-1, i0+1, 1

                    if (k/=k0.and.(i/=i0.or.j/=j0)) cycle
                    if (j/=j0.and.(k/=k0.or.i/=i0)) cycle
                    if (i/=i0.and.(j/=j0.or.k/=k0)) cycle

                    i1 = i
                    j1 = j
                    k1 = k

                    If(i1<1) i1=size(cluster,1)
                    If(i1>size(cluster,1)) i1= 1
                    If(j1<1) j1=size(cluster,2)
                    If(j1>size(cluster,2)) j1= 1
                    If(k1<1) k1=size(cluster,3)
                    If(k1>size(cluster,3)) k1= 1

                    If((i1/=i0.or.j1/=j0.or.k1/=k0).and.cluster(i1,j1,k1)==0) cycle

                    If(ngrid(i1,j1,k1)==1) Then
                        If(cluster(i1,j1,k1)==0) Then
                            cl(lowest) = cl(lowest) + 1
                            cluster(i1,j1,k1) = lowest
                        ElseIf(cluster(i1,j1,k1)==lowest)Then
                            cycle
                        Else
                            Call permutate(lowest, cluster(i1,j1,k1), cluster, nc, cl)
                        End If
                    End If

                end do
            end do
        end do
    End Subroutine update

End Module percolation
