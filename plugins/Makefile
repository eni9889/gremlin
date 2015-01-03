export TARGET=iphone:clang:latest:6.0
export THEOS_DEVICE_PORT=22
export GO_EASY_ON_ME=1
export ARCHS = armv7 armv7s arm64

# Support scan-build, which interposes CC/CXX variables
#CXX ?= xcrun -sdk iphoneos clang++
#CC ?= xcrun -sdk iphoneos clang

#export TARGET_CXX = $(CXX)
#export TARGET_CC = $(CC)

include $(THEOS)/makefiles/common.mk

SUBPROJECTS = contacts photos videos itunes docs

include $(THEOS_MAKE_PATH)/aggregate.mk
