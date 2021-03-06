      SUBROUTINE DMPY (Z,ZD)
C
C     DMPY WILL PRE OR POST MULTIPLY AN ARBITRARY MATRIX BY A DIAGONAL
C     MATRIX.
C
C     FILEA = MATRIX CONTROL BLOCK FOR DIAGONAL MATRIX.
C     FILEB = MATRIX CONTROL BLOCK FOR ARBITRARY MATRIX.
C     FILEC = MATRIX CONTROL BLOCK FOR PRODUCT MATRIX.
C     Z     = ADDRESS OF A BLOCK OF CORE FOR WORKING SPACE. ZD IS SAME
C             BLOCK.
C     NZ    = LENGTH OF THIS BLOCK.
C     FLAG .EQ. 0 FOR PRE-MULTIPLICATION BY DIAGONAL.
C     FLAG .NE. 0 FOR POST-MULTIPLICATION BY DIAGONAL.
C     SIGN .EQ. +1 FOR POSITIVE PRODUCT.
C     SIGN .EQ. -1 FOR NEGATIVE PRODUCT.
C
C
      INTEGER          FILEA ,FILEB ,FILEC ,FLAG  ,SIGN  ,SYSBUF,EOL   ,
     1                 EOR   ,TYPE  ,ONE   ,Z(1)  ,RD    ,RDREW ,WRT   ,
     2                 BUF1  ,BUF2  ,CLSREW,RCC   ,PTYPE ,QTYPE ,WRTREW
      DOUBLE PRECISION ZD(1) ,AD    ,XD
      DIMENSION        FILEA(7)     ,FILEB(7)     ,FILEC(7)
      COMMON /DMPYX /  FILEA ,FILEB ,FILEC ,NZ    ,FLAG  ,SIGN
      COMMON /NAMES /  RD    ,RDREW ,WRT   ,WRTREW,CLSREW
      COMMON /ZNTPKX/  AD (2),I     ,EOL   ,EOR
      COMMON /ZBLPKX/  XD (2),IX
      COMMON /UNPAKX/  TYPE  ,ONE   ,NX    ,INCR
      COMMON /SYSTEM/  SYSBUF
C
C
C     PERFORM GENERAL INITIALIZATION
C
      BUF1 = NZ - SYSBUF + 1
      BUF2 = BUF1 - SYSBUF
      ONE  = 1
      INCR = 1
      FILEC(2) = 0
      FILEC(6) = 0
      FILEC(7) = 0
      NX = FILEA(3)
C
C     COMPUTE TYPE OF C MATRIX.
C     RCC = 1 FOR REAL, = 2 FOR COMPLEX
C     QTYPE = 2 FOR RDP, = 4 FOR CDP
C
      RCC = 0
      IF (FILEA(5).GT.2 .OR. FILEB(5).GT.2) RCC = 2
      QTYPE = RCC + 2
      IF (RCC .EQ. 0) RCC = 1
      TYPE  = QTYPE*SIGN
      PTYPE = FILEC(5)
C
C     OPEN PRODUCT MATRIX AND WRITE HEADER RECORD.
C
      CALL GOPEN (FILEC(1),Z(BUF1),WRTREW)
C
C     UNPACK DIAGONAL MATRIX IN CORE AND OPEN ARBITRARY MATRIX.
C
      CALL GOPEN (FILEA(1),Z(BUF2),RDREW)
      CALL UNPACK (*130,FILEA,Z)
      CALL CLOSE (FILEA(1),CLSREW)
      CALL GOPEN (FILEB(1),Z(BUF2),RDREW)
C
C     PERFORM MATRIX MULTIPLICATION.
C
      J  = 1
   60 KR = (J-1)*RCC + 1
      CALL BLDPK (QTYPE,PTYPE,FILEC(1),0,0)
      CALL INTPK (*90,FILEB(1),0,QTYPE,0)
   70 CALL ZNTPKI
      KL = (I-1)*RCC + 1
      K  = KL
      IF (FLAG .NE. 0) K = KR
      XD(1) = ZD(K)*AD(1)
      IF (RCC .EQ. 1) GO TO 80
      XD(1) = XD(1) - ZD(K+1)*AD(2)
      XD(2) = ZD(K)*AD(2) + ZD(K+1)*AD(1)
   80 IX = I
      CALL ZBLPKI
      IF (EOL .EQ. 0) GO TO 70
   90 CALL BLDPKN (FILEC(1),0,FILEC)
      J = J + 1
      IF (J .LE. FILEB(2)) GO TO 60
      GO TO 140
C
C     CODE FOR NULL DIAGONAL MATRIX.
C
  130 CALL BLDPKN (FILEC(1),0,FILEC)
      IF (FILEC(2) .LT. FILEB(2)) GO TO 130
C
C     CLOSE FILES AND RETURN.
C
  140 CALL CLOSE (FILEA(1),CLSREW)
      CALL CLOSE (FILEB(1),CLSREW)
      CALL CLOSE (FILEC(1),CLSREW)
      RETURN
      END
