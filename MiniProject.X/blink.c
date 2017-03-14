//****************************************************************************
//Filename:		BasicBlink.c
//Author:		jpk
//Date:  		9-21-16
//Version:		1.0
//Device:		16f18324
//Description:	Blink an LED using a time wasting loop 5Hz
//Complier:		XC8
//
//****************************************************************************


//****************************************************************************
// Configuration
// Window -> PIC Memory Views -> Configuration Bits
//****************************************************************************
// CONFIG1
#pragma config FEXTOSC = OFF    // FEXTOSC External Oscillator mode Selection bits->Oscillator not enabled
#pragma config RSTOSC = HFINT1    // Power-up default value for COSC bits->HFINTOSC
#pragma config CLKOUTEN = OFF    // Clock Out Enable bit->CLKOUT function is disabled; I/O or oscillator function on OSC2
#pragma config CSWEN = ON    // Clock Switch Enable bit->Writing to NOSC and NDIV is allowed
#pragma config FCMEN = ON    // Fail-Safe Clock Monitor Enable->Fail-Safe Clock Monitor is enabled

// CONFIG2
#pragma config MCLRE = ON    // Master Clear Enable bit->MCLR/VPP pin function is MCLR; Weak pull-up enabled
#pragma config PWRTE = OFF    // Power-up Timer Enable bit->PWRT disabled
#pragma config WDTE = OFF    // Watchdog Timer Enable bits->WDT disabled; SWDTEN is ignored
#pragma config LPBOREN = OFF    // Low-power BOR enable bit->ULPBOR disabled
#pragma config BOREN = ON    // Brown-out Reset Enable bits->Brown-out Reset enabled, SBOREN bit ignored
#pragma config BORV = LOW    // Brown-out Reset Voltage selection bit->Brown-out voltage (Vbor) set to 2.45V
#pragma config PPS1WAY = ON    // PPSLOCK bit One-Way Set Enable bit->The PPSLOCK bit can be cleared and set only once; PPS registers remain locked after one clear/set cycle
#pragma config STVREN = ON    // Stack Overflow/Underflow Reset Enable bit->Stack Overflow or Underflow will cause a Reset
#pragma config DEBUG = OFF    // Debugger enable bit->Background debugger disabled

// CONFIG3
#pragma config WRT = OFF    // User NVM self-write protection bits->Write protection off
#pragma config LVP = ON    // Low Voltage Programming Enable bit->Low Voltage programming enabled. MCLR/VPP pin function is MCLR. MCLRE configuration bit is ignored.

// CONFIG4
#pragma config CP = OFF    // User NVM Program Memory Code Protection bit->User NVM code protection disabled
#pragma config CPD = OFF    // Data NVM Memory Code Protection bit->Data NVM code protection disabled

//****************************************************************************
// Includes
//****************************************************************************
#include <xc.h>
#include <stdint.h>
#include <stdbool.h>

//****************************************************************************
// Defines
//****************************************************************************
#define _XTAL_FREQ  4000000

//****************************************************************************
// Global Variables
//****************************************************************************
uint16_t count = 0;

//****************************************************************************
// Main
//****************************************************************************
void main(void)
{     
    OSCCON1 = 0x60; // HFINTOSC   
    OSCFRQ = 0x03;  // HFFRQ 4_MHz; 
    
    TRISC = 0b11111111;
    T0CON0 = 0b10000000;
    T0CON1 = 0b01001001;
    
    TRISC5 = 0;
    RC5PPS = 0b00010;
    PPSLOCK = 1;
    
    ADCON0 = 0b0001001; //AN2
    ADCON1 = 0b01010000; //Fosc/4
    
    PR2 = 0b11111111;
    TMR2ON = 1;
    PWM5DCH = 0;
    PWM5CON = 0b10000000;
    
    
    TMR0H = 155;
   
    GIE = 1;
    PEIE = 1;
    TMR0IE = 1;
    
    //ADGO = 1;
    
    while (1)
    {
    }
}

void interrupt my_sir(void)
{
    if(TMR0IF && TMR0IE)
    {
        ADGO = 1;
        __delay_us(15);
        TMR0IF = 0;
        PWM5DCH = ADRESH;
        //ADGO = 0;
    }
}
