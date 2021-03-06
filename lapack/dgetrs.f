      SUBROUTINE DGETRS( TRANS, N, NRHS, A, LDA, IPIV, B, LDB, INFO )
!$acc routine seq
!$acc routine(DLASWP) seq
!$acc routine(DTRSM) seq
*
*  -- LAPACK routine (version 3.3.1) --
*  -- LAPACK is a software package provided by Univ. of Tennessee,    --
*  -- Univ. of California Berkeley, Univ. of Colorado Denver and NAG Ltd..--
*  -- April 2011                                                      --
*
*     .. Scalar Arguments ..
*      CHARACTER          TRANS(1)
      INTEGER            INFO, LDA, LDB, N, NRHS, TRANS
*     ..
*     .. Array Arguments ..
      INTEGER            IPIV( * )
      DOUBLE PRECISION   A( LDA, * ), B( LDB, * )
*     ..
*
*  Purpose
*  =======
*
*  DGETRS solves a system of linear equations
*     A * X = B  or  A**T * X = B
*  with a general N-by-N matrix A using the LU factorization computed
*  by DGETRF.
*
*  Arguments
*  =========
*
*  TRANS   (input) INTEGER
*          Specifies the form of the system of equations:
*          = 1 --> 'N':  A * X = B  (No transpose)
*          = 2 --> 'T':  A**T* X = B  (Transpose)
*          = 3 --> 'C':  A**T* X = B  (Conjugate transpose = Transpose)
*
*  N       (input) INTEGER
*          The order of the matrix A.  N >= 0.
*
*  NRHS    (input) INTEGER
*          The number of right hand sides, i.e., the number of columns
*          of the matrix B.  NRHS >= 0.
*
*  A       (input) DOUBLE PRECISION array, dimension (LDA,N)
*          The factors L and U from the factorization A = P*L*U
*          as computed by DGETRF.
*
*  LDA     (input) INTEGER
*          The leading dimension of the array A.  LDA >= max(1,N).
*
*  IPIV    (input) INTEGER array, dimension (N)
*          The pivot indices from DGETRF; for 1<=i<=N, row i of the
*          matrix was interchanged with row IPIV(i).
*
*  B       (input/output) DOUBLE PRECISION array, dimension (LDB,NRHS)
*          On entry, the right hand side matrix B.
*          On exit, the solution matrix X.
*
*  LDB     (input) INTEGER
*          The leading dimension of the array B.  LDB >= max(1,N).
*
*  INFO    (output) INTEGER
*          = 0:  successful exit
*          < 0:  if INFO = -i, the i-th argument had an illegal value
*
*  =====================================================================
*
*     .. Parameters ..
      DOUBLE PRECISION   ONE
      PARAMETER          ( ONE = 1.0D+0 )
*     ..
*     .. Local Scalars ..
      LOGICAL            NOTRAN
*     ..
*     .. External Functions ..
*      LOGICAL            LSAME
*      EXTERNAL           LSAME
*     ..
*     .. External Subroutines ..
      EXTERNAL           DLASWP, DTRSM, XERBLA
*     ..
*     .. Intrinsic Functions ..
      INTRINSIC          MAX
*     ..
*     .. Executable Statements ..
*
*     Test the input parameters.
*
      INFO = 0
*      NOTRAN = LSAME( TRANS, 'N' )
      NOTRAN = TRANS == 1
      IF( .NOT.NOTRAN .AND. .NOT. TRANS == 2 .AND. .NOT.
     $    TRANS == 3 ) THEN
         INFO = -1
*      ELSE IF( N.LT.0 ) THEN
*         INFO = -2
      ELSE IF( NRHS.LT.0 ) THEN
         INFO = -3
      ELSE IF( LDA.LT.MAX( 1, N ) ) THEN
         INFO = -5
      ELSE IF( LDB.LT.MAX( 1, N ) ) THEN
         INFO = -8
      END IF
*      !IF( INFO.NE.0 ) THEN
*      !   CALL XERBLA( 'DGETRS', -INFO )
*      !   RETURN
*      !END IF
*
*     Quick return if possible
*
*      IF( N.EQ.0 .OR. NRHS.EQ.0 )
*     $   RETURN
*
      IF( NOTRAN ) THEN
*
*        Solve A * X = B.
*
*        Apply row interchanges to the right hand sides.
*
         CALL DLASWP( NRHS, B, LDB, 1, N, IPIV, 1 )
*
*        Solve L*X = B, overwriting B with X.
*
*!         CALL DTRSM( 'Left', 'Lower', 'No transpose', 'Unit', N, NRHS,
         CALL DTRSM( 1, 2, 1, 1, N, NRHS,
     $               ONE, A, LDA, B, LDB )
*
*        Solve U*X = B, overwriting B with X.
*
*!         CALL DTRSM( 'Left', 'Upper', 'No transpose', 'Non-unit', N,
         CALL DTRSM( 1, 1, 1, 2, N,
     $               NRHS, ONE, A, LDA, B, LDB )
      ELSE
*
*        Solve A**T * X = B.
*
*        Solve U**T *X = B, overwriting B with X.
*
*!         CALL DTRSM( 'Left', 'Upper', 'Transpose', 'Non-unit', N, NRHS,
         CALL DTRSM( 1, 1, 2, 2, N, NRHS,
     $               ONE, A, LDA, B, LDB )
*
*        Solve L**T *X = B, overwriting B with X.
*
*!         CALL DTRSM( 'Left', 'Lower', 'Transpose', 'Unit', N, NRHS, ONE,
         CALL DTRSM( 1, 2, 2, 1, N, NRHS, ONE,
     $               A, LDA, B, LDB )
*
*        Apply row interchanges to the solution vectors.
*
         CALL DLASWP( NRHS, B, LDB, 1, N, IPIV, -1 )
      END IF
*
      RETURN
*
*     End of DGETRS
*
      END
