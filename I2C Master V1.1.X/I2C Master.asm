//I2C code for: Read, Write, Wait, Fail, Send_Byte//
//Created 3/3/17, Benjamin Hunt
//Source: Microchip PDF

#define LC01CTRLIN H'A0' //Control In byte, LSB set to 0
#define LC01CTRLOUT H'A1' //Control Out byte, LSB set to 1
    
#define LC01ADDR H'12' //Slave address
#define LC01DATA H'34' //Data to be sent, will constantly change in real applicaiton
    
#define BAUD D'100' //Set baud rate
#define FOSC D'4000' //Set oscillator
    
//#include <p24F16.h> //PIC24F16KL401
    
    __CONFIG _CP_OFF & _DEBUG_OFF & _WRT_ENABLE_OFF &
_CPD_OFF & _LVP_OFF & _BODEN_OFF & _PWRTE_ON & _WDT_OFF &
_XT_OSC
    
ORG 0
    
//***Setup I/O***//
    clrf    PORTB //PortB pins set low
    BANKSEL TRISC
    mov	    B'00011000', W0 //RC3,RC4 are inputs
    mov	    W0, TRISC
    
    clrf    TRISB //all PortB pins are outputs
    
//***Setup Registers***//
    BANKSEL SSPCON
    mov	    B'00101000', W0 //sets SSPEN and SSPM3
    mov	    W0, SSPCON //loads W into SSPCON
    
//Input Levels and Slew Rate//
    BANKSEL SSPSTAT
    mov	    B'10000000', W0 //sets slew rate (SMP bit) to 1(off)
    mov	    W0, SSPSTAT
    
//Configure Baud rate//
    BANKSEL SSPADD
    mov	    (FOSC / (4 * BAUD)) - 1, W0
    mov	    W0, SSPADD
    
I2CWrite
    //Send START and wait to complete
    BANKSEL SSPCON2
    bset    SSPCON2, SEN
    call    WaitMSSP
  
    //Send and check Control In byte, wait
    mov	    LC01CTRLIN, W0 //load control byte into W
    call    Send_Byte
    call    WaitMSSP
    
    BANKSEL SSPCON2 //load SSPCON2
    btsc    SSPCON2, ACKSTAT //check ACK bit
    goto    I2CFail
    
    //Send and check address byte, wait
    mov     LC01ADDR, W0
    call    Send_Byte
    call    WaitMSSP
    
    BANKSEL SSPCON2
    btsc    SSPCON2, ACKSTAT
    goto    I2CFail
    
    //Send and check data byte, wait
    mov     LC01DATA, W0
    call    Send_Byte
    call    WaitMSSP
    
    BANKSEL SSPCON2
    btsc    SSPCON2, ACKSTAT
    goto    I2CFail
    
    //Send and check STOP, wait 
    BANKSEL SSPCON2
    bset    SSPCON2, PEN //sends stop condition
    call    WaitMSSP
    
I2CRead
    //start by sending RESTART, wait
    BANKSEL SSPCON2
    bset    SSPCON2, RSEN //send RESTART bit
    call    WaitMSSP
    
    //Send and check Control Ib byte, wait
    mov     LC01CTRLIN, W0
    call    Send_Byte
    call    WaitMSSP
    
    //Check if slave is ready to transfer
    BANKSEL SSPCON2
    btsc    SSPCON2, ACKSTAT //check ACK bit. If fail, restart I2CRead
    goto    I2CRead
    
    //If passes check, send and check address byte, wait
    mov     LC01ADDR, W0
    call    Send_Byte
    call    WaitMSSP
    
    BANKSEL SSPCON2
    btsc    SSPCON2, ACKSTAT
    goto    I2CFAIL
    
    //Send RESTART to start again
    bset    SSPCON2, RSEN
    call    WaitMSSP
    
    //Send and check Control Out byte, wait
    mov     LC01CTRLOUT, W0
    call    Send_Byte
    call    WaitMSSP
    
    BANKSEL SSPCON2
    btsc    SSPCON2, ACKSTAT
    goto    I2CFail
    
    //Switch MSSP to receive mode
    bset    SSPCON2, RCEN
    
    //Wait for data transfer to complete
    //Data is in the SSPBUF, receive mode is disabled automatically at the end 
    //of the transfer by the MSSP
    call    WaitMSSP
    
    //sned NACK to acknowledging the sequence
    BANKSEL SSPCON2
    bset    SSPCON2, ACKDT //ACK Data set to '1' (NACK)
    bset    SSPCON2, ACKEN //send ACK Data now
    
    //Send and check STOP, wait
    bset    SSPCON2, PEN
    call    WaitMSSP
    
    //Get data from SSPBUF
    BANKSEL SSPBUF
    mov     SSPBUF, W0 //move data from SSPBUF to W
    mov     W0, ______	//move read value to variable
    
    
//**********Subroutines*********//
I2CFail //STOP is sent and entire cod is restarted
    BANKSEL SSPCON2
    bset    SSPCON2, PEN //send STOP
    call    WaitMSSP
    retlw   0
    
//Sends W to SSPBUF, this sending the byte. SSPIF flag is checked to ensure the byte
//has been sent
Send_Byte
    BANKSEL SSPBUF
    mov     SSPBUF, W0
    retlw   0
    
//Wait subroutine, check if I2C comms are complete
WaitMSSP
    BANKSEL PIR1
    btss    PIR1, SSPIF //chekc if operation is done
    goto    $-1
    bclr    PIR1,SSPIF
    retlw   0
    
    
    
    
    


    




