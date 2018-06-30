
TARGET = control_hdr
CROSS_COMPILE = arm-linux-gnueabihf-
CFLAGS = -std=c++11 -pthread
CC = $(CROSS_COMPILE)g++
ARCH= arm

all:
	$(CC) $(CFLAGS) main.cpp initial_reg_camera_1280x720.c -o $(TARGET)
