// testlu.cpp : アプリケーションのエントリ ポイントを定義します。
//

//#include "stdafx.h"
#define	_CRT_SECURE_NO_WARNINGS
#include <windows.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <conio.h>
#include <iostream>    
#include <windows.h>
#include <string>

unsigned int swapbits(unsigned int a) {
	a &= 0xff;
	unsigned int b = 0;
	for (int i = 0; i < 8; i++, a >>= 1, b <<= 1) b |= (a & 1);
	return b >> 1;
}

#define POLY 0x8408
unsigned int crc16(BYTE *data_p, unsigned short length, unsigned int crc)
{
	unsigned char i;
	unsigned int data;
	if (length == 0)
		return crc;
	do {
		for (i = 0, data = (unsigned int)0xff & *data_p++; i < 8; i++, data <<= 1) {
			if ((crc & 0x0001) ^ ((data >> 7) & 0x0001))
				crc = (crc >> 1) ^ POLY;
			else  crc >>= 1;
		}
	} while (--length);
	return crc;
}

unsigned int crc16b(BYTE *data_p, unsigned short length, unsigned int crc) {
	byte c[16], newcrc[16];
	byte d[8];
	for (int j = 0; j < 16; j++) c[j] = (crc >> (15 - j)) & 1;

	for (int i = 0; i < length; i++) {
		for (int j = 0; j < 8; j++) d[j] = (data_p[i] >> j) & 1;

		newcrc[0] = d[4] ^ d[0] ^ c[8] ^ c[12];
		newcrc[1] = d[5] ^ d[1] ^ c[9] ^ c[13];
		newcrc[2] = d[6] ^ d[2] ^ c[10] ^ c[14];
		newcrc[3] = d[7] ^ d[3] ^ c[11] ^ c[15];
		newcrc[4] = d[4] ^ c[12];
		newcrc[5] = d[5] ^ d[4] ^ d[0] ^ c[8] ^ c[12] ^ c[13];
		newcrc[6] = d[6] ^ d[5] ^ d[1] ^ c[9] ^ c[13] ^ c[14];
		newcrc[7] = d[7] ^ d[6] ^ d[2] ^ c[10] ^ c[14] ^ c[15];
		newcrc[8] = d[7] ^ d[3] ^ c[0] ^ c[11] ^ c[15];
		newcrc[9] = d[4] ^ c[1] ^ c[12];
		newcrc[10] = d[5] ^ c[2] ^ c[13];
		newcrc[11] = d[6] ^ c[3] ^ c[14];
		newcrc[12] = d[7] ^ d[4] ^ d[0] ^ c[4] ^ c[8] ^ c[12] ^ c[15];
		newcrc[13] = d[5] ^ d[1] ^ c[5] ^ c[9] ^ c[13];
		newcrc[14] = d[6] ^ d[2] ^ c[6] ^ c[10] ^ c[14];
		newcrc[15] = d[7] ^ d[3] ^ c[7] ^ c[11] ^ c[15];

		memcpy(c, newcrc, 16);
	}

	unsigned int r = 0;
	for (int j = 0; j < 16; j++) r = r * 2 + c[j];
	return r;
}

size_t FormatPacket(byte *buf, int address, const void *data, int data_size) {
	byte *org = buf;
	while (data_size) {
		int n = data_size > 256 ? 256 : data_size;
		int cksum = address + n;
		buf[1] = address;
		buf[2] = n;
		for (int i = 0; i < n; i++) {
			int v = ((byte*)data)[i];
			buf[i + 3] = v;
			cksum += v;
		}
		buf[0] = -cksum;
		buf += n + 3;
		data = (char*)data + n;
		data_size -= n;
	}
	return buf - org;
}

void WritePacket(HANDLE h, int address, const void *data, size_t data_size) {
	byte buf[(3 + 64) * 256];
	size_t n = FormatPacket(buf, address, data, data_size);
	DWORD written;
	if (!WriteFile(h, buf, n, &written, NULL) || written != n) {
		printf("WriteFile failed\n");
		return;
	}
}

HANDLE hStdin;
DWORD fdwSaveOldMode;

VOID KeyEventProc(KEY_EVENT_RECORD ker){
	printf("Key event: ");
	if (ker.bKeyDown)
		 printf("key pressed  %c\n", ker.uChar);
	else printf("key released %c\n", ker.uChar);
}

void keytest() {
	DWORD cNumRead, fdwMode, k;
	INPUT_RECORD irInBuf[128];
	int counter = 0;

	hStdin = GetStdHandle(STD_INPUT_HANDLE);
	GetConsoleMode(hStdin, &fdwSaveOldMode);
	SetConsoleMode(hStdin, ENABLE_WINDOW_INPUT);

	while (counter++ <= 100){
		ReadConsoleInput(hStdin, irInBuf, 128, &cNumRead);
		for (k = 0; k < cNumRead; k++) {
			switch (irInBuf[k].EventType) {
			case KEY_EVENT: KeyEventProc(irInBuf[k].Event.KeyEvent);break;
			default       : break;	// ErrorExit("Unknown event type");
			}
		}
	}
	SetConsoleMode(hStdin, fdwSaveOldMode);
}

int main(int argc, char * argv[]) {

	size_t henkansaretamojisu = 0;
	wchar_t wtextname[32] = { 0 };
	char textname[8] = "COM4";
	int  comspeed = 921600;// 460800;// 230400;// 115200;// 2147720;
	int keyuse = 0;

	if (argc >= 3) strcpy(textname, argv[2]);
	if (argc >= 4) keyuse = 1;

	FILE *f;
	errno_t err = fopen_s(&f, argv[1], "rb");
	if (!f) { printf("File open fail %s\n", argv[1]); return 1; }
	printf("Send %s:%dbps  %s\n", textname, comspeed, argv[1]);

    mbstowcs_s(&henkansaretamojisu, wtextname, 32, textname, _TRUNCATE);
	std::wstring comNum;
	std::wstring comPrefix = L"\\\\.\\";
	std::wstring comID = comPrefix + wtextname;

	HANDLE h = CreateFile(comID.c_str(), GENERIC_READ | GENERIC_WRITE, 0, NULL, OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, NULL);
	if (!h) { printf("CreateFile(%s) failed\n", textname); return 0; }

	DCB dcb = { 0 };
	dcb.DCBlength = sizeof(DCB);
	dcb.ByteSize = 8;
	dcb.StopBits = ONESTOPBIT;
	dcb.BaudRate = comspeed;
	dcb.fBinary = TRUE;
	if (!SetCommState(h, &dcb)) { printf("SetCommState failed\n"); return 0; }

	{ char v = 1; WritePacket(h, 0x35, &v, 1); }
	{ char v = 0; WritePacket(h, 0x35, &v, 1); }

	size_t total_read = 0xffffff;//10180;
	size_t pos = 0;

	while (pos < total_read) {
		unsigned char buf[16384 / 8];
		size_t want_read = (total_read - pos) > sizeof(buf) ? sizeof(buf) : (total_read - pos);
		int n = fread(buf, 1, want_read, f);

		if (pos == 0) {	// Read.Start
			printf("Prg:%dKB(%02x)  Chr:%dKB(%02x)  Mapper:%d(%02x %02x)\n", 
				buf[4]*16, buf[4], buf[5]*8, buf[5], ((buf[7] & 0xf0) | (buf[6] >> 4 )),buf[6], buf[7]);
		}

		if (n <= 0) {
			break;
		}
		WritePacket(h, 0x37, buf, n);
		pos += n;
		if(((pos/n) & 0x03)==0) printf(".");
	}
	printf("\nSend %dbyte\n\n", pos);
	if (keyuse == 0) exit(0);

	int last_keys = -1;
	int keys = 0;
	int key = 0, mkey = 0;
	int i, j;

	printf("Please key in for operation\n");
	printf("A:1  B:2  SELCT:3  START:4   (Esc:Eexit)\n\n");

	DWORD cNumRead, fdwMode, k;
	INPUT_RECORD irInBuf[128];
	BOOL keysts;
	DWORD keydat;
	int kpos;
	int counter = 0;
	hStdin = GetStdHandle(STD_INPUT_HANDLE);
	GetConsoleMode(hStdin, &fdwSaveOldMode);
	SetConsoleMode(hStdin, ENABLE_WINDOW_INPUT);

	keys = 0;
	for (;;) {

		BOOL keysts = GetNumberOfConsoleInputEvents( hStdin, &cNumRead);
		if (keysts != 0) {
			ReadConsoleInput(hStdin, irInBuf, 128, &cNumRead);
			for (k = 0; k < cNumRead; k++) {
				switch (irInBuf[k].EventType) {
				case KEY_EVENT: //KeyEventProc(irInBuf[k].Event.KeyEvent);
					KEY_EVENT_RECORD ker = irInBuf[k].Event.KeyEvent;
					keysts = ker.bKeyDown;
					keydat = ker.wVirtualScanCode;
					//printf(" %x %x ", keysts, keydat);
					if (keydat == 0x01) exit(0);
					kpos = 0;
					if (keydat == 0x02) kpos = 0x01;
					if (keydat == 0x03) kpos = 0x02;
					if (keydat == 0x04) kpos = 0x04;
					if (keydat == 0x05) kpos = 0x08;
					if (keydat == 0x48) kpos = 0x10;
					if (keydat == 0x50) kpos = 0x20;
					if (keydat == 0x4b) kpos = 0x40;
					if (keydat == 0x4d) kpos = 0x80;
					if (keydat == 0x33) kpos = 0x01;	// ,
					if (keydat == 0x34) kpos = 0x02;	// .
					if (keydat == 0x1c) kpos = 0x08;	// Ent
					if (keydat == 0x36) kpos = 0x04;	// Shift
					if (kpos != 0) {
						if (keysts == 1) keys = keys | kpos;
						else             keys = keys ^ kpos;
					}
					break;
				default: break;
				}
			}

		}

		j = 1;
		for (i = 0; i < 8; i++) {
			if ((keys & j) != 0) printf(" 1 ");
			else                 printf(" 0 ");
			j = j << 1;
		}
		printf("\r");

		if (keys != last_keys) {
			WritePacket(h, 0x40, &keys, 1);
			last_keys = keys;
		}
		Sleep(1);
	}

	/*
		for (;;) {
			JOYINFOEX joy;
			joy.dwSize = sizeof(joy);
			joy.dwFlags = JOY_RETURNALL;
			if (joyGetPosEx(JOYSTICKID2, &joy) != MMSYSERR_NOERROR) {
				printf("Joystick error!\n");
				return 1;
			}
			unsigned char keys = 0;
			keys |= !!(joy.dwButtons & 4) * 1;
			keys |= !!(joy.dwButtons & 8) * 2;332411
			keys |= !!(joy.dwButtons & 256) * 4;
			keys |= !!(joy.dwButtons & 512) * 8;
			keys |= (joy.dwYpos < 0x4000) * 16;
			keys |= (joy.dwYpos >= 0xC000) * 32;
			keys |= (joy.dwXpos < 0x4000) * 64;
			keys |= (joy.dwXpos >= 0xC000) * 128;

			if (keys != last_keys) {
				printf("Keys %.2x\n", keys);
				WritePacket(h, 0x40, &keys, 1);
				last_keys = keys;
			}
			Sleep(1);
		}
	*/
	SetConsoleMode(hStdin, fdwSaveOldMode);
	return 0;
}

